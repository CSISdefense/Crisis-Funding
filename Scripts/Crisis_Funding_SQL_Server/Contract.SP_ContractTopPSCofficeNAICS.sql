/****** Object:  StoredProcedure [Contract].[SP_ContractDetailsCustomer]    Script Date: 3/22/2018 11:52:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
CREATE PROCEDURE [Contract].[SP_ContractTopPSCofficeNAICS]
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
	 
		select  cc.CSIScontractID
		,cc.topContractingOfficeAgencyID
		,cc.topContractingOfficeAgencyIDamount
		,cc.topContractingOfficeID
		,cc.topContractingOfficeAmount
		,cc.topProductOrServiceCode
		,cc.topProductOrServiceAmount
		,cc.topPrincipalNAICScode
		,cc.topPrincipalNAICSamount
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.CSIScontractID cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
group by cc.CSIScontractID
		,cc.topContractingOfficeAgencyID
		,cc.topContractingOfficeAgencyIDamount
		,cc.topContractingOfficeID
		,cc.topContractingOfficeAmount
		,cc.topProductOrServiceCode
		,cc.topProductOrServiceAmount
		,cc.topPrincipalNAICScode
		,cc.topPrincipalNAICSamount
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select  cc.CSIScontractID
		,cc.topContractingOfficeAgencyID
		,cc.topContractingOfficeAgencyIDamount
		,cc.topContractingOfficeID
		,cc.topContractingOfficeAmount
		,cc.topProductOrServiceCode
		,cc.topProductOrServiceAmount
		,cc.topPrincipalNAICScode
		,cc.topPrincipalNAICSamount
from contract.CSIScontractID cc

		--End of your query
		END
	END
GO


