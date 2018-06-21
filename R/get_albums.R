#' Get Artist Albums
#'
#' This function returns an artist's discography on Spotify
#' @param artist_uri String identifier for an artist on Spotify. Can be found within the Spotify app or with spotifyr::get_artists()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords albums
#' @export
#' @examples
#' \dontrun{
#' artists <- get_artists('radiohead')
#' albums <- get_artist_albums(artists$artist_uri[1])
#' }
get_albums <- function(artist_uri, access_token = get_spotify_access_token()) {
    .Deprecated('get_artist_albums')
    get_artist_albums(artist_uri = artist_uri, access_token = access_token)
}
