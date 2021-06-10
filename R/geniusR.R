#' Retrieve artist discography with song lyrics and audio info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the
#' associated audio information. Returns the song data as a nested tibble.
#' This way we can easily see each album, artist, and song title before expanding our data.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param albums A character vector of album names. Spelling matters, capitalization does not
#' @param authorization Authorization token for Spotify web API. Defaults to
#' \code{get_spotify_access_token()}
#' @examples
#' \donttest{
#' get_album_data(artist = "Wild child",
#'                albums = "Expectations")
#' }
#'
#' @export
#' @importFrom tidyr nest unnest
#' @importFrom genius genius_album
#' @importFrom purrr possibly map_df
#' @importFrom dplyr mutate select filter left_join ungroup rename
#' @importFrom tibble as_tibble


get_album_data <- function(artist,
                           albums = character(),
                           authorization = get_spotify_access_token()
                           ) {

    artist_disco <- get_artist_audio_features(
             artist,
             authorization = authorization
             ) %>%
        filter(tolower(.data$album_name) %in% tolower(albums)) %>%
        group_by(album_name) %>%
        mutate(track_n = row_number()) %>%
        ungroup()

    # Identify each unique album name and artist pairing
    album_list <- artist_disco %>%
        distinct(album_name) %>%
        mutate(artist = artist)
    # Create possible_album for potential error handling
    empty_album <- tibble (
        track_n  = NA_real_,
        line = NA_real_,
        lyric = NA_character_,
        track_title = NA_character_
    )
    possible_album <- possibly(genius::genius_album, otherwise = empty_album ) #as_tibble is not allowed
    #PA <- possible_album(album_list$artist[1], album_list$album_name[1])


    album_lyrics <- map2(album_list$artist, album_list$album_name, function(x, y) possible_album(x, y) %>% mutate(album_name = y)) %>%
        map_df(function(x) nest(x, -c(track_title, track_n, album_name))) %>%
        rename(lyrics = .data$data) %>%
        select(-all_of("track_title"))

    # Acquire the lyrics for each track
    album_data <- artist_disco %>%
        left_join(album_lyrics, by = c('album_name', 'track_n'))

    album_data
}

#' Retrieve artist discography with song lyrics and audio info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the associated audio information. Returns the song data as a nested tibble. This way we can easily see each album, artist, and song title before expanding our data.
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param authorization Authorization token for Spotify web API. Defaults to \code{get_spotify_access_token()}
#'
#' @examples
#' \donttest{
#' rex_orange <- get_discography("Rex Orange County")
#' unnest(rex_orange, data)
#' }
#' @export
#' @importFrom dplyr mutate group_by filter distinct rename left_join ungroup
#' @importFrom tidyr nest unnest
#' @importFrom purrr possibly

get_discography <- function(artist,
                            authorization = get_spotify_access_token()
                            ) {

    # Identify All Albums for a single artist
    artist_audio_features <- get_artist_audio_features(artist,
                                                       authorization = authorization) %>%
        group_by(album_name) %>%
        mutate(track_n = row_number())

    # Identify each unique album name and artist pairing
    album_list <- artist_audio_features %>%
        distinct(album_name) %>%
        mutate(artist = artist)

    # Create possible_album for potential error handling
    possible_album <- possibly(genius_album, otherwise = as_tibble())

    album_lyrics <- map2(album_list$artist,
                         album_list$album_name,
                         function(x, y) possible_album(x, y) %>%
                             mutate(album_name = y)) %>%
        map_df(function(x) {
            if (nrow(x) > 0) {
                nest(x, -c(track_title, track_n, album_name))
            } else {
                tibble()
            }
        }) %>%
        rename(lyrics = data) %>%
        select(-track_title)

    # Acquire the lyrics for each track
    album_data <- artist_audio_features %>%
        left_join(album_lyrics,
                  by = c('album_name', 'track_n'))

    return(album_data)
}
