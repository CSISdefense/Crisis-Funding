library(lubridate)
library(csis360)
library(Hmisc)
library(readr)


#This function generates some derived figures for a contrat sample that's been augmented
#by extra column on closed out and/or terminated contracts.
transform_endings<-function(contract){
  if("MaxClosedDate" %in% colnames(contract)){
    contract$PreCloseLength<-contract$MaxClosedDate-contract$MinOfSignedDate
    contract$PostCloseSignedLength<-contract$MaxBoostDate-contract$MaxClosedDate
    contract$PostCloseCurrentLength<-contract$LastCurrentCompletionDate-contract$MaxClosedDate
  }
  
  if("MaxTerminatedDate" %in% colnames(contract)){
    contract$EndType<-as.character(NA)
    contract$EndType[contract$IsClosed==1 & contract$Term==0]<-"Close Out"
    contract$EndType[contract$IsClosed==1 & contract$Term==1 & contract$isDefaultOrCause==1]<-"Term: ~Default"
    contract$EndType[contract$IsClosed==1 & contract$Term==1 & contract$isDefaultOrCause==0]<-"Term: Canceled"
    contract$EndType[(contract$IsClosed==0|is.na(contract$IsClosed)) & contract$Term==1 & contract$isDefaultOrCause==0]<-"Term: Convenience"
    contract$EndType[(contract$IsClosed==0|is.na(contract$IsClosed)) & contract$Term==1 & contract$isDefaultOrCause==1]<-"Term: Cause"
    contract$EndType<-factor(contract$EndType,levels=c("Close Out","Term: ~Default","Term: Canceled",
                                                       "Term: Convenience","Term: Cause"))
    
    contract$ThroughTerm<-contract$ObligatedBeforeMaxTerminatedDate+
      contract$ObligatedOnMaxTerminatedDate
    contract$PostTermFloor0<-contract$ObligatedAfterMaxTerminatedDate
    contract$PostTermFloor0[contract$PostTermFloor0<0]<-0
    contract$PreTermFloor1<-contract$ThroughTerm
    contract$PreTermFloor1[contract$ThroughTerm<1]<-1
    contract$TermPct<-contract$PostTermFloor0/(contract$PostTermFloor0+contract$PreTermFloor1)
    summary(contract$TermPct)
    
    contract$NoPreTermObl<-"Some Net $s Pre-contract."
    contract$NoPreTermObl[contract$ObligatedBeforeMaxTerminatedDate<=0]<-"0 Pre-contract"
    contract$NoPreTermObl<-factor(contract$NoPreTermObl)
    
    contract$TermPctCat<-Hmisc::cut2(contract$TermPct,c(0.25,0.5))
    summary(contract$TermPctCat)
    # levels(contract$TermPctCat)[3]<-"[50%+]"
    contract$TermPctCat<-as.character(contract$TermPctCat)
    contract$TermPctCat[contract$TermPct==0]<-"[0]"
    contract$TermPctCat[contract$TermPct==0 & contract$ObligatedOnMaxTerminatedDate>0]<-"[0]+Last Day Spend"
    # contract$TermPctCat[contract$TermPct==0 & contract$ObligatedOnMaxTerminatedDate>0 & contract$MaxTerminatedDate<=contract$MinOfSignedDate]<-"[0]+One Day Spend"
    contract$TermPctCat<-factor(contract$TermPctCat)
    
    
    contract$TermPartial<-contract$TermPctCat
    levels(contract$TermPartial)<-list(
      "Complete Termination"=c("[0]+No Last Day Spend","[0]+Last Day Spend","(0%,25%)"),
      "Partial Termination"=c("[25%,50%)","[50%+]")
    )
    
    contract$TermPctCat3<-contract$TermPctCat
    levels(contract$TermPctCat3)<-list(
      "Term Ends Spend"="[0]+No Last Day Spend",
      "Last Day Spend"="[0]+Last Day Spend",
      "Any After"=c("(0%,10%)","[10%,100%)","[100%+]")
    )
    
    contract$FirstDayTerm<-"No"
    contract$FirstDayTerm[contract$MaxTerminatedDate==contract$MinOfSignedDate]<-"Yes"
    
    contract$LastCurrentCompletionDate<-na_nonsense_dates(contract$LastCurrentCompletionDate)
    contract$PreTermLength<-contract$MaxTerminatedDate-contract$MinOfSignedDate
    contract$PostTermSignedLength<-contract$MaxBoostDate-contract$MaxTerminatedDate
    contract$LastCurrentCompletionDate<-as.Date(contract$LastCurrentCompletionDate)
    contract$PostTermCurrentLength<-contract$LastCurrentCompletionDate-contract$MaxTerminatedDate
    
    if("PreTermLength" %in% colnames(contract)){
      #Imput close out lengths for unterminated  contracts
      contract$PreTermCloseLength<-contract$PreTermLength
      contract$PreTermCloseLength[is.na(contract$PreTermCloseLength)]<-
        contract$PreCloseLength[is.na(contract$PreTermCloseLength)]
      
      contract$PostTermCloseSignedLength<-contract$PostTermSignedLength
      contract$PostTermCloseSignedLength[is.na(contract$PostTermCloseSignedLength)]<-
        contract$PostCloseSignedLength[is.na(contract$PostTermCloseSignedLength)]
      
      
      contract$PostTermCloseCurrentLength<-contract$PostTermCurrentLength
      contract$PostTermCloseCurrentLength[is.na(contract$PostTermCloseCurrentLength)]<-
        contract$PostCloseCurrentLength[is.na(contract$PostTermCloseCurrentLength)]
    }
    
  }
  contract
}

