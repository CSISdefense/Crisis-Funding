# ChangeOrders
Greg Sanders  
Wednesday, February 8, 2017  

Costly Change Orders (Refined by NPS Study on Crisis-Funded Contracts)
============================================================================




```r
Path<-"D:\\Users\\Greg Sanders\\Documents\\Development\\R-scripts-and-data\\"
# Path<-"K:\\2007-01 PROFESSIONAL SERVICES\\R scripts and data\\"
source(paste(Path,"lookups.r",sep=""))
```

```
## Loading required package: stringr
```

```
## Loading required package: plyr
```

```r
source(paste(Path,"helper.r",sep=""))
```

```
## Loading required package: ggplot2
```

```
## Loading required package: grid
```

```
## Loading required package: scales
```

```
## Loading required package: reshape2
```

```
## Loading required package: lubridate
```

```
## 
## Attaching package: 'lubridate'
```

```
## The following object is masked from 'package:plyr':
## 
##     here
```

```
## The following object is masked from 'package:base':
## 
##     date
```

```r
source("ContractCleanup.r")

require(ggplot2)
require(scales)
require(Hmisc)
```

```
## Loading required package: Hmisc
```

```
## Loading required package: lattice
```

```
## Loading required package: survival
```

```
## Loading required package: Formula
```

```
## 
## Attaching package: 'Hmisc'
```

```
## The following object is masked _by_ '.GlobalEnv':
## 
##     subplot
```

```
## The following objects are masked from 'package:plyr':
## 
##     is.discrete, summarize
```

```
## The following objects are masked from 'package:base':
## 
##     format.pval, round.POSIXt, trunc.POSIXt, units
```

```r
require(plyr)
require(quantreg)
```

```
## Loading required package: quantreg
```

```
## Loading required package: SparseM
```

```
## 
## Attaching package: 'SparseM'
```

```
## The following object is masked from 'package:base':
## 
##     backsolve
```

```
## 
## Attaching package: 'quantreg'
```

```
## The following object is masked from 'package:Hmisc':
## 
##     latex
```

```
## The following object is masked from 'package:survival':
## 
##     untangle.specials
```

```r
Coloration<-read.csv(
    paste(Path,"Lookups\\","lookup_coloration.csv",sep=""),
    header=TRUE, sep=",", na.strings="", dec=".", strip.white=TRUE, 
    stringsAsFactors=FALSE
    )

Coloration<-ddply(Coloration
                  , c(.(R), .(G), .(B))
                  , transform
                  , ColorRGB=as.character(
                      if(min(is.na(c(R,G,B)))) {NA} 
                      else {rgb(max(R),max(G),max(B),max=255)}
                      )
                  )
```


Contracts are classified using a mix of numerical and categorical variables. While the changes in numerical variables are easy to grasp and summarize, a contract may have one line item that is competed and another that is not. As is detailed in the exploration on R&D, we are only considering information available prior to contract start. The percentage of contract obligations that were competed is a valuable benchmark, but is highly influenced by factors that occured after contract start..


##Costly Change Orders: existence and number of change orders 

In the same manner as contract terminations, change orders are reported in the *reason for modification* field.  There are two values that this study counts as change orders: "Change Order" and "Definitize Change Order."  For the remainder of this report, contracts with at least one change order are called **Changed Contracts**.  

There are also multiple modifications captured in FPDS that this current study will not investigate as change orders.  These include:

* Additional World (new agreement, FAR part 6 applies)
* Supplemental Agreement for work within scope
* Exercise an Option
* Definitize Letter Contract

In addition, there are a number of other modifications that may be undertaken based on changes on the government or vendor side that are not included in this analysis. 


