#' Get user playlists
#'
#' This function returns a dataframe of playlists for a given Spotify username
#' @param artist_name String of Spotify username. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords username
#' @export
#' @examples
#' get_user_playlists('barackobama')

## helper functions
parse_playlist_list_to_df <- function(playlist_list) {
  playlists_df <- map_df(1:length(playlist_list), function(x) {
    tmp <- playlist_list[[x]]
    map_df(1:length(tmp), function(y) {
      tmp2 <- tmp[[y]]
      
      if (!is.null(tmp2)) {
        name <- ifelse(is.null(tmp2$name), NA, tmp2$name)
        uri <- ifelse(is.null(tmp2$id), NA, tmp2$id)
        
        list(
          playlist_name = name,
          playlist_uri = uri,
          playlist_tracks_url = tmp2$tracks$href,
          playlist_num_tracks = tmp2$tracks$total,
          snapshot_id = tmp2$snapshot_id,
          playlist_img = tmp2$images[[1]]$url
        )
      } else {
        return(tibble())
      }
    })
  }) %>% filter(!is.na(playlist_uri))
}

get_user_playlist_count <- function(username, access_token = get_spotify_access_token(), echo = F) {
  endpoint <- paste0('https://api.spotify.com/v1/users/', username, '/playlists')
  total <- GET(endpoint, query = list(access_token = access_token, limit = 1)) %>% content %>% .$total
  
  if (echo) {
    print(paste0('Found ', total, ' playlists from ', username))
  }
  
  return(total)
}


get_user_playlists <- function(username, access_token = get_spotify_access_token()) {
  
  playlist_count <- get_user_playlist_count(username)
  num_loops <- ceiling(playlist_count / 50)
  offset <- 0
  
  pb <- txtProgressBar(min = 0, max = num_loops, style = 3)
  
  playlists_list <- map(1:ceiling(num_loops), function(x) {
    endpoint <- paste0('https://api.spotify.com/v1/users/', username, '/playlists')
    res <- GET(endpoint, query = list(access_token = access_token, offset = offset, limit = 50)) %>% content %>% .$items
    offset <<- offset + 50
    setTxtProgressBar(pb, x)
    return(res)
  })
  
  playlists_df <- parse_playlist_list_to_df(playlists_list)
  
  return(playlists_df)
  
}
