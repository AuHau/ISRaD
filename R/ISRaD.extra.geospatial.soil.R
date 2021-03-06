#' ISRaD.extra.geospatial.soil
#'
#' @description Function to download and extract soil data from ISRIC spatial data products. WARNING: downloads large data files (>15 GB total)
#' @param database ISRaD dataset object.
#' @param geodata_soil_directory directory where geospatial soil datasets are found, or to which can be downloaded.
#' @details Uses site and profile latitude and longitute to extract soil classifications and characteristics from .tif geospatial files acquired from ISRIC (https://www.isric.org/explore/soilgrids).
#' Currently includes USDA soil classifications and soil organic carbon to 100 cm, with new columns added at profile level for SOC at surface (0cm), 5, 15, 30, 60, and 100 cm depth. Points that are very near water bodies tend to produce NA values due to grid cell classification as water (which contains no data).
#' All data are currently from 250 m grid cells.
#' @author Shane Stoner sstoner@bgc-jena.mpg.de
#' @references Hengl, T., Mendes de Jesus, J., Heuvelink, G. B.M., Ruiperez Gonzalez, M., Kilibarda, M. et al. (2017) SoilGrids250m: global gridded soil information based on Machine Learning. PLoS ONE 12(2): e0169748. doi:10.1371/journal.pone.0169748.
#' Hengl T, de Jesus JM, MacMillan RA, Batjes NH, Heuvelink GBM, et al. (2014) SoilGrids1km — Global Soil Information Based on Automated Mapping. PLoS ONE 9(8): e105992. doi:10.1371/journal.pone.0105992.
#' Shangguan, W., Hengl, T., de Jesus, J. M., Yuan, H. and Dai, Y. (2016), Mapping the global depth to bedrock for land surface modeling. J. Adv. Model. Earth Syst. doi:10.1002/2016MS000686.
#' @export

## Create ISRaD_extra object if necessary, with inherited coodrinates for each profile

