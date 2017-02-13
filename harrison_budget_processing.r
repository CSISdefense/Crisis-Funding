#*************************************Required Libraries******************************************
require(plyr)
require(grid)
require(reshape2)
require(stringr)
require(ggplot2)
# require(logging)
# debug(VariableNumericalFormat)
#*************************************Options*****************************************************
options(error=recover)
options(warn=1)
# basicConfig()
# logdebug("not shown, basic is INFO")
# logwarn("shown and timestamped")

# system("defaults write org.R-project.R force.LANG en_US.UTF-8")
# debug("CreateCSV")

# debug(apply_lookups)
# debug(CreateDuration)
#*************************************Lookup Files*****************************************************
# Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
Path<-"~\\R scripts and data\\"
# Path<-"C:\\Users\\Greg Sanders\\SkyDrive\\Documents\\R Scripts and Data SkyDrive\\"

require(plyr)
require(reshape2)

source(paste(Path,"helper.r",sep=""))
source(paste(Path,"lookups.r",sep=""))


setwd("K:\\Development\\Budget")
# setwd("C:\\Users\\Greg Sanders\\Documents\\Budget")

# debug(create_procedural_graphs
Procurement<-read.csv(
    paste("Data\\","Harrison_Procurement_Budget_Database_Export_2015.csv",sep=""),
    header=TRUE, sep=",", na.strings=c("","NULL"), dec=".", strip.white=TRUE, 
    stringsAsFactors=TRUE
)

Procurement<-standardize_variable_names(Path,Procurement)
colnames(Procurement)[colnames(Procurement)=="Account"]<-"MainAccountCode"

colnames(Procurement)
Procurement<-reshape2::melt(Procurement
      , id=c("ID"
          ,"MainAccountCode"
          ,"BudgetActivity"
          ,"BudgetActivityTitle"
          ,"BSA"
          ,"BSAtitle"
          ,"LineItem"
          ,"LineItemTitle"
          ,"CostType"
          ,"CostTypeTitle"
          ,"ProcurementCategory"
          ,"Classified")
      )


Procurement$FiscalYear<-as.numeric(substring(as.character(Procurement$variable),4,7))
Procurement$variable<-substring(as.character(Procurement$variable),9,999)


Procurement<-read_and_join(
    ""
    ,"RenameComptrollerColumns.csv"
    ,Procurement
)


Procurement<-subset(Procurement,!is.na(value))


# Procurement$variable[Procurement$variable==""]<-"Actual"
# Procurement$variable[Procurement$variable=="CR.Quant"]<-"Quant.CR"
# Procurement$variable[Procurement$variable=="CR.OCO.Quant"]<-"Quant.CR.OCO"
# Procurement$variable[Procurement$variable=="Quant"]<-"Quant.Actual"
# Procurement$AllColumns<-ordered(Procurement$AllColumns,c("PB",
#                                                      "App",
#                                                      "Actual",
#                                                      "CR",
#                                                      "CR_OCO",
#                                                      "OCO_PB",
#                                                      "OCO_App",
#                                                      "OCO_Sup",
#                                                      "Quant_PB",
#                                                      "Quant_App",
#                                                      "Quant_Actual",
#                                                      "Quant_CR",
#                                                      "Quant_CR_OCO",
#                                                      "Quant_OCO_PB",
#                                                      "Quant_OCO_App",
#                                                      "Quant_OCO_Sup"
#                                                      ))
# summary(Procurement$AllColumns)
# unique(Procurement$variable)
# Procurement$Type[substring(as.character(Procurement$variable),1,5)=="Quant"]<-"Quantity"
# Procurement$Type[substring(as.character(Procurement$variable),1,5)!="Quant"]<-"Dollars"
# Procurement$variable[substring(as.character(Procurement$variable),1,5)=="Quant"]<-
    # substring(as.character(Procurement$variable[substring(as.character(Procurement$variable),1,5)=="Quant"]),7,999)

# ProcurementAllColumns<-dcast(subset(Procurement,select=-c(variable,SourceColumn,Consolidate,OriginType)), 
#                    ID
#                    +MainAccountCode
#                    +BudgetActivity
#                    +BudgetActivityTitle
#                    +BSA
#                    +BSAtitle
#                    +LineItem
#                    +LineItemTitle
#                    +CostType
#                    +CostTypeTitle
#                    +ProcurementCategory
#                    +Classified
#                    + FiscalYear~ AllColumns ,sum, fill=NA_real_ )
# 
# 
# 
# 
# write.csv(ProcurementAllColumns,paste("Data\\","Procurement_Budget_Database_Export_All_Columns.csv",sep=""), row.names=FALSE,na="")



