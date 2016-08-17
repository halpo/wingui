# test_win_processes.R

context("win_processes.R")
if(Sys.info()['sysname']=='Windows') {
test_that("win_processes", {
    wp <- win_processes(verbose=TRUE)
    expect_is(wp, "data.frame")
    expect_equal(ncol(wp), 9)
    
    wp <- win_processes(verbose=FALSE)
    expect_is(wp, "data.frame")
    expect_equal(ncol(wp), 5)
})

test_that("win_process_running", {
    expect_true(x <- win_process_running("winlogon.exe"))
})

test_that("win_users", {
    users <- win_users()
    expect_is(users, 'data.frame')
    expect_equal(names(users), c('USERNAME', 'SESSIONNAME', 'ID', 'STATE', 'IDLE TIME', 'LOGON TIME'))
})

test_that("win_load", {
    load <- win_load()
    expect_is(load, 'data.frame')
    expect_equal( names(load), c("Node", "Name", "LoadPercentage", "CurrentClockSpeed", "MaxClockSpeed"))
})


}
