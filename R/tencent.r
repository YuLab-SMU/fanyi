##' @rdname translate
##' @export
tencent_translate <- function(x, from = 'en', to = 'zh') {
    vectorize_translator(x,
        .fun = .tencent_translate_query, 
        from = from, to = to)
}



##' @method get_translate_text volcengine
##' @export
get_translate_text.tencent <- function(response) {
  response$Response$TargetText
}

##' @importFrom httr2 request
##' @importFrom httr2 req_headers
##' @importFrom httr2 req_body_raw
##' @importFrom httr2 req_method
##' @importFrom httr2 req_perform
##' @importFrom openssl sha256
##' @importFrom digest hmac
##' @importFrom jsonlite toJSON
##' @importFrom jsonlite unbox
#for help, visit: https://cloud.tencent.com/document/product/551/15619
.tencent_translate_query <- function(x, from = 'en', to = 'zh') {
  schema <- 'https'
  version <- '2018-03-21'
  action <- 'TextTranslate'
  region <- 'ap-beijing'
  endpoint <- 'tmt.tencentcloudapi.com'
  service <- 'tmt'

  canonicalUri <- '/'
  canonicalQueryString <- ''
  canonicalHeaders <- paste0('content-type:application/json', '\n', 
                             'host:', 
                             endpoint, 
                             '\n')
  signedHeaders <- 'content-type;host'
  httpRequestMethod <- 'POST'
  .info <- get_translate_appkey('tencent')
  appid <- .info$appid
  secret <- .info$key
  
  text <- x
  body <- list(SourceText = text,
               Source = from,
               Target = to,
               ProjectId = 0)
  payload <- jsonlite::toJSON(body, auto_unbox = T)
  hashedRequestPayload <- openssl::sha256(payload)
  
  format_date <- strftime(as.POSIXlt(Sys.time(), "GMT"), "%Y-%m-%d")
  timeStamp <- as.character(trunc(as.numeric(Sys.time())))

  canonicalRequest <- paste0(httpRequestMethod, '\n',
                             canonicalUri, '\n',
                             canonicalQueryString, '\n',
                             canonicalHeaders, '\n',
                             signedHeaders, '\n',
                             hashedRequestPayload)
  hashedCanonicalRequest <- openssl::sha256(canonicalRequest)

  algorithm <- 'TC3-HMAC-SHA256'
  credentialScope <- paste0(format_date,
                           "/",
                           service,
                           "/",
                           "tc3_request")
  stringToSign <- paste0(algorithm,
                         "\n",
                         timeStamp,
                         "\n",
                         credentialScope,
                         "\n",
                         hashedCanonicalRequest)
  
  headers <- list(
    'authorization'  = '',
    'content-type'   = 'application/json',
    'Host'           = endpoint,
    'x-tc-version'   = version,
    'x-tc-action'    = action,
    'x-tc-timestamp' = timeStamp,
    'x-tc-region'    = region
  )

  #hmac invoke once, run everywhere #
  .hmac <- (\(x, y, z) digest::hmac(object    = x,
                                    key       = y,
                                    algo      = "sha256",
                                    serialize = F,
                                    raw       = z))

  kdate      <- .hmac(format_date, paste0("TC3", secret), T)
  kservice   <- .hmac(service, kdate, T)
  ksigning   <- .hmac("tc3_request", kservice, T)
  signed_str <- .hmac(stringToSign, ksigning, F)
  
  headers['authorization'] <- paste0(algorithm,
                                     ' ',
                                     'Credential=',
                                     appid,
                                     '/',
                                     credentialScope,
                                     ', SignedHeaders=',
                                     signedHeaders,
                                     ', ',
                                     'Signature=',
                                     signed_str)
  
  url <- paste0(schema, '://', endpoint)

  req <- httr2::request(url) |> 
         httr2::req_headers(!!!headers) |>
         httr2::req_body_raw(payload) |>
         httr2::req_method(httpRequestMethod) |> 
         httr2::req_perform()
  res <- req |> 
         httr2::resp_body_json()

  structure(res, class = "tencent")
}

#.volcengine_translate_query2 <- memoise(.volcengine_translate_query)

