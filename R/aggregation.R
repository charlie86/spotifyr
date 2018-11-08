#' Get audio feature information for all or part of an artists' discography.
#'
#' @param artist Required. String of either an artist name or an artist Spotify ID. If an artist name is provided, \code{search_spotify()} will be used to find a Spotify ID matching the name provided.
#' @param include_groups Optional. A character vector of keywords that will be used to filter the response. Defaults to \code{"album"}. Valid values are: \cr
#' \code{"album"} \cr
#' \code{"single"} \cr
#' \code{"appears_on"} \cr
#' \code{"compilation"} \cr
#' For example: \code{include_groups = c("album", "single")}
#' @param return_closest_artist Optional. Boolean
#' @param parallelize Optional. Boolean
#' @param future_plan Optional. String
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing track audio features data. See the \href{https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-audio-features/}{Spotify Web API documentation} for more information.
#' @export
#'
#' @examples
#'

get_artist_audio_features <- function(artist = NULL, include_groups = "album", return_closest_artist = TRUE,
                                      Authorization = get_spotify_access_token(), parallelize = FALSE,
                                      future_plan = "multiprocess") {

    artist_ids <- search_spotify(artist, 'artist', Authorization = Authorization)

    if (return_closest_artist == TRUE) {
        artist_id <- artist_ids$id[1]
    }

    artist_albums <- get_artist_albums(artist_id, include_groups = include_groups, include_meta_info = TRUE, Authorization = Authorization)
    num_loops_artist_albums <- floor(artist_albums$total / 20)
    if (num_loops_artist_albums > 1) {
        res <- map_df(1:num_loops_artist_albums, function(this_loop) {
            get_artist_albums(artist_id, include_groups = include_groups, offset = this_loop * 20, Authorization = Authorization)
        })
        artist_albums <- rbind(artist_albums$items, res)
    } else {
        artist_albums <- artist_albums$items
    }

    artist_albums <- artist_albums %>%
        rename(album_id = id,
               album_name = name)

    album_tracks <- map_df(artist_albums$album_id, function(this_album_id) {
        album_tracks <- get_album_tracks(this_album_id, include_meta_info = TRUE, Authorization = Authorization)
        num_loops_album_tracks <- floor(album_tracks$total / 20)
        if (num_loops_album_tracks > 1) {
            res <- map_df(1:num_loops_album_tracks, function(this_loop) {
                get_album_tracks(this_album_id, offset = this_loop * 20, Authorization = Authorization)
            })
            album_tracks <- rbind(album_tracks$items, res)
        } else {
            album_tracks <- album_tracks$items
        }

        album_tracks <- album_tracks %>%
            mutate(album_id = this_album_id,
                   album_name = artist_albums$album_name[artist_albums$album_id == this_album_id]) %>%
            rename(track_name = name,
                   track_uri = uri,
                   track_preview_url = preview_url,
                   track_href = href,
                   track_id = id)
    })

    dupe_columns <- c('duration_ms', 'type', 'uri', 'track_href')

    num_loops_tracks <- ceiling(nrow(album_tracks) / 100)
    track_audio_features <- map_df(1:num_loops_tracks, function(this_loop) {
        get_track_audio_features(album_tracks$track_id[((this_loop * 100) - 99):(this_loop * 100)], Authorization = Authorization)
    }) %>%
        select(-dupe_columns) %>%
        rename(track_id = id) %>%
        left_join(album_tracks, by = 'track_id')

    artist_albums %>%
        select(album_id, album_type, album_images = images, album_release_date = release_date,
               album_release_date_precision = release_date_precision) %>%
        left_join(track_audio_features, by = 'album_id')

}

