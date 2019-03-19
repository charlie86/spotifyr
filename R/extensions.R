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
#' @param dedupe_albums Optional. Boolean
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing track audio features data. See the \href{https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-audio-features/}{Spotify Web API documentation} for more information.
#' @export
get_artist_audio_features <- function(artist = NULL, include_groups = 'album', return_closest_artist = TRUE,
                                      dedupe_albums = TRUE, authorization = get_spotify_access_token()) {

    artist_ids <- search_spotify(artist, 'artist', authorization = authorization)

    if (return_closest_artist) {
        artist_id <- artist_ids$id[1]
        artist_name <- artist_ids$name[1]
    }

    artist_albums <- get_artist_albums(artist_id, include_groups = include_groups, include_meta_info = TRUE, authorization = authorization)
    num_loops_artist_albums <- ceiling(artist_albums$total / 20)
    if (num_loops_artist_albums > 1) {
        artist_albums <- map_df(1:num_loops_artist_albums, function(this_loop) {
            get_artist_albums(artist_id, include_groups = include_groups, offset = (this_loop - 1) * 20, authorization = authorization)
        })
    } else {
        artist_albums <- artist_albums$items
    }

    artist_albums <- artist_albums %>%
        rename(album_id = id,
               album_name = name) %>%
        mutate(album_release_year = case_when(release_date_precision == 'year' ~ suppressWarnings(as.numeric(release_date)),
                                              release_date_precision == 'day' ~ year(as.Date(release_date, '%Y-%m-%d', origin = '1970-01-01')),
                                              TRUE ~ as.numeric(NA)))

    if (dedupe_albums) {
        artist_albums <- dedupe_album_names(artist_albums)
    }

    album_tracks <- map_df(artist_albums$album_id, function(this_album_id) {
        album_tracks <- get_album_tracks(this_album_id, include_meta_info = TRUE, authorization = authorization)
        num_loops_album_tracks <- ceiling(album_tracks$total / 20)
        if (num_loops_album_tracks > 1) {
            album_tracks <- map_df(1:num_loops_album_tracks, function(this_loop) {
                get_album_tracks(this_album_id, offset = (this_loop - 1) * 20, authorization = authorization)
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
            pull(track_id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>%
        select(-dupe_columns) %>%
        rename(track_id = id) %>%
        left_join(album_tracks, by = 'track_id')

    artist_albums %>%
        mutate(artist_name = artist_name,
               artist_id = artist_id) %>%
        select(artist_name, artist_id, album_id, album_type, album_images = images, album_release_date = release_date,
               album_release_year, album_release_date_precision = release_date_precision) %>%
        left_join(track_audio_features, by = 'album_id') %>%
        mutate(key_name = pitch_class_lookup[key + 1],
               mode_name = case_when(mode == 1 ~ 'major', mode == 0 ~ 'minor', TRUE ~ as.character(NA)),
               key_mode = paste(key_name, mode_name))
}

#' Search for artists by label
#'
#' Get Spotify Catalog information about artists belonging to a given label.
#' @param label Required. \cr
#' String of label name to search for \cr
#' For example: \code{label = "brainfeeder"}.
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. \cr
#' If a country code is specified, only artists with content that is playable in that market is returned. \cr
#' Note: \cr
#' - If market is set to \code{"from_token"}, and a valid access token is specified in the request header, only content playable in the country associated with the user account is returned. \cr
#' - Users can view the country that is associated with their account in the account settings. A user must grant access to the user-read-private scope prior to when the access token is issued.
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50
#' @param offset Optional. \cr
#' The index of the first result to return. \cr
#' Default: 0 (the first result). \cr
#' Maximum offset (including limit): 10,000. \cr
#' Use with limit to get the next page of search results.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @keywords search label artist
#' @export
#' @examples
#' \dontrun{
#' get_label_artists('brainfeeder')
#' }
get_label_artists <- function(label = character(), market = NULL, limit = 20, offset = 0, authorization = get_spotify_access_token()) {

    base_url <- 'https://api.spotify.com/v1/search'

    if (!is.character(label)) {
        stop('"label" must be a string')
    }

    if (!is.null(market)) {
        if (!str_detect(market, '^[[:alpha:]]{2}$')) {
            stop('"market" must be an ISO 3166-1 alpha-2 country code')
        }
    }

    if ((limit < 1 | limit > 50) | !is.numeric(limit)) {
        stop('"limit" must be an integer between 1 and 50')
    }

    if ((offset < 0 | offset > 10000) | !is.numeric(offset)) {
        stop('"offset" must be an integer between 1 and 10,000')
    }

    params <- list(
        q = str_replace_all(str_glue('label:"{label}"'), ' ', '+'),
        type = 'artist',
        market = market,
        limit = limit,
        offset = offset,
        access_token = authorization
    )
    print(params)
    res <- RETRY('GET', base_url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    res <- res[['artists']]$items %>%
        as_tibble() %>%
        mutate(label = label)

    return(res)
}

#' Search for artists by genre
#'
#' Get Spotify Catalog information about artists belonging to a given genre
#' @param genre Required. \cr
#' String of genre name to search for \cr
#' For example: \code{genre = "wonky"}.
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. \cr
#' If a country code is specified, only artists with content that is playable in that market is returned. \cr
#' Note: \cr
#' - If market is set to \code{"from_token"}, and a valid access token is specified in the request header, only content playable in the country associated with the user account is returned. \cr
#' - Users can view the country that is associated with their account in the account settings. A user must grant access to the user-read-private scope prior to when the access token is issued.
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50
#' @param offset Optional. \cr
#' The index of the first result to return. \cr
#' Default: 0 (the first result). \cr
#' Maximum offset (including limit): 10,000. \cr
#' Use with limit to get the next page of search results.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @keywords search label artist
#' @export
#' @examples
#' \dontrun{
#' get_genre_artists('wonky')
#' }
get_genre_artists <- function(genre = character(), market = NULL, limit = 20, offset = 0, authorization = get_spotify_access_token()) {

    base_url <- 'https://api.spotify.com/v1/search'

    if (!is.character(genre)) {
        stop('"genre" must be a string')
    }

    if (!is.null(market)) {
        if (!str_detect(market, '^[[:alpha:]]{2}$')) {
            stop('"market" must be an ISO 3166-1 alpha-2 country code')
        }
    }

    if ((limit < 1 | limit > 50) | !is.numeric(limit)) {
        stop('"limit" must be an integer between 1 and 50')
    }

    if ((offset < 0 | offset > 10000) | !is.numeric(offset)) {
        stop('"offset" must be an integer between 1 and 10,000')
    }

    params <- list(
        q = str_replace_all(str_glue('genre:"{genre}"'), ' ', '+'),
        type = 'artist',
        market = market,
        limit = limit,
        offset = offset,
        access_token = authorization
    )
    print(params)
    res <- RETRY('GET', base_url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    res <- res[['artists']]$items %>%
        as_tibble() %>%
        mutate(genre = genre)

    return(res)
}

#' Get audio feature information for a users' playlists
#'
#' @param username Required. String of Spotify username.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing track audio features data. See the \href{https://developer.spotify.com/documentation/web-api/reference/tracks/get-several-audio-features/}{Spotify Web API documentation} for more information.
#' @export
get_user_audio_features <- function(username = NULL, authorization = get_spotify_access_token()) {

    user_playlist_info <- get_user_playlists(username, include_meta_info = TRUE)

    if (user_playlist_info$total == 0) {
        stop(str_glue('Error: cannot find any public playlists belonging to username {"username"}.'))
    }

    num_loops_user_playlists <- ceiling(user_playlist_info$total / 20)
    if (num_loops_user_playlists > 1) {
        user_playlists <- map_df(1:num_loops_user_playlists, function(this_loop) {
            get_user_playlists(username, offset = this_loop * 20, authorization = authorization)
        })
    } else {
        user_playlists <- user_playlist_info$items
    }

    user_playlists <- user_playlists %>%
        rename(playlist_id = id,
               playlist_name = name)

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
            slice(playlist_tracks$track.id[((this_loop * 100) - 99):(this_loop * 100)]) %>%
            pull(track.id)
        get_track_audio_features(track_ids, authorization = authorization)
    }) %>%
        select(-dupe_columns) %>%
        rename(track.id = id) %>%
        left_join(playlist_tracks, by = 'track.id') %>%
        select(-c(playlist_name, primary_color))

    user_playlists %>%
        left_join(track_audio_features, by = 'playlist_id') %>%
        mutate(key_name = pitch_class_lookup[key + 1],
               mode_name = case_when(mode == 1 ~ 'major', mode == 0 ~ 'minor', TRUE ~ as.character(NA)),
               key_mode = paste(key_name, mode_name))
}

#' Get features and popularity for all of a given set of playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for a given set of playlists on Spotify
#' @param username String of Spotify username. Can be found on the Spotify app.
#' @param playlist_uris Character vector of Spotify playlist uris. Can be found within the Spotify App
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @keywords track audio features playlists
#' @export
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' playlist_audio_features <- get_playlist_audio_features(playlist_username, playlist_uris)
#' }

get_playlist_audio_features <- function(username, playlist_uris, authorization = get_spotify_access_token()) {

    playlist_tracks <- map_df(playlist_uris, function(playlist_uri) {
        this_playlist <- get_playlist(playlist_uri)
        n_tracks <- this_playlist$tracks$total
        num_loops <- ceiling(n_tracks / 100)
        map_df(1:num_loops, function(this_loop) {
            get_playlist_tracks(tmp$id, limit = 100, offset = (this_loop - 1) * 100, authorization = authorization) %>%
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
               mode_name = case_when(mode == 1 ~ 'major', mode == 0 ~ 'minor', TRUE ~ as.character(NA)),
               key_mode = paste(key_name, mode_name)) %>%
        select(playlist_id, playlist_name, playlist_img, playlist_owner_name, playlist_owner_id, everything())

    return(playlist_audio_features)
}
