#' Get a playlist owned by a Spotify user.
#'
#'@importFrom stringr str_glue
#'@importFrom purrr pluck map map_dfr
#'@importFrom dplyr bind_rows
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param fields Optional. Filters for the query: a comma-separated list of the fields to return. If omitted, all fields are returned. For example, to get just the playlist’s description and URI: \cr
#' \code{fields = c("description", "uri")} \cr A dot separator can be used to specify non-reoccurring fields, while parentheses can be used to specify reoccurring fields within objects. For example, to get just the added date and user ID of the adder: \cr
#' \code{fields = "tracks.items(added_at,added_by.id)"} \cr Use multiple parentheses to drill down into nested objects, for example: \cr
#' \code{fields = "tracks.items(track(name,href,album(name,href)))"} \cr Fields can be excluded by prefixing them with an exclamation mark, for example: \cr
#' \code{fields = "tracks.items(track(name,href,album(!name,href)))"}
#' @param market Optional. \cr
#' An ISO 3166-1 alpha-2 country code or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Both Public and Private playlists belonging to any user are retrievable on provision of a valid access token. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export

get_playlist <- function(playlist_id, fields = NULL, market = NULL, authorization = get_spotify_access_token()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}')
    params <- list(
        fields = paste(fields, collapse = ','),
        market = market,
        access_token = authorization
    )

    # stopping is built into query_playlist()
    init_query <- query_playlist(url, params = params)

    if (!is.null(fields)) {
        return(init_query)
    } else {
        # identify how many pages there are
        n_pages <- ceiling(pluck(init_query, "tracks", "total")/100) - 1
        # identify pagination offsets
        offsets <- seq(from = 1, to = n_pages) * 100
        # create page urls
        page_urls <- str_glue("{url}/tracks?offset={offsets}&limit=100")
        # query api
        other_pages <- map(page_urls, query_playlist, params)
        # merge the song track results
        all_items <- bind_rows(
            pluck(init_query, "tracks", "items"),
            map_dfr(other_pages, pluck, "items")
        )

        # overwrite init_query item results
        init_query[["tracks"]][["items"]] <- all_items

        #return init_query object
        structure(init_query, class = c("playlist", "list"))

    }
}

#' Get full details of the tracks of a playlist owned by a Spotify user.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param fields Optional. Filters for the query: a comma-separated list of the fields to return. If omitted, all fields are returned. For example, to get just the playlist’s creation date and album information: \code{fields = c("added_at", "track.album")}. A dot separator can be used to specify non-reoccurring fields, while parentheses can be used to specify reoccurring fields within objects. For example, to get just the added date and user ID of the adder: \cr
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization guide} for more details. Both Public and Private playlists belonging to any user are retrievable on provision of a valid access token. Defaults to \code{spotifyr::get_spotify_access_token()}
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export

