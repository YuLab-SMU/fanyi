##' check English word in Youdao dictionary
##'
##' @title ydict
##' @param word word to check
##' @return interpretation from youdao dictionary
##' @importFrom rlang as_name
##' @importFrom rlang enquo
##' @export
ydict <- function(word) {
    word <- rlang::as_name(rlang::enquo(word))
    x <- .youdao_translate(word) 

    uk <- yd_format_item("\tUK: [%s]", x$basic$`uk-phonetic`)
    us <- yd_format_item("\tUS: [%s]", x$basic$`us-phonetic`)
    explain <- yd_format_item("\tExplains: %s", x$basic$explains[[1]])
    web <- yd_format_item("\tWeb: %s", x$mTerminalDict$url)

    y <- sprintf("\n%s%s\n\n%s\n\n%s\n\n", 
                    uk, us, explain, web)

    cat(y)
}

yd_format_item <- function(format, item) {
    if (is.null(item)) {
        res <- ""
    } else {
        res <- sprintf(format, item) 
    }         
    return(res)
}