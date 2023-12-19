##' @rdname translate
##' @export
bing_translate <- function(x, from = 'en', to='zh') {
    res <- vapply(x, .bing_translate, 
            from = from, to = to, 
            FUN.VALUE = character(1)
        )
    names(res) <- NULL
    return(res)
}

# set_translate_option(key ="hide", region = 'southeastasia', source = "bing")
# bing_translate("I am superman")   

# set apikey through translate.r/set_translate_option
.bing_translate <- function(x, from = 'en', to = 'zh') {
    src <- get_translate_appkey('bing')
    api_key <- src$key
    region <- src$region

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
        'Ocp-Apim-Subscription-Region' = region,
        'Content-type' = 'application/json',
        'X-ClientTraceId' = as.character(uuid::UUIDgenerate())
    )

    body <- list(
        list(
        text = x
        )
    )

    response <- httr::POST(url = constructed_url, 
                        query = params, 
                        httr::add_headers(.headers = headers), 
                        body = body, 
                        encode = "json")

    response_content <- httr::content(response, "text")
    parsed_response <- jsonlite::fromJSON(response_content)
    out <- jsonlite::toJSON(parsed_response, auto_unbox = TRUE, pretty = TRUE)
    return(fromJSON(out[[1]])$translations[[1]]$text)
}

