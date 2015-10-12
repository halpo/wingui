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
#' 
#' @import Rcpp
#' @import methods
#' @useDynLib wingui
NULL

if(!exists(".packageName", inherit=F))
    .packageName <- 'wingui'

if(.Platform$OS.type=="windows" && .Platform$GUI=="Rgui"){
    setRcppClass("WindowsGUI", module='wingui', saveAs="WindowsGUI"
    , methods=list(show=function(){
        cat("Windows GUI (", .hwnd, ")\n")  
    }))
    myLoad <- function(ns){
        if(interactive()){
            GUI <<- new("WindowsGUI")
        } else {
            packageStartupMessage("wingui is most helpfull in interactive windows situations.")
        }
    }
    setLoadAction(myLoad)
}



#' @title Windows Rgui accessor class
#' 
#' @details 
#' This is a singleton class with instance \code{GUI}.
#' The is a \link[methods:ReferenceClasses]{reference class} building off the 
#' windows API.
#' 
#' @format An instance of WindowsGUI reference class.
#' 
#' @Description
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
#' }
#' 
#' @export
GUI <- NULL



