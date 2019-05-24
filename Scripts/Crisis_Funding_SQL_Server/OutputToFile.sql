USE [CSIS360]
GO


--SET ANSI_WARNINGS OFF;
--SET NOCOUNT ON;

--EXEC	Budget.SP_LocationVendorCrisisFundingHistoryBucketCustomer
----EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
--		@Customer = NULL,
--		@StartFiscalYear = 2000



SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	Budget.SP_LocationVendorCrisisFundingHistoryBucketCustomerDetail
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		@Customer = NULL,
		@StartFiscalYear = 2000

--SELECT	'Return Value' = @return_value

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	Contract.[SP_ContractBudgetDecisionTree]
		@Customer = NULL,
		@StartFiscalYear = 2000

--SELECT	'Return Value' = @return_value

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	 [Contract].[SP_ContractSampleCriteriaDetailsCustomer]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	 [Contract].SP_ContractModificationDeltaCustomer
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	 [Contract].[SP_ContractUnmodifiedandOutcomeDetailsCustomer]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	  [Contract].[SP_ContractTerminationExamination]
		--@IsDefense = NULL

--SELECT	'Return Value' = @return_value

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	 [Contract].[SP_ContractBucketPlatformCustomer]
		@Customer = NULL

--SELECT	'Return Value' = @return_value


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	 [Contract].[SP_ContractLocationCustomer]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value


GO

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Contract].[SP_ContractUnmodifiedCompetitionVehicleCustomer]
		@Customer = NULL

--SELECT	'Return Value' = @return_value

GO


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Contract].[SP_ContractCompetitionVehicleCustomer]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value

GO


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Contract].[SP_ContractTopPSCofficeNAICS]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;
        
EXEC	[Contract].[SP_ContractFundingAccount]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	[Contract].[SP_ContractPricingCustomer]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [DepartmentID]
      ,[AgencyID]
      ,[ContractingOfficeCode]
      ,[ContractingOfficeName]
      ,[StartDate]
      ,[EndDate]
      ,[AddressLine1]
      ,[AddressLine2]
      ,[AddressLine3]
      ,[AddressCity]
      ,[AddressState]
      ,[ZipCode]
      ,[CountryCode]
      ,[Depot]
      ,[FISC]
      ,[TFBSOrelated]
      ,[CSIScreatedDate]
      ,[CSISmodifieddDate]
      ,[OCOcrisisScore]
      ,[OCOcrisisPercent]
      ,[CrisisPercent]
      ,[AvgplaceOCOcrisisScore]
  FROM [Office].[ContractingOfficeCode]
  order by [AvgplaceOCOcrisisScore] desc


  select name,OCOcrisisScore
  ,l.isforeign

  --update  l
  --set OCOcrisisScore=0
  from location.CountryCodes l
  where isforeign=1
  and OCOcrisisScore is null
  --order by isforeign


GO
