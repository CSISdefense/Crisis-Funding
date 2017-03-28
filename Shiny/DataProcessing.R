################################################################################
# Data Pre-Processing for Vendor Size Shiny Graphic
# L. Lipsey for DIIG, May 2016
#
# This script does pre-processing to get VendorSizeShiny.csv into proper form
# for use in the Shiny graphic.  The purpose is to avoid doing this processing
# in the Shiny script itself, thus reducing the graphic's load times for users.
#
# Input: CSV-format results from SQL query:
# sp_VendorSizeHistoryPlatformPortfolioSubCustomer on 5/13/2016
#
# Output: CSV file (CleanedVendorSize.csv)
# with data in the minimal form needed by Shiny script
################################################################################

library(plyr)
library(dplyr)

Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
# Path<-"C:\\Users\\Greg Sanders\\SkyDrive\\Documents\\R Scripts and Data SkyDrive\\"
source(paste(Path,"lookups.r",sep=""))
source(paste(Path,"helper.r",sep=""))


# read in data    
ZipFile<-unz(file.path("..","Data","budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.zip"),
             "budget_SP_LocationVendorCrisisFundingHistoryBucketCustomer.csv")
FullData <- read.csv(ZipFile,
                     na.strings="NULL")
rm(ZipFile)


FullData<-apply_lookups(Path,FullData)
FullData<-subset(FullData, year(Fiscal.Year)>=2000)
# change header names to be shorter / more useful

FullData$CrisisFundingTheater[FullData$PlaceCountryText %in% c("CZECHOSLOVAKIA",
                                                               "NJUNI",
                                                               "SERBIA AND MONTENEGRO",
                                                               "SPRATLY ISLANDS [UNDETERMINED]",
                                                               "USSR RUSSIA",
                                                               "YUGOSLAVIA")]<-"Rest of World"

FullData$CrisisFundingTheater[FullData$PlaceCountryText == "" | is.na(FullData$PlaceCountryText)
                              ]<-"Domestic"
#Note that non distributed remains unlabeled
FullData<-subset(FullData,select=c(Fiscal.Year,
                                   Shiny.VendorSize,
                                   SimpleArea,
                                   CrisisFunding,
                                   CrisisFundingTheater,
                                   Obligation.2015,
                                   numberOfActions
))

names(FullData)[names(FullData)=="Fiscal.Year"] <- "FY"
names(FullData)[names(FullData)=="Shiny.VendorSize"] <- "VendorSize"
names(FullData)[names(FullData)=="SimpleArea"] <- "Area"
names(FullData)[names(FullData)=="Obligation.2015"] <- "Amount"
names(FullData)[names(FullData)=="numberOfActions"] <- "Actions"
names(FullData)[names(FullData)=="CrisisFundingTheater"] <- "Place"
FullData$FY<-year(FullData$FY)



# remove lines with NA obligation amounts and unlabeled vendor sizes
FullData <- FullData[!is.na(FullData$Amount) &
                         FullData$VendorSize != "Unlabeled" &
                         FullData$Area != "Mixed or Unlabeled" &
                         !is.na(FullData$Place),
                     ]

# subset to years of focus (2000-2014)
FullData <- suppressWarnings(subset(FullData, 
                                    FY >= 2000 ))


# Swich Vendorsize to a factor
FullData$VendorSize <- as.factor(FullData$VendorSize)


# This line discards the "Area" and "Actions" columns and aggregates Amount
# by the five other category columns.  You must alter or remove this if you 
# want to use Area or Actions for anything.
FullData <- ddply(FullData, .(FY, VendorSize, Place, Area, CrisisFunding),
                  plyr::summarize, 
                  Amount = sum(Amount),
                  Actions=sum(Actions))

FullData$CrisisFunding<-factor(FullData$CrisisFunding,
                               levels=c("ARRA","Disaster","OCO",NA),
                               labels=c("ARRA","Disaster","OCO","Residual"),
                               exclude=NULL)

# write output to CleanedVendorSize.csv
write.csv(FullData, file.path("CleanedVendorSize.csv"))

