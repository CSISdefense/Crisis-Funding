USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractPricingCustomer]    Script Date: 9/14/2017 4:09:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
CREATE PROCEDURE [Contract].[SP_ContractPricingUCA]
	-- Add the parameters for the stored procedure here
	@Customer varchar(255)
	--@ServicesOnly Bit
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
 
		select cc.[CSIScontractID]
		,cc.[TypeOfContractPricing]
      ,[UnmodifiedTypeOfContractPricing]
	  ,IsLabeledPricing
		,[ObligatedAmountIsUCA]
      ,[IsUCA]
      ,[UnmodifiedIsUCA]
from contract.ContractPricing cc
where @Customer is null or cc.CSIScontractID in 
	(select CSIScontractID
	from contract.CSIStransactionID ctid
	inner join FPDSTypeTable.agencyid a
	on ctid.contractingofficeagencyid=a.AgencyID
	where a.Customer=@Customer 
	group by CSIScontractID)
	
	END










GO


