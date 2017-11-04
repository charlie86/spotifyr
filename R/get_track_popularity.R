#' Get popularity of one or more tracks on Spotify
#'
#' This function returns the popularity of tracks on Spotify
#' @param tracks Dataframe containing a column `track_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_album_tracks or spotifyr::get_playlist_tracks()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features
#' @export
#' @examples
#' artists <- get_artists('radiohead')
#' albums <- get_albums(artists$artist_uri[1])
#' tracks <- get_album_tracks(albums)
#' track_popularity <- get_track_popularity(tracks)


get_track_popularity <- function(tracks, access_token = get_spotify_access_token()) {

    num_loops <- ceiling(nrow(tracks %>% filter(!duplicated(track_uri))) / 50)

    map_df(1:num_loops, function(this_loop) {
        uris <- tracks %>%
            filter(!duplicated(track_uri)) %>%
            slice(((this_loop * 50) - 49):(this_loop * 50)) %>%
            select(track_uri) %>% .[[1]] %>% paste0(collapse = ',')

        res <- GET(paste0('https://api.spotify.com/v1/tracks/?ids=', uris),
                   query = list(access_token = access_token)) %>% content

        if (!is.null(res$error)) {
            stop(paste0(res$error$message, ' (', res$error$status, ')'))
        }

        content <- res$tracks

        df <- map_df(1:length(content), function(this_row) {

            this_track <- content[[this_row]]

            list(
                track_uri = this_track$id,
                track_popularity = this_track$popularity
            )
        })

        return(df)
    })
}
