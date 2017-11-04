#' Get tracks from one or more playlists
#'
#' This function returns tracks from a dataframe of playlists on Spotify
#' @param playlists Dataframe containing the columns `playlist_num_tracks`, `playlist_tracks_url`, `playlist_name`, and `playlist_img`, corresponding to Spotify playlists. Can be output from spotifyr::get_user_playlists()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords album tracks
#' @export
#' @examples
#' playlists <- get_user_playlists('barackobama')
#' playlist_tracks <- get_playlist_tracks(playlists)


get_playlist_tracks <- function(playlists, access_token = get_spotify_access_token()) {

    pb <- txtProgressBar(min = 0, max = nrow(playlists), style = 3)

    playlist_tracks_df <- map_df(1:nrow(playlists), function(this_playlist) {

        num_loops <- ceiling(playlists$playlist_num_tracks[this_playlist] / 100)

        df <- map_df(1:num_loops, function(this_loop) {

            res <- GET(playlists$playlist_tracks_url[this_playlist], query = list(access_token = access_token, limit = 100, offset = (100 * this_loop) - 100)) %>% content

            if (!is.null(res$error)) {
                stop(paste0(res$error$message, ' (', res$error$status, ')'))
            }

            content <- res$items

            if (length(content) == 0) {
                track_info <- tibble()
            } else {
                track_info <- map_df(1:length(content), function(this_row) {

                    this_track <- content[[this_row]]

                    if (!is.null(this_track$track$id)) {
                        list(
                            playlist_name = playlists$playlist_name[this_playlist],
                            playlist_img = playlists$playlist_img[this_playlist],
                            track_name = this_track$track$name,
                            track_uri = this_track$track$id,
                            artist_name = this_track$track$artists[[1]]$name,
                            album_name = this_track$track$album$name,
                            album_img = ifelse(length(this_track$track$album$images) > 0, this_track$track$album$images[[1]]$url, '')
                        )
                    }
                })
            }
        })
        setTxtProgressBar(pb, this_playlist)
        return(df)
    })

    return(playlist_tracks_df)
}
