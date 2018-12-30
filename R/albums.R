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
#' met_meta <- get_albums(albums = met_albums$album_uri)

get_albums <- function(albums = character(), access_token = get_spotify_access_token()) {

    stopifnot(length(albums) > 0)

    url <- 'https://api.spotify.com/v1/albums'

    num_loops <- ceiling(length(albums)/20)

    map_df(1:num_loops, function(this_loop) {

        index_start <- 1 + (20 * (this_loop - 1))
        index_end <- min(length(albums), 20 + (20 * (this_loop - 1)))

        content <- RETRY('GET', url,
                         query = list(ids = paste0(albums[index_start:index_end], collapse = ","),
                                      access_token = access_token),
                         encode = "json") %>% content()

        map_df(1:length(content$albums),
               ~ tibble(name = content$albums[[.x]][['name']],
                        album_type = content$albums[[.x]][["album_type"]],
                        href = content$albums[[.x]][['href']],
                        id = content$albums[[.x]][['id']],
                        external_ids = unlist(content$albums[[.x]][['external_ids']]),
                        external_urls = unlist(content$albums[[.x]][['external_urls']]),
                        image_urls = list(map(content$albums[[.x]][['images']], 'url')),
                        label = content$albums[[.x]][['label']],
                        popularity = content$albums[[.x]][['popularity']],
                        release_date = content$albums[[.x]][['release_date']],
                        release_date_precision = content$albums[[.x]][['release_date_precision']],
                        total_tracks = content$albums[[.x]][['total_tracks']],
                        type = content$albums[[.x]][['type']],
                        uri = content$albums[[.x]][['uri']],
                        copyright_text = unlist(map(content$albums[[.x]][["copyrights"]], "text")),
                        available_markets = list(content$albums[[.x]][['available_markets']]),
                        copyright_type = unlist(map(content$albums[[.x]][["copyrights"]], "type")),
                        genres = list(unlist(ifelse(length(content$albums[[.x]][["genres"]]) == 0, "", content$albums[[.x]][["genres"]])))),
               tracks = list(content$albums[[.x]][["tracks"]][["items"]])) %>%
            mutate(copyright_type = paste0("copyright_type_", copyright_type)) %>%
            spread(key = copyright_type, value = copyright_text)
    })
}

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

#' Get tracks from one or more albums on Spotify
#'
#' This function returns tracks from a dataframe of albums on Spotify
#' @param albums A character vector containing the ids of one or several albums to retrieve information for OR a dataframe containing a column `album_uri`, corresponding to Spotify Album URIs (Can be output from spotifyr::get_artist_albums())
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{FALSE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @keywords album tracks
#' @export
#' @examples
#' \dontrun{
#' albums <- get_artist_albums('radiohead')
#' get_album_tracks(albums)
#' }

get_album_tracks <- function(albums, access_token = get_spotify_access_token(), parallelize = FALSE, future_plan = 'multiprocess') {

    if (is.data.frame(albums)) {
        album_uris <- albums$album_uri
    } else {
        album_uris <- albums
    }

    album_info <- get_albums(album_uris)

    map_args <- list(
        1:length(album_uris),
        function(this_album) {

            url <- str_glue('https://api.spotify.com/v1/albums/{album_uris[this_album]}/tracks')

            track_check <- RETRY('GET', url, query = list(limit = 50, access_token = access_token), quiet = TRUE, times = 10) %>% content

            if (!is.null(track_check$error)) {
                stop(str_glue('{track_check$error$message} ({track_check$error$status})'))
            }

            track_count <- track_check$total
            num_loops <- ceiling(track_count / 50)
            offset <- 0

            map_df(1:num_loops, function(this_loop) {

                res <- RETRY('GET', url, query = list(limit = 50, access_token = access_token), offset = offset, quiet = TRUE, times = 10) %>% content

                content <- res$items

                if (length(content) == 0) {
                    track_info <- tibble()
                } else {
                    track_info <- map_df(1:length(content), function(this_row) {

                        this_track <- content[[this_row]]

                        if (!is.null(this_track$id)) {
                            list(
                                album_name = album_info$name[album_info$id == album_uris[this_album]],
                                album_uri = album_info$id[album_info$id == album_uris[this_album]],
                                track_name = this_track$name,
                                track_uri = this_track$id,
                                track_number = this_track$track_number,
                                disc_number = this_track$disc_number
                            )
                        }
                    })
                }
                offset <<- offset + 50
                track_info
            })
        }
    )

    if (parallelize) {
        og_plan <- plan()
        on.exit(plan(og_plan), add = TRUE)
        plan(future_plan)
        map_function <- 'future_map_dfr'
        map_args <- c(map_args, .progress = TRUE)
    } else {
        map_function <- 'map_df'
    }

    do.call(map_function, map_args)
}

#' Get Album Popularity
#'
#' This function returns popularity of albums on Spotify
#' @param albums Dataframe containing a column `album_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_artist_albums()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords albums
#' @export
#' @examples
#' \dontrun{
#' albums <- get_artist_albums('radiohead')
#' get_album_popularity(albums)
#' }

get_album_popularity <- function(albums, access_token = get_spotify_access_token()) {

    num_loops <- ceiling(sum(!duplicated(albums$album_uri)) / 20)

    map_df(1:num_loops, function(this_loop) {

        uris <- albums %>%
            dplyr::filter(!duplicated(album_uri)) %>%
            slice(((this_loop * 20) - 19):(this_loop * 20)) %>%
            pull(album_uri) %>%
            paste0(collapse = ',')

        url <- str_glue('https://api.spotify.com/v1/albums/?ids={uris}')

        res <- RETRY('GET', url, query = list(access_token = access_token), quiet = TRUE) %>% content

        content <- res$albums

        map_df(1:length(content), function(this_row) {

            this_album <- content[[this_row]]

            list(
                album_uri = this_album$id,
                album_popularity = this_album$popularity
            )
        })

    })
}
