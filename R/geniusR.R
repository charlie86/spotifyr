#' Create Genius url
#'
#' Generates the url for a song given an artist and a song title. This function is used internally within the `genius_lyrics()` function.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param song The quoted name of the song. Spelling matters, capitalization does not.
#'
#' @examples
#' gen_song_url(artist = "Kendrick Lamar", song = "HUMBLE")
#' gen_song_url("Margaret glaspy", "Memory Street")
#'
#' @export
#' @importFrom stringr str_replace_all
#' @import dplyr
#'
gen_song_url <- function(artist = NULL, song = NULL) {
    artist <- prep_info(artist)
    song <- prep_info(song)
    base_url <- "https://genius.com/"
    query <- paste(artist, song, "lyrics", sep = "-") %>%
        str_replace_all(" ", "-")
    url <- paste0(base_url, query)
    return(url)
}


#' Create Genius Album url
#'
#' Creates a string containing the url to an album tracklist on Genius.com. The function is used internally to `genius_tracklist()`.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param album The quoted name of the album Spelling matters, capitalization does not.
#'
#' @examples
#'
#' gen_album_url(artist = "Pinegrove", album = "Cardinal")
#'
#' @export
#' @import dplyr
#' @importFrom stringr str_replace_all

gen_album_url <- function(artist = NULL, album = NULL) {
    artist <- prep_info(artist)
    album <-  prep_info(album)
    base_url <- "https://genius.com/albums/"
    query <- paste(artist,"/", album, sep = "") %>%
        str_replace_all(" ", "-")

    url <- paste0(base_url, query)
    return(url)
}

#' Retrieve song lyrics for an album
#'
#' Obtain the lyrics to an album in a tidy format.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param album The quoted name of the album Spelling matters, capitalization does not.
#' @param info Return extra information about each song. Default `"simple"` returns `title`, `track_n`, and `text`. Set `info = "artist"` for artist and track title. See args to `genius_lyrics()`.
#'
#' @examples
#'
#' genius_album(artist = "Petal", album = "Comfort EP")
#' genius_album(artist = "Fit For A King", album = "Deathgrip")
#'
#' @export
#' @import dplyr
#' @importFrom purrr map
#' @importFrom stringr str_replace_all
#' @importFrom tidyr unnest

genius_album <- function(artist = NULL, album = NULL, info = "simple") {

    # Obtain tracklist from genius_tracklist
    tracks <-  genius_tracklist(artist, album)

    album <- tracks %>%

        # Iterate over the url to the song title
        mutate(lyrics = map(track_url, genius_url, info)) %>%

        # Unnest the tibble with lyrics
        unnest(lyrics) %>%
        right_join(tracks, by = c('track_title', 'track_n', 'track_url')) %>%
        select(-track_url)

    return(album)
}

#' Retrieve song lyrics from Genius.com
#'
#' Retrieve the lyrics of a song with supplied artist and song name.
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param song The quoted name of the song. Spelling matters, capitalization does not.
#'@param info Default `"title"`, returns the track title. Set to `"simple"` for only lyrics, `"artist"` for the lyrics and artist, or `"all"` to return the lyrics, artist, and title.
#'
#'
#' @examples
#' genius_lyrics(artist = "Margaret Glaspy", song = "Memory Street")
#' genius_lyrics(artist = "Kendrick Lamar", song = "Money Trees")
#' genius_lyrics("JMSN", "Drinkin'")
#'
#' @export
#' @import dplyr

genius_lyrics <- function(artist = NULL, song = NULL, info = "title") {
    song_url <- gen_song_url(artist, song)
    lyrics <- genius_url(song_url, info)
    return(lyrics)
}


#' Create a tracklist of an album
#'
#' Creates a `tibble` containing all track titles for a given artist and album. This function is used internally in `genius_album()`.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param album The quoted name of the album Spelling matters, capitalization does not.
#'
#' @examples
#'
#' genius_tracklist(artist = "Andrew Bird", album = "Noble Beast")
#'
#' @export
#' @import dplyr
#' @importFrom rvest html_session html_nodes html_text html_attr
#' @importFrom stringr str_replace_all str_trim

