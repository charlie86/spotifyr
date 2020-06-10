#' Check if a string matches the pattern of a Spotify URI
#'
#' Check if a string matches the pattern of a Spotify URI
#' @param s String to check
#' @export
is_uri <- function(s) {
    nchar(s) == 22 &
        !str_detect(s, ' ') &
        str_detect(s, '[[:digit:]]') &
        str_detect(s, '[[:lower:]]') &
        str_detect(s, '[[:upper:]]')
}

#' Pitch class notation lookup
#'
# Create lookup to classify key: https://developer.spotify.com/web-api/get-audio-features/
#' @export
pitch_class_lookup <- c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')

#' Verify API result
#'
#' Check API result for error codes
#' @param res API result ot check
#' @export
verify_result <- function(res) {
    if (!is.null(res$error)) {
        stop(str_glue('{res$error$message} ({res$error$status})'))
    }
}

#' Valid scopes
#'
#' Vector of valid scopes for spotifyr::get_authorization_code()
#' @export
scopes <- xml2::read_html("https://developer.spotify.com/documentation/general/guides/scopes/") %>%
    html_nodes('code') %>%
    html_text() %>%
    unique()

#' Remove duplicate album names
#'
#' Use fuzzy matching to remove duplicate album names (including reissues, remasters, etc)
#' @param df Dataframe with album name
#' @param album_name_col String of field name containing album names
#' @param album_release_year_col String of field name containing album release year
#' @export
dedupe_album_names <- function(df, album_name_col = 'album_name', album_release_year_col = 'album_release_year') {

    album_dupe_regex <- '(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo)'

    base_album_names <- df %>%
        mutate_('album_name_' = album_name_col,
                'album_release_year_' = album_release_year_col) %>%
        dplyr::filter(!duplicated(tolower(album_name_))) %>%
        mutate(base_album_name = gsub(str_glue(' \\(.*{album_dupe_regex}.*\\)'), '', tolower(album_name_)),
               base_album_name = gsub(str_glue(' \\[.*{album_dupe_regex}.*\\]'), '', base_album_name),
               base_album_name = gsub(str_glue(':.*{album_dupe_regex}.*'), '', base_album_name),
               base_album_name = gsub(str_glue(' - .*{album_dupe_regex}.*'), '', base_album_name),
               base_album = tolower(album_name_) == base_album_name) %>%
        group_by(base_album_name) %>%
        dplyr::filter((album_release_year_ == min(album_release_year_)) | base_album) %>%
        mutate(num_albums = n(),
               num_base_albums = sum(base_album)) %>%
        ungroup() %>%
        dplyr::filter((base_album == 1) |((num_base_albums == 0 | num_base_albums > 1) & row_number() == 1)) %>%
        pull(album_name_)

    df %>%
        mutate_('album_name_' = album_name_col) %>%
        filter(album_name_ %in% base_album_names) %>%
        select(-album_name_)
}

# Function for querying playlist API url
# This function is used for pagination in the playlist api
query_playlist <- function(url, params) {
    res <- RETRY('GET', url, query = params, encode = 'json')
    stop_for_status(res)
    res <- fromJSON(content(res, as = 'text', encoding = 'UTF-8'), flatten = TRUE)
    res
}

# currently sourcing in make_clean_names rather than importing janitor entirely

