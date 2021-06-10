## Test environments
* local R installation, R 4.1.0
* win-builder (devel)

## R CMD check results

## To reviewer

The package has been on CRAN for a very long time without changes, and eventually archived a short while ago, because it contained many deprecated dependencies, particularly ggjoy, which is no longer on CRAN. This is a long overdue minor release that fixes such issues without changing functionality.  This means fixing dozens of broken links, removing deprecated dependencies, and improving in many places non-standard evaluation to current best practices. 

Most examples are in \donttest{}. Per earlier CRAN policy \dontrun{} was allowed, and we changed them everywhere to \donttest{}. This is a necessity, because the the entire package is working with the Spotify Web API, which requires personal authentication from the developers, and in case of interaction with third parties, authentication from the third parties, too. These functions were tested with devtools::run_examples() with the maintainers personal access token.

We are looking into ways to include small replication data in the package's future versions for unit testing and examples, but this requires approval from Spotify Web API.
