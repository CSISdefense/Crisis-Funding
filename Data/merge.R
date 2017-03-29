library(data.table)
library(openxlsx)


#mg <- list.files(pattern =("*descriptions"))
#for (i in 1:length(mg)) assign(mg[i], read.csv(mg[i]))

setwd("H:/Crisis-Funding/Data/FY2017/Output")

file_list <- list.files()

dataset <- rbindlist(lapply( file_list, fread ), fill = TRUE)

# dataset <- dataset %>% select(-V1)

write.csv(dataset, "2017 OCO Merge.csv", append = FA)


