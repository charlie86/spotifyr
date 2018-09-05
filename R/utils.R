#' Check if a string matches the pattern of a Spotify URI
#'
#' Check if a string matches the pattern of a Spotify URI
#' @param s String to check
#' @export
is_uri <- function(s) {
    nchar(s) == 22 &
        !str_detect(s, ' ') &
        str_detect(s, '[[:digit:]]') &
        str_detect(s, '[[:lower:]]') &
        str_detect(s, '[[:upper:]]')
}

#' Verify API result
#'
#' Check API result for error codes
#' @param res API result ot check
#' @export
verify_result <- function(res) {
    if (!is.null(res$error)) {
        stop(str_glue('{res$error$message} ({res$error$status})'))
    }
}
