# _targets.R file
library(targets)
lapply(grep("R$", list.files("R"), value = TRUE), function(x) source(file.path("R", x)))

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("terra", "rgdal", "dplyr", "ggplot2", "RCurl", "httr", "raster"))

list(
  tar_target(coords_file,"data/NFI/FUNDIV_coordinates.csv",
             format = "file"
  ),
  tar_target(
    coords_t,
    read.csv(coords_file)
  ),  
  tar_target(
    coords,
    add_mask_coords(coords_t)
  ),
  tar_target(
    pr_2018,
    extract_chelsa_var_year(coords)
  ),
  tar_target(
    pr_all,
    extract_chelsa_var_years(coords)
  ),
  tar_target(
    pr_chelsa_1983_2018,
    extract_chelsa_var_years(coords, var = "pr"),
    format = "file"
  )  ,
  tar_target(
    tas_chelsa_1983_2018,
    extract_chelsa_var_years(coords, var = "tas"),
    format = "file"
  )  ,
  tar_target(
    tasmin_chelsa_1983_2018,
    extract_chelsa_var_years(coords, var = "tasmin"),
    format = "file"
  )  ,
  tar_target(
    tasmax_chelsa_1983_2018,
    extract_chelsa_var_years(coords, var = "tasmax"),
    format = "file"
  )  ,
  tar_target(
    pet_terra_1983_2018,
    extract_terra_var_years(coords, var = "pet"),
    format = "file"
  )  ,
  tar_target(
    soil_terra_1983_2018,
    extract_terra_var_years(coords, var = "soil"),
    format = "file"
  )  ,
  tar_target(
    srad_terra_1983_2018,
    extract_terra_var_years(coords, var = "srad"),
    format = "file"
  )  ,
  tar_target(
    srad_wc,
    extract_wc_var(coords, var = "srad"),
    format = "file"
  ), 
  tar_target(
    tmean_moreno,
    get_Tmean_Moreno()
  )
  
)