genius_tracklist <- function(artist = NULL, album = NULL) {
    url <- gen_album_url(artist, album)
    session <- html_session(url)

    # Get track numbers
    # Where there are no track numbers, it isn't a song
    track_numbers <- html_nodes(session, ".chart_row-number_container-number") %>%
        html_text() %>%
        str_replace_all("\n", "") %>%
        str_trim()

    # Get all titles
    # Where there is a title and a track number, it isn't an actual song
    track_titles <- html_nodes(session, ".chart_row-content-title") %>%
        html_text() %>%
        str_replace_all("\n","") %>%
        str_replace_all("Lyrics", "") %>%
        str_trim()

    # Get all song urls
    track_url <- html_nodes(session, ".u-display_block") %>%
        html_attr('href') %>%
        str_replace_all("\n", "") %>%
        str_trim()

    # Create df for easy filtering
    # Filter to find only the actual tracks, the ones without a track number were credits / booklet etc
    df <- tibble(
        track_title = track_titles,
        track_n = as.integer(track_numbers),
        track_url = track_url
    ) %>%
        filter(track_n > 0)

    return(df)
}


#' Use Genius url to retrieve lyrics
#'
#' This function is used inside of the `genius_lyrics()` function. Given a url to a song on Genius, this function returns a tibble where each row is one line. Pair this function with `gen_song_url()` for easier access to song lyrics.
#'
#' @param url The url of song lyrics on Genius
#' @param info Default `"title"`, returns the track title. Set to `"simple"` for only lyrics, `"artist"` for the lyrics and artist, or `"all"` to return the lyrics, artist, and title.
#'
#' @examples
#' url <- gen_song_url(artist = "Kendrick Lamar", song = "HUMBLE")
#' genius_url(url)
#'
#' genius_url("https://genius.com/Head-north-in-the-water-lyrics", info = "all")
#'
#' @export
#' @import dplyr
#' @importFrom rvest html_session html_node
#' @importFrom stringr str_detect
#' @importFrom readr read_lines

genius_url <- function(url, info = "title") {

    # Start a new session
    session <- html_session(url)

    # Clean the song lyrics
    lyrics <- gsub(pattern = "<.*?>",
                   replacement = "\n",
                   html_node(session, ".lyrics")) %>%
        read_lines() %>%
        na.omit()

    # Artist
    artist <- html_nodes(session, ".header_with_cover_art-primary_info-primary_artist") %>%
        html_text() %>%
        str_replace_all("\n", "") %>%
        str_trim()

    # Song title
    song_title <- html_nodes(session, ".header_with_cover_art-primary_info-title") %>%
        html_text() %>%
        str_replace_all("\n", "") %>%
        str_trim()

    # Convert to tibble
    lyrics <- tibble(artist = artist,
                     track_title = song_title,
                     lyric = lyrics)

    # Isolate only lines that contain content
    index <- which(str_detect(lyrics$lyric, "[[:alnum:]]") == TRUE)
    lyrics <- lyrics[index,]

    # Remove lines with things such as [Intro: person & so and so]
    lyrics <- lyrics[str_detect(lyrics$lyric, "\\[|\\]") == FALSE, ]
    lyrics <- lyrics %>% mutate(line = row_number())

    switch(info,
           simple = {return(select(lyrics, -artist, -track_title))},
           artist = {return(select(lyrics, -track_title))},
           title = {return(select(lyrics, -artist))},
           all = return(lyrics)
    )
}



#' Prepares input strings for `gen_song_url()`
#'
#' Applies a number of regular expressions to prepare the input to match Genius url format
#'
#' @param input Either artist, song, or album, function input.
#'
#'
#'
#' @export
#' @importFrom stringr str_replace_all str_trim
#' @import dplyr


prep_info <- function(input) {
    str_replace_all(input,
                    c("\\s*\\(Ft.[^\\)]+\\)" = "",
                      "&" = "and",
                      "\\$" = " ",
                      "[[:punct:]]" = " ",
                      "[[:blank:]]+" = " ")) %>%
        str_trim()
}
