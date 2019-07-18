USE [CSIS360]
GO

/****** Object:  View [Contract].[ContractHistoryPBLscoreSubCustomer]    Script Date: 3/29/2017 5:23:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER VIEW [Contract].[ContractHistoryPBLscoreSubCustomer]
AS
SELECT   CSIScontractID
	,fiscal_year
	,subcustomer
	,customer
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
  FROM [Contract].[CompetitionContractSizeHistoryBucketSubCustomerClassification]
  group by CSIScontractID
  	,fiscal_year
	,subcustomer
	,customer
 
 












 































GO


