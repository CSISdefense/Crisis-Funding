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

if(!exists("fed"))  load(file="data\\clean\\fed_transformed.rdata")

head(fed)
## Verify data transformations

contract_transform_verify(fed,dollars_suffix="OMB20_GDP18")


fed$NoCompOffr2<-factor(fed$NoCompOffr,
                               levels=c(  "2-4 offers" ,"Other No",   "Urgency" ,   "1 offer"  ,"5+ offers" ))
fed$NoCompOffr2<-factor(fed$NoCompOffr,
                           levels=c(  "2-4 offers" ,
                                      "Other No",  
                                      "Urgency" ,  
                                      "1 offer"  ,
                                      "5+ offers" ))

#Reordering NoCompOffr to make the most common level the default
fed$NoCompOffr2<-factor(fed$NoCompOffr,
                        levels=c(  "2-4 offers" ,"Other No",   "Urgency" ,   "1 offer"  ,"5+ offers" ))
fed$NoCompOffr2<-factor(fed$NoCompOffr,
                        levels=c(  "2-4 offers" ,
                                   "Other No",  
                                   "Urgency" ,  
                                   "1 offer"  ,
                                   "5+ offers" ))




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
summary(fed$b_UCA)
summary(fed$PlaceCountryISO3)
summary(fed$VendorCountryISO3)
summary(fed$OriginCountryISO3)
summary(fed$c_OffCri)
summary(fed$OffPlace)
summary(fed$Crisis)

# summary(fed$cl_def3_HHI_lag1) 
# summary(fed$cl_def6_HHI_lag1) 
#Controls
# summary(fed$cln_Ceil)
summary(fed$cln_Days)
summary(fed$Veh) 
summary(fed$PricingFee)
summary(fed$b_Intl)

summary(fed$NAICS)
# summary(fed$NAICS3)
summary(fed$Office)
summary(fed$Agency)
# summary(fed$Customer)
summary(fed$CrisisProductOrServiceArea)
summary(fed$ProdServ)
# summary(fed$StartCY)
# summary(fed$cl_def3_ratio_lag1) 
# summary(fed$cl_def6_obl_lag1)
# summary(fed$cl_def6_ratio_lag1)
# summary(fed$cl_US6_avg_sal_lag1)

#Competition 
summary(fed$Agency[is.na(fed$NoCompOffr)])
summary(fed$Urg[is.na(fed$NoCompOffr)])
summary(fed$CompOffr[is.na(fed$NoCompOffr)]) #Including urgency exception adds NAs for no competition, it doesn't matter for competed contracts.


# Next, we eliminate missing data entries. 



complete<-get_complete_list(fed)
 

summary(complete)

summary(fed$Action_Obligation_Then_Year)
money<-fed$Action_Obligation_Then_Year
any(fed$Action_Obligation_Then_Year<0)
money[fed$Action_Obligation_Then_Year<0]<-0
sum(fed$Action_Obligation_Then_Year[fed$Action_Obligation_Then_Year<0])

#Missing data, how many records and how much money
#4003325 NA 16881342 Complete
length(money[!complete])/length(money) #0.1916873
sum(money[!complete],na.rm=TRUE)/sum(money,na.rm=TRUE) #0.04529853

## Once the missing entries have been removed, we draw a sample
## The final computation uses a 1 million row  dataset , but as a computation shortcut, only a 250k subset of the data is needed to
## allow for processing of models faster.

crisis_all<-fed[complete&fed$Crisis %in% c("ARRA","Dis","OCO"),]
crisis_all_with_na<-fed[fed$Crisis %in% c("ARRA","Dis","OCO"),]


#Percent of crisis records incomplete
1-nrow(crisis_all)/nrow(crisis_all_with_na) #0.0303168
  
#Percent of dollars incomplete
1-sum(crisis_all$Action_Obligation_Then_Year,na.rm=TRUE)/ #0.01373789
  sum(crisis_all_with_na$Action_Obligation_Then_Year,na.rm=TRUE) 



if(file.exists("data/clean/fed_sample.Rdata")){ load(file="data/clean/fed_sample.Rdata")
} else{
  smp_complete<-fed[complete,]
  # #
  fed_1m<-smp_complete[sample(nrow(smp_complete),1000000),]
  fed_smp<-smp_complete[sample(nrow(smp_complete),250000),]
  
  rm(smp_complete)
}

length(crisis_all)/length(crisis_all_with_na)


head(fed_smp)



# crisis_all_with_na<-get_crisis_sample_with_na(fed)
# crisis_smp<-crisis_all_with_na[get_complete_list(crisis_all_with_na),]


summary(crisis_all$Crisis)

contract_transform_verify(fed_1m,dollars_suffix="OMB20_GDP18",just_check_na=TRUE)
contract_transform_verify(fed_smp,dollars_suffix="OMB20_GDP18",just_check_na=TRUE)
contract_transform_verify(crisis_all,dollars_suffix="OMB20_GDP18",just_check_na=TRUE)
contract_transform_verify(crisis_all_with_na,dollars_suffix="OMB20_GDP18",just_check_na=TRUE)



save(file="data//clean//fed_sample.Rdata",fed_smp,fed_1m)
save(file="data//clean//crisis_population.Rdata",crisis_all,crisis_all_with_na)


write.foreign(df=fed_smp,
              datafile="Data//clean//fed_sample250k.dat",
              codefile="Data//clean//fed_sample250k_code.do",
              package = "Stata")
write.foreign(df=fed_1m,
              datafile="Data//clean//fed_sample1m.dat",
              codefile="Data//clean//fed_sample1m_code.do",
              package = "Stata")
write.foreign(df=crisis_all,
              datafile="Data//clean//crisis_all250k.dat",
              codefile="Data//clean//crisis_all250k_code.do",
              package = "Stata")
write.foreign(df=crisis_all_with_na,
              datafile="Data//clean//crisis_all_with_na1m.dat",
              codefile="Data//clean//crisis_all_with_na1m_code.do",
              package = "Stata")

summary(fed$OffPlace)

##### Example update codes
# crisis_smp<-add_col_from_transformed(crisis_smp,fed)
# crisis_all_with_na<-add_col_from_transformed(crisis_all_with_na,fed)
# large_crisis_smp<-add_col_from_transformed(large_crisis_smp,fed)  
# large_crisis_all_with_na<-add_col_from_transformed(large_crisis_all_with_na,fed)  





##### Original weighted sample creation, since abandoned
# extra_large_crisis_all_with_na<-fed[fed$Crisis %in% c("ARRA","Dis","OCO"),]
# other_intl<-fed[fed$Crisis %in% c("Other")&fed$OffIntl>=0.5,]
# other_dom<-fed[fed$Crisis %in% c("Other")&(fed$OffIntl<0.5
#                                            |is.na(fed$OffIntl)),]
# other_dom<-other_dom[sample(nrow(other_dom),1000000),]
# extra_large_crisis_all_with_na<-rbind(extra_large_crisis_all_with_na,other_dom,other_intl)
# rm(other_dom,other_intl)
# 
# extra_large_complete<-get_complete_list(extra_large_crisis_all_with_na)
# extra_large_crisis_smp<-extra_large_crisis_all_with_na[extra_large_complete,]
# summary(large_crisis_all_with_na$Crisis)
# # #
# #

# save(extra_large_crisis_smp,extra_large_crisis_all_with_na,file="Data\\extra_large_crisis_smp.Rdata")