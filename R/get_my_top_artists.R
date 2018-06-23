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
