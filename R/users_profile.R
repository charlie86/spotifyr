#' Get detailed profile information about the current user (including the current user’s username).
#'
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Reading the user’s email address requires the \code{user-read-email} scope; reading country and product subscription level requires the \code{user-read-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export

get_my_profile <- function(authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/'
    res <- RETRY('GET', base_url, config(token = authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>%
        unlist() %>%
        t() %>%
        as_tibble()

    return(res)
}

#' Get public profile information about a Spotify user.
#'
#' @param user_id Required. The user's \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify user ID}.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-users-profile/} for more information.
#' @export

get_user_profile <- function(user_id, authorization = get_spotify_access_token()) {
    base_url <- 'https://api.spotify.com/v1/users'
    url <- str_glue('{base_url}/{user_id}')
    params = list(access_token = authorization)
    res <- RETRY('GET', url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>%
        unlist() %>%
        t() %>%
        as_tibble()
    return(res)
}
