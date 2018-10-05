#' Get the object currently being played on the user’s Spotify account.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API Authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-currently-playing} and/or \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_my_currently_playing <- function(Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/currently-playing'
    res <- GET(base_url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Get the object currently being played on the user’s Spotify account.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API Authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-currently-playing} and/or \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_my_recently_played <- function(Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/recently-played'
    res <- GET(base_url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}
