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

	IF (@Customer is not null) --Begin sub path where only services only one Customer will be returned
	BEGIN
		--Copy the start of your query here
	 
		select distinct
		ct.CSIScontractID
--, total.IsTerminated
		--Change Order
		--,total.SumOfisChangeOrder
		--,total.MaxOfisChangeOrder
		, ChangeOrderObligatedAmount
		, ChangeOrderBaseAndExercisedOptionsValue
		,ChangeOrderBaseAndAllOptionsValue
--New Work
		--,total.SumOfisNewWork
		--,total.MaxOfisNewWork
, NewWorkObligatedAmount
, NewWorkBaseAndExercisedOptionsValue
, NewWorkBaseAndAllOptionsValue
--Closed
--, total.IsClosed
--, ClosedObligatedAmount
--, ClosedBaseAndExercisedOptionsValue
--, ClosedBaseAndAllOptionsValue
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization Total
on ct.CSIScontractID=Total.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.customer=@Customer
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select 
			total.CSIScontractID
--, total.IsTerminated
		--Change Order
		--,total.SumOfisChangeOrder
		--,total.MaxOfisChangeOrder
		, ChangeOrderObligatedAmount
		, ChangeOrderBaseAndExercisedOptionsValue
		,ChangeOrderBaseAndAllOptionsValue
--New Work
		--,total.SumOfisNewWork
		--,total.MaxOfisNewWork
, NewWorkObligatedAmount
, NewWorkBaseAndExercisedOptionsValue
, NewWorkBaseAndAllOptionsValue
--Closed
--, total.IsClosed
--, ClosedObligatedAmount
--, ClosedBaseAndExercisedOptionsValue
--, ClosedBaseAndAllOptionsValue
from contract.ContractDiscretization Total

		--End of your query
		END
	END










GO


