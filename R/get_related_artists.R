#' Get Related Artists
#'
#' This function searches Spotify's library for artists by name or Spotify URI and returns related artists using Spotify's "Related Artists" API endpoint.
#' @param artist String of artist name or Spotify artist URI
#' @param return_closest_artist Boolean for selecting the artist result with the closest match on Spotify's Search endpoint. Defaults to \code{TRUE}.
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @keywords artists related
#' @export
#' @examples
#' \dontrun{
#' get_related_artists('radiohead')
#'
#' purrr::map_df(vector_of_artist_uris, function(this_artist_uri) {
#'     get_related_artists(artist = this_artist_uri)
#' })
#' }

get_related_artists <- function(artist = NULL, return_closest_artist = TRUE, access_token = get_spotify_access_token()) {

    is_uri <- function(x) {
        nchar(x) == 22 &
            !str_detect(x, ' ') &
            str_detect(x, '[[:digit:]]') &
            str_detect(x, '[[:lower:]]') &
            str_detect(x, '[[:upper:]]')
    }

    if (is.null(artist)) {
        stop('You must enter an artist name or URI.')
    }


    if (is_uri(artist)) {
        artist_uri <- artist
    } else {

        artists <- get_artists(artist, access_token = access_token)

        if (nrow(artists) > 0) {
            if (return_closest_artist == TRUE) {

                exact_matches <- artists$artist_name[tolower(artists$artist_name) == tolower(artist)]

                if (length(exact_matches) > 0) {
                    selected_artist <- exact_matches[1]
                } else {
                    selected_artist <- artists$artist_name[1]
                }

            } else {
                cat(paste0('We found the following artists on Spotify matching "', artist, '":\n\n\t', paste(artists$artist_name, collapse = "\n\t"), '\n\nPlease type the name of the artist you would like:'), sep  = '')
                selected_artist <- readline()
            }

            artist_uri <- artists$artist_uri[artists$artist_name == selected_artist]
        } else {
            stop(paste0('Cannot find any artists on Spotify matching "', artist, '"'))
        }
    }

    res <- RETRY('GET', url = paste0('https://api.spotify.com/v1/artists/', artist_uri, '/related-artists'), query = list(access_token = access_token), quiet = TRUE) %>% content

    content <- res$artists

    related_artists <- purrr::map_df(1:length(content), function(this_artist) {
        this_artist_info <- content[[this_artist]]
        list(
            artist_name = this_artist_info$name,
            artist_uri = this_artist_info$id,
            popularity = this_artist_info$popularity,
            num_followers = this_artist_info$followers$total
        )
    })

    return(related_artists)
}
