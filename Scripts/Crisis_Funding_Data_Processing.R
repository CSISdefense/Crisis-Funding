# ---
#   title: "Crisis Funding Classification"
# author: "Greg Sanders"
# date: "March 28, 2017"
# output:
#   html_document: 
#   keep_md: yes
# pdf_document: default
# ---
  
  #Setup

library(plyr)
library(dplyr)
library(reshape2)
library(Hmisc)
library(csis360)
library(readr)

source("https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/lookups.r")
source("https://raw.githubusercontent.com/CSISdefense/R-scripts-and-data/master/helper.r")


##Import Data
# read in detailed defense dataset    
# ZipFile<-unz(file.path("Data","Defense_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.zip"),
#              "Defense_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.txt")
# defense_data <- readr::read_delim(ZipFile,
#   delim="\t",na=c("NULL","NA"))
# readr::problems(defense_data)
# defense_data<-standardize_variable_names(defense_data)

# read in full data set    
# ZipFile<-unz(file.path("Data","budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.zip"),
#              "budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.txt")
#Need to manually unzip ecause unz doesn't work above 2 gigs
full_data<-read_tsv(file.path("data","semi_clean",
                              "budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.txt"),
                    na = c("NA","NULL"),
                    guess_max = 10000000)

#Dropping time to complete
if(all(is.na((full_data[nrow(full_data),]))))
  full_data<-full_data[1:(nrow(full_data)-1),]


full_data<-standardize_variable_names(full_data)

full_data<-full_data[,!colnames(full_data) %in%
                             c(
                               "ContractCrisisFunding.1"             ,
                               "localareasetaside.1",
                               "IsOMBocoList.1",
                               "ContractCrisisFunding_1"             ,
                               "localareasetaside_1",
                               "IsOMBocoList_1"
                             )]



full_data<-subset(full_data, Fiscal.Year>=2000 & Fiscal.Year<=2017)
 
#Create new  variables
full_data$CrisisFundingLegacy<-full_data$CrisisFunding

full_data$Theater[full_data$Theater %in% c("Afghanistan","Iraq")]<-"Afghanistan and Iraq"


full_data$International<-full_data$Theater
full_data$International[full_data$Theater %in% c("Afghanistan and Iraq",
                                                 "Regional Support",
                                                 "Rest of World")]<-"International"
full_data$International<-ordered(full_data$International,
                                 levels=c("International",
                                          "Domestic"))

full_data$Theater<-factor(full_data$Theater)
summary(full_data$Theater)
summary(full_data$International)



full_data$ContingencyHumanitarianPeacekeepingOperation[full_data$ContingencyHumanitarianPeacekeepingOperation==""]<-NA
full_data<-read_and_join_experiment(full_data,
  lookup_file="ContingencyHumanitarianPeacekeepingOperation.csv",
  by=c("ContingencyHumanitarianPeacekeepingOperation"),
  path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
  dir="assistance//",
  add_var = "ContingencyHumanitarianPeacekeepingOperationText")

# colnames(full_data)[colnames(full_data)=="ContractingCustomer"]<-"Customer"
full_data<-read_and_join_experiment(
  full_data,
  "Customer.csv",
  by=c("ContractingCustomer"="Customer"),
  path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
  dir="office//",
  add_var="Is.Defense",
  new_var_checked="Is.Defense"
  # skip_check_var=NULL
)

full_data$nationalinterestactioncode[full_data$nationalinterestactioncode==""]<-NA
full_data<-read_and_join_experiment(
  full_data,
  "NationalInterestActionCode.csv",
  by=c("nationalinterestactioncode"="NationalInterestActionCode"),
  path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
  dir="assistance//",skip_check_var = c('IsHurricane',	'CrisisFunding'
  ))

full_data<-read_and_join_experiment(
  full_data,
  "SubCustomer.csv",
  by=c("ContractingCustomer"="Customer","ContractingSubCustomer"="SubCustomer"),
  path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
  dir="office//",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  add_var="SubCustomer.detail"
  # new_var_checked=TRUE,
  # skip_check_var=c("NIAcrisisFunding","IsHurricane")
)
full_data$SAMcrisisFunding[full_data$SAMcrisisFunding==""]<-NA

full_data$CCRexception[full_data$CCRexception==""]<-NA
full_data<-read_and_join_experiment(
  full_data,
  "CCRexception.csv",
  by="CCRexception",
  replace_na_var="CCRexception",
  path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
  dir="assistance//",skip_check_var = c('SAMcrisisFunding'))
  
  
#   full_data,
#   "CCRexception.csv",
#   by="CCRexception",
#   replace_na_var="CCRexception",
#   # overlap_var_replaced=TRUE,
#   # add_var="Is.Defense"
#   # new_var_checked=TRUE,
#   skip_check_var=c("SAMcrisisFunding")
# )

full_data<-read_and_join_experiment(full_data,
                      "CompetitionClassification.csv",
                      by=c("CompetitionClassification",
                           "ClassifyNumberOfOffers"),
                      path="https://raw.githubusercontent.com/CSISdefense/Lookup-Tables/master/",
                      dir="contract//",
                      add_var="No.Competition.Offer")




full_data<-replace_nas_with_unlabeled(full_data,"ContractCrisisFunding")
full_data<-replace_nas_with_unlabeled(full_data,"Is.Defense")
full_data<-replace_nas_with_unlabeled(full_data,"Theater")
full_data<-replace_nas_with_unlabeled(full_data,"ContingencyHumanitarianPeacekeepingOperationText")


colnames(full_data)[colnames(full_data)=="Fiscal.Year"]<-"fiscal_year"
full_data<-deflate(full_data,
                   money_var = "Action_Obligation",
                   deflator_var="GDPdeflator2017"
)

colnames(full_data)[colnames(full_data)=="Action_Obligation_GDPdeflator2017"]<-"Obligation.2017"

summary(factor(full_data$No.Competition.Offer))
full_data$NoCompOffr<-as.character(full_data$No.Competition.Offer)
full_data$NoCompOffr[full_data$IsUrgency==1]<-"Urgency"
full_data$NoCompOffr[full_data$CompetitionClassification=="Unlabeled: Competition; Unlabeled Offers"]<-"Unlabeled"
full_data$NoCompOffr<-factor(full_data$NoCompOffr)

summary(full_data$NoCompOffr)

levels(full_data$NoCompOffr)<-list(
  "1 Offer"="1 Offer",              
  "2-4 Offers"="2-4 Offers",   
  "5+ Offers"="5+ Offers",   
  "Urgency"="Urgency",
  "Other No"=c("No Comp. (Other)","No Comp. (Only 1 Source)","Follow on to Competed Action"),
  "Unlabeled"=c("No Comp. (Unlabeled)","Unlabeled")  )

full_data$NoCompOffr<-factor(full_data$NoCompOffr,c(
  "Other No",
    "Urgency",
    "1 Offer",
    "2-4 Offers",
    "5+ Offers",
  "Unlabeled"
  ))
full_data %>% group_by(NoCompOffr) %>% dplyr::summarise(Obligation.2017=sum(Obligation.2017,na.rm=TRUE))

full_data$dFYear<-as.Date(paste("1/1/",as.character(full_data$fiscal_year),sep=""),"%m/%d/%Y")

for(i in 1:ncol(full_data))
  if (typeof(full_data[,i])=="character")
    full_data[,i]<-factor(full_data[,i])

full_labels_and_colors<-prepare_labels_and_colors(full_data,na_replaced=TRUE)
full_column_key<-get_column_key(full_data)

save(full_data,full_labels_and_colors,full_column_key,
  file="Data//semi_clean//budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")



