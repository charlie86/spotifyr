#' Get a list of Spotify categories
#'
#' @param df (default TRUE). Should the results be formatted as a data frame? If FALSE, the full response JSON will be returned as a list.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#'
#' @return
#' Returns a data frame of results containing album data. See \url{https://developer.spotify.com/documentation/web-api/reference/browse/get-list-categories/} for more information.
#' @export

get_categories <- function(authorization = get_spotify_access_token(), df = TRUE) {

    url <- 'https://api.spotify.com/v1/browse/categories'

    params <- list(
        access_token = authorization
    )

    res <- GET(url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if(df) res <- res$categories$items %>% select(id, name, everything())

    return(res)
}


#' Get a single category used to tag items in Spotify (on, for example, the Spotify player’s “Browse” tab).
#'
#' @param category_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the category.
#' @param country Optional. A country: an \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}. Provide this parameter to ensure that the category exists for a particular country.
#' @param locale Optional. The desired language, consisting of an \href{http://en.wikipedia.org/wiki/ISO_639-1}{ISO 639-1} language code and an \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}, joined by an underscore. For example: \code{es_MX}, meaning "Spanish (Mexico)". Provide this parameter if you want the category strings returned in a particular language. Note that, if \code{locale} is not supplied, or if the specified language is not available, the category strings returned will be in the Spotify default language (American English).
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a list of results containing category information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export

get_category <- function(category_id, country = NULL, locale = NULL, authorization = get_spotify_access_token()) {
    base_url <- 'https://api.spotify.com/v1/browse/categories'
    url <- str_glue('{base_url}/{category_id}')
    params <- list(
        country = country,
        locale = locale,
        access_token = authorization
    )
    res <- RETRY('GET', url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>%
        as.data.frame(stringsAsFactors = FALSE)
    return(res)
}


#' Get a list of Spotify playlists tagged with a particular category.
#'
#' @param category_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the category.
#' @param country Optional. A country: an \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}.
#' @param limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
#' @param offset Optional. The index of the first item to return. Default: 0 (the first object). Use with \code{limit} to get the next set of items.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing category playlists. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Get Brazilian party playlists
#' get_category_playlists('party', country = 'BR')
#' }

get_category_playlists <- function(category_id, country = NULL, limit = 20, offset = 0, authorization = get_spotify_access_token(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/browse/categories'
    url <- str_glue('{base_url}/{category_id}/playlists')
    params <- list(
        country = country,
        limit = limit,
        offset = offset,
        access_token = authorization
    )
    res <- RETRY('GET', url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>% .$playlists
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Get a list of new album releases featured in Spotify (shown, for example, on a Spotify player’s “Browse” tab).
#'
#' @param country Optional. A country: an \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}. Provide this parameter if you want the list of returned items to be relevant to a particular country. If omitted, the returned items will be relevant to all countries.
#' @param limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
#' @param offset Optional. The index of the first item to return. Default: 0 (the first object). Use with \code{limit} to get the next set of items.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"country"}, \code{"offset"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing new releases. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Get new Swedish music
#' get_new_releases(country = 'SE')
#' }

get_new_releases <- function(country = NULL, limit = 20, offset = 0, authorization = get_spotify_access_token(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/browse/new-releases'
    params <- list(
        country = country,
        limit = limit,
        offset = offset,
        access_token = authorization
    )
    res <- RETRY('GET', base_url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>% .$albums
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Get a list of Spotify featured playlists (shown, for example, on a Spotify player’s ‘Browse’ tab).
#'
#' @param locale Optional. The desired language, consisting of an \href{http://en.wikipedia.org/wiki/ISO_639-1}{ISO 639-1} language code and an \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}, joined by an underscore. For example: \code{es_MX}, meaning "Spanish (Mexico)". Provide this parameter if you want the category strings returned in a particular language. Note that, if \code{locale} is not supplied, or if the specified language is not available, the category strings returned will be in the Spotify default language (American English). The \code{locale} parameter, combined with the \code{country} parameter, may give odd results if not carefully matched. For example \code{country=SE&locale=de_DE} will return a list of categories relevant to Sweden but as German language strings.
#' @param country Optional. A country: an \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}. Provide this parameter if you want the list of returned items to be relevant to a particular country. If omitted, the returned items will be relevant to all countries.
#' @param timestamp Optional. A timestamp in \href{http://en.wikipedia.org/wiki/ISO_8601}{ISO 8601 format}: \code{yyyy-MM-ddTHH:mm:ss}. Use this parameter to specify the user’s local time to get results tailored for that specific date and time in the day. If not provided, the response defaults to the current UTC time. Example: “2014-10-23T09:00:00” for a user whose local time is 9AM. If there were no featured playlists (or there is no data) at the specified time, the response will revert to the current UTC time.
#' @param limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
#' @param offset Optional. The index of the first item to return. Default: 0 (the first object). Use with \code{limit} to get the next set of items.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing featured playlists. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Get new Swedish music
#' get_featured_playlists(country = 'SE')
#' }

get_featured_playlists <- function(locale = NULL, country = NULL, timestamp = NULL, limit = 20, offset = 0, authorization = get_spotify_access_token(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/browse/featured-playlists'
    params <- list(
        locale = locale,
        country = country,
        timestamp = timestamp,
        limit = limit,
        offset = offset,
        access_token = authorization
    )
    res <- RETRY('GET', base_url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    res$playlists$message <- res$message
    res <- res$playlists
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Create a playlist-style listening experience based on seed artists, tracks and genres.
#'
#' @param limit Optional. The target size of the list of recommended tracks. For seeds with unusually small pools or when highly restrictive filtering is applied, it may be impossible to generate the requested number of recommended tracks. Debugging information for such cases is available in the response. Default: 20. Minimum: 1. Maximum: 100.
#' @param market Optional. An \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code} or the string \code{from_token}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide}{Track Relinking}. Because \code{min_*}, \code{max_*} and \code{target_*} are applied to pools before relinking, the generated results may not precisely match the filters applied. Original, non-relinked tracks are available via the \code{linked_from} attribute of the \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide}{relinked track response}.
#' @param max_acousticness Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' acousticness.
#' @param max_danceability Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' danceability.
#' @param max_duration_ms Optional. Integer indicating a hard ceiling on recommended tracks' duration in milliseconds.
#' @param max_energy Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' energy.
#' @param max_instrumentalness Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' instrumentalness.
#' @param max_key Optional. Integer ranging from 1 to 12 indicating a hard ceiling on recommended tracks' key.
#' @param max_liveness Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' liveness.
#' @param max_loudness Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' loudness.
#' @param max_mode Optional. Integer ranging from 0 to 1 indicating a hard ceiling on recommended tracks' mode.
#' @param max_popularity Optional. Integer ranging between 0 and 100 indicating a hard ceiling on recommended tracks' popularity.
#' @param max_speechiness Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' speechiness.
#' @param max_tempo Optional. Numeric value indicating a hard ceiling on recommended tracks' tempo.
#' @param max_time_signature Optional. Integer indicating a hard ceiling on recommended tracks' time signature.
#' @param max_valence Optional. Numeric value between 0 and 1 indicating a hard ceiling on recommended tracks' valence.
#' @param min_acousticness Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' acousticness.
#' @param min_danceability Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' danceability.
#' @param min_duration_ms Optional. Integer indicating a hard floor on recommended tracks' duration in milliseconds.
#' @param min_energy Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' energy.
#' @param min_instrumentalness Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' instrumentalness.
#' @param min_key Optional. Integer ranging from 1 to 12 indicating a hard floor on recommended tracks' key.
#' @param min_liveness Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' liveness.
#' @param min_loudness Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' loudness.
#' @param min_mode Optional. Integer ranging from 0 to 1 indicating a hard floor on recommended tracks' mode.
#' @param min_popularity Optional. Integer ranging between 0 and 100 indicating a hard floor on recommended tracks' popularity.
#' @param min_speechiness Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' speechiness.
#' @param min_tempo Optional. Numeric value indicating a hard floor on recommended tracks' tempo.
#' @param min_time_signature Optional. Integer indicating a hard floor on recommended tracks' time signature.
#' @param min_valence Optional. Numeric value between 0 and 1 indicating a hard floor on recommended tracks' valence.
#' @param target_acousticness Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' acousticness. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_danceability Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' danceability. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_duration_ms Optional. Integer indicating a target value for recommended tracks' duration in milliseconds. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_energy Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' energy. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_instrumentalness Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' instrumentalness. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_key Optional. Integer ranging from 1 to 12 indicating a target value for recommended tracks' key. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_liveness Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' liveness. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_loudness Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' loudness. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_mode Optional. Integer ranging from 0 to 1 indicating a target value for recommended tracks' mode. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_popularity Optional. Integer ranging between 0 and 100 indicating a target value for recommended tracks' popularity. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_speechiness Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' speechiness. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_tempo Optional. Numeric value indicating a target value for recommended tracks' tempo. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_time_signature Optional. Integer indicating a target value for recommended tracks' time signature. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param target_valence Optional. Numeric value between 0 and 1 indicating a target value for recommended tracks' valence. Tracks with the attribute values nearest to the target values will be preferred. For example, you might request \code{target_energy = 0.6} and \code{target_danceability = 0.8}. All target values will be weighed equally in ranking results.
#' @param seed_artists A character vector of \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs} for seed artists. Up to 5 seed values may be provided in any combination of \code{seed_artists}, \code{seed_tracks} and \code{seed_genres}.
#' @param seed_genres A character vector of any genres in the set of \href{https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/#available-genre-seeds}{available genre seeds}. Up to 5 seed values may be provided in any combination of \code{seed_artists}, \code{seed_tracks} and \code{seed_genres}.
#' @param seed_tracks A character vector of \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs} for a seed track. Up to 5 seed values may be provided in any combination of \code{seed_artists}, \code{seed_tracks} and \code{seed_genres}.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_seeds_in_response Optional. Boolean for whether to include seed object in response. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results recommendations. See the official \href{https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/}{Spotify Web API documentation} for more information.
#' @export
#'
#' @examples
#' \dontrun{
#' ## Get new Swedish music
#' get_recommendations(country = 'SE')
#' }

get_recommendations <- function(limit = 20,
                                market = NULL,
                                seed_artists = NULL,
                                seed_genres = NULL,
                                seed_tracks = NULL,
                                max_acousticness = NULL,
                                max_danceability = NULL,
                                max_duration_ms = NULL,
                                max_energy = NULL,
                                max_instrumentalness = NULL,
                                max_key = NULL,
                                max_liveness = NULL,
                                max_loudness = NULL,
                                max_mode = NULL,
                                max_popularity = NULL,
                                max_speechiness = NULL,
                                max_tempo = NULL,
                                max_time_signature = NULL,
                                max_valence = NULL,
                                min_acousticness = NULL,
                                min_danceability = NULL,
                                min_duration_ms = NULL,
                                min_energy = NULL,
                                min_instrumentalness = NULL,
                                min_key = NULL,
                                min_liveness = NULL,
                                min_loudness = NULL,
                                min_mode = NULL,
                                min_popularity = NULL,
                                min_speechiness = NULL,
                                min_tempo = NULL,
                                min_time_signature = NULL,
                                min_valence = NULL,
                                target_acousticness = NULL,
                                target_danceability = NULL,
                                target_duration_ms = NULL,
                                target_energy = NULL,
                                target_instrumentalness = NULL,
                                target_key = NULL,
                                target_liveness = NULL,
                                target_loudness = NULL,
                                target_mode = NULL,
                                target_popularity = NULL,
                                target_speechiness = NULL,
                                target_tempo = NULL,
                                target_time_signature = NULL,
                                target_valence = NULL,
                                authorization = get_spotify_access_token(),
                                include_seeds_in_response = FALSE) {

    if (length(seed_artists) + length(seed_tracks) + length(seed_genres) > 5) {
        stop("Too many seed values. Up to 5 seed values may be provided in any combination of seed_artists, seed_tracks and seed_genres")
    }

    base_url <- 'https://api.spotify.com/v1/recommendations'
    params <- list(
        limit = limit,
        market = market,
        seed_artists = paste(seed_artists, collapse = ','),
        seed_genres = paste(seed_genres, collapse = ','),
        seed_tracks = paste(seed_tracks, collapse = ','),
        max_acousticness = max_acousticness,
        max_danceability = max_danceability,
        max_duration_ms = max_duration_ms,
        max_energy = max_energy,
        max_instrumentalness = max_instrumentalness,
        max_key = max_key,
        max_liveness = max_liveness,
        max_loudness = max_loudness,
        max_mode = max_mode,
        max_popularity = max_popularity,
        max_speechiness = max_speechiness,
        max_tempo = max_tempo,
        max_time_signature = max_time_signature,
        max_valence = max_valence,
        min_acousticness = min_acousticness,
        min_danceability = min_danceability,
        min_duration_ms = min_duration_ms,
        min_energy = min_energy,
        min_instrumentalness = min_instrumentalness,
        min_key = min_key,
        min_liveness = min_liveness,
        min_loudness = min_loudness,
        min_mode = min_mode,
        min_popularity = min_popularity,
        min_speechiness = min_speechiness,
        min_tempo = min_tempo,
        min_time_signature = min_time_signature,
        min_valence = min_valence,
        target_acousticness = target_acousticness,
        target_danceability = target_danceability,
        target_duration_ms = target_duration_ms,
        target_energy = target_energy,
        target_instrumentalness = target_instrumentalness,
        target_key = target_key,
        target_liveness = target_liveness,
        target_loudness = target_loudness,
        target_mode = target_mode,
        target_popularity = target_popularity,
        target_speechiness = target_speechiness,
        target_tempo = target_tempo,
        target_time_signature = target_time_signature,
        target_valence = target_valence,
        access_token = authorization
    )

    res <- RETRY('GET', base_url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    if (!include_seeds_in_response) {
        res <- res$tracks
    }
    return(res)
}


#' Get recommendations for a submitted vector of track IDs, with no limit on the number of seed tracks
#'
#' @description
#' This is a wrapper for the get_recommendations() function, which provides a workaround for the limit of 5 seed tracks per recommendation call. The function splits a supplied vector of track IDs into subsets of length 5, then applies a get_recommendations() call, 5 tracks at a time. This should generate a data frame of recommended tracks, with length equal to the supplied vector of track ids.
#'
#'
#' @param track_ids
#' A vector containing the IDs of the tracks you'd like recommendations for
#' @param valence
#' The target valence for the recommendations
#'
#' @return
#' Returns a data frame containing recommendations from the Spotify API
#' @export
#'
#' @examples
#' get_recommendations_all(c("5VIpLopHgolKcSSj7JPCMA" "3QRGYDFFUVb4qneE4DX1gR" "5daijadRuGwMA4HvhuOW9P" "020F5NN49ygwQzy0MjV7vb" "1gXU06BFeIcmkpBWisYCMB", "1msXkHv84LKikJGKcfdGBu"))
get_recommendations_all <- function(track_ids, valence = NULL) {
    get_recs <- function(i, ids, vec_length, valence) {
        start <- i
        end <- ifelse(i + 4 > vec_length, vec_length, i+4)
        seeds <- ids[c(start:end)]
        recs <- get_recommendations(limit = end + 1 - start,
                                    seed_tracks = seeds,
                                    target_valence = valence)
        recs
    }

    tracks_length <- length(track_ids)
    tracks_seq <- seq(from = 1, to = tracks_length, by = 5)
    all_recs <- map_df(tracks_seq,
                       ~ get_recs(.x, track_ids, tracks_length, valence))
    all_recs
}