Procurement$Consolidate<-ordered(Procurement$Consolidate,c("PBtotal",#Amounts
                                           "PBtype",
                                           "EnactedTotal",
                                           "EnactedType",
                                           "SpecialType",
                                           "ActualTotal",
                                           "QuantPBtotal",#Quantities
                                           "QuantPBtype",
                                           "QuantEnactedTotal",
                                           "QuantEnactedType",
                                           # "QuantSpecialTotal",
                                           "QuantSpecialType",  
                                           "QuantActualTotal"
                                           
))

# 
# "PBtotal"
# "PBtype"
# "EnactedTotal"
# "EnactedType"
# "SpecialType"
# "ActualTotal"                                       
# "QuantPBtotal"
# "QuantPBtype" 
# "QuantEnactedTotal"
# "QuantEnactedType" 
# 
# "QuantActualTotal" 
#              




Procurement$SourceFiscalYear[Procurement$Consolidate %in% c("PBtotal","PBtype",
                                           "QuantPBtotal","QuantPBtype")]<-
    Procurement$FiscalYear[Procurement$Consolidate %in% c("PBtotal","PBtype",
                                               "QuantPBtotal","QuantPBtype")]
Procurement$SourceFiscalYear[Procurement$Consolidate %in% c("EnactedTotal","EnactedType","SpecialType",
                                           "QuantEnactedTotal","QuantEnactedType","QuantSpecialType")]<-
    Procurement$FiscalYear[Procurement$Consolidate %in%  c("EnactedTotal","EnactedType","SpecialType",
                                                "QuantEnactedTotal","QuantEnactedType","QuantSpecialType")]+1
Procurement$SourceFiscalYear[Procurement$Consolidate %in% c("ActualTotal","QuantActualTotal")]<-
    Procurement$FiscalYear[Procurement$Consolidate %in%  c("ActualTotal","QuantActualTotal")]+2





ProcurementConsolidated<-reshape2::dcast(subset(Procurement,select=-c(variable,SourceColumn,AllColumns)), 
                                         SourceFiscalYear
                                         +ID
                                         +MainAccountCode
                                         +BudgetActivity
                                         +BudgetActivityTitle
                                         +BSA
                                         +BSAtitle
                                         +LineItem
                                         +LineItemTitle
                                         +CostType
                                         +CostTypeTitle
                                         +ProcurementCategory
                                         +Classified
                                         + FiscalYear
                                         + OriginType~  Consolidate   ,
                                         sum, 
                                         fill=NA_real_ )




ProcurementsqlColumns<-c(	"ID"  ,
                          "SourceFiscalYear"  ,
                          "AccountDSI"  ,
                          "TreasuryAgencyCode"  ,
                          "MainAccountCode"  ,
                          "AccountTitle"  ,
                          "Organization"  ,
                          "BudgetActivity"  ,
                          "BudgetActivityTitle"  ,
                          "LineNumber" ,
                          "BSA"   ,
                          "BSAtitle"  ,
                          "LineItem"  ,
                          "LineItemTitle"  ,
                          "CostType"  ,
                          "CostTypeTitle"  ,
                          "AddOrNonAdd"  ,
                          "Classified"  ,
                          "ProcurementCategory"  ,
                          "FiscalYear"  ,
                          "OriginType" ,
                          "PBtotal" ,
                          "PBtype"  ,
                          "EnactedTotal"  ,
                          "EnactedType"  ,
                          "SpecialType"  ,
                          "ActualTotal"  ,
                          "QuantPBtotal"  ,
                          "QuantPBtype"  ,
                          "QuantEnactedTotal"  ,
                          "QuantEnactedType"  ,
                          "QuantSpecialType"  ,
                          "QuantActualTotal"  
                          ) 

Missing<-ProcurementsqlColumns[!ProcurementsqlColumns %in% colnames(ProcurementConsolidated)]
ProcurementConsolidated[,Missing]<-NA
ProcurementConsolidated<-ProcurementConsolidated[,ProcurementsqlColumns]

write.csv(ProcurementConsolidated,paste("Data\\","Procurement_Budget_Database_Export_Consolidated.csv",sep=""), 
          row.names=FALSE,
          na="")
str(ProcurementConsolidated)


max(nchar(as.character(Procurement$LineItem)))



RnD<-read.csv(
    paste("Data\\","Harrison_RnD_Budget_Database_Export.csv",sep=""),
    header=TRUE, sep=",", na.strings=c("","NULL"), dec=".", strip.white=TRUE, 
    stringsAsFactors=TRUE
)

