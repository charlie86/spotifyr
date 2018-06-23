#' Get audio features from one or more tracks on Spotify
#'
#' This function returns audio features from a dataframe of tracks on Spotify
#' @param tracks Dataframe containing a column `track_uri`, corresponding to Spotify Album URIs. Can be output from spotifyr::get_album_tracks or spotifyr::get_playlist_tracks()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords track audio features
#' @export
#' @examples
#' \dontrun{
#' ##### Get tracks for all of Radiohead's albums
#' albums <- get_artist_albums('radiohead')
#' tracks <- get_album_tracks(albums)
#' radiohead_audio_features <- get_track_audio_features(tracks)
#'
#' ##### Get tracks for all of Barack Obama's playlists
#' playlists <- get_user_playlists('barackobama')
#' tracks <- get_playlist_tracks(playlists)
#' obama_audio_features <- get_track_audio_features(tracks)
#' }

get_track_audio_features <- function(tracks, access_token = get_spotify_access_token()) {

    audio_feature_vars <- c('danceability', 'energy', 'key', 'loudness', 'mode', 'speechiness', 'acousticness',
                            'instrumentalness', 'liveness', 'valence', 'tempo', 'duration_ms', 'time_signature')

    # create lookup to classify key: https://developer.spotify.com/web-api/get-audio-features/
    pitch_class_lookup <- c('C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B')

    num_loops <- ceiling(sum(!duplicated(tracks$track_uri)) / 100)

    track_audio_features <- map_df(1:num_loops, function(this_loop) {

        uris <- tracks %>%
            dplyr::filter(!duplicated(track_uri)) %>%
            slice(((this_loop * 100) - 99):(this_loop * 100)) %>%
            select(track_uri) %>%
            .[[1]] %>%
            paste0(collapse = ',')

        res <- RETRY('GET', url = str_glue('https://api.spotify.com/v1/audio-features/?ids={uris}'),
                     query = list(access_token = access_token), quiet = TRUE, times = 10) %>% content

        content <- res$audio_features

        # replace nulls with NA and convert to character
        content <- map(content, function(row) {
            map(row, function(element) {
                ifelse(is.null(element), as.character(NA), as.character(element))
            })
        })

        null_results <- which(map_int(content, length) == 0)
        if (length(null_results) > 0) {
            content <- content[-null_results]
        }

        audio_features_df <- unlist(content) %>%
            matrix(nrow = length(content), byrow = T) %>%
            as.data.frame(stringsAsFactors = F)
        names(audio_features_df) <- names(content[[1]])

        return(audio_features_df)

    }) %>% select(-c(type, uri, track_href, analysis_url)) %>%
        rename(track_uri = id) %>%
        mutate_at(audio_feature_vars, as.numeric) %>%
        mutate(key = pitch_class_lookup[key + 1],
               mode = case_when(mode == 1 ~ 'major',
                                mode == 0 ~ 'minor',
                                TRUE ~ as.character(NA)),
               key_mode = paste(key, mode))

    return(track_audio_features)
}
