#' Get tracks from one or more albums on Spotify
#'
#' This function returns tracks from a dataframe of albums on Spotify
#' @param albums Dataframe containing a column `album_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_artist_albums()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @keywords album tracks
#' @export
#' @examples
#' \dontrun{
#' albums <- get_artist_albums('radiohead')
#' get_album_tracks(albums)
#' }

get_album_tracks <- function(albums, access_token = get_spotify_access_token(), parallelize = TRUE, future_plan = 'multiprocess') {

    map_args <- list(
        1:nrow(albums),
        function(this_album) {

            url <- paste0('https://api.spotify.com/v1/albums/', albums$album_uri[this_album], '/tracks')

            track_check <- RETRY('GET', url, query = list(limit = 50, access_token = access_token), quiet = TRUE, times = 10) %>% content

            if (!is.null(track_check$error)) {
                stop(paste0(track_check$error$message, ' (', track_check$error$status, ')'))
            }

            track_count <- track_check$total
            num_loops <- ceiling(track_count / 50)
            offset <- 0

            map_df(1:num_loops, function(this_loop) {
                res <- RETRY('GET', url, query = list(limit = 50, access_token = access_token), offset = offset, quiet = TRUE, times = 10) %>% content

                content <- res$items

                if (length(content) == 0) {
                    track_info <- tibble()
                } else {
                    track_info <- map_df(1:length(content), function(this_row) {

                        this_track <- content[[this_row]]

                        if (!is.null(this_track$id)) {
                            list(
                                album_name = albums$album_name[this_album],
                                track_name = this_track$name,
                                track_uri = this_track$id
                            )
                        }
                    })
                }
                offset <<- offset + 50
                track_info
            })
        }
    )

    if (parallelize) {
        og_plan <- plan()
        on.exit(plan(og_plan), add = TRUE)
        plan(future_plan)
        map_function <- 'future_map_dfr'
    } else {
        map_function <- 'map_df'
    }

    do.call(map_function, map_args)
}
