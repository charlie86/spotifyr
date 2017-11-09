#' Get Album Popularity
#'
#' This function returns popularity of albums on Spotify
#' @param albums Dataframe containing a column `album_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_albums()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords albums
#' @export
#' @examples
#' \dontrun{
#' artists <- get_artists('radiohead')
#' albums <- get_albums(artists$artist_uri[1])
#' get_album_popularity(albums)
#' }

get_album_popularity <- function(albums, access_token = get_spotify_access_token()) {

    num_loops <- ceiling(sum(!duplicated(albums$album_uri)) / 20)

    map_df(1:num_loops, function(this_loop) {

        uris <- albums %>%
            filter(!duplicated(album_uri)) %>%
            slice(((this_loop * 20) - 19):(this_loop * 20)) %>%
            select(album_uri) %>%
            .[[1]] %>%
            paste0(collapse = ',')

        url <- paste0('https://api.spotify.com/v1/albums/?ids=', uris)

        res <- GET(url, query = list(access_token = access_token)) %>% content

        if (!is.null(res$error)) {
            stop(paste0(res$error$message, ' (', res$error$status, ')'))
        }

        content <- res$albums

        map_df(1:length(content), function(this_row) {

            this_album <- content[[this_row]]

            list(
                album_uri = this_album$id,
                album_popularity = this_album$popularity
            )
        })

    })
}
