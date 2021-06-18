#' \code{spotifyr} package
#'
#' A Quick and Easy Wrapper for Pulling Track Audio Features from Spotify's Web API in Bulk
#'
#' See the README on
#' \href{https://github.com/charlie86/spotifyr#readme}{GitHub}
#'
#' @docType package
#' @name spotifyr
#' @importFrom purrr map map_df map2
#' @importFrom httr RETRY GET accept_json authenticate config content oauth2.0_token oauth_app oauth_endpoint stop_for_status
#' @importFrom rvest html_session html_node html_nodes html_text html_attr
#' @importFrom tibble tribble
#' @importFrom readr read_lines
#' @importFrom stringr str_glue str_detect str_replace_all
#' @importFrom jsonlite fromJSON toJSON
#' @importFrom lubridate year as_datetime
#' @importFrom utils setTxtProgressBar txtProgressBar str
#' @section artist functions:
#' Retrieve information related to artists.
#' \code{\link{get_artist}}: Get the data of a single artist.\cr
#' \code{\link{get_artists}}: Get the data of multiple artist.\cr
#' \code{\link{get_related_artists}}: Get that of related artist to an original artist.\cr
#' \code{\link{get_artist_albums}}: Get artists who appear on an album.\cr
#' @section track functions:
#' Retrieve information related to individual song recordings (songs, concerts).
#' \code{\link{get_track}} \cr
#' \code{\link{get_tracks}} \cr
#' \code{\link{get_playlist_tracks}} \cr
#' @section album functions:
#' Retrieve information about albums.
#' See also \code{\link{get_album_tracks}}.
#' @section playlist functions:
#' Work with playlists.\cr
#' \code{\link{add_tracks_to_playlist}} \cr
#' \code{\link{change_playlist_details}} \cr
#' \code{\link{get_user_playlists}} \cr
#' @section player functions:
#' Interact with the user's devices and players.
#' @section personalization functions:
#' \code{\link{get_my_top_artists_or_tracks}}
#' @section musicology functions:
#' Functions related to the contents of the music.\cr
#' \code{\link{get_track_audio_analysis}} \cr
#' \code{\link{get_artist_audio_features}} \cr
#' \code{\link{get_playlist_audio_features}} \cr
#' \code{\link{get_user_audio_features}}\cr
#' \code{\link{get_genre_artists}} \cr
#' @section lyrics functions:
#' Functions related to the lyrics of the music, such as \cr
#' \code{\link{get_discography}}.
#' @section search functions:
#' Search for an artist, song or other keyword.\cr
#' The main function is \code{\link{search_spotify}}.
#' @section authentication functions:
#' Helper functions to provide authentication function for requests.
#' Never reveal in public documents, markdown files the returned values of these
#' functions: \cr
#' \code{\link{get_spotify_authorization_code}} \cr
#' \code{\link{get_spotify_access_token}}.
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
"id",
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
"added_at",
"artist_names",
"artists",
"available_markets",
"duration_ms",
"genius_album",
"popularity",
"str",
"track_number",
".")

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(globalVars)
