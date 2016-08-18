{###############################################################################
#  win_read_lnk.R
#  2013 Andrew Redd
#  
#  This file is released under the terms of the MIT license.
#  Please See http://www.r-project.org/Licenses/MIT
}###############################################################################

raw2int <- function(x){
  round(sum(as.integer(x) * 2L^(8*(seq(0, length(x)-1)))))
}
if(FALSE){#! @testing
    x <- 1234567890
    y <- "499602D2"
    
    r <- raw(4)
    r[[4]] <- as.raw(0x49)
    r[[3]] <- as.raw(0x96)
    r[[2]] <- as.raw(0x02)
    r[[1]] <- as.raw(0xD2)
    
    expect_equal(raw2int(r), 1234567890)
}
raw2CLSID <- function(r){
    stopifnot(length(r) == 16 && is.raw(r))
    paste( sep="-"
         , paste0(rev(r[1:4]), collapse='')
         , paste0(   (r[5:6]), collapse='')
         , paste0(   (r[7:8]), collapse='')
         , paste0(   (r[9:10]), collapse='')
         , paste0(   (r[11:16]), collapse='')
         )
}
if(FALSE){#! @test
    r <- raw(16)
    r[[16]] <- as.raw(0xFF)
    r[[15]] <- as.raw(0xEE)
    r[[14]] <- as.raw(0xDD)
    r[[13]] <- as.raw(0xCC)
    r[[12]] <- as.raw(0xBB)
    r[[11]] <- as.raw(0xAA)
    r[[10]] <- as.raw(0x99)
    r[[09]] <- as.raw(0x88)
    r[[08]] <- as.raw(0x77)
    r[[07]] <- as.raw(0x66)
    r[[06]] <- as.raw(0x55)
    r[[05]] <- as.raw(0x44)
    r[[04]] <- as.raw(0x33)
    r[[03]] <- as.raw(0x22)
    r[[02]] <- as.raw(0x11)
    r[[01]] <- as.raw(0x00)
    expect_equal(raw2CLSID(r), "33221100-4455-6677-8899-aabbccddeeff")
}

blockReader <- 
function( block
        , start       = attr(block, "start")
    ){
    size <- length(block)
    if(is.null(start))
        start <- 0
    offset <- start
    get_exact <- function(exact){ return(block[exact]) }
    peek <- function(size=1){ get_exact(seq.int(size)+offset) }
    remaining <- function(){ peek(size-offset) }
    get <- function(size=4){
        on.exit(offset <<- offset+size)
        peek(size)
    }
    get_int <- function(size=4){raw2int(get(size))}
    get_clsid <- function(){raw2CLSID(get(16))}
    get_string <- function(unicode=FALSE, size.prefixed=FALSE){
        if(unicode){
            r <- remaining()
            if(size.prefixed){
                m <- get_int(2)
            } else {
                w <- which(colSums(matrix(r==0, nrow=2))==2)
                if(length(w)){
                    m <-(min(w)-1)*2 
                    on.exit(offset <<- offset + m + 2)
                }else{
                    m <- length(r)
                    on.exit(offset <<- offset + m)
                }
            }
            iconv(list(r[1:m]), from = 'UTF-16LE', to = 'UTF-8')
        }else{
            n <- if(size.prefixed) get_int(1) else min(which(remaining()==0))
            rawToChar(get(n))
        }
    }
    reset <- function(x=start){offset <<- x}
    sub <- function( size.block.size = 4
                   , size            = raw2int(peek(size.block.size))
                   , adjust.start    = 0
                   ){
        on.exit(offset <<- offset + size + adjust.start)
        sub_exact(offset + adjust.start, size=size, start = size.block.size - adjust.start)
    }
    sub_exact <- function(offset, size, ...){
        block = get_exact(seq.int(size)+offset)
        blockReader(block, ...)
    }
    
    consume <- function(){
        w <- which(block == 0)
        while(peek(1)==0) get(1)
    }
    more <- function(){offset < length(block)}
    left <- function(){length(block) - offset}
    back <- function(size = 4){offset <<- offset - size}
    return(structure(environment(), class=c("blockReader", "environment"), start=start))
}
readBlock <- function(filename, size.block.size = 4, ...){
    raw.size <- readBin(filename, "raw", size.block.size)
    size <- raw2int(raw.size)
    block <- readBin(file, "raw", size - size.block.size)
    block <- c(raw.size, block)
    offset <- size
    structure(block, start=offset)
}

