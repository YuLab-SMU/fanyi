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
#for help, visit: https://open.bigmodel.cn/dev/api#nosdk
.chatglm_query <- function(prompt) {
  #user_model <- "turbo"
  .key_info <- get_translate_appkey('chatglm')
  user_model <- .key_info$user_model

  url <- paste0("https://open.bigmodel.cn/api/paas/v3/model-api/", 
                user_model,
                "/", "sse-invoke")
  header <- list("alg" = "HS256",
                 "sign_type" = "SIGN")
  .token <- unlist(strsplit(.key_info$key, split= "[.]"))
  id     <- .token[1]
  secret <- .token[2]

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

  body <- list(prompt = prompt)
  body_json <- jsonlite::toJSON(body, auto_unbox = TRUE)
  headers <- list("Content-Type" = "application/json",
                  "accept"       = "text/event-stream",
                  "Authorization"= auth_header)
  
  parser <- SSEparser$new()
  req <- httr2::request(url) |>
    httr2::req_headers(!!!headers) |>
    httr2::req_body_raw(body_json) |>
    httr2::req_perform_stream(callback = \(x) {
      event <- rawToChar(x)
      parser$parse_sse(event)
      TRUE
    })
  return(parser)
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
  
  # res <- paste(sapply(parser$events, \(x) x[["data"]]), collapse = '')
  res <- .get_chatglm_data(parser, sep)
  structure(res, class = "chatglm")
}

.chatglm_summarize_query <- function(x) {
  prompt <- .chatglm_prompt_summarize(x, role = 'user')
  parser <- .chatglm_query(prompt)
  .get_chatglm_data(parser)
}

.chatglm_prompt_summarize <- function(x, prefix = "Summarize the sentences", role = 'user') {
  list(list(content = "You are a text summarizer, you can only summarize the text, never interpret it.",
            role   = "user"),
      list(content = 'Ok, I will only summarize the text,never interpret it.',
          role   = "assistant"),
      .chatglm_prompt(x, prefix = prefix, role = role)
  )
}


.chatglm_prompt_translate <- function(x, prefix = NULL, role = 'user') {
  list(list(content = "You are a professional translation engine, please translate the text into a colloquial, professional, elegant and fluent content, without the style of machine translation. You must only translate the text content, never interpret it.",
            role    = "user"),
      list(content = "Ok, I will only translate the text content, never interpret it.",
            role    = "assistant"),
      .chatglm_prompt(x, prefix = prefix, role = role)
  )
}

.chatglm_prompt <- function(x, prefix=NULL, role = 'user') {
  if (is.null(prefix)) {
    content = x
  } else {
    content <- sprintf("%s\n\"\"\"%s\"\"\"", prefix, x)
  }

  list(content = content, role = role)
}

.get_chatglm_data <- function(parser, sep = ' ') {
  y <- sapply(parser$events, function(x) {
    i <- rev(which(names(x) == "data"))[1] ## sometimes there are several items named with 'data', get the last one
    if (is.na(i)) return("")
    x[[i]]
  })
  y <- y[y != ""]
  res <- paste(y, collapse = sep) |>
    gsub("\\s+([,\\.])", "\\1", x = _) |> # remove empty space preceeding with punctuation marks
    sub("^\"\\s*", "", x = _) |> # remove quote marks
    sub("\\s*\"$", "", x = _)

  return(res) 
}
