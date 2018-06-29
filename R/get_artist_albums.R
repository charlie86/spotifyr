#' Get Artist Albums
#'
#' This function returns an artist's discography on Spotify
#' @param artist String of artist name or Spotify artist URI
#' @param album_types Character vector of album types to include. Valid values are "album", "single", "appears_on", and "compilation". Defaults to "album".
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @param parallelize Boolean determining to run in parallel or not. Defaults to \code{FALSE}.
#' @param future_plan String determining how `future()`s are resolved when `parallelize == TRUE`. Defaults to \code{multiprocess}.
#' @keywords albums
#' @export
#' @examples
#' \dontrun{
#' albums <- get_artist_albums('radiohead')
#' }

get_artist_albums <- function(artist = NULL, album_types = 'album', return_closest_artist = TRUE, access_token = get_spotify_access_token(), parallelize = FALSE, future_plan = 'multiprocess') {

    is_uri <- function(x) {
        nchar(x) == 22 &
            !str_detect(x, ' ') &
            str_detect(x, '[[:digit:]]') &
            str_detect(x, '[[:lower:]]') &
            str_detect(x, '[[:upper:]]')
    }

    if (is.null(artist)) {
        stop('You must enter an artist name or URI.')
    }

    if (is_uri(artist)) {
        artist_uri <- artist
    } else {

        artists <- get_artists(artist, access_token = access_token)

        if (nrow(artists) > 0) {
            if (return_closest_artist == TRUE) {

                exact_matches <- artists$artist_name[tolower(artists$artist_name) == tolower(artist)]

                if (length(exact_matches) > 0) {
                    selected_artist <- exact_matches[1]
                } else {
                    selected_artist <- artists$artist_name[1]
                }

            } else {
                cat(str_glue('We found the following artists on Spotify matching "{artist}":\n\n\t{paste(artists$artist_name, collapse = "\n\t")}\n\nPlease type the name of the artist you would like:'), sep  = '')
                selected_artist <- readline()
            }

            artist_uri <- artists$artist_uri[artists$artist_name == selected_artist]
        } else {
            stop(str_glue('Cannot find any artists on Spotify matching "{artist}"'))
        }
    }

    album_check <- RETRY('GET', url = str_glue('https://api.spotify.com/v1/artists/{artist_uri}/albums'), query = list(limit = 50, access_token = access_token, include_groups = paste0(album_types, collapse = ',')), quiet = TRUE, times = 10) %>% content

    album_count <- album_check$total
    num_loops <- ceiling(album_count / 50)
    offset <- 0

    if (parallelize) {
        og_plan <- plan()
        on.exit(plan(og_plan), add = TRUE)
        plan(future_plan)
        map_function <- 'future_map_dfr'
    } else {
        map_function <- 'map_df'
    }

    map_df(1:ceiling(num_loops), function(this_loop) {

        albums <- RETRY('GET', url = str_glue('https://api.spotify.com/v1/artists/{artist_uri}/albums'), query = list(limit = 50, access_token = access_token, include_groups = paste0(album_types, collapse = ','), offset = offset), quiet = TRUE, times = 10) %>% content

        map_args <- list(
            1:length(albums$items),
            function(this_row) {
                this_album <- albums$items[[this_row]]
                is_collaboration <- gsub('spotify:artist:', '', this_album$artists[[1]]$uri) != artist_uri | length(this_album$artists) > 1
                res <- RETRY('GET', url = str_glue('https://api.spotify.com/v1/albums/{gsub("spotify:album:", "", this_album$uri)}'), query = list(access_token = access_token), quiet = TRUE, times = 10) %>% content

                tibble(artist_name = this_album$artists[[1]]$name,
                       artist_uri = this_album$artists[[1]]$id,
                       album_uri = this_album$uri %>% gsub('spotify:album:', '', .),
                       album_name = gsub('\'', '', this_album$name),
                       album_img = ifelse(length(this_album$images) > 0, this_album$images[[1]]$url, NA),
                       album_type = this_album$album_type,
                       is_collaboration = is_collaboration) %>%
                    mutate(album_release_date = res$release_date,
                           album_release_year = as.Date(ifelse(nchar(album_release_date) == 4, as.Date(str_glue('{year(as.Date(album_release_date, "%Y"))}-01-01')), as.Date(album_release_date, '%Y-%m-%d')), origin = '1970-01-01'))

            }
        )

        if (parallelize) {
            map_args <- c(map_args, .progress = TRUE)
        }

        df <- do.call(map_function, map_args)

        if (nrow(df) > 0) {
            df <- df %>%
                dplyr::filter(!duplicated(tolower(album_name))) %>%
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
                select(-c(base_album_name, base_album, num_albums, num_base_albums, album_rank)) %>%
                group_by(album_name_lower = tolower(album_name), artist_uri, is_collaboration, album_type) %>%
                slice(1) %>%
                ungroup %>%
                select(-album_name_lower)
        }
        offset <<- offset + 50
        return(df)
    })
}
