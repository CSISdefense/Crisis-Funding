USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractIdentifierCustomer]    Script Date: 9/28/2017 6:42:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
Create PROCEDURE [Contract].[SP_ContractDiscretizationCustomer]
	-- Add the parameters for the stored procedure here
	@IsDefense Bit
	--@ServicesOnly Bit
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	IF (@IsDefense is not null) --Begin sub path where only services only one Customer will be returned
	BEGIN
		--Copy the start of your query here		

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct ccid.[CSIScontractID]
      ,ccid.[ContractLabelID]
	  ,ccid.[IDVPIID]
      ,ccid.[piid]
      ,ccid.[IsIDV]
      ,ccid.[StartFiscal_Year]
      ,ccid.[MinOfFiscal_Year]
      ,ccid.[maxoffiscal_year]
      ,ccid.[CountofModnumber]
      ,ccid.[SumOfnumberOfActions]
      ,ccid.[SumofObligatedAmount]
      ,ccid.[IsModified]
      ,ccid.[IsTerminated]
      ,ccid.[MaxOfSignedDate]
      ,ccid.[MinOfSignedDate]
      ,ccid.[MaxOfEffectiveDate]
      ,ccid.[MinOfEffectiveDate]
      ,ccid.[isAnyRnD1to5]
      ,ccid.[obligatedAmountRnD1to5]
      ,ccid.[firstSignedDateRnD1to5]
      ,ccid.[UnmodifiedRnD1to5]
      ,ccid.[UnmodifiedCurrentCompletionDate]
      ,ccid.[UnmodifiedLastDateToOrder]
      ,ccid.[UnmodifiedUltimateCompletionDate]
      ,ccid.[SumOfisChangeOrder]
      ,ccid.[MaxOfisChangeOrder]
      ,ccid.[ChangeOrderObligatedAmount]
      ,ccid.[ChangeOrderBaseAndExercisedOptionsValue]
      ,ccid.[ChangeOrderBaseAndAllOptionsValue]
      ,ccid.[SumOfisNewWork]
      ,ccid.[MaxOfisNewWork]
      ,ccid.[NewWorkObligatedAmount]
      ,ccid.[NewWorkBaseAndExercisedOptionsValue]
      ,ccid.[NewWorkBaseAndAllOptionsValue]
      ,ccid.[IsClosed]
      ,ccid.[ClosedObligatedAmount]
      ,ccid.[ClosedBaseAndExercisedOptionsValue]
      ,ccid.[ClosedBaseAndAllOptionsValue]
      ,ccid.[UnmodifiedNumberOfOffersReceived]
      ,ccid.[SizeOfObligatedAmount]
      ,ccid.[SumOfbaseandexercisedoptionsvalue]
      ,ccid.[SizeofSumofbaseandexercisedoptionsvalue]
      ,ccid.[SumOfbaseandalloptionsvalue]
      ,ccid.[SizeofSumOfbaseandalloptionsvalue]
      ,ccid.[SumofUnmodifiedObligatedAmount]
      ,ccid.[SizeOfUnmodifiedObligatedAmount]
      ,ccid.[SumOfUnmodifiedbaseandexercisedoptionsvalue]
      ,ccid.[SizeOfUnmodifiedSumOfbaseandexercisedoptionsvalue]
      ,ccid.[SumOfUnmodifiedbaseandalloptionsvalue]
      ,ccid.[SizeOfUnmodifiedSumOfbaseandalloptionsvalue]
  FROM [Contract].[ContractDiscretization] as ccid

  select ccid.CSIScontractID,
ccid.idvpiid,
ccid.piid
from contract.fpds f
inner join contract.CSIStransactionID ctid
on f.CSIStransactionID=ctid.CSIStransactionID
inner join contract.[ContractDiscretization] ccid
on ctid.CSIScontractID=ccid.CSIScontractID
inner join FPDSTypeTable.AgencyID a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
order by ccid.CSIScontractID



	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
SELECT  ccid.[CSIScontractID]
      ,ccid.[ContractLabelID]
	  ,ccid.[IDVPIID]
      ,ccid.[piid]
      ,ccid.[IsIDV]
      ,ccid.[StartFiscal_Year]
      ,ccid.[MinOfFiscal_Year]
      ,ccid.[maxoffiscal_year]
      ,ccid.[CountofModnumber]
      ,ccid.[SumOfnumberOfActions]
      ,ccid.[SumofObligatedAmount]
      ,ccid.[IsModified]
      ,ccid.[IsTerminated]
      ,ccid.[MaxOfSignedDate]
      ,ccid.[MinOfSignedDate]
      ,ccid.[MaxOfEffectiveDate]
      ,ccid.[MinOfEffectiveDate]
      ,ccid.[isAnyRnD1to5]
      ,ccid.[obligatedAmountRnD1to5]
      ,ccid.[firstSignedDateRnD1to5]
      ,ccid.[UnmodifiedRnD1to5]
      ,ccid.[UnmodifiedCurrentCompletionDate]
      ,ccid.[UnmodifiedLastDateToOrder]
      ,ccid.[UnmodifiedUltimateCompletionDate]
      ,ccid.[SumOfisChangeOrder]
      ,ccid.[MaxOfisChangeOrder]
      ,ccid.[ChangeOrderObligatedAmount]
      ,ccid.[ChangeOrderBaseAndExercisedOptionsValue]
      ,ccid.[ChangeOrderBaseAndAllOptionsValue]
      ,ccid.[SumOfisNewWork]
      ,ccid.[MaxOfisNewWork]
      ,ccid.[NewWorkObligatedAmount]
      ,ccid.[NewWorkBaseAndExercisedOptionsValue]
      ,ccid.[NewWorkBaseAndAllOptionsValue]
      ,ccid.[IsClosed]
      ,ccid.[ClosedObligatedAmount]
      ,ccid.[ClosedBaseAndExercisedOptionsValue]
      ,ccid.[ClosedBaseAndAllOptionsValue]
      ,ccid.[UnmodifiedNumberOfOffersReceived]
      ,ccid.[SizeOfObligatedAmount]
      ,ccid.[SumOfbaseandexercisedoptionsvalue]
      ,ccid.[SizeofSumofbaseandexercisedoptionsvalue]
      ,ccid.[SumOfbaseandalloptionsvalue]
      ,ccid.[SizeofSumOfbaseandalloptionsvalue]
      ,ccid.[SumofUnmodifiedObligatedAmount]
      ,ccid.[SizeOfUnmodifiedObligatedAmount]
      ,ccid.[SumOfUnmodifiedbaseandexercisedoptionsvalue]
      ,ccid.[SizeOfUnmodifiedSumOfbaseandexercisedoptionsvalue]
      ,ccid.[SumOfUnmodifiedbaseandalloptionsvalue]
      ,ccid.[SizeOfUnmodifiedSumOfbaseandalloptionsvalue]
  FROM [Contract].[ContractDiscretization] as ccid
order by ccid.CSIScontractID

		--End of your query
		END
	END











GO


