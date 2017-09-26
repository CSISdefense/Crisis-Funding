library(dplyr)
library(stringr)
library(readr)
require(shiny)
require(ggplot2)
require(scales)
require(Cairo)
require(grid)
require(gridExtra)
library(forcats)
library(shinyBS)
library(shinyjs)


O_and_M <- read_csv("OandMCrossYearCleaned.csv")
View(O_and_M)



for(i in 1:length(O_and_M$AccountTitle)){
  if(grepl("Army", O_and_M$AccountTitle[i]) == TRUE & is.na(O_and_M$Organization[i])){
    O_and_M$Organization[i] <- "Army"}
  else if(grepl("Navy", O_and_M$AccountTitle[i]) == TRUE & is.na(O_and_M$Organization[i])){
    O_and_M$Organization[i] <- "Navy"}
else if(grepl("Air Force", O_and_M$AccountTitle[i]) == TRUE & is.na(O_and_M$Organization[i])){
  O_and_M$Organization[i] <- "Air Force"}}

O_and_M <- filter(O_and_M, 
                  Organization == "Army" |
                    Organization == "Navy" |
                    Organization == "Air Force")


for(i in 1:length(O_and_M$AccountTitle)){
  O_and_M$AccountTitle[i] <- "Operation and Maitenance"}


O_and_M$AccountTitle[O_and_M$AccountTitle == "Contributions to the Cooperative Threat Red Pgm"] <- "Contributions to the Cooperative Threat Reduction Program"
O_and_M$AccountTitle[O_and_M$AccountTitle == "Emergency Response Fund, Defense"] <- "Emergency Response Fund"
O_and_M$AccountTitle[O_and_M$AccountTitle == "Environmental Restoration, Air Force"] <- "Environmental Restoration"
O_and_M$AccountTitle[O_and_M$AccountTitle == "Environmental Restoration, Army"] <- "Environmental Restoration"
O_and_M$AccountTitle[O_and_M$AccountTitle == "Environmental Restoration, Navy"] <- "Environmental Restoration"
O_and_M$AccountTitle[O_and_M$AccountTitle == "Overseas Humanitarian, Disaster, and Civic Aid"] <- "Overseas Humanitarian, Disaster and Civic Aid"
O_and_M$AccountTitle[O_and_M$AccountTitle == "Operation & Maintenance, MC Reserve"] <- "Operation and Maitenance"

    
O_and_M$AGtitle[O_and_M$AGtitle == "Basic Skills And Advanced Training"] <- "Basic Skill and Advanced Training"
O_and_M$AGtitle[O_and_M$AGtitle == "Support Of Other Nations"] <- "Support to Other Nations"
O_and_M$AGtitle[O_and_M$AGtitle == "Support To Other Nations"] <- "Support to Other Nations"
O_and_M$AGtitle[O_and_M$AGtitle == "Support of Other Nations"] <- "Support to Other Nations"
O_and_M$AGtitle[O_and_M$AGtitle == "Support of Other Nations"] <- "Support to Other Nations"
O_and_M$AGtitle[O_and_M$AGtitle == "Recruiting, and Other Training & Education"] <- "Recruiting and Other Training & Education"
O_and_M$AGtitle[O_and_M$AGtitle == "Servicewide Support"] <- "Servicewide Activities" 
O_and_M$AGtitle[O_and_M$AGtitle == "Investigations And Security Programs" ] <- "Investigations and Security Programs"
O_and_M$AGtitle[O_and_M$AGtitle == "Recruiting and Other Training & Education"] <- "Recruiting, and Other Training & Education"
O_and_M$AGtitle[O_and_M$AGtitle == "Recruiting And Other Training & Education"] <- "Recruiting, and Other Training & Education"
O_and_M$AGtitle[O_and_M$AGtitle == "Logistics Operations"] <- "Logistics Operations And Technical Support"
O_and_M$AGtitle[O_and_M$AGtitle == "Land Forces Readiness Support"] <- "Land Forces"
O_and_M$AGtitle[O_and_M$AGtitle == "Land Forces Readiness"] <- "Land Forces"
O_and_M$AGtitle[O_and_M$AGtitle == "Disposal Of Dod Real Property"] <- "Disposal of DoD Real Property"  
O_and_M$AGtitle[O_and_M$AGtitle == "Combat Operations/Support" ] <- "Combat Related Operations" 
O_and_M$AGtitle[O_and_M$AGtitle == "Ready Reserve And Prepositioning Force"] <- "Ready Reserve and Prepositioning Force"
O_and_M$AGtitle[O_and_M$AGtitle == "Servicewide Activities"] <- "Servicewide Support"
O_and_M$AGtitle[O_and_M$AGtitle == "Logistics Operations And Technical Support"] <- "Logistics Operations and Technical Support"
O_and_M$AGtitle[O_and_M$AGtitle == "Lease Of Dod Real Property"] <- "Lease of DoD Real Property"
O_and_M$AGtitle[O_and_M$AGtitle == "Basic Skill and Advanced Training"] <- "Basic Skills and Advanced Training"

