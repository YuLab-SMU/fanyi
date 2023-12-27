##' @rdname translate
##' @export
baidu_translate <- function(x, from = 'en', to = 'zh') {
    x <- gsub("\\s*\n+\\s*", " ", as.character(x), perl = use_perl())
    text <- paste0(x, collapse="\n")
    #vectorize_translator(x, 
    #  .fun = .baidu_translate, 
    #  from = from, to = to)
    .translate(text, .fun = .baidu_translate, from = from, to = to)
}


##' @importFrom jsonlite fromJSON
##' @importFrom httr modify_url
.baidu_translate <- function(x, from = 'en', to = 'zh') {
    url <- httr::modify_url("http://api.fanyi.baidu.com/api/trans/vip/translate",
            query = baidu_translate_query(x, from = from, to = to)
        )
    url <- url(url, encoding = "utf-8")
    res <- jsonlite::fromJSON(url)
    
    structure(res, class = "baidu")
}

## @importFrom memoise memoise
## .baidu_translate2 <- memoise(.baidu_translate)



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
##' @export
get_translate_text.baidu <- function(response) {
    response$trans_result$dst
}