```r
CompleteModelAndDetail  <- read.csv(
    paste("LargeDatasets\\defense_contract_CSIScontractID_detail.csv", sep = ""),
    header = TRUE, sep = ",", dec = ".", strip.white = TRUE, 
    na.strings = c("NULL","NA",""),
    stringsAsFactors = TRUE
    )




CompleteModelAndDetail<-FormatContractModel(CompleteModelAndDetail)


CompleteModelAndDetail$TermNum<-as.integer(as.character(factor(CompleteModelAndDetail$Term,
                                  levels=c("Terminated","Unterminated"),
                                  labels=c(1,0))))

CompleteModelAndDetail$ObligationWT<-CompleteModelAndDetail$Action.Obligation
CompleteModelAndDetail$ObligationWT[CompleteModelAndDetail$ObligationWT<0]<-NA

CompleteModelAndDetail<-ddply(CompleteModelAndDetail,
                         .(Ceil),
                         
                         plyr::mutate,
                         ceil.median.wt = median(UnmodifiedContractBaseAndAllOptionsValue)
)


CompleteModelAndDetail$UnmodifiedYearsFloat<-CompleteModelAndDetail$UnmodifiedDays/365.25
CompleteModelAndDetail$UnmodifiedYearsCat<-floor(CompleteModelAndDetail$UnmodifiedYearsFloat)
CompleteModelAndDetail$Dur[CompleteModelAndDetail$UnmodifiedYearsCat<0]<-NA

CompleteModelAndDetail$Dur.Simple<-as.character(CompleteModelAndDetail$Dur)
CompleteModelAndDetail$Dur.Simple[CompleteModelAndDetail$Dur.Simple %in% c(
    "[0 months,~2 months)",
    "[~2 months,~7 months)",
    "[~7 months-~1 year]")]<-"<~1 year"
CompleteModelAndDetail$Dur.Simple<-factor(CompleteModelAndDetail$Dur.Simple,
                                          levels=c("<~1 year",
                                               "(~1 year,~2 years]",
                                               "(~2 years+]"),
                                   ordered=TRUE
                                   )

CompleteModelAndDetail$Ceil.Simple<-as.character(CompleteModelAndDetail$Ceil)

CompleteModelAndDetail$Ceil.Simple[CompleteModelAndDetail$Ceil.Simple %in% c(
    "75m+",
    "10m - <75m")]<-"10m+"
CompleteModelAndDetail$Ceil.Simple[CompleteModelAndDetail$Ceil.Simple %in% c(
    "1m - <10m",
    "100k - <1m")]<-"100k - <10m"
CompleteModelAndDetail$Ceil.Simple[CompleteModelAndDetail$Ceil.Simple %in% c(
    "15k - <100k",
    "0 - <15k")]<-"0k - <100k"
CompleteModelAndDetail$Ceil.Simple<-factor(CompleteModelAndDetail$Ceil.Simple,
       levels=c("0k - <100k",
                "100k - <10m",
                "10m+"),
       ordered=TRUE
       )


CompleteModelAndDetail$Ceil.Big<-as.character(CompleteModelAndDetail$Ceil)

CompleteModelAndDetail$Ceil.Big[CompleteModelAndDetail$Ceil.Big %in% c(
    "100k - <1m",
    "15k - <100k",
    "0 - <15k")]<-"0k - <1m"

CompleteModelAndDetail$Ceil.Big<-factor(CompleteModelAndDetail$Ceil.Big,
       levels=c("0k - <1m",
                "1m - <10m",
                "10m - <75m",
                "75m+"),
       ordered=TRUE
       )


CompleteModelAndDetail$pNewWork3Sig<-round(
  CompleteModelAndDetail$pNewWorkUnmodifiedBaseAndAll,3)
CompleteModelAndDetail$pChange3Sig<-round(
  CompleteModelAndDetail$pChangeOrderUnmodifiedBaseAndAll,3)
```

**A histogram of the data** showing the distribution of the number of change orders each year from 2007.


```r
  NChgCeil<-ddply(CompleteModelAndDetail,
               .(SumOfisChangeOrder,
                 StartFiscalYear,
                 Ceil),
               plyr::summarise,
               ContractCount=length(CSIScontractID),
               Action.Obligation=sum(Action.Obligation))

NChgCeil<-ddply(NChgCeil, 
                .(Ceil), 
                transform, 
                pContractByCeil=ContractCount/sum(ContractCount),
                pObligationByCeil=Action.Obligation/sum(Action.Obligation))

NChgCeil$pTotalObligation<-NChgCeil$Action.Obligation/sum(NChgCeil$Action.Obligation,na.rm=TRUE)
NChgCeil$pTotalContract<-NChgCeil$ContractCount/sum(NChgCeil$ContractCount,na.rm=TRUE)
```


```r
ggplot(
  data = subset(NChgCeil,SumOfisChangeOrder>0),
  aes_string(x = "SumOfisChangeOrder")
  ) + geom_bar(binwidth=1) + 
    facet_grid( Ceil ~ .,
                scales = "free_y",
                space = "free_y") + scale_y_continuous(expand = c(0,50)) +scale_x_continuous(limits=c(0,10))
```

```
## Warning: `geom_bar()` no longer has a `binwidth` parameter. Please use
## `geom_histogram()` instead.
```

```
## Warning: Removed 794 rows containing non-finite values (stat_bin).
```

![](Contract_CeilingBreaches_files/figure-html/ChangeOrderGraphs-1.png)<!-- -->

```r
ggplot(
  data = subset(NChgCeil,SumOfisChangeOrder>0),
  aes_string(x = "Ceil",weight="ContractCount"),
  main="Number of Contracts with Change Orders\nBy Initial Contract Ceiling")+ 
  geom_bar()+
    scale_x_discrete("Initial Cost Ceiling (Current $ Value)")+scale_y_continuous("Number of Contracts with Change Orders")+theme(axis.text.x=element_text(angle=90))
```

![](Contract_CeilingBreaches_files/figure-html/ChangeOrderGraphs-2.png)<!-- -->

