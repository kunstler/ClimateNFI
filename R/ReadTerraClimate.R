# Read Terra climate

read_terra_netcdf <- function(var ="pet", year = "2018", path= "terraclimate"){
  
  pet <- rast(file.path(path, paste0("TerraClimate_", var, "_", year, ".nc")))
  
}
