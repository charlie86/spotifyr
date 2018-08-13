#' Get album metadata
#'
#' @param albums A character vector containing the ids of one or several albums to retrieve information for
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#'
#' @return
#' Returns a data frame of results containing album data. See \url{https://developer.spotify.com/documentation/web-api/reference/albums/get-album/} for more information.
#' @export
#'
#' @examples
#'
#' met_albums <- get_artist_albums(artist = "Metallica")
#' met_meta <- get_album_meta(albums = met_albums$album_uri)

get_albums <- function(albums = character(), access_token = get_spotify_access_token()) {

    stopifnot(length(albums) >0)

    url <- 'https://api.spotify.com/v1/albums'

    content <- RETRY('GET', url,
                     query = list(ids = paste0(albums, collapse = ","),
                                  access_token = access_token),
                     encode = "json") %>% content()

    res <- map_df(1:length(content$albums),
                  ~ tibble(name = content$albums[[.x]][['name']],
                           album_type = content$albums[[.x]][["album_type"]],
                           href = content$albums[[.x]][['href']],
                           id = content$albums[[.x]][['id']],
                           external_ids = unlist(content$albums[[.x]][['external_ids']]),
                           external_urls = unlist(content$albums[[.x]][['external_urls']]),
                           image_urls = paste0(map(content$albums[[.x]][['images']], 'url'), collapse = ","),
                           label = content$albums[[.x]][['label']],
                           popularity = content$albums[[.x]][['popularity']],
                           release_date = content$albums[[.x]][['release_date']],
                           release_date_precision = content$albums[[.x]][['release_date_precision']],
                           total_tracks = content$albums[[.x]][['total_tracks']],
                           type = content$albums[[.x]][['type']],
                           uri = content$albums[[.x]][['uri']],
                           copyright_text = unlist(map(content$albums[[.x]][["copyrights"]], "text")),
                           available_markets = paste0(content$albums[[.x]][['available_markets']], collapse = ","),
                           copyright_type = unlist(map(content$albums[[.x]][["copyrights"]], "type")),
                           genres = unlist(ifelse(length(content$albums[[.x]][["genres"]]) == 0, "", content$albums[[.x]][["genres"]]))),
                  tracks = list(content$albums[[.x]][["tracks"]][["items"]])) %>%
        mutate(copyright_type = paste0("copyright_type_", copyright_type)) %>%
        spread(key = copyright_type, value = copyright_text)

    return(res)
}

