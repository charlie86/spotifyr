
<!-- README.md is generated from README.Rmd. Please edit that file -->

# spotifyr

<!-- badges: start -->

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/spotifyr?color=brightgreen)](https://cran.r-project.org/package=spotifyr)
![](http://cranlogs.r-pkg.org/badges/spotifyr?color=brightgreen) [![CRAN
status](https://www.r-pkg.org/badges/version/spotifyr)](https://CRAN.R-project.org/package=spotifyr)
<!-- badges: end -->

## Overview

spotifyr is an R wrapper for pulling track audio features and other
information from Spotify’s Web API in bulk. By automatically batching
API requests, it allows you to enter an artist’s name and retrieve their
entire discography in seconds, along with Spotify’s audio features and
track/album popularity metrics. You can also pull song and playlist
information for a given Spotify User (including yourself!).

## Installation

CRAN version 2.1.0 (recommended)

``` r
install.packages('spotifyr')
```

Development version

``` r
devtools::install_github('charlie86/spotifyr')
```

## Authentication

First, set up a Dev account with Spotify to access their Web API
[here](https://developer.spotify.com/my-applications/#!/applications).
This will give you your `Client ID` and `Client Secret`. Once you have
those, you can pull your access token into R with
`get_spotify_access_token()`.

The easiest way to authenticate is to set your credentials to the System
Environment variables `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET`.
The default arguments to `get_spotify_access_token()` (and all other
functions in this package) will refer to those. Alternatively, you can
set them manually and make sure to explicitly refer to your access token
in each subsequent function call.

``` r
Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxxxxxxxxxxxxxxx')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxx')

access_token <- get_spotify_access_token()
```

#### Authorization Code Flow

For certain functions and applications, you’ll need to log in as a
Spotify user. To do this, your Spotify Developer application needs to
have a callback url. You can set this to whatever you want that will
work with your application, but a good default option is
`http://localhost:1410/` (see image below). For more information on
authorization, visit the offical [Spotify Developer
Guide](https://developer.spotify.com/documentation/general/guides/authorization-guide/).

<img src="man/figures/spotifyr_auth_screenshot.png" width="50%" />

## Usage

### What Was the Beatles’ Favorite Key?

``` r
library(spotifyr)
beatles <- get_artist_audio_features('the beatles')
```

``` r
library(dplyr)
library(purrr)
library(knitr)

beatles %>% 
    count(key_mode, sort = TRUE) %>% 
    head(5) %>% 
    kable()
```

| key\_mode |   n |
|:----------|----:|
| C major   | 104 |
| D major   |  98 |
| G major   |  82 |
| A major   |  76 |
| E major   |  62 |

### Get your most recently played tracks

``` r
library(lubridate)

get_my_recently_played(limit = 5) %>% 
    mutate(
        artist.name = map_chr(track.artists, function(x) x$name[1]),
        played_at = as_datetime(played_at)
        ) %>% 
    select(track.name, artist.name, track.album.name, played_at) %>% 
    kable()
```

| track.name           | artist.name                      | track.album.name                 | played\_at          |
|:---------------------|:---------------------------------|:---------------------------------|:--------------------|
| Deep In Love         | Bonny Light Horseman             | Bonny Light Horseman             | 2021-06-07 21:41:33 |
| Humbug Mountain Song | Fruit Bats                       | Absolute Loser                   | 2021-06-07 21:40:33 |
| Texas Sun            | Khruangbin                       | Texas Sun                        | 2021-06-07 21:37:28 |
| Dylan Thomas         | Better Oblivion Community Center | Better Oblivion Community Center | 2021-06-07 21:33:15 |
| Hot & Heavy          | Lucy Dacus                       | Hot & Heavy                      | 2021-06-07 21:29:38 |

### Find your all Time Favorite Artists

``` r
get_my_top_artists_or_tracks(type = 'artists', 
                             time_range = 'long_term', 
                             limit = 5) %>% 
    select(name, genres) %>% 
    rowwise %>% 
    mutate(genres = paste(genres, collapse = ', ')) %>% 
    ungroup %>% 
    kable()
```

| name                | genres                                                                   |
|:--------------------|:-------------------------------------------------------------------------|
| Japanese Breakfast  | art pop, bubblegrunge, eugene indie, indie pop, indie rock, philly indie |
| Haley Bonar         | melancholia, stomp and holler                                            |
| Balthazar           | belgian indie, belgian rock, dutch indie, dutch rock, ghent indie        |
| Buildings Breeding  | indie fuzzpop                                                            |
| Angus & Julia Stone | australian indie folk, indie folk, stomp and holler                      |

### Find your favorite tracks at the moment

``` r
get_my_top_artists_or_tracks(type = 'tracks', 
                             time_range = 'short_term', 
                             limit = 5) %>% 
    mutate(
        artist.name = map_chr(artists, function(x) x$name[1])
        ) %>% 
    select(name, artist.name, album.name) %>% 
    kable()
```

| name           | artist.name   | album.name     |
|:---------------|:--------------|:---------------|
| Animal - Edit  | LUMP          | Animal         |
| Hot & Heavy    | Lucy Dacus    | Hot & Heavy    |
| Wrong with You | Tristen       | Wrong with You |
| Sea Urchin     | Mystic Braves | Sea Urchin     |
| Hot Motion     | Temples       | Hot Motion     |

### What’s the most joyful Joy Division song?

My favorite audio feature has to be “valence,” a measure of musical
positivity.

``` r
joy <- get_artist_audio_features('joy division')
```

``` r
joy %>% 
    arrange(-valence) %>% 
    select(track_name, valence) %>% 
    head(5) %>% 
    kable()
```

| track\_name                               | valence |
|:------------------------------------------|--------:|
| Passover - 2020 Digital Master            |   0.946 |
| Passover - 2007 Remaster                  |   0.941 |
| Colony - 2020 Digital Master              |   0.829 |
| Colony - 2007 Remaster                    |   0.808 |
| Atrocity Exhibition - 2020 Digital Master |   0.790 |

Now if only there was some way to plot joy…

### Joyplot of the emotional rollercoasters that are Joy Division’s albums

``` r
library(ggplot2)
library(ggridges)

ggplot(
    joy, 
    aes(x = valence, y = album_name)
    ) + 
geom_density_ridges() + 
theme_ridges() +
labs(title = "Joyplot of Joy Division's joy distributions", 
     subtitle = "Based on valence pulled from Spotify's Web API with spotifyr")
```

<img src="man/figures/README-joyplot-1.png" width="100%" />

## Sentify: A Shiny app

This [app](http://rcharlie.net/sentify/), powered by spotifyr, allows
you to visualize the energy and valence (musical positivity) of all of
Spotify’s artists and playlists.

## Dope Stuff Other People Have Done with spotifyr

The coolest thing about making this package has definitely been seeing
all the awesome stuff other people have done with it. Here are a few
examples:

[Exploring the Spotify API with R: A tutorial for beginners, by a
beginner](https://msmith7161.github.io/what-is-speechiness/), Mia Smith

[Sentiment analysis of musical taste: a cross-European
comparison](http://paulelvers.com/post/emotionsineuropeanmusic/), Paul
Elvers

[Blue Christmas: A data-driven search for the most depressing Christmas
song](https://caitlinhudon.com/2017/12/22/blue-christmas/), Caitlin
Hudon

[Sente-se triste quando ouve “Amar pelos dois”? Não é o único (Do you
feel sad when you hear “Love for both?” You’re not
alone)](http://rr.sapo.pt/especial/112355/sente-se-triste-quando-ouve-amar-pelos-dois-nao-e-o-unico),
Rui Barros, Rádio Renascença

[Using Data to Find the Angriest Death Grips
Song](https://towardsdatascience.com/angriest-death-grips-data-anger-502168c1c2f0),
Evan Oppenheimer

[Hierarchical clustering of David Bowie
records](https://twitter.com/WireMonkey/status/1009915034246565891?s=19),
Alyssa Goldberg

[tayloR](https://medium.com/@simranvatsa5/taylor-f656e2a09cc3), Simran
Vatsa

## Code of Conduct

Please note that the spotifyr project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
