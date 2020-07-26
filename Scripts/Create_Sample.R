# ---
# title: "Create Sample"
# output:
#   html_document:
#     keep_md: yes
#     toc: yes
# date: "Wednesday, July 11, 2019"
# ---

#Setup
library(csis360)
library(ggplot2)
library(dplyr)
library(arm)
library(R2WinBUGS)
library(knitr)
library(foreign)
library(stargazer)
library(texreg)
library(reshape2)
library(tidyverse)
source("https://raw.githubusercontent.com/CSISdefense/Vendor/master/Scripts/DIIGstat.r")


##Prepare Data
##First we load the data. The dataset used is a U.S. Federal Contracting dataset derived from   FPDS.

###Data Transformations and Summary
#### ReadInData 

if(!exists("fed"))  load(file="data\\clean\\transformed_fed.rdata")

head(fed)
## Functional transformations on data


#Output variables
summary(fed$b_Term)
summary(fed$b_CBre)
# summary(fed$ln_CBre_Then_Year)
# summary(fed$p_CBre)
#Study Variables
summary(fed$CompOffr)
summary(fed$b_Comp )
summary(fed$n_Comp )
summary(fed$b_Urg)
summary(fed$EffComp )
summary(fed$NoCompOffr)
summary(fed$UCA)

summary(fed$PlaceCountryISO3)
summary(fed$VendorCountryISO3)
summary(fed$OriginCountryISO3)

summary(fed$Crisis)

# summary(fed$cl_def3_HHI_lag1) 
# summary(fed$cl_def6_HHI_lag1) 
#Controls
# summary(fed$cl_Ceil_Then_Year)
summary(fed$cln_Days)
summary(fed$Veh) 
summary(fed$PricingFee)
summary(fed$b_Intl)

summary(fed$NAICS)
# summary(fed$NAICS3)
summary(fed$Office)
summary(fed$Agency)
summary(fed$CrisisProductOrServiceArea)
# summary(fed$StartCY)
# summary(fed$cl_def3_ratio_lag1) 
# summary(fed$cl_def6_obl_lag1)
# summary(fed$cl_def6_ratio_lag1)
# summary(fed$cl_US6_avg_sal_lag1)



# Next, we eliminate missing data entries. 



complete<-
  #Dependent Variables
  !is.na(fed$b_Term)&
  !is.na(fed$b_CBre)&
  #Study Variables
  !is.na(fed$NoCompOffr)&
  !is.na(fed$UCA)&
  !is.na(fed$PlaceCountryISO3)&
  !is.na(fed$VendorCountryISO3)&
  !is.na(fed$OriginCountryISO3)&
  !is.na(fed$Crisis)&
  # !is.na(fed$l_Ceil)&
  !is.na(fed$cln_Days)&
  !is.na(fed$Veh) &
  !is.na(fed$PricingFee)&
  !is.na(fed$b_Intl)&
  !is.na(fed$NAICS)&
  # !is.na(fed$NAICS3)&
  !is.na(fed$CrisisProductOrServiceArea)&
!is.na(fed$Office)&
  !is.na(fed$Agency)
# !is.na(fed$StartCY)&
# !is.na(fed$cl_def3_ratio_lag1)&
# !is.na(fed$cl_def6_obl_lag1)&
# !is.na(fed$cl_def6_ratio_lag1)&
# !is.na(fed$cl_US6_avg_sal_lag1)

summary(complete)

summary(fed$Action_Obligation_Then_Year)
money<-fed$Action_Obligation_Then_Year
any(fed$Action_Obligation_Then_Year<0)
money[fed$Action_Obligation_Then_Year<0]<-0
sum(fed$Action_Obligation_Then_Year[fed$Action_Obligation_Then_Year<0])

#8818392  to 8818392
nrow(fed[!complete,])/nrow(fed)
sum(fed$Action.Obligation[!complete,],na.rm=TRUE)/sum(fed$Action.Obligation,na.rm=TRUE)

#Missing data, how many records and how much money
length(money[!complete])/length(money)
sum(money[!complete],na.rm=TRUE)/sum(money,na.rm=TRUE)

## Once the missing entries have been removed, we draw a sample
## The final computation uses a 1 million row  dataset , but as a computation shortcut, only a 250k subset of the data is needed to
## allow for processing of models faster.


fed_smp<-fed[complete,]
fed_smp<-fed_smp[sample(nrow(fed_smp),250000),]





