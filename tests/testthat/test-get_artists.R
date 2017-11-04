library(spotifyr)
context('get_artists')

test_that('get_artists returns a dataframe', {
    expect_true(is.data.frame(get_artists('radiohead')))
})

test_that('empty string returns error', {
    expect_error(get_artists(''))
})
