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
