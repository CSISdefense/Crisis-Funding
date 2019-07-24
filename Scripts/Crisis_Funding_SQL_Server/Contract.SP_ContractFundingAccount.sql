/****** Object:  StoredProcedure [Contract].[SP_ContractFundingAccount]    Script Date: 9/19/2018 9:34:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractFundingAccount]
	-- Add the parameters for the stored procedure here
	@IsDefense bit
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
	 
		select distinct cc.[CSIScontractID]
      ,[TreasuryAgencyCode]
      ,[UnmodifiedTreasuryAgencyCode]
      ,[AnyTreasuryAgencyCode]
      ,[AnyUnmodifiedTreasuryAgencyCode]
      ,[MainAccountCode]
      ,[UnmodifiedMainAccountCode]
      ,[AnyMainAccountCode]
      ,[AnyUnmodifiedMainAccountCode]
      ,[SubAccountCode]
      ,[UnmodifiedSubAccountCode]
      ,[AnySubAccountCode]
      ,[AnyUnmodifiedSubAccountCode]
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join [Contract].[ContractFundingAccount] cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select distinct cc.[CSIScontractID]
      ,[TreasuryAgencyCode]
      ,[UnmodifiedTreasuryAgencyCode]
      ,[AnyTreasuryAgencyCode]
      ,[AnyUnmodifiedTreasuryAgencyCode]
      ,[MainAccountCode]
      ,[UnmodifiedMainAccountCode]
      ,[AnyMainAccountCode]
      ,[AnyUnmodifiedMainAccountCode]
      ,[SubAccountCode]
      ,[UnmodifiedSubAccountCode]
      ,[AnySubAccountCode]
      ,[AnyUnmodifiedSubAccountCode]
  FROM [Contract].[ContractFundingAccount] cc

		--End of your query
		END
	END
GO


