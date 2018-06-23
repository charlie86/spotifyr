
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

The development version now imports the `geniusR` package from [Josiah Parry](https://github.com/JosiahParry/geniusR), which you can install with:

``` r
devtools::install_github('JosiahParry/geniusR')
```

(Note that this is separate from the `geniusr` package currently on CRAN)

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
    kable()
```

| key\_mode |    n|
|:----------|----:|
| C major   |   46|
| D major   |   41|
| G major   |   38|
| A major   |   36|
| E major   |   21|
| F major   |   18|
| A minor   |   11|
| B minor   |   10|
| E minor   |   10|
| C\# minor |    9|
| F\# minor |    8|
| A\# major |    6|
| C\# major |    6|
| D minor   |    6|
| D\# major |    3|
| G\# major |    3|
| B major   |    2|
| C minor   |    2|
| F minor   |    2|
| F\# major |    2|
| G\# minor |    2|
| G minor   |    1|

### Get your most recently played tracks

``` r
get_my_recently_played(limit = 10) %>% 
    kable()
```

| track\_name            | artist\_name          | album\_name         | played\_at\_utc     | context\_type | context\_uri | context\_spotify\_url | album\_type |  track\_number|  track\_popularity| explicit | album\_release\_date | album\_img                                                         | track\_uri             | artist\_uri            | album\_uri             | track\_preview\_url                                                                                           | track\_spotify\_url                                     |
|:-----------------------|:----------------------|:--------------------|:--------------------|:--------------|:-------------|:----------------------|:------------|--------------:|------------------:|:---------|:---------------------|:-------------------------------------------------------------------|:-----------------------|:-----------------------|:-----------------------|:--------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------|
| HoursDaysMonthsSeasons | Nathan Fake           | Providence          | 2018-06-23 22:18:21 | NA            | NA           | NA                    | album       |              3|                 34| FALSE    | NA                   | <https://i.scdn.co/image/77560c6cccc524891f930353b98a7b5ff7ec38f3> | 3ahMheJQ0ukl1edNuTRSfr | 5rZVjGkZZI4TnpMHQwrxfG | 6m2Yw1xMhp90rwUnOdtBcp | <https://p.scdn.co/mp3-preview/cad8071ea845ea8e08462d0d0075c88ca7598a81?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/3ahMheJQ0ukl1edNuTRSfr> |
| Deceiver               | Loscil                | Monument Builders   | 2018-06-23 22:13:38 | NA            | NA           | NA                    | album       |              5|                 36| FALSE    | NA                   | <https://i.scdn.co/image/b1fd8f0015767b736324feb28d8c4293b32dfbfd> | 5ziYoXutr7LlxWtJNDnRG4 | 3GM5cpCBadq2PMHjFoEvhK | 1anZBWOeghB5twG4CyJdoc | <https://p.scdn.co/mp3-preview/83bbf815785f71e51816d24d21aad9adb3458207?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/5ziYoXutr7LlxWtJNDnRG4> |
| Txt (MSGS)             | Mndsgn                | Yawn Zen            | 2018-06-23 22:11:11 | NA            | NA           | NA                    | album       |              9|                 33| FALSE    | NA                   | <https://i.scdn.co/image/b5a4c363b2cb30669e334f5b5a34d91ea904a8f6> | 6keqH1nqtS2j3DOovYwGFU | 4GcpBLY8g8NrmimWbssM26 | 5UNxfgrTnkQeVxFSdkAbCp | <https://p.scdn.co/mp3-preview/50c8bd2809482f479b55c6029b4e05756d7b4e86?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/6keqH1nqtS2j3DOovYwGFU> |
| A Grass Day            | Groundislava          | Groundislava        | 2018-06-23 22:10:05 | NA            | NA           | NA                    | album       |              3|                  9| FALSE    | NA                   | <https://i.scdn.co/image/ce3c6e3d79195edbcca8734e3ddcac5f51f22cd5> | 7CgOsQpzjHToqAfIUmWn4h | 2Y2gruKUC2cAjhe0h2RpzV | 2tjaNznEZzzGHFZw6UiErj | <https://p.scdn.co/mp3-preview/c50bf0ab2f50f7740e7c451c20b7a3826234b648?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/7CgOsQpzjHToqAfIUmWn4h> |
| A Grass Day            | Groundislava          | Groundislava        | 2018-06-23 22:09:27 | NA            | NA           | NA                    | album       |              3|                  9| FALSE    | NA                   | <https://i.scdn.co/image/ce3c6e3d79195edbcca8734e3ddcac5f51f22cd5> | 7CgOsQpzjHToqAfIUmWn4h | 2Y2gruKUC2cAjhe0h2RpzV | 2tjaNznEZzzGHFZw6UiErj | <https://p.scdn.co/mp3-preview/c50bf0ab2f50f7740e7c451c20b7a3826234b648?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/7CgOsQpzjHToqAfIUmWn4h> |
| Ancestors              | Gonjasufi             | A Sufi And A Killer | 2018-06-23 22:07:09 | NA            | NA           | NA                    | album       |              3|                 29| FALSE    | NA                   | <https://i.scdn.co/image/2caf364598d6ba6f990a374216b4da48bbd42239> | 4M4pvnVwdpQnd7wPIQI3h4 | 6pdYN3jOHWteVALy9sKGEf | 3FfW96Pt3UxQlchDVhkaFi | <https://p.scdn.co/mp3-preview/d1a4906c207f06cee6b3325e9333896fc7bb4920?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/4M4pvnVwdpQnd7wPIQI3h4> |
| Labyrinth IV           | Kaitlyn Aurelia Smith | Euclid              | 2018-06-23 22:04:32 | NA            | NA           | NA                    | album       |             10|                 17| FALSE    | NA                   | <https://i.scdn.co/image/4384711ad2ff5af294861edd666d154ac8ba5330> | 7nEQLBGhMMyYuI3Cj0mv6F | 6P86FLVAK4sxu8OhyQJBvH | 37butxH4sLnzjHxjkOOfgE | <https://p.scdn.co/mp3-preview/6a0c35dcce2e80f63aac03dc39c4a46df4004565?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/7nEQLBGhMMyYuI3Cj0mv6F> |
| Why Like This          | Teebs                 | Ardour              | 2018-06-23 22:02:10 | NA            | NA           | NA                    | album       |             16|                 28| FALSE    | NA                   | <https://i.scdn.co/image/8930dc1af7a726f1f28756c99a5cd7cfd201f354> | 2eo1Egv8l0JOupb7U0TGBb | 2L2unNFaPbDxjg3NqzpqhJ | 4NtIc6H8UadGHAYysXqzkc | <https://p.scdn.co/mp3-preview/73c44b156619c15b9540e079bf9798d55498d224?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/2eo1Egv8l0JOupb7U0TGBb> |
| Four Years and One Day | Mount Kimbie          | Love What Survives  | 2018-06-23 21:59:12 | NA            | NA           | NA                    | album       |              1|                 50| FALSE    | NA                   | <https://i.scdn.co/image/591e987e8330ee7d91b5b3355d77e80062d62afd> | 7foBPPS22i7vZlvsxqYiLe | 3NUtpWpGDoffm3RCGhSHtl | 54FblbvyHNrWeAuEJqnyit | <https://p.scdn.co/mp3-preview/d812e547e453ca13b32c7d38c1ab273ebb471cc0?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/7foBPPS22i7vZlvsxqYiLe> |
| Smoke Streams          | Lapalux               | The End Of Industry | 2018-06-23 21:55:54 | NA            | NA           | NA                    | album       |              5|                 12| FALSE    | NA                   | <https://i.scdn.co/image/d54c7cafc388af192a857488e0809731e12d5093> | 0L4hyppzNl7td9Zo4GPYuv | 46Ce0QmI1mE2bl5VQ4P9N8 | 1jIoxByxgoUr7SJSsJgQct | <https://p.scdn.co/mp3-preview/656c3ee9bdf01249780bbd544e6088a63ae34dec?cid=0cfbcde7a276401c891d1ba876c1ebb7> | <https://open.spotify.com/track/0L4hyppzNl7td9Zo4GPYuv> |

### Find your all time favorite artists

``` r
get_my_top_artists(time_range = 'long_term', limit = 10) %>% 
    kable()
```

| artist\_name     | artist\_uri            | artist\_img                                                        | artist\_genres                                                                                                                                              |  artist\_popularity|  artist\_num\_followers| artist\_spotify\_url                                     |
|:-----------------|:-----------------------|:-------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------:|-----------------------:|:---------------------------------------------------------|
| Radiohead        | 4Z8W4fKeB5YxbusRsdQVPb | <https://i.scdn.co/image/afcd616e1ef2d2786f47b3b4a8a6aeea24a72adc> | alternative rock, art rock, melancholia, modern rock, permanent wave, rock                                                                                  |                  79|                 3218607| <https://open.spotify.com/artist/4Z8W4fKeB5YxbusRsdQVPb> |
| Onra             | 2sAlo7Fey5cqBk5WJILSd8 | <https://i.scdn.co/image/06280e94f233f6c49f5fdf980dd12d51ba11fa91> | alternative hip hop, chillhop, ninja, trip hop, wonky                                                                                                       |                  53|                   70262| <https://open.spotify.com/artist/2sAlo7Fey5cqBk5WJILSd8> |
| Flying Lotus     | 29XOeO6KIWxGthejQqn793 | <https://i.scdn.co/image/96a2af0c3ea3654121a2bdc55731e6ef5034be87> | alternative hip hop, chillwave, electronic, escape room, glitch, glitch hop, hip hop, indie r&b, indietronica, intelligent dance music, wonky               |                  59|                  360260| <https://open.spotify.com/artist/29XOeO6KIWxGthejQqn793> |
| Teebs            | 2L2unNFaPbDxjg3NqzpqhJ | <https://i.scdn.co/image/9554a83f7f84e01a989c6633f5d0e1d174323986> | abstract beats, bass music, chillwave, wonky                                                                                                                |                  42|                   46614| <https://open.spotify.com/artist/2L2unNFaPbDxjg3NqzpqhJ> |
| Four Tet         | 7Eu1txygG6nJttLHbZdQOh | <https://i.scdn.co/image/f96458025a0640bf1d3c8f764a42ec21d4db1eae> | alternative dance, chamber psych, electronic, indie r&b, indietronica, intelligent dance music, microhouse, new rave, nu jazz, trip hop                     |                  63|                  246691| <https://open.spotify.com/artist/7Eu1txygG6nJttLHbZdQOh> |
| J Dilla          | 0IVcLMMbm05VIjnzPkGCyp | <https://i.scdn.co/image/bf1bd61ca9468f0f6328f4095d376826380afe95> | alternative hip hop, detroit hip hop, hip hop                                                                                                               |                  63|                  228516| <https://open.spotify.com/artist/0IVcLMMbm05VIjnzPkGCyp> |
| Aphex Twin       | 6kBDZFXuLrZgHnvmPu9NsG | <https://i.scdn.co/image/742a137a1b42a69c215fba62fe177ab470b47e53> | acid techno, ambient, electronic, fourth world, intelligent dance music, trip hop                                                                           |                  65|                  353017| <https://open.spotify.com/artist/6kBDZFXuLrZgHnvmPu9NsG> |
| The Black Angels | 0VNWuGf8SMVU2AerpdhMbP | <https://i.scdn.co/image/f6de8cac7577646463b18f2df218348679ee8265> | blues-rock, garage rock, neo-psychedelic, nu gaze, punk blues                                                                                               |                  53|                  124412| <https://open.spotify.com/artist/0VNWuGf8SMVU2AerpdhMbP> |
| Siriusmo         | 22680B8sUdq6bL6nQaJfwg | <https://i.scdn.co/image/1bf301b7dc879c9b174eeae6d2939f59bdfe235f> | alternative dance, dance-punk, filter house, new rave                                                                                                       |                  49|                   43491| <https://open.spotify.com/artist/22680B8sUdq6bL6nQaJfwg> |
| Mount Kimbie     | 3NUtpWpGDoffm3RCGhSHtl | <https://i.scdn.co/image/d784215c4b003f30d5622912584f4d21a1030269> | alternative dance, art pop, bass music, chamber psych, chillwave, electronic, future garage, indie r&b, indietronica, microhouse, new rave, trip hop, wonky |                  58|                  161596| <https://open.spotify.com/artist/3NUtpWpGDoffm3RCGhSHtl> |

### Find your favorite tracks at the moment

``` r
get_my_top_tracks(time_range = 'short_term', limit = 10) %>% 
    kable()
```

| track\_name                       | artist\_name | album\_name     | album\_type |  track\_number|  track\_popularity| explicit | album\_release\_date | album\_img                                                         | track\_uri             | artist\_uri            | album\_uri             | track\_preview\_url                                                               | track\_spotify\_url                                     |
|:----------------------------------|:-------------|:----------------|:------------|--------------:|------------------:|:---------|:---------------------|:-------------------------------------------------------------------|:-----------------------|:-----------------------|:-----------------------|:----------------------------------------------------------------------------------|:--------------------------------------------------------|
| Wake and Bake                     | Fleece       | Scavenger       | ALBUM       |              2|                 39| TRUE     | 2015-01-20           | <https://i.scdn.co/image/beab03ac56f835bc228082d9b3709c1dcfb143b2> | 1ed5ib8UKeZsQaN2GFbmrS | 3M8JKaNdIRChzvxVK1XxKm | 2RaZ55erDzUKE0zstJ3T0x | <https://p.scdn.co/mp3-preview/cf6b19d95a0ca8fd33e882f8995c66ad0592a869?cid=null> | <https://open.spotify.com/track/1ed5ib8UKeZsQaN2GFbmrS> |
| Riverside                         | Fleece       | Voyager         | ALBUM       |              5|                 33| FALSE    | 2017-01-19           | <https://i.scdn.co/image/158a2df106b819d5a72227e33d5fbfb51cef21ab> | 5jBsnG7CPKNNKeR7DmT9FU | 3M8JKaNdIRChzvxVK1XxKm | 2PuXMzeWFG1N7meAXFVMoq | <https://p.scdn.co/mp3-preview/1306392012bd8f78fad728c38b3b4ddcf5987b65?cid=null> | <https://open.spotify.com/track/5jBsnG7CPKNNKeR7DmT9FU> |
| Under the Light                   | Fleece       | Voyager         | ALBUM       |              1|                 38| FALSE    | 2017-01-19           | <https://i.scdn.co/image/158a2df106b819d5a72227e33d5fbfb51cef21ab> | 6HBSSVm0X3z178D6FaXj9d | 3M8JKaNdIRChzvxVK1XxKm | 2PuXMzeWFG1N7meAXFVMoq | <https://p.scdn.co/mp3-preview/858208e5482a9932b04c0f8270118fbd6813691a?cid=null> | <https://open.spotify.com/track/6HBSSVm0X3z178D6FaXj9d> |
| Jynweythek                        | Aphex Twin   | Drukqs          | ALBUM       |              1|                 40| FALSE    | 2001-10-22           | <https://i.scdn.co/image/0ecee6d7885e1e7cbe8ff5284706a3f0046d5748> | 7etelDpVxaPTzmeZrYo8Qy | 6kBDZFXuLrZgHnvmPu9NsG | 1maoQPAmw44bbkNOxKlwsx | <https://p.scdn.co/mp3-preview/4ca837c390dc6a05aae2f590bbc2aa6a5d495c10?cid=null> | <https://open.spotify.com/track/7etelDpVxaPTzmeZrYo8Qy> |
| Vibras                            | J Balvin     | Vibras          | ALBUM       |              1|                 70| FALSE    | 2018-05-25           | <https://i.scdn.co/image/cc56f48efc4285caaa8e895337846f5174bf3989> | 2EEjiKbE4pAjX49TrBzw1X | 1vyhD5VmyZ7KMfW5gqLgo5 | 5kprdYds6oZb4iSldfflOT | NA                                                                                | <https://open.spotify.com/track/2EEjiKbE4pAjX49TrBzw1X> |
| Fix It Together                   | Fleece       | Voyager         | ALBUM       |             10|                 30| FALSE    | 2017-01-19           | <https://i.scdn.co/image/158a2df106b819d5a72227e33d5fbfb51cef21ab> | 27Fayw7YOL3gTkxg7yfaiz | 3M8JKaNdIRChzvxVK1XxKm | 2PuXMzeWFG1N7meAXFVMoq | <https://p.scdn.co/mp3-preview/a2af20b463c2739b5b5470427845c113e4273324?cid=null> | <https://open.spotify.com/track/27Fayw7YOL3gTkxg7yfaiz> |
| Vordhosbn                         | Aphex Twin   | Drukqs          | ALBUM       |              2|                 40| FALSE    | 2001-10-22           | <https://i.scdn.co/image/0ecee6d7885e1e7cbe8ff5284706a3f0046d5748> | 3tWiIOPBJjgjA6PpozJqNO | 6kBDZFXuLrZgHnvmPu9NsG | 1maoQPAmw44bbkNOxKlwsx | <https://p.scdn.co/mp3-preview/a23964759032c954b9cda3b8b8a23de71bb72b45?cid=null> | <https://open.spotify.com/track/3tWiIOPBJjgjA6PpozJqNO> |
| What You've Done                  | Fleece       | Voyager         | ALBUM       |              4|                 24| FALSE    | 2017-01-19           | <https://i.scdn.co/image/158a2df106b819d5a72227e33d5fbfb51cef21ab> | 7GLoVC2XBr1nfMfrX3odGt | 3M8JKaNdIRChzvxVK1XxKm | 2PuXMzeWFG1N7meAXFVMoq | <https://p.scdn.co/mp3-preview/233d3d117f2c1d83332f102662aab83abd302f50?cid=null> | <https://open.spotify.com/track/7GLoVC2XBr1nfMfrX3odGt> |
| Skip Divided (Modeselektor Remix) | Thom Yorke   | The Eraser Rmxs | ALBUM       |              4|                 29| FALSE    | 2008                 | <https://i.scdn.co/image/8fa0eb1c627ce67ebe1e3e82c019791ff4bfdb2f> | 0Aphl3uGYo7PCoVSGZjnAP | 4CvTDPKA6W06DRfBnZKrau | 0K78rF0ziljfWqb1BtXyFB | <https://p.scdn.co/mp3-preview/da8e38b528aa5695a7f3b3b0a21445c37fc6c513?cid=null> | <https://open.spotify.com/track/0Aphl3uGYo7PCoVSGZjnAP> |
| On My Mind                        | Fleece       | Voyager         | ALBUM       |              2|                 41| FALSE    | 2017-01-19           | <https://i.scdn.co/image/158a2df106b819d5a72227e33d5fbfb51cef21ab> | 0DbMOz6MrPJ9nfYXgGarLw | 3M8JKaNdIRChzvxVK1XxKm | 2PuXMzeWFG1N7meAXFVMoq | <https://p.scdn.co/mp3-preview/14b68f0d16af9e5f9356ca0d25c3e4d35f3dc55a?cid=null> | <https://open.spotify.com/track/0DbMOz6MrPJ9nfYXgGarLw> |

### What's the most joyful Joy Division song?

My favorite audio feature has to be "valence," a measure of musical positivity.

``` r
joy <- get_artist_audio_features('joy division')
```

``` r
joy %>% 
    arrange(-valence) %>% 
    select(track_name, valence) %>% 
    head(10) %>% 
    kable()
```

| track\_name                                   |  valence|
|:----------------------------------------------|--------:|
| These Days                                    |    0.949|
| Passover - 2007 Remastered Version            |    0.941|
| Colony - 2007 Remastered Version              |    0.808|
| Atrocity Exhibition - 2007 Remastered Version |    0.787|
| Wilderness                                    |    0.775|
| Twenty Four Hours                             |    0.773|
| A Means To An End - 2007 Remastered Version   |    0.752|
| Interzone - 2007 Remastered Version           |    0.746|
| She's Lost Control - 2007 Remastered Version  |    0.743|
| Disorder - 2007 Remastered Version            |    0.740|
| Now if only there was some way to plot joy... |         |

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

### Danceability of Thom Yorke

``` r
library(magick)
library(lubridate)

tots <- map_df(c('radiohead', 'thom yorke', 'atoms for peace'), get_artist_audio_features)
```

``` r
non_studio_albums <- c('OK Computer OKNOTOK 1997 2017', 'TKOL RMX 1234567', 'In Rainbows Disk 2', 
                       'Com Lag: 2+2=5', 'I Might Be Wrong', 'The Eraser Rmxs')

tots <- filter(tots, !album_name %in% non_studio_albums)

album_names_label <- tots %>% 
    arrange(album_release_date) %>% 
    mutate(label = str_glue('{album_name} ({year(album_release_year)})')) %>% 
    pull(label) %>% 
    unique

plot_df <- tots %>% 
    select(track_name, album_name, danceability, album_release_date) %>% 
    gather(metric, value, -c(track_name, album_name, album_release_date))

p <- ggplot(plot_df, aes(x = value, y = album_release_date)) + 
    geom_density_ridges(size = .1) +
    theme_ridges(center_axis_labels = TRUE, grid = FALSE, font_size = 6) +
    theme(plot.title = element_text(face = 'bold', size = 14, hjust = 1.25),
          plot.subtitle = element_text(size = 10, hjust = 1.1)) +
    ggtitle('Have we reached peak Thom Yorke danceability?', 'Song danceability by album - Radiohead, Thom Yorke, and Atoms for Peace') +
    labs(x = 'Song danceability', y = '') +
    scale_x_continuous(breaks = c(0,.25,.5,.75,1)) +
    scale_y_discrete(labels = album_names_label)

ggsave(p, filename = 'img/danceplot.png', width = 5, height = 3)
#> Picking joint bandwidth of 0.0714
background <- image_read('img/danceplot.png')
logo_raw <- image_read('img/thom_dance.gif')
frames <- lapply(1:length(logo_raw), function(frame) {
    hjust <- 200+(100*frame)
    image_composite(background, logo_raw[frame], offset = str_glue('+{hjust}+400'))
})

image_animate(image_join(frames), fps = 5, loop = 0)
```

![](man/figures/README-unnamed-chunk-11-1.gif)

Parallelization
---------------

By default, `get_artist_audio_features()`, `get_artist_albums()`, `get_album_tracks()`, `get_playlist_tracks()`, and `get_user_playlists()` will run in parallel using the `furrr` package. To turn this feature off, set `parallelize = FALSE`. You can also adjust the evaluation strategy by setting `future_plan`, which accepts a string matching one of the strategies implemented in `future::plan()` (defaults to `"multiprocess"`).

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
