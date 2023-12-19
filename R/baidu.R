##' @rdname translate
##' @export
baidu_translate <- function(x, from = 'en', to = 'zh') {
    res <- vapply(x, .baidu_translate, 
            from = from, to = to, 
            FUN.VALUE = character(1)
        )
    names(res) <- NULL
    return(res)
}

##' @importFrom jsonlite fromJSON
##' @importFrom httr modify_url
.baidu_translate <- function(x, from = 'en', to = 'zh') {
    url <- httr::modify_url("http://api.fanyi.baidu.com/api/trans/vip/translate",
            query = baidu_translate_query(x, from = from, to = to)
        )
    url <- url(url, encoding = "utf-8")
    res <- jsonlite::fromJSON(url)
    
    return(res$trans_result$dst)
}

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