```r
ggplot(
  data = subset(NChgCeil,SumOfisChangeOrder>0),
  aes_string(x = "Ceil",weight="pContractByCeil"),
  main="Percentage of Contracts going to Contracts with Change Orders\nBy Initial Contract Ceiling")+ geom_bar()+ scale_y_continuous("Percent of Contracts with Change Orders", labels=percent)+
    scale_x_discrete("Initial Cost Ceiling (Current $ Value)")+theme(axis.text.x=element_text(angle=90))
```

![](Contract_CeilingBreaches_files/figure-html/ChangeOrderGraphs-3.png)<!-- -->

```r
ggplot(
  data =subset(NChgCeil,SumOfisChangeOrder>0),
  aes_string(x = "Ceil",weight="pObligationByCeil"),
  main="Percentage of Contract Obligations going to Contracts with Change Orders\nBy Initial Contract Ceiling"
  )+ geom_bar()+ scale_y_continuous("Percent of Obligations in Cost Ceiling Category", labels=percent)+
    scale_x_discrete("Initial Cost Ceiling (Current $ Value)")+theme(axis.text.x=element_text(angle=90))
```

![](Contract_CeilingBreaches_files/figure-html/ChangeOrderGraphs-4.png)<!-- -->

```r
ggplot(
  data = subset(NChgCeil,SumOfisChangeOrder>0),
  aes_string(x = "Ceil",weight="Action.Obligation")
  )+ geom_bar()+
    scale_x_discrete("Initial Cost Ceiling (Current $ Value)")+scale_y_continuous("Total Obligated Value of Contracts with Change Orders")+theme(axis.text.x=element_text(angle=90))
```

![](Contract_CeilingBreaches_files/figure-html/ChangeOrderGraphs-5.png)<!-- -->

```r
sum(subset(NChgCeil,SumOfisChangeOrder>0)$pTotalObligation)
```

```
## [1] 0.3954099
```

```r
sum(subset(NChgCeil,SumOfisChangeOrder>0)$pTotalContract)
```

```
## [1] 0.02841951
```

## Costly Change Orders Potential Change Cost 

###Size of change orders measured by raise of ceiling

This study uses changes in the *Base and All Options Value Amount* as a way of tracking the potential cost of change orders.

* The *Base and All Options Value Amount* refers to the ceiling of contract costs if all available options were exercised. 
* The *Base and Exercised Value Amount* is not used because contracts are often specified such that the bulk of the eventually executed contract in dollar terms are treated as options.  In these cases, the all-inclusive value provides a better baseline for tracking growth.  
* The *Action Obligation* refers to the actual amount transferred to vendors.  This study team does not use this value because spending for change orders are not necessarily front-loaded.  For example, a change to a contract in May of 2010 could easily result in payments from May 2010 through August 2013.

The % Growth in Base and All Options Value Amount form Change Orders is calculated as follows: 

*Base and All Options Value Amount* increases for all Change Order Modifications/
*Base and All Options Value Amount* from the original unmodified contract transaction


**A histogram of the data** showing the distribution of the initial amount of the specific change order 



```r
pChgCeil<-ddply(CompleteModelAndDetail,
             .(pChange3Sig,
               StartFiscalYear,
               Ceil),
             plyr::summarise,
             ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation))

pChgCeil<-ddply(pChgCeil, 
                .(Ceil), 
                transform, 
                pContractByCeil=ContractCount/sum(ContractCount),
                pObligationByCeil=Action.Obligation/sum(Action.Obligation))

pChgCeil<-ddply(pChgCeil, 
                .(StartFiscalYear), 
                transform, 
                pContractByFYear=ContractCount/sum(ContractCount),
                pObligationByFYear=Action.Obligation/sum(Action.Obligation))

pChgCeil$pChange3Sig[pChgCeil$pChange3Sig==-Inf]<-NA
pChgCeil$pChange3Sig[pChgCeil$pChange3Sig==Inf]<-NA

pChgCeilAverage<-ddply(pChgCeil,
                .(Ceil),
                plyr::summarise,
                mean = wtd.mean(pChange3Sig,ContractCount),
                sd   = sqrt(wtd.var(pChange3Sig,ContractCount))
                # se   = sd / sqrt(ContractCount)
                )




pChgCeil$pTotalObligation<-pChgCeil$Action.Obligation/sum(NChgCeil$Action.Obligation,na.rm=TRUE)
pChgCeil$pTotalContract<-pChgCeil$ContractCount/sum(NChgCeil$ContractCount,na.rm=TRUE)

pChgCeil$CRai <- cut2(
    pChgCeil$pChange3Sig,c(
                                              -0.001,
                                              0.001,
                                              0.15)
    )
```


```r
ggplot(
  data = pChgCeil,
  aes_string(x = "pChange3Sig",
             weights = "ContractCount")
  ) + geom_histogram(binwidth=0.01) +
    facet_grid( Ceil ~ .,
                scales = "free_y",
                space = "free_y") +
    scale_y_log10("Number of Contracts")+
    scale_x_continuous("Percentage of Cost-Ceiling-Raising Change Orders b
                       y\nInitial Cost Ceiling (Current $ Value)",
                       limits=c(-1.25,1.25), labels=percent)+
    theme(axis.text.x=element_text(angle=90,size=1))+
  geom_vline(data=pChgCeilAverage,aes(xintercept=mean),color="red")
```

