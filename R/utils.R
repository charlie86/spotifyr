#' Check if a string matches the pattern of a Spotify URI
#'
#' Check if a string matches the pattern of a Spotify URI
#' @param s String to check
#' @importFrom stringr str_detect
#' @return A boolean if the provided URI matches the Spotify URI criteria.
#' @keywords internal

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
#' @keywords internal
#' @return A character vector of the pitch class names
pitch_class_lookup <- c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')

#' Verify API Result
#'
#' Check API result for error codes.
#'
#' @param res API result ot check
#' @keywords internal
#' @return A meaningful error message if communication with the Spotify Web API was not
#' successful.

verify_result <- function(res) {
    if (!is.null(res$error)) {
        stop(str_glue('{res$error$message} ({res$error$status})'))
    }
}

#' Valid Authorization Scopes
#'
#' A vector of valid scopes for \code{\link{get_spotify_authorization_code}}.
#'
#' @family authorization functions
#' @param exclude_SOA Boolean indicating whether to exclude 'Spotify Open Access' (SOA) scopes, which are only available for approved partners. Defaults to \code{TRUE}.
#' @examples
#' scopes()
#' @return A character vector of valid authorization scopes for the Spotify Web API.
#' See \href{https://developer.spotify.com/documentation/general/guides/authorization/scopes/}{Spotify Web API Authorization Scopes}
#' @export
#' @importFrom xml2 read_html
#' @importFrom rvest html_text html_elements

scopes <- function(exclude_SOA = TRUE) {
    res <-
        xml2::read_html("https://developer.spotify.com/documentation/general/guides/authorization/scopes/") %>%
        rvest::html_elements('code') %>%
        rvest::html_text() %>%
        unique()
    if (exclude_SOA) res <- grep("soa", res, invert = TRUE, value = TRUE, fixed = TRUE)
    res
}

#' Remove duplicate album names
#'
#' Use fuzzy matching to remove duplicate album names (including reissues, remasters, etc).
#'
#' @param df Data frame with album name
#' @param album_name_col String of field name containing album names
#' @param album_release_year_col String of field name containing album release year
#' @importFrom dplyr case_when pull all_of everything slice row_number n
#' @importFrom tibble tibble
#' @return The original data frame with distinct \code{album_name} rows, keeping as much as
#' possible the original album release (and not re-releases.)
#' @export

dedupe_album_names <- function(df, album_name_col = 'album_name', album_release_year_col = 'album_release_year') {

    album_dupe_regex <- '(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo)'

    base_album_names <- df %>%
        dplyr::mutate(
          album_name_ = album_name_col,
          album_release_year_ = album_release_year_col
        ) %>%
        dplyr::filter(!duplicated(tolower(album_name_))) %>%
        dplyr::mutate(
          base_album_name = gsub(str_glue(' \\(.*{album_dupe_regex}.*\\)'), '', tolower(.data$album_name_)),
          base_album_name = gsub(str_glue(' \\[.*{album_dupe_regex}.*\\]'), '', .data$base_album_name),
          base_album_name = gsub(str_glue(':.*{album_dupe_regex}.*'), '', .data$base_album_name),
          base_album_name = gsub(str_glue(' - .*{album_dupe_regex}.*'), '', .data$base_album_name),
          base_album = tolower(.data$album_name_) == .data$base_album_name
        ) %>%
        dplyr::group_by(.data$base_album_name) %>%
        dplyr::filter((.data$album_release_year_ == min(.data$album_release_year_)) | base_album) %>%
        dplyr::mutate(num_albums = dplyr::n(),
               num_base_albums = sum(.data$base_album)) %>%
        dplyr::ungroup() %>%
        dplyr::filter((.data$base_album == 1) |((.data$num_base_albums == 0 | .data$num_base_albums > 1) & row_number() == 1)) %>%
        dplyr::pull(.data$album_name_)

    df %>%
        dplyr::mutate(album_name_ = album_name_col) %>%
        dplyr::filter(.data$album_name_ %in% base_album_names) %>%
        dplyr::select(-dplyr::all_of("album_name_"))
}

# Function for querying playlist API url
# This function is used for pagination in the playlist api
#' @importFrom httr RETRY
#' @importFrom jsonlite fromJSON
#' @keywords internal

query_playlist <- function(url, params) {

    res <- RETRY('GET', url, query = params, encode = 'json')
    httr::stop_for_status(res)

    res <- jsonlite::fromJSON(
      httr::content(res, as = 'text', encoding = 'UTF-8'),
      flatten = TRUE
    )

    res
}

# currently sourcing in make_clean_names rather than importing janitor entirely

