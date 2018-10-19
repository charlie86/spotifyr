#' Get a playlist owned by a Spotify user.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param fields Optional. Filters for the query: a comma-separated list of the fields to return. If omitted, all fields are returned. For example, to get just the playlist’s description and URI: \code{fields = c("description", "uri")}. A dot separator can be used to specify non-reoccurring fields, while parentheses can be used to specify reoccurring fields within objects. For example, to get just the added date and user ID of the adder: \cr
#' \code{fields = "tracks.items(added_at,added_by.id)"}. Use multiple parentheses to drill down into nested objects, for example: \cr
#' \code{fields = "tracks.items(track(name,href,album(name,href)))"}. Fields can be excluded by prefixing them with an exclamation mark, for example: \cr
#' \code{fields = "tracks.items(track(name,href,album(!name,href)))"}.
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API Authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Both Public and Private playlists belonging to any user are retrievable on provision of a valid access token. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_playlist <- function(playlist_id, fields = NULL, market = NULL, Authorization = get_spotify_access_token()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}')
    params <- list(
        fields = paste(fields, collapse = ','),
        market = market,
        access_token = Authorization
    )
    # res <- GET(url, query = params, encode = 'json')
    res <- RETRY('GET', url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Get full details of the tracks of a playlist owned by a Spotify user.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param fields Optional. Filters for the query: a comma-separated list of the fields to return. If omitted, all fields are returned. For example, to get just the playlist’s description and URI: \code{fields = c("description", "uri")}. A dot separator can be used to specify non-reoccurring fields, while parentheses can be used to specify reoccurring fields within objects. For example, to get just the added date and user ID of the adder: \cr
#' \code{fields = "tracks.items(added_at,added_by.id)"}. Use multiple parentheses to drill down into nested objects, for example: \cr
#' \code{fields = "tracks.items(track(name,href,album(name,href)))"}. Fields can be excluded by prefixing them with an exclamation mark, for example: \cr
#' \code{fields = "tracks.items(track(name,href,album(!name,href)))"}.
#' @param limit Optional. \cr
#' Maximum number of tracks to return. \cr
#' Default: 100 \cr
#' Minimum: 1 \cr
#' Maximum: 100 \cr
#' @param offset Optional. \cr
#' The index of the first track to return. \cr
#' Default: 0 (the first object). \cr
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{Web API Authorization Guide}{https://developer.spotify.com/documentation/general/guides/authorization-guide/} for more details. Both Public and Private playlists belonging to any user are retrievable on provision of a valid access token. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_playlist_tracks <- function(playlist_id, fields = NULL, limit = 100, offset = 0, market = NULL, Authorization = get_spotify_access_token(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/tracks')
    params <- list(
        fields = paste(fields, collapse = ','),
        limit = limit,
        offset = offset,
        market = market,
        access_token = Authorization
    )
    res <- GET(url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}


#' Get a list of the playlists owned or followed by the current Spotify user.
#'
#' @param limit Optional. \cr
#' Maximum number of playlists to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' @param offset Optional. \cr
#' The index of the first playlist to return. \cr
#' Default: 0 (the first object). Maximum offset: 100,000. Use with \code{limit} to get the next set of playlists.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Private playlists are only retrievable for the current user and requires the \code{playlist-read-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user. Note that this scope alone will not return collaborative playlists, even though they are always private. \cr
#' Collaborative playlists are only retrievable for the current user and requires the \code{playlist-read-collaborative} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export
#'
#' @examples
#'

get_my_playlists <- function(limit = 20, offset = 0, Authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/me/playlists'
    params <- list(
        limit = limit,
        offset = offset
    )
    res <- GET(base_url, query = params, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)

    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Get a list of the playlists owned or followed by a Spotify user.
#'
#' @param user_id Required. The user's \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify user ID}.
#' @param limit Optional. \cr
#' Maximum number of playlists to return. \cr
#' Default: 20 \cr
#' Minimum: 1 \cr
#' Maximum: 50 \cr
#' @param offset Optional. \cr
#' The index of the first playlist to return. \cr
#' Default: 0 (the first object). Maximum offset: 100,000. Use with \code{limit} to get the next set of playlists.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Private playlists are only retrievable for the current user and requires the \code{playlist-read-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user. Note that this scope alone will not return collaborative playlists, even though they are always private. \cr
#' Collaborative playlists are only retrievable for the current user and requires the \code{playlist-read-collaborative} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing user playlist information. See the official \href{https://developer.spotify.com/documentation/web-api/reference/playlists/get-list-users-playlists/}{Spotify Web API documentation} for more information.
#' @export
#'
#' @examples
#'

get_user_playlists <- function(user_id, limit = 20, offset = 0, Authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/users'
    url <- str_glue('{base_url}/{user_id}/playlists')
    params <- list(
        limit = limit,
        offset = offset
    )
    res <- RETRY('GET', url, query = params, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    if (!include_meta_info) {
        res <- res$items
    }
    return(res)
}

#' Get the current image associated with a specific playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Current playlist image for both Public and Private playlists of any user are retrievable on provision of a valid access token.
#' @return
#' Returns a data frame of results containing playlist cover image information. See the official \href{https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist-cover/}{Spotify Web API Documentation} for more information.
#' @export
#'
#' @examples
#'

get_playlist_cover_image <- function(playlist_id, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/images')
    res <- GET(url, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Create a playlist for a Spotify user. (The playlist will be empty until you add tracks.)
#'
#' @param user_id Required. The user's \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify user ID}.
#' @param name Required. String containing the name for the new playlist, for example \code{"Your Coolest Playlist"}. This name does not need to be unique; a user may have several playlists with the same name.
#' @param public Optional. Boolean. Defaults to \code{TRUE}. If \code{TRUE} the playlist will be public. If \code{FALSE} it will be private. To be able to create private playlists, the user must have granted the \code{playlist-modify-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope}
#' @param collaborative Optional. Boolean. Defaults to \code{FALSE}. If \code{TRUE} the playlist will be collaborative. Note that to create a collaborative playlist you must also set \code{public} to \code{FALES}. To create collaborative playlists you must have granted \code{playlist-modify-private} and \code{playlist-modify-public} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scopes}.
#' @param description Optional. String containing the playlist description as displayed in Spotify Clients and in the Web API.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Creating a public playlist for a user requires authorization of the \code{playlist-modify-public} scope; creating a private playlist requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export
#'
#' @examples
#'

create_playlist <- function(user_id, name, public = TRUE, collaborative = FALSE, description = NULL, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/users'
    url <- str_glue('{base_url}/{user_id}/playlists')
    params <- list(
        name = name,
        public = public,
        collaborative  = collaborative,
        description = description
    )
    res <- POST(url, body = params, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Add one or more tracks to a user’s playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param uris Optional. A character vector of \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify track URIs} to add. For example \cr
#' \code{uris = "spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"} \cr
#' A maximum of 100 tracks can be added in one request.
#' @param position Optional. Integer indicating the position to insert the tracks, a zero-based index. For example, to insert the tracks in the first position: \code{position = 0}; to insert the tracks in the third position: \code{position = 2} . If omitted, the tracks will be appended to the playlist. Tracks are added in the order they are listed in the query string or request body.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Adding tracks to the current user’s public playlists requires authorization of the \code{playlist-modify-public} scope; adding tracks to the current user’s private playlist (including collaborative playlists) requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export
#'
#' @examples
#'

add_tracks_to_playlist <- function(playlist_id, uris, position = NULL, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/tracks')
    params <- list(
        uris = uris,
        position = position
    )
    res <- POST(url, body = params, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Change a playlist’s name and public/private state. (The user must, of course, own the playlist.)
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param name Optional String containing the name for the new playlist, for example \code{"Your Coolest Playlist"}. This name does not need to be unique; a user may have several playlists with the same name.
#' @param public Optional. Boolean. If \code{TRUE} the playlist will be public. If \code{FALSE} it will be private.
#' @param collaborative Optional. Boolean. If \code{TRUE} the playlist will become collaborative and other users will be able to modify the playlist in their Spotify client.Note: you can only set \code{collaborative} to \code{TRUE} on non-public playlists.
#' @param description Optional. String containing the playlist description as displayed in Spotify Clients and in the Web API.
#' @param Authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API Authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Changing a public playlist for a user requires authorization of the \code{playlist-modify-public} scope; changing a private playlist requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export
#'
#' @examples
#'

change_playlist_details <- function(playlist_id, name = NULL, public = NULL, collaborative = NULL, description = NULL, Authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}')
    params <- list(
        name = name,
        public = public,
        collaborative  = collaborative,
        description = description
    )
    res <- PUT(url, body = params, config(token = Authorization), encode = 'json')
    stop_for_status(res)
    return(res)
}
