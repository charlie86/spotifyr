#' Parse Spotify playlist list to a dataframe
#'
#' Helper function for spotifyr::get_user_playlists()
#' @param playlist_list List of Spotify playlists, in the format of output from spotifyr::get_user_playlists
#' @keywords username
#' @export
#' @examples
#'
#' playlist_count <- get_user_playlist_count(username)
#' num_loops <- ceiling(playlist_count / 50)
#' offset <- 0
#'
#' pb <- txtProgressBar(min = 0, max = num_loops, style = 3)
#'
#' playlists_list <- map(1:ceiling(num_loops), function(x) {
#'     endpoint <- paste0('https://api.spotify.com/v1/users/', username, '/playlists')
#'     res <- GET(endpoint, query = list(access_token = access_token, offset = offset, limit = 50)) %>% content
#'
#'     if (!is.null(res$error)) {
#'         stop(paste0(res$error$message, ' (', res$error$status, ')'))
#'     }
#'
#'     content <- res$items
#'
#'     total <- content$total
#'     offset <<- offset + 50
#'     setTxtProgressBar(pb, x)
#'     return(content)
#' })

parse_playlist_list_to_df <- function(playlist_list) {
    playlists_df <- map_df(1:length(playlist_list), function(this_playlist) {
        tmp <- playlist_list[[this_playlist]]
        map_df(1:length(tmp), function(this_row) {
            tmp2 <- tmp[[this_row]]

            if (!is.null(tmp2)) {
                name <- ifelse(is.null(tmp2$name), NA, tmp2$name)
                uri <- ifelse(is.null(tmp2$id), NA, tmp2$id)

                list(
                    playlist_name = name,
                    playlist_uri = uri,
                    playlist_tracks_url = tmp2$tracks$href,
                    playlist_num_tracks = tmp2$tracks$total,
                    snapshot_id = tmp2$snapshot_id,
                    playlist_img = tmp2$images[[1]]$url
                )
            } else {
                return(tibble())
            }
        })
    }) %>% filter(!is.na(playlist_uri))
}
