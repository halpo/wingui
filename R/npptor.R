{###############################################################################
#  npptor.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################
# nocov start
find_npp <- 
function(){
    exe <- 
    file.path( utils::readRegistry("SOFTWARE\\Notepad++", "HLM", view="32-bit")[[1]]
             , "Notepad++.exe"
             )
    if(file.exists(exe)) return(normalizePath(exe))
    exe <- file.path("C:", "Program Files (x86)", "Notepad++", "Notepad++.exe", fsep="\\")
    if(file.exists(exe)) return(normalizePath(exe))
    exe <- file.path("C:", "Program Files", "Notepad++", "Notepad++.exe", fsep="\\")
    if(file.exists(exe)) return(normalizePath(exe))
    return(invisible(NULL))
}
find_npptor <- 
function(){
    exe <- file.path(Sys.getenv("PROGRAMFILES"), "NppToR", "NppToR.exe", fsep="\\")
    if(file.exists(exe)) return(normalizePath(exe))
    exe <- file.path(Sys.getenv("PROGRAMFILES(X86)"), "NppToR", "NppToR.exe", fsep="\\")
    if(file.exists(exe)) return(normalizePath(exe))
    exe <- file.path(Sys.getenv("APPDATA"), "NppToR", "NppToR.exe", fsep="\\")
    if(file.exists(exe)) return(normalizePath(exe))
    return(invisible(NULL))
}
is_npptor_running <- 
function(){
    win_process_running("NppToR")
}



#' Launch NppToR
#' 
#' @param ... passed on as arguments to npptor
#' @param exe path to the NppToR exacutable
#' @param startup   should the '-startup' parameter be passed to npptor?
#' @param overwrite if TRUE do not attempt to start if NppToR is running.
#' 
#' @export
npptor <- 
function( ...           
        , exe       = getOption("wingui::npptor::exe", find_npptor())
        , startup   = getOption("wingui::npptor::startup", is_r_startup())
        , overwrite = getOption("wingui::npptor::overwrite", !startup)
        ){
    npp.loc <- getOption("wingui::Notepad++", find_npp())
    args <- 
        c( "-rhome", R.home()
         , if(!is.null(npp.loc)) c("-npp", npp.loc)
         , if(startup) "-startup"
         , ... 
         )

    if(is.null(exe))
        stop( "NppToR exe could not be found, "
            , "please specify location in the 'wingui::npptor' option.")
    if(!overwrite && is_npptor_running()) return(invisible(NULL))
    system2(exe, list(...), wait=FALSE, invisible=FALSE)
}

#' Launch Notepad++
#' 
#' @param file  file to open in Notepad++
#' @param new   open in a new instance?
#' @param exe   Path to Notepad++ executable.
#' 
#' @export
npp <- 
function( file  = NULL
        , new   = FALSE
        , exe   = getOption("wingui::Notepad++", find_npp())
        ){
	args <- NULL
	if(is.character(file))
		args <- shQuote(normalizePath(file))
	if(new){
		args <- c("-multiInst", args)
	}
    if(!is.null(exe))
        system2(exe, args, wait=F, invisible=F)
}
# nocov end
