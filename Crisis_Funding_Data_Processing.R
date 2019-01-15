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
full_data <- readr::read_delim(file.path("Data",
                                         "Budget.SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.txt"),
                               delim="\t",
                               na=c("NULL","NA"))

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

full_data$ContractingCustomer<-factor(full_data$ContractingCustomer)


full_data<-apply_lookups(Path,full_data)
full_data<-subset(full_data, year(Fiscal.Year)>=2000)

#Create new  variables
full_data$CrisisFundingLegacy<-full_data$CrisisFunding

full_data$Theater<-as.character(full_data$CrisisFundingTheater)
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




# rm(ZipFile)



full_data<-read_and_join(
  full_data,
  "Lookup_ContingencyHumanitarianPeacekeepingOperation.csv",
  by="ContingencyHumanitarianPeacekeepingOperation",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  # add_var="Is.Defense"
  # new_var_checked=TRUE,
  skip_check_var="CHPKisCrisisFunding"
  )

colnames(full_data)[colnames(full_data)=="ContractingCustomer"]<-"Customer"
full_data<-read_and_join(
  full_data,
  "LOOKUP_Customer.csv",
  by="Customer",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  add_var="Is.Defense",
  new_var_checked="Is.Defense"
  # skip_check_var=NULL
)

full_data<-read_and_join(
  full_data,
  "Lookup_nationalinterestactioncode.csv",
  by="nationalinterestactioncode",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  # add_var="Is.Defense"
  # new_var_checked=TRUE,
  skip_check_var=c("NIAcrisisFunding","IsHurricane")
)

full_data$SubCustomer<-full_data$ContractingSubCustomer
full_data<-read_and_join(
  full_data,
  "Lookup_SubCustomer.csv",
  by=c("Customer","SubCustomer"),
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  add_var="SubCustomer.detail"
  # new_var_checked=TRUE,
  # skip_check_var=c("NIAcrisisFunding","IsHurricane")
)

full_data$CCRexception[full_data$CCRexception==""]<-NA
full_data<-read_and_join(
  full_data,
  "Lookup_CCRexception.csv",
  by="CCRexception",
  replace_na_var="CCRexception",
  # overlap_var_replaced=TRUE,
  # add_var="Is.Defense"
  # new_var_checked=TRUE,
  skip_check_var=c("SAMcrisisFunding")
)




full_data$DecisionTree<-factor(full_data$DecisionTree)
full_data$DecisionTreeStep4<-factor(full_data$DecisionTreeStep4)



save(full_data,
  file="Data//budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")

# load(file="budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")


