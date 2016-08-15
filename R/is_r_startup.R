{###############################################################################
#  is_r_startup.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################

# nocov start

#' Check if R is in the startup sequence.
#' 
#' @export
is_r_startup<- function(){
    root <- sys.call(1)
    !is.null(root) && (deparse(root) == ".First.sys()")
}
# nocov end