#' Get tracks from one or more playlists
#'
#' This function returns tracks from a dataframe of playlists on Spotify
#' @param playlists Dataframe containing the columns `playlist_num_tracks`, `playlist_tracks_url`, `playlist_name`, and `playlist_img`, corresponding to Spotify playlists. Can be output from spotifyr::get_user_playlists()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords album tracks
#' @export
#' @examples
#' playlists <- get_user_playlists('barackobama')
#' playlist_tracks <- get_playlist_tracks(playlists)


get_playlist_tracks <- function(playlists, access_token = get_spotify_access_token()) {
  
  pb <- txtProgressBar(min = 0, max = nrow(playlists), style = 3)
  
  playlist_tracks_df <- map_df(1:nrow(playlists), function(x) {
    
    num_loops <- ceiling(playlists$playlist_num_tracks[x] / 100)
    
    df <- map_df(1:num_loops, function(y) {
      
      res <- GET(playlists$playlist_tracks_url[x], query = list(access_token = access_token, limit = 100, offset = (100 * y) - 100)) %>% content %>% .$items
      
      if (length(res) == 0) {
        track_info <- tibble()
      } else {
        track_info <- map_df(1:length(res), function(z) {
          if (!is.null(res[[z]]$track$id)) {
            list(
              playlist_name = playlists$playlist_name[x],
              playlist_img = playlists$playlist_img[x],
              track_name = res[[z]]$track$name,
              track_uri = res[[z]]$track$id,
              artist_name = res[[z]]$track$artists[[1]]$name,
              album_name = res[[z]]$track$album$name,
              album_img = ifelse(length(res[[z]]$track$album$images) > 0, res[[z]]$track$album$images[[1]]$url, '')
            )
          }
        })
      }
    })
    setTxtProgressBar(pb, x)
    return(df)
  })
  
  return(playlist_tracks_df)
}