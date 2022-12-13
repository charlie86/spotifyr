#' Retrieve artist discography with song lyrics and audio info
#'
#' Retrieve the entire discography of an artist with the lyrics of each song and the
#' associated audio information. Returns the song data as a nested tibble
#' (see \code{tidyr::\link[tidyr]{nest}}).
#' This way we can easily see each album, artist, and song title before expanding our data.
#'
#' @param artist The quoted name of the artist. Spelling matters, capitalization does not.
#' @param albums A character vector of album names. Spelling matters, capitalization does not
#' @param authorization Authorization token for Spotify web API. Defaults to
#' \code{get_spotify_access_token()}
#' @examples
#' \donttest{
#' get_album_data(artist = "Wild child",
#'                albums = "Expectations")
#' }
#' @export
#' @importFrom tidyr nest unnest
#' @importFrom purrr possibly map_df
#' @importFrom dplyr mutate select filter left_join ungroup rename
#' @importFrom tibble as_tibble
#' @return A nested tibble. See \code{tidyr::\link[tidyr]{nest}}.
#' @family lyrics functions

get_album_data <- function(artist,
                           albums = character(),
                           authorization = get_spotify_access_token()
) {

    artist_disco <- get_artist_audio_features(
        artist,
        authorization = authorization
    ) %>%
        dplyr::filter(tolower(.data$album_name) %in% tolower(albums)) %>%
        dplyr::group_by(album_name) %>%
        dplyr::mutate(track_n = dplyr::row_number()) %>%
        dplyr::ungroup()

    artist_disco

}
