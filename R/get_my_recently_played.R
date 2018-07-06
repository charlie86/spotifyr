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
