#' Get Spotify catalog information for a single artist identified by their unique Spotify ID.
#'
#' @param id The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the artist.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing album data. See \url{https://developer.spotify.com/documentation/web-api/reference/albums/get-album/} for more information.
#' @export

get_artist <- function(id, authorization = get_spotify_access_token()) {

    base_url <- 'https://api.spotify.com/v1/artists'

    params <- list(
        access_token = authorization
    )
    url <- str_glue('{base_url}/{id}')
    res <- GET(url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    return(res)
}

#' Get Spotify catalog information for multiple artists identified by their Spotify IDs.
#'
#' @param ids Required. A character vector of the \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs} for the artists. Maximum: 50 IDs.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing artist data. See \url{https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/} for more information.
#' @export

get_artists <- function(ids, authorization = get_spotify_access_token(), include_meta_info = FALSE) {

    base_url <- 'https://api.spotify.com/v1/artists'

    params <- list(
        ids = paste(ids, collapse = ','),
        access_token = authorization
    )
    res <- GET(base_url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$artists
    }

    return(res)
}

#' Get Spotify catalog information for multiple artists identified by their Spotify IDs.
#'
#' @param id The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the artist.
#' @param include_groups Optional. A character vector of keywords that will be used to filter the response. If not supplied, all album types will be returned. Valid values are: \cr
#' \code{"album"} \cr
#' \code{"single"} \cr
#' \code{"appears_on"} \cr
#' \code{"compilation"} \cr
#' For example: \code{include_groups = c("album", "single")}
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. \cr
#' Supply this parameter to limit the response to one particular geographical market. For example, for albums available in Sweden: \code{market = "SE"}. \cr
#' If not given, results will be returned for all markets and you are likely to get duplicate results per album, one for each market in which the album is available!
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' @param offset Optional. \cr
#' The index of the first album to return. \cr
#' Default: 0 (i.e., the first album). \cr
#' Use with limit to get the next set of albums.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing artist data. See \url{https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/} for more information.
#' @export

get_artist_albums <- function(id, include_groups = c('album', 'single', 'appears_on', 'compilation'), market = NULL, limit = 20, offset = 0, authorization = get_spotify_access_token(), include_meta_info = FALSE) {

    base_url <- 'https://api.spotify.com/v1/artists'

    if (!is.null(market)) {
        if (!str_detect(market, '^[[:alpha:]]{2}$')) {
            stop('"market" must be an ISO 3166-1 alpha-2 country code')
        }
    }

    params <- list(
        include_groups = paste(include_groups, collapse = ','),
        market = market,
        limit = limit,
        offset = offset,
        access_token = authorization
    )
    url <- str_glue('{base_url}/{id}/albums')
    res <- GET(url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Get Spotify catalog information about an artist’s top tracks by country.
#'
#' @param id The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the artist.
#' @param market Required. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}.
#' Defaults to \code{"US"}.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing artist data. See \url{https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/} for more information.
#' @export

get_artist_top_tracks <- function(id, market = 'US', authorization = get_spotify_access_token(), include_meta_info = FALSE) {

    base_url <- 'https://api.spotify.com/v1/artists'

    if (!is.null(market)) {
        if (!str_detect(market, '^[[:alpha:]]{2}$')) {
            stop('"market" must be an ISO 3166-1 alpha-2 country code')
        }
    }

    params <- list(
        market = market,
        access_token = authorization
    )
    url <- str_glue('{base_url}/{id}/top-tracks')
    res <- GET(url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$tracks
    }

    return(res)
}

#' Get Spotify catalog information about artists similar to a given artist. Similarity is based on analysis of the Spotify community’s listening history.
#'
#' @param id The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the artist.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing artist data. See \url{https://developer.spotify.com/documentation/web-api/reference/artists/get-several-artists/} for more information.
#' @export

get_related_artists <- function(id, authorization = get_spotify_access_token(), include_meta_info = FALSE) {

    base_url <- 'https://api.spotify.com/v1/artists'

    params <- list(
        access_token = authorization
    )
    url <- str_glue('{base_url}/{id}/related-artists')
    res <- GET(url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$artists
    }

    return(res)
}
