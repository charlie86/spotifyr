#' Add the current user as a follower of one or more artists or other Spotify users.
#'
#' @param type Required. The ID type: either \code{"artist"} or \code{"user"}.
#' @param ids Optional. A character vector of the artist or the user \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs}. For example: \code{ids = c("74ASZWbe4lXaubB36ztrGX", "08td7MxkoHQkXnWAYD8d6Q")}. A maximum of 50 IDs can be sent in one request.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. Modifying the list of artists or users the current user follows requires authorization of the \code{user-follow-modify} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

follow_artists_or_users <- function(type, ids, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/me/following'
    query_params <- list(
        type = type,
        ids = paste0(ids, collapse = ',')
    )
    res <- RETRY('PUT', base_url, config(token = authorization), query = query_params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Add the current user as a follower of a playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} of the playlist. Any playlist can be followed, regardless of its \href{https://developer.spotify.com/documentation/general/guides/working-with-playlists/#public-private-and-collaborative-status}{public/private status}, as long as you know its playlist ID.
#' @param public Optional. Defaults to \code{TRUE}. If \code{TRUE} the playlist will be included in the user's public playlists, if \code{FALSE} it will remain private. o be able to follow playlists privately, the user must have granted the \code{playlist-modify-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope}.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Following a publicly followed playlist for a user requires authorization of the \code{playlist-modify-public} scope; following a privately followed playlist requires the \code{playlist-modify-private} scope. See See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}. \cr
#' Note that the scopes you provide relate only to whether the current user is following the playlist publicly or privately (i.e. showing others what they are following), not whether the playlist itself is public or private.
#' @export

follow_playlist <- function(playlist_id, public = FALSE, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/followers')
    params <- list(
        public = public
    )
    res <- RETRY('PUT', url, config(token = authorization), body = params, encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Remove the current user as a follower of a playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} of the playlist that is to be no longer followed.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Unfollowing a publicly followed playlist for a user requires authorization of the \code{playlist-modify-public} scope; unfollowing a privately followed playlist requires the \code{playlist-modify-private} scope. See See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}. \cr
#' Note that the scopes you provide relate only to whether the current user is following the playlist publicly or privately (i.e. showing others what they are following), not whether the playlist itself is public or private.
#' @export

unfollow_playlist <- function(playlist_id, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/followers')
    res <- RETRY('DELETE', url, config(token = authorization), encode = 'json')
    stop_for_status(res)
    return(res)
}

#' Get the current user’s followed artists.
#'
#' @param limit Optional. The maximum number of items to return. Default: 20. Minimum: 1. Maximum: 50.
#' @param after Optional. The last artist ID retrieved from the previous request.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. Getting details of the artists or users the current user follows requires authorization of the \code{user-follow-read} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @export

get_my_followed_artists <- function(limit = 20, after = NULL, authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/me/following'
    params <- list(
        type = 'artist',
        limit = limit,
        after = after
    )
    res <- RETRY('GET', base_url, query = params, config(token = authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE) %>%
        .$artists
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Check if Current User Follows Artists or Users
#'
#' @param type Required. String of the ID type: either \code{"artist"} or \code{"user"}.
#' @param ids Required. A character vector of the artist or the user \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify IDs} to check. For example: \code{ids = c("74ASZWbe4lXaubB36ztrGX", "08td7MxkoHQkXnWAYD8d6Q")}. A maximum of 50 IDs can be sent in one request.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. Getting details of the artists or users the current user follows requires authorization of the \code{user-follow-read} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

check_me_following <- function(type, ids, authorization = get_spotify_authorization_code()) {

    base_url <- 'https://api.spotify.com/v1/me/following/contains'
    params <- list(
        type = type,
        ids = paste0(ids, collapse = ',')
    )
    res <- RETRY('GET', base_url, query = params, config(token = authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    tibble(type = type,
           id = ids,
           is_following = res)

}

#' Check if Users Follow a Playlist
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} of the playlist.
#' @param ids Required. \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify User IDs}; the ids of the users that you want to check to see if they follow the playlist. Maximum: 5 ids.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. \cr
#' Following a playlist can be done publicly or privately. Checking if a user publicly follows a playlist doesn’t require any scopes; if the user is publicly following the playlist, this endpoint returns \code{TRUE}. \cr
#' Checking if the user is privately following a playlist is only possible for the current user when that user has granted access to the \code{playlist-read-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

check_users_following <- function(playlist_id, ids, authorization = get_spotify_authorization_code()) {

    base_url <- 'https://api.spotify.com/v1/playlists'
    params <- list(
        playlist_id = playlist_id,
        ids = paste0(ids, collapse = ',')
    )
    url <- str_glue('{base_url}/{playlist_id}/followers/contains')
    res <- RETRY('GET', url, query = params, config(token = authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    tibble(user_id = ids,
           playlist_id = playlist_id,
           is_following = res)

}