ISRaD.extra.geospatial.soil <- function(database, geodata_soil_directory) {
  ISRaD_extra <- ISRaD::ISRaD.extra.fill_coords(database)

  if (!is.list(ISRaD_extra)) {
    ISRaD_extra <- ISRaD::ISRaD.extra.fill_coords(database)
  }

  current_wd <- base::getwd()

  ## FTP ISRIC Downloads ##
  #Requires local folder for downloading large (>3 GB) spatial .tif files
  #Checking and appending last '/ ' to path name, if necessary
  pathlength <- nchar(geodata_soil_directory)

  if(substr(geodata_soil_directory, pathlength-0,pathlength) != '/'){
    geodata_soil_directory <-paste(geodata_soil_directory, '/', sep='')
  }

  base::setwd(geodata_soil_directory)

  ####### USDA Classifications #######
  #250m resolution

  #Find files hosted on FTP

  sg.ftp <- "ftp://ftp.soilgrids.org/data/recent/"

  
  

  savefile_USDA_250m = "soilgrids_USDA_250m.tif"
  
  if(!base::file.exists(savefile_USDA_250m)) {
    filenames = RCurl::getURL(sg.ftp, ftp.use.epsv=FALSE, dirlistonly = TRUE)
    base::print('Connected to ftp server...')
    filenames = base::strsplit(filenames, "\r*\n")[[1]]
    USDA_250m.name <- filenames[grep(filenames, pattern=utils::glob2rx("TAXOUSDA_250m.tif$"))]
    
    try(utils::download.file(paste(sg.ftp, USDA_250m.name, sep=""), savefile_USDA_250m))
    base::print('Downloading USDA classification raster...')
  }

  #Load .tif into R as raster
  USDA_250m_raster = raster::raster("soilgrids_USDA_250m.tif")

  #Create key for adding soil names to raster
  #Will need to be moved to "ISRaD Geospatial Data folder"
  USDA_key_path = base::paste(geodata_soil_directory, 'USDA_taxon_key.csv', sep = '')
  USDA_key = utils::read.csv(USDA_key_path, header = T)
  #Add FID column
  USDA_key$FID <- seq(length(USDA_key$ION))

  #Create profile object
  ISRAD_pro <- ISRaD_extra$profile

  #Extract site and/or profile point values from raster
  ISRAD_coords <- data.frame(ISRAD_pro$pro_long, ISRAD_pro$pro_lat)
  ISRAD_pro$pro_USDA_ISRIC_250m <- raster::extract(USDA_250m_raster, ISRAD_coords)

  #Convert numerical values to soil classification names
  ix <- raster::match(ISRAD_pro$pro_USDA_ISRIC_250m, USDA_key$MAXIMUM)
  ISRAD_pro$pro_USDA_ISRIC_250m <- USDA_key[ix, "NAME"]

  #Check for profiles with NA after raster extraction
  ISRIC_NA.df <- ISRAD_pro[is.na(ISRAD_pro$pro_USDA_ISRIC_250m),]
  #ISRIC_NA.list <- list(base::unique(USDA_250m_bad.df$entry_name))

  #Add column to ISRaD_extra object
  ISRaD_extra$profile$pro_ISRIC_USDA_250m <- ISRAD_pro$pro_USDA_ISRIC_250m

  base::print("USDA soil orders updated from raster...")

  #### Gridded Soil Organic C Products ####
  # These values represent predicted SOC content at certain depth, not weighted across depth range (converted to percent from per mille)
  ####### Surface Organic C Estimates (0cm) #######
  ISRaD_extra$profile$pro_ISRIC_ORC_0cm <- 0
  ISRaD_extra$profile$pro_ISRIC_ORC_5cm <- 0
  ISRaD_extra$profile$pro_ISRIC_ORC_15cm <- 0
  ISRaD_extra$profile$pro_ISRIC_ORC_30cm <- 0
  ISRaD_extra$profile$pro_ISRIC_ORC_60cm <- 0
  ISRaD_extra$profile$pro_ISRIC_ORC_100cm <- 0

  ## 250m resolution

  savefile_ORC_0cm = "soilgrids_ORC_0cm.tif"


  #Download file from ISRIC ftp
  if(!file.exists(savefile_ORC_0cm)) {
    ORC_0cm.name <- filenames[grep(filenames, pattern=utils::glob2rx("ORCDRC_M_sl1_250m.tif$"))]
    
    try(utils::download.file(paste(sg.ftp, ORC_0cm.name, sep=""), savefile_ORC_0cm))
    base::print('Downloading ORC 0cm raster...')
  }

  #Load .tif into R as raster
  ORC_0cm_raster = raster::raster("soilgrids_ORC_0cm.tif")

  #Extract site and/or profile point values from raster
  ISRAD_pro$pro_ISRIC_ORC_0cm <- raster::extract(ORC_0cm_raster, ISRAD_coords)

  #Add column to ISRaD_extra object and convert C content from per mill to percent
  ISRaD_extra$profile$pro_ISRIC_ORC_0cm <- ISRAD_pro$pro_ISRIC_ORC_0cm / 10

  base::print("ORC 0cm added from raster...")

  ####### Soil Organic C Estimates (5cm) #######
  ## 250m resolution

  savefile_ORC_5cm = "soilgrids_ORC_5cm.tif"


  #Download file from ISRIC ftp
  if(!file.exists(savefile_ORC_5cm)) {
    ORC_5cm.name <- filenames[grep(filenames, pattern=utils::glob2rx("ORCDRC_M_sl2_250m.tif$"))]
    
    try(utils::download.file(paste(sg.ftp, ORC_5cm.name, sep=""), savefile_ORC_5cm))
    base::print('Downloading ORC 5cm raster...')
  }

  #Load .tif into R as raster
  ORC_5cm_raster = raster::raster("soilgrids_ORC_5cm.tif")

  #Extract site and/or profile point values from raster
  ISRAD_pro$pro_ISRIC_ORC_5cm <- raster::extract(ORC_5cm_raster, ISRAD_coords)

  #Add column to ISRaD_extra object and convert C content from per mill to percent
  ISRaD_extra$profile$pro_ISRIC_ORC_5cm <- ISRAD_pro$pro_ISRIC_ORC_5cm / 10

  base::print("ORC 5cm added from raster...")

  ####### Soil Organic C Estimates (15cm) #######
  ## 250m resolution

  savefile_ORC_15cm = "soilgrids_ORC_15cm.tif"


  #Download file from ISRIC ftp
  if(!file.exists(savefile_ORC_15cm)) {
    ORC_15cm.name <- filenames[grep(filenames, pattern=utils::glob2rx("ORCDRC_M_sl3_250m.tif$"))]
    try(utils::download.file(paste(sg.ftp, ORC_15cm.name, sep=""), savefile_ORC_15cm))
    base::print('Downloading ORC 15cm raster...')
  }

  #Load .tif into R as raster
  ORC_15cm_raster = raster::raster("soilgrids_ORC_15cm.tif")

  #Extract site and/or profile point values from raster
  ISRAD_pro$pro_ISRIC_ORC_15cm <- raster::extract(ORC_15cm_raster, ISRAD_coords)

  #Add column to ISRaD_extra object and convert C content from per mill to percent
  ISRaD_extra$profile$pro_ISRIC_ORC_15cm <- ISRAD_pro$pro_ISRIC_ORC_15cm / 10

  base::print("ORC 15cm added from raster...")

  ####### Soil Organic C Estimates (30cm) #######
  ## 250m resolution

  savefile_ORC_30cm = "soilgrids_ORC_30cm.tif"


  #Download file from ISRIC ftp
  if(!file.exists(savefile_ORC_30cm)) {
    ORC_30cm.name <- filenames[grep(filenames, pattern=utils::glob2rx("ORCDRC_M_sl4_250m.tif$"))]
    
    try(utils::download.file(paste(sg.ftp, ORC_30cm.name, sep=""), savefile_ORC_30cm))
    base::print('Downloading ORC 30cm raster...')
  }

  #Load .tif into R as raster
  ORC_30cm_raster = raster::raster("soilgrids_ORC_30cm.tif")

  #Extract site and/or profile point values from raster
  ISRAD_pro$pro_ISRIC_ORC_30cm <- raster::extract(ORC_30cm_raster, ISRAD_coords)

  #Add column to ISRaD_extra object and convert C content from per mill to percent
  ISRaD_extra$profile$pro_ISRIC_ORC_30cm <- ISRAD_pro$pro_ISRIC_ORC_30cm / 10

  base::print("ORC 30cm added from raster...")

  ####### Surface Organic C Estimates (60cm) #######
  ## 250m resolution

  savefile_ORC_60cm = "soilgrids_ORC_60cm.tif"


  #Download file from ISRIC ftp
  if(!file.exists(savefile_ORC_60cm)) {
    ORC_60cm.name <- filenames[grep(filenames, pattern=utils::glob2rx("ORCDRC_M_sl5_250m.tif$"))]
    
    try(utils::download.file(paste(sg.ftp, ORC_60cm.name, sep=""), savefile_ORC_60cm))
    base::print('Downloading ORC 60cm raster...')
  }

  #Load .tif into R as raster
  ORC_60cm_raster = raster::raster("soilgrids_ORC_60cm.tif")

  #Extract site and/or profile point values from raster
  ISRAD_pro$pro_ISRIC_ORC_60cm <- raster::extract(ORC_60cm_raster, ISRAD_coords)

  #Add column to ISRaD_extra object and convert C content from per mill to percent
  ISRaD_extra$profile$pro_ISRIC_ORC_60cm <- ISRAD_pro$pro_ISRIC_ORC_60cm / 10

  base::print("ORC 60cm added from raster...")

  ####### Soil Organic C Estimates (100cm) #######
  ## 250m resolution
  savefile_ORC_100cm = "soilgrids_ORC_100cm.tif"


  #Download file from ISRIC ftp
  if(!file.exists(savefile_ORC_100cm)) {
    ORC_100cm.name <- filenames[grep(filenames, pattern=utils::glob2rx("ORCDRC_M_sl6_250m.tif$"))]
    
    try(utils::download.file(paste(sg.ftp, ORC_100cm.name, sep=""), savefile_ORC_100cm))
    base::print('Downloading ORC 100cm raster...')
  }

  #Load .tif into R as raster
  ORC_100cm_raster = raster::raster("soilgrids_ORC_100cm.tif")

  #Extract site and/or profile point values from raster
  ISRAD_pro$pro_ISRIC_ORC_100cm <- raster::extract(ORC_100cm_raster, ISRAD_coords)

  #Add column to ISRaD_extra object and convert C content from per mill to percent
  ISRaD_extra$profile$pro_ISRIC_ORC_100cm <- ISRAD_pro$pro_ISRIC_ORC_100cm / 10

  base::print("ORC 100cm added from raster...")

  #####
  #Delete ISRaD_pro object
  rm(ISRAD_pro)

  ### Reset working directory ###
  setwd(current_wd)

  return(ISRaD_extra)
}
