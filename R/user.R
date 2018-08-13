#' Get Spotify Authorization Code
#'
#' Get profile information of current user
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_my_profile()
#' }

get_my_profile <- function(auth_code = get_spotify_authorization_code()) {
    res <- GET('https://api.spotify.com/v1/me', config(token = auth_code)) %>% content

    res %>%
        unlist(recursive = FALSE) %>%
        t %>%
        as.data.frame(stringsAsFactors = F) %>%
        mutate_all(funs(ifelse(is.null(.[[1]]), NA, .[[1]]))) %>%
        mutate(birthdate = as.Date(birthdate))
}


#' Get currently playing track for current user
#'
#' Get currently playing track for current user
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#' @param simplify Boolean deciding whether to simplify JSON object into a dataframe with pre-selected fields for analysis. Defaults to \code{FALSE}.
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_my_currently_playing()
#' }

get_my_currently_playing <- function(auth_code = get_spotify_authorization_code()) {

    res <- GET('https://api.spotify.com/v1/me/player/', config(token = auth_code)) %>% content

    tibble(
        track_name = res$item$name,
        artist_name = res$item$artists[[1]]$name,
        album_name = res$item$album$name,
        device_id = res$device$id,
        is_active = res$device$is_active,
        is_playing = res$is_playing,
        is_private_session = res$device$is_private_session,
        is_restricted = res$device$is_restricted,
        device_name = res$device$name,
        device_type = res$device$type,
        volume_percent = res$device$volume_percent,
        timestamp_utc = as_datetime(Sys.time(), tz = 'UTC'),
        started_at_utc = as_datetime(res$timestamp/1000),
        progress_ms = res$progress_ms,
        repeat_state = res$repeat_state,
        shuffle_state = res$shuffle_state,
        context_type = ifelse(!is.null(res$context$type), res$context$type, NA),
        context_uri = ifelse(!is.null(res$context$uri), res$context$uri, NA),
        context_spotify_url = ifelse(!is.null(res$context$external_urls$spotify), res$context$external_urls$spotify, NA),
        album_type = res$item$album$album_type,
        track_number = res$item$track_number,
        track_duration_ms = res$item$duration_ms,
        track_popularity = res$item$popularity,
        explicit = res$item$explicit,
        album_release_date = ifelse(!is.null(res$item$album$release_date), res$item$album$release_date, NA),
        album_img = res$item$album$images[[1]]$url,
        track_uri = res$item$id,
        artist_uri = res$item$artists[[1]]$id,
        album_uri = res$item$album$id,
        track_preview_url = ifelse(!is.null(res$item$preview_url), res$item$preview_url, NA),
        track_spotify_url = res$item$external_urls$spotify
    )

}

#' Get recently played tracks for current user
#'
#' Get recently played tracks for current user
#' @param limit Integer indicating the number of tracks to return. Default: 50. Minimum: 1. Maximum: 50
#' @param after A Unix timestamp in milliseconds. Returns all items after (but not including) this cursor position. If after is specified, before must not be specified.
#' @param before A Unix timestamp in milliseconds. Returns all items before (but not including) this cursor position. If before is specified, after must not be specified.
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_my_recently_played()
#' }

get_my_recently_played <- function(limit = 50, auth_code = get_spotify_authorization_code()) {

    res <- GET('https://api.spotify.com/v1/me/player/recently-played', config(token = auth_code), query = list(limit = limit)) %>% content %>% .$items

    map_df(1:length(res), function(i) {
        this_track <- res[[i]]
        list(
            track_name = this_track$track$name,
            artist_name = this_track$track$artists[[1]]$name,
            album_name = this_track$track$album$name,
            played_at_utc = as_datetime(this_track$played_at),
            context_type = ifelse(!is.null(this_track$context$type), this_track$context$type, NA),
            context_uri = ifelse(!is.null(this_track$context$uri), this_track$context$uri, NA),
            context_spotify_url = ifelse(!is.null(this_track$context$external_urls$spotify), this_track$context$external_urls$spotify, NA),
            album_type = this_track$track$album$album_type,
            track_number = this_track$track$track_number[[1]],
            track_popularity = this_track$track$popularity,
            explicit = this_track$track$explicit,
            album_release_date = ifelse(!is.null(this_track$track$album$release_date), this_track$track$album$release_date, NA),
            album_img = this_track$track$album$images[[1]]$url,
            track_uri = this_track$track$id,
            artist_uri = this_track$track$artists[[1]]$id,
            album_uri = this_track$track$album$id,
            track_preview_url = ifelse(!is.null(this_track$track$preview_url), this_track$track$preview_url, NA),
            track_spotify_url = this_track$track$external_urls$spotify
        )
    })

}

