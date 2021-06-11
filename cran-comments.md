## Test environments
* local R installation, R 4.1.0 on Windows 10
* win-builder (devel, release)
* Fedora Linux, R-devel, clang, gfortran on rhub
* Ubuntu Linux 20.04.1 LTS, R-release, GCC on rhub

## R CMD check results

0 errors v | 0 warnings v | 0 notes v

## Resubmission

The following (possibly) invalid URLs:
* http://rr.sapo.pt/especial/112355/sente-se-triste-quando-ouve-amar-pelos-dois-nao-e-o-unico
* https://developer.spotify.com/documentation/general/guides/track-relinking-guide
were fixed. 

## Re-release of archived CRAN package

The package has been on CRAN for a very long time without changes, and eventually archived a short while ago, because it contained many deprecated dependencies, particularly ggjoy, which is no longer on CRAN. This is a long overdue minor release that fixes such issues without changing functionality.  This means fixing dozens of broken links, removing deprecated dependencies, and improving in many places non-standard evaluation to current best practices. 

Most examples are in \donttest{}. Per earlier CRAN policy \dontrun{} was allowed, and we changed them everywhere to \donttest{}. This is a necessity, because the the entire package is working with the Spotify Web API, which requires personal authentication from the developers, and in case of interaction with third parties, authentication from the third parties, too. These functions were tested with the maintainers personal access token, and the examples ran by devtools::run_examples(). As the package has a wide user base, we also received some issues that we used to fix issues.

We are looking into ways to include small replication data in the package's future versions for unit testing and examples, but this requires approval from Spotify Web API.
