#' \code{spotifyr} package
#'
#' A Quick and Easy Wrapper for Pulling Track Audio Features from Spotify's Web API in Bulk
#'
#' See the README on
#' \href{https://github.com/charlie86/spotifyr#readme}{GitHub}
#'
#' @docType package
#' @name spotifyr
#' @import genius
#' @importFrom purrr map map_df map2
#' @importFrom httr RETRY GET accept_json authenticate config content oauth2.0_token oauth_app oauth_endpoint stop_for_status
#' @importFrom rvest html_session html_node html_nodes html_text html_attr
#' @importFrom tibble tribble
#' @importFrom readr read_lines
#' @importFrom stringr str_glue str_detect str_replace_all
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom lubridate year as_datetime
#' @importFrom utils setTxtProgressBar txtProgressBar
NULL

globalVars <- c(
"album_name",
"album_name_",
"album_release_year_",
"album_rank",
"album_release_date",
"album_release_year",
"album_uri",
"analysis_url",
"base_album",
"base_album_name",
"key",
"name",
"num_albums",
"num_base_albums",
"playlist_img",
"playlist_name",
"playlist_uri",
"preview_url",
"href",
"album_id",
"images",
"release_date",
"release_date_precision",
"track_href",
"track_uri",
"type",
"uri",
"album_name_lower",
"album_type",
"possible_album",
"possible_lyrics",
"disco_audio_feats",
"data",
"future_map_df",
"map_chr",
"is_collaboration",
"key_name",
"mode_name",
"lyrics",
"na.omit",
"parse_playlist_to_df",
"release_date",
"selected_artist",
"track_n",
"track_title",
"track_url",
"volume",
"primary_color",
"track_id",
"track.id",
"playlist_id",
"playlist_owner_name",
"playlist_owner_id",
".")

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(globalVars)
