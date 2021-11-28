
read_stack_var_year <- function(var = 'pr', year = 2018, 
                                path = "envicloud/chelsa/chelsa_V2/GLOBAL/monthly"){
  require(terra)
  require(rgdal)
  if(!var %in% c("pr", "tas", "tasmax", "tasmin")) stop("not good var")
  
  xstring <- paste('_',var, '_', sep='')
  files   <- list.files( file.path(path, var), full.names = T)
  ms <- c(paste0("0",1:9), 10,12)
  
  files_sel <- paste0("CHELSA_pr_",ms,"_",year, "_V.2.1.tif")
  
  if(sum(!files_sel %in% files)) stop("error missing files")

  layers <- rast(file.path(path, var,files_sel[1]))
  for (m in 2:12){
    layer_t <- rast(file.path(path, var,files_sel[m]))
    add(layers) <- layer_t
  }
return(layers)
  
}

extract_var_year <- function(coords= NA, var = "pr", year = 2018){
  # df <- read.csv("FunDiv_plots_Nadja.csv", stringsAsFactors=FALSE)
  df <- read.csv("mastifPlotData.csv", stringsAsFactors=FALSE)
  #coords <- df[, c("longitude", "latitude")] 
  #names(coords) <-c("lon", "lat")
  coords <- df[, c("lon", "lat")] 
  
  stacks <- read_stack_var_year(var, year)
  res <- terra::extract(stacks, coords)
  return(res)
}


library(tictoc)
tic()
res <- extract_var_year()
toc()
sum(is.na(res[, 1]))


tileChelsa2 <- function(vars = c('pr'), 
                       path = "/Users/jimclark/makeMastOnJimClark/makeMast/climateBuild/terraClimateFiles"){
  vars = c('pr')
  path <- "envicloud/chelsa/chelsa_V2/GLOBAL/monthly/pr"
  # generates tiles for chelsa data, run when new years are added
  
  require(raster)
  require(rgdal)
  
  # wpath <- "~/Library/Mobile Documents/com~apple~CloudDocs/Documents/makeMastOnJimClark/makeMast/climateBuild/chelsaTiles"
  wpath <- "envicloud/chelsa/chelsa_V2/GLOBAL/monthly"
  
  
  monNames <- as.character(1:12)
  monNames[ nchar(monNames) == 1] <- paste('0', monNames[ nchar(monNames) == 1], sep='' )
  
  mstart <- 1
  ystart <- 1
  
  for(k in 1:length(vars)){
    
    xstring <- paste('_',vars[k], '_', sep='')
    files   <- list.files( path, full.names = T)
    files   <- files[ grep( xstring, files ) ]
    tmp     <- columnSplit(files,  xstring)
    dates   <- columnSplit( tmp[,2], '_' )
    months  <- dates[,1]
    years   <- dates[,2]
    
    if(length(years) == 0)next
    
    kpath <- paste(wpath, vars[k], sep='/')
    
    for(j in ystart:length(years)){
      
      library(envirem)
      library(rgdal)
      jfile <- files[ grep( years[j], files ) ]
      mj    <- length( jfile )
      
      tiles <- numeric(0)
      xk    <- numeric(0)
      
      for(m in mstart:mj){
        layer <- raster( jfile[m] )
        
        dname <- paste( vars[k], years[j], monNames[m], sep='/' )
        if( !dir.exists(vars[k]) ) dir.create(vars[k])
        if( !dir.exists(paste( vars[k], years[j], sep= "/")) ) dir.create(paste( vars[k], years[j], sep= "/"))
        if( !dir.exists(paste( vars[k], years[j], monNames[m], sep= "/")) ) dir.create(paste( vars[k], years[j], monNames[m], sep= "/"))
        
        
        n_vertical_tile = 25   
        split_raster(jfile[m], s = n_vertical_tile, outputDir = dname,
                     gdalinfoPath = "/Library/Frameworks/GDAL.framework/Programs/gdalinfo" , 
                     gdal_translatePath = "/Library/Frameworks/GDAL.framework/Programs/gdal_translate")
   rm(layer)
   gc()
      }
    }
  }
}









start <- Sys.time()
tileChelsa()
end  <- Sys.time()
t1 <- end - start

start <- Sys.time()
tileChelsa2()
end  <- Sys.time()
t2 <- end - start

