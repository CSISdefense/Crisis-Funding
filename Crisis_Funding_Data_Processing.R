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



full_data<-apply_lookups(Path,full_data)
full_data<-subset(full_data, year(Fiscal.Year)>=2000 & year(Fiscal.Year)<=2017)
 
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





full_data<-replace_nas_with_unlabeled(full_data,"ContractCrisisFunding")
full_data<-replace_nas_with_unlabeled(full_data,"Is.Defense")
full_data<-replace_nas_with_unlabeled(full_data,"Theater")
full_data<-replace_nas_with_unlabeled(full_data,"contingencyhumanitarianpeacekeepingoperationText")


full_data$SAMcrisisFunding[full_data$SAMcrisisFunding==""]<-NA

full_data<-full_data[,!colnames(full_data) %in% c(
  # "Fiscal.Year"                                     
  "SimpleArea",
  # "ProductOrServiceArea"                            
  # "Customer"                                        
  # "ContractingSubCustomer"                          
  # "PlaceCountryText"                                
  # "CrisisFundingTheater"                            
  # "VendorPlaceType"                                 
  # "Vendor.Size"                                     
  # "UnmodifiedUltimateDurationCategory"              
  # "OMBagencyName"                                   
  # "OMBbureauName"                                   
  # "treasuryagencycode"                              
  # "mainaccountcode"                                 
  # "isUndefinitizedAction"                           
  # "OCOcrisisScore"                                  
  # "CompetitionClassification"                       
  # "ClassifyNumberOfOffers"                          
  # "IsOMBocoList"                                    
  # "PSCOCOcrisisScore"                               
  # "OfficeOCOcrisisScore"                            
  # "MajorCommandID"                                  
  # "IsMultipleYearProcRnD"                           
  # "isforeign"                                       
  # "ContractCrisisFunding"                           
  # "nationalinterestactioncode"                      
  # "CrisisFunding"                                   
  # "localareasetaside"                               
  # "ContingencyHumanitarianPeacekeepingOperation"    
  # "ConHumIsOCOcrisisFunding"                        
  # "CCRexception"                                    
  # "IsOCOcrisisFunding"                              
  # "DecisionTree"                                    
  # "DecisionTreeStep4"                               
  # "pscOCOcrisisPoint"                               
  # "FundingAccountOCOpoint"                          
  # "OfficeOCOcrisisPoint"                            
  # "PercentFundingAccountOCO"                        
  # "OfficeOCOcrisisPercentSqrt"                      
  # "pscOCOcrisisPercentSqrt"                         
  # "Action.Obligation"                               
  # "numberOfActions"                                 
  # "MajorCommandCode"                                
  # "ContractingOfficeCode"                           
  # "Contracting.Agency.ID"                           
  # "MajorCommandName"                                
  # "MCC_StartFiscal_Year"                            
  # "MCC_EndFiscal_Year"                              
  # "ContractingOfficeName"                           
  # "Competition.detail"                              
  # "Competition.sum"                                 
  # "Competition.effective.only"                      
  # "Competition.multisum"                            
  # "No.Competition.sum"                              
  # "ProductServiceOrRnDarea"                         
  "ServicesCategory.detail",
  "ServicesCategory.sum",
  "ProductsCategory.detail",
  "ProductOrServiceArea.DLA",
  "ProductOrServicesCategory.Graph",
  "ProductServiceOrRnDarea.sum",
  # "SupplyServiceFRC"                                
  # "SupplyServiceERS"                                
  "RnDCategory.detail",
  # "Vendor.Size.detail"                              
  # "Vendor.Size.sum"                                 
  # "Shiny.VendorSize"                                
  "Deflator.2005",
  "Deflator.2011",
  "Deflator.2012",
  "Deflator.2013",
  "Deflator.2014",
  "Deflator.2015",
  "Deflator.2016",
  # "Deflator.2017"                                   
  # "Unknown.2017"                                    
  # "OMB.2019"                                        
  "Obligation.2013",
  "Obligation.2014",
  "Obligation.2015",
  # "Obligation.2016"                                 
  # "LogOfAction.Obligation"                          
  # "Fiscal.Year.End"                                 
  # "Fiscal.Year.Start"                               
  # "Graph"                                           
  # "CrisisFundingLegacy"                             
  # "Theater"                                         
  # "International"                                   
  # "contingencyhumanitarianpeacekeepingoperationText"
  # "CHPKisCrisisFunding"                             
  # "Is.Defense"                                      
  # "nationalinterestactioncodeText"                  
  # "IsHurricane"                                     
  # "NIAcrisisFunding"                                
  # "SubCustomer"                                     
  "SubCustomer.detail"
  # "SAMexceptionText"                                
  # "SAMexception.sum"                                
  # "SAMcrisisFunding"  
)]


full_data<-deflate(full_data,
                   money_var = "Action.Obligation",
                   deflator_var="Deflator.2017"
)




full_data$NoCompOffr<-as.character(full_data$No.Competition.sum)
full_data$NoCompOffr<-as.character(full_data$NoCompOffr)
full_data$NoCompOffr[full_data$ClassifyNumberOfOffers %in% c("5-9 Offers","10-24 Offers","25-99 Offers","100+ Offers")
                     &  full_data$NoCompOffr == "2+ Offers"] <-"5+ Offers"
full_data$NoCompOffr[full_data$ClassifyNumberOfOffers %in% c("Two Offers","3-4 Offers")
                     &  full_data$NoCompOffr == "2+ Offers"] <-"2-4 Offers"

full_data$NoCompOffr[full_data$IsUrgency==1]<-"Urgency"
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
full_data %>% group_by(NoCompOffr) %>% dplyr::summarise(obligation.2016=sum(Obligation.2016,na.rm=TRUE))


for(i in 1:ncol(full_data))
  if (typeof(full_data[,i])=="character")
    full_data[,i]<-factor(full_data[,i])

full_labels_and_colors<-prepare_labels_and_colors(full_data,na_replaced=TRUE)
full_column_key<-get_column_key(full_data)

save(full_data,full_labels_and_colors,full_column_key,
  file="Data//budget_SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail.Rdata")



