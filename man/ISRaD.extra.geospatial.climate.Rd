% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ISRaD.extra.geospatial.climate.R
\name{ISRaD.extra.geospatial.climate}
\alias{ISRaD.extra.geospatial.climate}
\title{ISRaD.extra.geospatial.climate}
\usage{
ISRaD.extra.geospatial.climate(database, geodata_clim_directory,
  geodata_pet_directory)
}
\arguments{
\item{database}{ISRaD dataset object.}

\item{geodata_clim_directory}{directory where geospatial climate datasets are found.}

\item{geodata_pet_directory}{directory where geospatial pet dataset is found.}
}
\value{
An ISRaD_data object with additional rows containing values from geospatial datasets. See description for details.
}
\description{
Extracts values from gridded (2.5' arc) climate data using ISRaD profile coordinates.
}
\details{
Adds new climate fields BIO1-BIO19, PET:

BIO1 = Annual Mean Temperature,
BIO2 = Mean Diurnal Range (Mean of monthly (max temp - min temp)),
BIO3 = Isothermality (BIO2/BIO7) (* 100),
BIO4 = Temperature Seasonality (standard deviation *100),
BIO5 = Max Temperature of Warmest Month,
BIO6 = Min Temperature of Coldest Month,
BIO7 = Temperature Annual Range (BIO5-BIO6),
BIO8 = Mean Temperature of Wettest Quarter,
BIO9 = Mean Temperature of Driest Quarter,
BIO10 = Mean Temperature of Warmest Quarter,
BIO11 = Mean Temperature of Coldest Quarter,
BIO12 = Annual Precipitation,
BIO13 = Precipitation of Wettest Month,
BIO14 = Precipitation of Driest Month,
BIO15 = Precipitation Seasonality (Coefficient of Variation),
BIO16 = Precipitation of Wettest Quarter,
BIO17 = Precipitation of Driest Quarter,
BIO18 = Precipitation of Warmest Quarter,
BIO19 = Precipitation of Coldest Quarter
PET = Potential evapotranspiration, mm/yr (Penman-Monteith method for short-clipped grass w/ worldclim input data)

All BIO## variables are from http://www.worldclim.org/bioclim V1.4 at 2.5 resolution and are based on site lat and long
}
\references{
http://www.worldclim.org/; PET data from: Kramer, M. and O. Chadwick. 2018. Climate-driven thresholds in reactive mineral retention of soil carbon at the global scale. Nature Climate Change 8:1104–1108.
}
\author{
J. Grey Monroe, Alison Hoyt
}
