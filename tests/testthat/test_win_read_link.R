# test_win_read_link.R

context("win_processes.R")

test_that("raw2int", {
    x <- 1234567890
    y <- "499602D2"
    
    r <- raw(4)
    r[[4]] <- as.raw(0x49)
    r[[3]] <- as.raw(0x96)
    r[[2]] <- as.raw(0x02)
    r[[1]] <- as.raw(0xD2)
    
    expect_equal(raw2int(r), 1234567890)
})

test_that("raw2CLSID", {
    r <- raw(16)
    r[[16]] <- as.raw(0xFF)
    r[[15]] <- as.raw(0xEE)
    r[[14]] <- as.raw(0xDD)
    r[[13]] <- as.raw(0xCC)
    r[[12]] <- as.raw(0xBB)
    r[[11]] <- as.raw(0xAA)
    r[[10]] <- as.raw(0x99)
    r[[09]] <- as.raw(0x88)
    r[[08]] <- as.raw(0x77)
    r[[07]] <- as.raw(0x66)
    r[[06]] <- as.raw(0x55)
    r[[05]] <- as.raw(0x44)
    r[[04]] <- as.raw(0x33)
    r[[03]] <- as.raw(0x22)
    r[[02]] <- as.raw(0x11)
    r[[01]] <- as.raw(0x00)
    expect_equal(raw2CLSID(r), "33221100-4455-6677-8899-aabbccddeeff")
})

test_that("read_lnk", {
    file <- system.file("test.lnk", package="wingui")
    expect_equal( as.character(read_lnk(file)), '.')
    
    info <- read_lnk(system.file("net.lnk", package="wingui"))
    expect_equal(as.character(info), file.path("G:", "\u4f60\u597d"))
    expect_true(env[['flags']][['CommonNetworkRelativeLinkAndPathSuffix']])
})

