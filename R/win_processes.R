{###############################################################################
#  win_processes.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################

#' List machine processes
#'
#' @param verbose Verbose output.
#'
#' @return a data.frame with process information
#' @importFrom lubridate dhours dminutes dseconds
#' @export
win_processes <-
function( verbose = TRUE  #< Verbose output.
        ){
    "List machine processes"
    output <- system2("tasklist", c(if(verbose)"/v", "/fo csv"), stdout=T)
    file <- textConnection(output)
    on.exit(close(file))
    wp <- utils::read.csv( file, na.strings="N/A")
    names(wp) <- gsub("\\.$", "", names(wp))
    wp$Mem.Usage = as.numeric(gsub(" K", "", gsub(",", "", wp$Mem.Usage)))
    wp$CPU.Time  =(lubridate::dhours  (as.integer(gsub("(\\d+):(\\d+):(\\d+)", "\\1", wp$CPU.Time)))
                 + lubridate::dminutes(as.integer(gsub("(\\d+):(\\d+):(\\d+)", "\\2", wp$CPU.Time)))
                 + lubridate::dseconds(as.integer(gsub("(\\d+):(\\d+):(\\d+)", "\\3", wp$CPU.Time)))
                 )
    wp$Session.Name = tolower(wp$Session.Name)
    wp
}

#' Check for a running process.
#'
#' @param name     Program name, Process ID, or Session Name.
#' @param server   server to check on, if `NULL` defaults to local host.
#' @param session  session to filter for.
#'
#' @return A logical indicating if there exists a process running.
#' @export
win_process_running <-
function( name
	    , server=NULL
	    , session=NULL
	    ){
    output <-
	system2( "QUERY"
	       , c("PROCESS", name)
	       , stdout=TRUE)
    if(any(grepl("No Process exits", output))) return(FALSE)
    output <- gsub("^[ >]", '', output)
    file <- textConnection(output)
    on.exit(close(file))
    info <- utils::read.csv( file, na.strings="N/A")
    return(structure(TRUE, info=info))
    #< A logical indicating if there exists a process running.
}

#' List logged on users
#'
#' @return data.frame of user information
#' @export
win_users <-
function(){
    stopifnot(requireNamespace("stringr"))
    output <- suppressWarnings(system2("query", "user", stdout=TRUE))
    output <- stringr::str_sub(output, 2)

    x <- stringr::str_split(output, "  +")

    y <- do.call(rbind, x[-1])
    colnames(y) <- x[[1]]
    z <- as.data.frame(y)
    z[["LOGON TIME"]] <- as.POSIXct(z[["LOGON TIME"]], format="%m/%d/%Y %I:%M %p")
    return(z)
}
if(FALSE){ #testing
    library(plyr)
    processes <- win_processes()
    head(processes)

    arrange(processes, ImageName)
    "NppToR.exe" %in% win_processes()$ImageName

    using(plyr)
    ddply( win_processes(), .(Session), summarize
         , Total.Mem = sum(Mem.Usage)
         )
}

LoadPercentage <- NULL #< variable check confuser.

#' list the load on the CPU.
#' @export
win_load <- function(){
    "list the load on the CPU."
    output <- system2("wmic", c("cpu", "get", "loadpercentage,CurrentClockSpeed,MaxClockSpeed,Name", "/format:csv"), stdout=TRUE)
    load.data <- read.csv(textConnection(output))
    load.data$LoadPercentage=load.data$LoadPercentage/100
    load.data[,c('Node', 'Name', 'LoadPercentage', 'CurrentClockSpeed', 'MaxClockSpeed')]
    #! @Return A <data.frame> with Node, Processor Name,
    #^ Current load percent (0-1), Current clock speed (Mhz),
    #^ and Max Clock Speed (Mhz)
}

#' Kill Processes
#'
#' @param ...    Thrown Away, used to force user to specify full argument name.
#' @param image  The executable name, such as 'Rgui.exe'
#' @param pid    process ID, a number
#' @param force  force close?
#' @param title  Filter by title
#'
#'
#' @export
win_kill <-
function( ...
        , image
	    , pid
	    , force=TRUE
	    , title=NULL
	    ){
    if(!missing(image))
        for(i in image)
            system2("taskkill", c(if(force)"/F", "/IM", i))
    if(!missing(pid))
        for(p in pid)
            system2("taskkill", c(if(force)"/F", "/IM", p))
    if(!missing(title))
        system2("taskkill", c(if(force)"/F", "/FI", shQuote(paste0("Windowtitle eq ", title))))
}