RnD<-standardize_variable_names(Path,RnD)
colnames(RnD)[colnames(RnD)=="Account"]<-"MainAccountCode"

colnames(RnD)
RnD<-melt(RnD
                  , id=c("ID"
                         ,"ProgramElement"
                         ,"ProgramElementTitle"
                         ,"BudgetActivity"
                         ,"BudgetActivityTitle"
                         ,"MainAccountCode"
                         ,"Classified")
                  # ,value.name="DollarsThousands"
)



RnD$FiscalYear<-as.numeric(substring(as.character(RnD$variable),4,7))
RnD$variable<-substring(as.character(RnD$variable),9,999)
# RnD$variable[RnD$variable==""]<-"Actual"

RnD<-read_and_join(
    ""
    ,"RenameComptrollerColumns.csv"
    ,RnD
)

RnD$AllColumns<-ordered(RnD$AllColumns,c("PB",
                                                     "App",
                                                     "Actual",
                                                     "CR",
                                                     "CR_OCO",
                                                     "OCO_PB",
                                                     "OCO_App",
                                                     "OCO_Sup"
                                  
))

RnD$Consolidate<-ordered(RnD$Consolidate,c("PBtotal",
                                         "PBtype",
                                         "EnactedTotal",
                                         "EnactedType",
                                         "SpecialType",
                                         "ActualTotal"
                                         
))

RnD<-subset(RnD,!is.na(value))


RnD$SourceFiscalYear[RnD$Consolidate %in% c("PBtotal","PBtype")]<-
    RnD$FiscalYear[RnD$Consolidate %in% c("PBtotal","PBtype")]
RnD$SourceFiscalYear[RnD$Consolidate %in% c("EnactedTotal","EnactedType","SpecialType")]<-
    RnD$FiscalYear[RnD$Consolidate %in%  c("EnactedTotal","EnactedType","SpecialType")]+1
RnD$SourceFiscalYear[RnD$Consolidate %in% c("ActualTotal")]<-
    RnD$FiscalYear[RnD$Consolidate %in%  c("ActualTotal")]+2


# RnDallColumns<-dcast(subset(RnD,select=-c(variable,SourceColumn,Consolidate,OriginType)), 
#            ID+
#                          ProgramElement+
#                          ProgramElementTitle+
#                          BudgetActivity+
#                          BudgetActivityTitle+
#                          MainAccountCode+
#                          Classified+ FiscalYear~ AllColumns ,
#            sum, 
#            fill=NA_real_ )
# 
# 
# 
# 
# # max(nchar(as.character(RnD$ProgramElement)))
# write.csv(RnDallColumns,paste("Data\\","RnD_Budget_Database_All_Columns.csv",sep=""), row.names=FALSE,na="")




RnDconsolidated<-reshape2::dcast(subset(RnD,select=-c(variable,SourceColumn,AllColumns)), 
                                         SourceFiscalYear+
                                     ID+  
                                     ProgramElement+
                                     ProgramElementTitle+
                                     BudgetActivity+
                                     BudgetActivityTitle+
                                     MainAccountCode+
                                     Classified+
                                    FiscalYear +                                 
                                     OriginType ~  Consolidate   ,
                                         sum, 
                                         fill=NA_real_ )



RnDsqlColumns<-c("ID"
                 ,"SourceFiscalYear"
                 ,"AccountDSI"
                 ,"TreasuryAgencyCode"
                 ,"MainAccountCode"
                 ,"AccountTitle"
                 ,"Organization"
                 ,"BudgetActivity"
                 ,"BudgetActivityTitle"
                 ,"LineNumber"
                 ,"ProgramElement"
                 ,"ProgramElementTitle"
                 ,"IncludeInTOA"
                 ,"Classified"
                 ,"FiscalYear"
                 ,"OriginType"
                 ,"PBtotal"
                 ,"PBtype"
                 ,"EnactedTotal"
                 ,"EnactedType"
                 ,"SpecialType"
                 ,"ActualTotal") 

Missing<-RnDsqlColumns[!RnDsqlColumns %in% colnames(RnDconsolidated)]
RnDconsolidated[,Missing]<-NA
RnDconsolidated<-RnDconsolidated[,RnDsqlColumns]


write.csv(RnDconsolidated,paste("Data\\","RDTE_Budget_Database_Consolidated.csv",sep=""), 
          row.names=FALSE,
          na="")
str(ProcurementConsolidated)