O_and_M$SAG.Title[O_and_M$SAG.Title == "Acquisition & Program Management"] <- "Acquisition and Program Management"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Acquisition And Program Management"] <- "Acquisition and Program Management"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Air Operations And Safety Support"] <- "Air Operations and Safety Support"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Civilian Education And Training"] <- "Civilian Education and Training" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Civilian Manpower And Personnel Management"] <- "Civilian Manpower and Personnel Management" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Combatant Commands Direct Mission Support"] <- "Combatant Commanders Direct Mission Support" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "CommanderS Emergency Response Program"] <- "Commanders Emergency Response Program"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Environmental Restoration, Air Force"] <- "Environmental Restoration"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Environmental Restoration, Army"] <- "Environmental Restoration"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Environmental Restoration, Navy"] <- "Environmental Restoration"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Equipment And Transportation"] <- "Equipment and Transportation" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Equipment & Transportation"] <- "Equipment and Transportation" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Equipment/Transportation"] <- "Equipment and Transportation"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Equipment Maintenance"] <- "Equipment and Transportation"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Facilities Sustainment, Restoration, & Modernization"] <- "Facilities Sustainment, Restoration & Modernization" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Global C3I And Early Warning"] <- "Global C3I and Early Warning" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Hull, Mechanical And Electrical Support"] <- "Hull, Mechanical and Electrical Support"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Industrial Readiness"] <- "Industrial Preparedness"
O_and_M$SAG.Title[O_and_M$SAG.Title == "International Headquarters And Agencies"] <- "International Headquarters and Agencies"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Operating Forces"] <- "Operational Forces"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Off-Duty And Voluntary Education"] <- "Off-Duty and Voluntary Education"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Operational Meteorology And Oceanography"] <- "Operational Meteorology and Oceanography"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Other Pers Support (Disability Comp)"] <- "Other Personnel Support"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Judgement Fund"] <- "Judgment Fund"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Judgement Fund Reimbursement"] <- "Judgment Fund"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Judgment Fund Reimbursement"] <- "Judgment Fund"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Junior ROTC"] <- "Junior Reserve Officer Training Corps"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Lease Of DoD Real Property" ] <- "Lease of DoD Real Property" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Logistic Support Activities" ] <- "Logistics Operations"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Management And Operational Hq"] <- "Management and Operational Headquarters"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Management and Operational Hq's"] <- "Management and Operational Headquarters"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Military Manpower and Pers Mgmt (ARPC)"  ] <- "Military Manpower and Personnel Management"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Military Manpower And Pers Mgmt (Arpc)"  ] <- "Military Manpower and Personnel Management"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Military Manpower And Personnel Management" ] <- "Military Manpower and Personnel Management"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Planning, Engineering And Design"] <- "Planning, Engineering and Design"  
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Other Service Support"  ] <- "Other Servicewide Activities"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Recruiting And Advertising" ] <- "Recruiting and Advertising"
O_and_M$SAG.Title[O_and_M$SAG.Title ==   "Ship Prepositioning And Surge"] <- "Ship Prepositioning and Surge"
O_and_M$SAG.Title[O_and_M$SAG.Title ==   "Space And Electronic Warfare Systems" ] <- "Space and Electronic Warfare Systems" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==   "Ship Prepositioning And Surge"] <- "Ship Prepositioning and Surge"
O_and_M$SAG.Title[O_and_M$SAG.Title ==   "Space And Electronic Warfare Systems"] <- "Space and Electronic Warfare Systems"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Space Systems And Surveillance"] <- "Space Systems and Surveillance" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Support of International Sporting Competitions, Defense"] <- "Support Of International Sporting Competitions, Defense"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Sustainment, Restoration & Modernization"  ] <- "Sustainment, Restoration and Modernization" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Sustainment, Restoration, & Modernization"   ] <- "Sustainment, Restoration and Modernization" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Sustainment, Restoration And Modernization"   ] <- "Sustainment, Restoration and Modernization" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Tactical Intel And Other Special Activities"  ] <- "Tactical Intel and Other Special Activities" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Base Operating Support"  ] <- "Base Support"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Training Support"   ] <- "Training and Operations"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Mission And Other Flight Operations"] <- "Mission and Other Flight Operations"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Mission And Other Ship Operations" ] <- "Mission and Other Ship Operations" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Misc. Support Of Other Nations"] <- "Misc. Support of Other Nations"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Training"   ] <- "Training and Operations"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Training And Operations"   ] <- "Training and Operations"
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Cancelled Account Adjustment"  ] <- "Cancelled Account Adjustments" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Army Prepositioning Stocks"  ] <- "Army Prepositioned Stocks" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Basic Skill and Advanced Training"] <- "Basic Skills and Advanced Training4" 
O_and_M$SAG.Title[O_and_M$SAG.Title ==  "Sustainment"  ] <- "Sustainment, Restoration and Modernization"
O_and_M$AGtitle[O_and_M$SAG.Title == "Disposal Of Dod Real Property"] <- "Disposal of DoD Real Property"
O_and_M$AGtitle[O_and_M$SAG.Title == "Support Of NATO Operations" ] <- "Support of NATO Operations"
O_and_M$AGtitle[O_and_M$SAG.Title == "Sustainment, Restoration & Modernization" ] <- "Sustainment, Restoration and Modernization"
O_and_M$AGtitle[O_and_M$SAG.Title == "Sustainment"   ] <- "Sustainment, Restoration and Modernization"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Reserve Officers Training Corps (ROTC)"   ] <- "Reserve Officers Training Corps"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Other Pers Support (Disability Comp)"  ] <- "Other Personnel Support"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Operational Forces" ] <- "Operating Forces"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Training Support" ] <- "Training and Operations"  
O_and_M$SAG.Title[O_and_M$SAG.Title == "Judgement Fund" ] <- "Judgment Fund"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Infrastructue" ] <- "Infrastructure"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Infrastructue" ] <- "Infrastructure"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Combatant Commands Direct Mission Support"  ] <-  "Combatant Commanders Direct Mission Support"
O_and_M$SAG.Title[O_and_M$SAG.Title == "Disposal Of DoD Real Property"  ] <- "Disposal of DoD Real Property" 
O_and_M$SAG.Title[O_and_M$SAG.Title == "Cancelled Account Adjustment"  ] <- "Cancelled Account Adjustments" 
O_and_M$BudgetActivityTitle <- paste(O_and_M$Organization, O_and_M$BudgetActivityTitle, sep = " - ")

