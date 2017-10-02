USE [DIIG]
GO

/****** Object:  StoredProcedure [budget].[SP_LocationVendorCrisisFundingHistoryBucketCustomer]    Script Date: 9/26/2017 4:56:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/
Create procedure Contract.[SP_ContractBudgetDecisionTree]

@Customer VARCHAR(255),
@StartFiscalYear smallint


 as 
SELECT CSIScontractID[CSIScontractID]
      ,max(DecisionTree) as MaxOfDecisionTree
	  ,max(DecisionTreeStep4) as MaxOfDecisionTreeStep4
	  ,min(DecisionTree) as MinOfDecisionTree
	  ,min(DecisionTreeStep4) as MinOfDecisionTreeStep4  
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
  where (@Customer is null or @Customer=ContractingCustomer)
  and (@StartFiscalYear is null or @StartFiscalYear<=fiscal_year)
  group by CSIScontra[CSIScontractID]

GO


