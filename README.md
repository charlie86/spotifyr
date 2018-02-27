
<!-- README.md is generated from README.Rmd. Please edit that file -->
spotifyr
========

[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/spotifyr?color=green)](https://cran.r-project.org/package=spotifyr) ![](http://cranlogs.r-pkg.org/badges/grand-total/spotifyr?color=green)

Overview
--------

spotifyr is a wrapper for pulling track audio features and other information from Spotify's Web API in bulk. By automatically batching API requests, it allows you to enter an artist's name and retrieve their entire discography in seconds, along with Spotify's audio features and track/album popularity metrics. You can also pull song and playlist information for a given Spotify User (including yourself!).

Installation
------------

Stable version 1.0.0 on CRAN

``` r
install.packages('spotifyr')
```

Development version

``` r
devtools::install_github('charlie86/spotifyr')
```

Authenication
-------------

You'll have to set up a Dev account with Spotify to access their Web API [here](https://developer.spotify.com/my-applications/#!/applications). This will give you your `Client ID` and `Client Secret`. Once you have those, you can pull your access token into R with `get_spotify_access_token`.

The easiest way to authenticate is to set your credentials to the System Environment variables `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET`. The default arguments to `get_spotify_access_token` (and all other functions in this package) will refer to those. Alternatively, you can set them manually and make sure to explicitly refer to your access token in each subsequent function call.

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
```

``` r
beatles <- get_artist_audio_features('the beatles')

library(tidyverse)
count(beatles, key_mode, sort = T)
#> # A tibble: 22 x 2
#>    key_mode     n
#>    <chr>    <int>
#>  1 C major     40
#>  2 D major     38
#>  3 A major     33
#>  4 G major     33
#>  5 E major     19
#>  6 F major     13
#>  7 B minor      9
#>  8 C# minor     9
#>  9 A minor      8
#> 10 F# minor     8
#> # ... with 12 more rows
```

### What's the most joyful Joy Division song?

My favorite audio feature has to be "valence," a measure of musical positivity.

``` r
joy <- get_artist_audio_features('joy division')

joy %>% 
 arrange(-valence) %>% 
 select(track_name, valence) %>% 
 head(10)
#> # A tibble: 10 x 2
#>    track_name                                    valence
#>    <chr>                                           <dbl>
#>  1 These Days                                      0.949
#>  2 Passover - 2007 Remastered Version              0.941
#>  3 Colony - 2007 Remastered Version                0.808
#>  4 Atrocity Exhibition - 2007 Remastered Version   0.787
#>  5 Wilderness                                      0.775
#>  6 Twenty Four Hours                               0.773
#>  7 A Means To An End - 2007 Remastered Version     0.752
#>  8 Interzone - 2007 Remastered Version             0.746
#>  9 She's Lost Control - 2007 Remastered Version    0.743
#> 10 Disorder - 2007 Remastered Version              0.740
```

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
  ggtitle("Joyplot of Joy Division's joy distributions", subtitle = paste0("Based on valence pulled from Spotify's Web API with spotifyr"))
#> Picking joint bandwidth of 0.112
```

![](man/figures/README-unnamed-chunk-5-1.png)

Sentify: A Shiny app
--------------------

This [app](http://rcharlie.net/sentify/), powered by spotifyr, allows you to visualize the energy and valence (musical positivity) of all of Spotify's artists and playlists.

Dope stuff other people have done with spotifyr
-----------------------------------------------

The coolest thing about making this package has definitely been seeing all the awesome stuff other people have done with it. Here are a few examples:

[Sentiment analysis of musical taste: a cross-European comparison](http://paulelvers.com/post/emotionsineuropeanmusic/) - Paul Elvers

[Blue Christmas: A data-driven search for the most depressing Christmas song](https://caitlinhudon.com/2017/12/22/blue-christmas/) - Caitlin Hudon

[KendRick LamaR](https://davidklaing.github.io/kendrick-lamar-data-science/) - David K. Laing
