USE [DIIG]
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
	  ,ProductOrServiceCode
	  ,ProductOrServiceCodeText
	  ,[ContractCrisisFunding]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
      ,[nationalinterestactioncodeText]
      ,[NIAcrisisFunding]
	  ,IsOCOcrisisFunding
      ,[CrisisFunding]
	  ,[CrisisFundingTheater]
      ,[PlaceCountryText]
      ,[VendorCountryText]
	  ,[VendorPlaceType]
	  ,[VendorSize]
	  ,UnmodifiedUltimateDurationCategory
	,OMBagencyName
	  ,OMBbureauName
	  , treasuryagencycode
	  , mainaccountcode
	  , subaccountcode
	  , isUndefinitizedAction
	  ,OCOcrisisScore
	  ,CompetitionClassification
	  ,ClassifyNumberOfOffers
	  ,OfficeOCOcrisisScore
	    ,[MajorCommandID]
      ,[ContractingOfficeID]
      ,[ContractingOfficeName]
	  ,ContractingOfficeCity
			,ContractingOfficeState
			,ContractingOfficeCountry
			--New Decision tree options
			,IsMultipleYearProcRnD
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
      
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
  where (@Customer is null or @Customer=ContractingCustomer)
  and (@StartFiscalYear is null or @StartFiscalYear<=fiscal_year)
  group by [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,ProductOrServiceCode
	  ,ProductOrServiceCodeText
	  ,[ContractCrisisFunding]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
      ,[nationalinterestactioncodeText]
      ,[NIAcrisisFunding]
	  ,IsOCOcrisisFunding
      ,[CrisisFunding]
	  ,CrisisFundingTheater
      ,[PlaceCountryText]
      ,[VendorCountryText]
	  ,[VendorPlaceType]
	  ,[VendorSize]
	  ,UnmodifiedUltimateDurationCategory
	,OMBagencyName
	  ,OMBbureauName
	    , treasuryagencycode
	  , mainaccountcode
	  , subaccountcode
	  , isUndefinitizedAction
	  ,OCOcrisisScore
	  ,CompetitionClassification
	  ,ClassifyNumberOfOffers
	  ,OfficeOCOcrisisScore
	  ,OfficeOCOcrisisPercent
	  ,pscOCOcrisisPercent
	  ,IsOMBocoList
	  
	  ,isforeign
	  ,IsOMBocoList
	  ,PercentFundingAccountOCO

	  ,isforeign
	  ,[MajorCommandID]
      ,[ContractingOfficeID]
      ,[ContractingOfficeName]
	  ,ContractingOfficeCity
			,ContractingOfficeState
			,ContractingOfficeCountry
			,IsMultipleYearProcRnD
			,IsDisasterCrisisFunding
			,IsARRAcrisisFunding
GO


