##' Chat with LLM
##'
##' This function allows users to chat with Large Language Models (LLM) such as DeepSeek, GLM, Qwen.
##' @title chat_request
##' @param x query sentences or prompt
##' @param model model name (e.g., 'deepseek-chat', 'glm-4', 'qwen-turbo')
##' @param api_key API key (optional if set via set_translate_option)
##' @param ... additional parameters
##' @return response text
##' @author Guangchuang Yu
##' @export
chat_request <- function(x, model = 'deepseek-chat', api_key = NULL, ...) {
    
    # Construct messages list format which is standard for most chat APIs
    # If x is already a list, assume it is properly formatted messages
    if (is.list(x) && !is.null(x[[1]]$role) && !is.null(x[[1]]$content)) {
        messages <- x
    } else {
        messages <- list(
            list(role = "user", content = as.character(x))
        )
    }

    # Normalize model name for dispatch
    # Simple heuristic to determine provider
    if (grepl("deepseek", model, ignore.case = TRUE)) {
        res <- .deepseek_query_messages(messages, model = model, api_key = api_key, ...)
        # DeepSeek returns a response object
        content <- httr2::resp_body_json(res)
        text <- content$choices[[1]]$message$content
        return(text)
        
    } else if (grepl("glm", model, ignore.case = TRUE)) {
        # .chatglm_query returns text content
        res <- .chatglm_query(messages, model = model, api_key = api_key, ...)
        return(res)
        
    } else if (grepl("qwen", model, ignore.case = TRUE)) {

        res <- .qwen_query(messages, model = model, api_key = api_key, ...)
        return(res)
        
    } else {
        stop("Unsupported model: ", model, ". Please use deepseek, glm, or qwen models.")
    }
}
