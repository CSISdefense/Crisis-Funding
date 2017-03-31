USE [DIIG]
GO

/****** Object:  View [Contract].[ContractHistoryPBLscoreSubCustomerDetail]    Script Date: 3/29/2017 5:27:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












ALTER VIEW [Contract].[ContractHistoryPBLscoreSubCustomerDetail]
AS

SELECT ctid.[CSIScontractID]
      ,f.[fiscal_year]
      ,a.[customer]
	  ,a.[subcustomer]
	  ,mcid.MajorCommandID
	  ,mcid.ContractingOfficeID
	  ,mcid.ContractingOfficeName
	  ,mcid.CSISofficeName
	  ,p.ProductOrServiceArea
	  ,p.ProductOrServiceCode
	  ,p.ProductOrServiceCodeText
      ,[MaxOfPBLscore] as MaxOfPSCscore
      ,[MaxOfIsOnlyOneSource]
      ,[MaxOfIsSingleAward]
      ,[LengthScore]
      ,[PricingScore]
      ,[MaxOfIsOfficialPBL]
      ,[MaxOfIsPerformanceBasedLogistics]
      ,[obligatedAmount]
  FROM contract.FPDS f
  left outer join FPDSTypeTable.ProductOrServiceCode p
  on f.productorservicecode=p.ProductOrServiceCode
  left outer join FPDSTypeTable.agencyid a
  on f.contractingofficeagencyid = a.AgencyID
  left outer join contract.CSIStransactionID ctid
  on f.CSIStransactionID=ctid.CSIStransactionID
  left outer join contract.ContractHistoryPBLscoreSubCustomer c
  on ctid.CSIScontractID=c.CSIScontractID
  and f.fiscal_year=c.fiscal_year
  and a.Customer=c.customer
  and a.SubCustomer=c.subcustomer
  	left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory mcid
		on f.contractingofficeagencyid=mcid.contractingagencyid and
		f.contractingofficeid=mcid.contractingofficeid and
		f.fiscal_year=mcid.fiscal_year
  

 












 



































GO


