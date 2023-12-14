#' @rdname baidu-translate
#' @export
en2cn <- function (x) {
    baidu_translate(x, from = 'en', to = 'zh')
}

#' @rdname baidu-translate
#' @export
cn2en <- function (x) {
    baidu_translate(x, from = 'zh', to = 'en')
}

#' set appid and key of translation engine
#' 
#' This function allows users to use their own appid and key
#' @title set_translate_option
#' @rdname set-translate-option
#' @param appid appid
#' @param key app key
#' @param source translation engine, currently only 'baidu' is supported
#' @return NULL
#' @author Guangchuang Yu 
#' @export
set_translate_option <- function(appid, key, source = "baidu") {
    if (source != "baidu") stop ("currently, only baidu is supported")

    set_translate_source(source)
    set_translate_appkey(appid, key)
}

set_translate_source <- function(source) {
    options(yulab_translate_source = source)
}

set_translate_appkey <- function(appid, key) {
    options(yulab_translate = list(appid = appid, key = key))
}

get_translate_source <- function() {
    getOption('yulab_translate_source', "baidu")
}

get_translate_appkey <- function() {
    res <- getOption('yulab_translate')
    if (!is.null(res)) return(res)

    src <- get_translate_source()
    if (src == "baidu") {
        # res <- getOption('yulab_translate', .baidu_appkey)
        res <- getOption('yulab_translate')
    }

    if (is.null(res)) stop("Please set your appid and key via set_translate_appkey()")

    return(res)
}




#' Translate query sentence
#' 
#' This function use the Baidu fanyi API to translate query sentences
#' @title baidu_translate
#' @rdname baidu-translate
#' @param x query sentence
#' @param from source language, i.e., the language to be translated
#' @param to target language, i.e., the language to be translated into
#' @return the translated sentence
#' @author Guangchuang Yu 
#' @export
baidu_translate <- function(x, from = 'en', to = 'zh') {
    vapply(x, .baidu_translate, from = from, to = to, FUN.VALUE = character(1))
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
    .info <- get_translate_appkey()
    sign <- sprintf("%s%s%s%s", .info$appid, x, salt, .info$key)
    .sign <- openssl::md5(sign)

    .query <- list(q = x, from = from, to = to,
                    appid = .info$appid, 
                    salt = salt, 
                    sign = .sign
                )
    return(.query)
}

