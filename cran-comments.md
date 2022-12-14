## Test environments

* local R installation, R 4.1.0 on Ubuntu
* win-builder (devel, release)
* Fedora Linux, R-devel, clang, gfortran on rhub
* Ubuntu Linux 20.04.1 LTS, R-release, GCC on rhub
* Windows Server 2022, R-devel, 64 bit on rhub


## R CMD check results

0 errors v | 0 warnings v | 0 notes v

## Minor fixes

spotifyR has been for many years on CRAN but was archived 3 days ago because a dependency, genius, was archived.  We removed this minor dependency. 

This release candidate has some minor bug fixes, i.e. handling 0-length and very lengthy playlists. A few typos were corrected in the documentation and a new WORLDLIST added to spellchecking.
