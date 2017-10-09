# spotifyr

#### Overview
spotifyr is a quick and easy wrapper for pulling track audio features from Spotify's Web API in bulk. By automatically batching API requests, it allows you to enter an artist's name and retrieve their entire discography in seconds, along with Spotify's audio features and track/album popularity metrics. You can also pull song and playlist information for a given Spotify User (including yourself!).

#### Installation
```r
devtools::install_github('charlie86/spotifyr')
```

#### Usage
Ever wondered what the most danceable Joy Division song is?

```{r echo=FALSE}

library(spotifyr)

joy <- get_artist_audio_features('joy division')

joy %>% 
 arrange(-danceability) %>% 
 select(track_name, danceability) %>% 
 head(10)
 
```
