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

extract_chelsa_var_year <- function(coords, var = "pr", year = 2018){
  coords <- coords[, c("longitude", "latitude")] 
  
  stacks <- read_chelsa_stack_var_year(var, year)
  res <- terra::extract(stacks, coords)
  if(nrow(res) != nrow(coords)) stop("missing plots")
  return(res[, -1])
}

extract_chelsa_var_years <- function(coords,  
                                     var = "pr", 
                                     years= 1983:2018){
  
 list_var_years <- vector("list")
  for (y in seq_len(length(years))){
    print(years[y])
    list_var_years[[y]] <- extract_chelsa_var_year(coords, var, years[y])
  }
 names(list_var_years) <- paste0(var, "_", years)
 res <- as.matrix(bind_cols(list_var_years))
 write.csv(bind_cols(coords, as.data.frame(res)), file = file.path("output", paste0(var, ".csv")), row.names = FALSE)
 return(file.path("output", paste0(var, ".csv")))
}

# library(tictoc)
# tic()
# res <- extract_var_year()
# toc()
# sum(is.na(res[, 1])) 






