##' check English word in Youdao dictionary
##'
##' @title ydict
##' @param word word to check
##' @return interpretation from youdao dictionary
##' @export
ydict <- function(word) {
    x <- .youdao_translate(word) 
    y <- sprintf("\n\tUK: [%s]\tUS: [%s]\n\n\tExplains: %s\n\n\tWeb: %s\n\n", 
            x$basic$`uk-phonetic`, 
            x$basic$`us-phonetic`,
            x$basic$explains[[1]],
            x$mTerminalDict$url)
    cat(y)
}

