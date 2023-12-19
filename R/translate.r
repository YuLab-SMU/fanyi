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
#' @param region this is for bing use only, translation engine location, depends on your Azure service setting
#' @return No return value, called for side effects
#' @author Guangchuang Yu 
#' @export
set_translate_option <- function(appid, key, region="southeastasia", source = "baidu") {
    source <- match.arg(source, c("baidu", "bing", "youdao"))
    set_translate_source(source)
    set_translate_appkey(appid, key, region, source)
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
set_translate_appkey <- function(appid=NULL , key=NULL, region=NULL, source) {
    newkey <- list(appid = appid, key = key)
    if (source == "bing") {
        newkey$region <- region
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
#' @importFrom yulab.utils use_perl
#' @export
translate <- function(x, from = 'en', to = 'zh') {
    x <- gsub("\\s*\n+\\s*", " ", x, perl = use_perl())
    src <- get_translate_source()
    switch(src,
           baidu = baidu_translate(x, from = from, to = to),
           bing = bing_translate(x, from = from, to = to),
           youdao = youdao_translate(x, from = from, to = to)
        )
}

#' Translate axis label of a ggplot
#' 
#' This function use the `translate()` function to translate axis labels of a ggplot
#' @title translate_ggplot
#' @rdname translate_ggplot
#' @param plot a ggplot object to be translated
#' @param axis one of 'x', 'y' or 'xy' to select axis labels to be translated
#' @param from source language, i.e., the language to be translated
#' @param to target language, i.e., the language to be translated into
#' @return a translated ggplot object
#' @author Guangchuang Yu 
#' @importFrom ggfun get_aes_var
#' @importFrom ggfun get_plot_data
#' @export
translate_ggplot <- function(plot, axis = "xy", from="en", to="zh") {
    axis <- match.arg(axis, c("x", "y", "xy"))
    if (axis != 'xy') {
        var <- get_aes_var(plot$mapping, axis)
        lab <- get_plot_data(plot, var)[[1]]
        tlab <- translate(lab, from=from, to = to)
        if (is.factor(lab)) {
            names(tlab) <- lab
            tlab <- factor(tlab, levels = tlab[levels(lab)])
        }
        plot$data[[var]] <- tlab
    } else {
        plot <- translate_ggplot(plot, axis='x', from=from, to=to)
        plot <- translate_ggplot(plot, axis='y', from=from, to=to)
    }

    return(plot)
}

