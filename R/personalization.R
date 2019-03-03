#' Get the current user’s top artists or tracks based on calculated affinity.
#'
#' @param type Required. The type of entity to return. Valid values: \code{artists} or \code{tracks}.
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' @param offset Optional. \cr
#' The index of the first entity to return. \cr
#' Default: 0 (i.e., the first track). \cr
#' Use with limit to get the next set of entities.
#' @param time_range Optional. Over what time frame the affinities are computed. Valid values: long_term (calculated from several years of data and including all new data as it becomes available), \code{medium_term} (approximately last 6 months), \code{short_term} (approximately last 4 weeks). Default: \code{medium_term}.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing track or album data. See the official API \href{https://developer.spotify.com/documentation/web-api/reference/personalization/get-users-top-artists-and-tracks/}{documentation} for more information.
#' @export

get_my_top_artists_or_tracks <- function(type = NULL, limit = 20, offset = 0, time_range = 'medium_term', authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {

    if (!type %in% c('artists', 'tracks')) {
        stop('"type" must be one of "artists" or "tracks"')
    }

    if ((limit < 1 | limit > 50) | !is.numeric(limit)) {
        stop('"limit" must be an integer between 1 and 50')
    }

    if ((offset < 0 | offset > 10000) | !is.numeric(offset)) {
        stop('"offset" must be an integer between 1 and 10,000')
    }

    if (!time_range %in% c('short_term', 'medium_term', 'long_term')) {
        stop('"type" must be one of "short_term", "medium_term", or "long_term"')
    }

    base_url <- 'https://api.spotify.com/v1/me/top'

    params <- list(
        limit = limit,
        offset = offset,
        time_range = time_range
    )
    url <- str_glue('{base_url}/{type}')
    res <- RETRY('GET', url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)

    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$items
    }

    return(res)
}
