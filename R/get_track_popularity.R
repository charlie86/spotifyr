#' Get popularity of one or more tracks on Spotify
#'
#' This function returns the popularity of tracks on Spotify
#' @param tracks Dataframe containing a column `track_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_album_tracks or spotifyr::get_playlist_tracks()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features
#' @export
#' @examples
#' artists <- get_artists('radiohead')
#' albums <- get_albums(artists$artist_uri[1])
#' tracks <- get_album_tracks(albums)
#' track_popularity <- get_track_popularity(tracks)


get_track_popularity <- function(tracks, access_token = get_spotify_access_token()) {
  map_df(1:ceiling(nrow(tracks %>% filter(!duplicated(track_uri))) / 50), function(x) {
    uris <- tracks %>%
      filter(!duplicated(track_uri)) %>%
      slice(((x * 50) - 49):(x*50)) %>%
      select(track_uri) %>%
      .[[1]] %>%
      paste0(collapse = ',')
    
    res <- GET(paste0('https://api.spotify.com/v1/tracks/?ids=', uris),
               query = list(access_token = access_token)) %>% content %>% .$tracks
    
    df <- map_df(1:length(res), function(y) {
      list(
        track_uri = res[[y]]$id,
        track_popularity = res[[y]]$popularity
      )
    })
    
    return(df)
  })
}
