#' Get audio features from one or more tracks on Spotify
#'
#' This function returns audio features from a dataframe of tracks on Spotify
#' @param tracks Dataframe containing a column `track_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_album_tracks or spotifyr::get_playlist_tracks()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features
#' @export
#' @examples
#' ##### Get tracks for all of Radiohead's albums
#' artists <- get_artists('radiohead')
#' albums <- get_albums(artists$artist_uri[1])
#' tracks <- get_album_tracks(albums)
#' radiohead_audio_features <- get_track_audio_features(tracks)
#' 
#' ##### Get tracks for all of Barack Obama's playlists
#' playlists <- get_user_playlists('barackobama')
#' tracks <- get_playlist_tracks(playlists)
#' obama_audio_features <- get_track_audio_features(tracks)

get_track_audio_features <- function(tracks, access_token = get_spotify_access_token()) {
  
  audio_features <- c('danceability', 'energy', 'key', 'loudness', 'mode', 'speechiness', 'acousticness', 
                      'instrumentalness', 'liveness', 'valence', 'tempo', 'duration_ms', 'time_signature')
  
  num_loops <- ceiling(sum(!duplicated(tracks$track_uri)) / 100)
  
  map_df(1:num_loops, function(x) {
    uris <- tracks %>%
      filter(!duplicated(track_uri)) %>%
      slice(((x*100) - 99):(x*100)) %>%
      select(track_uri) %>%
      .[[1]] %>%
      paste0(collapse = ',')
    
    res <- GET(paste0('https://api.spotify.com/v1/audio-features/?ids=', uris),
               query = list(access_token = access_token)) %>% content %>% .$audio_features
    
    df <- unlist(res) %>%
      matrix(nrow = length(res), byrow = T) %>%
      as.data.frame(stringsAsFactors = F)
    names(df) <- names(res[[1]])
    
    return(df)
    
  }) %>% select(-c(type, uri, track_href, analysis_url)) %>%
    rename(track_uri = id) %>% 
    mutate_at(audio_features, funs(as.numeric(gsub('[^0-9.-]+', '', as.character(.)))))
}