
initial_gs_cache <- function() {
    pos <- 1
    envir <- as.environment(pos)
    assign(".yulabGSCache", new.env(), envir = envir)
}


get_gs_cache <- function() {
    if (!exists(".yulabGSCache", envir = .GlobalEnv)) {
        initial_gs_cache()
    }
    get(".yulabGSCache", envir = .GlobalEnv)
}

