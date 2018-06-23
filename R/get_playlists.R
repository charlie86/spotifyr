#' Get playlists
#'
#' This function returns a dataframe of playlists for a given Spotify username and a character vector of playlist uris
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param playlist_uris Character vector of Spotify playlist uris associated with the given \code{username}. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @param show_progress Boolean determining to show progress bar or not. Defaults to \code{FALSE}.
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' my_playlist_audio_features <- get_playlist_audio_features('spotify', playlist_uris)
#' }

get_playlists <- function(username, playlist_uris, access_token = get_spotify_access_token(), show_progress = TRUE) {

    num_loops <- length(playlist_uris)

    if (show_progress == TRUE & num_loops > 1) {
        pb <- txtProgressBar(min = 1, max = num_loops, style = 3)
    }

    map_df(playlist_uris, function(this_playlist) {
        url <- str_glue('https://api.spotify.com/v1/users/{username}/playlists/', this_playlist)

        content <- RETRY('GET', url, query = list(access_token = access_token), quiet = TRUE) %>% content

        playlist_df <- content %>%
            list %>%
            list %>%
            parse_playlist_list_to_df()

        if (exists('pb')) {
            setTxtProgressBar(pb, this_playlist)
        }

        return(playlist_df)
    })

}
