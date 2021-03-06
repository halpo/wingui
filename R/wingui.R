{###############################################################################
#  wingui.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################



#' @name wingui
#' @docType package
#' @title Manipulate the Windows Rgui.
#' @description
#' Interact with windows gui and other processes on windows.
#' 
#' \enumerate{
#'   \item \code{\link{GUI}}
#'   \item \code{\link{win_memory}}
#'   \item \code{\link{win_load}}
#'   \item \code{\link{whos_the_hog}}
#'   \item \code{\link{win_load}}
#'   \item \code{\link{win_kill}}
#'   \item \code{\link{win_users}}
#'   \item \code{\link{win_process_running}}
#'   \item \code{\link{win_processes}}
#'   \item \code{\link{spawnR}}
#'   \item \code{\link{BATCH}}
#'   \item \code{\link{explorer}}
#'   \item \code{\link{is_r_startup}}
#'   \item \code{\link{npptor}}
#'   \item \code{\link{npp}}
#' }
#' 
#' @importFrom utils head tail read.csv
#' @import Rcpp
#' @import methods
#' @useDynLib wingui
NULL

.hwnd <- NULL #< Global variable check confuser

if(!exists(".packageName", inherit=F))
    .packageName <- 'wingui'

# nocov start
if(.Platform$OS.type=="windows"){
    setRcppClass( "WindowsGUI"
                , module='wingui'
#~                 , saveAs="WindowsGUI"
                , methods=list(show=function(){
                        cat("Windows GUI (", .hwnd, ")\n")
                    })
                )
    myLoad <- function(ns){
        if(interactive() && .Platform$GUI=="Rgui"){
            GUI <<- new("WindowsGUI")
        } else {
            packageStartupMessage("wingui is most helpfull in Rgui on windows.")
        }
    }
    setLoadAction(myLoad)
}
# nocov end


#' @title Windows Rgui accessor class
#' 
#' @details 
#' This is a singleton class with instance \code{GUI}.
#' The is a \link[methods:ReferenceClasses]{reference class} building off the 
#' windows API.
#' 
#' @format An instance of WindowsGUI reference class.
#' 
#' @description
#' This object is defined if using the Rgui interface on windows.
#' Available attributes are available through attributes of \code{GUI}
#' \enumerate{
#'    \item \code{$Title} The title of the window.
#'    \item \code{$opacity} Percentage of the opacity of the window.
#'    \item \code{$transparency} Percentage of the transparency of the window, wrapper of opacity
#'    \item \code{$on.top} bollean of if the window is fixed on top. 
#'    \item \code{$layered} bollean of if the window is considered layered.
#'    \item \code{$.pid} The process ID.
#'    \item \code{$.hwnd} The window handle.
#' }
#' @examples
#' \dontrun{
#' GUI$Title
#' GUI$Title <- "My Title"
#' GUI$opacity <- 0.90      # set to 90%
#' GUI$transparency         # should now be 0.10
#' GUI$on.top <- T          # Rgui will now always be on top
#' }
#' 
#' @export
GUI <- NULL



