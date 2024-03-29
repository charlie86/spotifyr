% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/browse.R
\name{get_categories}
\alias{get_categories}
\title{Get a list of Spotify categories}
\usage{
get_categories(authorization = get_spotify_access_token(), df = TRUE)
}
\arguments{
\item{authorization}{Required. A valid access token from the Spotify Accounts service.
See the \href{https://developer.spotify.com/documentation/general/guides/authorization-guide/}{Web API authorization Guide} for more details.
Defaults to \code{spotifyr::get_spotify_access_token()}}

\item{df}{Should the results be formatted as a data frame?
If \code{FALSE}, the full response JSON will be returned as a list; defaults to
\code{TRUE}.}
}
\value{
Returns a data frame of results containing album data.
See \url{https://developer.spotify.com/documentation/web-api/reference/browse/get-list-categories/} for more information.
}
\description{
Get a list of Spotify categories
}
