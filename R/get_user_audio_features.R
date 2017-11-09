#' Get features and popularity for all of a user's playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for all of a given user's playlists on Spotify
#' @param username String of Spotify username. Can be found on the Spotify app. (See http://rcharlie.net/sentify/user_uri.gif for example)
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features playlists
#' @export
#' @examples
#' \dontrun{
#' obama_track_features <- get_user_audio_features('barackobama')
#' }

get_user_audio_features <- function(username, access_token = get_spotify_access_token()) {

  playlists <- get_user_playlists(username)
  tracks <- get_playlist_tracks(playlists)
  track_popularity <- get_track_popularity(tracks)
  track_audio_features <- get_track_audio_features(tracks)

  tots <- playlists %>%
    select(-playlist_img) %>%
    left_join(tracks, by = 'playlist_name') %>%
    left_join(track_popularity, by = 'track_uri') %>%
    left_join(track_audio_features, by = 'track_uri')

  return(tots)
}
