#' Get features and popularity for an artist's entire discography on Spotify
#'
#' This function returns the popularity and audio features for every song and album for a given artist on Spotify
#' @param artist_name String of artist name
#' @param artist_uri String of Spotify artist URI. Will only be applied if \code{use_arist_uri} is set to \code{TRUE}. This is useful for pulling related artists in bulk and allows for more accurate matching since Spotify URIs are unique.
#' @param use_artist_uri Boolean determining whether to search by Spotify URI instead of an artist name. If \code{TRUE}, you must also enter an \code{artist_uri}. Defaults to \code{FALSE}.
#' @param return_closest_artist Boolean for selecting the artist result with the closest match on Spotify's Search endpoint. Defaults to \code{TRUE}.
#' @param message Boolean for printing the name of artist matched when using \code{return_closest_artist = TRUE}. Defaults to \code{FALSE}.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features discography
#' @export
#' @examples
#' \dontrun{
#' radiohead_features <- get_artist_audio_features(artist_name = 'radiohead')
#' }

get_artist_audio_features <- function(artist_name = NULL, artist_uri = NULL, use_artist_uri = FALSE, return_closest_artist = TRUE, message = FALSE, access_token = get_spotify_access_token()) {

    if (use_artist_uri == FALSE) {

        if (is.null(artist_name)) {
            stop('You must enter an artist name if use_artist_uri = FALSE.')
        }

        artists <- get_artists(artist_name)

        if (nrow(artists) > 0) {
            if (return_closest_artist == TRUE) {
                selected_artist <- artists$artist_name[1]
                if (message) {
                    message(paste0('Selecting artist "', selected_artist, '"', '. Choose return_closest_artist = FALSE to interactively choose from all the artist matches on Spotify.'))
                }
            } else {
                cat(paste0('We found the following artists on Spotify matching "', artist_name, '":\n\n\t', paste(artists$artist_name, collapse = '\n\t'), '\n\nPlease type the name of the artist you would like:'), sep  = '')
                selected_artist <- readline()
            }

            artist_uri <- artists$artist_uri[artists$artist_name == selected_artist]
        } else {
            stop(paste0('Cannot find any artists on Spotify matching "', artist_name, '"'))
        }

    } else {
        if (is.null(artist_uri)) {
            stop('You must enter an artist_uri if use_artist_uri = TRUE.')
        }
    }

    albums <- get_albums(artist_uri)

    if (nrow(albums) > 0) {
        albums <- select(albums, -c(base_album_name, base_album, num_albums, num_base_albums, album_rank))
    } else {
        stop(paste0('Cannot find any albums for "', selected_artist, '" on Spotify'))
    }

    album_popularity <- get_album_popularity(albums)
    tracks <- get_album_tracks(albums)
    track_features <- get_track_audio_features(tracks)
    track_popularity <- get_track_popularity(tracks)

    tots <- albums %>%
        left_join(album_popularity, by = 'album_uri') %>%
        left_join(tracks, by = 'album_name') %>%
        left_join(track_features, by = 'track_uri') %>%
        left_join(track_popularity, by = 'track_uri')

    return(tots)
}
