#' Get Artists
#'
#' This function searches Spotify's library for artists by name
#' @param artist_name String of artist name
#' @param return_closest_artist Boolean for selecting the artist result with the closest match on Spotify's Search endpoint. Defaults to \code{TRUE}.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords artists
#' @export
#' @examples
#' \dontrun{
#' get_artists('radiohead')
#' }

get_artists <- function(artist_name, return_closest_artist = FALSE, access_token = get_spotify_access_token()) {

    # Search Spotify API for artist name
    res <- GET('https://api.spotify.com/v1/search', query = list(q = artist_name, type = 'artist', access_token = access_token)) %>%
        content

    if (!is.null(res$error)) {
        stop(paste0(res$error$message, ' (', res$error$status, ')'))
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
            artist_uri = gsub('spotify:artist:', '', this_artist$uri), # remove meta info from the uri string
            artist_img = ifelse(length(this_artist$images) > 0, this_artist$images[[1]]$url, NA) # we'll grab this just for fun
        )
    }) %>% dplyr::filter(!duplicated(tolower(artist_name)))

    return(artists)
}