```
## Warning: Removed 10128 rows containing non-finite values (stat_bin).
```

```
## Warning: Transformation introduced infinite values in continuous y-axis
```

```
## Warning: Removed 221 rows containing missing values (geom_bar).
```

```
## Warning: Removed 2 rows containing missing values (geom_vline).
```

![](Contract_CeilingBreaches_files/figure-html/CeilingBreachGraphs-1.png)<!-- -->

```r
# ggplot(
#   data = subset(pChgCeil,is.numeric(pChange3Sig)&is.finite(pChange3Sig)),
#   aes_string(y = "pChange3Sig")
#   ) + geom_boxplot() 

ggplot(
  data = subset(pChgCeil,is.finite(pChange3Sig)&
                  !is.na(pChange3Sig)&StartFiscalYear>2007&StartFiscalYear<=2014&pChange3Sig!=0),
  aes(y = pChange3Sig,x=factor(StartFiscalYear),
             weight = ContractCount)
  ) + geom_violin() + 
    facet_grid( Ceil ~ .) +
    # scale_y_log10("Number of Contracts",limits=c(-1.25,1.25))+
     scale_y_continuous(
       "Cost-Ceiling-Raising Change Orders Percent (Current $ Value)",
                       limits=c(-0.05,0.05), labels=percent)
```

```
## Warning: Removed 42319 rows containing non-finite values (stat_ydensity).
```

```
## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density

## Warning in density.default(x, weights = w, bw = bw, adjust = adjust, kernel
## = kernel, : sum(weights) != 1 -- will not get true density
```

![](Contract_CeilingBreaches_files/figure-html/CeilingBreachGraphs-2.png)<!-- -->

```r
    # theme(axis.text.x=element_text(angle=90,size=1))



ggplot(
  data = subset(pChgCeil,is.finite(pChange3Sig)&
                  !is.na(pChange3Sig)&StartFiscalYear>2007&StartFiscalYear<=2014),
  aes(y = pChange3Sig,x=factor(StartFiscalYear),
             weight = ContractCount)
  ) + geom_boxplot(outlier.shape = NA,notch=TRUE) + 
    facet_grid( Ceil ~ .) +
    # scale_y_log10("Number of Contracts",limits=c(-1.25,1.25))+
     scale_y_continuous(
       "Cost-Ceiling-Raising Change Orders Percent (Current $ Value)",
                       limits=c(-0.05,0.05), labels=percent)
```

```
## Warning: Removed 42319 rows containing non-finite values (stat_boxplot).
```

![](Contract_CeilingBreaches_files/figure-html/CeilingBreachGraphs-3.png)<!-- -->

```r
    # theme(axis.text.x=element_text(angle=90,size=1))


# Percent of Contracts breakdown by StartYear
ggplot(
  data = subset(pChgCeil,
                StartFiscalYear>=2007 & 
                  StartFiscalYear<=2015 &
                  pChange3Sig!=0),
  aes_string(x = "pChange3Sig",
             weight="pContractByFYear")
  ) + geom_histogram(binwidth=0.01) +
  scale_x_continuous("Percentage of Cost-Ceiling-Raising Change Orders b
                       y\nInitial Cost Ceiling (Current $ Value)",
                       limits=c(-1.25,1.25), labels=percent)+
  scale_y_continuous()+
  facet_wrap("StartFiscalYear")
```

```
## Warning: Removed 10097 rows containing non-finite values (stat_bin).
```

![](Contract_CeilingBreaches_files/figure-html/CeilingBreachGraphs-4.png)<!-- -->

```r
# Percent of Contracts breakdown by Ceiling
ggplot(
  data = subset(pChgCeil,pChange3Sig!=0),
  aes_string(x = "pChange3Sig",weight="pContractByCeil",fill="CRai")#
  )+ geom_histogram(binwidth=0.05)+
#     scale_x_continuous("Percentage of Cost-Ceiling-Raising Change Orders by\nInitial Cost Ceiling (Current $ Value)")
    scale_y_continuous("Percent of Contracts", labels=percent)+
        facet_grid( . ~ Ceil )+scale_x_continuous("Extent of Ceiling Breach in 5% Increments",limits=c(-0.5,1), labels=percent)+theme(axis.text.x=element_text(angle=90),legend.position="bottom")+scale_fill_discrete(name="Extent of Ceiling Breach")
```

```
## Warning: Removed 19065 rows containing non-finite values (stat_bin).
```

![](Contract_CeilingBreaches_files/figure-html/CeilingBreachGraphs-5.png)<!-- -->

```r
tapply(pChgCeil$pChange3Sig, pChgCeil$Ceil, summary)
```

