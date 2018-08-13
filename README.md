
<!-- README.md is generated from README.Rmd. Please edit that file -->
spotifyr
========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/spotifyr?color=brightgreen)](https://cran.r-project.org/package=spotifyr) ![](http://cranlogs.r-pkg.org/badges/spotifyr?color=brightgreen)

Overview
--------

spotifyr is a wrapper for pulling track audio features and other information from Spotify's Web API in bulk. By automatically batching API requests, it allows you to enter an artist's name and retrieve their entire discography in seconds, along with Spotify's audio features and track/album popularity metrics. You can also pull song and playlist information for a given Spotify User (including yourself!).

Installation
------------

Development version (recommended)

``` r
devtools::install_github('charlie86/spotifyr')
```

The development version now includes functions from the `geniusR` package from [Josiah Parry](https://github.com/JosiahParry/geniusR).

CRAN version 1.0.0 (Note: this is somewhat outdated, as it takes extra time to submit and pass CRAN checks)

``` r
install.packages('spotifyr')
```

Authentication
--------------

First, set up a Dev account with Spotify to access their Web API [here](https://developer.spotify.com/my-applications/#!/applications). This will give you your `Client ID` and `Client Secret`. Once you have those, you can pull your access token into R with `get_spotify_access_token()`.

The easiest way to authenticate is to set your credentials to the System Environment variables `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET`. The default arguments to `get_spotify_access_token()` (and all other functions in this package) will refer to those. Alternatively, you can set them manually and make sure to explicitly refer to your access token in each subsequent function call.

``` r
Sys.setenv(SPOTIFY_CLIENT_ID = 'xxxxxxxxxxxxxxxxxxxxx')
Sys.setenv(SPOTIFY_CLIENT_SECRET = 'xxxxxxxxxxxxxxxxxxxxx')

access_token <- get_spotify_access_token()
```

Usage
-----

### What was The Beatles' favorite key?

``` r
library(spotifyr)
beatles <- get_artist_audio_features('the beatles')
```

``` r
library(tidyverse)
library(knitr)

beatles %>% 
    count(key_mode, sort = TRUE) %>% 
    head(5) %>% 
    kable()
```

| key\_mode |    n|
|:----------|----:|
| D major   |   64|
| A major   |   63|
| E major   |   58|
| G major   |   57|
| C major   |   49|

### Get your most recently played tracks

``` r
get_my_recently_played(limit = 5) %>% 
    select(track_name, artist_name, album_name, played_at_utc) %>% 
    kable()
```

| track\_name                          | artist\_name | album\_name                                     | played\_at\_utc     |
|:-------------------------------------|:-------------|:------------------------------------------------|:--------------------|
| DISKPREPT1                           | Aphex Twin   | Computer Controlled Acoustic Instruments pt2 EP | 2018-08-13 21:50:35 |
| disk prep calrec2 barn dance \[slo\] | Aphex Twin   | Computer Controlled Acoustic Instruments pt2 EP | 2018-08-13 21:49:38 |
| hat 2b 2012b                         | Aphex Twin   | Computer Controlled Acoustic Instruments pt2 EP | 2018-08-13 21:44:40 |
| DISKPREPT4                           | Aphex Twin   | Computer Controlled Acoustic Instruments pt2 EP | 2018-08-13 21:43:14 |
| piano un1 arpej                      | Aphex Twin   | Computer Controlled Acoustic Instruments pt2 EP | 2018-08-13 21:41:22 |

### Find your all time favorite artists

``` r
get_my_top_artists(time_range = 'long_term', limit = 5) %>% 
    select(artist_name, artist_genres) %>% 
    rowwise %>% 
    mutate(artist_genres = paste(artist_genres, collapse = ', ')) %>% 
    ungroup %>% 
    kable()
```

| artist\_name | artist\_genres                                                                                                                   |
|:-------------|:---------------------------------------------------------------------------------------------------------------------------------|
| Radiohead    | alternative rock, art rock, melancholia, modern rock, permanent wave, rock                                                       |
| Onra         | alternative hip hop, chillhop, ninja, trip hop, wonky                                                                            |
| Flying Lotus | alternative hip hop, chillwave, electronic, glitch, glitch hop, hip hop, indie r&b, indietronica, intelligent dance music, wonky |
| Teebs        | abstract beats, bass music, chillwave, indietronica, wonky                                                                       |
| Siriusmo     | dance-punk, filter house, new rave                                                                                               |

### Find your favorite tracks at the moment

``` r
get_my_top_tracks(time_range = 'short_term', limit = 5) %>% 
    select(track_name, artist_name, album_name) %>% 
    kable()
```

| track\_name     | artist\_name | album\_name                                   |
|:----------------|:-------------|:----------------------------------------------|
| Bella           | Wolfine      | Bella                                         |
| Drogba (Joanna) | Afro B       | Drogba (Joanna)                               |
| Fellin' Myself  | Mac Dre      | Ronald Dregan For President 2004: Dreganomics |
| T69 collapse    | Aphex Twin   | T69 collapse                                  |
| Not My Job      | Mac Dre      | The Genie Of The Lamp                         |

### What's the most joyful Joy Division song?

My favorite audio feature has to be "valence," a measure of musical positivity.

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

| track\_name                                   |  valence|
|:----------------------------------------------|--------:|
| These Days                                    |    0.949|
| Passover - 2007 Remastered Version            |    0.941|
| Colony - 2007 Remastered Version              |    0.808|
| Atrocity Exhibition - 2007 Remastered Version |    0.787|
| Wilderness                                    |    0.775|

Now if only there was some way to plot joy...

### Joyplot of the emotional rollercoasters that are Joy Division's albums

``` r
library(ggjoy)
#> Loading required package: ggridges
#> The ggjoy package has been deprecated. Please switch over to the
#> ggridges package, which provides the same functionality. Porting
#> guidelines can be found here:
#> https://github.com/clauswilke/ggjoy/blob/master/README.md

ggplot(joy, aes(x = valence, y = album_name)) + 
    geom_joy() + 
    theme_joy() +
    ggtitle("Joyplot of Joy Division's joy distributions", subtitle = "Based on valence pulled from Spotify's Web API with spotifyr")
#> Picking joint bandwidth of 0.112
```

![](man/figures/README-unnamed-chunk-9-1.png)

Parallelization
---------------

`get_artist_audio_features()`, `get_artist_albums()`, `get_album_tracks()`, `get_playlist_tracks()`, and `get_user_playlists()` can run in parallel using the `furrr` package. To enable this feature, set `parallelize = TRUE`. You can also adjust the evaluation strategy by setting `future_plan`, which accepts a string matching one of the strategies implemented in `future::plan()` (defaults to `"multiprocess"`).

Sentify: A Shiny app
--------------------

This [app](http://rcharlie.net/sentify/), powered by spotifyr, allows you to visualize the energy and valence (musical positivity) of all of Spotify's artists and playlists.

Dope stuff other people have done with spotifyr
-----------------------------------------------

The coolest thing about making this package has definitely been seeing all the awesome stuff other people have done with it. Here are a few examples:

[Sentiment analysis of musical taste: a cross-European comparison](http://paulelvers.com/post/emotionsineuropeanmusic/) - Paul Elvers

[Blue Christmas: A data-driven search for the most depressing Christmas song](https://caitlinhudon.com/2017/12/22/blue-christmas/) - Caitlin Hudon

[KendRick LamaR](https://davidklaing.github.io/kendrick-lamar-data-science/) - David K. Laing

[Vilken är Kents mest deprimerande låt? (What is Kent's most depressing song?)](http://dataland.rbind.io/2017/11/07/vilken-%C3%A4r-kents-mest-deprimerande-lat/) - Filip Wästberg

[Чёрное зеркало Arcade Fire (Black Mirror Arcade Fire)](http://thesociety.ru/arcadefire) - TheSociety

[Sente-se triste quando ouve "Amar pelos dois"? Não é o único (Do you feel sad when you hear "Love for both?" You're not alone)](http://rr.sapo.pt/especial/112355/sente-se-triste-quando-ouve-amar-pelos-dois-nao-e-o-unico) - Rui Barros, Renascença

[Hierarchical clustering of David Bowie records](https://twitter.com/WireMonkey/status/1009915034246565891?s=19) - Alyssa Goldberg

[tayloR](https://medium.com/@simranvatsa5/taylor-f656e2a09cc3) - Simran Vatsa
