USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractUnmodifiedCompetitionVehicleCustomer]    Script Date: 9/14/2017 4:26:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractUnmodifiedCompetitionVehicleCustomer]
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
	 
		select distinct cc.CSIScontractID
      ,[UnmodifiedNumberOfOffersReceived]
      ,[UnmodifiedIsFullAndOpen]
      ,[UnmodifiedIsSomeCompetition]
      ,[UnmodifiedIsOnlyOneSource]
      ,[UnmodifiedIsFollowonToCompetedAction]
	  ,[UnmodifiedIsUrgency]
      ,[Unmodifiedmultipleorsingleawardidc]
      --,[Unmodifiedaddmultipleorsingawardidc]
	  ,unmodifiedaward_type_code
	  ,unmodifiedidv_type_code
      --,[UnmodifiedAwardOrIDVcontractactiontype]
	  --,cc.MaxOfIsUndefinitizedAction
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractUnmodifiedCompetitionVehicle cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.customer=@Customer
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select distinct cc.CSIScontractID
      ,[UnmodifiedNumberOfOffersReceived]
      ,[UnmodifiedIsFullAndOpen]
      ,[UnmodifiedIsSomeCompetition]
      ,[UnmodifiedIsOnlyOneSource]
      ,[UnmodifiedIsFollowonToCompetedAction]
	  	  ,[UnmodifiedIsUrgency]
      ,[Unmodifiedmultipleorsingleawardidc]
      --,[Unmodifiedaddmultipleorsingawardidc]
      --,[UnmodifiedAwardOrIDVcontractactiontype]
	  	  ,unmodifiedaward_type_code
	  ,unmodifiedidv_type_code
	  --,cc.MaxOfIsUndefinitizedAction
from contract.ContractUnmodifiedCompetitionVehicle cc

		--End of your query
		END
	END




GO