O_and_M$BudgetActivityTitle[O_and_M$BudgetActivityTitle == "Navy - Environmental Restoration, Navy"] <-"Navy - Environmental Restoration" 
O_and_M$BudgetActivityTitle[O_and_M$BudgetActivityTitle == "Army - Environmental Restoration, Army"] <-"Army - Environmental Restoration" 
O_and_M$BudgetActivityTitle[O_and_M$BudgetActivityTitle == "Air Force - Environmental Restoration, Air Force"] <-"Air Force - Environmental Restoration" 




O_and_M <- mutate(O_and_M, Type = "", Amount = 0, Amount2 = 0)

for(i in 1:length(O_and_M$SAG.Title)){
  if(is.na(O_and_M$SAG.Title[i])){
    O_and_M$SAG.Title[i] <- O_and_M$BudgetLineItem[i]}}

for(i in 1:length(O_and_M$AGtitle)){
  if(is.na(O_and_M$AGtitle[i])){
    O_and_M$AGtitle[i] <- O_and_M$BudgetSubActivityTitle[i]}}

for(i in 1:length(O_and_M$Organization)){
  if(!is.na(O_and_M$ActualTotal[i])){
    O_and_M$Type[i] <- "Obligated"
    O_and_M$Amount[i] <- O_and_M$ActualTotal[i]}}

