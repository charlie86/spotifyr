#' Assertion for Correct API Requests.
#'
#' Assertions are made to give early and precise error messages for wrong
#' API call parameters.
#'
#' These assertions are called from various wrapper functions.  However, you can also call this
#' function directly to make sure that you are adding (programatically) the correct
#' parameters to a call.
#'
#' All \code{\link{validate_parameters}} parameters default to \code{NULL}.
#' Asserts the correct parameter values for any values that are not \code{NULL}.
#'
#' @param artist_or_user "The type parameter must be either 'artist' or 'user'."
#' @param artists_or_tracks The type parameter must be either 'artists' or 'tracks'."
#' @param limit Optional. The maximum number of items to return.
#' Default to \code{20}. Minimum: 1. Maximum: 50.
#' @param offset Optional. The index of the first item to return.
#' Defaults to \code{0}, i.e., the first object.
#' Use with \code{limit} to get the next set of items.
#' @param position_ms The 'position_ms' parameter must be an integer value that is greater than 0.
#' @param country Optional. \cr
#' An \href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code} or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param locale Optional. The desired language, consisting of an
#' \href{https://en.wikipedia.org/wiki/ISO_639-1}{ISO 639-1} language code and
#' an \href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code}, joined by an underscore. For example: \code{es_MX}, meaning "Spanish (Mexico)". Provide this parameter if you want the category strings returned in a particular language. Note that, if \code{locale} is not supplied, or if the specified language is not available, the category strings returned will be in the Spotify default language (American English). The \code{locale} parameter,
#' combined with the \code{country} parameter, may give odd results if not carefully matched.
#' For example \code{country=SE&locale=de_DE} will return a list of categories relevant to Sweden
#' but as German language strings.
#' @param market Optional. \cr
#' An \href{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}{ISO 3166-1 alpha-2 country code} or the string \code{"from_token"}. Provide this parameter if you want to apply \href{https://developer.spotify.com/documentation/general/guides/track-relinking-guide/}{Track Relinking}
#' @param time_range Optional. Over what time frame the affinities are computed.
#' Valid values: long_term (calculated from several years of data and including all new data
#' as it becomes available), \code{medium_term} (approximately last 6 months),
#' \code{short_term} (approximately last 4 weeks). Default: \code{medium_term}.
#' @param position_ms Optional. Integer indicating from what position to start playback. Must be a positive number. Passing in a position that is greater than the length of the track will cause the player to start playing the next song.
#' @param volume_percent Required integer value. The volume to set.
#'  Must be a value from 0 to 100 inclusive. Defaults to \code{50}.
#' @param include_meta_info Optional. Boolean indicating whether to include full result,
#'  with meta information such as \code{"total"}, and \code{"limit"}. Defaults to \code{FALSE}.
#' @importFrom stringr str_detect
#' @param state The state parameter must be exactly one of \code{'track'},
#' \code{'context'} or  \code{'off'}.
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @export

validate_parameters <- function(artists_or_tracks = NULL,
                                artist_or_user = NULL,
                                market = NULL,
                                country = NULL,
                                limit = NULL,
                                offset = NULL,
                                locale = NULL,
                                volume_percent = NULL,
                                time_range = NULL,
                                position_ms = NULL,
                                state = NULL,
                                include_meta_info = NULL) {

    if(!is.null(artist_or_user)) validate_type_artist_or_user(artist_or_user)
    if(!is.null(artists_or_tracks)) validate_type_artists_or_tracks(artists_or_tracks)
    if(!is.null(limit)) validate_limit(limit)
    if(!is.null(offset)) validate_offset(offset)
    if(!is.null(market)) validate_market(market)
    if(!is.null(country)) validate_country(country)
    if(!is.null(locale)) validate_locale(locale)
    if(!is.null(time_range)) validate_time_range(time_range)
    if(!is.null(state)) validate_state(state)
    if(!is.null(position_ms)) validate_position_ms(position_ms)
    if(!is.null(include_meta_info)) validate_include_meta_info(include_meta_info)
}

