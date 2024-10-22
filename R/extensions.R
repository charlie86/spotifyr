#' Get Audio Features For Artists' Discography
#'
#' Get audio feature information for all or part of an artists' discography.
#'
#' @param artist Required. String of either an artist name or an artist Spotify ID.
#' If an artist name is provided, \code{search_spotify()} will be used to find a Spotify ID
#' matching the name provided.
#' @param include_groups Optional. A character vector of keywords that will be used to filter
#'  the response. Defaults to \code{"album"}.
#'  Valid values are: \cr
#' \code{"album"} \cr
#' \code{"single"} \cr
#' \code{"appears_on"} \cr
#' \code{"compilation"} \cr
#' For example: \code{include_groups = c("album", "single")}
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. \cr
#' Supply this parameter to limit the response to one particular geographical market.
#' For example, for albums available in Sweden: \code{market = "SE"}. \cr
#' If not given, results will be returned for all markets and you are likely to get duplicate results per album, one for each market in which the album is available!
#' @param return_closest_artist Optional. Boolean.
#' @param dedupe_albums Optional. Logical, boolean parameter, defaults to
#' \code{TRUE}.
#' @param authorization Required. A valid access token from the Spotify Accounts service.
#' See the
#' \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details.
#' Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing track audio features data. See the
#' \href{https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-audio-features/}{Spotify Web API documentation} for more information.
#' @family musicology functions
#' @importFrom rlang .data
#' @export