#' Get top artists for Current User
#'
#' Get top artists for current user
#' @param time_range String indicating the time frame over which the affinities are computed. Valid values: long_term (calculated from several years of data and including all new data as it becomes available), medium_term (approximately last 6 months), short_term (approximately last 4 weeks). Default: medium_term.
#' @param limit Integer indicating the number of entities to return. Default: 50. Minimum: 1. Maximum: 50
#' @param offset Integer indicating the index of the first entity to return. Default: 0 (i.e., the first artist). Use with limit to get the next set of entities.
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_my_top_artists()
#' }

get_my_top_artists <- function(time_range = 'medium_term', limit = 50, offset = 0, auth_code = get_spotify_authorization_code()) {

    res <- GET('https://api.spotify.com/v1/me/top/artists', config(token = auth_code), query = list(limit = limit, offset = offset, time_range = time_range)) %>% content %>% .$items

    map_df(1:length(res), function(i) {
        this_artist <- res[[i]]
        list(
            artist_name = this_artist$name,
            artist_uri = this_artist$id,
            artist_img = ifelse(length(this_artist$images) > 0, this_artist$images[[1]]$url, NA),
            artist_genres = list(unlist(this_artist$genres)),
            artist_popularity = this_artist$popularity,
            artist_num_followers = this_artist$followers$total,
            artist_spotify_url = this_artist$external_urls$spotify
        )
    })
}

#' Get Top tracks for Current User
#'
#' Get top tracks for current user
#' @param time_range String indicating the time frame over which the affinities are computed. Valid values: long_term (calculated from several years of data and including all new data as it becomes available), medium_term (approximately last 6 months), short_term (approximately last 4 weeks). Default: medium_term.
#' @param limit Integer indicating the number of entities to return. Default: 50. Minimum: 1. Maximum: 50
#' @param offset Integer indicating the index of the first entity to return. Default: 0 (i.e., the first track). Use with limit to get the next set of entities.
#' @param auth_code Authorization code with proper scopes. Calls get_spotify_authorization_code() by default.
#' @keywords auth
#' @export
#' @examples
#' \dontrun{
#' get_my_top_tracks()
#' }

get_my_top_tracks <- function(time_range = 'medium_term', limit = 50, offset = 0, auth_code = get_spotify_authorization_code()) {

    res <- GET('https://api.spotify.com/v1/me/top/tracks', config(token = auth_code), query = list(limit = limit, offset = offset, time_range = time_range)) %>% content %>% .$items

    map_df(1:length(res), function(i) {
        this_track <- res[[i]]
        list(
            track_name = this_track$name,
            artist_name = this_track$artists[[1]]$name,
            album_name = this_track$album$name,
            album_type = this_track$album$album_type,
            track_number = this_track$track_number[[1]],
            track_popularity = this_track$popularity,
            explicit = this_track$explicit,
            album_release_date = this_track$album$release_date,
            album_img = this_track$album$images[[1]]$url,
            track_uri = this_track$id,
            artist_uri = this_track$artists[[1]]$id,
            album_uri = this_track$album$id,
            track_preview_url = ifelse(!is.null(this_track$preview_url), this_track$preview_url, NA),
            track_spotify_url = this_track$external_urls$spotify
        )
    })
}
