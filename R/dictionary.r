##' check English word in Youdao dictionary
##'
##' @title ydict
##' @param word word to check
##' @param web whether open youdao dict in web browser
##' @return interpretation from youdao dictionary
##' @importFrom rlang as_name
##' @importFrom rlang enquo
##' @export
##' @examples
##' \dontrun{
##' ydict('panda') 
##' ydict(tiger) # unquoted word is supported
##' 
##' # if using a word stored in a variable
##' #
##' x <- 'panda'
##' ydict(!!rlang::sym(x))
##' 
##' }
ydict <- function(word, web=FALSE) {
    word <- rlang::as_name(rlang::enquo(word))
    x <- .youdao_translate(word) 

    url <- x$mTerminalDict$url
    uk <- yd_format_item("\tUK: [%s]", x$basic$`uk-phonetic`)
    us <- yd_format_item("\tUS: [%s]", x$basic$`us-phonetic`)
    explain <- yd_format_item("\tExplains: %s", x$basic$explains[[1]])
    www <- yd_format_item("\tWeb: %s", url)

    y <- sprintf("\n%s%s\n\n%s\n\n%s\n\n", 
                    uk, us, explain, www)

    cat(y)
    if (web && !is.null(url)) {
        utils::browseURL(url)
    }
}

yd_format_item <- function(format, item) {
    if (is.null(item)) {
        res <- ""
    } else {
        res <- sprintf(format, item) 
    }         
    return(res)
}