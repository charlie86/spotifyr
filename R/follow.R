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
