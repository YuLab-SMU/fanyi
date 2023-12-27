##' @rdname translate
##' @export
baidu_translate <- function(x, from = 'en', to = 'zh') {
    vectorize_translator(x, 
      .fun = .baidu_translate2, 
      from = from, to = to)
}


##' @importFrom jsonlite fromJSON
##' @importFrom httr2 request
##' @importFrom httr2 req_url_query
##' @importFrom httr2 req_perform
##' @importFrom httr2 resp_body_json
.baidu_translate <- function(x, from = 'en', to = 'zh') {
    url_prefix <- "http://api.fanyi.baidu.com/api/trans/vip/translate"
    query <- baidu_translate_query(x, from = from, to = to)
    req <- httr2::request(url_prefix) |> httr2::req_url_query(!!!query) |>
           httr2::req_perform()
    res <- req |> httr2::resp_body_json()
    structure(res, class = "baidu")
}


.baidu_translate2 <- memoise(.baidu_translate)



##' @importFrom openssl md5
baidu_translate_query <- function(x, from, to) {
    salt <- sample.int(1e+05, 1) 
    .info <- get_translate_appkey('baidu')
    sign <- sprintf("%s%s%s%s", .info$appid, x, salt, .info$key)
    .sign <- openssl::md5(sign)

    .query <- list(q = x, from = from, to = to,
                    appid = .info$appid, 
                    salt = salt, 
                    sign = .sign
                )
    return(.query)
}


##' @method get_translate_text baidu
get_translate_text.baidu <- function(response) {
    response$trans_result$dst
}



