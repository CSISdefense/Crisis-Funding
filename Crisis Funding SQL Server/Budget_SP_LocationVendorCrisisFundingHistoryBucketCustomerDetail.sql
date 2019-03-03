USE [CSIS360]
GO

/****** Object:  StoredProcedure [budget].[SP_LocationVendorCrisisFundingHistoryBucketCustomer]    Script Date: 9/26/2017 4:56:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
alter procedure [budget].[SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail]

@Customer VARCHAR(255),
@StartFiscalYear smallint


 as 
SELECT [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
	  ,ContractingOfficeID
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
	  ,IsUrgency
	  ,ClassifyNumberOfOffers
	  ,IsOMBocoList
	  ,PSCOCOcrisisScore
	  ,OfficeOCOcrisisScore
	  ,[MajorCommandID]
	  --New Decision tree options
	  ,IsMultipleYearProcRnD
	  ,isforeign
	  ,[ContractCrisisFunding]
      ,[nationalinterestactioncode]
      ,[NIAcrisisFunding]
      ,[CrisisFunding]
      ,[localareasetaside]
	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,ConHumIsOCOcrisisFunding
	  ,CCRexception
	  ,IsOCOcrisisFunding  
	  ,IsARRAcrisisFunding
	  	  ,DecisionTree
	  ,DecisionTreeStep4
	,pscOCOcrisisPoint
	,FundingAccountOCOpoint
	,OfficeOCOcrisisPoint
	  ,round(PercentFundingAccountOCO,2 ) as PercentFundingAccountOCO
	  	  ,round(sqrt(iif(OfficeOCOcrisisPercent<0,0,OfficeOCOcrisisPercent)),2) as OfficeOCOcrisisPercentSqrt
	  ,round(sqrt(iif(pscOCOcrisisPercent<0,0,pscOCOcrisisPercent)),2) as pscOCOcrisisPercentSqrt
	  
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
      
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
  where (@Customer is null or @Customer=ContractingCustomer)
  and (@StartFiscalYear is null or @StartFiscalYear<=fiscal_year)
  group by [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,[ContractCrisisFunding]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
	  ,ContractingOfficeID
      ,[nationalinterestactioncode]
      ,[NIAcrisisFunding]
	  ,IsOCOcrisisFunding
	  ,IsARRAcrisisFunding
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
	  ,IsUrgency
	  ,ClassifyNumberOfOffers
	  ,IsOMBocoList
	,PSCOCOcrisisScore
	,OfficeOCOcrisisScore
	    ,[MajorCommandID]
			--New Decision tree options
			,IsMultipleYearProcRnD
			  ,isforeign
			  	  	  ,DecisionTree
	  ,DecisionTreeStep4
	  ,round(PercentFundingAccountOCO,2 ) 
	 	  ,round(sqrt(iif(OfficeOCOcrisisPercent<0,0,OfficeOCOcrisisPercent)),2) 
	  ,round(sqrt(iif(pscOCOcrisisPercent<0,0,pscOCOcrisisPercent)),2) 
	  ,[nationalinterestactioncode]	  
	  ,[localareasetaside]
	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,ConHumIsOCOcrisisFunding
	  ,CCRexception
	,pscOCOcrisisPoint
	,FundingAccountOCOpoint
	,OfficeOCOcrisisPoint
GO


