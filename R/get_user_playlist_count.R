#' Get count of Spotify playlists for a given user
#'
#' Helper function for \code{spotifyr::get_user_playlists()}
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' obama_playlist_count <- get_user_playlist_count('barackobama')
#' }

get_user_playlist_count <- function(username, access_token = get_spotify_access_token()) {
    endpoint <- str_glue('https://api.spotify.com/v1/users/{username}/playlists')
    res <- RETRY('GET', url = endpoint, query = list(access_token = access_token, limit = 1), quiet = TRUE) %>% content

    if (!is.null(res$error)) {
        stop(str_glue('{res$error$message} ({res$error$status})'))
    }
    res$total
}
