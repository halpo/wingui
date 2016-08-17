# test_explorer.R

context("explorer.R")


test_that("find_default_fm", {
    expect_equal(find_default_fm("Windows"), "explorer.exe")
    expect_equal(find_default_fm("Darwin" ), "open"        )
    expect_equal(find_default_fm("Linux"  ), "xdg-open"    )
})

