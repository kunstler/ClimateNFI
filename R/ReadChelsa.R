read_mask <- function(path = "data/mask"){
  require(terra)
  require(rgdal)
  m <- rast(file.path(path, "chelsa-w5e5v1.0_obsclim_mask_30arcsec_global.nc"))
  return(m)
}


add_mask_coords <- function(coords){
  library(terra)
  m <- read_mask()
  coords2 <- coords[, c("longitude", "latitude")] 
  res <- terra::extract(m, coords2)
  coords$mask <- res$mask
  return(coords)
}


read_chelsa_stack_var_year <- function(var = 'pr', year = 2018, 
                                       path = "data/envicloud/chelsa/chelsa_V2/GLOBAL/monthly"){
  require(terra)
  require(rgdal)
  if(!var %in% c("pr", "pet", "tas", "tasmax", "tasmin")) stop("not good var")
  
  xstring <- paste('_',var, '_', sep='')
  files   <- list.files( file.path(path, var), full.names = F)
  ms <- c(paste0("0",1:9), 10:12)
  
  var_file <- ifelse(var == "pet", "pet_penman", var)
  files_sel <- paste0("CHELSA_", var_file, "_",ms,"_",year, "_V.2.1.tif")
  if(sum(!files_sel %in% files)) stop("error missing files")
  layer_t <- rast(file.path(path, var,files_sel[1]))
  layers <- layer_t
  for (m in 2:12){
    layer_t <- rast(file.path(path, var,files_sel[m]))
    add(layers) <- layer_t
  }
names(layers) <- gsub("_V.2.1", "", gsub("CHELSA_", "", names(layers)))
return(layers)
}


extract_chelsa_var_year <- function(coords, var = "pr", year = 2018, 
                                    path = "data/envicloud/chelsa/chelsa_V2/GLOBAL/monthly") {

  # Get rasters for the given variable and year
  stacks <- read_chelsa_stack_var_year(var, year, path)
  
  # Extract values from rasters at coordinates in coords dataframe
  res <- terra::extract(stacks, coords[, c("longitude", "latitude")])
  
  # Check number of rows
  if(nrow(res) != nrow(coords)) stop("missing plots")
  
  # Add values to the original coord dataset (remove ID first column to res dataset)
  res <- data.frame(plotcode = coords$plotcode, res[,-1])
  
  return(list(var = var, year = year, data = res))
}


merge_chelsa_year <- function(chelsa_vars_years, year) {
  
  # True if year element in each list is equal to the given year
  keep_data <- sapply(chelsa_vars_years, function(X) X$year == year)
  
  # Select dataframe from lists of the given year
  chelsa_year_merged <- lapply(chelsa_vars_years[keep_data], function(X) X$data)
  
  # Bind df for all vars and all years into a single one for each year with all vars
  chelsa_year_merged <- chelsa_year_merged %>% purrr::reduce(full_join, by = "plotcode")
  
  # Return result as a list
  return(list(year = year, data = chelsa_year_merged))
}


save_chelsa_year <- function(chelsa_year, path = "output") {
  
  filepath <- file.path(path, paste0("chelsa_", chelsa_year$year, ".csv"))
  write.table(chelsa_year$data, filepath, sep = ";", dec = ".", row.names = F)
  
  return(filepath)
}

# extract_chelsa_var_years <- function(coords,  
#                                      var = "pr", 
#                                      years= 1983:2018){
#   
#  list_var_years <- vector("list")
#   for (y in seq_len(length(years))){
#     print(years[y])
#     list_var_years[[y]] <- extract_chelsa_var_year(coords, var, years[y])
#   }
#  names(list_var_years) <- paste0(var, "_", years)
#  res <- as.matrix(bind_cols(list_var_years))
#  write.csv(bind_cols(coords, as.data.frame(res)), file = file.path("output", paste0(var, ".csv")), row.names = FALSE)
#  return(file.path("output", paste0(var, ".csv")))
# }

# library(tictoc)
# tic()
# res <- extract_var_year()
# toc()
# sum(is.na(res[, 1])) 






