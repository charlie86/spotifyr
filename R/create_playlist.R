#' Create playlists
#'
#' This function creates a new playlist for a given Spotify username and returns a dataframe of metadata about the new playlist.
#'
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#' @param playlist_name Character vector of the new playlist name
#'
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' hello_fromr <- create_playlist(username = 'rstats', playlist_name =  'hello from spotifyr!')
#' }

create_playlist <- function(username, playlist_name, auth_code = get_spotify_authorization_code()) {

        url <- str_glue('https://api.spotify.com/v1/users/{username}/playlists/')

        content <- RETRY('POST', url, body = list(name = playlist_name), config(token = auth_code), encode = "json") %>% content

        results_df <- data.frame(unlist(content)) %>%
            mutate(colname = rownames(.)) %>%
            spread(key = colname, value = `unlist.content.`)

        results_df
}
