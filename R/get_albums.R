#' Get Albums
#'
#' This function returns an artist's discography on Spotify
#' @param artist_uri String identifier for an artist on Spotify. Can be found within the Spotify app or with spotifyr::get_artists()
#' @param access_token Spotify Web API token. Defaults to spotifyr::get_spotify_access_token()
#' @keywords albums
#' @export
#' @examples
#' artists <- get_artists('radiohead')
#' albums <- get_albums(artists$artist_uri[1])

get_albums <- function(artist_uri, access_token = get_spotify_access_token()) {

    albums <- GET(paste0('https://api.spotify.com/v1/artists/', artist_uri,'/albums'), query = list(limit = 50, access_token = access_token)) %>% content

    if (!is.null(albums$error)) {
        stop(paste0(albums$error$message, ' (', albums$error$status, ')'))
    }

    df <- map_df(1:length(albums$items), function(this_row) {

        this_album <- albums$items[[this_row]]

        # Make sure the album_type is not "single"
        if (this_album$album_type == 'album' & gsub('spotify:artist:', '', this_album$artists[[1]]$uri) == artist_uri) {

            res <- GET(paste0('https://api.spotify.com/v1/albums/', this_album$uri %>% gsub('spotify:album:', '', .)), query = list(access_token = access_token)) %>% content

            if (!is.null(res$error)) {
                stop(paste0(res$error$message, ' (', res$error$status, ')'))
            }


            data.frame(album_uri = this_album$uri %>% gsub('spotify:album:', '', .),
                       album_name = gsub('\'', '', this_album$name),
                       album_img = ifelse(length(this_album$images) > 0, this_album$images[[1]]$url, NA),
                       stringsAsFactors = F) %>%
                mutate(album_release_date = res$release_date,
                       album_release_year = as.Date(ifelse(nchar(album_release_date) == 4, as.Date(paste0(year(as.Date(album_release_date, '%Y')), '-01-01')), as.Date(album_release_date, '%Y-%m-%d')), origin = '1970-01-01')
                )
        } else {
            NULL
        }

    })

    if (nrow(df) > 0) {
        df <- df %>% filter(!duplicated(tolower(album_name))) %>%
            mutate(base_album_name = gsub(' \\(.*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*\\)', '', tolower(album_name)),
                   base_album_name = gsub(' \\[.*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*\\]', '', base_album_name),
                   base_album_name = gsub(':.*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*', '', base_album_name),
                   base_album_name = gsub(' - .*(deluxe|international|anniversary|version|edition|remaster|re-master|live|mono|stereo).*', '', base_album_name)) %>%
            group_by(base_album_name) %>%
            filter(album_release_year == min(album_release_year)) %>%
            mutate(base_album = tolower(album_name) == base_album_name,
                   num_albums = n(),
                   num_base_albums = sum(base_album)) %>%
            filter((num_base_albums == 1 & base_album == 1) | ((num_base_albums == 0 | num_base_albums > 1) & row_number() == 1)) %>%
            ungroup %>%
            arrange(album_release_year) %>%
            mutate(album_rank = row_number())
    }

    return(df)
}
