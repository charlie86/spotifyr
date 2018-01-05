#' Get user playlists
#'
#' This function returns a dataframe of playlists for a given Spotify username
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @param show_progress Boolean determining to show progress bar or not. Defaults to \code{FALSE}.
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' get_user_playlists('barackobama')
#' }

get_user_playlists <- function(username, access_token = get_spotify_access_token(), show_progress = TRUE) {

  playlist_count <- get_user_playlist_count(username)
  num_loops <- ceiling(playlist_count / 50)
  offset <- 0

  if (show_progress == TRUE & num_loops > 1) {
    pb <- txtProgressBar(min = 0, max = num_loops, style = 3)
  }

  playlists_list <- map(1:ceiling(num_loops), function(x) {
    endpoint <- paste0('https://api.spotify.com/v1/users/', username, '/playlists')
    res <- GET(endpoint, query = list(access_token = access_token, offset = offset, limit = 50)) %>% content

    if (!is.null(res$error)) {
        stop(paste0(res$error$message, ' (', res$error$status, ')'))
    }

    content <- res$items

    total <- content$total
    offset <<- offset + 50

    if (exists('pb')) {
      setTxtProgressBar(pb, x)
    }

    return(content)
  })

  playlists_df <- parse_playlist_list_to_df(playlists_list) %>%
      dplyr::filter(!is.na(playlist_name))

  return(playlists_df)

}
