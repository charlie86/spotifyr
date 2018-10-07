#' Add the current user as a follower of a playlist.
#'
#' @param type Required. The ID type: either \code{"artist"} or \code{"user"}.
#' @param ids Optional. A character of the artist or the user \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs}. For example: \code{ids = c("74ASZWbe4lXaubB36ztrGX", "08td7MxkoHQkXnWAYD8d6Q")}. A maximum of 50 IDs can be sent in one request.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. Modifying the list of artists or users the current user follows requires authorization of the \code{user-follow-modify} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export
#'
#' @examples
#'

follow_artist_or_user <- function(type, ids, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/following'
    query_params <- list(
        type = type,
        ids = ids
    )
    body_params <- list(
        ids = ids
    )
    res <- PUT(base_url, config(token = Authorization), query = query_params, body = body_params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Add the current user as a follower of a playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} of the playlist. Any playlist can be followed, regardless of its \href{https://developer.spotify.com/documentation/general/guides/working-with-playlists/#public-private-and-collaborative-status}{public/private status}, as long as you know its playlist ID.
#' @param public Optional. Defaults to \code{TRUE}. If \code{TRUE} the playlist will be included in the user's public playlists, if \code{FALSE} it will remain private. o be able to follow playlists privately, the user must have granted the \code{playlist-modify-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope}.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Following a publicly followed playlist for a user requires authorization of the \code{playlist-modify-public} scope; following a privately followed playlist requires the \code{playlist-modify-private} scope. See See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}. \cr
#' Note that the scopes you provide relate only to whether the current user is following the playlist publicly or privately (i.e. showing others what they are following), not whether the playlist itself is public or private.
#' @export
#'
#' @examples
#'

follow_playlist <- function(playlist_id, public = FALSE, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/followers')
    params <- list(
        public = public
    )
    res <- PUT(url, config(token = Authorization), body = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Remove the current user as a follower of a playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} of the playlist that is to be no longer followed.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Unfollowing a publicly followed playlist for a user requires authorization of the \code{playlist-modify-public} scope; unfollowing a privately followed playlist requires the \code{playlist-modify-private} scope. See See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}. \cr
#' Note that the scopes you provide relate only to whether the current user is following the playlist publicly or privately (i.e. showing others what they are following), not whether the playlist itself is public or private.
#' @export
#'
#' @examples
#'

unfollow_playlist <- function(playlist_id, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/followers')
    res <- DELETE(url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Get the current user’s followed artists.
#'
#' @param limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
#' @param after Optional. The last artist ID retrieved from the previous request.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. Getting details of the artists or users the current user follows requires authorization of the \code{user-follow-read} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @export
#'
#' @examples
#'

get_my_followed_artists <- function(limit = 20, after = NULL, Authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/me/following'
    params <- list(
        type = 'artist',
        limit = limit,
        after = after
    )
    res <- GET(base_url, query = params, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>%
        .$artists
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}