rename_dataset<-function(contract){
  
  colnames(contract)[colnames(contract)=="SubCustomer.sum"]<-"Who"
  # colnames(contract)[colnames(contract)=="UnmodifiedIsSomeCompetition"]<-"Comp"
  colnames(contract)[colnames(contract)=="UnmodifiedPlatformPortfolio"]<-"What"
  colnames(contract)[colnames(contract)=="IsIDV"]<-"IDV"
  colnames(contract)[colnames(contract)=="FixedOrCost"]<-"FxCb"
  colnames(contract)[colnames(contract)=="AnyPlaceInternational"]<-"Intl"
  colnames(contract)[colnames(contract)=="SimpleArea"]<-"PSR"
  colnames(contract)[colnames(contract)=="qLowCeiling"]<-"LowCeil"
  if(!"Ceil" %in% colnames(contract))
    colnames(contract)[colnames(contract)=="qHighCeiling"]<-"Ceil"
  colnames(contract)[colnames(contract)=="Dur"]<-"qDuration"
  # colnames(contract)[colnames(contract)=="SingleOffer"]<-"One"
  colnames(contract)[colnames(contract)=="qOffers"]<-"Offr"
  colnames(contract)[colnames(contract)=="IsTerminated"]<-"Term"
  colnames(contract)[colnames(contract)=="SimpleVehicle"]<-"Veh"
  colnames(contract)[colnames(contract)=="LabeledMDAP"]<-"MDAP"
  # colnames(contract)[colnames(contract)=="qNChg"]<-"NChg"
  # colnames(contract)[colnames(contract)=="qCRais"]<-"CRai"
  colnames(contract)[colnames(contract) %in% c("StartFiscal_Year","StartFiscalYear")]<-"StartFY"
  colnames(contract)[colnames(contract)=="topContractingOfficeAgencyID"]<-"Agency"
  colnames(contract)[colnames(contract)=="topContractingOfficeID"]<-"Office"
  if(!"ProdServ" %in% colnames(contract))
    colnames(contract)[colnames(contract) %in% c("topProductOrServiceCode","ProductOrServiceCode")]<-"ProdServ"
  colnames(contract)[colnames(contract)=="topPrincipalNAICScode"]<-"NAICS"
  colnames(contract)[colnames(contract)=="UnmodifiedPlaceCountryISO3"]<-"Where"
  colnames(contract)[colnames(contract)=="GrossObligatedAmount"]<-"Gross"
  
  contract<-transition_variable_names_common(contract)
  if(any(duplicated(colnames(contract)))) stop("Duplicate Contract Name")
  contract
}

