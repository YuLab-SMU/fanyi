.hmac <- (\(x, y, z) digest::hmac(object    = x,
                                  key       = y,
                                  algo      = "sha256",
                                  serialize = FALSE,
                                  raw       = z))

.lang_map <- function(lang_name){
  lang_list <- list(
    "en"  = "English",
    "zh"  = "Chinese",
    "jp"  = "Japanese",
    "ru"  = "Russian",
    "fr"  = "French",
    "kr"  = "Korean",
    "pt"  = "Portuguese"
  )
  return(lang_list[[lang_name]])
}                                 
