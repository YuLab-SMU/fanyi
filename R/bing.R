library(httr)
library(jsonlite)
 

# set apikey through translate.r/set_translate_option
bing_translate_text <- function(api_key, location, text_to_translate, from = 'en', to = 'zh') {
    endpoint <- 'https://api.cognitive.microsofttranslator.com'
    path <- '/translate'
    constructed_url <- paste0(endpoint, path)
    params <- list(
        'api-version' = '3.0',
        'from' = from,
        'to' = to
    )
    headers <- c(
        'Ocp-Apim-Subscription-Key' = api_key,
        'Ocp-Apim-Subscription-Region' = location,
        'Content-type' = 'application/json',
        'X-ClientTraceId' = as.character(uuid::UUIDgenerate())
    )
    body <- list(
        list(
        text = text_to_translate
        )
    )
    response <- httr::POST(url = constructed_url, query = params, httr::add_headers(.headers = headers), body = body, encode = "json")
    response_content <- httr::content(response, "text")
    parsed_response <- jsonlite::fromJSON(response_content)
    out <- jsonlite::toJSON(parsed_response, auto_unbox = TRUE, pretty = TRUE)
    return(fromJSON(out[[1]])$translations[[1]]$text)
}
