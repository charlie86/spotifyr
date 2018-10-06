#' Get the object currently being played on the user’s Spotify account.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API Authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-currently-playing} and/or \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_my_currently_playing <- function(market = NULL, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/currently-playing'
    params <- list(market = market)
    res <- GET(base_url, config(token = Authorization), query = params, encode = 'json')
    res <- GET(base_url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Get the object currently being played on the user’s Spotify account.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API Authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-currently-playing} and/or \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_my_recently_played <- function(Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/recently-played'
    res <- GET(base_url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Get information about a user’s available devices.
#'
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user device information. See the official Spotify Web API \href{https://developer.spotify.com/documentation/web-api/reference/player/get-a-users-available-devices/}{documentation} for more information.
#' @export
#'
#' @examples
#'

get_my_devices <- function(Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/devices'
    res <- GET(base_url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res$devices)
}

#' Get information about the user’s current playback state, including track, track progress, and active device.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a list containing user playback information. See the official Spotify Web API \href{https://developer.spotify.com/documentation/web-api/reference/player/get-information-about-the-users-current-playback/}{documentation} for more information.
#' @export
#'
#' @examples
#'

get_my_current_playback <- function(market = NULL, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player'
    params <- list(market = market)
    res <- GET(base_url, config(token = Authorization), query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Pause playback on the user’s account.
#'
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export
#'
#' @examples
#'

pause_my_current_playback <- function(device_id = NULL, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/pause'
    params <- list(device_id = device_id)
    res <- PUT(base_url, config(token = Authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Toggle shuffle on or off for user’s playback.
#'
#' @param state Required. \cr
#' \code{TRUE}: Shuffle user's playback \cr
#' \code{FALSE} Do not shuffle user's playback
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export
#'
#' @examples
#'

toggle_my_shuffle <- function(state, device_id = NULL, Authorization = get_spotify_authorization_code()) {
    stopifnot(is.logical(state))
    base_url <- 'https://api.spotify.com/v1/me/player/shuffle'
    params <- list(
        state = state,
        device_id = device_id
        )
    res <- PUT(base_url, config(token = Authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Set the repeat mode for the user’s playback. Options are repeat-track, repeat-context, and off.
#'
#' @param state Required. \cr
#' \code{"track"}, \code{"context"}, or \code{"off"}
#' \code{"track"} will repeat the current track. \cr
#' \code{"context"} will repeat the current context. \cr
#' \code{"off"} will turn repeat off
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export
#'
#' @examples
#'

set_my_repeat_mode <- function(state, device_id = NULL, Authorization = get_spotify_authorization_code()) {
    stopifnot(state %in% c('track', 'context', 'off'))
    stopifnot(length(state) == 1)
    base_url <- 'https://api.spotify.com/v1/me/player/repeat'
    params <- list(
        state = state,
        device_id = device_id
    )
    res <- PUT(base_url, config(token = Authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Transfer playback to a new device and determine if it should start playing.
#'
#' @param device_ids Required. A character vector containing the ID of the device this on which playback should be started/transferred. Note: only a single device_id is currently supported.
#' @param play Optional. \cr
#' \code{TRUE}: Ensure playback happens on new device \cr
#' \code{FALSE} (default): keep the current playback state \cr
#' Note that a value of \code{FALSE} for the \code{play} parameter when also transferring to another \code{device_id} will not pause playback. To ensure that playback is paused on the new device you should send a pause command to the currently active device before transferring to the new \code{device_id}.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export
#'
#' @examples
#'

transfer_my_playback <- function(device_ids, play = FALSE, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/'
    params <- list(
        device_ids = list(device_ids),
        play = play
    )
    res <- PUT(base_url, config(token = Authorization), body = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Seeks to the given position in the user’s currently playing track.
#'
#' @param position_ms Required. Integer indicating the position in milliseconds to seek to. Must be a positive number. Passing in a position that is greater than the length of the track will cause the player to start playing the next song.
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export
#'
#' @examples
#'

seek_to_position <- function(position_ms, device_id = NULL, Authorization = get_spotify_authorization_code()) {

    stopifnot(is.numeric(position_ms))
    stopifnot(position_ms > 0)
    stopifnot(round(position_ms) == position_ms)

    base_url <- 'https://api.spotify.com/v1/me/player/seek'
    params <- list(
        position_ms = position_ms,
        device_id = device_id
        )
    res <- PUT(base_url, config(token = Authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}
