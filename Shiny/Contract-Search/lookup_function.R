library(tidyverse)

# 
# Contract_Detail <- read.csv("defense_contract_CSIScontractID_detail.csv",
#                             header = TRUE,sep = ",")
# Contract_Detail$CSIScontractID <- as.character(Contract_Detail$CSIScontractID)
# save(Contract_Detail,file = "Contract_Detail.RData")
# 



#------------------------------------------------------------------------------------------------------
# The argument of this function is the name of the dataframe and an integer vector(Contract ID)
#------------------------------------------------------------------------------------------------------
Contract_Id_Lookup <- function(filename,x){
  specified_record <- filter(filename,CSIScontractID %in% x)
  Action_Obligation <- select(specified_record,CSIScontractID,Action.Obligation)
  return(Action_Obligation)
}
#-----------------------------------------------------------------------------------------------------

# load("Contract_Detail.RData")
# a <- Contract_Id_Lookup(Contract_Detail,c("60560387","20809194"))
# 
# 
# rm(Contract_Detail)













