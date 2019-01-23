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



full_data<-subset(full_data, Fiscal.Year>=2000 & Fiscal.Year<=2017)
 
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


colnames(full_data)[colnames(full_data)=="ProductOrServiceArea"]<-"ProductServiceOrRnDarea"
full_data<-read_and_join(full_data,
                      "LOOKUP_Buckets.csv",
                      by="ProductServiceOrRnDarea",
                      add_var="ProductServiceOrRnDarea.sum")
colnames(full_data)[colnames(full_data)=="ProductServiceOrRnDarea"]<-"ProductOrServiceArea"


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
full_data<-read_and_join(full_data,
                      "Lookup_SubCustomer.csv",
                      by=c("Customer","SubCustomer"),
                      add_var="SubCustomer.detail"
)


full_data<-replace_nas_with_unlabeled(full_data,"ClassifyNumberOfOffers")
full_data<-read_and_join(full_data,
                      "Lookup_SQL_CompetitionClassification.csv",
                      by=c("CompetitionClassification",
                           "ClassifyNumberOfOffers"),
                      add_var="No.Competition.Offer")


full_data$Dur.Simple<-factor(full_data$UnmodifiedUltimateDurationCategory)
levels(full_data$Dur.Simple)<- list(
  "<~1 year"=c("<=2 Months",">2-7 Months",">7-12 Months"),
  "(~1 year,~2 years]"=">1-2 Years",
  "(~2 years+]"=c(">2-4 Years",">4 years"),
  "Unlabeled"="Unlabeled"
  )

full_data<-replace_nas_with_unlabeled(full_data,"ContractCrisisFunding")
full_data<-replace_nas_with_unlabeled(full_data,"Is.Defense")
full_data<-replace_nas_with_unlabeled(full_data,"Theater")
full_data<-replace_nas_with_unlabeled(full_data,"contingencyhumanitarianpeacekeepingoperationText")
full_data<-replace_nas_with_unlabeled(full_data,"Dur.Simple")
full_data$SAMcrisisFunding[full_data$SAMcrisisFunding==""]<-NA


full_data<-deflate(full_data,
                   money_var = "Action.Obligation",
                   deflator_var="Deflator.2017"
)



full_data$NoCompOffr<-as.character(full_data$No.Competition.Offer)
summary(factor(full_data$NoCompOffr))

full_data$NoCompOffr[full_data$IsUrgency==1]<-"Urgency"
full_data$NoCompOffr<-factor(full_data$NoCompOffr)

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

colnames(full_data)[colnames(full_data)=="Action.Obligation.2017"]<-"Obligation.2017"
full_data %>% group_by(NoCompOffr) %>% dplyr::summarise(Obligation.2017=sum(Obligation.2017,na.rm=TRUE))


for(i in 1:ncol(full_data))
  if (typeof(full_data[,i])=="character")
    full_data[,i]<-factor(full_data[,i])

full_data$dFYear <-as.Date(paste("1/1/",as.character(full_data$Fiscal.Year),sep=""),"%m/%d/%Y")

full_data$NIAlist<-full_data$nationalinterestactioncodeText
# labels.x.DF<-prepare_labels_and_colors(full_data,"nationalinterestactioncodeText")
# full_data$NIAlist<-factor(full_data$nationalinterestactioncodeText,
#                           levels=c(rev(labels.x.DF$variable)),
#                           labels=c(rev(labels.x.DF$Label)),
#                           ordered=TRUE)
full_data<-replace_nas_with_unlabeled(full_data,"NIAcrisisFunding")

#Priming all the labels_and_colors with the legend values we need.
full_data$CrisisFunding1A<-full_data$CrisisFunding
full_data$CrisisFunding1B<-full_data$CrisisFunding
full_data$CrisisFunding1C<-full_data$CrisisFunding
full_data$CrisisFunding2<-full_data$CrisisFunding

full_data$CrisisFunding3<-full_data$CrisisFunding
full_data$CrisisFunding3<-factor(full_data$CrisisFunding3,
                                 levels=c("OCO","Disaster","ARRA","Excluded","Unlabeled"))
full_data$CrisisFunding3[1]<-"Excluded"
full_data$CrisisFunding4A<-full_data$CrisisFunding3
full_data$CrisisFunding4B<-full_data$CrisisFunding3

full_data$MultipleYearProcRnD<-factor(full_data$IsMultipleYearProcRnD)
levels(full_data$MultipleYearProcRnD)<-list(
  "Excluded"="1",
  "Remainder"="0"
)


full_labels_and_colors<-prepare_labels_and_colors(full_data,na_replaced=TRUE)
full_column_key<-get_column_key(full_data)

full_data$CrisisFunding1A<-NA
full_data$CrisisFunding1B<-NA
full_data$CrisisFunding1C<-NA
full_data$CrisisFunding2<-NA

full_data$CrisisFunding3<-NA
full_data$CrisisFunding4A<-NA
full_data$CrisisFunding4B<-NA


save(full_data,full_labels_and_colors,full_column_key,
  file="Data//budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")



