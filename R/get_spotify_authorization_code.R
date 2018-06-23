#' Get Spotify Authorization Code
#'
#' This function creates a Spotify access token.
#' @param client_id Defaults to System Envioronment variable "SPOTIFY_CLIENT_ID"
#' @param client_secret Defaults to System Envioronment variable "SPOTIFY_CLIENT_SECRET"
#' @param scope Space delimited string of spotify scopes, found here: https://developer.spotify.com/documentation/general/guides/scopes/. No scopes are selected by default
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_spotify_authorization_code()
#' }

get_spotify_authorization_code <- function(client_id = Sys.getenv("SPOTIFY_CLIENT_ID"), client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"), scope = '') {
    endpoint <- oauth_endpoint(authorize = 'https://accounts.spotify.com/authorize', access = 'https://accounts.spotify.com/api/token')
    app <- oauth_app('spotifyr', client_id, client_secret)
    oauth2.0_token(endpoint = endpoint, app = app, scope = scope)
}
