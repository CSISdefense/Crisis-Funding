USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractLocationCustomer]    Script Date: 9/25/2017 5:51:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractLocationCustomer]
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
      ,[PlaceCountryISO3]
      ,[UnmodifiedPlaceCountryISO3]
      ,[ObligatedAmountPlaceIsInternational]
      ,[AnyPlaceInternational]
      ,[PlaceIsInternational]
      ,[UnmodifiedPlaceIsInternational]
      ,[VendorCountryISO3]
      ,[UnmodifiedVendorCountryISO3]
      ,[ObligatedAmountVendorIsInternational]
      ,[AnyVendorInternational]
      ,[VendorIsInternational]
      ,[UnmodifiedVendorIsInternational]
      ,[OriginCountryISO3]
      ,[UnmodifiedOriginCountryISO3]
      ,[ObligatedAmountOriginIsInternational]
      ,[AnyOriginInternational]
      ,[OriginIsInternational]
      ,[UnmodifiedOriginIsInternational]
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractLocation cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select distinct cc.[CSIScontractID]
      ,[PlaceCountryISO3]
      ,[UnmodifiedPlaceCountryISO3]
      ,[ObligatedAmountPlaceIsInternational]
      ,[AnyPlaceInternational]
      ,[PlaceIsInternational]
      ,[UnmodifiedPlaceIsInternational]
      ,[VendorCountryISO3]
      ,[UnmodifiedVendorCountryISO3]
      ,[ObligatedAmountVendorIsInternational]
      ,[AnyVendorInternational]
      ,[VendorIsInternational]
      ,[UnmodifiedVendorIsInternational]
      ,[OriginCountryISO3]
      ,[UnmodifiedOriginCountryISO3]
      ,[ObligatedAmountOriginIsInternational]
      ,[AnyOriginInternational]
      ,[OriginIsInternational]
      ,[UnmodifiedOriginIsInternational]
from contract.ContractLocation cc

		--End of your query
		END
	END









GO


