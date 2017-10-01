# ---
#   title: "Crisis Funding Exploration"
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


# Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
# Path<-"C:\\Users\\Greg Sanders\\SkyDrive\\Documents\\R Scripts and Data SkyDrive\\"
Path<-"C:\\Users\\gsand_000.ALPHONSE\\Documents\\Development\\R-scripts-and-data\\"
source(paste(Path,"lookups.r",sep=""))
source(paste(Path,"helper.r",sep="")) 

# diigtheme1:::diiggraph()

Coloration<-read.csv(
  paste(Path,"Lookups\\","lookup_coloration.csv",sep=""),
  header=TRUE, sep=",", na.strings="", dec=".", strip.white=TRUE, 
  stringsAsFactors=FALSE
)

Coloration<-ddply(Coloration
                  , c(.(R), .(G), .(B))
                  , transform
                  , ColorRGB=as.character(
                    if(min(is.na(c(R,G,B)))) {NA} 
                    else {rgb(max(R),max(G),max(B),max=255)}
                  )
)


axis.text.size<-12
strip.text.size<-12
legend.text.size<-8
# table.text.size<-5.75
title.text.size<-12
geom.text.size<-12

main.text.size<-2
note.text.size<-1.40

##Import Data
# read in detailed defense dataset    
ZipFile<-unz(file.path("Data","Defense_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.zip"),
             "Defense_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.csv")
defense_data <- readr::read_delim(ZipFile,
  delim="\t",
  
                         na="NULL")
defense_data<-standardize_variable_names(defense_data)

# read in full data set    
# ZipFile<-unz(file.path("Data","Overall_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.zip"),
             # "Overall_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.txt")
full_data <- readr::read_delim(file.path("LargeDataSets",
  "Overall_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.txt"),
                      na="NULL",
                      delim="\t")

# defense_data<-defense_data[,colnames(defense_data) %in% 
#     c(
#       "ContractCrisisFunding.1"             ,
#       "localareasetaside.1",
#       "IsOMBocoList.1"
#     )]

full_data<-standardize_variable_names(full_data)
missingf<-colnames(full_data)[!colnames(full_data) %in% colnames(defense_data)]
missingd<-colnames(defense_data)[!colnames(defense_data) %in% colnames(full_data)]




rm(ZipFile)
full_data$CrisisFundingLegacy<-full_data$CrisisFunding

defense_data<-apply_lookups(Path,defense_data)
defense_data<-subset(defense_data, year(Fiscal.Year)>=2000)

debug(apply_lookups)
full_data<-apply_lookups(Path,full_data)
full_data<-subset(full_data, year(Fiscal.Year)>=2000)

defense_data$Theater<-as.character(defense_data$CrisisFundingTheater)
defense_data$Theater[defense_data$Theater %in% c("Afghanistan","Iraq")]<-"Afghanistan and Iraq"
defense_data$International<-defense_data$Theater
defense_data$International[defense_data$Theater %in% c("Afghanistan and Iraq",
  "Regional Support",
  "Rest of World")]<-"International"
defense_data$International<-ordered(defense_data$International,
  levels=c("International",
    "Domestic"))

full_data$Theater<-as.character(full_data$CrisisFundingTheater)
full_data$Theater[full_data$Theater %in% c("Afghanistan","Iraq")]<-"Afghanistan and Iraq"
full_data$International<-full_data$Theater
full_data$International[full_data$Theater %in% c("Afghanistan and Iraq",
  "Regional Support",
  "Rest of World")]<-"International"
full_data$International<-ordered(full_data$International,
  levels=c("International",
    "Domestic"))





full_data<-csis360::read_and_join(
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
full_data<-csis360::read_and_join(
  full_data,
  "LOOKUP_Customer.csv",
  by="Customer",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  add_var="Is.Defense",
  new_var_checked="Is.Defense"
  # skip_check_var=NULL
)

full_data<-csis360::read_and_join(
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
full_data<-csis360::read_and_join(
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
full_data<-csis360::read_and_join(
  full_data,
  "Lookup_CCRexception.csv",
  by="CCRexception",
  replace_na_var="CCRexception",
  # overlap_var_replaced=TRUE,
  # add_var="Is.Defense"
  # new_var_checked=TRUE,
  skip_check_var=c("SAMcrisisFunding")
)



defense_data<-csis360::read_and_join(
  defense_data,
  "Lookup_ContingencyHumanitarianPeacekeepingOperation.csv",
  by="ContingencyHumanitarianPeacekeepingOperation",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  # add_var="Is.Defense"
  # new_var_checked=TRUE,
  skip_check_var="CHPKisCrisisFunding"
)

colnames(defense_data)[colnames(defense_data)=="ContractingCustomer"]<-"Customer"
defense_data<-csis360::read_and_join(
  defense_data,
  "LOOKUP_Customer.csv",
  by="Customer",
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  add_var="Is.Defense",
  new_var_checked="Is.Defense"
  # skip_check_var=NULL
)

# defense_data<-csis360::read_and_join(
#   defense_data,
#   "Lookup_nationalinterestactioncode.csv",
#   by="nationalinterestactioncode",
#   # replace_na_var=NULL,
#   # overlap_var_replaced=TRUE,
#   # add_var="Is.Defense"
#   # new_var_checked=TRUE,
#   skip_check_var=c("NIAcrisisFunding","IsHurricane")
# )


defense_data$SubCustomer<-defense_data$ContractingSubCustomer
defense_data<-csis360::read_and_join(
  defense_data,
  "Lookup_SubCustomer.csv",
  by=c("Customer","SubCustomer"),
  # replace_na_var=NULL,
  # overlap_var_replaced=TRUE,
  add_var="SubCustomer.detail"
  # new_var_checked=TRUE,
  # skip_check_var=c("NIAcrisisFunding","IsHurricane")
)


save(full_data,
  file="overall_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")


save(full_data,defense_data,
  file="budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")

load(file="budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")