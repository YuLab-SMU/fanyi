##' @rdname translate
##' @export
bing_translate <- function(x, from = 'en', to = 'zh') {
    vectorize_translator(x, 
      .fun = .bing_translate, 
      from = from, to = to)
}



# set_translate_option(key ="hide", region = 'southeastasia', source = "bing")
# bing_translate("I am superman")   

##' @importFrom httr2 request
##' @importFrom httr2 req_headers
##' @importFrom httr2 req_body_json
##' @importFrom httr2 req_method
##' @importFrom httr2 req_perform
##' @importFrom httr2 resp_body_json
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

    req <- httr2::request(constructed_url) |> httr2::req_url_query(!!!params) |>
           httr2::req_headers(!!!headers) |> httr2::req_body_json(body) |>
           httr2::req_perform()
    res <- req |> httr2::resp_body_json() |> 
           (\(x) { return(x[[1]]$translations) })() |>
           (\(y) { return(y[[1]]$text) })()
    structure(res, class = "bing")
}



##' @method get_translate_text bing
##' @export
get_translate_text.bing <- function(response) {
    response$translations[[1]]$text
}

# .bing_translate2 <- memoise(.bing_translate)