```
## $`75m+`
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
##  -3.313   0.003   0.048   1.135   0.154 790.700 
## 
## $`10m - <75m`
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
## -8.2840 -0.0070  0.0730  0.3392  0.2480 61.1900 
## 
## $`1m - <10m`
##      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
##   -75.600    -0.052     0.142     5.106     0.474 28500.000 
## 
## $`100k - <1m`
##      Min.   1st Qu.    Median      Mean   3rd Qu.      Max. 
##    -109.2      -0.1       0.2     189.4       0.7 2316000.0 
## 
## $`15k - <100k`
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
##  -1291.0     -0.3      0.2     23.2      0.8 354500.0 
## 
## $`0 - <15k`
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
##   -60650        0        0     2497        1 20440000       26
```

```r
#Percent of obligations breakdown
ggplot(
  data = subset(pChgCeil,pChange3Sig!=0),
  aes_string(x = "pChange3Sig",weight="pTotalObligation",fill="CRai")#
  )+ geom_bar(binwidth=0.01)+
#     scale_x_continuous("Percentage of Obligations  by\nInitial Cost Ceiling (Current $ Value)")
    scale_y_continuous("Percent of Completed Contracts\n(Weighted by Current $ Obligations)", labels=percent)+
       # facet_grid( . ~ Term )+
    scale_x_continuous("Extent of Ceiling Breach \n(Percent Change in Current $ Value in 1% Increments)",labels=percent,limits=c(-0.5,1))+
    coord_cartesian(xlim=c(-0.5,1))+ theme(axis.text.x=element_text(angle=90),legend.position="bottom")+
    scale_fill_discrete(name="Extent of Ceiling Breach")
```

```
## Warning: `geom_bar()` no longer has a `binwidth` parameter. Please use
## `geom_histogram()` instead.
```

```
## Warning: Removed 19065 rows containing non-finite values (stat_bin).
```

![](Contract_CeilingBreaches_files/figure-html/CeilingBreachGraphs-6.png)<!-- -->

```r
tapply(pChgCeil$CRai, pChgCeil$Ceil, summary)
```

```
## $`75m+`
## [-6.06e+04,-1.00e-03) [-1.00e-03, 1.00e-03) [ 1.00e-03, 1.50e-01) 
##                   170                    21                   437 
## [ 1.50e-01, 2.04e+07] 
##                   217 
## 
## $`10m - <75m`
## [-6.06e+04,-1.00e-03) [-1.00e-03, 1.00e-03) [ 1.00e-03, 1.50e-01) 
##                   680                    26                   935 
## [ 1.50e-01, 2.04e+07] 
##                   900 
## 
## $`1m - <10m`
## [-6.06e+04,-1.00e-03) [-1.00e-03, 1.00e-03) [ 1.00e-03, 1.50e-01) 
##                  2098                    30                  1270 
## [ 1.50e-01, 2.04e+07] 
##                  3280 
## 
## $`100k - <1m`
## [-6.06e+04,-1.00e-03) [-1.00e-03, 1.00e-03) [ 1.00e-03, 1.50e-01) 
##                  4328                    34                  1334 
## [ 1.50e-01, 2.04e+07] 
##                  6646 
## 
## $`15k - <100k`
## [-6.06e+04,-1.00e-03) [-1.00e-03, 1.00e-03) [ 1.00e-03, 1.50e-01) 
##                  6618                    30                  1337 
## [ 1.50e-01, 2.04e+07] 
##                  8388 
## 
## $`0 - <15k`
## [-6.06e+04,-1.00e-03) [-1.00e-03, 1.00e-03) [ 1.00e-03, 1.50e-01) 
##                  6728                    35                  1340 
## [ 1.50e-01, 2.04e+07]                  NA's 
##                 10673                    26
```

```r
sum(subset(pChgCeil,pChange3Sig>0)$pTotalObligation)
```

```
## [1] 0.2615659
```




```r
# BreachSummary<-ddply(CompleteModelAndDetail,
#                      .(Ceil,
#                        pChange3Sig,
#                        SumOfisChangeOrder,
#                        CRai,
#                        Term),
#                      summarise,
#                      pContractByCeil=sum(pContractByCeil),
#                      pObligationByCeil=sum(pObligationByCeil),
#                      pTotalObligation=sum(pTotalObligation))
# 
# 
# 
# ddply(pChgCeil,.(Term,CRai),
#                      summarise,
#                      pTotalObligation=sum(pTotalObligation))
```