parseLnkHeader <- 
function( header #< blockReader for the header.
        , ...){
    if(inherits(header, "raw"))
        header <- blockReader(header, 4)
    link.clsid      <- header$get_clsid()
    stopifnot(link.clsid=="00021401-0000-0000-c000-000000000046")
    
    flags           <- header$get(4)
    file.flags      <- header$get(4)
    creation.time   <- header$get(8)  #TODO: Make a function to convert to file time object.
    access.time     <- header$get(8) 
    write.time      <- header$get(8)
    file.size       <- header$get_int(4)
    icon.index      <- header$get(4)
    show.command    <- header$get(4)
    hotkey          <- header$get(2)
    reserved        <- header$get(10)
    
    flags          <- as.logical(rawToBits(flags))
    names(flags) <- { c( "HasLinkTargetIDList"
                       , "HasLinkInfo"
                       , "HasName"
                       , "HasRelativePath"
                       , "HawWorkingDirectory"
                       , "HasArguments"
                       , "HasIconLocation"
                       , "IsUnicode"
                       , "ForceNoLinkInfo"
                       , "HasExpString"
                       , "RunInSeparateProcess"
                       , "Unused1"
                       , "HasDarwinID"
                       , "RunAsUser"
                       , "HasExpIcon" # the shell link is saved with an icon environment data block
                       , "NoPidlAlias" # The file system is represented in the shell namespace when the path to an item is parsed into an ID list
                       , "unused2"
                       , "RunWithShimLayer" # The shell link is saves with aShimDataBlock
                       , "ForceNoLinkTrack" # the TrackerDataBlock is ignored
                       , "EnableTargetMetadata" # The shell link attemps to collect target properties ans store them in the PropertyStoreDataBlock when the link target is set.
                       , "DisableLinkPathTracking" # the environment variable data block is ignored
                       , "DisableKnownFolderTracking" # the special folder data blockand the known folder data bloclk are ignored when loading the shell link. if this bit is set these extra data blocks shouldnot be saved when saving the shell link
                       , "DisableKnownFolderAlias" # If the link has a known folder data block the unaliases form of the known folder IDList should be used when translating the target IDList at the time that the link is loaded.
                       , "AllowLinkToLink" # creating a link that thereferences another link is enabled.  Otherwise specifying a link as the target IDLIstSHOULD NOT be allowed
                       , "UnaliasOnSave"  # When saving a link for whish the target IDList is under a known folder, either the unaliased form of that known folder or the target IDLIst SHOULD be used.
                       , "PreferEnvironmentPath" # Target IDList SHOULD NOT be stored; instead, the path specified in the environment VariableDataBlock SHOULD be used to refer to the target.
                       , "KeepLocalIDListForUNCTarget" # when the target is a UNC name that refers to a location on a local machine, the local path IDList in the PropertyStoreDataBlock Should Be Stored so that it can be used when the link is loaded on the local machine.
                       )}
    
    file.flags <- as.logical(rawToBits(file.flags))
    names(file.flags) <-{ c( "readonly", "hidden", "system", "reserved", "directory", "archive"
                           , "reserved", "normal", "temporary", "sparse", "reparse_point"
                           , "compressed", "offline", "not_indexed", "encrypted"
                           )}
    
    return(as.list(environment()))
}
parseTargetIDList <- function(idlist){
    if(inherits(idlist, "raw"))
        idlist <- blockReader(idlist)
    items <- list()
    while(idlist$more() && raw2int(idlist$peek(2)) ){
        item.size <- raw2int(idlist$get(2))
        items <- c(items, list(idlist$get(item.size-2)))
        while(idlist$more() && !raw2int(idlist$peek(1))) idlist$get(1)
    }
    return(items)
}
readTargetIDList <- function(f, ...){#read target IDList
    idlist <- readBlock(f, 2)
    parseTargetIDList(idlist)
}
parseLinkInfo <- function(li, ...){
    {# Header extraction
        header <- li$sub(adjust.start = -4)
        flags  <- structure( as.logical(rawToBits(header$get(4))[1:2])
                           , names=c("VolumeIDAndLocalBasePath", "CommonNetworkRelativeLinkAndPathSuffix"))
        volume.id.offset                    <- header$get_int()
        local.base.path.offset              <- header$get_int()
        if(!flags[1]){
            stopifnot( volume.id.offset       == 0
                     , local.base.path.offset == 0
                     )
        }
        common.network.relative.link.offset <- header$get_int()
        common.path.suffix.offset           <- header$get_int()
        if(!flags[2]){
            stopifnot( common.network.relative.link.offset == 0
                     , common.path.suffix.offset           == 0
                     )
        }
        if(header$size >= 0x24){
            local.base.path.offset.unicode    <- header$get_int()
            common.path.suffix.offset.unicode <- header$get_int()
            if(!flags[1]) stopifnot(local.base.path.offset.unicode    ==0)
            if(!flags[2]) stopifnot(common.path.suffix.offset.unicode ==0)
        } else {
            local.base.path.offset.unicode    <- NA
            common.path.suffix.offset.unicode <- NA
        }
    }
    if(flags['VolumeIDAndLocalBasePath']){
        vi <- li$sub()
        volume.id <- parseVolumeID(vi)
        
        if(li$offset != local.base.path.offset)
            li$offset <- local.base.path.offset
        link <- 
        local.base.path <- li$get_string()
        
    }
    if(flags['CommonNetworkRelativeLinkAndPathSuffix']){
        if(li$offset != common.network.relative.link.offset) li$reset(li$offset != common.network.relative.link.offset)
        common.network.relative.link <- 
            parseCommonNetworkRelativeLink(cn <- li$sub())
        if(common.path.suffix.offset > 0)
            common.path.suffix <- li$get_string()
        
        if(!is.na(common.path.suffix.offset.unicode)){
            li$reset(common.path.suffix.offset.unicode)
            common.path.suffix <- li$get_string(unicode=TRUE)
        }
        
        link <- file.path( common.network.relative.link$device.name
                         , common.path.suffix
                         )
    }
    
    #TODO unicode strings
    structure( link
             , env = as.list(environment()), raw=li)
}
parseVolumeID <- function(vi){
    volume.info.size <- raw2int(vi$get_exact(1:4))
    
    drive.type                  = vi$get_int()
    drive.serial.number         = vi$get_int()
    volume.label.offset         = vi$get_int()
    if(volume.label.offset == 0x14){
        volume.label.offset.unicode = vi$get_int()
        stop("notimplimented")
    } else {
        if(vi$offset != volume.label.offset) vi$offset <- volume.label.offset
        data <- vi$get_string()
    }
    list( drive.type          = drive.type         
        , drive.serial.number = drive.serial.number
        , volume.label.offset = volume.label.offset
        , data = data
        )
}
parseCommonNetworkRelativeLink <- function(cn){
    flags <- structure( as.logical(rawToBits(cn$get()))[1:2]
                      , names = c("ValidDevice", "ValidNetType"))
    net.name.offset            <- cn$get_int()
    device.name.offset         <- cn$get_int()
    network.provider.type      <- cn$get_int()
    if(net.name.offset > 0x14){
        net.name.offset.unicode    <- cn$get_int()
        device.name.offset.unicode <- cn$get_int()
    }
    net.name    <- cn$get_string()
    device.name <- cn$get_string()
    
    structure(as.list(environment()))
}

