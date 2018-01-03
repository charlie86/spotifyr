#' Get Spotify Access Token
#'
#' This function creates a Spotify access token.
#' @param client_id Defaults to System Envioronment variable "SPOTIFY_CLIENT_ID"
#' @param client_secret Defaults to System Envioronment variable "SPOTIFY_CLIENT_SECRET"
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_spotify_access_token()
#' }

get_spotify_access_token <- function(client_id = Sys.getenv('SPOTIFY_CLIENT_ID'), client_secret = Sys.getenv('SPOTIFY_CLIENT_SECRET')) {

  post <- POST('https://accounts.spotify.com/api/token',
           accept_json(), authenticate(client_id, client_secret),
           body = list(grant_type = 'client_credentials'),
           encode = 'form', httr::config(http_version = 2)) %>% content

  if (!is.null(post$error)) {
    stop(paste0('Could not authenticate with given Spotify credentials:\n\t', post$error_description))
  }

  access_token <- post$access_token

  return(access_token)
}
