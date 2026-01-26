##' @rdname translate
##' @export
dsk_translate <- function(x, from = 'en', to = 'zh') {
  vectorize_translator(
    x,
    .fun = .deepseek_translate_query,
    from = from,
    to = to
  ) |> gsub(pattern = '^"+|"+$', replacement = '', x = _)
}

#' @method get_translate_text deepseek
#' @export
get_translate_text.deepseek <- function(response) {
  # Extract text from the response
  content <- httr2::resp_body_json(response)
  text <- content$choices[[1]]$message$content
  # Remove leading and trailing quote marks
  text <- sub("^\"\\s*", "", text)
  text <- sub("\\s*\"$", "", text)
  return(trimws(text))
}
##' @importFrom httr2 request
##' @importFrom httr2 req_headers
##' @importFrom httr2 req_body_json
##' @importFrom httr2 req_perform
##' @importFrom httr2 resp_body_json
##' @importFrom httr2 resp_body_string
##' @importFrom httr2 resp_status
##' @importFrom jsonlite toJSON
##' @importFrom jsonlite unbox
##' @importFrom SSEparser SSEparser
##' @importFrom SSEparser parse_sse
##' @importFrom openssl sha2
##' @importFrom purrr map

.deepseek_translate_query <- function(x, from = 'en', to = 'zh') {
  if (to == 'zh') {
    sep <- ''
  } else {
    sep <- ' '
  }

  from <- .lang_map(from)
  to <- .lang_map(to)
  .prefix <- sprintf("Translate into %s", to)
  
  # Get the prompt structure
  prompt <- .deepseek_prompt_translate(x, prefix = .prefix, role = 'user')
  
  # Call API with the message list
  result <- .deepseek_query_messages(prompt)
  
  # Return as a classed object, not just character
  class(result) <- c("deepseek", class(result))
  return(result)
}
.deepseek_query_messages <- function(messages, model = NULL, api_key = NULL, max_tokens = 4096, ...) {
  .key_info <- .get_translate_appkey('dsk')
  
  if (is.null(model)) {
    user_model <- .key_info$user_model
    if (is.null(user_model)) user_model <- "deepseek-chat"
  } else {
    user_model <- model
  }
  
  if (is.null(api_key)) {
      api_key <- .key_info$key
  }
  
  if (is.null(api_key)) stop("API key for deepseek is missing.")

  url <- "https://api.deepseek.com/v1/chat/completions"

  body <- list(
    model = user_model,
    messages = messages,
    stream = FALSE,
    max_tokens = max_tokens
  )

  response <- httr2::request(url) |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = paste("Bearer", api_key)
    ) |>
    httr2::req_body_json(body) |>
    httr2::req_perform()

  if (httr2::resp_status(response) != 200) {
    error_content <- httr2::resp_body_json(response)
    error_msg <- if (!is.null(error_content$error$message)) {
      error_content$error$message
    } else {
      httr2::resp_body_string(response)
    }
    stop(sprintf("API request failed: %s", error_msg))
  }

  # Return the full response object, not just text
  # This allows get_translate_text method to extract the translation
  return(response)
}

# Update the .deepseek_query function to work with your current code
.deepseek_query <- function(prompt) {
  # If prompt is already a list of messages, use it directly
  if (is.list(prompt) && all(c("content", "role") %in% names(prompt[[1]]))) {
    return(.deepseek_query_messages(prompt))
  }

  # Otherwise, treat prompt as text and create a simple user message
  .key_info <- get_translate_appkey('dsk')
  user_model <- .key_info$user_model %||% "deepseek-chat"
  api_key <- .key_info$key

  body <- list(
    model = user_model,
    messages = list(
      list(role = "user", content = as.character(prompt))
    ),
    stream = FALSE,
    max_tokens = 1000
  )

  response <- httr2::request("https://api.deepseek.com/v1/chat/completions") |>
    httr2::req_headers(
      "Content-Type" = "application/json",
      "Authorization" = paste("Bearer", api_key)
    ) |>
    httr2::req_body_json(body) |>
    httr2::req_perform()

  if (httr2::resp_status(response) != 200) {
    error_content <- httr2::resp_body_json(response)
    stop(sprintf(
      "API request failed: %s",
      error_content$error$message %||% "Unknown error"
    ))
  }

  content <- httr2::resp_body_json(response)
  return(trimws(content$choices[[1]]$message$content))
}

.deepseek_summarize_query <- function(x) {
  prompt <- .deepseek_prompt_summarize(x, role = 'user')
  parser <- .deepseek_query(prompt)
  .get_deepseek_data(parser)
}

.deepseek_prompt_summarize <- function(
  x,
  prefix = "Summarize the sentences",
  role = 'user'
) {
  list(
    list(
      content = "You are a text summarizer, you can only summarize the text, never interpret it.",
      role = "system"
    ),
    .deepseek_prompt(x, prefix = prefix, role = role)
  )
}


.deepseek_prompt_translate <- function(x, prefix = NULL, role = 'user') {
  # Return a list of two messages: system and user
  list(
    list(
      content = "You are a professional translation engine, please translate the text into a colloquial, professional, elegant and fluent content, without the style of machine translation. You must only translate the text content, never interpret it.",
      role = "system"
    ),
    .deepseek_prompt(x, prefix = prefix, role = role)
  )
}

.deepseek_prompt <- function(x, prefix = NULL, role = 'user') {
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
    if (is.na(i)) {
      return("")
    }
    x[[i]]
  })
  y <- y[y != ""]
  res <- paste(y, collapse = sep) |>
    gsub("\\s+([,\\.])", "\\1", x = _) |> # remove empty space preceeding with punctuation marks
    sub("^\"\\s*", "", x = _) |> # remove quote marks
    sub("\\s*\"$", "", x = _)

  return(res)
}
