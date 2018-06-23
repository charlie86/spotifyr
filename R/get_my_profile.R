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
