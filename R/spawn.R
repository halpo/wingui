
#' Spawn an additional R gui
#' 
#' @param wd Working directory
#' @param restore Restore session?
#' @param save Save on exit?
#' @param vanilla pass --vanilla flag see \link{Startup}
#' 
#' @return Called for side effect.
#' @export
spawnR <- 
function( wd      = getwd() #< [character] Working directory
        , restore = FALSE   #< [logical] Rrestore session
        , save    = FALSE   #< [logical] save on exit
        , vanilla = FALSE   #< [logical] pass --vanilla flag see <Startup>
        ){#! Open a new session
    #! Spawn an additional 
    if(.Platform$GUI!="Rgui")
        stop("spawnR only works within Rgui.")
    if(!missing(wd) && wd != getwd()){
        old.dir <- getwd()
        on.exit(setwd(old.dir))
        setwd(wd)
    }
	args <- character(0)
	if(!restore)
		args <- c(args, '--no-restore')
	if(vanilla)
		args <- c(args, '--vanilla')
	if(!save)
		args <- c(args, '--no-save')
	system2(file.path(R.home("bin"), "Rgui.exe"), args
	       , wait=FALSE, stdout=FALSE, stderr=FALSE, invisible=FALSE)
}


#' Run a file in a separate Batch mode.
#'
#' @param file the file to run.
#'
#' @return Called for the side effect of creating a separate process.
#' @export
BATCH <- function(file){
	system2( list.file(R.home("bin"), "Rcmd", full.names=TRUE)
	       , sprintf("BATCH %s", shQuote(file))
		   , wait=FALSE, invisible=TRUE)
}

in_dir <- function(dir, code){
    old.dir <- getwd()
    on.exit(setwd(old.dir))
    setwd(dir)
    force(code)
}
