{###############################################################################
#  win_memory.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################

#' Get the memory usage for the current machine.
#' 
#' @param print Should a summary be printed out?
#' 
#' Uses the API call GlobalMemoryStatusEx to retrieve information
#' about the memory usage on the machine.
#'
#' @seealso `<win_processes>`
#' @export
#' @importFrom utils txtProgressBar
win_memory <- 
function(print=TRUE  #< Should a summary be printed out?
        ){
    if(!is.loaded("GlobalMemoryStatusEx"))
        dyn.load( Sys.which("Kernel32.dll"))
    r <- raw(64)
    r[[1]] <- as.raw(64L)
    s <- .C("GlobalMemoryStatusEx", r)[[1]]
    mem <-  list( Size                  = raw2int(s[1:4 + 4L*0])
                , Percent               = raw2int(s[1:4 + 4L*1])
                , Physical              = raw2int(s[1:8 + 8L*1L])
                , Available             = raw2int(s[1:8 + 8L*2L])
                , TotalPage             = raw2int(s[1:8 + 8L*3L])
                , AvailPage             = raw2int(s[1:8 + 8L*4L])
                , TotalVirtual          = raw2int(s[1:8 + 8L*5L])
                , AvailVirtual          = raw2int(s[1:8 + 8L*6L])
                , AvailVirtualExtended  = raw2int(s[1:8 + 8L*7L])
                ) 
    if(print){
        cat(sprintf("%.0f/%.0f", mem$Available, mem$Physical), "\n")
        close(utils::txtProgressBar(0, 100, mem$Percent, style=3
            , width = min(59, floor(getOption("width")*.8))))
            
    }
    #! ```@references
    #!  - bibtype: Manual
    #!    title: GlobalMemoryStatusEx function
    #!    year: 2016
    #!    url: https://msdn.microsoft.com/en-us/library/windows/desktop/aa366589(v=vs.85).aspx
    #! ```
    return(invisible(mem))
    #< invisibly returns a `data.frame` the memory usage on the machine.
}
#` @export
win_load <- function(){
    #! Get the percentage of load on the machine 
    output <- 
        system2("wmic", list("CPU", "GET", "LoadPercentage", "/format:csv"), stdout=TRUE)
    #! ```@references
    #!  - bibtype: Manual
    #!    title: WMIC - Take Command-line Control over WMI
    #!    year: 2016
    #!    url: https://msdn.microsoft.com/en-us/library/bb742610.aspx
    #! ```
    read.csv(textConnection(output))[[2]]    
    #< An integer (0-100) representing the percent load on the machine.
}

#' Lists the resource useage summarized by user.
#' 
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
