##' @rdname translate
##' @export
#Go to https://ai.youdao.com for application of your appid and API key.
youdao_translate <- function(x, from = 'en', to = 'zh') {
    vectorize_translator(x, 
      .fun = .youdao_translate, 
      from = from, to = to)
}



### Use anonymous function to reduce assignment of value and improve readability ###
# truncate_func <- (\(x) ifelse(nchar(x) <= 20, 
#                               return(x), 
#                               return(paste0(substring(x, c(1, nchar(x) - 9), c(10, nchar(x))), 
#                                             collapse = as.character(nchar(x)))))
#                             )

truncate_func <- function(x) {
	x <- as.character(x)
	n <- nchar(x)
	if (n <= 20) return(x)

	ps <- substring(x, c(1, n-9), c(10, n))

	sprintf("%s%d%s", ps[1], n, ps[2])
}

##' @importFrom openssl sha256
##' @importFrom jsonlite fromJSON
##' @importFrom utils URLencode
##' @importFrom httr2 request
##' @importFrom httr2 req_url_query
##' @importFrom httr2 req_perform
##' @importFrom httr2 resp_body_json 
# the native R pipe |> pipes the LHS into the first argument of the function on 
# the RHS: LHS |> RHS. (https://ivelasq.rbind.io/blog/understanding-the-r-pipe/)
.youdao_translate <- function(x, from = 'en', to = 'zh-CHS') {
  url_prefix <- "https://openapi.youdao.com/api?"
  query <- youdao_translate_query(x, from = from, to = to)
  req <- httr2::request(url_prefix) |> httr2::req_url_query(!!!query) |> 
         httr2::req_perform()
  res <- req |> httr2::resp_body_json()
  structure(res, class = c("youdao", "list"))
}

# .youdao_translate2 <- memoise(.youdao_translate)

youdao_translate_query <- function(x, from = 'en', to = 'zh-CHS') {
    salt <- as.character(trunc(as.numeric(Sys.time()) * 1e3))
    curtime <- as.character(trunc(as.numeric(Sys.time())))
    .info <- get_translate_appkey('youdao')
    appid <- .info$appid
    key <- .info$key
    encode_str <- paste0(appid = appid, 
                         truncate_func(x), 
                         salt, 
                         curtime, 
                         key = key)
    signed_str <- as.character(sha256(encode_str))
    query = list(q = x,
                appKey = appid, 
                salt = salt, 
                from = from, 
                to = to,
                sign = signed_str, 
                signType = 'v3',
                curtime = curtime)

    if (!is.null(.info$out_id)) {
        query$vocabId = .info$out_id
    }
    return(query)
}

##' @method get_translate_text youdao
##' @export
get_translate_text.youdao <- function(response) {
    response$translation[[1]]
}

