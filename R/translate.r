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
#' @param appid appid, "bing translate" will not use this input. 
#' @param key app key
#' @param source translation engine
#' @param location this is for bing use only, translation engine location, depends on your Azure service setting
#' @return No return value, called for side effects
#' @author Guangchuang Yu 
#' @export
set_translate_option <- function(appid, key, location="southeastasia", source = "baidu") {
    source <- match.arg(source, c("baidu", "bing"))
    set_translate_source(source)
    set_translate_appkey(appid, key, location, source)
}

#' set source of online translator service
#' 
#' This function allows users to set the default source for `translate()` function
#' @rdname set-translate-source
#' @param source translation engine
#' @return No return value, called for side effects
#' @author Guangchuang Yu 
#' @export
set_translate_source <- function(source) {
    options(yulab_translate_source = source)
}

##' @importFrom utils modifyList
set_translate_appkey <- function(appid=NULL , key=NULL, location=NULL, source) {
    newkey <- list(appid = appid, key = key)
    if (source == "bing") {
        newkey$location <- location
    }

    x <- list()
    x[[source]] <- newkey

    opts <- getOption('yulab_translate', list())
    opts <- modifyList(opts, x)
    
    options(yulab_translate = opts)
}

get_translate_source <- function() {
    getOption('yulab_translate_source', "baidu")
}

get_translate_appkey <- function(source) {
    if (missing(source)) {
        source <- get_translate_source()
    }
    appkeys <- getOption('yulab_translate', list())
    res <- appkeys[[source]]
    if (is.null(res)) stop("Please set your appid and key via set_translate_option()")
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
    } else if (src == "bing") {
        res <- bing_translate(x, from = from, to = to)
    } else {
        stop ("Please set your appid and key via set_translate_option()")
    }

    return(res)
}

