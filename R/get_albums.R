#' Get Artist Albums
#'
#' This function returns an artist's discography on Spotify
#' @param artist_uri String identifier for an artist on Spotify. Can be found within the Spotify app or with spotifyr::get_artists()
#' @param studio_albums_only Logical for whether to remove album types "single" and "compilation" and albums with mulitple artists. Defaults to \code{TRUE}
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords albums
#' @export
#' @examples
#' \dontrun{
#' artists <- get_artists('radiohead')
#' albums <- get_artist_albums(artists$artist_uri[1])
#' }
get_albums <- function(artist_uri, studio_albums_only = TRUE, access_token = get_spotify_access_token()) {
    .Deprecated('get_artist_albums')
    get_artist_albums(artist_uri = artist_uri, studio_albums_only = studio_albums_only, access_token = access_token)
}
