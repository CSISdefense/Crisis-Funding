/****** Script for SelectTopNRows command from SSMS  ******/
alter procedure Budget.SP_LocationVendorCrisisFundingHistoryBucketCustomer

@Customer VARCHAR(255),
@StartFiscalYear smallint


 as f

 
 --Invesitgate the reliability of ContingencyHumanitarianPeacekeepingOperation
SELECT [fiscal_year]
,ContractingCustomer
      --,[ProductOrServiceArea]
	  --,ProductOrServiceCode
	  --,ProductOrServiceCodeText
	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,contingencyhumanitarianpeacekeepingoperationText
	  ,NIAcrisisFunding
	  ,nationalinterestactioncode
	  ,nationalinterestactioncodeText
	  ,CrisisFunding
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
      
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomer]
  WHERE IsOCOcrisisFunding=1 
  group by [fiscal_year]
      --,[ProductOrServiceArea]
	  ,ContractingCustomer
	  ,NIAcrisisFunding
	  ,nationalinterestactioncode
	  ,nationalinterestactioncodeText
	  	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,contingencyhumanitarianpeacekeepingoperationText
	  ,CrisisFunding

 --Product or service codes for Contingency Contracts
SELECT [fiscal_year]
,ContractingCustomer
      ,[ProductOrServiceArea]
	  ,ProductOrServiceCode
	  ,ProductOrServiceCodeText
	  ,IsOCOcrisisFunding
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomer]
  group by [fiscal_year]
,ContractingCustomer
      ,[ProductOrServiceArea]
	  ,ProductOrServiceCode
	  ,ProductOrServiceCodeText
	  ,IsOCOcrisisFunding

 --Main run
SELECT [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,[ContractCrisisFunding]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
      ,[nationalinterestactioncodeText]
      ,[NIAcrisisFunding]
      ,[CrisisFunding]
	  ,[CrisisFundingTheater]
      ,[PlaceCountryText]
      ,[VendorCountryText]
	  ,[VendorPlaceType]
	  ,[VendorSize]
	  ,UnmodifiedUltimateDurationCategory
	  ,OMBagencycode
	  ,OMBbureaucode
	  , treasuryagencycode
	  , mainaccountcode
	  , subaccountcode
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
      
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomer]
  where (@Customer is null or @Customer=ContractingCustomer)
  and (@StartFiscalYear is null or @StartFiscalYear<=fiscal_year)
  group by [fiscal_year]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,[ContractCrisisFunding]
	  ,ContractingCustomer
	  ,ContractingSubCustomer
      ,[nationalinterestactioncodeText]
      ,[NIAcrisisFunding]
      ,[CrisisFunding]
	  ,CrisisFundingTheater
      ,[PlaceCountryText]
      ,[VendorCountryText]
	  ,[VendorPlaceType]
	  ,[VendorSize]
	  ,UnmodifiedUltimateDurationCategory
	  ,OMBagencycode
	  ,OMBbureaucode
	  , treasuryagencycode
	  , mainaccountcode
	  , subaccountcode