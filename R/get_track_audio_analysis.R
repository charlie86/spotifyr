#' Get track audio analysis by URI
#'
#' This function takes a track URI and returns a list containing an audio analysis object
#' from Spotify's audio analysis endpoint
#' @param track_uri A string with a track URI
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track uri string search
#' @export
#' @examples
#' \dontrun{
#' ##### Get track uri for Radiohead - Kid A
#' kid_a <- get_tracks(artist_name = "Radiohead", track_name = "Kid A", return_closest_track = TRUE)
#' kid_a_audio_analysis <- get_track_audio_analysis(kid_a$track_uri)
#' }

get_track_audio_analysis <- function(track_uri, access_token = get_spotify_access_token()) {

    is_uri <- function(x) {
        nchar(x) == 22 &
            !str_detect(x, ' ') &
            str_detect(x, '[[:digit:]]') &
            str_detect(x, '[[:lower:]]') &
            str_detect(x, '[[:upper:]]')
    }

    track_uri <- gsub('spotify:track:', '', track_uri)

    if (!is_uri(track_uri)) {
        stop('Error: Must enter a valid uri')
    }

    GET(str_glue('https://api.spotify.com/v1/audio-analysis/{track_uri}'), query = list(
        access_token = get_spotify_access_token()
    )) %>% content
}
