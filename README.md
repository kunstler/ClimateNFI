# Function to read climatic data and extract for NFI data

INRAE LESSEM Grenoble


## Installation

We need to download the climatic data into the quadri cluster as too big for local computer.

To connect to quadri

`ssh kunstler@quadri1.grenoble.cemagref.fr`

to transfer data

`sftp kunstler@quadri1.grenoble.cemagref.fr`


To mount the smb server on quadri
`git clone ...`

Old mount 
`sudo mount -t cifs //195.221.110.170/projets/chelsa ClimateNFI/data --verbose -o rw,user=georges.kunstler,domain=irstea.priv,vers=1.0`


New mount
`sudo mount -t cifs //195.221.110.170/projets/chelsa ClimateNFI/data --verbose -o rw,user=gkunstler,domain=inra.local,vers=1.0`


To download chelsa data

`wget --no-host-directories --force-directories --input-file=envidatS3paths_all.txt`

with `envidatS3paths_all.txt`the file with the list of tif to download (Tmin Tmax Tas Precip)

to download terraclimate data
wget -nc -c -nd --input-file=terraclimat_wget.txt (PET soil water content and radiation

I also dowloaded the long-term average monthly radiation series from worldclim

This R cran code require the package `target`.
Use targets::tar_make_clustermq(workers = N) with N:number of cores to use for running the code in parallel

In addition the following packages are required:

`terra` for raster file
TODO


## Folders structure

 * The R script functions are in the folder `R`
 * The folder `data` contains the data for coordinates of plot for which we need to extract climate 
 * The folder `ms` contains the file for the pdf Rmarkdown report (latex header bibliography)


