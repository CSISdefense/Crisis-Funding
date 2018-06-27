library(lubridate)
library(csis360)
library(Hmisc)


rename_dataset<-function(contract){
  
  colnames(contract)[colnames(contract)=="SubCustomer.sum"]<-"Who"
  # colnames(contract)[colnames(contract)=="UnmodifiedIsSomeCompetition"]<-"Comp"
  colnames(contract)[colnames(contract)=="PlatformPortfolio.sum"]<-"What"
  colnames(contract)[colnames(contract)=="IsIDV"]<-"IDV"
  colnames(contract)[colnames(contract)=="FixedOrCost"]<-"FxCb"
  colnames(contract)[colnames(contract)=="AnyPlaceInternational"]<-"Intl"
  colnames(contract)[colnames(contract)=="SimpleArea"]<-"PSR"
  colnames(contract)[colnames(contract)=="qLowCeiling"]<-"LowCeil"
  colnames(contract)[colnames(contract)=="qHighCeiling"]<-"Ceil"
  colnames(contract)[colnames(contract)=="qDuration"]<-"Dur"
  # colnames(contract)[colnames(contract)=="SingleOffer"]<-"One"
  colnames(contract)[colnames(contract)=="qOffers"]<-"Offr"
  colnames(contract)[colnames(contract)=="IsTerminated"]<-"Term"
  colnames(contract)[colnames(contract)=="SimpleVehicle"]<-"Veh"
  colnames(contract)[colnames(contract)=="LabeledMDAP"]<-"MDAP"
  colnames(contract)[colnames(contract)=="qNChg"]<-"NChg"
  colnames(contract)[colnames(contract)=="qCRais"]<-"CRai"
  colnames(contract)[colnames(contract)=="StartFiscal_Year"]<-"StartFY"
  colnames(contract)[colnames(contract)=="StartFiscalYear"]<-"StartFY"
  colnames(contract)[colnames(contract)=="topContractingOfficeAgencyID"]<-"Agency"
  colnames(contract)[colnames(contract)=="topContractingOfficeID"]<-"Office"
  colnames(contract)[colnames(contract)=="topProductOrServiceCode"]<-"ProdServ"
  colnames(contract)[colnames(contract)=="topPrincipalNAICScode"]<-"NAICS"
  colnames(contract)[colnames(contract)=="UnmodifiedPlaceCountryISO3"]<-"Where"
  
  
  contract
}

