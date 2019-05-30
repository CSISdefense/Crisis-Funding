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
ALTER PROCEDURE [Contract].[SP_ContractUnmodifiedScope]
	-- Add the parameters for the stored procedure here
	@IsDefense varchar(255)
	--@ServicesOnly Bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

		--Copy the start of your query here
	 
		select cc.CSIScontractID
,cc.SumOfUnmodifiedobligatedAmount
,cc.SumOfUnmodifiedbaseandexercisedoptionsvalue
,cc.SumOfUnmodifiedbaseandalloptionsvalue
--,cc.ChangeOrderBaseAndAllOptionsValue
--,cc.ChangeOrderCeilingGrowth
--,cc.UnmodifiedNumberOfOffersReceived
,cc.UnmodifiedCurrentCompletionDate
,cc.UnmodifiedUltimateCompletionDate
,cc.UnmodifiedLastDateToOrder
--, cc.IsClosed
		, cc.IsModified
		--, cc.IsTerminated
		--,cc.SumOfisChangeOrder
		--,cc.MaxOfisChangeOrder
		--,cc.SumOfisNewWork
		--,cc.MaxOfisNewWork
from contract.ContractDiscretization cc
where @IsDefense is null or cc.CSIScontractID in 
	(select CSIScontractID
	from contract.CSIStransactionID ctid
	inner join FPDSTypeTable.agencyid a
	on ctid.contractingofficeagencyid=a.AgencyID
	where (a.Customer='Defense' and @IsDefense=1) or (a.Customer<>'Defense' and @IsDefense=0)
	group by CSIScontractID)
	END










GO


