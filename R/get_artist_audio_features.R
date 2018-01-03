#' Get features and popularity for an artist's entire discography on Spotify
#'
#' This function returns the popularity and audio features for every song and album for a given artist on Spotify
#' @param artist_name String of artist name
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param return_closest_artist Boolean for using string distance to select the artist result with the closest match to the given string. Defaults to \code{TRUE}.
#' @keywords track audio features discography
#' @export
#' @examples
#' \dontrun{
#' radiohead_features <- get_artist_audio_features('radiohead')
#' }

get_artist_audio_features <- function(artist_name, access_token = get_spotify_access_token(), return_closest_artist = TRUE) {

    artists <- get_artists(artist_name)

    if (nrow(artists) > 0) {
        if (return_closest_artist == TRUE) {
            string_distances <- stringdist(artist_name, artists$artist_name, method = 'cosine')
            min_distance_index <- which(string_distances == min(string_distances))
            selected_artist <- artists$artist_name[min_distance_index]
            message(paste0('Selecting artist "', selected_artist, '"', '. Choose return_closest_artist = FALSE to interactively choose from all the artist matches on Spotify.'))
        } else {
            cat(paste0('We found the following artists on Spotify matching "', artist_name, '":\n\n\t', paste(artists$artist_name, collapse = '\n\t'), '\n\nPlease type the name of the artist you would like:'), sep  = '')
            selected_artist <- readline()
        }

        artist_uri <- artists$artist_uri[artists$artist_name == selected_artist]
    } else {
        stop(paste0('Cannot find any artists on Spotify matching "', artist_name, '"'))
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
