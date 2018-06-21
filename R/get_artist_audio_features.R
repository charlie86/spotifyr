#' Get features and popularity for an artist's entire discography on Spotify
#'
#' This function returns the popularity and audio features for every song and album for a given artist on Spotify
#' @param artist_name String of artist name
#' @param artist_uri String of Spotify artist URI. Will only be applied if \code{use_arist_uri} is set to \code{TRUE}. This is useful for pulling related artists in bulk and allows for more accurate matching since Spotify URIs are unique.
#' @param use_artist_uri Boolean determining whether to search by Spotify URI instead of an artist name. If \code{TRUE}, you must also enter an \code{artist_uri}. Defaults to \code{FALSE}.
#' @param return_closest_artist Boolean for selecting the artist result with the closest match on Spotify's Search endpoint. Defaults to \code{TRUE}.
#' @param album_types Character vector of album types to include. Valid values are "album", "single", "appears_on", and "compilation". Defaults to "album".
#' @param message Boolean for printing the name of artist matched when using \code{return_closest_artist = TRUE}. Defaults to \code{FALSE}.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @keywords track audio features discography
#' @export
#' @examples
#' \dontrun{
#' radiohead_features <- get_artist_audio_features(artist_name = 'radiohead')
#' }

get_artist_audio_features <- function(artist_name = NULL, artist_uri = NULL, use_artist_uri = FALSE, return_closest_artist = TRUE, album_types = 'album', message = FALSE, access_token = get_spotify_access_token(), parallelize = TRUE, future_plan = 'multiprocess') {

    albums <- get_artist_albums(artist_name = artist_name, artist_uri = artist_uri, use_artist_uri = use_artist_uri, return_closest_artist = TRUE, message = message, album_types = album_types, access_token = access_token, parallelize = parallelize, future_plan = future_plan)

    if (nrow(albums) == 0) {
        stop(paste0('Cannot find any albums for "', selected_artist, '" on Spotify'))
    }

    album_popularity <- get_album_popularity(albums)
    tracks <- get_album_tracks(albums, parallelize = parallelize, future_plan = future_plan)
    track_features <- get_track_audio_features(tracks)
    track_popularity <- get_track_popularity(tracks)

    tots <- albums %>%
        left_join(album_popularity, by = 'album_uri') %>%
        left_join(tracks, by = 'album_name') %>%
        left_join(track_features, by = 'track_uri') %>%
        left_join(track_popularity, by = 'track_uri')

    return(tots)
}
