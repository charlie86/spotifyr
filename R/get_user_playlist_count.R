#' Get count of Spotify playlists for a given user
#'
#' Helper function for \code{spotifyr::get_user_playlists()}
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @param echo Boolean for whether or not to print number of playlists for the given username. Defaults to \code{FALSE}
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' obama_playlist_count <- get_user_playlist_count('barackobama')
#' }

get_user_playlist_count <- function(username, access_token = get_spotify_access_token(), echo = FALSE) {
    endpoint <- paste0('https://api.spotify.com/v1/users/', username, '/playlists')
    res <- GET(endpoint, query = list(access_token = access_token, limit = 1)) %>% content

    if (!is.null(res$error)) {
        stop(paste0(res$error$message, ' (', res$error$status, ')'))
    }

    total <- res$total

    if (echo) {
        print(paste0('Found ', total, ' playlists from ', username))
    }

    return(total)
}
