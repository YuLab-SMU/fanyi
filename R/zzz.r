.onAttach <- function(libname, pkgname) {
  # pkgVersion <- utils::packageDescription(pkgname, fields="Version")

  citation <- paste0("If you use ", pkgname, " in published research, please cite:\n",
                     "Guangchuang Yu. ",
                     "Using fanyi to assist research communities in retrieving and interpreting information. ",
                     "bioRxiv 2023, doi: 10.1101/2023.12.21.572729", "\n")

  packageStartupMessage(citation)
}

