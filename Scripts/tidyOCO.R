library(dplyr)
library(tidyr)


setwd("H:/Crisis-Funding/Data/FY2017/Output")


data.OCO <- read.csv("./2017 OCO Merge.csv",  stringsAsFactors  = F)

data.OCO$AccountDSI[is.na(data.OCO$AccountDSI)] <- "Unlabeled"


data.OCO <- data.OCO %>% select (-QuantPBtotal, -QuantPBtype, -QuantEnactedType, 
                                 -QuantSpecialTotal, -QuantActualTotal, -SAG, -ID, -TreasuryAgencyCode,
                                 -MainAccountCode, -LineNumber.1, -AG...BSA, -CostType,-CostTypeTitle,
                                 -Category, -IncludeInTOA.1, -SpecialType, -QuantEnactedTotal,
                                 -BSA.Title, -ProgramElementTitle) 
                                
                                


data.OCO$EnactedTotal[is.na(data.OCO$EnactedTotal)] <- 0

data.OCO$EnactedType[is.na(data.OCO$EnactedType)] <- 0
 
#  data.OCO$AccountDSI[is.na(data.OCO$AccountDSI)] <- "Unlabeled"                             )
# 
# data.OCO$Account[is.na(data.OCO$Account)] <- "Unlabeled"
# 
# data.OCO$MilDeptDW[is.na(data.OCO$MilDeptDW)] <- "Unlabeled"
# 
# data.OCO$AccountTitle[is.na(data.OCO$AccountTitle)] <- "Unlabeled"
# 
# data.OCO$Organization[is.na(data.OCO$Organization)] <- "Unlabeled"
# 
# data.OCO$BudgetActivity[is.na(data.OCO$BudgetActivity)] <- "Unlabeled"
# 
# data.OCO$BudgetActivityTitle[is.na(data.OCO$BudgetActivityTitle)] <- "Unlabeled"
# 
# data.OCO$StateCountry[is.na(data.OCO$StateCountry)] <- "Unlabeled"
# 
# data.OCO$StateCountryTitle[is.na(data.OCO$StateCountryTitle)] <- "Unlabeled"

data.OCO[is.na(data.OCO)] <- "Unlabeled"


# data.OCO$PBtotal <- as.numeric(data.OCO$PBtotal)

data.group.OCO <- data.OCO %>% 
  group_by(SourceFiscalYear, FiscalYear, OriginType, AccountDSI) %>%
     summarise(EnactedTotal= sum(EnactedTotal), EnactedType =sum(EnactedType))

setwd("H:/Crisis-Funding/Data/Tidy Data")

write.csv(data.group.OCO, "2017 OCO Tidy Data.csv")
