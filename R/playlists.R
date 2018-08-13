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

#' Get count of Spotify playlists for a given user
#'
#' Helper function for \code{spotifyr::get_user_playlists()}
#' @param username String of Spotify username. Can be found within the Spotify App
#' @param access_token Spotify Web API token. Defaults to \code{spotifyr::get_spotify_access_token()}.
#' @keywords username
#' @export
#' @examples
#' \dontrun{
#' obama_playlist_count <- get_user_playlist_count('barackobama')
#' }

get_user_playlist_count <- function(username, access_token = get_spotify_access_token()) {
    endpoint <- str_glue('https://api.spotify.com/v1/users/{username}/playlists')
    res <- RETRY('GET', url = endpoint, query = list(access_token = access_token, limit = 1), quiet = TRUE) %>% content

    if (!is.null(res$error)) {
        stop(str_glue('{res$error$message} ({res$error$status})'))
    }
    res$total
}

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

    playlist_count <- get_user_playlist_count(username, access_token = access_token)

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

#' Get features and popularity for all of a user's playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for all of a given user's playlists on Spotify
#' @param username String of Spotify username. Can be found on the Spotify app. (See http://rcharlie.net/sentify/user_uri.gif for example)
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features playlists
#' @export
#' @examples
#' \dontrun{
#' obama_track_features <- get_user_audio_features('barackobama')
#' }

get_user_audio_features <- function(username, parallelize = FALSE, future_plan = 'multiprocess', access_token = get_spotify_access_token()) {

    playlists <- get_user_playlists(username, parallelize = parallelize, future_plan = future_plan, access_token = access_token)
    tracks <- get_playlist_tracks(playlists, parallelize = parallelize, future_plan = future_plan, access_token = access_token)
    track_popularity <- get_track_popularity(tracks, access_token = access_token)
    track_audio_features <- get_track_audio_features(tracks, access_token = access_token)

    tots <- playlists %>%
        select(-playlist_img) %>%
        left_join(tracks, by = 'playlist_name') %>%
        left_join(track_popularity, by = 'track_uri') %>%
        left_join(track_audio_features, by = 'track_uri')

    return(tots)
}

#' Get tracks from one or more playlists
#'
#' This function returns tracks from a dataframe of playlists on Spotify
#' @param playlists Dataframe containing the columns `playlist_num_tracks`, `playlist_tracks_url`, `playlist_name`, and `playlist_img`, corresponding to Spotify playlists. Can be output from spotifyr::get_user_playlists()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @keywords album tracks
#' @export
#' @examples
#' \dontrun{
#' playlists <- get_user_playlists('barackobama')
#' playlist_tracks <- get_playlist_tracks(playlists)
#' }

get_playlist_tracks <- function(playlists, access_token = get_spotify_access_token(), parallelize = FALSE, future_plan = 'multiprocess') {

    map_args <- list(
        1:nrow(playlists),
        function(this_playlist) {
            print(this_playlist)
            num_loops <- ceiling(playlists$playlist_num_tracks[this_playlist] / 100)

            map_df(1:num_loops, function(this_loop) {
                print(this_loop)

                res <- RETRY('GET', url = playlists$playlist_tracks_url[this_playlist], query = list(access_token = access_token, limit = 100, offset = (100 * this_loop) - 100), quiet = TRUE, times = 10) %>% content

                if (!is.null(res$error)) {
                    stop(str_glue('{res$error$message} ({res$error$status})'))
                }

                content <- res$items

                if (length(content) == 0) {
                    track_info <- tibble()
                } else {
                    track_info <- map_df(1:length(content), function(this_row) {

                        this_track <- content[[this_row]]

                        if (is.null(this_track$added_at)) {
                            track_added_at <- NA
                        } else {
                            track_added_at <- this_track$added_at
                        }

                        if (!is.null(this_track$track$id)) {

                            list(
                                playlist_name = playlists$playlist_name[this_playlist],
                                playlist_img = playlists$playlist_img[this_playlist],
                                track_name = this_track$track$name,
                                track_uri = this_track$track$id,
                                artist_name = this_track$track$artists[[1]]$name,
                                album_name = this_track$track$album$name,
                                album_img = ifelse(length(this_track$track$album$images) > 0, this_track$track$album$images[[1]]$url, ''),
                                track_added_at = as.POSIXct(track_added_at, format = '%Y-%m-%dT%H:%M:%SZ')
                            )
                        }
                    })
                }
            })

        }
    )

    if (parallelize) {
        og_plan <- plan()
        on.exit(plan(og_plan), add = TRUE)
        plan(future_plan)
        map_function <- 'future_map_dfr'
        map_args <- c(map_args, .progress = TRUE)
    } else {
        map_function <- 'map_df'
    }

    do.call(map_function, map_args)

}

#' Get features and popularity for all of a given set of playlists on Spotify
#'
#' This function returns the popularity and audio features for every song for a given set of playlists on Spotify
#' @param username String of Spotify username. Can be found on the Spotify app. (See http://rcharlie.net/sentify/user_uri.gif for example)
#' @param playlist_uris Character vector of Spotify playlist uris associated with the given \code{username}. Can be found within the Spotify App
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{TRUE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features playlists
#' @export
#' @examples
#' \dontrun{
#' playlist_username <- 'spotify'
#' playlist_uris <- c('37i9dQZF1E9T1oFsQFg98K', '37i9dQZF1CyQNOI21QVf3p')
#' my_playlist_audio_features <- get_playlist_audio_features('spotify', playlist_uris)
#' }

get_playlist_audio_features <- function(username, playlist_uris, parallelize = FALSE, future_plan = 'multiprocess', access_token = get_spotify_access_token()) {

    playlists <- get_playlists(username, playlist_uris, access_token = access_token)
    tracks <- get_playlist_tracks(playlists, parallelize = parallelize, future_plan = future_plan, access_token = access_token)
    track_popularity <- get_track_popularity(tracks, access_token = access_token)
    track_audio_features <- get_track_audio_features(tracks, access_token = access_token)

    tots <- playlists %>%
        select(-playlist_img) %>%
        left_join(tracks, by = 'playlist_name') %>%
        left_join(track_popularity, by = 'track_uri') %>%
        left_join(track_audio_features, by = 'track_uri')

    return(tots)
}
