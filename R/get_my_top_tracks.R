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
