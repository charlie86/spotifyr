#' Get features and popularity for all of a given set of playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for a given set of playlists on Spotify
#' @param username String of Spotify username. Can be found on the Spotify app. (See http://rcharlie.net/sentify/user_uri.gif for example)
#' @param playlist_uris Character vector of Spotify playlist uris associated with the given \code{username}. Can be found within the Spotify App
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features playlists
#' @export
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' my_playlist_audio_features <- get_playlist_audio_features('spotify', playlist_uris)
#' }

get_playlist_audio_features <- function(username, playlist_uris, parallelize = FALSE, future_plan = 'multiprocess', access_token = get_spotify_access_token()) {

    playlists <- get_playlists(username, playlist_uris, access_token = access_token)
    tracks <- get_playlist_tracks(playlists, parallelize = parallelize, future_plan = future_plan, access_token = access_token)
    track_popularity <- get_track_popularity(tracks, access_token = access_token)
    track_audio_features <- get_track_audio_features(tracks, access_token = access_token)

    tots <- playlists %>%
        select(-playlist_img) %>%
        left_join(tracks, by = 'playlist_name') %>%
        left_join(track_popularity, by = 'track_uri') %>%
        left_join(track_audio_features, by = 'track_uri')

    return(tots)
}
