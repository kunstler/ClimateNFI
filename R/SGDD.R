# SGDD compute from monthly data
get_tas <- function(){
  tas <- read.csv("output/tas.csv")
  temp <- tas[, grep("tas", names(tas))]*0.1 - 273
  library(lubridate)
  vec_m <- substr( names(temp), 5,6)
  vec_y <- substr( names(temp), 8,11)
  vec_d <- floor(days_in_month(ym(paste0(vec_y, "-", vec_m)))/2)
  vec_date <- ymd(paste0(vec_y, "-", vec_m, "-", vec_d))
return(list(tas = temp, date = vec_date))
}

compute_sgdd <- function(year_sel, i, temp, vec_date,threshold.sgdd =  5.56){
  indexx <- (1:ncol(temp))[year(vec_date) == year_sel]
  dec <- (indexx[1] - 1)
  if(dec <1) dec <- indexx[12]
  jan <- indexx[12] +1
  if(jan > ncol(temp)) jan <- 1 
  indexx2 <- c(dec, indexx, jan)
  xx <- c(as.numeric(vec_date)[indexx[1]] - 30, as.numeric(vec_date)[indexx], as.numeric(vec_date)[indexx[12]] + 30)
  yy <- as.vector(t(temp[i, indexx2]))  
  myfit <- loess(y~x, data= data.frame(y=yy, x = xx),
                 span = 0.4, degree = 2)
  #predict with constant temp per month
  date_pred <- seq.Date(from =  ymd(paste0(year_sel, "-", 01, "-", 01)), 
                        to =  ymd(paste0(year_sel, "-", 12, "-", 31)),
                        by = "day")
  pred_cst <- as.vector(t(temp[i, indexx]))[month(date_pred)]
  x_pred <- as.numeric(date_pred)
  mypred <- predict(myfit, x_pred)
  sgdd <- sum(mypred[mypred>=threshold.sgdd]-threshold.sgdd)
  sgdd_cst <- sum(pred_cst[pred_cst>=threshold.sgdd]-threshold.sgdd)
  # plot(xx, yy, type = "b", main = paste("year", year_sel, "plot", i))
  # lines(x_pred, mypred, col ="red")               
  # lines(x_pred, pred_cst, col ="green")     
  
  return(c(sgdd, sgdd_cst))
}


# compute all sgdd

compute_sgdd_all <- function(){
  library(lubridate)
  
  list_temp <- get_tas()
  yearss <-  unique(year(list_temp$date))
  nn <- nrow(list_temp$tas)
  res <- matrix(NA, nrow = nn, ncol = 2)
  for (i in 1:nrow(list_temp$tas)){
   for (yy in yearss){
     res[i, ] <- compute_sgdd(yy, i, list_temp$tas, list_temp$date)
   } 
  }
  return(res)
}

# library(tictoc)
# tic()
# mat_sgdd <- compute_sgdd_all()
# toc()


## function to compute sum of degree days above 5.56
fun.sgdd <-  function(temp,threshold.sgdd =  5.56){
  require(season)
  temp <-  unlist(temp)
  ndays.month <- flagleap(data.frame(year=2013, month=1:12), F)$ndaysmonth
  ndays.year <- sum(ndays.month)
  x <- c(-ndays.month[12]/2,(ndays.month/2) + c(0, cumsum(ndays.month[1:11])),
         ndays.year+ndays.month[1]/2)
  ## plot(x,c(temp[12],temp,temp[1]),xlim=c(0,365),type='b')
  myfit <- loess(y~x, data=data.frame(y=c(temp[12],temp,temp[1]), x = x),
                 span = 0.4, degree = 2)
  mypred <- predict(myfit, 1:ndays.year)
  ## lines( 1:ndays.year,mypred,col="red")
  sgdd <- sum(mypred[mypred>=threshold.sgdd]-threshold.sgdd)
  return(sgdd)
}

