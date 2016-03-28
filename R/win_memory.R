#` @export
win_memory <- 
function(print=TRUE  #< Should a summary be printed out.
        ){
    #! Get the memory usage for the current machine.
    #! 
    #! Uses the API call GlobalMemoryStatusEx to retrieve information
    #! about the memory usage on the machine.
    #! 
    #! @seealso `<win_processes>`
    if(!is.loaded("GlobalMemoryStatusEx"))
        dyn.load( Sys.which("Kernel32.dll"))
    r <- raw(64)
    r[[1]] <- as.raw(64L)
    s <- .C("GlobalMemoryStatusEx", r)[[1]]
    mem <-  list( Size                  = wingui:::raw2int(s[1:4 + 4L*0])
                , Percent               = wingui:::raw2int(s[1:4 + 4L*1])
                , Physical              = wingui:::raw2int(s[1:8 + 8L*1L])
                , Available             = wingui:::raw2int(s[1:8 + 8L*2L])
                , TotalPage             = wingui:::raw2int(s[1:8 + 8L*3L])
                , AvailPage             = wingui:::raw2int(s[1:8 + 8L*4L])
                , TotalVirtual          = wingui:::raw2int(s[1:8 + 8L*5L])
                , AvailVirtual          = wingui:::raw2int(s[1:8 + 8L*6L])
                , AvailVirtualExtended  = wingui:::raw2int(s[1:8 + 8L*7L])
                ) 
    if(print){
        sprintf("%.0f/%.0f", mem$Available, mem$Physical) %>% cat("\n")
        txtProgressBar(0, 100, mem$Percent, style=3
            , width = min(59, floor(getOption("width")*.8))) %>% 
            close
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