get_artist_audio_features <- function(artist = NULL,
                                      include_groups = 'album',
                                      return_closest_artist = TRUE,
                                      dedupe_albums = TRUE,
                                      market = NULL,
                                      authorization = get_spotify_access_token()
                                      ) {

    artist_id <- NULL

    if (is_uri(artist)) {
        artist_info <- get_artist(artist, authorization = authorization)
        artist_id <- artist_info$id
        artist_name <- artist_info$name
    } else {
        # Try to find an artist  with this ID
        artist_ids <- search_spotify(
            artist, 'artist',
            authorization = authorization)

        if (return_closest_artist) {
            artist_id <- artist_ids$id[1]
            artist_name <- artist_ids$name[1]
        } else {
            choices <- map_chr(1:length(artist_ids$name), function(x) {
                str_glue('[{x}] {artist_ids$name[x]}')
            }) %>% paste0(collapse = '\n\t')
            cat(str_glue('We found the following artists on Spotify matching "{artist}":\n\n\t{choices}\n\nPlease type the number corresponding to the artist you\'re interested in.'), sep  = '')
            selection <- as.numeric(readline())
            artist_id <- artist_ids$id[selection]
            artist_name <- artist_ids$name[selection]
        }
    }


    if (is.null(artist_id)) {
        stop("No artist found with artist_id='", artist_id, "'.")
    }

    artist_albums <- get_artist_albums(id = artist_id,
                                       include_groups = include_groups,
                                       include_meta_info = TRUE,
                                       market = market,
                                       authorization = authorization)


    if (is.null(artist_albums$items) | length(artist_albums$items)==0) {
        stop("No albums found with with artist_id='", artist_id, "'.")
    }


    num_loops_artist_albums <- ceiling(artist_albums$total / 20)

    if (num_loops_artist_albums > 1) {
        artist_albums <- map_df(1:num_loops_artist_albums, function(this_loop) {
            get_artist_albums(artist_id,
                              include_groups = include_groups,
                              offset = (this_loop - 1) * 20,
                              authorization = authorization)
        })
    } else {
        artist_albums <- artist_albums$items
    }

    artist_albums <- artist_albums %>%
        dplyr::rename(
          album_id = .data$id,
          album_name = .data$name
        ) %>%
        dplyr::mutate(
          album_release_year = case_when(
              release_date_precision == 'year' ~ suppressWarnings(as.numeric(.data$release_date)),
              release_date_precision == 'day' ~ lubridate::year(
                            as.Date(.data$release_date, '%Y-%m-%d',
                                    origin = '1970-01-01')),
              TRUE ~ as.numeric(NA))
        )

    if (dedupe_albums) {
        artist_albums <- dedupe_album_names(df = artist_albums)
    }

    album_tracks <- purrr::map_df(artist_albums$album_id, function(this_album_id) {
        album_tracks <- get_album_tracks(this_album_id,
                                         include_meta_info = TRUE,
                                         authorization = authorization)

        num_loops_album_tracks <- ceiling(album_tracks$total / 20)
        if (num_loops_album_tracks > 1) {
            album_tracks <- purrr::map_df(1:num_loops_album_tracks, function(this_loop) {
                get_album_tracks(this_album_id,
                                 offset = (this_loop - 1) * 20,
                                 authorization = authorization)
            })
        } else {
            album_tracks <- album_tracks$items
        }

        album_tracks <- album_tracks %>%
            dplyr::mutate(
              album_id = this_album_id,
              album_name = artist_albums$album_name[artist_albums$album_id == this_album_id]
            ) %>%
            dplyr::rename(
              track_name = name,
              track_uri = uri,
              track_href = href,
              track_id = id
            )
    })

    dupe_columns <- c('duration_ms', 'type', 'uri', 'track_href')

    num_loops_tracks <- ceiling(nrow(album_tracks) / 100)

    track_audio_features <- map_df(1:num_loops_tracks, function(this_loop) {
        track_ids <- album_tracks %>%
            dplyr::slice(((this_loop * 100) - 99):(this_loop * 100)) %>%
            dplyr::pull(.data$track_id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>%
        dplyr::select(-dplyr::all_of( dupe_columns )) %>%
        dplyr::rename(track_id = .data$id) %>%
        dplyr::left_join(album_tracks, by = 'track_id')

    artist_albums %>%
        dplyr::mutate(
          artist_name = artist_name,
          artist_id = artist_id
        ) %>%
        dplyr::select(
          .data$artist_name,
          .data$artist_id,
          .data$album_id,
          .data$album_type,
          album_images = .data$images,
          album_release_date = .data$release_date,
          .data$album_release_year,
          album_release_date_precision = .data$release_date_precision
        ) %>%
        dplyr::left_join(track_audio_features, by = 'album_id') %>%
        dplyr::mutate(key_name = pitch_class_lookup[key + 1],
               mode_name = case_when(mode == 1 ~ 'major',
                                     mode == 0 ~ 'minor',
                                     TRUE ~ as.character(NA)),
               key_mode = paste(key_name, mode_name))
}


#' Get User Playlist Audio Features
#'
#' Get audio feature information for a users' playlists.
#'
#' @param username Required. String of Spotify username.
#' @param authorization Required. A valid access token from the Spotify Accounts service.
#' See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details.
#' Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing track audio features data. See the
#' \href{https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-audio-features/}{Spotify Web API documentation} for more information.
#' @family musicology functions
#' @export

get_user_audio_features <- function(username = NULL,
                                    authorization = get_spotify_access_token()
                                    ) {

    user_playlist_info <- get_user_playlists(username,
                                             include_meta_info = TRUE)

    if (user_playlist_info$total == 0) {
        stop(str_glue('Error: cannot find any public playlists belonging to username {"username"}.'))
    }

    num_loops_user_playlists <- ceiling(user_playlist_info$total / 20)

    if (num_loops_user_playlists > 1) {
        user_playlists <- map_df(1:num_loops_user_playlists, function(this_loop) {
            get_user_playlists(username,
                               offset = this_loop * 20,
                               authorization = authorization)
        })
    } else {
        user_playlists <- user_playlist_info$items
    }

    user_playlists <- user_playlists %>%
        dplyr::rename(playlist_id = .data$id,
               playlist_name =  .data$name)

    playlist_tracks <- purrr::map_df(user_playlists$playlist_id, function(this_playlist_id) {
        this_playlist_tracks <- get_playlist_tracks(this_playlist_id, include_meta_info = TRUE, authorization = authorization)
        num_loops_playlist_tracks <- ceiling(this_playlist_tracks$total / 20)
        if (num_loops_playlist_tracks > 1) {
            this_playlist_tracks <- purrr::map_df(1:num_loops_playlist_tracks, function(this_loop) {
                get_playlist_tracks(this_playlist_id, offset = (this_loop - 1) * 20, authorization = authorization)
            })
        } else {
            this_playlist_tracks <- this_playlist_tracks$items
        }

        this_playlist_tracks <- this_playlist_tracks %>%
            mutate(playlist_id = this_playlist_id,
                   playlist_name = user_playlists$playlist_name[user_playlists$playlist_id == this_playlist_id])
    })

    dupe_columns <- c('duration_ms', 'type', 'uri', 'track_href')

    num_loops_tracks <- ceiling(nrow(playlist_tracks) / 100)

    track_audio_features <- map_df(1:num_loops_tracks, function(this_loop) {
        track_ids <- playlist_tracks %>%
            slice(((this_loop * 100) - 99):(this_loop * 100)) %>%
            pull(track.id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>%
        dplyr::select(-dplyr::all_of( dupe_columns )) %>%
        dplyr::rename(track.id = .data$id) %>%
        dplyr::left_join(playlist_tracks, by = 'track.id') %>%
        dplyr::select(-c(playlist_name, primary_color))

    user_playlists %>%
        dplyr::left_join(track_audio_features, by = 'playlist_id') %>%
        dplyr::mutate(key_name = pitch_class_lookup[.data$key + 1],
               mode_name = dplyr::case_when(.data$mode == 1 ~ 'major',
                                     .data$mode == 0 ~ 'minor',
                                     TRUE ~ as.character(NA)),
               key_mode = paste(.data$key_name, .data$mode_name)
               )
}

#' Get Features and Popularity of Playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for a given set of
#' playlists on Spotify
#'
#' @param username String of Spotify username. Can be found on the Spotify app.
#' @param playlist_uris Character vector of Spotify playlist uris.
#' Can be found within the Spotify App
#' @param authorization Required. A valid access token from the Spotify Accounts service.
#' See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @keywords track audio features playlists
#' @export
#' @family musicology functions
#' @return A data frame with the audio features and popularity variables of playlists.
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' playlist_audio_features <- get_playlist_audio_features(playlist_username, playlist_uris)
#' }

get_playlist_audio_features <- function(username,
                                        playlist_uris,
                                        authorization = get_spotify_access_token()
                                        ) {

    playlist_tracks <- purrr::map_df(playlist_uris, function(playlist_uri) {
        this_playlist <- get_playlist(playlist_uri, authorization = authorization)
        n_tracks <- this_playlist$tracks$total
        num_loops <- ceiling(n_tracks / 100)
        purrr::map_df(1:num_loops, function(this_loop) {
            get_playlist_tracks(this_playlist$id,
                                limit = 100,
                                offset = (this_loop - 1) * 100,
                                authorization = authorization) %>%
                dplyr::mutate(
                  playlist_id = this_playlist$id,
                  playlist_name = this_playlist$name,
                  playlist_img = this_playlist$images$url[[1]],
                  playlist_owner_name = this_playlist$owner$display_name,
                  playlist_owner_id = this_playlist$owner$id
                )
        })
    })

    dupe_columns <- c('duration_ms', 'type', 'uri', 'track_href')

    num_loops_tracks <- ceiling(nrow(playlist_tracks) / 100)
    track_audio_features <- purrr::map_df(1:num_loops_tracks, function(this_loop) {
        track_ids <- playlist_tracks %>%
            dplyr::slice(((this_loop * 100) - 99):(this_loop * 100)) %>%
            dplyr::pull(track.id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>% dplyr::select(-dupe_columns) %>%
        dplyr::rename(track.id = id)

    playlist_audio_features <- track_audio_features %>%
        dplyr::left_join(playlist_tracks, by = 'track.id') %>%
        dplyr::mutate(key_name = pitch_class_lookup[key + 1],
               mode_name = dplyr::case_when(
                   .data$mode == 1 ~ 'major',
                   .data$mode == 0 ~ 'minor',
                   TRUE ~ as.character(NA)),
               key_mode = paste(.data$key_name, .data$mode_name)
               ) %>%
        dplyr::select(playlist_id, playlist_name, playlist_img, playlist_owner_name, playlist_owner_id, everything())

    playlist_audio_features
}
