##' @rdname translate
##' @export
chatglm_translate <- function(x, from = 'en', to = 'zh') {
  vectorize_translator(x,
                       .fun = .chatglm_translate_query,
                       from = from, to = to)
}

#' @method get_translate_text chatglm
#' @export
get_translate_text.chatglm <- function(response) {
  response
}

##' @importFrom httr2 request
##' @importFrom httr2 req_headers
##' @importFrom httr2 req_body_raw
##' @importFrom httr2 req_method
##' @importFrom httr2 req_perform_stream
##' @importFrom jsonlite toJSON
##' @importFrom jsonlite unbox
##' @importFrom SSEparser SSEparser
##' @importFrom SSEparser parse_sse
##' @importFrom openssl sha2
##' @importFrom purrr map
#for help, visit: https://open.bigmodel.cn/dev/api#nosdk
.chatglm_query <- function(prompt, model = NULL, api_key = NULL, max_tokens = NULL, ...) {
  .key_info <- get_translate_appkey('chatglm')
  
  if (is.null(model)) {
      # Try to use user_model from settings if available, otherwise default
      user_model <- if (!is.null(.key_info$user_model)) .key_info$user_model else "glm-4"
  } else {
      user_model <- model
  }
  
  # Ensure prompt is in the correct format (list of messages)
  if (!is.list(prompt) || (is.list(prompt) && length(prompt) > 0 && is.character(prompt[[1]]))) {
      # If prompt is a character vector or a list of characters (not message objects)
      
      # Case 1: prompt is a simple character string -> wrap it
      if (is.character(prompt)) {
          prompt <- list(list(role = "user", content = prompt))
      } 
      # Case 2: prompt is a single message object list(content=..., role=...) -> wrap in list()
      else if (is.list(prompt) && "role" %in% names(prompt) && "content" %in% names(prompt)) {
          prompt <- list(prompt)
      }
      # Case 3: prompt is already list(list(role=..., content=...), ...) -> do nothing
  }
  
  url <- "https://open.bigmodel.cn/api/paas/v4/chat/completions"
  header <- list("alg" = "HS256",
                 "sign_type" = "SIGN")
                 
  key_to_use <- if (!is.null(api_key)) api_key else .key_info$key
  if (is.null(key_to_use)) stop("API key for chatglm is missing.")
  
  .token <- unlist(strsplit(key_to_use, split= "[.]"))

  secret <- .token[2]
  id <- .token[1]

  timeStamp <- trunc(as.numeric(Sys.time()) * 1e3)
  payload <- list("api_key" = id,
                  "exp" = as.numeric(timeStamp) + (1e3 * 60),
                  "timestamp" = timeStamp)
  ### partial jwt implementation of r-lib/jose
  base64url_encode <- (\(x) sub("=+$", 
                                "", 
                                chartr('+/', 
                                       '-_', 
                                       openssl::base64_encode(x))))
  token <- base64url_encode(openssl::sha2(charToRaw(paste(base64url_encode(jsonlite::toJSON(header,  auto_unbox = TRUE)),
                                                          base64url_encode(jsonlite::toJSON(payload, auto_unbox = TRUE)),
                                                          sep = ".")
                                                    ),
                                          key = secret,
                                          size = 256))
  
  auth_header <- paste(base64url_encode(jsonlite::toJSON(header,  auto_unbox = TRUE)),
                       base64url_encode(jsonlite::toJSON(payload, auto_unbox = TRUE)),
                       token,
                       sep = ".")

  body <- list("messages" = prompt,
               "model"    = user_model,
               "stream"   = "false"
              )
  if (!is.null(max_tokens)) {
      body$max_tokens <- max_tokens
  }
  
  body_json <- jsonlite::toJSON(body, auto_unbox = TRUE)
  
  headers <- c("Content-Type" = "application/json",
                  "Authorization"= auth_header)
  
  req <- httr2::request(url) |>
    httr2::req_headers(!!!headers) |>
    httr2::req_body_raw(body_json) |>
    httr2::req_perform()

  res_temp <- req |> resp_body_json()
  return(res_temp$choices[[1]]$message$content)
}

.chatglm_translate_query <- function(x, from = 'en', to = 'zh') {
  if (to == 'zh') {
    sep <- ''
  } else {
    sep <- ' '
  } 

  from <- .lang_map(from)
  to   <- .lang_map(to)  
  .prefix <- sprintf("Translate into %s", to)
  prompt <- .chatglm_prompt_translate(x, prefix = .prefix, role = 'user')
  parser <- .chatglm_query(prompt)

  structure(parser, class = "chatglm")
}

# .chatglm_summarize_query <- function(x) {
#   prompt <- .chatglm_prompt_summarize(x, role = 'user')
#   parser <- .chatglm_query(prompt)
#   .get_chatglm_data(parser)
# }

.chatglm_prompt_summarize <- function(x, prefix = "Summarize the sentences", role = 'user') {
  list(list(content = "You are a text summarizer, you can only summarize the text, never interpret it.",
            role   = "user"),
      list(content = 'Ok, I will only summarize the text,never interpret it.',
          role   = "assistant"),
      list(content = if(is.null(prefix)) x else sprintf("%s\n\"\"\"%s\"\"\"", prefix, x), role = role)
  )
}


.chatglm_prompt_translate <- function(x, prefix = NULL, role = 'user') {
  list(list(content = "You are a professional translation engine, please translate the text into a colloquial, professional, elegant and fluent content, without the style of machine translation. You must only translate the text content, never interpret it.",
            role    = "user"),
      list(content = "Ok, I will only translate the text content, never interpret it.",
            role    = "assistant"),
      list(content = if(is.null(prefix)) x else sprintf("%s\n\"\"\"%s\"\"\"", prefix, x), role = role)
  )
}

.chatglm_prompt <- function(x, prefix=NULL, role = 'user') {
  if (is.null(prefix)) {
    content = x
  } else {
    content <- sprintf("%s\n\"\"\"%s\"\"\"", prefix, x)
  }

  list(list(content = content, role = role))
}
