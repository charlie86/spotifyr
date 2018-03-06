#' Get Related Artists
#'
#' This function searches Spotify's library for artists by name or Spotify URI and returns related artists using Spotify's "Related Artists" API endpoint.
#' @param artist_name String of artist name
#' @param artist_uri String of Spotify artist URI. Will only be applied if \code{use_arist_uri} is set to \code{TRUE}. This is useful for pulling related artists in bulk and allows for more accurate matching since Spotify URIs are unique.
#' @param use_artist_uri Boolean determining whether to search by Spotify URI instead of an artist name. If \code{TRUE}, you must also enter an \code{artist_uri}. Defaults to \code{FALSE}.
#' @param return_closest_artist Boolean for selecting the artist result with the closest match on Spotify's Search endpoint. Defaults to \code{TRUE}.
#' @param message Boolean for printing the name of artist matched when using \code{return_closest_artist = TRUE}. Defaults to \code{FALSE}.
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @keywords artists related
#' @export
#' @examples
#' \dontrun{
#' get_related_artists('radiohead')
#'
#' ## If you know the Spotify URI for the artist (or more likely, artists) you're looking for,
#' ## set use_artist_uri to TRUE and use artist_uri.
#' purrr::map_df(bunch_of_artist_uris, function(this_artist_uri) {
#'     get_related_artists(artist_uri = this_artist_uri, use_artist_uri = TRUE)
#' })
#' }

get_related_artists <- function(artist_name = NULL, artist_uri = NULL, use_artist_uri = FALSE, return_closest_artist = TRUE, message = FALSE, access_token = get_spotify_access_token()) {

    if (use_artist_uri == FALSE) {

        if (is.null(artist_name)) {
            stop('You must enter an artist name if use_artist_uri == FALSE.')
        }

        artists <- get_artists(artist_name, access_token = access_token)

        if (nrow(artists) > 0) {
            if (return_closest_artist == TRUE) {
                selected_artist <- artists$artist_name[1]
                if (message) {
                    message(paste0('Selecting artist "', selected_artist, '"', '. Choose return_closest_artist = FALSE to interactively choose from all the artist matches on Spotify.'))
                }
            } else {
                cat(paste0('We found the following artists on Spotify matching "', artist_name, '":\n\n\t', paste(artists$artist_name, collapse = "\n\t"), '\n\nPlease type the name of the artist you would like:'), sep  = '')
                selected_artist <- readline()
            }

            artist_uri <- artists$artist_uri[artists$artist_name == selected_artist]
        } else {
            stop(paste0('Cannot find any artists on Spotify matching "', artist_name, '"'))
        }
    } else {
        if (!is.null(artist_uri)) {
            artist_uri <- artist_uri
        } else {
            stop('You must enter an artist_uri if use_artist_uri == TRUE.')
        }
    }

    res <- GET(paste0('https://api.spotify.com/v1/artists/', artist_uri, '/related-artists'), query = list(access_token = access_token)) %>% content

    if (!is.null(res$error)) {
        stop(paste0(res$error$message, ' (', res$error$status, ')'))
    }

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
