##' @rdname translate
##' @export
volcengine_translate <- function(x, from = 'en', to = 'zh') {
    vectorize_translator(x,
      .fun = .volcengine_translate_query2, 
      from = from, to = to)
}



##' @method get_translate_text volcengine
get_translate_text.volcengine <- function(response) {
  response$TranslationList[[1]]$Translation
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
##' @importFrom utils URLencode
.volcengine_translate_query <- function(x, from = 'en', to = 'zh') {
    serviceVersion <- '2020-06-01'
    schema <- 'https'
    host <- 'open.volcengineapi.com'
    path <- '/'
    method <- 'POST'
    .info <- get_translate_appkey('volcengine')
    appid <- .info$appid
    secret <- .info$key

    credentials <- list(
       ak = appid,
       sk = secret,
       service = 'translate',
       region = 'cn-north-1'
    )

    text <- x
    body <- list(TargetLanguage = jsonlite::unbox(to),
                 TextList = text)
    bodyStr <- jsonlite::toJSON(body)
    body_hash <- openssl::sha256(bodyStr)
  
    format_date <- strftime(as.POSIXlt(Sys.time(), "GMT"), "%Y%m%dT%H%M%OSZ")

    signed_headers = list(
        'content-type' = 'application/json',
        host = host,
        'x-content-sha256' = body_hash,
        'x-date' = format_date
    )
  
    md <- list(
        algorithm = 'HMAC-SHA256',
        credential_scope = '',
        signed_headers = '',
        date = substring(format_date, first = 1, last = 8),
        region = credentials[["region"]],
        service = credentials[["service"]]
    )
    md["credential_scope"] <- sprintf("%s/%s/%s/request",
                                    md["date"], 
                                    md["region"],
                                    md["service"])

    signed_str <- ''
    md_signed_headers <- ''
    signedHeaderKeys <- names(signed_headers)
    signed_str <-
      paste(unlist(lapply(
        1:length(signedHeaderKeys),
        \(i) paste0(signedHeaderKeys[i], ":",
                    signed_headers[signedHeaderKeys[i]], "\n")
      )), collapse = '')
  
    .md_signed_headers <-
      paste(unlist(lapply(
        1:length(signedHeaderKeys), \(i) paste0(signedHeaderKeys[i], ';')
      )), collapse = '')
    md_signed_headers <-
    substring(.md_signed_headers, 1, (nchar(.md_signed_headers) - 1))
  
    md["signed_headers"] <- md_signed_headers
  
    headers = list(
       Authorization = '',
       'Content-Type' = 'application/json',
       Host = host,
       'X-Content-Sha256' = body_hash,
       'X-Date' = format_date
    )

    norm_uri <- path
    norm_query <- paste0('Action=TranslateText&Version=', serviceVersion)
    canoncial_request <- paste0(method,
                                '\n',
                                norm_uri,
                                '\n',
                                norm_query,
                                '\n',
                                signed_str,
                                '\n',
                                md['signed_headers'],
                                '\n',
                                body_hash)
    hashed_canon_req <- openssl::sha256(canoncial_request)
    kdate <- digest::hmac(object = md[['date']],
                          key = secret,
                          algo = "sha256",
                          serialize = F,
                          raw = T)
    kregion <- digest::hmac(object = md[['region']],
                            key = kdate,
                            algo = "sha256",
                            serialize = F,
                            raw = T)
    kservice <- digest::hmac(object = md[['service']],
                             key = kregion,
                             algo = "sha256",
                             serialize = F,
                             raw = T)
    signing_key <- digest::hmac(object = "request",
                                key = kservice,
                                algo = "sha256",
                                serialize = F,
                                raw = T)

    signing_str <- paste0(md[['algorithm']], '\n',
                          format_date, '\n',
                          md[['credential_scope']], '\n',
                          hashed_canon_req)
    sign <- digest::hmac(object = signing_str,
                         key = signing_key,
                         algo = "sha256",
                         serialize = F,
                         raw = F)
  
    headers['Authorization'] <- paste0(md['algorithm'],
                                       ' Credential=',
                                       appid,
                                       '/',
                                       md['credential_scope'],
                                       ', SignedHeaders=',
                                       md['signed_headers'],
                                       ', Signature=',
                                       sign)
  
    url <- paste0(schema, '://', host, path, '?',
                  'Action=TranslateText&Version=',
                  serviceVersion)

    response <- httr2::request(url) |> httr2::req_headers(!!!headers) |>
                httr2::req_body_raw(bodyStr) |>
                httr2::req_method(method) |> httr2::req_perform()
    resp <- response |> httr2::resp_body_json()

    structure(resp, class = "volcengine")
}


.volcengine_translate_query2 <- memoise(.volcengine_translate_query)

