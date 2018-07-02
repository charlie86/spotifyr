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