trim_dataset<-function(contract){
  
  keep_list<-c(
    "CSIScontractID",
    # IsIDV,
    "FxCb",
    "Fee",
    "UCA",
    "Comp",
    "EffComp",
    "Urg",
    # MDAP,
    # unmodifiedSystemequipmentcode,
    "Who",
    "Veh",
    "PSR",
    "What",
    "Where",
    "Intl",
    "PlaceCountryISO3",
    "VendorCountryISO3",
    "OriginCountryISO3",
    # "LowCeil",
    # "Ceil",
    # "qDuration",
    "Offr",
    # IsIDV,
    # Soft,
    "CBre",
    # "qCRais",
    # "qNChg",
    "Term",
    "UnmodifiedNumberOfOffersReceived",
    "UnmodifiedBase",
    "SteadyScopeOptionGrowthAlone",
    "UnmodifiedCeiling",
    "SumOfisChangeOrder",
    "ChangeOrderCeilingGrowth",
    "n_CBre",
    # "AdminCeilingModification",
    # "NewWorkUnmodifiedBaseAndAll",
    # pChangeOrderObligated,
    "UnmodifiedDays",
    # "MinOfEffectiveDate",
    "StartFY",
    "StartCY",
    "Action_Obligation",
    "Agency",
    "Office",
    "ProdServ",
    "NAICS",
    "Crisis",
    "MaxOfDecisionTree",
    # "MaxOfDecisionTreeStep4",
    "MinOfDecisionTree",
    # "MinOfDecisionTreeStep4"
    "LastCurrentCompletionDate",
    "UnmodifiedCurrentCompletionDate",
    "IsClosed",
    "MinOfSignedDate",
    "MaxBoostDate"
  )
  
  missing<-keep_list[!keep_list %in% colnames(contract)]
  
  #Don't note something as missing if a sufficiently detailed variant is available
  if("Agency" %in% colnames(contract)) missing<-missing[!missing %in% c("Who")]
  if("UnmodifiedNumberOfOffersReceived" %in% colnames(contract)) missing<-missing[!missing %in% c("Offr")]
  if("ProdServ" %in% colnames(contract)) missing<-missing[!missing %in% c("PSR")]
  if("MinOfSignedDate" %in% colnames(contract)) missing<-missing[!missing %in% c("StartFY","StartCY")]
  
  if(length(missing)>1) warning(paste("Missing Cols:",paste(missing,collapse=", ")))
  
  
  contract<-contract[,colnames(contract) %in% keep_list]
  # 
  contract
}

