# To confuse the code checker
Mem.Usage <- 
CPU.Time <- 
Session.Name <-
NULL

#' List machine processes
#' 
#' @param verbose Verbose output.
#' 
#' @return a data.frame with process information
#' @export
win_processes <- 
function( verbose = TRUE  #< Verbose output.
	){
    "List machine processes"
    stopifnot(requireNamespace("lubridate"))
    output <- system2("tasklist", c(if(verbose)"/v", "/fo csv"), stdout=T)
    file <- textConnection(output)
    on.exit(close(file))
    wp <- utils::read.csv( file, na.strings="N/A")
    names(wp) <- gsub("\\.$", "", names(wp))
    transform( wp
             , Mem.Usage = as.numeric(gsub(" K", "", gsub(",", "", wp$Mem.Usage)))
             , CPU.Time  = lubridate::dhours(  as.integer(gsub("(\\d+):(\\d+):(\\d+)", "\\1", CPU.Time)))
                         + lubridate::dminutes(as.integer(gsub("(\\d+):(\\d+):(\\d+)", "\\2", CPU.Time)))
                         + lubridate::dseconds(as.integer(gsub("(\\d+):(\\d+):(\\d+)", "\\3", CPU.Time)))
             , Session.Name = tolower(Session.Name)
             )
    #! @return a data.frame with process information
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
function( name	    	#< Program name, Process ID, or Session Name.
	, server=NULL  	#< server to check on, if `NULL` defaults to local host.
	, session=NULL  #< session to filter for.
	){
    #' Check for a running process.
    output <- 
	system2( "QUERY"
	       , c("PROCESS", name)
	       , stdout=TRUE)
    if(any(grepl("No Process exits", output))) return(FALSE)
    output <- gsub("^[ >]", '', output)
    file <- textConnection(output)
    on.eqxit(close(file))
    info <- utils::read.csv( file, na.strings="N/A")
    return(structure(TRUE, info=info))
    #' A logical indicating if there exists a process running.
}
#' List logged on users
#' 
#' @return data.frame of user information
#' @export
win_users <-
function(){
    "List logged on users"
    stopifnot(requireNamespace("stringr"))
    output <- system("query user", intern=TRUE)
    output <- stringr::str_sub(output, 2)
    
    x <- stringr::str_split(output, "  +")
    
    y <- do.call(rbind, x[-1])
    colnames(y) <- x[[1]]
    z <- as.data.frame(y)
    z[["LOGON TIME"]] <- as.POSIXct(z[["LOGON TIME"]], format="%m/%d/%Y %I:%M %p")
    return(z)
    #! data.frame of user information
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

#' list the load on the CPU.
#' @export
win_load <- function(){
    "list the load on the CPU."
    system2("wmic", c("cpu", "get", "loadpercentage"))
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
function( ...       	#< Thrown Away, used to force user to specify full argument name.
        , image     	#< The executable name, such as 'Rgui.exe'
	, pid       	#< process ID, a number
	, force=TRUE	#< force close?
	, title=NULL	#< Filter by title
	){
    "Kill processes"
    if(!missing(image))
        for(i in image)
            system2("taskkill", c(if(force)"/F", "/IM", i))
    if(!missing(pid))
        for(p in pid)
            system2("taskkill", c(if(force)"/F", "/IM", p))    
    if(!missing(title))
        system2("taskkill", c(if(force)"/F", "/FI", shQuote(paste0("Windowtitle eq ", title))))
}

#' Lists the resource useage summarized by user.
#' 
#' @Suggests plyr
#' @Suggests lubridate
#' @export
whos_the_hog <- function(){
    "Lists the resource useage summarized by user."
    stopifnot(requireNamespace("plyr"), requireNamespace("lubridate"))
    wp <- win_processes(verbose=TRUE)
    users <- win_users()
    names(users) <- c("Username", "Session.Name", "Session.ID", "State", "Idle.Time", "Logon.Time")
    joined <- merge( wp[setdiff(names(wp), "User.Name")]
                   , users, by="Session.Name")
    
    plyr::arrange(
	plyr::ddply( joined, plyr::as.quoted("Username"), plyr::summarize
                   , Mem.Usage = sum(Mem.Usage)
                   , N.Processes = NROW(Mem.Usage)
                   , CPU.Time = sum(CPU.Time)
                   ), Mem.Usage, CPU.Time)
}
