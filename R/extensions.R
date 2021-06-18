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
                                      authorization = get_spotify_access_token()
                                      ) {

    if (is_uri(artist)) {
        artist_info <- get_artist(artist, authorization = authorization)
        artist_id <- artist_info$id
        artist_name <- artist_info$name
    } else {
        artist_ids <- search_spotify(artist, 'artist', authorization = authorization)

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

    artist_albums <- get_artist_albums(artist_id,
                                       include_groups = include_groups,
                                       include_meta_info = TRUE,
                                       authorization = authorization)


    if (is.null(artist_albums$items) | length(artist_albums$items) ==0) {
        stop("No artist found with artist_id='", artist_id, "'.")
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
        rename(album_id = .data$id,
               album_name = .data$name) %>%
        mutate(album_release_year = case_when(
            release_date_precision == 'year' ~ suppressWarnings(as.numeric(.data$release_date)),
            release_date_precision == 'day' ~ year(
                          as.Date(.data$release_date, '%Y-%m-%d',
                                  origin = '1970-01-01')),
            TRUE ~ as.numeric(NA))
            )

    if (dedupe_albums) {
        artist_albums <- dedupe_album_names(df = artist_albums)
    }

    album_tracks <- map_df(artist_albums$album_id, function(this_album_id) {
        album_tracks <- get_album_tracks(this_album_id,
                                         include_meta_info = TRUE,
                                         authorization = authorization)

        num_loops_album_tracks <- ceiling(album_tracks$total / 20)
        if (num_loops_album_tracks > 1) {
            album_tracks <- map_df(1:num_loops_album_tracks, function(this_loop) {
                get_album_tracks(this_album_id,
                                 offset = (this_loop - 1) * 20,
                                 authorization = authorization)
            })
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
        track_ids <- album_tracks %>%
            slice(((this_loop * 100) - 99):(this_loop * 100)) %>%
            pull(.data$track_id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>%
        select(-all_of( dupe_columns )) %>%
        rename(track_id = .data$id) %>%
        left_join(album_tracks, by = 'track_id')

    artist_albums %>%
        mutate(artist_name = artist_name,
               artist_id = artist_id) %>%
        select(.data$artist_name, .data$artist_id, .data$album_id, .data$album_type,
               album_images = .data$images,
               album_release_date = .data$release_date,
               .data$album_release_year,
               album_release_date_precision = .data$release_date_precision) %>%
        left_join(track_audio_features, by = 'album_id') %>%
        mutate(key_name = pitch_class_lookup[key + 1],
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
        rename(playlist_id = .data$id,
               playlist_name =  .data$name)

    playlist_tracks <- map_df(user_playlists$playlist_id, function(this_playlist_id) {
        this_playlist_tracks <- get_playlist_tracks(this_playlist_id, include_meta_info = TRUE, authorization = authorization)
        num_loops_playlist_tracks <- ceiling(this_playlist_tracks$total / 20)
        if (num_loops_playlist_tracks > 1) {
            this_playlist_tracks <- map_df(1:num_loops_playlist_tracks, function(this_loop) {
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
        select(-all_of( dupe_columns )) %>%
        rename(track.id = .data$id) %>%
        left_join(playlist_tracks, by = 'track.id') %>%
        select(-c(playlist_name, primary_color))

    user_playlists %>%
        left_join(track_audio_features, by = 'playlist_id') %>%
        mutate(key_name = pitch_class_lookup[.data$key + 1],
               mode_name = case_when(.data$mode == 1 ~ 'major',
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
#' @return A data frame with the audio featurees and popularity variables of playlists.
#' @examples
#' \donttest{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' playlist_audio_features <- get_playlist_audio_features(playlist_username, playlist_uris)
#' }

get_playlist_audio_features <- function(username,
                                        playlist_uris,
                                        authorization = get_spotify_access_token()
                                        ) {

    playlist_tracks <- map_df(playlist_uris, function(playlist_uri) {
        this_playlist <- get_playlist(playlist_uri, authorization = authorization)
        n_tracks <- this_playlist$tracks$total
        num_loops <- ceiling(n_tracks / 100)
        map_df(1:num_loops, function(this_loop) {
            get_playlist_tracks(this_playlist$id, limit = 100, offset = (this_loop - 1) * 100, authorization = authorization) %>%
                mutate(playlist_id = this_playlist$id,
                       playlist_name = this_playlist$name,
                       playlist_img = this_playlist$images$url[[1]],
                       playlist_owner_name = this_playlist$owner$display_name,
                       playlist_owner_id = this_playlist$owner$id)
        })
    })

    dupe_columns <- c('duration_ms', 'type', 'uri', 'track_href')

    num_loops_tracks <- ceiling(nrow(playlist_tracks) / 100)
    track_audio_features <- map_df(1:num_loops_tracks, function(this_loop) {
        track_ids <- playlist_tracks %>%
            slice(((this_loop * 100) - 99):(this_loop * 100)) %>%
            pull(track.id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>% select(-dupe_columns) %>%
        rename(track.id = id)

    playlist_audio_features <- track_audio_features %>%
        left_join(playlist_tracks, by = 'track.id') %>%
        mutate(key_name = pitch_class_lookup[key + 1],
               mode_name = case_when(
                   .data$mode == 1 ~ 'major',
                   .data$mode == 0 ~ 'minor',
                   TRUE ~ as.character(NA)),
               key_mode = paste(.data$key_name, .data$mode_name)
               ) %>%
        select(playlist_id, playlist_name, playlist_img, playlist_owner_name, playlist_owner_id, everything())

    playlist_audio_features
}
