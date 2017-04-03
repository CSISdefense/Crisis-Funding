require(plyr)
require(ggplot2)
require(scales)
# options(java.parameters = "-Xmx8g")
require(XLConnect)
#require(reshape2)
require(data.table)
require(lubridate)

# Path<-"K:/2007-01 PROFESSIONAL SERVICES/R scripts and data/"
# Path<-"D:/Users/Greg Sanders/Documents/Development/R-scripts-and-data/"
Path<-"C:/Users/gsand_000.ALPHONSE/Documents/Development/R-scripts-and-data/"
source(paste(Path,"lookups.r",sep=""))
source(paste(Path,"helper.r",sep=""))


ComptrollerMelt<-function(dfComptroller){
  varlist<-c("SourceFiscalYear",
             "AccountDSI",
             "Account",
             "MilDeptDW",
             "AccountTitle",
             "Account.Title", 
             "Organization" ,
             "BudgetActivity",
             "BudgetActivityTitle",
             "BudgetSubActivity",
             "BudgetSubActivityTitle",
             "BudgetLineItem", 
             "StateCountry",
             "StateCountryTitle",
             "Fiscal.Year",
             "FacilityCategoryTitle",
             "LocationTitle",
             "ConstructionProject",
             "ConstructionProjectTitle",
             "AGtitle",
             "BSA",
             "BSAtitle",
             "BSA.Title"  ,
             "LineNumber",
             "LineItem",
             "LineItemTitle",
             "ProgramElement",
             "ProgramElementTitle",
             "CostType",
             "CostTypeTitle",
             "LineNumber",
             "SAG",
             "SAGtitle",
             "SAG.Title", 
             "IncludeInTOA",
             "AddOrNonAdd",
             "Classified",
             "BudgetType", 
             "FiscalYear",
             "SubActivity", 
             # "ComptrollerVariable",
             "Project.Title", 
             "Treasury.Agency", 
             "SourceType",
             "OriginType"
             
  )
  
  varlist<-varlist[varlist %in% colnames(dfComptroller) ]
  data.table::melt(dfComptroller,
                   id.vars=varlist
  )
  
}

ComptrollerVariableRename<-function(dfComptroller){
  if(!"FiscalYear" %in% colnames(dfComptroller)){
    dfComptroller$FiscalYear<-as.numeric(
      substring(as.character(dfComptroller$variable),4,7))
    dfComptroller$variable<-substring(as.character(dfComptroller$variable),9,999)
    # dfComptroller$variable<-substring(as.character(dfComptroller$variable),1,999)
  }
  dfComptroller<-read_and_join(
    ""
    ,"RenameComptrollerColumns.csv"
    ,dfComptroller
  )   
  
  
  if(any(is.na(dfComptroller$AllColumns))){
    stop(paste("Unaccounted for Comptroller Column Variant(s): ",
               paste(unique(dfComptroller$variable[is.na(dfComptroller$AllColumns)]),
                     collapse=", "),
               sep=", "))
  }
  
  varlist<-c("SourceFiscalYear",
             "AccountDSI",
             "Account",
             "MilDeptDW",
             "AccountTitle",
             "Account.Title", 
             "Organization" ,
             "BudgetActivity",
             "BudgetActivityTitle",
             "BudgetSubActivity",
             "BudgetSubActivityTitle",
             "BudgetLineItem", 
             "StateCountry",
             "StateCountryTitle",
             "Fiscal.Year",
             "FacilityCategoryTitle",
             "LocationTitle",
             "ConstructionProject",
             "ConstructionProjectTitle",
             "AGtitle",
             "BSA",
             "BSAtitle",
             "BSA.Title",
             "LineNumber",
             "LineItem",
             "LineItemTitle",
             "ProgramElement",
             "ProgramElementTitle",
             "CostType",
             "CostTypeTitle",
             "LineNumber",
             "SAG",
             "SAGtitle",
             "SAG.Title", 
             "IncludeInTOA",
             "AddOrNonAdd",
             "Classified",
             "BudgetType",
             "FiscalYear",
             "Project.Title", 
             "Treasury.Agency", 
             "SourceType", 
             "TOAamount", 
             
             "OriginType"
             
             #Note that origin type is missing in the other function, as it's added in this step.
  )
  
  varlist<-varlist[varlist %in% colnames(dfComptroller) ]
  subset(dfComptroller,select=-c(variable,SourceColumn,AllColumns))
  dfComptroller<-reshape2::dcast(dfComptroller, 
                                 paste(
                                   paste(varlist,collapse=" + ")
                                   ,"~  Consolidate"),
                                 sum, 
                                 fill=NA_real_ )
  
  
  dfComptroller
}

ComptrollerOCObyAccount<-function(dfComptroller){
  dfComptroller<-ddply(dfComptroller,
                       .(AccountDSI,
                         AccountTitle,
                         Organization,
                         SourceFiscalYear,
                         FiscalYear,
                         OriginType),
                       plyr::summarise,
                       EnactedType=sum(EnactedType)
  )
  dfComptroller<-subset(dfComptroller,!is.na(EnactedType))
  dfComptroller<-reshape2::dcast(dfComptroller, 
                                 AccountDSI +
                                   AccountTitle +
                                   Organization +
                                   SourceFiscalYear +
                                   FiscalYear ~  
                                   OriginType,
                                 sum, 
                                 fill=NA_real_ )
  dfComptroller$pOCO=dfComptroller$OCO/(dfComptroller$OCO+dfComptroller$Base)
  dfComptroller
}

ComptrollerLoadWorkbook<-function(sfy,fileprefix){
  if(file.exists(file.path("Data",sfy,paste(fileprefix,"1a.xlsx",sep="")))){
    ReturnXLS <- XLConnect::loadWorkbook(file.path("Data",sfy,paste(fileprefix,"1a.xlsx",sep="")))
  }
  else if(file.exists(file.path("Data",sfy,paste(fileprefix,"1a.xls",sep="")))) {
    ReturnXLS <- XLConnect::loadWorkbook(file.path("Data",sfy,paste(fileprefix,"1a.xls",sep="")))
  }
  else if(file.exists(file.path("Data",sfy,paste(fileprefix,"1.xlsx",sep="")))) {
    ReturnXLS <- XLConnect::loadWorkbook(file.path("Data",sfy,paste(fileprefix,"1.xlsx",sep="")))
  }
  else if(file.exists(file.path("Data",sfy,paste(fileprefix,"1.xls",sep="")))) {
    ReturnXLS <- XLConnect::loadWorkbook(file.path("Data",sfy,paste(fileprefix,"1.xls",sep="")))
  }
  
  ReturnXLS
}
