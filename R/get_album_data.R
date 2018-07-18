#' Retrieve artist discography with song lyrics and audio info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the associated audio information. Returns the song data as a nested tibble. This way we can easily see each album, artist, and song title before expanding our data.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param albums A character vector of album names. Spelling matters, capitalization does not
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{FALSE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#'
#' @examples
#' get_album_data("Wild child", "Expectations")
#'
#' @export
#' @import dplyr
#' @importFrom tidyr nest unnest
#' @importFrom purrr possibly


get_album_data <- function(artist, albums = character(), parallelize = FALSE, future_plan = 'multiprocess', access_token = get_spotify_access_token()) {

    # Identify All Albums for a single artist
    artist_albums <- get_artist_albums(artist, parallelize = parallelize, future_plan = future_plan, access_token = access_token) %>% as_tibble()
    # Acquire all tracks for each album
    artist_disco <-  artist_albums %>%
        get_album_tracks(parallelize = parallelize, future_plan = future_plan, access_token = access_token) %>% as_tibble() %>%
        group_by(album_name) %>%
        # There might be song title issues, we will just order by track number to prevent problems
        # we will join on track number
        mutate(track_n = row_number()) %>%
        ungroup() %>%
        filter(tolower(album_name) %in% tolower(albums))


    # Get the audio features for each song
    disco_audio_feats <- get_track_audio_features(artist_disco, access_token = access_token) %>% as_tibble()

    # Identify each unique album name and artist pairing
    album_list <- artist_disco %>%
        distinct(album_name) %>%
        mutate(artist = artist)
    # Create possible_album for potential error handling
    possible_album <- possibly(genius_album, otherwise = as_tibble())

    album_lyrics <- map2(album_list$artist, album_list$album_name, function(x, y) possible_album(x, y) %>% mutate(album_name = y)) %>%
        map_df(function(x) nest(x, -c(track_title, track_n, album_name))) %>%
        rename(lyrics = data) %>%
        select(-track_title)

    # Acquire the lyrics for each track
    album_data <- artist_disco %>%
        left_join(disco_audio_feats, by = 'track_uri') %>%
        left_join(album_lyrics, by = c('album_name', 'track_n'))

    return(album_data)
}

