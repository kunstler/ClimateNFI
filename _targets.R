# _targets.R file
library(targets)

# Source functions in R folder
lapply(grep("R$", list.files("R"), value = TRUE), function(x) source(file.path("R", x)))

# Set options (i.e. clustermq for multiprocess computing)
options(tidyverse.quiet = TRUE, clustermq.scheduler = "multiprocess")
tar_option_set(packages = c("terra", "rgdal", "dplyr", "tidyr"))

# List of targets
list(
  
  # Coordinates file
  tar_target(coords_file, "data/data_coord_plots_test.csv", format = "file"),
  tar_target(coords_t, read.table(coords_file, sep = ";", dec = ".", header = T)),  
  tar_target(coords, add_mask_coords(coords_t)),
  
  # Use dynamic branching through years and variables
  tar_target(years, seq(1983,2018)),
  tar_target(vars, c("pet", "pr", "tas", "tasmin", "tasmax")),
  
  # Extract chelsa values (produce on file per variable per year with values for all coordinates)
  tar_target(chelsa_raw_vars_years, extract_chelsa_var_year(coords, vars, years, 
                                                            path = "data/envicloud/chelsa/chelsa_V2/GLOBAL/monthly"), 
             pattern = cross(vars, years), iteration = "list"),
  
  # Merge chelsa files (produce one file per years)
  tar_target(chelsa_merged_years, merge_chelsa_year(chelsa_raw_vars_years, years), pattern = map(years), iteration = "list"),
  
  # Save chelsa files
  tar_target(chelsa_filepaths, save_chelsa_year(chelsa_merged_years), pattern = map(chelsa_merged_years))
  
  
  # tar_target(
  #   pr_2018,
  #   extract_chelsa_var_year(coords)
  # ),
  # tar_target(
  #   pr_all,
  #   extract_chelsa_var_years(coords)
  # ),
  # tar_target(
  #   pr_chelsa_1983_2018,
  #   extract_chelsa_var_years(coords, var = "pr"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   pet_chelsa_1983_2018,
  #   extract_chelsa_var_years(coords, var = "pet"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   tas_chelsa_1983_2018,
  #   extract_chelsa_var_years(coords, var = "tas"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   tasmin_chelsa_1983_2018,
  #   extract_chelsa_var_years(coords, var = "tasmin"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   tasmax_chelsa_1983_2018,
  #   extract_chelsa_var_years(coords, var = "tasmax"),
  #   format = "file"
  # ) ,
  # tar_target(
  #   pet_terra_1983_2018,
  #   extract_terra_var_years(coords, var = "pet"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   soil_terra_1983_2018,
  #   extract_terra_var_years(coords, var = "soil"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   srad_terra_1983_2018,
  #   extract_terra_var_years(coords, var = "srad"),
  #   format = "file"
  # )  ,
  # tar_target(
  #   srad_wc,
  #   extract_wc_var(coords, var = "srad"),
  #   format = "file"
  # )
  
)

