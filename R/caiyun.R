##' @rdname translate
##' @export
caiyun_translate <- function(x, from = 'auto', to = 'zh') {
    vectorize_translator(x, 
      .fun = .caiyun_translate, 
      from = from, to = to)
}



# set_translate_option(key ="********", source = "caiyun")

##' @importFrom httr2 request
##' @importFrom httr2 req_headers
##' @importFrom httr2 req_body_json
##' @importFrom httr2 req_perform
##' @importFrom httr2 resp_body_json
# set apikey through translate.r/set_translate_option
.caiyun_translate <- function(x, from = 'auto', to = 'zh') {
    src <- get_translate_appkey('caiyun')
    token <- src$key
    base_url <- 'http://api.interpreter.caiyunai.com/v1/translator'
    
    body <- list(
        'source' = x,
        'trans_type' = paste0(from, 2, to),
        request_id = 'demo',
        detect = "true"
    )

    headers <- c(
        'content-type' = 'application/json',
        'x-authorization' = paste0("token ", token)
    )

    req <- httr2::request(base_url) |>
           httr2::req_headers(!!!headers) |> 
           httr2::req_body_json(body) |>
           httr2::req_perform()
    res <- req |> httr2::resp_body_json() 
    structure(res, class = "caiyun")
}

##' @method get_translate_text caiyun
##' @export
get_translate_text.caiyun <- function(response) {
    response$target[1]
}
