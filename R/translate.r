#' @rdname translate
#' @export
en2cn <- function (x) {
    translate(x, from = 'en', to = 'zh')
}

#' @rdname translate
#' @export
cn2en <- function (x) {
    translate(x, from = 'zh', to = 'en')
}

#' set appid and key of translation engine
#' 
#' This function allows users to use their own appid and key
#' @title set_translate_option
#' @rdname set-translate-option
#' @param appid appid
#' @param key app key
#' @param source translation engine, currently only 'baidu' is supported
#' @return No return value, called for side effects
#' @author Guangchuang Yu 
#' @export
set_translate_option <- function(appid, key, source = "baidu") {
    if (source != "baidu") stop ("currently, only baidu is supported")

    set_translate_source(source)
    set_translate_appkey(appid, key, source)
}

set_translate_source <- function(source) {
    options(yulab_translate_source = source)
}

set_translate_appkey <- function(appid, key, source) {
    opts <- getOption('yulab_translate', list())
    x <- list()
    x[[source]] <- list(appid = appid, key = key)
    opts <- modifyList(opts, x)
    options(yulab_translate = x)
}

get_translate_source <- function() {
    getOption('yulab_translate_source', "baidu")
}

get_translate_appkey <- function() {
    src <- get_translate_source()

    appkeys <- getOption('yulab_translate', list())

    res <- appkeys[[src]]

    if (is.null(res)) stop("Please set your appid and key via set_translate_appkey()")

    return(res)
}



#' Translate query sentences
#' 
#' This function use online translator API (e.g., Baidu fanyi) to translate query sentences
#' @title translate
#' @rdname translate
#' @param x query sentences
#' @param from source language, i.e., the language to be translated
#' @param to target language, i.e., the language to be translated into
#' @return the translated sentences
#' @examples 
#' library(fanyi)
#' ## set your appid and key once in your R session
#' #
#' # set_translate_option(appid = 'your_appid', key = 'your_key')
#' #
#' # translate('hello world', from = 'en', to = 'zh')
#' @author Guangchuang Yu 
#' @export
translate <- function(x, from = 'en', to = 'zh') {
    src <- get_translate_source()
    if (src == "baidu") {
        res <- baidu_translate(x, from = from, to = to)
    } else {
        stop ("only baidu translate is supported")
    }

    return(res)
}
