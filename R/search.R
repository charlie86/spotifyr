#' Get Artists
#'
#' This function searches Spotify's library for artists by name
#' @param artist_name String of artist name
#' @param return_closest_artist Boolean for selecting the artist result with the closest match on Spotify's Search endpoint. Defaults to \code{TRUE}.
#' @param offset Integer indicating the offset of the first artist to return. Defaults to 0 (Spotify's API default value).
#' @param limit Integer indicating the max number of artists to return. Defaults to 20 (Spotify's API default value), max of 50.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords artists
#' @export
#' @examples
#' \dontrun{
#' get_artists('radiohead')
#' }

get_artists <- function(artist_name, return_closest_artist = FALSE, offset = 0, limit = 20, access_token = get_spotify_access_token()) {

    # Search Spotify API for artist name
    res <- RETRY('GET', url = 'https://api.spotify.com/v1/search', query = list(q = artist_name, type = 'artist', offset = offset, limit = limit, access_token = access_token), quiet = TRUE) %>%
        content

    if (!is.null(res$error)) {
        stop(str_glue('{res$error$message} ({res$error$status})'))
    }

    content <- res$artists %>% .$items

    if (return_closest_artist == TRUE) {
        num_loops <- 1
    } else {
        num_loops <- length(content)
    }

    # Clean response and combine all returned artists into a dataframe
    artists <- map_df(seq_len(num_loops), function(this_row) {
        this_artist <- content[[this_row]]
        list(
            artist_name = this_artist$name,
            artist_uri = gsub('spotify:artist:', '', this_artist$uri),
            artist_img = ifelse(length(this_artist$images) > 0, this_artist$images[[1]]$url, NA),
            artist_genres = list(unlist(this_artist$genres)),
            artist_popularity = this_artist$popularity,
            artist_num_followers = this_artist$followers$total
        )
    }) %>% dplyr::filter(!duplicated(tolower(artist_name)))

    return(artists)
}

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

#' Get artists by genre
#'
#' @param genre String of genre name to search for
#' @param offset Integer indicating the offset of the first artist to return. Defaults to 0 (Spotify's API default value).
#' @param limit Integer indicating the max number of artists to return. Defaults to 20 (Spotify's API default value), max of 50.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#'
#' @return
#' Returns a data frame of results containing artist data for the given genre.
#' @export
#'
#' @examples
#' wonky_artists <- get_genre_artists("wonky")

get_genre_artists <- function(genre = character(), offset = 0, limit = 20, access_token = get_spotify_access_token()) {

    url <- 'https://api.spotify.com/v1/search'

    content <- RETRY('GET', url,
                     query = list(q = str_glue('genre:"{genre}"'),
                                  type = 'artist',
                                  limit = limit,
                                  offset = offset,
                                  access_token = access_token),
                     encode = "json") %>% content()

    map_df(1:length(content$artists$items),
           ~ tibble(
               artist_name = content$artists$items[[.x]]$name,
               genre = genre,
               genres = list(unlist(content$artists$items[[.x]]$genres)),
               popularity = content$artists$items[[.x]]$popularity,
               follower_count = content$artists$items[[.x]]$followers$total,
               artist_uri = str_replace(content$artists$items[[.x]]$uri, 'spotify:artist:', ''),
               image_urls = list(map(content$artists$items[[.x]][['images']], 'url'))
           ))

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

#' Get track uris from a string search on Spotify
#'
#' This function takes a string and returns a data frame with track information
#' from Spotify's search endpoint
#' @param track_name A string with track name
#' @param artist_name Optional. A string with artist name
#' @param album_name Optional. A string with album name
#' @param return_closest_track Optional. A string with album name
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track uri string search
#' @export
#' @examples
#' \dontrun{
#' ##### Get track uri for Radiohead - Kid A
#' kid_a <- get_tracks(artist_name = "Radiohead", track_name = "Kid A", return_closest_track = TRUE)
#' }

get_tracks <- function(track_name, artist_name = NULL, album_name = NULL, return_closest_track = FALSE, access_token = get_spotify_access_token()) {

    string_search <- track_name

    if (!is.null(artist_name)) {
        string_search <- paste(string_search, artist_name)
    }

    if (!is.null(album_name)) {
        string_search <- paste(string_search, album_name)
    }

    # Search Spotify API for track name
    res <- GET('https://api.spotify.com/v1/search',
               query = list(q = string_search,
                            type = 'track',
                            access_token = access_token)
    ) %>% content

    if (length(res$tracks$items) >= 0) {

        res <- res %>% .$tracks %>% .$items

        tracks <- map_df(seq_len(length(res)), function(x) {
            list(
                track_name = res[[x]]$name,
                track_uri = gsub('spotify:track:', '', res[[x]]$uri),
                artist_name = res[[x]]$artists[[1]]$name,
                artist_uri = res[[x]]$artists[[1]]$id,
                album_name = res[[x]]$album$name,
                album_id = res[[x]]$album$id
            )
        })

        if (return_closest_track == TRUE) {
            tracks <- slice(tracks, 1)
        }

    } else {
        tracks <- tibble()
    }

    return(tracks)
}
