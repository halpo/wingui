if(FALSE){
    using(dplyr)
    output <- system2("systeminfo", list("/fo", "LIST"), stdout=TRUE)
    grep("Memory", output, value=TRUE)



    output <- 
        system2("wmic", list("CPU", "GET", "LoadPercentage", "/format:csv"), stdout=TRUE) %>% cat(sep="\n")
        system2("wmic", list("CPU", "GET", "/?"), stdout=TRUE) %>% cat(sep="\n")
}

#' @export
win_memory <- function(print=TRUE){
    #! 
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
        close(txtProgressBar(0, 100, mem$Percent, style=3
            , width = min(59, floor(getOption("width")*.8))))
    }
    return(invisible(mem))
    #! @return a named list of memory usage statistics.
}

#' @importFrom plyr arrange ddply summarize as.quoted
#' @export
whos_the_hog <- function(){
    "Lists the resource useage summarized by user."
    stopifnot(requireNamespace("plyr"))
    wp    <- win_processes()
    users <- win_users()
    names(users) <- c("Username", "Session.Name", "Session.ID", "State", "Idle.Time", "Logon.Time")
    joined <- merge( wp[setdiff(names(wp), "User.Name")]
                   , users, by="Session.Name")
    
    plyr::arrange(
	plyr::ddply( joined, plyr::as.quoted("Username"), plyr::summarize
               , Mem.Usage   = sum(Mem.Usage)
               , N.Processes = NROW(Mem.Usage)
               , CPU.Time    = sum(CPU.Time)
               ), Mem.Usage, CPU.Time)
    #! @return a <data.frame> With total memory and CPU usage aggregated across
    #^ all process for each user on the system.
}
