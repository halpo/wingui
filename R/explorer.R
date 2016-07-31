{###############################################################################
#  explorer.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################

find_default_fm <- 
function(sysname = Sys.info()['sysname']){
    #TODO: add full.path options to give option of returning full path.
    switch( OS.type
          , Windows = "explorer.exe"
          , Darwin  = "open"
          , Linux   = "xdg-open"
          )
}
if(FALSE){#! @test
    expect_equal(find_default_fm("Windows", "explorer.exe"))
    expect_equal(find_default_fm("Darwin" , "open"))
    expect_equal(find_default_fm("Linux", "xdg-open"))
}

#' Open the file manager
#' 
#' @param dir Directory to open.
#' @param manager the file manager to use.
#' 
#' @export
file_manager <- 
function( dir     = getwd()                                         #< Directory to open
        , manager = getOption("file.manager", find_default_fm())    #< The file manager to use.
        ){
    "Open the file manager."
    dir <- normalizePath(dir)
    if(.Platform$OS.type=="windows")
        suppressWarnings(system2(manager, shQuote(dir), wait=FALSE, invisible=FALSE))
    else 
        suppressWarnings(system2(manager, shQuote(dir), wait=FALSE))
    #! @return called for the side effect.
}

#' @export
#' @describeIn file_manager alias for \code{file_manager}
explorer <- file_manager

