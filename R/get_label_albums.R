#' Get albums by label
#'
#' @param label String of label name to search for
#' @param album_types Character vector of album types to include. Valid values are "album", "single", "appears_on", and "compilation". Defaults to "album".
#' @param offset Integer indicating the offset of the first album to return. Defaults to 0 (Spotify's API default value).
#' @param limit Integer indicating the max number of album to return. Defaults to 20 (Spotify's API default value), max of 50.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#'
#' @return
#' Returns a data frame of results containing album data for the given label.
#' @export
#'
#' @examples
#' brainfeeder_albums <- get_label_albums("brainfeeder")

get_label_albums <- function(label = character(), album_types = 'album', offset = 0, limit = 20, access_token = get_spotify_access_token()) {

        url <- 'https://api.spotify.com/v1/search'

        content <- RETRY('GET', url,
                         query = list(q = str_glue('label:"{label}"'),
                                      type = album_types,
                                      offset = offset,
                                      limit = limit,
                                      access_token = access_token),
                         encode = "json") %>% content()

        map_df(1:length(content$albums$items),
                      ~ tibble(
                          artist_name = content$albums$items[[.x]]$artists[[1]]$name,
                          album_name = content$albums$items[[.x]]$name,
                          album_type = content$albums$items[[.x]]$type,
                          label = label,
                          release_date = content$albums$items[[.x]]$release_date,
                          artist_uri = str_replace(content$albums$items[[.x]]$artists[[1]]$uri, "spotify:artist:", ''),
                          album_uri = str_replace(content$albums$items[[.x]]$uri, "spotify:album:", ''))
        )

}
