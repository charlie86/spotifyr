#' Get Artist Albums
#'
#' This function returns an artist's discography on Spotify
#' @param artist_name String of artist name
#' @param artist_uri String of Spotify artist URI. Will only be applied if \code{use_arist_uri} is set to \code{TRUE}. This is useful for pulling artists in bulk and allows for more accurate matching since Spotify URIs are unique.
#' @param use_artist_uri Boolean determining whether to search by Spotify URI instead of an artist name. If \code{TRUE}, you must also enter an \code{artist_uri}. Defaults to \code{FALSE}.
#' @param studio_albums_only Logical for whether to remove album types "single" and "compilation" and albums with mulitple artists. Defaults to \code{TRUE}
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords albums
#' @export
#' @examples
#' \dontrun{
#' albums <- get_artist_albums('radiohead')
#' }

get_artist_albums <- function(artist_name = NULL, artist_uri = NULL, use_artist_uri = FALSE, return_closest_artist = TRUE, message = FALSE, studio_albums_only = TRUE, access_token = get_spotify_access_token()) {

    # artist_name = 'run the jewels'
    # artist_uri = NULL
    # use_artist_uri = FALSE
    # return_closest_artist = TRUE
    # message = FALSE
    # studio_albums_only = FALSE
    # access_token = get_spotify_access_token()

    if (use_artist_uri == FALSE) {

        if (is.null(artist_name)) {
            stop('You must enter an artist name if use_artist_uri == FALSE.')
        }

        artists <- get_artists(artist_name, access_token = access_token)

        if (nrow(artists) > 0) {
            if (return_closest_artist == TRUE) {

                exact_matches <- artists$artist_name[tolower(artists$artist_name) == tolower(artist_name)]

                if (length(exact_matches) > 0) {
                    selected_artist <- exact_matches[1]
                } else {
                    selected_artist <- artists$artist_name[1]
                }

                if (message) {
                    message(paste0('Selecting artist "', selected_artist, '"', '. Choose return_closest_artist = FALSE to interactively choose from all the artist matches on Spotify.'))
                }
            } else {
                cat(paste0('We found the following artists on Spotify matching "', artist_name, '":\n\n\t', paste(artists$artist_name, collapse = "\n\t"), '\n\nPlease type the name of the artist you would like:'), sep  = '')
                selected_artist <- readline()
            }

            artist_uri <- artists$artist_uri[artists$artist_name == selected_artist]
        } else {
            stop(paste0('Cannot find any artists on Spotify matching "', artist_name, '"'))
        }
    } else {
        if (!is.null(artist_uri)) {
            artist_uri <- artist_uri
        } else {
            stop('You must enter an artist_uri if use_artist_uri == TRUE.')
        }
    }

    album_check <- RETRY('GET', url = paste0('https://api.spotify.com/v1/artists/', artist_uri,'/albums'), query = list(limit = 50, access_token = access_token), quiet = TRUE, times = 10) %>% content

    album_count <- album_check$total
    num_loops <- ceiling(album_count / 50)
    offset <- 0

    map_df(1:ceiling(num_loops), function(this_loop) {

        albums <- RETRY('GET', url = paste0('https://api.spotify.com/v1/artists/', artist_uri, '/albums'), query = list(limit = 50, access_token = access_token, offset = offset), quiet = TRUE, times = 10) %>% content

        df <- map_df(1:length(albums$items), function(this_row) {

            this_album <- albums$items[[this_row]]

            is_collaboration <- gsub('spotify:artist:', '', this_album$artists[[1]]$uri) != artist_uri | length(this_album$artists) > 1

            if (studio_albums_only & (is_collaboration | this_album$album_type != 'album')) {
                df <- tibble()
            } else {
                res <- RETRY('GET', url = paste0('https://api.spotify.com/v1/albums/', this_album$uri %>% gsub('spotify:album:', '', .)), query = list(access_token = access_token), quiet = TRUE, times = 10) %>% content

                df <- tibble(artist_name = this_album$artists[[1]]$name,
                             artist_uri = this_album$artists[[1]]$id,
                             album_uri = this_album$uri %>% gsub('spotify:album:', '', .),
                             album_name = gsub('\'', '', this_album$name),
                             album_img = ifelse(length(this_album$images) > 0, this_album$images[[1]]$url, NA),
                             album_type = this_album$album_type,
                             is_collaboration = is_collaboration) %>%
                    mutate(album_release_date = res$release_date,
                           album_release_year = as.Date(ifelse(nchar(album_release_date) == 4, as.Date(paste0(year(as.Date(album_release_date, '%Y')), '-01-01')), as.Date(album_release_date, '%Y-%m-%d')), origin = '1970-01-01'))
            }

        })

        if (nrow(df) > 0 & studio_albums_only) {
            df <- df %>% dplyr::filter(!duplicated(tolower(album_name))) %>%
                mutate(base_album_name = gsub(' \\(.*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*\\)', '', tolower(album_name)),
                       base_album_name = gsub(' \\[.*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*\\]', '', base_album_name),
                       base_album_name = gsub(':.*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*', '', base_album_name),
                       base_album_name = gsub(' - .*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*', '', base_album_name),
                       base_album = tolower(album_name) == base_album_name) %>%
                group_by(base_album_name) %>%
                dplyr::filter((album_release_year == min(album_release_year)) | base_album) %>%
                mutate(num_albums = n(),
                       num_base_albums = sum(base_album)) %>%
                dplyr::filter((base_album == 1) |((num_base_albums == 0 | num_base_albums > 1) & row_number() == 1)) %>%
                ungroup %>%
                arrange(album_release_year) %>%
                mutate(album_rank = row_number()) %>%
                select(-c(base_album_name, base_album, num_albums, num_base_albums, album_rank))
        }
        offset <<- offset + 50

        df %>%
            group_by(album_name_lower = tolower(album_name), artist_uri, is_collaboration, album_type) %>%
            slice(1) %>%
            ungroup %>%
            select(-album_name_lower)
    })
}
