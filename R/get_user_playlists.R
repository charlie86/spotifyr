#' Get user playlists
#'
#' This function returns a dataframe of playlists for a given Spotify username
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{FALSE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' get_user_playlists('barackobama')
#' }

get_user_playlists <- function(username, access_token = get_spotify_access_token(), parallelize = FALSE, future_plan = 'multiprocess') {

    playlist_count <- get_user_playlist_count(username)

    if (playlist_count == 0) {
        stop('Can\'t find any playlists for this user on Spotify.')
    }

    num_loops <- ceiling(playlist_count / 50)
    offset <- 0

    map_args <- list(
        1:ceiling(num_loops),
        function(x) {
            endpoint <- str_glue('https://api.spotify.com/v1/users/{username}/playlists')
            res <- RETRY('GET', url = endpoint, query = list(access_token = access_token, offset = offset, limit = 50), quiet = TRUE) %>% content

            if (!is.null(res$error)) {
                stop(str_glue('{res$error$message} ({res$error$status})'))
            }

            content <- res$items

            total <- content$total
            offset <<- offset + 50

            return(content)
        }
    )

    if (parallelize) {
        og_plan <- plan()
        on.exit(plan(og_plan), add = TRUE)
        plan(future_plan)
        map_function <- 'future_map'
        map_args <- c(map_args, .progress = TRUE)
    } else {
        map_function <- 'map'
    }

    playlist_list <- do.call(map_function, map_args)

    map_df(1:length(playlist_list), function(this_playlist) {

        tmp <- playlist_list[[this_playlist]]
        map_df(1:length(tmp), function(this_row) {

            tmp2 <- tmp[[this_row]]

            if (!is.null(tmp2)) {
                name <- ifelse(is.null(tmp2$name), NA, tmp2$name)
                uri <- ifelse(is.null(tmp2$id), NA, tmp2$id)
                snapshot_id <- ifelse(is.null(tmp2$snapshot_id), NA, tmp2$snapshot_id)

                if (length(tmp2$images) > 0) {
                    img <- tmp2$images[[1]]$url
                } else {
                    img <- NA
                }

                list(
                    playlist_name = name,
                    playlist_uri = uri,
                    playlist_tracks_url = tmp2$tracks$href,
                    playlist_num_tracks = tmp2$tracks$total,
                    snapshot_id = snapshot_id,
                    playlist_img = img
                )
            } else {
                return(tibble())
            }
        })
    }) %>% dplyr::filter(!is.na(playlist_uri), !is.na(playlist_name))
}
