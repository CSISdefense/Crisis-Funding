######################################################
# code to read the top 10 rows of csv file
######################################################

#Alphabetical order for ease of comparison with folder.
data1 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractBucketPlatformCustomer.txt", nrows = 10)
fulldata1 <-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractBucketPlatformCustomer.txt",
  col_names=TRUE, 
  delim="\t",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata1)
fulldata1<-fulldata1[-c(18092192:18092195),]
readr::write_tsv(fulldata1,
  "LargeDataSets\\Civilian_Contract_SP_ContractBucketPlatformCustomer.txt"
  )



data1A <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractCompetitionVehicleCustomer.txt", nrows = 10,sep="\t")
fulldata1A<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractCompetitionVehicleCustomer.txt",
  col_names=TRUE, 
  delim="\t",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata1A)


data2 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractDetailsCustomer.csv", nrows = 10)
fulldata2<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractDetailsCustomer.csv",
  col_names=TRUE, 
  delim=",",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata2)
fulldata2<-fulldata2[-c(18090375:18090379),]
readr::write_csv(fulldata2,
  "LargeDataSets\\Civilian_Contract_SP_ContractDetailsCustomer.csv"
)


data3 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractIdentifierCustomer.csv", nrows = 10)
fulldata3<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractIdentifierCustomer.csv",
  col_names=TRUE, 
  delim=",",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata3)
fulldata3<-fulldata3[-c(18092192:18092195),]
readr::write_csv(fulldata3,
  "LargeDataSets\\Civilian_Contract_SP_ContractIdentifierCustomer.csv"
)


data4 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractModificationDeltaCustomer.csv", nrows = 10)
fulldata4<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractModificationDeltaCustomer.csv",
  col_names=TRUE, 
  delim=",",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata4)
fulldata4<-fulldata4[-c(18090375:18090379),]
readr::write_csv(fulldata4,
  "LargeDataSets\\Civilian_Contract_SP_ContractModificationDeltaCustomer.csv"
)

data5 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractPricingCustomer.txt", sep="\t", nrows=10)
fulldata5<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractPricingCustomer.txt",
  col_names=TRUE, 
  delim="\t",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
fulldata5<-fulldata5[-c(18092192:18092195),]
readr::problems(fulldata5)
readr::write_csv(fulldata5,
  "LargeDataSets\\Civilian_Contract_SP_ContractPricingCustomer.csv"
)

data6 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractSampleCriteriaDetailsCustomer.csv", nrows = 10)
fulldata6 <-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractSampleCriteriaDetailsCustomer.csv",
  col_names=TRUE, 
  delim=",",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata6)
fulldata6<-fulldata6[-c(18090375:18090379),]
readr::write_csv(fulldata6,
  "LargeDataSets\\Civilian_Contract_SP_ContractSampleCriteriaDetailsCustomer.csv"
)

data7 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractUnmodifiedAndOutcomeDetailsCustomer.txt", nrows = 10,
  sep="\t")
fulldata7<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractUnmodifiedAndOutcomeDetailsCustomer.txt",
  col_names=TRUE, 
  delim="\t",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata7)


data8 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractUnmodifiedCompetitionVehicleCustomer.csv", nrows = 10)
fulldata8<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractUnmodifiedCompetitionVehicleCustomer.csv",
  col_names=TRUE, 
  delim=",",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata8)
fulldata8<-fulldata8[-c(18047133:18047136),]
readr::write_csv(fulldata8,
  "LargeDataSets\\Civilian_Contract_SP_ContractUnmodifiedCompetitionVehicleCustomer.csv"
)

18092195


data9 <- read.csv("LargeDataSets/Civilian_Contract_SP_ContractLocationCustomer.txt", 
  sep="\t",nrows = 10)
fulldata9<-readr::read_delim(
  "LargeDataSets\\Civilian_Contract_SP_ContractLocationCustomer.txt",
  col_names=TRUE, 
  delim=",",
  # , dec=".",
  trim_ws=TRUE,
  na=c("NULL","NA")
  # stringsAsFactors=FALSE
)
readr::problems(fulldata9)




# Below file is run in terminal with bcp command. 
# The output file does not have a header, but it can solve the issue for strings with comma.
# bcp "EXEC [DIIG].[Contract].[SP_ContractBucketPlatformCustomer] @IsDefense = 0" queryout C:\Users\ZWang\Documents\Civilian_SP_ContractBucketPlatformCustomer_zw.csv -c -t "," -S VMDatabase -T

data8 <- read.csv("Civilian_SP_ContractBucketPlatformCustomer_zw.csv", header = F, nrows = 10)



# Below is the code to read the .rpt file, but it has the limitation of 100MB
library(epanetReader)
dt6 <- read.rpt("aaa.rpt")
