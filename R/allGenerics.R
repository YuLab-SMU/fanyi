##' access translated text from online translator response
##'
##'
##' @title get_translate_text
##' @param response return from the online translator
##' @return translated text
##' @rdname get-translate-text
##' @export
get_translate_text <- function(response) {
    UseMethod("get_translate_text")
}