#' Read a windows '.lnk' file.
#' 
#' @param filename file to read.
#' @param ... discarded
#' 
#' @return file path to where the file points, most often specified relatively, along with
#' 		attribute data which contains the information used to parse the lnk file.
#' 
#' @export
read_lnk <- function(filename, ...){
    if(!file.exists(filename) && file.exists(.f <- paste0(filename, ".lnk")))
        filename <- .f
    total.size <- file.info(filename)$size
    all.bytes <- 
    bytes <- readBin(filename, "raw", total.size)
    reader <- blockReader(bytes, 0)
    header <- parseLnkHeader(reader$sub())
    
    if(header$flags["HasLinkTargetIDList"]){
        idlist <- reader$sub(2)
        TargetIDList <- parseTargetIDList(idlist)
        terminalid <- reader$get_int(2)
        stopifnot(terminalid==0)
    }
    if(header$flags["HasLinkInfo"]){
        link <- 
        link.info <- parseLinkInfo(li <- reader$sub(4))
    }
    if(reader$left() && header$flags["HasRelativePath"]){
        link <- 
        relative.path <- reader$get_string(header$flags["IsUnicode"], size.prefixed=TRUE)
    }
    if(reader$left() && header$flags["EnableTargetMetadata"]){
        xtra <- list()
        while(reader$left() > 4){
            xread <- reader$sub()
            sig <- xread$get_int()
            if(sig == 0xA0000003){
                xtra[["TrackerData"]] <- parseTrackerData(xread, sig)
            } else if(sig == 0XA0000009){
                xtra[["PropertyStore"]] <- parsePropertyStore(xread, sig)
            }
        }
    }
    return( 
        structure( link
                 , data = as.list(environment())
                 , class = c("WindowsLinkInfo", "character")
                 ))
}
if(FALSE){#' @test
    file <- system.file("test.lnk", package="wingui")
    expect_equal( as.character(read_lnk(file)), '.')
    
    info <- read_lnk(system.file("net.lnk", package="wingui"))
    
    expect_equal(as.character(info), file.path("G:", "\u4f60\u597d"))
    expect_true(env[['flags']][['CommonNetworkRelativeLinkAndPathSuffix']])
}


