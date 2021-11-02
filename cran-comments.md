## Test environments
* local R installation, R 4.1.0 on Windows 10
* win-builder (devel, release)
* Fedora Linux, R-devel, clang, gfortran on rhub
* Ubuntu Linux 20.04.1 LTS, R-release, GCC on rhub

## R CMD check results

0 errors v | 0 warnings v | 0 notes v

## Minor fixes

This release candidate has some minor bug fixes, including revision of the scopes() function following a change in the Spotify API.  (Wrong scoping caused build errors with the vignettes.)
