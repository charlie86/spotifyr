#' Get Spotify Access Token
#'
#' This function creates a Spotify access token.
#'
#' @param client_id Defaults to System Environment variable "SPOTIFY_CLIENT_ID"
#' @param client_secret Defaults to System Environment variable "SPOTIFY_CLIENT_SECRET"
#' @family authentication functions
#' @export
#' @return The Spotify Access Token of the current user or a meaningful error message.
#' @examples
#' \dontrun{
#' token <- get_spotify_access_token()
#' }

get_spotify_access_token <- function(client_id = Sys.getenv('SPOTIFY_CLIENT_ID'),
                                     client_secret = Sys.getenv('SPOTIFY_CLIENT_SECRET')
                                     ) {

    post <- RETRY('POST', 'https://accounts.spotify.com/api/token',
                 accept_json(),
                 authenticate(client_id, client_secret),
                 body = list(grant_type = 'client_credentials'),
                 encode = 'form', httr::config(http_version = 2)) %>%
        content

    if (!is.null(post$error)) {
        stop(str_glue('Could not authenticate with given Spotify credentials:\n\t{post$error_description}'))
    }

    access_token <- post$access_token

    access_token
}

#' Get Spotify Authorization Code
#'
#' This function creates a Spotify authorization code.
#' See \code{httr::\link[httr]{oauth2.0_token}}.
#'
#' @param client_id Defaults to System Environment variable "SPOTIFY_CLIENT_ID"
#' @param client_secret Defaults to System Environment variable "SPOTIFY_CLIENT_SECRET"
#' @param scope Space delimited string of spotify scopes,
#' found here: https://developer.spotify.com/documentation/general/guides/scopes/.
#' All scopes are selected by default
#' @export
#' @return The Spotify Web API Token2.0 reference class object (see
#'  \code{httr::\link[httr]{oauth2.0_token}}), or an error message.
#' @family authentication functions
#' @importFrom httr oauth2.0_token oauth_endpoint
#' @importFrom purrr safely
#' @examples
#' \dontrun{
#' authorization <- get_spotify_authorization_code()
#' }

get_spotify_authorization_code <- function(
        client_id = Sys.getenv("SPOTIFY_CLIENT_ID"),
        client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"),
        scope = scopes()
        ) {

    endpoint <- oauth_endpoint(authorize = 'https://accounts.spotify.com/authorize',
                               access = 'https://accounts.spotify.com/api/token')

    app <- oauth_app('spotifyr', client_id, client_secret)

    token <- purrr::safely(.f=oauth2.0_token)(
        endpoint = endpoint,
        app = app,
        scope = scope)

    if (!is.null(token$error)) {
        token$error
    } else {
      token$result
    }
}
