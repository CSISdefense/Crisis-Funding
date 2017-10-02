USE [DIIG]
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
ALTER PROCEDURE [Contract].[SP_ContractIdentifierCustomer]
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
	 
		select ccid.CSIScontractID,
ccid.idvpiid,
ccid.piid
from contract.fpds f
inner join contract.CSIStransactionID ctid
on f.CSIStransactionID=ctid.CSIStransactionID
inner join contract.CSIScontractID ccid
on ctid.CSIScontractID=ccid.CSIScontractID
inner join FPDSTypeTable.AgencyID a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
group by ccid.CSIScontractID,
ccid.idvpiid,
ccid.piid
order by ccid.CSIScontractID


	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select ccid.CSIScontractID,
ccid.idvpiid,
ccid.piid
from contract.fpds f
inner join contract.CSIStransactionID ctid
on f.CSIStransactionID=ctid.CSIStransactionID
inner join contract.CSIScontractID ccid
on ctid.CSIScontractID=ccid.CSIScontractID
inner join FPDSTypeTable.AgencyID a
on f.contractingofficeagencyid=a.AgencyID
group by ccid.CSIScontractID,
ccid.idvpiid,
ccid.piid
order by ccid.CSIScontractID

		--End of your query
		END
	END











GO


