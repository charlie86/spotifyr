#' Retrieve artist discography with song lyrics and audio info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the associated audio information. Returns the song data as a nested tibble. This way we can easily see each album, artist, and song title before expanding our data.
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#'
#' @examples
#' \dontrun{
#' rex_orange <- get_discography("Rex Orange County")
#' tidyr::unnest(rex_orange, lyrics)
#' }
#' @export
#' @import dplyr
#' @importFrom tidyr nest unnest
#' @importFrom purrr possibly

get_discography <- function(artist, parallelize = TRUE, future_plan = 'multiprocess') {

    # Identify All Albums for a single artist
    artist_audio_features <- get_artist_audio_features(artist, parallelize = parallelize, future_plan = future_plan) %>%
        group_by(album_name) %>%
        mutate(track_n = row_number())

    # Identify each unique album name and artist pairing
    album_list <- artist_audio_features %>%
        distinct(album_name) %>%
        mutate(artist = artist)

    # Create possible_album for potential error handling
    possible_album <- possibly(genius_album, otherwise = as_tibble())

    if (parallelize) {
        og_plan <- plan()
        on.exit(plan(og_plan), add = TRUE)
        plan(future_plan)

        album_lyrics <- future_map2(album_list$artist, album_list$album_name, function(x, y) possible_album(x, y) %>% mutate(album_name = y), .progress = TRUE) %>%
            future_map_dfr(function(x) {if (nrow(x) > 0) nest(x, -c(track_title, track_n, album_name)) else tibble()}, .progress = TRUE)
    } else {
        album_lyrics <- map2(album_list$artist, album_list$album_name, function(x, y) possible_album(x, y) %>% mutate(album_name = y)) %>%
            map_df(function(x) {if (nrow(x) > 0) nest(x, -c(track_title, track_n, album_name)) else tibble()})
    }

    album_lyrics <- album_lyrics %>%
        rename(lyrics = data) %>%
        select(-track_title)

    # Acquire the lyrics for each track
    album_data <- artist_audio_features %>%
        left_join(album_lyrics, by = c('album_name', 'track_n'))

    return(album_data)
}



