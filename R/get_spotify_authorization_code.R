#' Get Spotify Authorization Code
#'
#' This function creates a Spotify access token.
#' @param client_id Defaults to System Envioronment variable "SPOTIFY_CLIENT_ID"
#' @param client_secret Defaults to System Envioronment variable "SPOTIFY_CLIENT_SECRET"
#' @param scope Space delimited string of spotify scopes, found here: https://developer.spotify.com/documentation/general/guides/scopes/. All scopes are selected by default
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_spotify_authorization_code()
#' }

get_spotify_authorization_code <- function(client_id = Sys.getenv("SPOTIFY_CLIENT_ID"), client_secret = Sys.getenv("SPOTIFY_CLIENT_SECRET"), scope = 'user-library-read user-library-modify playlist-read-private playlist-modify-public playlist-modify-private playlist-read-collaborative user-read-recently-played user-top-read user-read-private user-read-email user-read-birthdate streaming user-modify-playback-state user-read-currently-playing user-read-playback-state user-follow-modify user-follow-read') {
    endpoint <- oauth_endpoint(authorize = 'https://accounts.spotify.com/authorize', access = 'https://accounts.spotify.com/api/token')
    app <- oauth_app('spotifyr', client_id, client_secret)
    oauth2.0_token(endpoint = endpoint, app = app, scope = scope)
}
