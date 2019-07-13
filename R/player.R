#' Get the object currently being played on the user’s Spotify account.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-currently-playing} and/or \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export

get_my_currently_playing <- function(market = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/currently-playing'
    params <- list(market = market)
    res <- RETRY('GET', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Get Current User's Recently Played Tracks
#'
#' @param limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
#' @param after Optional. A Unix timestamp in milliseconds. Returns all items after (but not including) this cursor position. If \code{after} is specified, \code{before} must not be specified.
#' @param before Optional. A Unix timestamp in milliseconds. Returns all items before (but not including) this cursor position. If \code{before} is specified, \code{after} must not be specified.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"before"}, \code{"after"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' The access token must have the \code{user-read-recently-played} scope authorized in order to read the user's recently played tracks.
#' @return
#' Returns a list or data frame of results containing the most recently played tracks for the current user.
#' @export

get_my_recently_played <- function(limit = 20, after = NULL, before = NULL, authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    stopifnot(is.null(after) | is.null(before))
    base_url <- 'https://api.spotify.com/v1/me/player/recently-played'
    params <- list(
        limit = limit,
        after = after,
        before = before
    )
    res <- RETRY('GET', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Get information about a user’s available devices.
#'
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a data frame of results containing user device information. See the official Spotify Web API \href{https://developer.spotify.com/documentation/web-api/reference/player/get-a-users-available-devices/}{documentation} for more information.
#' @export

get_my_devices <- function(authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/devices'
    res <- RETRY('GET', base_url, config(token = authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res$devices)
}

#' Get information about the user’s current playback state, including track, track progress, and active device.
#'
#' @param market An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-read-playback-state} scope authorized in order to read information.
#' @return
#' Returns a list containing user playback information. See the official Spotify Web API \href{https://developer.spotify.com/documentation/web-api/reference/player/get-information-about-the-users-current-playback/}{documentation} for more information.
#' @export

get_my_current_playback <- function(market = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player'
    params <- list(market = market)
    res <- RETRY('GET', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Pause playback on the user’s account.
#'
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

pause_my_playback <- function(device_id = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/pause'
    params <- list(device_id = device_id)
    res <- RETRY('PUT', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Toggle shuffle on or off for user’s playback.
#'
#' @param state Required. \cr
#' \code{TRUE}: Shuffle user's playback \cr
#' \code{FALSE} Do not shuffle user's playback
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

toggle_my_shuffle <- function(state, device_id = NULL, authorization = get_spotify_authorization_code()) {
    stopifnot(is.logical(state))
    base_url <- 'https://api.spotify.com/v1/me/player/shuffle'
    params <- list(
        state = state,
        device_id = device_id
        )
    res <- RETRY('PUT', base_url, config(token = authorization), query = params, encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

set_my_repeat_mode <- function(state, device_id = NULL, authorization = get_spotify_authorization_code()) {
    stopifnot(state %in% c('track', 'context', 'off'))
    stopifnot(length(state) == 1)
    base_url <- 'https://api.spotify.com/v1/me/player/repeat'
    params <- list(
        state = state,
        device_id = device_id
    )
    res <- RETRY('PUT', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Set the volume for the user’s current playback device.
#'
#' @param volume_percent Required. Integer. The volume to set. Must be a value from 0 to 100 inclusive.
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

set_my_volume <- function(volume_percent, device_id = NULL, authorization = get_spotify_authorization_code()) {
    stopifnot(is.numeric(volume_percent))
    stopifnot(volume %in% seq(0, 100))
    stopifnot(length(volume) == 1)
    base_url <- 'https://api.spotify.com/v1/me/player/volume'
    params <- list(
        volume_percent = volume_percent,
        device_id = device_id
    )
    res <- RETRY('PUT', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Skips to next track in the user’s queue.
#'
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

skip_my_playback <- function(device_id = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/next'
    params <- list(
        device_id = device_id
    )
    res <- RETRY('POST', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Skips to previous track in the user’s queue.
#'
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

skip_my_playback_previous <- function(device_id = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/previous'
    params <- list(
        device_id = device_id
    )
    res <- RETRY('POST', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Skips to previous track in the user’s queue.
#'
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param context_uri Optional. String of the Spotify URI of the context to play. Valid contexts are albums, artists, playlists. Example \code{context_uri = "spotify:album:1Je1IMUlBXcx1Fz0WE7oPT"}.
#' @param uris Optional. A character vector of the Spotify track URIs to play. For example: \code{"uris": c("spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M")}.
#' @param offset Optional. A named list indicating from where the context playback should start. Only available when \code{context_uri} corresponds to an album or playlist object, or when the \code{uris} parameter is used. \cr
#' \code{"position"} is zero based and can't be negative. Example: \code{"offset" = list("position" = 5)}. \cr
#' \code{"uri"} is a string representing the uri of the item to start at. Example: \code{"offset" = list("uri" = "spotify:track:1301WleyT98MSxVHPZCA6M")}.
#' @param position_ms Optional. Integer indicating from what position to start playback. Must be a positive number. Passing in a position that is greater than the length of the track will cause the player to start playing the next song.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

start_my_playback <- function(device_id = NULL, context_uri = NULL, uris = NULL, offset = NULL, position_ms = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/play'
    query_params = list(
        device_id = device_id
    )
    body_params <- list(
        context_uri = context_uri,
        uris = uris,
        offset = offset,
        position_ms = position_ms
    )
    res <- RETRY('PUT', base_url, query = query_params, config(token = authorization), body = body_params, encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

transfer_my_playback <- function(device_ids, play = FALSE, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/player/'
    params <- list(
        device_ids = list(device_ids),
        play = play
    )
    res <- RETRY('PUT', base_url, config(token = authorization), body = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Seeks to the given position in the user’s currently playing track.
#'
#' @param position_ms Required. Integer indicating the position in milliseconds to seek to. Must be a positive number. Passing in a position that is greater than the length of the track will cause the player to start playing the next song.
#' @param device_id Optional. The id of the device this command is targeting. If not supplied, the user’s currently active device is the target.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_access_token()}. The access token must have been issued on behalf of the current user. \cr
#' The access token must have the \code{user-modify-playback-state} scope authorized in order to control playback.
#' @export

seek_to_position <- function(position_ms, device_id = NULL, authorization = get_spotify_authorization_code()) {

    stopifnot(is.numeric(position_ms))
    stopifnot(position_ms > 0)
    stopifnot(round(position_ms) == position_ms)

    base_url <- 'https://api.spotify.com/v1/me/player/seek'
    params <- list(
        position_ms = position_ms,
        device_id = device_id
        )
    res <- RETRY('PUT', base_url, config(token = authorization), query = params, encode = 'json')
    stop_for_status(res)
    return(res)
}
