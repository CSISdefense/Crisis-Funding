USE [DIIG]
GO

/****** Object:  View [Contract].[ContractHistoryPBLscoreSubCustomer]    Script Date: 3/29/2017 5:23:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER VIEW [Contract].[ContractHistoryCrisisScore]
AS
SELECT   CSIScontractID
	,fiscal_year
	, nationalinterestactioncodeText
	,iif(NIAcrisisFunding='Disaster' or ContractCrisisFunding='Disaster',1,0) as IsDisasterCrisisFunding
	,iif(NIAcrisisFunding='ARRA' or ContractCrisisFunding='ARRA',1,0) as IsARRAcrisisFunding
	,case 
	--Naitional Intrest Action Code
	when NIAcrisisFunding='OCO'
	then 1
	--Manually labeled contract (not presently used)
	when ContractCrisisFunding='OCO'
	then 1
	--OMB standards 
	--Specifies stricter standard relacement, repair, modification, and procurement of equipment; 
	--New criteria specifying a 12-month time frame for obligating funds. 
	--Funding for research and development must be for projects required for combat operations in the theater that can be delivered in 12 months
	when OMBagencyCode=7 and OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration] in ('>1-2 Years','>2-4 Years','>4 years')
	then 0
	else NULL
	end as IsOCOcrisisFunding
	
	--GeographicTheater of Operations
	--U.S. Central Command, the Horn of Africa, the Indian Ocean, and the Phillipines, among others
	
	  ,max([PBLscore]) as MaxOfPBLscore

      ,max(iif([CompetitionClassification] in 
		('No Competition (Only One Source Exception)',
		'No Competition (Only One Source Exception; Overrode blank Fair Opportunity)')
		,1,0)) as MaxOfIsOnlyOneSource
		  ,max(iif([VehicleClassification] in 
		('SINGLE AWARD IDC',
		'SINGLE AWARD INDEFINITE DELIVERY CONTRACT')
		,1,0)) as MaxOfIsSingleAward
      ,max(case [UnmodifiedUltimateDuration]
	  		when '>2-4 Years'
			then 1
			when '>4 years'
			then 2
			else 0
		end) as LengthScore
		,max(case
	  		when IsFixedPrice=1 and IsFixedPrice=1
			then 2
			when IsFixedPrice=1
			then 1
			else 0
		end) as PricingScore

      ,max(cast([IsOfficialPBL] as smallint)) as [MaxOfIsOfficialPBL]
      ,max(cast([IsPerformanceBasedLogistics] as smallint)) as [MaxOfIsPerformanceBasedLogistics]
	  ,sum(sumofobligatedAmount) as sumofobligatedAmount
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomerPartial]

  group by CSIScontractID
  	,fiscal_year

 







 































GO


