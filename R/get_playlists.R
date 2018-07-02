#' Get playlists
#'
#' This function returns a dataframe of playlists for a given Spotify username and a character vector of playlist uris
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param playlist_uris Character vector of Spotify playlist uris associated with the given \code{username}. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' my_playlist_audio_features <- get_playlist_audio_features('spotify', playlist_uris)
#' }

get_playlists <- function(username, playlist_uris, access_token = get_spotify_access_token()) {

    num_loops <- length(playlist_uris)

    map_df(playlist_uris, function(this_playlist) {
        url <- str_glue('https://api.spotify.com/v1/users/{username}/playlists/', this_playlist)

        content <- RETRY('GET', url, query = list(access_token = access_token), quiet = TRUE) %>% content

        playlist_list <- content %>%
            list %>%
            list

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
    })

}
