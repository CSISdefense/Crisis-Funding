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
defense_data <- read.csv(ZipFile,
                         na.strings="NULL")
rm(ZipFile)

# read in full data set    
ZipFile<-unz(file.path("Data","Overall_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.zip"),
             "Overall_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.csv")
full_data <- read.csv(ZipFile,
                      na.strings="NULL",
                      sep=",")
rm(ZipFile)
full_data$CrisisFundingLegacy<-full_data$CrisisFunding

defense_data<-apply_lookups(Path,defense_data)
defense_data<-subset(defense_data, year(Fiscal.Year)>=2000)

debug(apply_lookups)
full_data<-apply_lookups(Path,full_data)
full_data<-subset(full_data, year(Fiscal.Year)>=2000)

defense_data$Theater<-defense_data$CrisisFundingTheater
levels(defense_data$Theater)<-c("Afghanistan"="Afghanistan and Iraq",
                                "Domestic"="Domestic",
                                "Iraq"="Afghanistan and Iraq",
                                "Regional Support"="Regional Support",
                                "Rest of World"="Rest of World")
defense_data$Theater<-ordered(defense_data$Theater,levels=
                                c("Afghanistan and Iraq",
                                  "Regional Support",
                                  "Rest of World",
                                  "Domestic"))

defense_data$International<-defense_data$Theater
levels(defense_data$International)<-c("Afghanistan and Iraq"="International",
                                      "Regional Support"="International",
                                      "Rest of World"="International",
                                      "Domestic"="Domestic")
defense_data$International<-ordered(defense_data$International,
                                    levels=c("International",
                                             "Domestic"))

full_data$Theater<-full_data$CrisisFundingTheater
levels(full_data$Theater)<-c("Afghanistan"="Afghanistan and Iraq",
                             "Domestic"="Domestic",
                             "Iraq"="Afghanistan and Iraq",
                             "Regional Support"="Regional Support",
                             "Rest of World"="Rest of World")
full_data$Theater<-ordered(full_data$Theater,levels=
                             c("Afghanistan and Iraq",
                               "Regional Support",
                               "Rest of World",
                               "Domestic"))

full_data$International<-full_data$Theater
levels(full_data$International)<-c("Afghanistan and Iraq"="International",
                                   "Regional Support"="International",
                                   "Rest of World"="International",
                                   "Domestic"="Domestic")
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

save(defense_data,
     full_data,
     file="Defense_budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")

