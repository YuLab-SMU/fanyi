.hmac <- (\(x, y, z) digest::hmac(object    = x,
                                  key       = y,
                                  algo      = "sha256",
                                  serialize = FALSE,
                                  raw       = z))
                                  
