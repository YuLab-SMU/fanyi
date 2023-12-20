##' @rdname translate
##' @export

##' @importFrom jsonlite fromJSON
##' @importFrom httr GET

#Go to https://ai.youdao.com (有道智云) for application of your appid and API key.

youdao_translate <- function(x, from = 'en', to = 'zh-CHS') {
    vapply(x, .youdao_translate, 
           from = from, to = to, 
           FUN.VALUE = character(1))
}

##' @importFrom stringr str_count

truncate_func <- function(x) {
    len <- str_count(x)
    if (len <= 20) {
        return(x)
    } else {
        return(paste0(substring(x, 1, 10), len, substring(x, len-9, len)))
    }
}

##' @importFrom httr GET
##' @importFrom openssl sha256
##' @importFrom jsonlite fromJSON
##' @importFrom utils URLencode

.youdao_translate <- function(x, from = 'en', to = 'zh-CHS') {
    query <- youdao_translate_query(x, from = from, to = to)
    url <- URLencode(query)
    res <- jsonlite::fromJSON(rawToChar(httr::GET(url)$content))
    return(res$translation)
}

youdao_translate_query <- function(x, from = 'en', to = 'zh-CHS', appid, key) {
    salt <- as.character(trunc(as.numeric(Sys.time()) * 1e3))
    curtime <- as.character(trunc(as.numeric(Sys.time())))
    appid <- get_translate_appkey('youdao')$appid
    key <- get_translate_appkey('youdao')$key
    encode_str <- paste0(appid = appid, 
                         truncate_func(x), 
                         salt, 
                         curtime, 
                         key = key)
    signed_str <- as.character(sha256(encode_str))
    query <- paste0("https://openapi.youdao.com/api?q=", x,
                    "&appKey=", appid, 
                    "&salt=", salt, 
                    "&from=", translate_from = from, 
                    "&to=", translate_to = to,
                    "&sign=", signed_str, 
                    "&signType=v3&curtime=", curtime)
    return(query)
}
