#' Get Spotify catalog information for a single show.
#'
#' @param id The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the show.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Reading the user’s resume points on episode objects requires the user-read-playback-position scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @param market Optional. \cr
#' An \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code} or the string \code{"from_token"}. If a country code is specified, only shows and episodes that are available in that market will be returned. If a valid user access token is specified in the request header, the country associated with the user account will take priority over this parameter.
#' @return
#' Returns a data frame of results containing show data. See the \href{https://developer.spotify.com/documentation/web-api/reference/shows/get-a-show/}{official documentation} for more information.
#' @export

get_show <- function(id, market = NULL, authorization = get_spotify_authorization_code()) {

  base_url <- 'https://api.spotify.com/v1/shows'

  if (!is.null(market)) {
    if (str_detect(market, '^[[:alpha:]]{2}$')) {
      stop('"market" must be an ISO 3166-1 alpha-2 country code')
    }
  }

  params <- list(
    market = market
  )
  url <- str_glue('{base_url}/{id}')
  res <- RETRY('GET', url, query = params, config(token = authorization), encode = 'json')
  stop_for_status(res)

  res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

  return(res)
}

#' Get Spotify catalog information for multiple shows identified by their Spotify IDs.
#'
#' @param ids Required. A character vector of the \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs} for the shows. Maximum: 20 IDs.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Reading the user’s resume points on episode objects requires the user-read-playback-position scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @param market Optional. \cr
#' An \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code} or the string \code{"from_token"}. If a country code is specified, only shows and episodes that are available in that market will be returned. If a valid user access token is specified in the request header, the country associated with the user account will take priority over this parameter.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing show data. See \url{https://developer.spotify.com/documentation/web-api/reference/shows/get-several-shows/} for more information.
#' @export

get_shows <- function(ids, market = NULL, authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {

  base_url <- 'https://api.spotify.com/v1/shows'

  if (!is.null(market)) {
    if (str_detect(market, '^[[:alpha:]]{2}$')) {
      stop('"market" must be an ISO 3166-1 alpha-2 country code')
    }
  }

  params <- list(
    ids = paste(ids, collapse = ','),
    market = market
  )
  res <- RETRY('GET', base_url, query = params, config(token = authorization), encode = 'json')
  stop_for_status(res)

  res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

  if (!include_meta_info) {
    res <- res$shows
  }

  return(res)
}

#' Get Spotify catalog information about an show's episodes. Optional parameters can be used to limit the number of episodes returned.
#'
#' @param id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the show.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Reading the user’s resume points on episode objects requires the user-read-playback-position scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @param limit Optional. \cr
#' Maximum number of results to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' @param offset Optional. \cr
#' The index of the first album to return. \cr
#' Default: 0 (the first album). \cr
#' Maximum offset (including limit): 10,000. \cr
#' Use with limit to get the next set of episodes.
#' @param market Optional. \cr
#' An \href{http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code} or the string \code{"from_token"}. If a country code is specified, only shows and episodes that are available in that market will be returned. If a valid user access token is specified in the request header, the country associated with the user account will take priority over this parameter.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing show data. See the official API \href{https://developer.spotify.com/documentation/web-api/reference/shows/get-shows-episodes/}{documentation} for more information.
#' @export

get_show_episodes <- function(id, limit = 20, offset = 0, market = NULL, authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {

  base_url <- 'https://api.spotify.com/v1/shows'

  if (!is.null(market)) {
    if (str_detect(market, '^[[:alpha:]]{2}$')) {
      stop('"market" must be an ISO 3166-1 alpha-2 country code')
    }
  }

  params <- list(
    market = market,
    offset = offset,
    limit = limit
  )
  url <- str_glue('{base_url}/{id}/episodes')
  res <- RETRY('GET', url, query = params, config(token = authorization), encode = 'json')
  stop_for_status(res)

  res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

  if (!include_meta_info) {
    res <- res$items
  }

  return(res)
}
