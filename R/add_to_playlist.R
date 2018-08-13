#' Add tracks to a playlist
#'
#' This function adds new tracks to a user's playlist.
#'
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param playlist_id The id of the playlist to add the tracks to. Can be obtained via either create_playlist() or get_playlists()
#' @param tracks A character vector of track uris
#' @param position (Optional) The position to insert the tracks, a zero-based index. If omitted, the tracks will be appended to the playlist
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#'
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' hello_fromr <- create_playlist(username = 'rstats', playlist_name =  'hello from spotifyr!')
#' my_top_tracks <- get_my_top_tracks(time_range = 'long_term')
#' my_added_tracks <- add_to_playlist(username = 'rstats', playlist_id = hello_fromr$id, tracks =  my_top_tracks$track_uri)
#' }

add_to_playlist <- function(username, playlist_id, tracks, position = NULL, auth_code = get_spotify_authorization_code()) {

    url <- str_glue('https://api.spotify.com/v1/users/{username}/playlists/{playlist_id}/tracks')

    content <- RETRY('POST', url,
                     body = list(uris = paste0("spotify:track:", tracks),
                                 position = position),
                     config(token = auth_code), encode = "json") %>% content

    results_df <- data.frame(unlist(content)) %>%
        mutate(colname = rownames(.)) %>%
        spread(key = colname, value = `unlist.content.`)

    results_df
}