#' Validate type paramter for 'artists' or 'user'.
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_type_artist_or_user <- function (artist_or_user) {

     assertthat::assert_that(
        artist_or_user %in% c("artist", "user"),
        msg = "The type parameter must be either 'artists' or 'user'."
    )

}

#' Validate type paramter for 'artists' or 'tracks'
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_type_artists_or_tracks <- function (artists_or_tracks) {

    assertthat::assert_that(
        artists_or_tracks %in% c("artists", "tracks"),
        msg = "The type parameter must be either 'artists' or 'tracks'."
    )

}

#' Validate limit parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_limit <- function(limit) {

    assertthat::assert_that(
        is.numeric(limit),
        msg = "The 'limit' parameter must be an integer value in the range of 1..50."
    )

    assertthat::assert_that(
        limit>=1 & limit <=50 & limit%%1 ==0,
        msg = "The 'limit' parameter must be an integer value in the range of 1..50."
    )
}

#' Validate offset parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_offset <- function(offset) {

    assertthat::assert_that(
        is.numeric(offset) & length(offset) == 1,
        msg = "The 'offset' parameter must be an integer value in the range of 1..50."
    )

    assertthat::assert_that(
        offset>=0 & offset <=10000 & offset%%1 ==0,
        msg = "The 'offset' parameter must be an integer value in the range of 1..10000."
    )
}

#' validate position_ms parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_position_ms <- function(position_ms) {

    assertthat::assert_that(
        is.numeric(position_ms),
        msg = "The 'position_ms' parameter must be an integer value that is greater than 0."
    )

    assertthat::assert_that(
        position_ms> 0 & position_ms <=10000 & position_ms%%1 ==0,
        msg = "The 'position_ms' parameter must be an integer value that is greater than 0."
    )
}

#' validate time_range parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_time_range <- function(time_range) {

    assertthat::assert_that(
        is.character(time_range) & length(time_range) == 1,
        msg = "The 'time_range' parameter must be one of short_term', 'medium_term', 'long_term'."
    )

    assertthat::assert_that(
        time_range %in% c('short_term', 'medium_term', 'long_term'),
        msg = "The 'time_range' parameter must be one of short_term', 'medium_term', 'long_term'."
    )
}

#' Validate volume percent parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_volume_percent <- function(volume_percent) {

    assertthat::assert_that(
        is.numeric(volume_percent) & length(volume_percent) == 1,
        msg = "The parameter 'volume_percent' must be a single integer value in the range  0,1,2...100."
    )

    assertthat::assert_that(
        volume_percent %in% seq(0, 100),
        msg = "The parameter 'volume_percent' must be a single integer value in the range  0,1,2...100."
    )

}

#' validate state parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_state <- function(state) {

    assertthat::assert_that(
        is.character(state) & length(state) == 1,
        msg = "The state parameter must be exactly one of 'track', 'context' or 'off'."
    )

    assertthat::assert_that(
        state %in% c('track', 'context', 'off'),
        msg = "The state parameter must be exactly one of 'track', 'context' or 'off'."
    )
}

#' Validate market parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_market <- function(market) {

    assertthat::assert_that(
        str_detect(market, '^[[:alpha:]]{2}$'),
        msg = '"market" must be an ISO 3166-1 alpha-2 country code'
        )
}


#' Validate country parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_country <- function(country) {

    assertthat::assert_that(
        str_detect(country, '^[[:alpha:]]{2}$'),
        msg = '"country" must be an ISO 3166-1 alpha-2 country code.'
    )
}

#' Validate locale parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_locale <- function(locale) {
    assertthat::assert_that(
        is.character(locale) & nchar(locale) <= 5,
        msg = "The parameter 'locale' must be an ISO_639-1 code as a character variable."
    )
}

#' Validate include_meta_info parameter
#'
#' @inheritParams validate_parameters
#' @return A boolean if the parameter matches the Spotify Web API parameter range.
#' @keywords internal
validate_include_meta_info <- function(include_meta_info) {
    assertthat::assert_that(
        is.logical(include_meta_info) & nchar(include_meta_info) <= 5,
        msg = "The parameter 'include_meta_info' must be a single boolean, logical value of TRUE or FALSE."
    )
}

