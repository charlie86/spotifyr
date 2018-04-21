#' Retrieve artist discography with song lyrics and audio info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the associated audio information. Returns the song data as a nested tibble. This way we can easily see each album, artist, and song title before expanding our data.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param albums A character vector of album names. Spelling matters, capitalization does not
#'
#' @examples
#' get_album_data("Wild child", "Expectations")
#'
#' @export
#' @import dplyr
#' @import geniusR
#' @importFrom tidyr nest unnest
#' @importFrom purrr possibly



get_album_data <- function(artist, albums = character()) {

    # Identify All Albums for a single artist
    artist_albums <- get_artist_albums(artist) %>% as_tibble()
    # Acquire all tracks for each album
    artist_disco <-  artist_albums %>%
        get_album_tracks() %>% as_tibble() %>%
        group_by(album_name) %>%
        # There might be song title issues, we will just order by track number to prevent problems
        # we will join on track number
        mutate(track_n = row_number()) %>%
        ungroup() %>%
        filter(tolower(album_name) %in% tolower(albums))


    # Get the audio features for each song
    disco_audio_feats <- get_track_audio_features(artist_disco) %>% as_tibble()


    # Identify each unique album name and artist pairing
    album_list <- artist_disco %>%
        distinct(album_name) %>%
        mutate(artist = artist)
    # Create possible_album for potential error handling
    possible_album <- possibly(genius_album, otherwise = as_tibble())

    # Acquire the lyrics for each track
    album_lyrics <- album_list %>%
        mutate(tracks = map2(artist, album_name, possible_album)) %>%
        unnest(tracks) %>%
        left_join(artist_disco, by = c("album_name", "track_n")) %>%
        inner_join(disco_audio_feats) %>%
        nest(-artist, -album_name, -track_title)

    return(album_lyrics)
}

