# Read Terra climate

read_terra_netcdf <- function(var ="pet", year = "2018", path= "data/terraclimate"){
  
  pet <- rast(file.path(path, paste0("TerraClimate_", var, "_", year, ".nc")))
  pet
}

extract_terra_var_year <- function(coords, var = "pet", year = 2018){
  coords <- coords[, c("longitude", "latitude")] 
  
  stacks <- read_terra_netcdf(var, year)
  res <- terra::extract(stacks, coords)
  if(nrow(res) != nrow(coords)) stop("missing plots")
  
  return(res[, -1])
}


extract_terra_var_years <- function(coords, mask, 
                                     var = "pet", 
                                     years= 2017:2018){
  
  list_var_years <- vector("list")
  for (y in seq_len(length(years))){
    list_var_years[[y]] <- extract_terra_var_year(coords, var, years[y])
    names(list_var_years[[y]]) <- paste0(var, "_", years[y], "_", 1:12)
  }
  names(list_var_years) <- paste0(var, "_", years)
  res <- as.matrix(bind_cols(list_var_years))
  
  write.csv(bind_cols(coords, res), file = file.path("output", paste0(var, ".csv")))
  return(file.path("output", paste0(var, ".csv")))
}
