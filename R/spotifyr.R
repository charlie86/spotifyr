#' \code{spotifyr} package
#'
#' A Quick and Easy Wrapper for Pulling Track Audio Features from Spotify's Web API in Bulk
#'
#' See the README on
#' \href{https://github.com/charlie86/spotifyr#readme}{GitHub}
#'
#' @docType package
#' @name spotifyr
#' @import purrr
#' @import dplyr
#' @import tidyr
#' @import httr
#' @import furrr
#' @import stringr
#' @import future
#' @importFrom rvest html_session html_node html_nodes html_text html_attr
#' @importFrom readr read_lines
#' @importFrom lubridate year as_datetime
#' @importFrom utils setTxtProgressBar txtProgressBar
NULL

globalVars <- c(
"album_name",
"album_rank",
"album_release_date",
"album_release_year",
"album_uri",
"analysis_url",
"base_album",
"base_album_name",
"key",
"num_albums",
"num_base_albums",
"playlist_img",
"playlist_name",
"playlist_uri",
"track_href",
"track_uri",
"type",
"uri",
"album_name_lower",
"album_type",
"data",
"future_map_df",
"is_collaboration",
"lyrics",
"na.omit",
"parse_playlist_to_df",
"selected_artist",
"track_n",
"track_title",
"track_url",
".")

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(globalVars)
