##' @rdname translate
##' @export
##' @importFrom jsonlite fromJSON
##' @importFrom httr GET
#Go to https://ai.youdao.com for application of your appid and API key.
youdao_translate <- function(x, from = 'en', to = 'zh-CHS') {
    vectorize_translator(x, .youdao_translate, from = from, to = to)
}


truncate_func <- function(x) {
    len <- nchar(x)
    if (len <= 20) {
        return(x)
    } 

    res <- paste0(substring(x, c(1, len-9), c(10, len)), 
                    collapse=as.character(len))
    return(res)
}


## @importFrom httr GET
##' @importFrom openssl sha256
##' @importFrom jsonlite fromJSON
##' @importFrom utils URLencode
.youdao_translate <- function(x, from = 'en', to = 'zh-CHS') {
    query <- youdao_translate_query(x, from = from, to = to)
    url <- URLencode(query)
    # res <- jsonlite::fromJSON(rawToChar(httr::GET(url)$content))
    res <- jsonlite::fromJSON(url)
    return(res$translation)
}

#' @importFrom httr modify_url
youdao_translate_query <- function(x, from = 'en', to = 'zh-CHS') {
    salt <- as.character(trunc(as.numeric(Sys.time()) * 1e3))
    curtime <- as.character(trunc(as.numeric(Sys.time())))
    .info <- get_translate_appkey('youdao')
    appid <- .info$appid
    key <- .info$key
    encode_str <- paste0(appid = appid, 
                         truncate_func(x), 
                         salt, 
                         curtime, 
                         key = key)
    signed_str <- as.character(sha256(encode_str))
    query = list(q = x,
                appKey = appid, 
                salt = salt, 
                from = from, 
                to = to,
                sign = signed_str, 
                signType = 'v3',
                curtime = curtime)
    
    if (!is.null(.info$out_id)) {
        query$vocabId = .info$out_id
    }

    modify_url("https://openapi.youdao.com/api?", 
                query = query
            )
}