FormatContractModel<-function(dfContract){
  
  
  
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
  
  
  if ("Ceil" %in% colnames(dfContract)&
      gsub(" ","",levels(dfContract$Ceil)[[2]]) =="[1.50e+04,1.00e+05)"&
      gsub(" ","",levels(dfContract$Ceil)[[3]]) =="[1.00e+05,1.00e+06)"&
      gsub(" ","",levels(dfContract$Ceil)[[4]]) =="[1.00e+06,1.00e+07)"&
      gsub(" ","",levels(dfContract$Ceil)[[5]]) =="[1.00e+07,7.50e+07)"){
    dfContract$Ceil<-factor(dfContract$Ceil, 
                            
                            levels=levels(dfContract$Ceil),
                            labels=c("[0,15k)",
                                     "[15k,100k)",
                                     "[100k,1m)",
                                     "[1m,10m)",
                                     "[10m,75m)",
                                     "[75m+]"),
                            ordered=TRUE
    )
  }
  
  
  if ("LowCeil" %in% colnames(dfContract)&
      all(levels(dfContract$LowCeil)==c("[0.00e+00,1.50e+04)",
                                        "[1.50e+04,1.00e+05)",
                                        "[1.00e+05,1.00e+06)",
                                        "[1.00e+06,3.00e+07)",
                                        "[3.00e+07,3.36e+12]"))){
    dfContract$LowCeil<-factor(dfContract$LowCeil, 
                               
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
  
  if ("Ceil" %in% colnames(dfContract)&
      all(
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
  
  
  
  
  if ( "Dur" %in% colnames(dfContract) & 
       gsub(" ","",levels(dfContract$Dur)[[2]]) =="[61,214)"&
       gsub(" ","",levels(dfContract$Dur)[[3]]) =="[214,366)"&
       gsub(" ","",levels(dfContract$Dur)[[4]]) =="[366,732)"
  ){
    dfContract$Dur<-factor(dfContract$Dur, 
                           
                           levels=levels(dfContract$Dur),
                           # "[    0,   61)",
                           # "[   61,  214)",
                           # "[  214,  366)",
                           # "[  366,  732)",
                           # "[  732,33192]"),
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
  
  
  if(is.null(dfContract$CRai) & 
     "pChangeOrderUnmodifiedBaseAndAll" %in% colnames(dfContract)){
    
    dfContract$CRais <- cut2(
      dfContract$pChangeOrderUnmodifiedBaseAndAll,c(
        -0.001,
        0.001,
        0.15)
    )
  }
  
  
  if(is.null(dfContract$NChg)  & 
     "SumOfisChangeOrder" %in% colnames(dfContract)){
    
    dfContract$NChg <- cut2(dfContract$SumOfisChangeOrder,c(1,2,3))
    
  }
  
  
  
  
  
  dfContract$ContractCount<-1
  
  if("UnmodifiedCurrentCompletionDate" %in% colnames(dfContract))
    dfContract$UnmodifiedCurrentCompletionDate<-
    as.Date(dfContract$UnmodifiedCurrentCompletionDate)
  if("MinOfSignedDate" %in% colnames(dfContract))
    dfContract$MinOfSignedDate<-
    as.Date(dfContract$MinOfSignedDate)
  if("LastCurrentCompletionDate" %in% colnames(dfContract))
    dfContract$LastCurrentCompletionDate<-
    as.Date(dfContract$LastCurrentCompletionDate)
  
  
  if("MinOfSignedDate" %in% colnames(dfContract) & 
     !"StartFY" %in% colnames(dfContract)){
    dfContract$MinOfSignedDate<-as.Date(as.character(dfContract$MinOfSignedDate))
    dfContract$StartFY<-DateToFiscalYear(dfContract$MinOfSignedDate)
  }
  
  if("MinOfSignedDate" %in% colnames(dfContract) &
     "UnmodifiedCurrentCompletionDate" %in% colnames(dfContract)){
    if(!"UnmodifiedDays" %in% colnames(dfContract))
      dfContract$UnmodifiedDays<-as.numeric(
        difftime(strptime(dfContract$UnmodifiedCurrentCompletionDate,"%Y-%m-%d")
                 , strptime(dfContract$MinOfSignedDate,"%Y-%m-%d")
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



decision_tree<-function(contract){
  contract$DecisionTree<-as.character(contract$MaxOfDecisionTree)
  contract$DecisionTree[
    contract$DecisionTree=="Excluded"|
      is.na(contract$DecisionTree)]<-"All Other"
  contract$DecisionTree<-factor(contract$DecisionTree,levels=c("OCO","Disaster","ARRA","All Other"))
  
  
  contract$DecisionTreeDisplay<-as.character( contract$DecisionTree)
  
  contract$DecisionTreeDisplay[
    (contract$StartFY<=2011 |
       contract$StartFY>2016
    ) &
      contract$DecisionTree=="OCO"]<-"Not in Sample"
  contract$DecisionTreeDisplay[contract$StartFY>=2012 &
                                 contract$StartFY<=2016 &
                                 contract$DecisionTree=="OCO"]<-"OCO ('12+)"
  contract$DecisionTreeDisplay[contract$DecisionTree=="Disaster"&
                                 contract$StartFY>=2007]<-"Disaster ('07+)"
  contract$DecisionTreeDisplay[contract$DecisionTree=="Disaster"&
                                 contract$StartFY<2007]<-"Not in Sample"
  contract$DecisionTreeDisplay[contract$DecisionTree=="ARRA"]<-"ARRA ('09-'13)"
  
  contract$DecisionTreeDisplay[contract$DecisionTree=="All Other" &
                                 contract$Intl=="Just U.S." &
                                 contract$Is.Defense=="Civilian"
                               ]<-"Other U.S. Civilian ('07+)"
  
  contract$DecisionTreeDisplay[contract$DecisionTree=="All Other" &
                                 contract$Intl=="Any Intl" &
                                 contract$Is.Defense=="Civilian"
                               ]<-"Other Intl. Civilian ('07+)"
  
  contract$DecisionTreeDisplay[contract$DecisionTree=="All Other" &
                                 contract$Intl=="Just U.S." &
                                 contract$Is.Defense=="Defense" &
                                 contract$StartFY>=2012 &
                                 contract$StartFY<=2016
                               ]<-"Other U.S. Defense ('12+)"
  
  contract$DecisionTreeDisplay[contract$DecisionTree=="All Other" &
                                 contract$Intl=="Any Intl" &
                                 contract$Is.Defense=="Defense" & 
                                 contract$StartFY>=2012 &
                                 contract$StartFY<=2016 
                               ]<-"Other Intl. Defense ('12+)"
  
  contract$DecisionTreeDisplay[contract$DecisionTree=="All Other" &
                                 contract$Is.Defense=="Defense" & 
                                 contract$StartFY<=2011 
                               ]<-"Not in Sample"
  
  contract$DecisionTreeDisplay[(contract$Intl=="Unlabeled") |
                                 is.na(contract$Is.Defense) &
                                 contract$DecisionTree=="All Other" 
                               ]<-"Not in Sample"
  
  contract$DecisionTreeDisplay<-factor(contract$DecisionTreeDisplay)
  contract
}


percent_obligated<-function(data,
                            num_col,
                            denom_col,
                            unmodified_col=NA,
                            overall_col=NA){
  data$p_obligated<-as.double(FactorToNumber(data[,num_col]))/
    as.double(FactorToNumber(data[,denom_col]))
  data$p_obligated[data$p_obligated>1]<-1
  data$p_obligated[data$p_obligated<0]<-NA
  if(!is.na(overall_col)&is.na(unmodified_col)){
    data[is.na(data$p_obligated),percent_col]<-
      data[is.na(data$p_obligated),overall_col]
  }
  else if (!is.na(unmodified_col)){
    if(!is.na(overall_col)){
      data[is.na(data[,unmodified_col]),unmodified_col]<-
        as.double(data[is.na(data[,unmodified_col]),overall_col])
    }
    data$p_obligated[is.na(data$p_obligated)]<-
      as.double(data[is.na(data$p_obligated),unmodified_col])
  }
  data$p_obligated
}

impute_unmodified<-function(unmodified,
                            full){
  NAlist<-is.na(unmodified)&
    !is.na(full)
  unmodified[NAlist]<-
    full[NAlist]
  
  unmodified
}



input_sample_criteria<-function(contract=NULL,
                                file="contract.SP_ContractSampleCriteriaDetailsCustomer.txt",
                                dir="Data\\",
                                drop_incomplete=TRUE,
                                last_year=2015,
                                retain_all=FALSE
){
  
  
  
  if(!exists("contract") | is.null(contract)){
    input<-swap_in_zip(file,dir)
    contract <-readr::read_delim(
      input,
      col_names=TRUE, 
      delim=get_delim(file),
      # , dec=".",
      trim_ws=TRUE,
      na=c("NULL","NA")
      # stringsAsFactors=FALSE
    )
  } else{
    contract<-csis360::read_and_join_experiment(data=contract
                                                ,file
                                                ,path=""
                                                ,dir
                                                ,by="CSIScontractID"
                                                ,new_var_checked=FALSE
    )
  }
  
  contract<-csis360::standardize_variable_names(contract)
  
  if(drop_incomplete==TRUE){
    #Limit to completed contracts that start in 2007 or later
    contract$LastCurrentCompletionDate<-strptime(contract$LastCurrentCompletionDate,"%Y-%m-%d") 
    #Drop contracts starting before the study period and not clearly end within it
    contract<-subset(contract, StartFiscal_Year>=2007   &
                       (LastCurrentCompletionDate<=paste(last_year,"09-30",sep="-") | IsClosed==1)
    )
  }
  
  # if(is.numeric(contract$Term)){
  #   contract$Term<-factor(contract$Term,
  #                         levels = c(0,1),
  #                         labels = c("Unterminated", "Terminated")
  #   )
  # }
  
  # contract<-subset(contract,select=-c(StartFiscal_Year
  # ,IsClosed
  # ,LastSignedLastDateToOrder
  #                                                       ,LastUltimateCompletionDate
  # ))
  
  if(retain_all==FALSE){
    contract<-contract[,!colnames(contract) %in% 
                         c(
                           # "StartFiscal_Year",
                           # "SumofObligatedAmount",
                           # "IsClosed"             ,
                           "LastSignedLastDateToOrder",
                           "LastUltimateCompletionDate",
                           # "LastCurrentCompletionDate",
                           # "MinOfSignedDate",
                           # "MinOfEffectiveDate",
                           "UnmodifiedContractObligatedAmount.1",
                           "UnmodifiedContractBaseAndExercisedOptionsValue.1",
                           "UnmodifiedContractBaseAndAllOptionsValue.2"
                         )]
  }
  contract
}


input_initial_scope<-function(contract,
                              file="Contract.SP_ContractUnmodifiedAndOutcomeDetailsCustomer.txt",
                              dir="Data\\",
                              retain_all=FALSE
){
  
  contract<-csis360::read_and_join_experiment(data=contract
                                              ,file
                                              ,path=""
                                              ,dir
                                              ,by="CSIScontractID"
                                              ,new_var_checked=FALSE
  )
  
  contract<-csis360::standardize_variable_names(contract)
  
  #Clear out 0 dates
  na_nonsense_dates<-function(dates){
    dates[dates=="1900-01-01" | dates=="9999-09-09"]<-NA
    dates
  }
  contract$MinOfEffectiveDate<-na_nonsense_dates(contract$MinOfEffectiveDate)
  contract$MinOfSignedDate<-na_nonsense_dates(contract$MinOfSignedDate)
  contract$LastCurrentCompletionDate<-na_nonsense_dates(contract$LastCurrentCompletionDate)
  contract$UnmodifiedCurrentCompletionDate<-na_nonsense_dates(contract$UnmodifiedCurrentCompletionDate)
  contract$UnmodifiedUltimateCompletionDate<-na_nonsense_dates(contract$UnmodifiedUltimateCompletionDate)
  contract$UnmodifiedLastDateToOrder<-na_nonsense_dates(contract$UnmodifiedLastDateToOrder)
  
  
  #Calculate the number of days the contract lasts.
  contract$UnmodifiedDays<-as.numeric(
    difftime(strptime(contract$UnmodifiedCurrentCompletionDate,"%Y-%m-%d")
             , strptime(contract$MinOfSignedDate,"%Y-%m-%d")
             , unit="days"
    ))+1
  #Remove negative durations and century-plus durations.
  contract$UnmodifiedDays[contract$UnmodifiedDays<1 |
                            contract$UnmodifiedDays>36524]<-NA
  # 
  # CDuration<-as.duration(strptime(contract$UnmodifiedCurrentCompletionDate,"%Y-%m-%d")-
  #                 strptime(contract$MinOfSignedDate,"%Y-%m-%d"))
  # 
  # CPeriod<-as.period(
  #     CInterval<-new_interval(ymd(contract$UnmodifiedCurrentCompletionDate),
  #                 ymd(contract$MinOfSignedDate))
  # 
  # 
  # 
  # summary(dYears)
  
  #Break the count of days into four categories.
  contract$qDuration<-cut2(contract$UnmodifiedDays,cuts=c(61,214,366,732))
  
  
  
  if ( 
    gsub(" ","",levels(contract$qDuration)[[2]]) =="[61,214)"&
    gsub(" ","",levels(contract$qDuration)[[3]]) =="[214,366)"&
    gsub(" ","",levels(contract$qDuration)[[4]]) =="[366,732)"
  ){
    contract$qDuration<-factor(contract$qDuration, 
                               
                               levels=levels(contract$qDuration),
                               # "[    0,   61)",
                               # "[   61,  214)",
                               # "[  214,  366)",
                               # "[  366,  732)",
                               # "[  732,33192]"),
                               labels=c("[0 months,~2 months)",
                                        "[~2 months,~7 months)",
                                        "[~7 months-~1 year]",
                                        "(~1 year,~2 years]",
                                        "(~2 years+]"),
                               ordered=TRUE
    )
  }
  
  
  
  
  lowroundedcutoffs<-c(15000,100000,1000000,30000000)
  highroundedcutoffs<-c(15000,100000,1000000,10000000,75000000)
  contract$qLowCeiling <- cut2(contract$UnmodifiedContractBaseAndAllOptionsValue,cuts=lowroundedcutoffs)
  contract$qHighCeiling <- cut2(contract$UnmodifiedContractBaseAndAllOptionsValue,cuts=highroundedcutoffs)
  rm(lowroundedcutoffs,highroundedcutoffs)
  
  
  
  if (gsub(" ","",levels(contract$qHighCeiling)[[2]]) =="[1.50e+04,1.00e+05)"&
      gsub(" ","",levels(contract$qHighCeiling)[[3]]) =="[1.00e+05,1.00e+06)"&
      gsub(" ","",levels(contract$qHighCeiling)[[4]]) =="[1.00e+06,1.00e+07)"&
      gsub(" ","",levels(contract$qHighCeiling)[[5]]) =="[1.00e+07,7.50e+07)"){
    contract$qHighCeiling<-factor(contract$qHighCeiling, 
                                  
                                  levels=levels(contract$qHighCeiling),
                                  labels=c("[0,15k)",
                                           "[15k,100k)",
                                           "[100k,1m)",
                                           "[1m,10m)",
                                           "[10m,75m)",
                                           "[75m+]"),
                                  ordered=TRUE
    )
  }
  
  
  
  if (gsub(" ","",levels(contract$qLowCeiling)[[2]]) =="[1.50e+04,1.00e+05)"&
      gsub(" ","",levels(contract$qLowCeiling)[[3]]) =="[1.00e+05,1.00e+06)"&
      gsub(" ","",levels(contract$qLowCeiling)[[4]]) =="[1.00e+06,3.00e+07)"){
    contract$qLowCeiling<-factor(contract$qLowCeiling, 
                                 
                                 levels=levels(contract$qLowCeiling),
                                 labels=c("[0,15k)",
                                          "[15k,100k)",
                                          "[100k,1m)",
                                          "[1m,30m)",
                                          "[30m+]"),
                                 ordered=TRUE
    )
  }
  
  
  
  
  summary(subset(contract$qCRais,contract$SumOfisChangeOrder>0    ))
  
  
  
  #Boolean value for ceiling breaches
  #Safety measure to make sure we don't assume it's never NA.
  contract$CBre <- NA
  contract$CBre[!is.na(contract$SumOfisChangeOrder)] <- "None"
  contract$CBre[contract$ChangeOrderBaseAndAllOptionsValue > 0
                & contract$SumOfisChangeOrder>0] <- "Ceiling Breach"
  contract$CBre<-ordered(contract$CBre,levels=c("None","Ceiling Breach"))
  
  
  
  #ContractWeighted <- apply_lookups(Path,ContractWeighted)
  
  
  
  if(retain_all==FALSE){
    contract<-contract[,!colnames(contract) %in% 
                         c(
                           #     UnmodifiedDays,
                           # UnmodifiedCurrentCompletionDate
                           # "MinOfSignedDate",
                           "LastUltimateCompletionDate"
                         )]
    
  }
  contract
  
  
}

input_contract_delta<-function(contract,
                               file="contract_SP_ContractModificationDeltaCustomer.csv",
                               dir="Data\\",
                               retain_all=FALSE
){
  
  # load(file="Data\\Federal_contract_CSIScontractID_complete.Rdata")
  
  contract<-csis360::read_and_join_experiment(contract,
                                              file,
                                              "",
                                              dir,
                                              by="CSIScontractID",
                                              new_var_checked=FALSE
  )
  
  contract<-csis360::standardize_variable_names(contract)
  
  contract$ChangeOrderObligatedAmount<-FactorToNumber(contract$ChangeOrderObligatedAmount)
  contract$ChangeOrderBaseAndAllOptionsValue<-FactorToNumber(contract$ChangeOrderBaseAndAllOptionsValue)
  
  
  
  contract$qNChg <- cut2(contract$SumOfisChangeOrder,c(1,2,3))
  
  
  # contract$pChangeOrderObligated<-contract$ChangeOrderObligatedAmount/
  #   contract$Action.Obligation
  # contract$pChangeOrderObligated[is.na(contract$pChangeOrderObligated)&
  #     contract$SumOfisChangeOrder==0]<-0
  contract$pChangeOrderUnmodifiedBaseAndAll<-contract$ChangeOrderBaseAndAllOptionsValue/
    contract$UnmodifiedContractBaseAndAllOptionsValue
  contract$pChangeOrderUnmodifiedBaseAndAll[
    is.na(contract$pChangeOrderUnmodifiedBaseAndAll) & contract$SumOfisChangeOrder==0]<-0
  
  #Boolean value for ceiling breaches
  #Safety measure to make sure we don't assume it's never NA.
  contract$CBre <- NA
  contract$CBre[!is.na(contract$SumOfisChangeOrder)] <- "None"
  contract$CBre[contract$ChangeOrderBaseAndAllOptionsValue > 0
                & contract$SumOfisChangeOrder>0] <- "Ceiling Breach"
  contract$CBre<-ordered(contract$CBre,levels=c("None","Ceiling Breach"))
  
  
  contract$qCRais <- cut2(
    contract$pChangeOrderUnmodifiedBaseAndAll,c(
      -0.001,
      0.001,
      0.15)
  )
  #                                               min(subset(
  #                                                   contract$pChangeOrderObligated,
  #                                                   contract$pChangeOrderObligated>0)),
  if(retain_all==FALSE){
    
    contract<-contract[,!colnames(contract) %in% 
                         c(
                           "ChangeOrderObligatedAmount"             ,
                           "ChangeOrderBaseAndExercisedOptionsValue",
                           #     ChangeOrderBaseAndAllOptionsValue      ,
                           "NewWorkObligatedAmount",
                           "NewWorkBaseAndExercisedOptionsValue"    ,
                           # "NewWorkBaseAndAllOptionsValue",
                           # "SumOfisChangeOrder",
                           "MaxOfisChangeOrder",
                           # "SumOfisNewWork"
                           "MaxOfisNewWork"
                         )]
    
  }
  
  contract
}