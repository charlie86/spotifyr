#' Search for an Item
#'
#' Get Spotify Catalog information about artists, albums, tracks or playlists that match a
#' keyword string. For more information see the official
#' \href{https://developer.spotify.com/documentation/web-api/reference/#category-search}{documentation}.
#' @param q Required. \cr
#' Search query keywords and optional field filters and operators.
#' @param type A character vector of item types to search across. \cr
#' Valid types are \code{album}, \code{artist}, \code{playlist}, and \code{track}. \cr
#' Search results include hits from all the specified item types. \cr
#' For example: \code{q = "name:abacab"} and \code{type =c("album", "track")} returns both albums and tracks with \code{"abacab"} included in their name.
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. \cr
#' If a country code is specified, only artists, albums, and tracks with content that is playable in that market is returned. \cr
#' Note: \cr
#' - Playlist results are not affected by the market parameter. \cr
#' - If market is set to \code{"from_token"}, and a valid access token is specified in the request header, only content playable in the country associated with the user account, is returned. \cr
#' - Users can view the country that is associated with their account in the account settings. A user must grant access to the user-read-private scope prior to when the access token is issued.
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' Note: The limit is applied within each type, not on the total response. \cr
#' For example, if the limit value is 3 and the type is \code{c("artist", "album")}, the response contains 3 artists and 3 albums.
#' @param offset Optional. \cr
#' The index of the first result to return. \cr
#' Default: 0 (the first result). \cr
#' Maximum offset (including limit): 10,000. \cr
#' Use with limit to get the next page of search results.
#' @param include_external Optional. \cr
#' Possible values: audio \cr
#' If \code{include_external = "audio"} is specified the response will include any
#' relevant audio content that is hosted externally. \cr
#' By default external content is filtered out from responses.
#' @param authorization Required. A valid access token from the Spotify Accounts service.
#' See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @export
#' @family search functions
#' @return A tibble with detailed information about the searched album, artist, playlist, track or
#' their combination.
#' @examples
#' \donttest{
#' search_spotify('radiohead', 'artist')
#' }

search_spotify <- function(q,
                           type = c('album', 'artist', 'playlist', 'track'),
                           market = NULL,
                           limit = 20,
                           offset = 0,
                           include_external = NULL,
                           authorization = get_spotify_access_token(),
                           include_meta_info = FALSE) {

    base_url <- 'https://api.spotify.com/v1/search'

    assertthat::assert_that(
        is.character(q),
        msg = "The parameter 'q' must be a character string."
    )

    if (!is.null(market)) {
        assertthat::assert_that(
            str_detect(market, '^[[:alpha:]]{2}$'),
            msg = "The parameter 'market' must be an ISO 3166-1 alpha-2 country code."
        )
    }

    assertthat::assert_that(
        (limit >= 1 & limit <= 50) & is.numeric(limit) & limit%%1==0,
        msg = "The parameter 'limit' must be an integer between 1 and 50"
    )

    assertthat::assert_that(
        (offset >= 0 & offset <= 10000) & is.numeric(offset) & offset%%1==0,
        msg = "The parameter 'offset' must be an integer between 1 and 50"
    )


    if (!is.null(include_external)) {
        assertthat::assert_that(
            include_external == 'audio',
            msg = "'include_external' must be 'audio' or an empty string."
        )
     }

    params <- list(
        q = q,
        type = paste(type, collapse = ','),
        market = market,
        limit = limit,
        offset = offset,
        include_external = include_external,
        access_token = authorization
    )

    res <- RETRY('GET', base_url,
                 query = params,
                 encode = 'json')

    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'),
                    flatten = TRUE)

    if (!include_meta_info && length(type) == 1) {
        res <- res[[str_glue('{type}s')]]$items %>%
            as_tibble
    }

    res
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
#' @param authorization Required.
#' A valid access token from the Spotify Accounts service.
#' See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @export
#' @family label functions
#' @return A data frame with the label information of the artists.
#' @examples
#' \donttest{
#' get_label_artists('brainfeeder')
#' }

get_label_artists <- function(label = character(),
                              market = NULL,
                              limit = 20,
                              offset = 0,
                              authorization = get_spotify_access_token()
                              ) {

    base_url <- 'https://api.spotify.com/v1/search'

    assertthat::assert_that(
        is.character(label),
        msg = "The parameter 'label' must be a character string."
    )

    if (!is.null(market)) {
        assertthat::assert_that(
            str_detect(market, '^[[:alpha:]]{2}$'),
            msg = "The parameter 'market' must be an ISO 3166-1 alpha-2 country code."
        )
    }

    assertthat::assert_that(
        (limit >= 1 & limit <= 50) & is.numeric(limit) & limit%%1==0,
        msg = "The parameter 'limit' must be an integer between 1 and 50"
    )

    assertthat::assert_that(
        (offset >= 0 & offset <= 10000) & is.numeric(offset) & offset%%1==0,
        msg = "The parameter 'offset' must be an integer between 1 and 50"
    )

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

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'),
                    flatten = TRUE)
    res <- res[['artists']]$items %>%
        as_tibble() %>%
        mutate(label = label)

    res
}

#' Search for Artists by Genre
#'
#' Get Spotify Catalog information about artists belonging to a given genre.
#'
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @family musicology functions
#' @return A data frame of the artists belonging to the genre with data and metadata about the
#' artists in a tibble.
#' @export
#' @examples
#' \donttest{
#' get_genre_artists('wonky')
#' }

get_genre_artists <- function(genre = character(),
                              market = NULL,
                              limit = 20,
                              offset = 0,
                              authorization = get_spotify_access_token()) {

    base_url <- 'https://api.spotify.com/v1/search'

    assertthat::assert_that(
        is.character(genre),
        msg = "The parameter 'genre' must be a character string."
    )

    if (!is.null(market)) {
        assertthat::assert_that(
            str_detect(market, '^[[:alpha:]]{2}$'),
            msg = "The parameter 'market' must be an ISO 3166-1 alpha-2 country code."
        )
    }

    assertthat::assert_that(
        (limit >= 1 & limit <= 50) & is.numeric(limit) & limit%%1==0,
        msg = "The parameter 'limit' must be an integer between 1 and 50"
    )

    assertthat::assert_that(
        (offset >= 0 & offset <= 10000) & is.numeric(offset) & offset%%1==0,
        msg = "The parameter 'offset' must be an integer between 1 and 50"
    )

    params <- list(
        q = str_replace_all(str_glue('genre:"{genre}"'), ' ', '+'),
        type = 'artist',
        market = market,
        limit = limit,
        offset = offset,
        access_token = authorization
    )

    params

    res <- RETRY('GET', base_url, query = params, encode = 'json')

    stop_for_status(res)

    res

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'),
                    flatten = TRUE)

    artists <- res$artists

    artists <- artists$items %>%
        as_tibble() %>%
        mutate(genre = genre)

    artists
}