parsePropertyStore <- function(ps, sig = ps$get_int()){
    stopifnot(sig == 0xA0000009)
    return(list(sig=sig, "not implimented"))
}
GUID <- function(r){
    stopifnot( inherits(r, "raw")
             , length(r) ==16)
    list( data1 = r[1:4]
        , data2 = r[5:6]
        , data3 = r[7:8]
        , data4 = r[9:16]
        )
}
parseTrackerData <- function(read, sig = read$get_int()){
    stopifnot(sig == 0xA0000003)
    length  <- read$get_int()
    version <- read$get_int()
    machine.id <- read$get_string()
    droid         <- list(GUID(read$get(16)), GUID(read$get(16)))
    droid.birth <- list(GUID(read$get(16)), GUID(read$get(16)))
    return(as.list(environment()))
}

#' @export
print.WindowsLinkInfo <- function(x, ...){
    cat(attr(x, 'data')$filename, "\u2794", x[1], "\n")
    invisible(x)
}


if(F){ #TESTING
cd("~/Shortcuts")
filename <-"Adi - CAUTI.lnk"

fi <- file.info(filename)
bytes <- readBin(filename, "raw", fi$size*1.1)
reader <- blockReader(bytes)

# header
size <- raw2int(reader$peek(4))
header <- parseLnkHeader(reader$get(size))
header$flags[header$flags]
head(header$flags, 10)

# TargetIDList
size <- raw2int(reader$get(2))
IDList <- reader$get(size)

# link info
size <- raw2int(reader$peek(4))
block <- 
LinkInfo <- reader$get(size)

size <- raw2int(reader$peek(4))
block <- reader$get(size)
reader$left()

size <- raw2int(reader$peek(4))
block2 <- reader$get(size)

tail <- reader$get(reader$left())

head(bytes)
}
