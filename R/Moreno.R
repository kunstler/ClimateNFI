#' Read Moreno daily climatic data
#'
#' @description Download, write in disk and and return as stack Moreno climate file from FTP server
#' @param tiles.in Character vector containing tiles to download (ex: "I_2")
#' @param country.in Character vector containing the countries of each tile (ex: "france")
#' @param year.in Numeric vector containing the years
#' @return A list, each element being a stack containing meant temperature for a given tile-year combination. 
get_Tmean_Moreno <- function(country.in = c("spain", "germany", "finland"), 
                             tiles.in = c("A_9", "F_6", "I_2"), 
                             year.in = c(2000, 2000, 2000)){
  # Directory to store Moreno daily data
  dirclimate = paste0(getwd(), "/data/Moreno")
  if(!dir.exists(dirclimate)) dir.create(dirclimate) 
  
  # Initialize output
  yr.mean.in <- list()
  
  # Loop on all tiles
  for(i in 1:length(tiles.in)){
    print(paste0("Getting daily data of ", year.in[i], ", for tile ", tiles.in[i], " located in ", country.in[i]))
    
    # Check existence and if needed create directories
    if(!dir.exists(paste(dirclimate, country.in[i], sep = "/"))){
      dir.create(paste(dirclimate, country.in[i], sep = "/"))} 
    if(!dir.exists(paste(dirclimate, country.in[i], tiles.in[i], sep = "/"))){
      dir.create(paste(dirclimate, country.in[i], tiles.in[i], sep = "/"))}
    
    
    # Tmin
    print("---Getting Tmin")
    
    url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tiles.in[i]),"/Tmin",year.in[i],"_",tiles.in[i],".hdr", sep="")
    output_file <- paste(dirclimate,"/", country.in[i],"/", tiles.in[i],"/Tmin",year.in[i],"_",tiles.in[i],".hdr", sep="")
    if(!file.exists(output_file)) try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
    
    
    url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tiles.in[i]),"/Tmin",year.in[i],"_",tiles.in[i],".tif", sep="")
    output_file <- paste(dirclimate,"/", country.in[i],"/", tiles.in[i],"/Tmin",year.in[i],"_",tiles.in[i],".tif", sep="")
    if(!file.exists(output_file)) try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
    
    
    # Tmax
    print("---Getting Tmax")
    
    url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tiles.in[i]),"/Tmax",year.in[i],"_",tiles.in[i],".hdr", sep="")
    output_file <- paste(dirclimate,"/", country.in[i],"/", tiles.in[i],"/Tmax",year.in[i],"_",tiles.in[i],".hdr", sep="")
    if(!file.exists(output_file)) try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
    
    url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tiles.in[i]),"/Tmax",year.in[i],"_",tiles.in[i],".tif", sep="")
    output_file <- paste(dirclimate,"/", country.in[i],"/", tiles.in[i],"/Tmax",year.in[i],"_",tiles.in[i],".tif", sep="")
    if(!file.exists(output_file)) try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
    
    
    # Tmean
    print("---Getting Tmean")
    yr.max.in <- stack(paste(dirclimate,"/", country.in[i],"/", tiles.in[i],"/Tmax",year.in[i],"_",tiles.in[i],".tif", sep=""))
    yr.min.in <- stack(paste(dirclimate,"/", country.in[i],"/", tiles.in[i],"/Tmin",year.in[i],"_",tiles.in[i],".tif", sep=""))
    yr.mean.in_i <- ((yr.max.in + yr.min.in)/2)/100
    yr.mean.in[[i]] <- yr.mean.in_i
  }
  names(yr.mean.in) <- paste(country.in, tiles.in, year.in, sep = "_")
  return(yr.mean.in)
}