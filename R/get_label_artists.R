#' Get artists by label
#'
#' @param label String of label name to search for
#' @param offset Integer indicating the offset of the first artist to return. Defaults to 0 (Spotify's API default value).
#' @param limit Integer indicating the max number of artists to return. Defaults to 20 (Spotify's API default value), max of 50.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#'
#' @return
#' Returns a data frame of results containing artist data for the given label.
#' @export
#'
#' @examples
#' brainfeeder_artists <- get_label_artists("brainfeeder")

get_label_artists <- function(label = character(), offset = 0, limit = 20, access_token = get_spotify_access_token()) {

    url <- 'https://api.spotify.com/v1/search'

    content <- RETRY('GET', url,
                     query = list(q = str_glue('label:"{label}"'),
                                  type = 'artist',
                                  limit = limit,
                                  offset = offset,
                                  access_token = access_token),
                     encode = "json") %>% content()

    map_df(1:length(content$artists$items),
                  ~ tibble(
                      artist_name = content$artists$items[[.x]]$name,
                      label = label,
                      genres = list(unlist(content$artists$items[[.x]]$genres)),
                      popularity = content$artists$items[[.x]]$popularity,
                      follower_count = content$artists$items[[.x]]$followers$total,
                      artist_uri = str_replace(content$artists$items[[.x]]$uri, 'spotify:artist:', ''),
                      image_urls = list(map(content$artists$items[[.x]][['images']], 'url'))
                  ))

}
