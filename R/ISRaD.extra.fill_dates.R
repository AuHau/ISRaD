#' ISRaD.extra.fill_dates
#'
#' @description Fills frc_obs_date_y and inc_obs_date_y columns from lyr_obs_date_y if not reported.
#' @param database ISRaD dataset object.
#' @details This function must be run prior to the ISRaD.extra.fill_14c, ISRaD.extra.fill_fm, and ISRaD.extra.delta_delta for the layer and fraction tables.
#' @export
#' @return returns ISRaD_data object with filled obs_date_y columns

ISRaD.extra.fill_dates<-function(database){

  frc_date_fill <- function(x) {
    
    for(r in 1:nrow(x$fraction)){
      
  x$fraction$frc_obs_date_y[r] <- ifelse(is.na(x$fraction$frc_obs_date_y[r]),
                                     as.character(x$layer$lyr_obs_date_y)[which(as.character(x$layer$pro_name)== as.character(x$fraction$pro_name)[r] & as.character(x$layer$site_name)== as.character(x$fraction$site_name)[r] & as.character(x$layer$lyr_name)== as.character(x$fraction$lyr_name)[r] &  as.character(x$layer$entry_name)== as.character(x$fraction$entry_name)[r])],
                                 x$fraction$frc_obs_date_y[r])
    }
    x$fraction$frc_obs_date_y<-as.numeric(x$fraction$frc_obs_date_y)
    
  return(x)
}

inc_date_fill <- function(x) {
  for(r in 1:nrow(x$incubation)){
    
    x$incubation$inc_obs_date_y[r] <- ifelse(is.na(x$incubation$inc_obs_date_y[r]),
                                           as.character(x$layer$lyr_obs_date_y)[which(as.character(x$layer$site_name)== as.character(x$incubation$site_name)[r] & as.character(x$layer$lyr_name)== as.character(x$incubation$lyr_name)[r] &  as.character(x$layer$entry_name)== as.character(x$incubation$entry_name)[r])],
                                           x$incubation$inc_obs_date_y[r])
  }
  x$incubation$inc_obs_date_y<-as.numeric(x$incubation$inc_obs_date_y)
  
  return(x)
}
out <- frc_date_fill(database)
out <- inc_date_fill(out)
return(out)
}
