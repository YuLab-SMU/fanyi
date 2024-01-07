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
.chatglm_translate_query <- function(x, from = 'en', to = 'zh') {
  from <- .lang_map(from)
  to   <- .lang_map(to)
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
  token <- base64url_encode(openssl::sha2(charToRaw(paste(base64url_encode(jsonlite::toJSON(header,  auto_unbox = T)),
                                                          base64url_encode(jsonlite::toJSON(payload, auto_unbox = T)),
                                                          sep = ".")
                                                    ),
                                          key = secret,
                                          size = 256))
  
  auth_header <- paste(base64url_encode(jsonlite::toJSON(header,  auto_unbox = T)),
                       base64url_encode(jsonlite::toJSON(payload, auto_unbox = T)),
                       token,
                       sep = ".")
  body <- list("prompt" = list(list("content" = "You are a professional translation engine, please translate the text into a colloquial, professional, elegant and fluent content, without the style of machine translation. You must only translate the text content, never interpret it.",
                                    "role"    = "user"),
                               list("content" = "Ok, I will only translate the text content, never interpret it.",
                                    "role"    = "assistant"),
                               list("content" = paste("Translate into", to, "\n", 
                                                      "\"\"\"", "\n",
                                                      "hello", "\n",
                                                      "\"\"\"", sep = " "),
                                    "role"    = "user"),
                               list("content" = "\u4f60\u597d", # 你好
                                    "role"    = "assistant"),
                               list("content" = paste("Translate into", 
                                                      to, "\n",
                                                      "\"\"\"", "\n",
                                                      x, "\n",
                                                      "\"\"\"", sep = " "),
                                    "role"    = "user")))
  body_json <- jsonlite::toJSON(body, auto_unbox = T)
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
  res <- paste(sapply(parser$events, \(x) x[["data"]]), collapse = '')
  structure(res, class = "chatglm")
}