for(i in 1:length(O_and_M$Organization)){
  if(!is.na(O_and_M$PBtotal[i])){
    O_and_M$Type[i] <- "PB"
    O_and_M$Amount[i] <- O_and_M$PBtotal[i]}}


for(i in 1:length(O_and_M$Organization)){
  if(!is.na(O_and_M$PBtype[i])){
    O_and_M$Type[i] <- "PB"
    if(O_and_M$FiscalYear[i] != 2013){
    O_and_M$Amount2[i] <- O_and_M$PBtype[i]}
    else if (O_and_M$FiscalYear[i] == 2013){
      O_and_M$Amount[i] <- O_and_M$PBtype[i]}}}

for(i in 1:length(O_and_M$Organization)){
  if(!is.na(O_and_M$EnactedType)[i]){
    O_and_M$Type[i] <- "Enacted"
    O_and_M$Amount2[i] <- O_and_M$EnactedType[i]}}

for(i in 1:length(O_and_M$Organization)){
  if(!is.na(O_and_M$EnactedTotal)[i]){
    O_and_M$Type[i] <- "Enacted"
    O_and_M$Amount[i] <- O_and_M$EnactedTotal[i]}}




O_and_M <- select(O_and_M, SourceFiscalYear, Organization, 
                  AccountTitle, BudgetActivityTitle, AGtitle, SAG.Title, FiscalYear, OriginType, Type, Amount, Amount2)
O_and_M$Amount <- as.numeric(O_and_M$Amount)
O_and_M$Amount2 <- as.numeric(O_and_M$Amount2)

O_and_M_base <- filter(O_and_M, OriginType == "Base" | OriginType == "Base.Ann")
O_and_M_OCO <- filter(O_and_M, OriginType == "OCO" | OriginType == "OCO.Ann")
O_and_M_tot <- filter(O_and_M, OriginType == "Total" | OriginType == "Total.Ann")
O_and_M_base <- subset(O_and_M_base, select =  -c(OriginType, Type))
O_and_M_OCO <- subset(O_and_M_OCO, select = -c(OriginType, Type))
O_and_M_tot <- subset(O_and_M_tot, select =  -c(OriginType, Type))
O_and_M_tot <- subset(O_and_M_tot, select =  -Amount2)
O_and_M_base <- subset(O_and_M_base, select = -Amount)
O_and_M_OCO <- subset(O_and_M_OCO, select = -Amount)
O_and_M_base <- as.data.frame(O_and_M_base)
O_and_M_tot <- as.data.frame(O_and_M_tot)
colnames(O_and_M_OCO)[colnames(O_and_M_OCO) == "Amount2"] <- "Amount3"
O_and_M_div <- left_join(O_and_M_base, O_and_M_tot)
O_and_M_div <- left_join(O_and_M_div, O_and_M_OCO)
write_csv(O_and_M, "O_and_M.csv")
write_csv(O_and_M_div, "O_and_M_div.csv")
