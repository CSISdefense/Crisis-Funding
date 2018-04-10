USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractUnmodifiedandOutcomeDetailsCustomer]    Script Date: 9/14/2017 4:27:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractUnmodifiedandOutcomeDetailsCustomer]
	-- Add the parameters for the stored procedure here
	@IsDefense varchar(255)
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
	 
		select distinct cc.CSIScontractID
,cc.SumOfUnmodifiedobligatedAmount
,cc.SumOfUnmodifiedbaseandexercisedoptionsvalue
,cc.SumOfUnmodifiedbaseandalloptionsvalue
,cc.ChangeOrderBaseAndAllOptionsValue
,cc.UnmodifiedNumberOfOffersReceived
,cc.UnmodifiedCurrentCompletionDate
,cc.UnmodifiedUltimateCompletionDate
,cc.UnmodifiedLastDateToOrder
, cc.IsClosed
		, cc.IsModified
		, cc.IsTerminated
		,cc.SumOfisChangeOrder
		,cc.MaxOfisChangeOrder
		,cc.SumOfisNewWork
		,cc.MaxOfisNewWork
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.customer=@IsDefense
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select distinct cc.CSIScontractID
,cc.SumOfUnmodifiedobligatedAmount
,cc.SumOfUnmodifiedbaseandexercisedoptionsvalue
,cc.SumOfUnmodifiedbaseandalloptionsvalue
,cc.ChangeOrderBaseAndAllOptionsValue
,cc.UnmodifiedNumberOfOffersReceived
,cc.UnmodifiedCurrentCompletionDate
,cc.UnmodifiedUltimateCompletionDate
,cc.UnmodifiedLastDateToOrder
, cc.IsClosed
		, cc.IsModified
		, cc.IsTerminated
		,cc.SumOfisChangeOrder
		,cc.MaxOfisChangeOrder
		,cc.SumOfisNewWork
		,cc.MaxOfisNewWork

from contract.ContractDiscretization cc

		--End of your query
		END
	END










GO


