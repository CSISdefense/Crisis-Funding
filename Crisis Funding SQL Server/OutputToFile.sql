USE [DIIG]
GO

SET ANSI_WARNINGS OFF;
SET NOCOUNT ON;

DECLARE	@return_value int

EXEC	@return_value = Budget.SP_LocationVendorCrisisFundingHistoryBucketCustomer
--EXEC	@return_value = Contract.[SP_ContractBudgetDecisionTree]
		@Customer = NULL,
		@StartFiscalYear = 2000

--SELECT	'Return Value' = @return_value

GO
