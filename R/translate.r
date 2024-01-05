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
#' @param user_dict user defined dictionary ID, only used for 'source = "youdao"'
#' @return No return value, called for side effects
#' @author Guangchuang Yu 
#' @export
set_translate_option <- function(appid, key, source = "baidu", region="southeastasia", user_dict=NULL) {
    source <- standardize_source(source)

    set_translate_source(source)
    set_translate_appkey(appid, key, source, region, user_dict)
}

#' set source of online translator service
#' 
#' This function allows users to set the default source for `translate()` function
#' @rdname set-translate-source
#' @param source translation engine
#' @return No return value, called for side effects
#' @author Guangchuang Yu 
#' @examples 
#' set_translate_source("baidu")
#' @export
set_translate_source <- function(source) {
    source <- standardize_source(source)
    options(yulab_translate_source = source)
}

##' @importFrom utils modifyList
set_translate_appkey <- function(appid=NULL , key=NULL, source, region=NULL, user_dict) {
    newkey <- list(appid = appid, key = key)
    if (source == "bing") {
        newkey$region <- region
    }

    if (source == 'youdao') {
        newkey$out_id <- user_dict
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
    src <- get_translate_source()
    switch(src,
           baidu   = baidu_translate(x, from = from, to = to),
           bing    = bing_translate(x, from = from, to = to),
           youdao  = youdao_translate(x, from = from, to = to),
           volcengine = volcengine_translate(x, from = from, to = to),
           caiyun  = caiyun_translate(x, from = from, to = to),  
           tencent = tencent_translate(x, from = from, to = to)
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
        if (any(duplicated(tlab))) {
            i <- which(tlab %in% tlab[duplicated(tlab)])
            tlab[i] <- sprintf("%s (%s)", tlab[i], lab[i])
        }
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


vectorize_translator <- function(x, .fun, from = 'en', to = 'zh') {
    # res <- vapply(x, .translate, 
    #         .fun = .fun, 
    #         from = from, to = to, 
    #         FUN.VALUE = character(1)
    #     )
    # names(res) <- NULL

    res <- character(length(x))
    for (i in seq_along(x)) {
        res[i] <- .translate(x[i], .fun = .fun, from = from, to = to)
        # Sys.sleep(1) # batch translate may fail and works with Sys.sleep(1)
    }

    if (all(res == "")) {
        message("No valid result found.\nPlease check your network and credentials (appid and key).\n")
    }

    return(res)
}

standardize_source <- function(source) {
    if (source %in% c("volc", "huoshan", "bytedance")) {
        source <- "volcengine"
    }
    
    source <- match.arg(source, c("baidu", "bing", "youdao", "volcengine", "caiyun"))

    return(source)
}


.translate <- function(x, .fun, from = 'en', to = 'zh') {
    resp <- .fun(x, from = from, to = to)
    res <- get_translate_text(resp)

    cnt <- 1
    while (is.null(res) && cnt < 5) {
        Sys.sleep(1)
        resp <- .fun(x, from = from, to = to)
        res <- get_translate_text(resp)
        cnt <- cnt + 1        
    }
    
    if (is.null(res)) {
        res <- ""
    }  

    return(res)
}

