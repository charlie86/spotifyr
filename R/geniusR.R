#' Retrieve Artist Discography with Song Lyrics and Audio Info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the
#' associated audio information. Returns the song data as a nested tibble.
#' This way we can easily see each album, artist, and song title before expanding our data.
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param authorization Authorization token for Spotify web API.
#' Defaults to \code{get_spotify_access_token()}#'
#' @examples
#' \donttest{
#' rex_orange <- get_discography("Rex Orange County")
#'
#' ## You can unnest it with
#' ## tidyr::unnest(rex_orange, data)
#'
#' }
#' @export
#' @importFrom dplyr mutate group_by filter distinct rename left_join ungroup
#' @importFrom tidyr nest unnest
#' @importFrom purrr possibly
#' @importFrom genius genius_album
#' @importFrom rlang .data
#' @return A nested tibble. See \code{tidyr::\link[tidyr]{nest}}.
#' @family album functions

get_discography <- function(artist,
                            authorization = get_spotify_access_token()
                            ) {

    # Identify All Albums for a single artist
    artist_audio_features <- get_artist_audio_features(
            artist,
            authorization = authorization) %>%
        group_by(.data$album_name) %>%
        mutate(track_n = row_number())

    # Identify each unique album name and artist pairing
    album_list <- artist_audio_features %>%
        distinct(.data$album_name) %>%
        mutate(artist = artist)

    # Create possible_album for potential error handling
    empty_album <- tibble (
        track_n  = NA_real_,
        line = NA_real_,
        lyric = NA_character_,
        track_title = NA_character_
    )
    possible_album <- possibly(genius_album, otherwise = empty_album )

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
        rename(lyrics = .data$data) %>%
        select(-all_of("track_title"))

    # Acquire the lyrics for each track
    album_data <- artist_audio_features %>%
        left_join(album_lyrics,
                  by = c('album_name', 'track_n'))

    return(album_data)
}
