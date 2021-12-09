# _targets.R file
library(targets)
lapply(grep("R$", list.files("R"), value = TRUE), function(x) source(file.path("R", x)))

options(tidyverse.quiet = TRUE)
tar_option_set(packages = c("terra", "rgdal", "dplyr", "ggplot2"))
list(
  tar_target(coords,"data/NFI/FUNDIV_coordinates.csv",
             format = "file"
  ),
  tar_target(
    pr_2018,
    extract_chelsa_var_year(coords, mask)
  ),
  tar_target(
    pr_all,
    extract_chelsa_var_years(coords, mask)
  ),
  tar_target(
    mask,
    read_mask
  )  ,
  tar_target(
    pr_chelsa_1983_2018,
    extract_chelsa_var_years(coords, mask, var = "pr")
  )  ,
  tar_target(
    tas_chelsa_1983_2018,
    extract_chelsa_var_years(coords, mask, var = "tas")
  )  ,
  tar_target(
    tasmin_chelsa_1983_2018,
    extract_chelsa_var_years(coords, mask, var = "tasmin")
  )  ,
  tar_target(
    tasmax_chelsa_1983_2018,
    extract_chelsa_var_years(coords, mask, var = "tasmax")
  )  ,
  tar_target(
    pet_terra_1983_2018,
    extract_terra_var_years(coords, var = "pet")
  )  
)