```r
df.QCrai<-ddply(subset(CompleteModelAndDetail,
                                        !is.na(Dur) & 
               !is.na(Ceil) &
               !is.na(CRai) &
               StartFiscalYear>=2007 & 
               StartFiscalYear<=2014 &                
               (LastCurrentCompletionDate<=as.Date("2015-09-30") |
                    IsClosed==1) &
               UnmodifiedCurrentCompletionDate<as.Date("2015-09-30")),
      .(StartFiscalYear,
               Ceil,
               Dur),
      summarise, 
      X50 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.5,na.rm=TRUE),
      X75 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.75,na.rm=TRUE), 
      X80 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.80,na.rm=TRUE), 
      X90 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.90,na.rm=TRUE), 
      X95 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.95,na.rm=TRUE),
      X99 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.99,na.rm=TRUE),
      ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation),
      metric="Contracts within Period")



df.QCrai<-rbind(df.QCrai,
                ddply(subset(CompleteModelAndDetail,
                                               !is.na(Dur) & 
                                               !is.na(Ceil) &
                                               !is.na(CRai) &
                                               StartFiscalYear>=2007 & 
                                               StartFiscalYear<=2014),
      .(StartFiscalYear,
               Ceil,
               Dur),
      summarise, 
      X50 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.5,na.rm=TRUE),
      X75 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.75,na.rm=TRUE), 
      X80 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.80,na.rm=TRUE), 
      X90 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.90,na.rm=TRUE), 
      X95 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.95,na.rm=TRUE),
      X99 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.99,na.rm=TRUE),
      ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation),
      metric="Early Results for All Contracts")
)

df.QCrai<-melt(df.QCrai,variable.name="Quantile",value.name="pCRai",measure.vars=c(
  "X50",
  "X75",
  "X80",
  "X90",
  "X95",
  "X99")
)

ggplot(df.QCrai,
       aes(x=StartFiscalYear,y=pCRai,color=Quantile))+
  geom_line()+
  facet_grid(Ceil~Dur)
```

![](Contract_CeilingBreaches_files/figure-html/Quantile-1.png)<!-- -->

```r
ggplot(subset(df.QCrai,
                !Quantile %in% c("X99")),
       aes(x=StartFiscalYear,y=pCRai,color=Quantile))+
  geom_line()+
  facet_grid(Ceil~Dur,
             scales="free_y",
             space="free_y")+
  scale_y_continuous(labels=percent)
```

![](Contract_CeilingBreaches_files/figure-html/Quantile-2.png)<!-- -->

```r
#Test to see which percentiles register at all.
df.ecdf<-ddply(CompleteModelAndDetail,
      .(Ceil,
               Dur),
      summarise, 
      r001 = ecdf(pChangeOrderUnmodifiedBaseAndAll)(0.001),
      r01 = ecdf(pChangeOrderUnmodifiedBaseAndAll)(0.01),
      r05 = ecdf(pChangeOrderUnmodifiedBaseAndAll)(0.01)
)

# df.ecdf<-subset(df.ecdf,StartFiscalYear>=2007&StartFiscalYear<=2014)

# test<-tapply(CompleteModelAndDetail, pChangeOrderUnmodifiedBaseAndAll, ecdf)
```



```r
df.QCrai.SDur<-ddply(subset(CompleteModelAndDetail,
                                        !is.na(Dur.Simple) & 
               !is.na(Ceil.Big) &
               !is.na(CRai) &
               StartFiscalYear>=2007 & 
               StartFiscalYear<=2014 &                
               (LastCurrentCompletionDate<=as.Date("2015-09-30") |
                    IsClosed==1) &
               UnmodifiedCurrentCompletionDate<as.Date("2015-09-30")),
      .(StartFiscalYear,
               Ceil.Big,
               Dur.Simple),
      summarise, 
      X50 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.5,na.rm=TRUE),
      X75 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.75,na.rm=TRUE), 
      X80 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.80,na.rm=TRUE), 
      X90 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.90,na.rm=TRUE), 
      X95 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.95,na.rm=TRUE),
      X99 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.99,na.rm=TRUE),
      ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation),
      metric="Contracts within Period")



df.QCrai.SDur<-rbind(df.QCrai.SDur,
                ddply(subset(CompleteModelAndDetail,
                                               !is.na(Dur.Simple) & 
                                               !is.na(Ceil.Big) &
                                               !is.na(CRai) &
                                               StartFiscalYear>=2007 & 
                                               StartFiscalYear<=2014),
      .(StartFiscalYear,
               Ceil.Big,
               Dur.Simple),
      summarise, 
      X50 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.5,na.rm=TRUE),
      X75 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.75,na.rm=TRUE), 
      X80 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.80,na.rm=TRUE), 
      X90 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.90,na.rm=TRUE), 
      X95 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.95,na.rm=TRUE),
      X99 = quantile(pChangeOrderUnmodifiedBaseAndAll, probs = 0.99,na.rm=TRUE),
      ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation),
      metric="Early Results for All Contracts")
)


df.QCrai.SDur<-melt(df.QCrai.SDur,
                      variable.name="Quantile",value.name="pCRai",measure.vars=c(
  "X50",
  "X75",
  "X80",
  "X90",
  "X95",
  "X99")
)

df.QCrai.SDur$Quantile<-factor(df.QCrai.SDur$Quantile,
  levels=c("X50",
  "X75",
  "X80",
  "X90",
  "X95",
  "X99"),
  labels=c("50th Percentile",
  "75th Percentile",
  "80th Percentile",
  "90th Percentile",
  "95th Percentile",
  "99th Percentile")
)

CRaiSDurCeilLabels<-ddply(
  subset(df.QCrai.SDur,Quantile=="50th Percentile" &
           metric=="Contracts within Period"),
    .(Dur.Simple,Ceil.Big),
    plyr::summarise,
    FacetCount=paste("Count:",prettyNum(sum(ContractCount),big.mark=",")),
    FacetValue=paste(FacetCount,"\nObligated: $",round(sum(Action.Obligation)/1000000000,1),"B",sep="")
    )

Ypos<-max(subset(df.QCrai.SDur,
                   !Quantile %in% c("99th Percentile")
                 )$pCRai,na.rm=TRUE)


CRaiOutput<-ggplot(subset(df.QCrai.SDur,
                !Quantile %in% c("99th Percentile",
                                 "75th Percentile")),
       aes(x=StartFiscalYear,y=pCRai,color=Quantile))+
  geom_line(aes(linetype=metric))+
  geom_point(aes(shape=Quantile))+
  geom_text(data=CRaiSDurCeilLabels,
              aes(x=2007,y=Ypos,label=FacetValue),
              # parse=TRUE,
              hjust=0,
              vjust=1,
              color="black")+
  facet_grid(Dur.Simple~Ceil.Big)+
               scale_y_continuous("Cost-Ceiling-Raising Change Orders Percent (Current $ Value)",
                                  labels=percent)+
  scale_x_continuous("Contract Starting Fiscal Year")+
  scale_linetype_discrete("Early Results")+
  theme(legend.position="bottom") #, position=pd

CRaiOutput
```

