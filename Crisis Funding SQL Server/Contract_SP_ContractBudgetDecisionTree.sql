USE [CSIS360]
GO

/****** Object:  StoredProcedure [budget].[SP_LocationVendorCrisisFundingHistoryBucketCustomer]    Script Date: 9/26/2017 4:56:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
ALTER procedure Contract.[SP_ContractBudgetDecisionTree]

@Customer VARCHAR(255),
@StartFiscalYear smallint


 as 
SELECT CSIScontractID
,sum(iif(DecisionTreeStep4='ARRA',GrossObligatedAmount,NULL)) as ARRAstep4grossObligated
,sum(iif(DecisionTreeStep4='OCO',GrossObligatedAmount,NULL)) as OCOstep4grossObligated
,sum(iif(DecisionTreeStep4='Disaster',GrossObligatedAmount,NULL)) as Disasterstep4GrossObligated
,sum(iif(DecisionTreeStep4='Excluded',GrossObligatedAmount,NULL)) as ExcludedStep4GrossObligated

,sum(iif(DecisionTree='ARRA',GrossObligatedAmount,NULL)) as ARRAtransactionGrossObligated
,sum(iif(DecisionTree='OCO',GrossObligatedAmount,NULL)) as OCOtransactionGrossObligated
,sum(iif(DecisionTree='Disaster',GrossObligatedAmount,NULL)) as DisastertransactionGrossObligated
,sum(iif(DecisionTree='Excluded',GrossObligatedAmount,NULL)) as ExcludedtransactionGrossObligated


,sum(iif(DecisionTreeStep4='OCO',1,iif(DecisionTreeStep4='Excluded',0,pscOCOcrisisPercent))*
	isnull(GrossObligatedAmount,0))/sum(GrossObligatedAmount) as pscOCOcrisisMeanPercent
,sum(iif(DecisionTreeStep4='OCO',1,iif(DecisionTreeStep4='Excluded',0,PercentFundingAccountOCO))*
	isnull(GrossObligatedAmount,0))/sum(GrossObligatedAmount) as FundingAccountOCOmeanPercent
,sum(iif(DecisionTreeStep4='OCO',1,iif(DecisionTreeStep4='Excluded',0,OfficeOCOcrisisPercent))*
	isnull(GrossObligatedAmount,0))/sum(GrossObligatedAmount)  as OfficeOCOcrisisMeanPercent

----DecisionTree
--	,case
--	--Step 1A
--	when ContractCrisisFunding is not null 
--	then ContractCrisisFunding
--	when RFisARRA=1
--	then 'ARRA'
--	--Step 1b 
--	when ConHumIsOCOcrisisFunding=1
--	then 'OCO'
--	--Step 1C
--	when NIAcrisisFunding is not null and
--		(nationalinterestactioncode<>'W081' or --Excluding a major ($26 billion mislabelling case)
--		fiscal_year>=2008) 

--	then NIAcrisisFunding 
--	when PlaceCountryText in ('Afghanistan','Iraq')
--	then 'OCO'
--	when l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
--		[UnmodifiedUltimateDuration]> 366
--	then 'Excluded'
--	when pscOCOcrisisScore=-1 or OfficeOCOcrisisScore=-1
--	then 'Excluded'
--Step4C+
--	when (pscOCOcrisisPoint + FundingAccountOCOpoint + OfficeOCOcrisisPoint)>=1 and
--		IsOMBocoList=1
--	then 'OCO'
--	when (pscOCOcrisisPoint + FundingAccountOCOpoint + OfficeOCOcrisisPoint)>=2 and
--		PlaceIsInternational=1
--	then 'OCO'
--	when (pscOCOcrisisPoint + FundingAccountOCOpoint + OfficeOCOcrisisPoint)>=3
--	then 'OCO'
--	else NULL
--	end as DecisionTree
--	--DecisionTree

,sum(GrossObligatedAmount) as GrossObligatedAmount


      
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
  where (@Customer is null or @Customer=ContractingCustomer)
  and (@StartFiscalYear is null or @StartFiscalYear<=fiscal_year)
  group by [CSIScontractID]

GO


