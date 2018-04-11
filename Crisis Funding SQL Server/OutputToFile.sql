USE [CSIS360]
GO


SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

EXEC	Budget.SP_LocationVendorCrisisFundingHistoryBucketCustomer
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
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

EXEC	 [Contract].[SP_ContractUnmodifiedandOutcomeDetailsCustomer]
		@IsDefense = NULL

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

EXEC	[Contract].[SP_ContractPricingCustomer]
		@IsDefense = NULL

--SELECT	'Return Value' = @return_value









GO
