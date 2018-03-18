#' Get track uri:s from a string search on Spotify
#'
#' This function returns a data frame with two lists of track name and track uri
#' returned from Spotfiys search function
#' @param artist_name A string with artist name
#' @param track_name A string with track name
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track uri string search
#' @export
#' @examples
#' \dontrun{
#' ##### Get track uri for Radiohead - Kid A
#' kid_a <- get_track(artist_name = "Radiohead", track_name = "Kid A")
#' }

get_track <- function(artist_name, track_name, access_token = get_spotify_access_token()) {
    string_search <- paste(artist, track)
    # Search Spotify API for track name
    res <- GET('https://api.spotify.com/v1/search',
               query = list(q = string_search,
                            type = 'track', access_token = access_token)) %>%
        content

    if(length(res$tracks$items) == 0){
        return(data.frame(track_name = c(NA), track_uri = c(NA)))
    } else {
        res <- res %>% .$tracks %>% .$items
        # Clean response and combine all returned tracks into a dataframe
        tracks <- map(seq_len(length(res)), function(x) {
            list(
                track_name = res[[x]]$name,
                track_uri = gsub('spotify:track:', '', res[[x]]$uri) # remove meta info from the uri string
            )
        })

    }
    return(tibble(track_name = list(lapply(tracks, `[[`, 1)),
                  track_uri = list(lapply(tracks, `[[`, 2))))
}