get_playlist_tracks <- function(playlist_id, fields = NULL, limit = 100, offset = 0, market = NULL, authorization = get_spotify_access_token(), include_meta_info = FALSE) {

    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/tracks')
    params <- list(
        fields = ifelse(!is.null(fields), paste0('items(', paste0(fields, collapse = ','), ')'), ''),
        limit = limit,
        offset = offset,
        market = market,
        access_token = authorization
    )
    res <- RETRY('GET', url, query = params, encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Private playlists are only retrievable for the current user and requires the \code{playlist-read-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user. Note that this scope alone will not return collaborative playlists, even though they are always private. \cr
#' Collaborative playlists are only retrievable for the current user and requires the \code{playlist-read-collaborative} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing user profile information. See \url{https://developer.spotify.com/documentation/web-api/reference/users-profile/get-current-users-profile/} for more information.
#' @export

get_my_playlists <- function(limit = 20, offset = 0, authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/me/playlists'
    params <- list(
        limit = limit,
        offset = offset
    )
    res <- RETRY('GET', base_url, query = params, config(token = authorization), encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Private playlists are only retrievable for the current user and requires the \code{playlist-read-private} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user. Note that this scope alone will not return collaborative playlists, even though they are always private. \cr
#' Collaborative playlists are only retrievable for the current user and requires the \code{playlist-read-collaborative} \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{scope} to have been authorized by the user.
#' @param include_meta_info Optional. Boolean indicating whether to include full result, with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @return
#' Returns a data frame of results containing user playlist information. See the official \href{https://developer.spotify.com/documentation/web-api/reference/playlists/get-list-users-playlists/}{Spotify Web API documentation} for more information.
#' @export
get_user_playlists <- function(user_id, limit = 20, offset = 0, authorization = get_spotify_authorization_code(), include_meta_info = FALSE) {
    base_url <- 'https://api.spotify.com/v1/users'
    url <- str_glue('{base_url}/{user_id}/playlists')
    params <- list(
        limit = limit,
        offset = offset
    )
    res <- RETRY('GET', url, query = params, config(token = authorization), encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Current playlist image for both Public and Private playlists of any user are retrievable on provision of a valid access token.
#' @return
#' Returns a data frame of results containing playlist cover image information. See the official \href{https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist-cover/}{Spotify Web API Documentation} for more information.
#' @export

get_playlist_cover_image <- function(playlist_id, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/images')
    res <- RETRY('GET', url, config(token = authorization), encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Creating a public playlist for a user requires authorization of the \code{playlist-modify-public} scope; creating a private playlist requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

create_playlist <- function(user_id, name, public = TRUE, collaborative = FALSE, description = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/users'
    url <- str_glue('{base_url}/{user_id}/playlists')
    params <- list(
        name = name,
        public = public,
        collaborative  = collaborative,
        description = description
    )
    res <- RETRY('POST', url, body = params, config(token = authorization), encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Adding tracks to the current user’s public playlists requires authorization of the \code{playlist-modify-public} scope; adding tracks to the current user’s private playlist (including collaborative playlists) requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

add_tracks_to_playlist <- function(playlist_id, uris, position = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/tracks?uris={paste0(uris, collapse = ",")}')
    params <- list(
        position = position
    )
    res <- RETRY('POST', url, body = params, config(token = authorization), encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    return(res)
}

#' Remove one or more tracks from a user’s playlist.
#'
#' @param playlist_id Required. The \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify ID} for the playlist.
#' @param uris Optional. A character vector of \href{https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids}{Spotify track URIs} to add. For example \cr
#' \code{uris = "spotify:track:4iV5W9uYEdYUVa79Axb7Rh", "spotify:track:1301WleyT98MSxVHPZCA6M"} \cr
#' A maximum of 100 tracks can be removed in one request.
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Removing tracks to the current user’s public playlists requires authorization of the \code{playlist-modify-public} scope; removing tracks from the current user’s private playlist (including collaborative playlists) requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

remove_tracks_from_playlist <- function(playlist_id, uris, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}/tracks/')

    # For DELETE request params URIs should be put in body
    uris_list <- lapply(uris, function(x) list(uri = x))
    params <- toJSON(list(tracks = uris_list), auto_unbox = T)

    res <- RETRY('DELETE', url, body = params, config(token = authorization), encode = 'json')
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
#' @param authorization Required. A valid access token from the Spotify Accounts service. See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details. Defaults to \code{spotifyr::get_spotify_authorization_code()}. The access token must have been issued on behalf of the current user. \cr
#' Changing a public playlist for a user requires authorization of the \code{playlist-modify-public} scope; changing a private playlist requires the \code{playlist-modify-private} scope. See \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/#list-of-scopes}{Using Scopes}.
#' @export

change_playlist_details <- function(playlist_id, name = NULL, public = NULL, collaborative = NULL, description = NULL, authorization = get_spotify_authorization_code()) {
    base_url <- 'https://api.spotify.com/v1/playlists'
    url <- str_glue('{base_url}/{playlist_id}')
    params <- list(
        name = name,
        public = public,
        collaborative  = collaborative,
        description = description
    )
    res <- RETRY('PUT', url, body = params, config(token = authorization), encode = 'json')
    stop_for_status(res)
    return(res)
}



#' Tidy a playlist
#'
#' \code{spotifyr::tidy()} extracts and tidies the data frame containing track level information that is returned from \code{get_playlist()} as a tibble.
#'
#' @param x A playlist object generated from
#' @examples
#' \dontrun{
#' fall <- get_playlist("4GSV6uJzlbtTCPJhnVU1o8")
#' tidy(fall)
#' }
#'
#'@importFrom purrr pluck map
#'@importFrom stringr str_remove
#'@importFrom dplyr as_tibble select mutate
#'@importFrom janitor make_clean_names
#' @export
#'
#'
tidy <- function(x, ...) {
    UseMethod("tidy")
}

#' @export
tidy.playlist <- function(x, ...) {
    # determine unneeded columns
    # the added by features can all bne derived by the `added_by_uri` col
    unneeded <- c("added_by_href", "added_by_uri", "added_by_external_urls_spotify",
                  # album information can be fetched with get_album
                  "album_uri", "album_href", "album_artists", "album_album_type",
                  "album_images", "album_release_date", "album_release_date_precision",
                  "album_total_tracks", "album_type", "album_external_urls_spotify",
                  "album_available_markets",
                  # do not need uri as that can be created from "spotify:{type}:{id}"
                  "uri")

    # clean col names
    track_items <- pluck(x, "tracks", "items")
    colnames(track_items) <- make_clean_names(str_remove(names(track_items), "track"))

    tidied <- track_items %>%
        # select(artists) %>%
        mutate(artist_names = map(artists, pull, "name")) %>%
        select(-unneeded) %>%
        select(track_name = name, album_name, id,
               artist_names, added_at, duration_ms, popularity, track_number,
               available_markets, everything())

    dplyr::as_tibble(tidied)
}



#' Print method for playlist object
#' @param x A playlist object generated from \code{get_playlist()}.
#' @param ... Unused.
#' @export
print.playlist <- function(x, ...) {

    to_show <- c("description", "tracks", "type", "href", "images", "public", "collaborative")

    frms <- format(c(
        paste(x$name, "by", x$owner$display_name),
        paste(x$tracks$total, "tracks"),
        paste(x$followers$total, "followers"),
        x$external_urls$spotify))

    cat(frms, "\n", fill = TRUE)
    str(x[to_show], 1, no.list = T, indent.str = "- ", comp.str = "")
    invisible(x)
}
