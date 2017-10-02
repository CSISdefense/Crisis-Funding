library(lubridate)
library(csis360)
library(Hmisc)

FormatContractModel<-function(dfContract){
  colnames(dfContract)[colnames(dfContract)=="SubCustomer.sum"]<-"Who"
  colnames(dfContract)[colnames(dfContract)=="UnmodifiedIsSomeCompetition"]<-"Comp"
  colnames(dfContract)[colnames(dfContract)=="PlatformPortfolio.sum"]<-"What"
  colnames(dfContract)[colnames(dfContract)=="IsIDV"]<-"IDV"
  colnames(dfContract)[colnames(dfContract)=="FixedOrCost"]<-"FxCb"
  colnames(dfContract)[colnames(dfContract)=="AnyInternational"]<-"Intl"
  colnames(dfContract)[colnames(dfContract)=="SimpleArea"]<-"PSR"
  colnames(dfContract)[colnames(dfContract)=="qLowCeiling"]<-"LowCeil"
  colnames(dfContract)[colnames(dfContract)=="qHighCeiling"]<-"Ceil"
  colnames(dfContract)[colnames(dfContract)=="qLinked"]<-"Link"
  colnames(dfContract)[colnames(dfContract)=="qDuration"]<-"Dur"
  # colnames(dfContract)[colnames(dfContract)=="SingleOffer"]<-"One"
  colnames(dfContract)[colnames(dfContract)=="qOffers"]<-"Offr"
  colnames(dfContract)[colnames(dfContract)=="IsTerminated"]<-"Term"
  colnames(dfContract)[colnames(dfContract)=="SoftwareEng"]<-"Soft"
  colnames(dfContract)[colnames(dfContract)=="SimpleVehicle"]<-"Veh"
  colnames(dfContract)[colnames(dfContract)=="LabeledMDAP"]<-"MDAP"
  colnames(dfContract)[colnames(dfContract)=="qNChg"]<-"NChg"
  colnames(dfContract)[colnames(dfContract)=="qCRais"]<-"CRai"
  
  
  if(is.null(dfContract$Ceil) &
     is.null(dfContract$LowCeil) &
     "UnmodifiedContractBaseAndAllOptionsValue" %in% colnames(dfContract)){
    lowroundedcutoffs<-c(15000,100000,1000000,30000000)
    highroundedcutoffs<-c(15000,100000,1000000,10000000,75000000)
    dfContract$qLowCeiling <- cut2(dfContract$UnmodifiedContractBaseAndAllOptionsValue,cuts=lowroundedcutoffs)
    dfContract$qHighCeiling <- cut2(dfContract$UnmodifiedContractBaseAndAllOptionsValue,cuts=highroundedcutoffs)
    rm(lowroundedcutoffs,highroundedcutoffs)
    
    colnames(dfContract)[colnames(dfContract)=="qLowCeiling"]<-"LowCeil"
    colnames(dfContract)[colnames(dfContract)=="qHighCeiling"]<-"Ceil"
    
  }
  if (all(levels(dfContract$qHighCeiling)==c("[0.00e+00,1.50e+04)",
                                                    "[1.50e+04,1.00e+05)",
                                                    "[1.00e+05,1.00e+06)",
                                                    "[1.00e+06,1.00e+07)",
                                                    "[1.00e+07,7.50e+07)",
                                                    "[7.50e+07,3.36e+12]"))){
    dfContract$qHighCeiling<-factor(dfContract$qHighCeiling, 
                                           
                                           levels=c("[0.00e+00,1.50e+04)",
                                                    "[1.50e+04,1.00e+05)",
                                                    "[1.00e+05,1.00e+06)",
                                                    "[1.00e+06,1.00e+07)",
                                                    "[1.00e+07,7.50e+07)",
                                                    "[7.50e+07,3.36e+12]"),
                                           labels=c("[0,15k)",
                                                    "[15k,100k)",
                                                    "[100k,1m)",
                                                    "[1m,10m)",
                                                    "[10m,75m)",
                                                    "[75m+]"),
                                           ordered=TRUE
    )
  }
  
  if (all(levels(dfContract$qLowCeiling)==c("[0.00e+00,1.50e+04)",
                                                   "[1.50e+04,1.00e+05)",
                                                   "[1.00e+05,1.00e+06)",
                                                   "[1.00e+06,3.00e+07)",
                                                   "[3.00e+07,3.36e+12]"))){
    dfContract$qLowCeiling<-factor(dfContract$qLowCeiling, 
                                          
                                          levels=c("[0.00e+00,1.50e+04)",
                                                   "[1.50e+04,1.00e+05)",
                                                   "[1.00e+05,1.00e+06)",
                                                   "[1.00e+06,3.00e+07)",
                                                   "[3.00e+07,3.36e+12]"),
                                          labels=c("[0,15k)",
                                                   "[15k,100k)",
                                                   "[100k,1m)",
                                                   "[1m,30m)",
                                                   "[30m+]"),
                                          ordered=TRUE
    )
  }

    
  if (all(
    levels(dfContract$Ceil) %in% c("[75m+]",
                                   "[10m,75m)",
                                   "[1m,10m)", 
                                   "[100k,1m)",
                                   "[15k,100k)",
                                   "[0,15k)"
    ))){
    dfContract$Ceil<-factor(dfContract$Ceil,
                            levels=c("[75m+]",
                                     "[10m,75m)",
                                     "[1m,10m)", 
                                     "[100k,1m)",
                                     "[15k,100k)",
                                     "[0,15k)"
                            ),
                            labels=c("75m+",
                                     "10m - <75m",
                                     "1m - <10m", 
                                     "100k - <1m",
                                     "15k - <100k",
                                     "0 - <15k"
                            ),
                            ordered=TRUE
                            
    )
  }
  
  
  if(is.null(dfContract$Dur) & 
     "UnmodifiedDays" %in% colnames(dfContract)){
    #Break the count of days into four categories.
    dfContract$qDuration<-cut2(dfContract$UnmodifiedDays,cuts=c(61,214,366,732))
    colnames(dfContract)[colnames(dfContract)=="qDuration"]<-"Dur"
    
  }
  
  
  
  
  if (levels(dfContract$qDuration)[[2]]=="[   61,  214)"){
    dfContract$qDuration<-factor(dfContract$qDuration, 
                                        
                                        levels=c("[    0,   61)",
                                                 "[   61,  214)",
                                                 "[  214,  366)",
                                                 "[  366,  732)",
                                                 "[  732,33192]"),
                                        labels=c("[0 months,~2 months)",
                                                 "[~2 months,~7 months)",
                                                 "[~7 months-~1 year]",
                                                 "(~1 year,~2 years]",
                                                 "(~2 years+]"),
                                        ordered=TRUE
    )
  }
  
  
  
  
  
  if(!is.null(dfContract$Dur) & all(
    levels(dfContract$Dur) %in% c("[0 months,~2 months)",
                                  "[~2 months,~7 months)",
                                  "[~7 months-~1 year]",
                                  "(~1 year,~2 years]",
                                  "(~2 years+]"
    ))){
    dfContract$Dur<-factor(dfContract$Dur,
                           levels=c("[0 months,~2 months)",
                                    "[~2 months,~7 months)",
                                    "[~7 months-~1 year]",
                                    "(~1 year,~2 years]",
                                    "(~2 years+]"
                           ),
                           labels=c("[0 months,~2 months)",
                                    "[~2 months,~7 months)",
                                    "[~7 months-~1 year]",
                                    "(~1 year,~2 years]",
                                    "(~2 years+]"
                           ),
                           ordered=TRUE
                           
    )
  }
  
  dfContract$ContractCount<-1
  
  if("UnmodifiedCurrentCompletionDate" %in% colnames(dfContract))
    dfContract$UnmodifiedCurrentCompletionDate<-
    as.Date(dfContract$UnmodifiedCurrentCompletionDate)
  if("MinOfEffectiveDate" %in% colnames(dfContract))
    dfContract$MinOfEffectiveDate<-
    as.Date(dfContract$MinOfEffectiveDate)
  if("LastCurrentCompletionDate" %in% colnames(dfContract))
    dfContract$LastCurrentCompletionDate<-
    as.Date(dfContract$LastCurrentCompletionDate)
  
  
  if("MinOfEffectiveDate" %in% colnames(dfContract) & 
     !"StartFiscalYear" %in% colnames(dfContract))
    dfContract$MinOfEffectiveDate<-as.Date(as.character(dfContract$MinOfEffectiveDate))
  dfContract$StartFiscalYear<-DateToFiscalYear(dfContract$MinOfEffectiveDate)
  
  
  if("MinOfEffectiveDate" %in% colnames(dfContract) &
     "UnmodifiedCurrentCompletionDate" %in% colnames(dfContract)){
    if(!"UnmodifiedDays" %in% colnames(dfContract))
      dfContract$UnmodifiedDays<-as.numeric(
        difftime(strptime(dfContract$UnmodifiedCurrentCompletionDate,"%Y-%m-%d")
                 , strptime(dfContract$MinOfEffectiveDate,"%Y-%m-%d")
                 , unit="days"
        ))+1
  }
  
  dfContract
}




## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=FALSE,
                      conf.interval=.95, .drop=TRUE) {
  library(plyr)
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}