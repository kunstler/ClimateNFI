#' Read daily climatic data for specific tile, year and country
#'
#' @description Download, write in disk and and return as stack Moreno climate file from FTP server
#' @param tiles.in Tile to download, as character (ex: "I_2")
#' @param country.in country where the tile is located, as character (ex: "france")
#' @param year.in year to download, as numeric (ex: 2000)
#' @param var.in variable to extract (ex: "Tmin")
get_var_Moreno <- function(tiles.in, country.in, year.in, var.in){
  dirclimate = paste0(getwd(), "/data/Moreno")
  
  # Check existence and if needed create directories
  if(!dir.exists(paste(dirclimate, country.in, sep = "/"))){
    dir.create(paste(dirclimate, country.in, sep = "/"))} 
  if(!dir.exists(paste(dirclimate, country.in, tiles.in, sep = "/"))){
    dir.create(paste(dirclimate, country.in, tiles.in, sep = "/"))}
  
  # Tmin
  print(paste0("---Downloading ", var.in, " from FTP server"))
  
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tiles.in), "/", var.in, year.in,"_",tiles.in,".hdr", sep="")
  output_file <- paste(dirclimate,"/", country.in,"/", tiles.in ,"/", var.in, year.in,"_",tiles.in,".hdr", sep="")
  if(!file.exists(output_file)) try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
  
  
  url <- paste("ftp://palantir.boku.ac.at/Public/ClimateData/TiledClimateData/", gsub("_", "/", tiles.in), "/", var.in, year.in,"_",tiles.in,".tif", sep="")
  output_file <- paste(dirclimate,"/", country.in,"/", tiles.in, "/", var.in, year.in,"_",tiles.in,".tif", sep="")
  if(!file.exists(output_file)) try(GET(url, authenticate('guest', ""), write_disk(output_file, overwrite = TRUE)))
  
  out <- stack(paste(dirclimate,"/", country.in,"/", tiles.in, "/", var.in, year.in,"_",tiles.in,".tif", sep=""))
  
  return(out)
}

#' Compute mean daily temperature for specific tile, year and country
#'
#' @description Compute mean daily temperature from Moreno
#' @param tiles.in Tile to download, as character (ex: "I_2")
#' @param country.in country where the tile is located, as character (ex: "france")
#' @param year.in year to download, as numeric (ex: 2000)
#' @param coords.in dataframe containing plot id (col 1) and coordinates (col 2 and 3) for which to download data
extract_Tmean_Moreno <- function(tiles.in, country.in, year.in, coords.in){
  
  out <- list()
  
  for(i in 1:length(tiles.in)){
    print(paste0("Extracting daily Tmean for tile ", tiles.in[i], 
                 " located in ", country.in[i], 
                 " for the year ", year.in[i]))
    
    # Get Tmin and Tmax
    Tmin.in <- get_var_Moreno(tiles.in[i], country.in[i], year.in[i], "Tmin")
    Tmax.in <- get_var_Moreno(tiles.in[i], country.in[i], year.in[i], "Tmax")
    
    # Restrict input coordinates to plots located within the tile
    data.in <- coords.in
    IDname0 <- colnames(data.in)[1]
    colnames(data.in) <- c("id", "longitude", "latitude")
    data.in <- data.in %>%
      filter(latitude >= extent(Tmax.in)[3]) %>%
      filter(latitude <= extent(Tmax.in)[4]) %>%
      filter(longitude >= extent(Tmax.in)[1]) %>%
      filter(longitude <= extent(Tmax.in)[2])
    
    # Extract extract Tmin and Tmax values for coordinates
    print("---Extracting Tmin and Tmax values for coordinates")
    out.Tmin.i <- terra::extract(Tmin.in, data.in[, c("longitude", "latitude")])/100
    out.Tmax.i <- terra::extract(Tmax.in, data.in[, c("longitude", "latitude")])/100
    
    # compute Tmean
    print("---Computing Tmean and formatting output")
    out.i <- (out.Tmin.i + out.Tmax.i)/2
    out.i <- cbind.data.frame(data.in[, 1], out.i)
    colnames(out.i) <- c(IDname0, paste0("D", c(1:365)))
    out[[i]] <- out.i
    print("")
  }
  names(out) <- paste("Tmean", country.in, tiles.in, year.in, sep = "_")
  return(out)
}






