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
#' @import stringdist
#' @importFrom lubridate year
#' @importFrom utils setTxtProgressBar txtProgressBar
NULL

globalVars <- c("album_name",
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
".")

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(globalVars)
