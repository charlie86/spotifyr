#' Parse Spotify playlist list to a dataframe
#'
#' Helper function for spotifyr::get_user_playlists()
#' @param playlist_list List of Spotify playlists, in the format of output from spotifyr::get_user_playlists
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' username <- 'barackobama'
#' playlist_count <- get_user_playlist_count(username)
#' num_loops <- ceiling(playlist_count / 50)
#' offset <- 0
#'
#' pb <- txtProgressBar(min = 0, max = num_loops, style = 3)
#'
#' playlist_list <- map(1:ceiling(num_loops), function(this_loop) {
#'     endpoint <- paste0('https://api.spotify.com/v1/users/', username, '/playlists')
#'     res <- GET(endpoint, query = list(access_token = get_spotify_access_token(),
#'                                       offset = offset,
#'                                       limit = 50)) %>% content
#'
#'     if (!is.null(res$error)) {
#'         stop(paste0(res$error$message, ' (', res$error$status, ')'))
#'     }
#'
#'     content <- res$items
#'
#'     total <- content$total
#'     offset <<- offset + 50
#'     setTxtProgressBar(pb, this_loop)
#'     return(content)
#' })
#'
#' playlist_df <- parse_playlist_list_to_df(playlist_list)
#' }

parse_playlist_list_to_df <- function(playlist_list) {
    playlists_df <- map_df(1:length(playlist_list), function(this_playlist) {

        tmp <- playlist_list[[this_playlist]]
        map_df(1:length(tmp), function(this_row) {

            tmp2 <- tmp[[this_row]]

            if (!is.null(tmp2)) {
                name <- ifelse(is.null(tmp2$name), NA, tmp2$name)
                uri <- ifelse(is.null(tmp2$id), NA, tmp2$id)
                snapshot_id <- ifelse(is.null(tmp2$snapshot_id), NA, tmp2$snapshot_id)

                has_img <- ifelse(length(tmp2$images) > 0, TRUE, FALSE)
                if (has_img == TRUE) {
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
    }) %>% dplyr::filter(!is.na(playlist_uri))
    return(playlists_df)
}
