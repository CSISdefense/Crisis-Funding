USE [CSIS360]
GO

/****** Object:  StoredProcedure [budget].[SP_CrisisFundingExploration]    Script Date: 9/26/2017 5:55:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
alter procedure Budget.SP_CrisisFundingExploration

@Customer VARCHAR(255),
@StartFiscalYear smallint


 as 

 
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
      
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
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
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
  group by [fiscal_year]
,ContractingCustomer
      ,[ProductOrServiceArea]
	  ,ProductOrServiceCode
	  ,ProductOrServiceCodeText
	  ,IsOCOcrisisFunding


 --Product or service codes for Contingency Contracts
update psc
set OCOcrisisPercent=cast(OCOamount2016 as decimal(19,4))/
		cast(nullif([obligatedAmount2016],0) as decimal(19,4))
from FPDSTypeTable.ProductOrServiceCode psc
inner join (SELECT ProductOrServiceCode
      ,sum([obligatedAmount]/d.GDPdeflator2016) as [obligatedAmount2016]
      ,sum(iif(IsOCOcrisisFunding=1,
		[obligatedAmount],
		0)/d.GDPdeflator2016) as OCOamount2016
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification] as lv
  left outer join Economic.Deflators d 
	on lv.fiscal_year=d.Fiscal_Year
	where lv.fiscal_year>=2000
	and (lv.ContractingCustomer = 'Defense'
	or lv.FundingAgency='Defense')
  group by ProductOrServiceCode
  ) as l
  on psc.ProductOrServiceCode=l.productorservicecode



  

 --Contracting office codes for Contingency Contracts
update coo
set OCOcrisisPercent=cast(OCOamount2016 as decimal(19,4))/
		cast(nullif([GrossObligatedAmount2016],0) as decimal(19,4))
, CrisisPercent=cast(CrisisAmount2016 as decimal(19,4))/
		cast(nullif([GrossObligatedAmount2016],0) as decimal(19,4))
, PlaceIntlPercent=cast(PlaceIntl2016 as decimal(19,4))/
		cast(nullif([GrossObligatedAmount2016],0) as decimal(19,4))
from Office.ContractingOfficeCode coo
inner join (SELECT ContractingOfficeID
      ,sum(iif( [obligatedAmount]>0,[obligatedAmount],0)/d.GDPdeflator2016) as
	   [GrossObligatedAmount2016]
      ,sum(iif(IsOCOcrisisFunding=1 and [obligatedAmount]>0,
		[obligatedAmount],
		0)/d.GDPdeflator2016) as OCOamount2016
	,sum(iif((IsOCOcrisisFunding=1 or
	  IsDisasterCrisisFunding=1 or
	  IsARRAcrisisFunding=1) and [obligatedAmount]>0,
		[obligatedAmount],
		0)/d.GDPdeflator2016) as CrisisAmount2016
	,sum(iif([PlaceIsInternational]=1 and [obligatedAmount]>0,
		[obligatedAmount],
		0)/d.GDPdeflator2016) as PlaceIntl2016
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification] as lv
  left outer join Economic.Deflators d 
	on lv.fiscal_year=d.Fiscal_Year
	where lv.fiscal_year>=2000
	 group by ContractingOfficeID
  ) as l
  on coo.ContractingOfficeCode=l.ContractingOfficeID

  


 --Contracting office codes for Contingency Contracts
update coo
set CrisisPercent=cast(OCOamount2016 as decimal(19,4))/
		cast(nullif([obligatedAmount2016],0) as decimal(19,4))
from Office.ContractingOfficeCode coo
inner join (SELECT ContractingOfficeID
      ,sum([obligatedAmount]/d.GDPdeflator2016) as [obligatedAmount2016]
      ,sum(iif(IsOCOcrisisFunding=1 or
	  IsDisasterCrisisFunding=1 or
	  IsARRAcrisisFunding=1,
		[obligatedAmount],
		0)/d.GDPdeflator2016) as OCOamount2016
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification] as lv
  left outer join Economic.Deflators d 
	on lv.fiscal_year=d.Fiscal_Year
	where lv.fiscal_year>=2000
	 group by ContractingOfficeID
  ) as l
  on coo.ContractingOfficeCode=l.ContractingOfficeID



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
      
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
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