USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractModificationDeltaCustomer]    Script Date: 9/14/2017 4:25:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractModificationDeltaCustomer]
	-- Add the parameters for the stored procedure here
	@Customer varchar(255)
	--@ServicesOnly Bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

		--Copy the start of your query here
	 
		select 
		CSIScontractID
--, total.IsTerminated
		--Change Order
		,SumOfisChangeOrder
		--,total.MaxOfisChangeOrder
		, ChangeOrderObligatedAmount
		--, ChangeOrderBaseAndExercisedOptionsValue
		--,ChangeOrderBaseAndAllOptionsValue
		,ChangeOrderCeilingGrowth
		,ChangeOrderCeilingGrowth
	,ChangeOrderCeilingRescision
	,SteadyScopeCeilingModification
	,AdminCeilingModification
	,EndingCeilingModification
	,OtherCeilingModification
--New Work
		--,SumOfisNewWork
		--,total.MaxOfisNewWork
--, NewWorkObligatedAmount
--, NewWorkBaseAndExercisedOptionsValue
--, NewWorkBaseAndAllOptionsValue
--Closed
--, total.IsClosed
--, ClosedObligatedAmount
--, ClosedBaseAndExercisedOptionsValue
--, ClosedBaseAndAllOptionsValue
from contract.ContractDiscretization cc
where @Customer is null or cc.CSIScontractID in 
	(select CSIScontractID
	from contract.CSIStransactionID ctid
	inner join FPDSTypeTable.agencyid a
	on ctid.contractingofficeagencyid=a.AgencyID
	where a.Customer=@Customer 
	group by CSIScontractID)
	

		--End of your query
	END










GO


