#Read WC files


read_wc_stack_rad <- function(var = 'srad',  
                              path = "data/wc"){
  require(terra)
  require(rgdal)
  if(!var %in% c("srad")) stop("not good var")
  
  files   <- list.files( file.path(path), full.names = F)
  ms <- c(paste0("0",1:9), 10:12)

  files_sel <- paste0(" wc2.1_30s_srad_",ms, ".tif")
  if(sum(!files_sel %in% files)) stop("error missing files")
  
  layers <- rast(file.path(path, var,files_sel[1]))
  for (m in 2:12){
    layer_t <- rast(file.path(path, var,files_sel[m]))
    add(layers) <- layer_t
  }
  names(layers) <- paste0("srad_", ms)
  return(layers)
  
}


extract_wc_var <- function(coords, var = "srad"){
  coords <- coords[, c("longitude", "latitude")] 
  
  stacks <- read_wc_stack_rad(var)
  stacks <- mask(stacks, mask)
  res <- terra::extract(stacks, coords)
  if(nrow(res) != nrow(coords)) stop("missing plots")
  write.csv(bind_cols(coords, as.data.frame(res[, -1])), file = file.path("output", paste0(var, ".csv")), row.names = FALSE)
  return(file.path("output", paste0("wc_",var, ".csv")))
  
  return(file.path("output", paste0("wc_",var, ".csv")))
}

