#' Get features and popularity for all of a given set of playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for a given set of playlists on Spotify
#' @param username String of Spotify username. Can be found on the Spotify app. (See http://rcharlie.net/sentify/user_uri.gif for example)
#' @param playlist_uris Character vector of Spotify playlist uris associated with the given \code{username}. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param show_progress Boolean determining to show progress bar or not. Defaults to \code{FALSE}.
#' @keywords track audio features playlists
#' @export
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' my_playlist_audio_features <- get_playlist_audio_features('spotify', playlist_uris)
#' }

get_playlist_audio_features <- function(username, playlist_uris, access_token = get_spotify_access_token(), show_progress = TRUE) {

    playlists <- get_playlists(username, playlist_uris, show_progress = show_progress)
    tracks <- get_playlist_tracks(playlists, show_progress = show_progress)
    track_popularity <- get_track_popularity(tracks)
    track_audio_features <- get_track_audio_features(tracks)

    tots <- playlists %>%
        select(-playlist_img) %>%
        left_join(tracks, by = 'playlist_name') %>%
        left_join(track_popularity, by = 'track_uri') %>%
        left_join(track_audio_features, by = 'track_uri')

    return(tots)
}
