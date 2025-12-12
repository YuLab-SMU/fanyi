##' @rdname translate
##' @export
dsk_translate <- function(x, from = 'en', to = 'zh') {
  vectorize_translator(x,
                       .fun = .deepseek_translate_query,
                       from = from, to = to)
}

#' @method get_translate_text deepseek
#' @export
get_translate_text.deepseek <- function(response) {
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
.deepseek_query <- function(prompt) {
  .key_info <- get_translate_appkey('deepseek')
  user_model <- .key_info$user_model
  api_key <- .key_info$key

  url <- "https://api.deepseek.com/chat/completions"

  body <- list("messages" = prompt,
               "model"    = user_model,
               "stream"   = TRUE)

  body_json <- jsonlite::toJSON(body, auto_unbox = TRUE)
  headers <- list("Content-Type" = "application/json",
                  "Authorization"= paste("Bearer",
                                         api_key,
                                         sep = " "),
                  "Accept"       = "application/json")
  
  parser <- SSEparser$new()
  req <- httr2::request(url) |>
    httr2::req_headers(!!!headers) |>
    httr2::req_body_raw(body_json) |>
    httr2::req_perform_stream(callback = \(x) {
      event <- rawToChar(x)
      parser$parse_sse(event)
      TRUE
    })
  res_temp <- parser$events
  len <- length(res_temp)
  res <- jsonlite::fromJSON(res_temp[[len]]$data)$output$text |> noquote()
  return(res)
}

.deepseek_translate_query <- function(x, from = 'en', to = 'zh') {
  if (to == 'zh') {
    sep <- ''
  } else {
    sep <- ' '
  } 

  from <- .lang_map(from)
  to   <- .lang_map(to)  
  .prefix <- sprintf("Translate into %s", to)
  prompt <- .deepseek_prompt_translate(x, prefix = .prefix, role = 'user')
  message <- list(messages = prompt)
  parser <- .deepseek_query(prompt)

  return(parser)
  # res <- paste(sapply(parser$events, \(x) x[["data"]]), collapse = '')
  #res <- .get_qwen_data(parser, sep)
  #structure(res, class = "qwen")
}

.deepseek_summarize_query <- function(x) {
  prompt <- .deepseek_prompt_summarize(x, role = 'user')
  parser <- .deepseek_query(prompt)
  .get_deepseek_data(parser)
}

.deepseek_prompt_summarize <- function(x, prefix = "Summarize the sentences", role = 'user') {
  list(list(content = "You are a text summarizer, you can only summarize the text, never interpret it.",
            role   = "system"),
       .deepseek_prompt(x, prefix = prefix, role = role)
  )
}


.deepseek_prompt_translate <- function(x, prefix = NULL, role = 'user') {
  list(list(content = "You are a professional translation engine, please translate the text into a colloquial, professional, elegant and fluent content, without the style of machine translation. You must only translate the text content, never interpret it.",
            role    = "system"),
      .deepseek_prompt(x, prefix = prefix, role = role))
}

.deepseek_prompt <- function(x, prefix=NULL, role = 'user') {
  if (is.null(prefix)) {
    content = x
  } else {
    content <- sprintf("%s\n\"\"\"%s\"\"\"", prefix, x)
  }

  list(content = content, role = role)
}

.get_deepseek_data <- function(parser, sep = ' ') {
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