if(file.exists("data/clean/def_sample.Rdata")){ load(file="data/cleaen/defe_smple.Rdata")
} else{
  smp_complete<-fed[complete,]
  # #
  smp1m<-smp_complete[sample(nrow(smp_complete),1000000),]
  smp<-smp_complete[sample(nrow(smp_complete),250000),]
  def_breach<-smp_complete[fed$b_CBre==1,]
  rm(smp_complete)
}

head(fed_smp)




# load(file="Data/Clean//def_sample.Rdata")

# summary(def_breach$n_CBre_Then_Year)
# def_breach$n_CBre_Then_Year<-def_breach$n_CBre_Then_Year-1
# summary(def_breach$n_CBre_Then_Year)
# summary(def_breach$ln_CBre_Then_Year)
# def_breach$ln_CBre_Then_Year<-na_non_positive_log(def_breach$n_CBre_Then_Year)
# summary(def_breach$ln_CBre_Then_Year)
# def_breach<-def_breach %>% dplyr::select(-n_CBre_OMB20_GDP18,-ln_CBre_OMB20_GDP18)






#To instead replace entries in existing sample, use  this code.
#Missing colnames in sample from fed
# colnames(smp)[!colnames(smp) %in% colnames(fed)]
# colnames(smp1m)[!colnames(smp1m) %in% colnames(fed)]
# colnames(fed)[!colnames(fed) %in% colnames(smp)]
# 
# nrow(smp[smp$CSIScontractID %in% fed$CSIScontractID[complete],])
# nrow(smp[!smp$CSIScontractID %in% fed$CSIScontractID[complete],])


#  #         
# # #Sample adjustments
# # colnames(smp)[colnames(smp)=="Action.Obligation"]<-"Action_Obligation_Then_Year"
# # colnames(smp1m)[colnames(smp1m)=="Action.Obligation"]<-"Action_Obligation_Then_Year"
# memory.limit(36000)
# smp<-smp[,colnames(smp)=="CSIScontractID"]
# # smp<-update_sample_col_CSIScontractID(smp,fed[complete,],drop_and_replace=TRUE)
# smp1m<-smp1m[,colnames(smp1m)=="CSIScontractID"]
# # smp1m<-update_sample_col_CSIScontractID(smp1m,fed[complete,],drop_and_replace=TRUE)

# smp<-update_sample_col_CSIScontractID(smp,fed[complete,],drop_and_replace=FALSE,col="cln_Base_Then_Year")
# 
# smp<-update_sample_col_CSIScontractID(smp,fed,drop_and_replace=FALSE,col="cln_Base_Then_Year")
# smp1m<-update_sample_col_CSIScontractID(smp1m,fed[complete,],drop_and_replace=FALSE,col="cln_Base_Then_Year")
# def_breach<-update_sample_col_CSIScontractID(def_breach,fed[complete,],drop_and_replace=FALSE,col="cln_Base_Then_Year")


# debug(contract_transform_verify)
# smp<-smp%>%select(-cln_Base_Then_Year)

# verify_transform(smp,"UnmodifiedBase_Then_Year","cln_Base_Then_Year",just_check_na=TRUE)
# summary(smp$UnmodifiedBase_Then_Year)
# 
# summary(smp$UnmodifiedBase_Then_Year)
# summary(smp$cln_Base_Then_Year)
# 
# 
# 
# smp$CSIScontractID[is.na(smp$cln_Base_Then_Year)&!is.na(smp$UnmodifiedBase_Then_Year)]





#
# large_crisis_smp$OffPl99<-Hmisc::cut2(large_crisis_smp$OffIntl,c(0.01,0.50))
# summary(large_crisis_smp$OffPl99)
#   levels(large_crisis_smp$OffPl99) <-
#     list("US99"=c("[0.00,0.01)"),
#          "Mixed"=c("[0.01,0.50)"),
#          "Intl"=c("[0.50,1.00]"))
#   large_crisis_smp$Reach<-factor(paste(large_crisis_smp$OffPl99,large_crisis_smp$Intl,sep="-"))
#
#
#      levels(crisis_smp$Reach) <-
#     list( "US50-Dom"=c("US99-Just U.S.","Mixed-Just U.S."),
#          "Mixed-Dom"=c(),
#          "Intl-Dom"=c("Intl-Just U.S."),
#          "US50-Intl"=c("Mixed-Any International","US99-Any International"),
#          "Intl-Intl"=c("Intl-Any International"))
#
# large_crisis_smp$PSA<-as.character(large_crisis_smp$ProductOrServiceArea)
# large_crisis_smp$PSA<-gsub(" & ","+",large_crisis_smp$PSA)
# load("Data\\large_crisis_smp.Rdata")
# save(large_crisis_smp,large_crisis_with_na,file="Data\\large_crisis_smp.Rdata")
# save(fed,file="Data\\transformed_fed.Rdata")
# load(file="Data\\transformed_fed.Rdata")

