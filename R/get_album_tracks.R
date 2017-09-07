#' Get tracks from one or more albums on Spotify
#'
#' This function returns tracks from a dataframe of albums on Spotify
#' @param albums Dataframe containing a column `album_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_albums()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords album tracks
#' @export
#' @examples
#' artists <- get_artists('radiohead')
#' albums <- get_albums(artists$artist_uri[1])
#' get_album_tracks(albums)

get_album_tracks <- function(albums, access_token = get_spotify_access_token()) {
  
  map_df(1:nrow(albums), function(x) {
    
    url <- paste0('https://api.spotify.com/v1/albums/', albums$album_uri[x], '/tracks')
    
    res <- GET(url, query = list(access_token = access_token)) %>% content %>% .$items
    
    if (length(res) == 0) {
      track_info <- tibble()
    } else {
      track_info <- map_df(1:length(res), function(z) {
        if (!is.null(res[[z]]$id)) {
          list(
            album_name = albums$album_name[x],
            track_name = res[[z]]$name,
            track_uri = res[[z]]$id
          )
        }
      })
    }
  })
}
