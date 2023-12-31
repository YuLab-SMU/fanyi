##' convert species common name to scientific name
##'
##' The function query species common name via the NCBI Taxonomy database and return corresponding scientific name
##' @title name2sci
##' @param x common names
##' @return corresponding scientific names
##' @export
##' @examples
##' name2sci("tiger")
name2sci <- function(x) {
    y <- vapply(x, name2sci.item, FUN.VALUE=character(1))

    msg <- sprintf("  %d%% of input species names are fail to map...", 
                    mean(y == "") * 100)
    message(msg)

    y <- y[y != ""]
    res <- data.frame(common_name = names(y), scientific_name = y)
    rownames(res) <- NULL
    return(res)
}

name2sci.item <- function(x) {
    term <- sprintf("%s[Common Name]", x)
    y <- rentrez::entrez_search(db='taxonomy', term=term)
    if (y$count == 0) return("")

    sci <- rentrez::entrez_fetch(db ='taxonomy', id = y$ids, rettype='native')
    sci <- sub("\\d\\.\\s+", "", sci)
    sci <- sub("\\n.*", "", sci)
    return(sci)
}