![](Contract_CeilingBreaches_files/figure-html/QuantileSimpleDur-1.png)<!-- -->

```r
ggsave("CRaiOutput.png",
       CRaiOutput,
       width=8,
       height=7,
       dpi=600)

ggplot(subset(df.QCrai.SDur,
                # !Quantile %in% c("99th Percentile")
                !Ceil.Big %in% c("15k - <100k","0 - <15k")
              ),
       aes(x=StartFiscalYear,
           y=pCRai,
           color=Quantile))+
  geom_line(aes(linetype=metric))+
  facet_grid(Ceil.Big~Dur.Simple,
             scales="free_y",
             space="free_y")+
  scale_y_continuous(labels=percent)
```

![](Contract_CeilingBreaches_files/figure-html/QuantileSimpleDur-2.png)<!-- -->

```r
#Test to see which percentiles register at all.
df.ecdf<-ddply(CompleteModelAndDetail,
      .(Ceil.Big,
               Dur.Simple),
      summarise, 
      r001 = ecdf(pChangeOrderUnmodifiedBaseAndAll)(0.001),
      r01 = ecdf(pChangeOrderUnmodifiedBaseAndAll)(0.01),
      r05 = ecdf(pChangeOrderUnmodifiedBaseAndAll)(0.01)
)

# df.ecdf<-subset(df.ecdf,StartFiscalYear>=2007&StartFiscalYear<=2014)


CRaiSDurCeilFYearSummary<-ddply(
  subset(df.QCrai.SDur,Quantile=="50th Percentile" &
           metric=="Contracts within Period"),
    .(Dur.Simple,Ceil.Big,StartFiscalYear),
    plyr::summarise,
    FacetCount=paste("Count:",prettyNum(sum(ContractCount),big.mark=",")),
    FacetValue=paste(FacetCount,"\nObligated: $",round(sum(Action.Obligation)/1000000000,1),"B",sep="")
    )

DurBoundary<-subset(CompleteModelAndDetail,Ceil=="75m+"&
         Dur=="(~2 years+]"&
         StartFiscalYear==2013&
         UnmodifiedCurrentCompletionDate<as.Date("2015-09-30")
         )
```



