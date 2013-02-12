.onLoad <- function(libname, pkgname){
   # require("methods", character.only=TRUE, quietly=TRUE)
  stopifnot("package:methods" %in% search())
    loadModule('wintitle', TRUE)
}



# set_win_title <-
# function(title){}