# extra_large_crisis_with_na<-fed[fed$Crisis %in% c("ARRA","Dis","OCO"),]
# other_intl<-fed[fed$Crisis %in% c("Other")&fed$OffIntl>=0.5,]
# other_dom<-fed[fed$Crisis %in% c("Other")&(fed$OffIntl<0.5
#                                            |is.na(fed$OffIntl)),]
# other_dom<-other_dom[sample(nrow(other_dom),1000000),]
# extra_large_crisis_with_na<-rbind(extra_large_crisis_with_na,other_dom,other_intl)
# rm(other_dom,other_intl)
# 
# extra_large_crisis_with_na<-(extra_large_crisis_with_na)
# extra_large_complete<-get_complete_list(extra_large_crisis_with_na)
# extra_large_crisis_smp<-extra_large_crisis_with_na[extra_large_complete,]
# # # summary(large_crisis_with_na$Crisis)
# # #
# #
# extra_large_crisis_smp$OffPl99<-Hmisc::cut2(extra_large_crisis_smp$OffIntl,c(0.01,0.50))
# summary(extra_large_crisis_smp$OffPl99)
#   levels(extra_large_crisis_smp$OffPl99) <-
#     list("US99"=c("[0.00,0.01)"),
#          "Mixed"=c("[0.01,0.50)"),
#          "Intl"=c("[0.50,1.00]"))
#   extra_large_crisis_smp$Reach<-factor(paste(extra_large_crisis_smp$OffPl99,extra_large_crisis_smp$Intl,sep="-"))
# 
# 
#      levels(extra_large_crisis_smp$Reach) <-
#     list( "US50-Dom"=c("US99-Just U.S.","Mixed-Just U.S."),
#          "Mixed-Dom"=c(),
#          "Intl-Dom"=c("Intl-Just U.S."),
#          "US50-Intl"=c("Mixed-Any International","US99-Any International"),
#          "Intl-Intl"=c("Intl-Any International"))
# 
# save(extra_large_crisis_smp,extra_large_crisis_with_na,file="Data\\extra_large_crisis_smp.Rdata")
# load("Data\\extra_large_crisis_smp.Rdata")

# verify_transform(smp,"def3_ratio_lag1","cl_def3_ratio_lag1",just_check_na=TRUE,log=FALSE)
# verify_transform(smp,"def6_ratio_lag1","cl_def6_ratio_lag1",just_check_na=TRUE,log=FALSE)


# crisis_smp<-add_col_from_transformed(crisis_smp,fed)
# crisis_with_na<-add_col_from_transformed(crisis_with_na,fed)
# large_crisis_smp<-add_col_from_transformed(large_crisis_smp,fed)  
# large_crisis_with_na<-add_col_from_transformed(large_crisis_with_na,fed)  

# large_crisis_with_na<-update_sample_col_CSIScontractID(sample=large_crisis_with_na,full=fed_full,
#                                  col=c("PlaceCountryISO3","VendorCountryISO3","OriginCountryISO3"))
# crisis_with_na<-update_sample_col_CSIScontractID(sample=crisis_with_na,full=fed_full,
#                                  col=c("PlaceCountryISO3","VendorCountryISO3","OriginCountryISO3"))

#save(fed,file="Data/fed_transformed.Rdata")
# head(fed)


# crisis_all<-rbind(oco,recovery,disaster)
# crisis_all_with_na<-rbind(oco_with_na,recovery,disaster)
# summary(crisis_all$Crisis)
# crisis_all$Crisis<-factor(crisis_all$Crisis,c("Other","OCO" ,"ARRA",  "Dis"     ))

