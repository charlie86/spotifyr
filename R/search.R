#' Search for an item
#'
#' Get Spotify Catalog information about artists, albums, tracks or playlists that match a keyword string.
#' @param q Required. \cr
#' Search query keywords and optional field filters and operators. \cr
#' For example: \code{q=roadhouse%20blues}.
#' @param type A character vector of item types to search across. \cr
#' Valid types are \code{album}, \code{artist}, \code{playlist}, and \code{track}. \cr
#' Search results include hits from all the specified item types. \cr
#' For example: \code{q=name:abacab&type=album, track} returns both albums and tracks with \code{"abacab"} included in their name.
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{from_token}. \cr
#' If a country code is specified, only artists, albums, and tracks with content that is playable in that market is returned. \cr
#' Note: \cr
#' - Playlist results are not affected by the market parameter. \cr
#' - If market is set to \code{from_token}, and a valid access token is specified in the request header, only content playable in the country associated with the user account, is returned. \cr
#' - Users can view the country that is associated with their account in the account settings. A user must grant access to the user-read-private scope prior to when the access token is issued.
#' @param offset Optional. \cr
#' The index of the first result to return. \cr
#' Default: 0 (the first result). \cr
#' Maximum offset (including limit): 10,000. \cr
#' Use with limit to get the next page of search results.
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' Note: The limit is applied within each type, not on the total response. \cr
#' For example, if the limit value is 3 and the type is \code{artist,album}, the response contains 3 artists and 3 albums.
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @keywords search
#' @export
#' @examples
#' \dontrun{
#' search_spotify('radiohead', 'artist')
#' }
search_spotify <- function(q, type = c('album', 'artist', 'playlist', 'track'), market = NULL, offset = 0, limit = 20, access_token = get_spotify_access_token()) {

    q = 'radiohead'
    type = c('album', 'artist', 'playlist', 'track')
    market = NULL
    offset = 0
    limit = 20
    access_token = get_spotify_access_token()

    base_url <- 'https://api.spotify.com/v1/search'

    params <- list(
        q = q,
        type = paste(type, collapse = ','),
        market = market,
        limit = limit,
        offset = offset,
        access_token = access_token
    )
    res <- GET(base_url, query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    res
}


