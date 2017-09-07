#' Get Artists
#'
#' This function searches Spotify's library for artists by name
#' @param artist_name String of artist name
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords artists
#' @export
#' @examples
#' get_artists('radiohead')

get_artists <- function(artist_name, access_token = get_spotify_access_token()) {
  
  # Search Spotify API for artist name
  res <- GET('https://api.spotify.com/v1/search', query = list(q = artist_name, type = 'artist', access_token = access_token)) %>%
    content %>% .$artists %>% .$items
  
  # Clean response and combine all returned artists into a dataframe
  artists <- map_df(seq_len(length(res)), function(x) {
    list(
      artist_name = res[[x]]$name,
      artist_uri = gsub('spotify:artist:', '', res[[x]]$uri), # remove meta info from the uri string
      artist_img = ifelse(length(res[[x]]$images) > 0, res[[x]]$images[[1]]$url, NA) # we'll grab this just for fun
    )
  }) %>% filter(!duplicated(tolower(artist_name)))
  
  return(artists)
}