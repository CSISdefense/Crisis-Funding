USE [DIIG]
GO

/****** Object:  StoredProcedure [budget].[SP_LocationVendorCrisisFundingHistoryBucketCustomer]    Script Date: 9/26/2017 4:56:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
alter procedure [budget].[SP_LocationVendorCrisisFundingHistoryBucketCustomer]

@Customer VARCHAR(255),
@StartFiscalYear smallint


 as 
SELECT [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
      ,[PlaceCountryText]
	  ,[CrisisFundingTheater]
	  ,[VendorPlaceType]
	  ,[VendorSize]
	  ,UnmodifiedUltimateDurationCategory
	  ,OMBagencyName
	  ,OMBbureauName
	  , treasuryagencycode
	  , mainaccountcode
	  , isUndefinitizedAction
	  ,OCOcrisisScore
	  ,CompetitionClassification
	  ,ClassifyNumberOfOffers
	  ,PSCOCOcrisisScore
	  ,OfficeOCOcrisisScore
	  ,[MajorCommandID]
	  --New Decision tree options
	  ,IsMultipleYearProcRnD
	  ,isforeign
	  ,IsOMBocoList
	  ,[ContractCrisisFunding]
      ,[nationalinterestactioncode]
      ,[NIAcrisisFunding]
      ,[CrisisFunding]
	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,ConHumIsOCOcrisisFunding
	  ,CCRexception
	  ,localareasetaside
	  ,IsOCOcrisisFunding  
	  --,round(PercentFundingAccountOCO,2 ) as PercentFundingAccountOCO
	  --	  ,round(sqrt(iif(OfficeOCOcrisisPercent<0,0,OfficeOCOcrisisPercent)),2) as OfficeOCOcrisisPercentSqrt
	  --,round(sqrt(iif(pscOCOcrisisPercent<0,0,pscOCOcrisisPercent)),2) as pscOCOcrisisPercentSqrt
	  ,DecisionTree
	  ,DecisionTreeStep4
	,pscOCOcrisisPoint
	,FundingAccountOCOpoint
	,OfficeOCOcrisisPoint
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
      
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
  where (@Customer is null or @Customer=ContractingCustomer)
  and (@StartFiscalYear is null or @StartFiscalYear<=fiscal_year)
  group by [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,[ContractCrisisFunding]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
      ,[nationalinterestactioncode]
      ,[NIAcrisisFunding]
	  ,IsOCOcrisisFunding
      ,[CrisisFunding]
	  ,[CrisisFundingTheater]
      ,[PlaceCountryText]
	  ,[VendorPlaceType]
	  ,[VendorSize]
	  ,UnmodifiedUltimateDurationCategory
	,OMBagencyName
	  ,OMBbureauName
	  , treasuryagencycode
	  , mainaccountcode
	  , isUndefinitizedAction
	  ,OCOcrisisScore
	  ,CompetitionClassification
	  ,ClassifyNumberOfOffers
	,PSCOCOcrisisScore
	,OfficeOCOcrisisScore
	    ,[MajorCommandID]
			--New Decision tree options
			,IsMultipleYearProcRnD
			  ,isforeign
	  ,IsOMBocoList
	  --,round(PercentFundingAccountOCO,2 ) 
	 	--  --,round(sqrt(iif(OfficeOCOcrisisPercent<0,0,OfficeOCOcrisisPercent)),2) 
	  --,round(sqrt(iif(pscOCOcrisisPercent<0,0,pscOCOcrisisPercent)),2) 
	  ,[nationalinterestactioncode]	  
	  ,[localareasetaside]
	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,ConHumIsOCOcrisisFunding
	  ,CCRexception
	  	  ,DecisionTree
	  ,DecisionTreeStep4
	,pscOCOcrisisPoint
	,FundingAccountOCOpoint
	,OfficeOCOcrisisPoint

GO


