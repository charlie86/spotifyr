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

#' Pitch class notation lookup
#'
# Create lookup to classify key: https://developer.spotify.com/web-api/get-audio-features/
#' @export
pitch_class_lookup <- c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')

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

#' Valid scopes
#'
#' Vector of valid scopes for spotifyr::get_authorization_code()
#' @export
scopes <- c(
    'user-library-read',
    'user-library-modify',
    'playlist-read-private',
    'playlist-modify-public',
    'playlist-modify-private',
    'playlist-read-collaborative',
    'user-read-recently-played',
    'user-top-read',
    'user-read-private',
    'user-read-email',
    'user-read-birthdate',
    'streaming',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'user-read-playback-state',
    'user-follow-modify',
    'user-follow-read'
)
