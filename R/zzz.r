.onAttach <- function(libname, pkgname) {
  # pkgVersion <- utils::packageDescription(pkgname, fields="Version")

  citation <- paste0("If you use ", pkgname, " in published research, please cite:\n",
                     "Guangchuang Yu. ",
                     "Using fanyi to assist research communities in retrieving and interpreting information. ",
                     "bioRxiv 2023, doi: 10.1101/2023.12.21.572729", "\n")

  packageStartupMessage(citation)
}


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

