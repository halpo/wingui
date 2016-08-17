# test_win_memory.R

context("win_memory.R")
if(Sys.info()['sysname'] == "Windows"){
test_that("win_memory", {
    expect_output(x <- win_memory())
    expect_is(x, 'list')
    expect_equal(names(x), 
        c( 'Size', 'Percent', 'Physical', 'Available'
         , 'TotalPage', 'AvailPage', 'TotalVirtual'
         , 'AvailVirtual', 'AvailVirtualExtended'
         ))
})
}



 