# colnames(fed)[colnames(fed)=="PlaceCountryISO3"]<-"alpha.3"
# fed<-csis360::read_and_join( fed, #contract,
#                                       "Location_CountryCodes.csv",
#                                       path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
#                                       directory="location\\",
#                                       by="alpha.3",
#                                       add_var=c("PlaceIntlPercent","CrisisPercent"),
#                                       new_var_checked=FALSE)
# colnames(fed)[colnames(fed)=="alpha.3"]<-"PlaceCountryISO3"

# fed$ProdServ[fed$ProdServ==""]<-NA


# fed<-fed[get_complete_list(fed),]
# fed<-fed[!fed$CSIScontractID %in% fed_1m$CSIScontractID,]
# count<-1000000-997374

# summary(factor(fed_1m$AgencyID[is.na(fed_1m$Customer)]))
# summary(factor(fed_1m$ProdServ[is.na(fed_1m$CrisisProductOrServiceArea)]))
# summary(factor(fed_1m$ProdServ[is.na(fed_1m$CrisisProductOrServiceArea)]))
# fed_1m$ProdServ[fed_1m$ProdServ==""]<-NA
fed_1m<-fed_1m[get_complete_list(fed_1m),]
fed_250k<-fed_250k[get_complete_list(fed_250k),]


# fed_1m$Customer<-factor(fed_1m$Customer)
# fed_1m$CrisisProductOrServiceArea<-factor(fed_1m$CrisisProductOrServiceArea)
# fed_complete<-fed[get_complete_list(fed),]
# fed_1m<-fed_complete[sample(nrow(fed_complete),1000000),]
# fed_250k<-fed_complete[sample(nrow(fed_complete),250000),]
# save(fed_1m,fed_250k,file="output//fed_sample.rdata")
load(file="output//fed_sample.rdata")
#Percent of records incomplete
nrow(fed[!fed_complete,])/nrow(fed) #0.2760521
nrow(fed[is.na(fed$UCA),])/nrow(fed) #0.2760521
#Percent of dollars incomplete
sum(fed[!fed_complete,]$Action.Obligation,na.rm=TRUE)/
  sum(fed$Action.Obligation,na.rm=TRUE) #0.1217748




# undebug(get_crisis_sample_with_na)
crisis_with_na<-get_crisis_sample_with_na(fed)
crisis_smp<-crisis_with_na[get_complete_list(crisis_with_na),]



summary(crisis_all$Crisis)

#Percent of records incomplete
nrow(crisis_with_na[!get_complete_list(crisis_with_na),])/
  nrow(crisis_with_na)
#Percent of dollars incomplete
sum(crisis_with_na[!get_complete_list(crisis_with_na),]$Action.Obligation,na.rm=TRUE)/
  sum(crisis_with_na$Action.Obligation,na.rm=TRUE)



# large_crisis_with_na<-get_crisis_sample_with_na(fed,large=TRUE)
nrow(large_crisis_with_na[!get_complete_list(large_crisis_with_na),])/
  nrow(large_crisis_with_na)
# #Percent of dollars incomplete
sum(large_crisis_with_na[!get_complete_list(large_crisis_with_na),]$Action.Obligation,na.rm=TRUE)/
  sum(large_crisis_with_na$Action.Obligation,na.rm=TRUE)
# large_crisis_smp<-large_crisis_with_na[get_complete_list(large_crisis_with_na),]
# 
# 
# # 
#   
# 
save(crisis_smp,crisis_with_na,
     large_crisis_with_na,large_crisis_smp,
     crisis_all,crisis_all_with_na,file="Data\\crisis_smp.Rdata")
# 



contract_transform_verify(smp,dollars_suffix="Then_Year",just_check_na=TRUE)
contract_transform_verify(smp1m,dollars_suffix="Then_Year",just_check_na=TRUE)
contract_transform_verify(def_breach,dollars_suffix="Then_Year",just_check_na=TRUE)

save(file="data//clean//def_sample.Rdata",smp,smp1m,def_breach)
write.foreign(df=smp,
              datafile="Data//clean//def_sample250k.dat",
              codefile="Data//clean//def_sample250k_code.do",
              package = "Stata")
write.foreign(df=smp1m,
              datafile="Data//clean//def_sample1m.dat",
              codefile="Data//clean//def_sample1m_code.do",
              package = "Stata")
write.foreign(df=def_breach,
              datafile="Data//clean//def_breach.dat",
              codefile="Data//clean//def_breach_code.do",
              package = "Stata")