FormatContractModel<-function(dfContract){
  
  
  
  if(is.null(dfContract$Ceil) &
     is.null(dfContract$LowCeil) &
     "UnmodifiedCeiling" %in% colnames(dfContract)){
    lowroundedcutoffs<-c(15000,100000,1000000,30000000)
    highroundedcutoffs<-c(15000,100000,1000000,10000000,75000000)
    dfContract$qLowCeiling <- cut2(dfContract$UnmodifiedCeiling,cuts=lowroundedcutoffs)
    dfContract$qHighCeiling <- cut2(dfContract$UnmodifiedCeiling,cuts=highroundedcutoffs)
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
  
  
  if(is.null(dfContract$qDuration) & 
     "UnmodifiedDays" %in% colnames(dfContract)){
    #Break the count of days into four categories.
    dfContract$qDuration<-cut2(dfContract$UnmodifiedDays,cuts=c(61,214,366,732))
    
  }
  
  
  
  
  if ( "qDuration" %in% colnames(dfContract) & 
       gsub(" ","",levels(dfContract$qDuration)[[2]]) =="[61,214)"&
       gsub(" ","",levels(dfContract$qDuration)[[3]]) =="[214,366)"&
       gsub(" ","",levels(dfContract$qDuration)[[4]]) =="[366,732)"
  ){
    dfContract$qDuration<-factor(dfContract$qDuration, 
                           
                           levels=levels(dfContract$qDuration),
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
  
  
  
  if(!is.null(dfContract$qDuration) & all(
    levels(dfContract$qDuration) %in% c("[0 months,~2 months)",
                                  "[~2 months,~7 months)",
                                  "[~7 months-~1 year]",
                                  "(~1 year,~2 years]",
                                  "(~2 years+]"
    ))){
    dfContract$qDuration<-factor(dfContract$qDuration,
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
  
  
  if(is.null(dfContract$qCRais) & 
     "pChangeOrderUnmodifiedBaseAndAll" %in% colnames(dfContract)){
    
    dfContract$CRais <- cut2(
      dfContract$pChangeOrderUnmodifiedBaseAndAll,c(
        -0.001,
        0.001,
        0.15)
    )
  }
  
  
  if(is.null(dfContract$qNChg)  & 
     "SumOfisChangeOrder" %in% colnames(dfContract)){
    
    dfContract$qNChg <- cut2(dfContract$SumOfisChangeOrder,c(1,2,3))
    
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
    dfContract$StartCY<-year(dfContract$MinOfSignedDate)
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
  data$p_obligated<-as.double(unlist(csis360::text_to_number(data[,num_col])))/
    as.double(unlist(csis360::text_to_number(data[,denom_col])))
  data$p_obligated[data$p_obligated>1]<-1
  data$p_obligated[data$p_obligated<0]<-NA
  if(!is.na(overall_col)&is.na(unmodified_col)){
    data[is.na(data$p_obligated),percent_col]<-
      data[is.na(data$p_obligated),overall_col]
  }
  else if (!is.na(unmodified_col)){
    if(!is.na(overall_col)){
      data[is.na(data[,unmodified_col]),unmodified_col]<-
        as.double(unlist(data[is.na(data[,unmodified_col]),overall_col]))
    }
    data$p_obligated[is.na(data$p_obligated)]<-
      as.double(unlist(data[is.na(data$p_obligated),unmodified_col]))
  }
  data$p_obligated
}

#Clear out 0 dates
na_nonsense_dates<-function(dates){
  dates[dates=="1900-01-01" | dates=="9999-09-09"]<-NA
  dates
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
                                file="Contract_SP_ContractSampleCriteriaDetailsCustomer.txt",
                                dir="..\\data\\semi_clean\\",
                                drop_incomplete=TRUE,
                                last_date="2016-12-31",
                                retain_all=FALSE
){
  
  
  
  if(!exists("contract") | is.null(contract)){
    # swap_in_zip(file,"",dir)
    contract <-readr::read_delim(
      paste(dir,file,sep=""),
      col_names=TRUE, 
      delim=get_delim(file),
      # , dec=".",
      trim_ws=TRUE,
      na=c("NULL","NA")
      # stringsAsFactors=FALSE
    )
  } else{
    
    # Prevent Action_Obligation clashes.
    colnames(contract)[colnames(contract)=="Action_Obligation"]<-"SumofObligatedAmount"
    
    contract<-csis360::read_and_join_experiment(data=contract
                                                ,file
                                                ,path=""
                                                ,dir
                                                ,by="CSIScontractID"
                                                ,new_var_checked=FALSE
                                                ,create_lookup_rdata=TRUE
    )
  }
  
  contract<-csis360::standardize_variable_names(contract)
  
  if("MinOfEffectiveDate" %in% colnames(contract)){
    contract$MinOfEffectiveDate<-na_nonsense_dates(contract$MinOfEffectiveDate)
  }
  contract$MinOfSignedDate<-na_nonsense_dates(contract$MinOfSignedDate)
  contract$LastCurrentCompletionDate<-na_nonsense_dates(contract$LastCurrentCompletionDate)
  if("MaxBoostDate" %in% colnames(contract)){
    contract$MaxBoostDate<-na_nonsense_dates(contract$MaxBoostDate) 
  } else {paste("Missing MaxBoostDate, redownload please.",file)}

  if(!"StartFiscal_Year" %in% colnames(contract)){
    contract$StartFiscal_Year<-year(contract$MinOfSignedDate)+ifelse(month(contract$MinOfSignedDate)>=10,1,0)
  }
  
  #These two are a bit lazy, ideally we'd fix it. But I think it's not going to come up, so input protection is first.
  if(!is.numeric(contract$IsTerminated)) stop("Expect IsTerminated to be numeric.")
  if(!is.numeric(contract$IsClosed)) stop("Expect IsClosed to be numeric.")
  
  contract$IsComplete<-0
    #Limit to completed contracts that start in 2007 or later
    contract$IsComplete[contract$StartFiscal_Year>=2007 & 
                       #For unclosed out contracts both current completion and last signed should before  2016
                       (contract$MaxBoostDate<=as.Date(last_date)| is.na(contract$MaxBoostDate))&
                       (contract$LastCurrentCompletionDate<=as.Date(last_date)
                        #For closed out it's enough that the boost date is within the range.
                        | (contract$IsClosed==1 | contract$IsTerminated==1))
                     ]<-1
  
  if(drop_incomplete==TRUE){
    contract<-contract %>% dplyr::filter(IsComplete==1)
    contract<-contract %>%dplyr::filter(is.na(IsParentCSIScontractID) | IsParentCSIScontractID==0)
  }
    
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
                           "UnmodifiedBase.1",
                           "UnmodifiedCeiling.2"
                         )]
  }
  contract
}


input_initial_scope<-function(contract,
                              file="Contract_SP_ContractUnmodifiedScope.txt",
                              dir="..\\data\\semi_clean\\",
                              retain_all=FALSE,
                              col_types="idddDDDl"
){
  
  contract<-csis360::read_and_join_experiment(data=contract
                                              ,file
                                              ,path=""
                                              ,dir
                                              ,by="CSIScontractID"
                                              ,new_var_checked=FALSE
                                              ,col_types = col_types
                                              ,create_lookup_rdata=TRUE
  )
  
  contract<-csis360::standardize_variable_names(contract)
  

  

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
  contract$qLowCeiling <- cut2(contract$UnmodifiedCeiling,cuts=lowroundedcutoffs)
  contract$qHighCeiling <- cut2(contract$UnmodifiedCeiling,cuts=highroundedcutoffs)
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

input_contract_ceiling_breach<-function(contract,
                               file="contract_SP_ContractCeilingBreachCustomer.txt",
                               dir="..\\data\\semi_clean\\",
                               retain_all=FALSE
){
  
  # load(file="..\\data\\semi_clean\\Federal_contract_CSIScontractID_complete.Rdata")
  if(!"UnmodifiedCeiling" %in% colnames(contract)) stop("UnmodifiedCeiling is missing from the data frame.")
  
  #Drop ContractBaseAndAllOptionsValue as it ends up duplicated after  being incorporated by a different name then standardized.
  if("ContractBaseAndAllOptionsValue" %in% colnames(contract)) contract <- contract %>% dplyr::select(-ContractBaseAndAllOptionsValue)
  contract<-read_and_join_experiment(contract,
                                              file,
                                              "",
                                              dir,
                                              by="CSIScontractID",
                                              new_var_checked=FALSE,
                                     create_lookup_rdata=TRUE
  )
  
  contract<-csis360::standardize_variable_names(contract)
  
  # contract$ChangeOrderObligatedAmount<-csis360::text_to_number(contract$ChangeOrderObligatedAmount)
  contract$ChangeOrderCeilingGrowth<-csis360::text_to_number(contract$ChangeOrderCeilingGrowth)
  contract$ChangeOrderCeilingRescision<-csis360::text_to_number(contract$ChangeOrderCeilingRescision)
  contract$AdminCeilingModification<-csis360::text_to_number(contract$AdminCeilingModification)
  
  summary(subset(contract$qCRais,contract$SumOfisChangeOrder>0    ))
  
  contract$qNChg <- cut2(contract$SumOfisChangeOrder,c(1,2,3))
  
  
  # contract$pChangeOrderObligated<-contract$ChangeOrderObligatedAmount/
  #   contract$Action_Obligation
  # contract$pChangeOrderObligated[is.na(contract$pChangeOrderObligated)&
  #     contract$SumOfisChangeOrder==0]<-0
    contract$pChangeOrderUnmodifiedBaseAndAll<-(
      contract$ChangeOrderCeilingGrowth+
        contract$ChangeOrderCeilingRescision)/contract$UnmodifiedCeiling
  contract$pChangeOrderUnmodifiedBaseAndAll[
    is.na(contract$pChangeOrderUnmodifiedBaseAndAll) & contract$SumOfisChangeOrder==0]<-0
  
  #Boolean value for ceiling breaches
  #Safety measure to make sure we don't assume it's never NA.
  contract$CBre <- NA
  contract$CBre[!is.na(contract$SumOfisChangeOrder)] <- "None"
  contract$CBre[contract$ChangeOrderCeilingGrowth > 0
                & contract$SumOfisChangeOrder>0] <- "Ceiling Breach"
  contract$CBre<-ordered(contract$CBre,levels=c("None","Ceiling Breach"))

  
  
  #Boolean value for ceiling breaches
  #Safety measure to make sure we don't assume it's never NA.
  contract$CBre <- NA
  contract$CBre[!is.na(contract$SumOfisChangeOrder)] <- "None"
  contract$CBre[contract$ChangeOrderCeilingGrowth > 0
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
                           #     ChangeOrderCeilingGrowth      ,
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

input_contract_psc_office_naics<-function(contract,
                                          file="Contract_SP_ContractTopPSCofficeNAICS.txt",
                                          dir="..\\data\\semi_clean\\",
                                          retain_all=FALSE
                                          ){
  
  # contract<-plyr::join(contract,test)
  # test<-read_delim("..\\data\\semi_clean\\Contract.SP_ContractTopPSCofficeNAICS.txt",delim="\t",
  #                  na=c("NA","NULL"),
  #                  col_types="icdcdcdcd")
  # c(col_integer(),
  #   col_character(),
  #   col_double(),
  #   col_character(),
  #   col_double(),
  #   col_character(),
  #   col_double(),
  #   col_character(),
  #   col_double()))

  
  contract<-read_and_join_experiment(data=contract,
                                             file,
                                             "",
                                             dir,
                                             by="CSIScontractID",
                                             new_var_checked=FALSE,
                                             col_types="icdcdcdcd"
  )
  
  contract$topContractingOfficeAgencyID<-factor(
    contract$topContractingOfficeAgencyID
  )
  contract$topContractingOfficeID<-factor(
    contract$topContractingOfficeID
  )
  contract$topProductOrServiceCode<-factor(
    contract$topProductOrServiceCode
  )
  contract$topPrincipalNAICScode<-factor(
    contract$topPrincipalNAICScode
  )
  
  
  contract<-contract[,!colnames(contract) %in% 
                     c(
                       # "topContractingOfficeAgencyID",
                       "topContractingOfficeAgencyIDamount"      ,
                       # "topContractingOfficeID",
                       "topContractingOfficeAmount"  ,
                       # "topProductOrServiceCode",
                       "topProductOrServiceAmount"               ,
                       # "topPrincipalNAICScode",
                       "topPrincipalNAICSamount")]
  # load(file="..\\data\\semi_clean\\Federal_contract_CSIScontractID_complete.Rdata")
  
}


sample_prep<-function(contract){
  #What - Product Or Service Code
  colnames(contract)[colnames(contract)=="ProdServ"]<-"ProductOrServiceCode"
  contract$ProductOrServiceCode<-as.character(contract$ProductOrServiceCode)
  contract<-csis360::read_and_join( contract,
                                "ProductOrServiceCodes.csv",
                                path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                                directory="",
                                by="ProductOrServiceCode",
                                add_var=c("Simple",
                                          "ProductServiceOrRnDarea",
                                          "ProductOrServiceArea",
                                          "HostNation3Category",
                                          "CrisisProductOrServiceArea",
                                          "ProductOrServiceCodeText"
                                ),
                                new_var_checked=FALSE)
  contract$ProductServiceOrRnDarea<-factor(contract$ProductServiceOrRnDarea)
  contract$ProductOrServiceArea<-factor(contract$ProductOrServiceArea)
  contract$HostNation3Category<-factor(contract$HostNation3Category)
  contract$CrisisProductOrServiceArea<-factor(contract$CrisisProductOrServiceArea)
  contract$ProductOrServiceCodeText<-factor(contract$ProductOrServiceCodeText)
  contract$ProductOrServiceCode<-factor(contract$ProductOrServiceCode)
  contract$ServCommCons<-contract$HostNation3Category
  contract$CPSA<-as.character(contract$CrisisProductOrServiceArea)
  contract$CPSA<-factor(gsub(" & ","+",contract$CPSA))
  
  contract$PSA<-as.character(contract$ProductOrServiceArea)
  contract$PSA<-gsub(" & ","+",contract$PSA)
  contract$b_NoComp<-!contract$b_Comp
  colnames(contract)[colnames(contract)=="ProductOrServiceCode"]<-"ProdServ"
  
  
  
  
  #Who - Agency
  colnames(contract)[colnames(contract)=="Agency"]<-"AgencyID"
  contract<-csis360::read_and_join( contract,
                                    "Agency_AgencyID.csv",
                                    path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                                    directory="",
                                    by="AgencyID",
                                    add_var=c("AgencyIDtext",
                                              "DepartmentID",
                                              "Customer",
                                              "SubCustomer"
                                    ),
                                    new_var_checked=FALSE)
  colnames(contract)[colnames(contract)=="AgencyID"]<-"Agency"
  
  if(!"Is.Defense" %in% colnames(contract)){
  contract$Is.Defense<-contract$Customer
    levels(contract$Is.Defense)<- list("Defense"=c("Defense"),
                                             "Civilian"=c("DHS","Energy","GSA","HHS","NASA",
                                                          "Other Agencies","State and IAP","VA"))
  }
  contract$Customer<-factor(contract$Customer)
  contract$DepartmentID<-factor(contract$DepartmentID)
  contract$SubCustomer<-factor(contract$SubCustomer)
  contract$Dur.Simple<-factor(contract$Dur.Simple)
  
  
  #Where - Place, Vendor, Origin
  
  contract<-iso3(contract,"PlaceCountryISO3","place")
  contract<-iso3(contract,"VendorCountryISO3","vendor")
  contract<-iso3(contract,"OriginCountryISO3","origin")
  
  contract
}

iso3<-function(contract,colname,prefix){
  colnames(contract)[colnames(contract)==colname]<-"alpha.3"
  contract<-csis360::read_and_join( contract,
                                    "Location_CountryCodes.csv",
                                    path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                                    directory="location/",
                                    by="alpha.3",
                                    add_var=c("CrisisFundingTheater",
                                              "CombatantCommand",
                                              "isforeign",
                                              "SubCustomer"
                                    ),
                                    new_var_checked=FALSE)
  colnames(contract)[colnames(contract)=="alpha.3"]<-colname
  contract$CrisisFundingTheater<-factor(contract$CrisisFundingTheater)
  contract$CombatantCommand<-factor(contract$CombatantCommand)
  contract$isforeign<-factor(contract$isforeign)
  
  
  colnames(contract)[colnames(contract) %in% c("CrisisFundingTheater",
                                               "CombatantCommand",
                                               "isforeign")]<-
    paste(prefix,
          colnames(contract)[colnames(contract) %in% c("CrisisFundingTheater",
                                                       "CombatantCommand",
                                                       "isforeign")]
          ,sep="_"
    )
  contract
}

get_complete_list<-function(contract,crisis=FALSE){
  complete<-  #Dependent Variables
    !is.na(contract$b_Term)&
    !is.na(contract$b_CBre)&
    #Study Variables
    !is.na(fed$Crisis)&
    !is.na(contract$b_Comp)&
    !is.na(contract$b_Urg)&
    !is.na(contract$NoCompOffr)&
    !is.na(contract$UCA)&
    !is.na(fed$OffPlace)&
    #Controls
    !is.na(contract$cln_Ceil)&
    !is.na(contract$cln_Days)&
    !is.na(contract$Veh) &
    !is.na(contract$PricingFee)&
    !is.na(contract$b_Intl)&
    !is.na(contract$ProdServ)&
    #Multilevel variables
    !is.na(fed$CrisisProductOrServiceArea)&
    !is.na(contract$Office)&
    !is.na(contract$Agency)&
    !is.na(contract$PlaceCountryISO3)&
    !is.na(contract$VendorCountryISO3)&
    !is.na(contract$OriginCountryISO3)&
    !is.na(contract$OffCri)&
    !is.na(contract$OffIntl)
    # !is.na(contract$Is.Defense)
  # !is.na(contract$cl_HHI_lag1)
    # !is.na(fed$b_Intl)&
    !is.na(fed$NAICS)&
    # !is.na(fed$NAICS3)&
    
  
  length(which(is.na(contract$b_Term)))/nrow(contract)
  length(which(is.na(contract$b_CBre)))/nrow(contract)
  length(which(is.na(contract$b_Comp)))/nrow(contract)
  length(which(is.na(contract$b_Urg)))/nrow(contract)
  length(which(is.na(contract$NoCompOffr)))/nrow(contract)
  length(which(is.na(contract$cl_Ceil)))/nrow(contract)
  length(which(is.na(contract$cl_Days)))/nrow(contract)
  length(which(is.na(contract$Veh)))/nrow(contract)
  length(which(is.na(contract$n_Fixed)))/nrow(contract)
  length(which(is.na(contract$b_Intl)))/nrow(contract)
  length(which(is.na(contract$b_UCA)))/nrow(contract)
  length(which(is.na(contract$ProdServ)))/nrow(contract)
  length(which(is.na(contract$Crisis)))/nrow(contract)
  length(which(is.na(contract$PlaceCountryISO3)))/nrow(contract)
  length(which(is.na(contract$VendorCountryISO3)))/nrow(contract)
  length(which(is.na(contract$OffCri)))/nrow(contract)
  length(which(is.na(contract$OffIntl)))/nrow(contract)
  
  
  
  complete
}

#Creating crisis sample
#I don't believe I use this approach anymore.
get_crisis_sample_with_na<-function(contract,large=FALSE){
  batch_size<-100000
  if(large==TRUE)
    batch_size<-300000
  
  crisis_with_na<-contract[contract$Crisis %in% c("ARRA","Dis"),]
  oco<-contract[contract$Crisis %in% c("OCO"),]
  if(large==FALSE)
    oco<-oco[sample(nrow(oco),batch_size),]
  crisis_with_na<-rbind(crisis_with_na,oco)
  rm(oco)
  other_intl<-contract[contract$Crisis %in% c("Other")&contract$b_Intl==1,]
  other_dom<-contract[contract$Crisis %in% c("Other")&(contract$b_Intl==0
                                             |is.na(contract$b_Intl)),]#This used to be OffCri
  other_dom<-other_dom[sample(nrow(other_dom),batch_size),]
  other_intl<-other_intl[sample(nrow(other_intl),batch_size),]
  crisis_with_na<-rbind(crisis_with_na,other_dom,other_intl)
  rm(other_dom,other_intl)
  
  crisis_with_na<-sample_prep(crisis_with_na)
  
}



place_compare<-function(contract,comparecol,newcol,comparename,placecol="PlaceCountryISO3"){
  contract[[newcol]]<-NA
  contract[!(contract[[placecol]] %in% c("USA","*MF","*MU"))&
                                 contract[[placecol]]==contract[[comparecol]],newcol]<-paste("Host Nation",comparename)
  contract[contract[[comparecol]]=="USA",newcol]<-paste("U.S. ",comparename)
  contract[contract[[comparecol]]=="*MF",newcol]<-paste("Foreign ",comparename,"s",sep="")
  contract[contract[[comparecol]]=="*MU",newcol]<-paste("U.S. & Foreign ",comparename,"s",sep="")
  contract[contract[[placecol]]!=contract[[comparecol]]&
                                 !contract[[comparecol]] %in% c("USA","*MF","*MU"),
           newcol]<-paste("Third Country",comparename)
  contract[,newcol]<-factor(contract[[newcol]])
  contract
}



add_col_from_transformed<-function(sample,transformed,col=NULL){
  warning("add_col_from_transformed is deprecated, use csis360::update_sample_col_CSIScontractID isntead")
  update_sample_col_CSIScontractID(sample,
                                             transformed,
                                             col=col, 
                                             drop_and_replace=FALSE)
}
