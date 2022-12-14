# spotifyr 2.1.4

* Minor improvements from [@yogat3ch](https://github.com/yogat3ch) for long playlists [PR186](https://github.com/charlie86/spotifyr/pull/186) and playlists with 0 songs [PR183.](https://github.com/charlie86/spotifyr/pull/183)
* Removal of the genius dependency [@JosiahParry](https://github.com/JosiahParry), [PR189](https://github.com/charlie86/spotifyr/pull/189).

# spotifyr 2.1.2

* Added a `NEWS.md` file to track changes to the package.
* New [New minor CRAN release 2.2 project](https://github.com/charlie86/spotifyr/projects/2) on github
* Remove deprecated dependency in README [ggjoy](https://cran.r-project.org/package=ggjoy/) and replace it with [ggridges](https://cran.r-project.org/package=ggridges)
* Remove good examples from README if they are broken links.
* Add pkgdown package reference website.

# spotifyr 2.1.3
* Further documentation improvements, adding sections to the documentation.
* Fixing `dedupe_album_names()`. Adding assertion to `get_artist_audio_features()` for reported issue with non-existing artist.

# spotifyr 2.2.0
* Release candidate for CRAN.
* Resubmitted after reformatting two (possibly) invalid urls.

# spotifyr 2.2.1
* All functions in the documentation have well-specified return values.
* Assertions are made with assertthat for more meaningful error messages. Use `validate_parameters()`.
* Released on CRAN.

# spotifyr 2.2.2
* Fixes bug [#152](https://github.com/charlie86/spotifyr/issues/152). Thanks for the report, _@pham-thomas_!
* Incorporates better API call, thanks for the valuable contribution,  [\@annnvv](https://github.com/annnvv).

# spotifyr 2.2.3
* Fixes [#160](https://github.com/charlie86/spotifyr/issues/160)   Thanks for reporting by [\@dwh1142](https://github.com/dwh1142) and fixing the scopes ,[\@bradisbrad](https://github.com/bradisbrad).
* Fixes [#161](https://github.com/charlie86/spotifyr/issues/161) with the bug fix provided by [\@apsteinmetz](https://github.com/apsteinmetz). Thank you!
* More consistent error messages for `get_artist_audio_features()`, which needs to be re-written together with `get_artist_albums()` for more consistency in the function API.