```r
df.QNWork.SDur<-ddply(subset(CompleteModelAndDetail,
                                        !is.na(Dur.Simple) & 
               !is.na(Ceil.Big) &
               !is.na(pNewWorkUnmodifiedBaseAndAll) &
               StartFiscalYear>=2007 & 
               StartFiscalYear<=2014 &                
               (LastCurrentCompletionDate<=as.Date("2015-09-30") |
                    IsClosed==1) &
               UnmodifiedCurrentCompletionDate<as.Date("2015-09-30")),
      .(StartFiscalYear,
               Ceil.Big,
               Dur.Simple),
      summarise, 
      X50 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.5,na.rm=TRUE),
      X75 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.75,na.rm=TRUE), 
      X80 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.80,na.rm=TRUE), 
      X90 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.90,na.rm=TRUE), 
      X95 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.95,na.rm=TRUE),
      X99 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.99,na.rm=TRUE),
      ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation),
      metric="Contracts within Period")



df.QNWork.SDur<-rbind(df.QNWork.SDur,
                ddply(subset(CompleteModelAndDetail,
                                               !is.na(Dur.Simple) & 
                                               !is.na(Ceil.Big) &
                                               !is.na(pNewWorkUnmodifiedBaseAndAll) &
                                               StartFiscalYear>=2007 & 
                                               StartFiscalYear<=2014),
      .(StartFiscalYear,
               Ceil.Big,
               Dur.Simple),
      summarise, 
      X50 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.5,na.rm=TRUE),
      X75 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.75,na.rm=TRUE), 
      X80 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.80,na.rm=TRUE), 
      X90 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.90,na.rm=TRUE), 
      X95 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.95,na.rm=TRUE),
      X99 = quantile(pNewWorkUnmodifiedBaseAndAll, probs = 0.99,na.rm=TRUE),
      ContractCount=length(CSIScontractID),
             Action.Obligation=sum(Action.Obligation),
      metric="Early Results for All Contracts")
)


df.QNWork.SDur<-melt(df.QNWork.SDur,
                      variable.name="Quantile",value.name="pNWork",measure.vars=c(
  "X50",
  "X75",
  "X80",
  "X90",
  "X95",
  "X99")
)

df.QNWork.SDur$Quantile<-factor(df.QNWork.SDur$Quantile,
  levels=c("X50",
  "X75",
  "X80",
  "X90",
  "X95",
  "X99"),
  labels=c("50th Percentile",
  "75th Percentile",
  "80th Percentile",
  "90th Percentile",
  "95th Percentile",
  "99th Percentile")
)

NWorkSDurCeilLabels<-ddply(
  subset(df.QNWork.SDur,Quantile=="50th Percentile" &
           metric=="Contracts within Period"),
    .(Dur.Simple,Ceil.Big),
    plyr::summarise,
    FacetCount=paste("Count:",prettyNum(sum(ContractCount),big.mark=",")),
    FacetValue=paste(FacetCount,"\nObligated: $",round(sum(Action.Obligation)/1000000000,1),"B",sep="")
    )

Ypos<-max(subset(df.QNWork.SDur,
                   !Quantile %in% c("99th Percentile")
                 )$pNWork,na.rm=TRUE)


NWorkOutput<-ggplot(subset(df.QNWork.SDur,
                !Quantile %in% c("99th Percentile",
                                 "75th Percentile")),
       aes(x=StartFiscalYear,y=pNWork,color=Quantile))+
  geom_line(aes(linetype=metric))+
  geom_point(aes(shape=Quantile))+
  geom_text(data=NWorkSDurCeilLabels,
              aes(x=2007,y=Ypos,label=FacetValue),
              # parse=TRUE,
              hjust=0,
              vjust=1,
              color="black")+
  facet_grid(Dur.Simple~Ceil.Big)+
               scale_y_continuous("New Work Orders Percent (Current $ Value)",
                                  labels=percent)+
  scale_x_discrete("Contract Starting Fiscal Year")+
  scale_linetype_discrete("Early Results")+
  theme(legend.position="bottom") #, position=pd

NWorkOutput
```

![](Contract_CeilingBreaches_files/figure-html/NewWorkQuantileSimpleDur-1.png)<!-- -->

```r
ggplot(subset(df.QNWork.SDur,
                # !Quantile %in% c("99th Percentile")
                !Ceil.Big %in% c("15k - <100k","0 - <15k")
              ),
       aes(x=StartFiscalYear,
           y=pNWork,
           color=Quantile))+
  geom_line(aes(linetype=metric))+
  facet_grid(Ceil.Big~Dur.Simple,
             scales="free_y",
             space="free_y")+
  scale_y_continuous(labels=percent)
```

![](Contract_CeilingBreaches_files/figure-html/NewWorkQuantileSimpleDur-2.png)<!-- -->

```r
#Test to see which percentiles register at all.
df.ecdf<-ddply(CompleteModelAndDetail,
      .(Ceil.Big,
               Dur.Simple),
      summarise, 
      r001 = ecdf(pNewWorkUnmodifiedBaseAndAll)(0.001),
      r01 = ecdf(pNewWorkUnmodifiedBaseAndAll)(0.01),
      r05 = ecdf(pNewWorkUnmodifiedBaseAndAll)(0.01)
)

# df.ecdf<-subset(df.ecdf,StartFiscalYear>=2007&StartFiscalYear<=2014)


NWorkSDurCeilFYearSummary<-ddply(
  subset(df.QNWork.SDur,Quantile=="50th Percentile" &
           metric=="Contracts within Period"),
    .(Dur.Simple,Ceil.Big,StartFiscalYear),
    plyr::summarise,
    FacetCount=paste("Count:",prettyNum(sum(ContractCount),big.mark=",")),
    FacetValue=paste(FacetCount,"\nObligated: $",round(sum(Action.Obligation)/1000000000,1),"B",sep="")
    )

DurBoundary<-subset(CompleteModelAndDetail,Ceil=="75m+"&
         Dur=="(~2 years+]"&
         StartFiscalYear==2013&
         UnmodifiedCurrentCompletionDate<as.Date("2015-09-30")
         )
```
