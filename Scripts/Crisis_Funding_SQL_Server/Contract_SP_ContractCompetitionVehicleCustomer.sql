USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractCompetitionVehicleCustomer]    Script Date: 9/14/2017 4:32:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractCompetitionVehicleCustomer]
	-- Add the parameters for the stored procedure here
	@IsDefense bit
	--@ServicesOnly Bit
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	IF (@IsDefense is not null) --Begin sub path where only services only one IsDefense will be returned
	BEGIN
		--Copy the start of your query here
	 
		select distinct cc.CSIScontractID
      ,cc.NumberOfOffersReceived
      ,IsFullAndOpen
      ,IsSomeCompetition
	  ,ObligatedAmountIsSomeCompetition
      ,IsOnlyOneSource
      ,IsFollowonToCompetedAction
	  ,IsUrgency
	  ,cc.IsIDV
      ,cc.multipleorsingleawardidc
      ,cc.Award_Type_Code
	  ,cc.IDV_Type_Code
      --,cc.AwardOrIDVcontractActionType
	  
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractCompetitionVehicle cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.IsDefense=@IsDefense
	END
	ELSE --Begin sub path wall IsDefenses will be returned
		BEGIN
		--Copy the start of your query here
		select distinct cc.CSIScontractID
 ,cc.NumberOfOffersReceived
      ,IsFullAndOpen
      ,IsSomeCompetition
	  ,ObligatedAmountIsSomeCompetition
      ,IsOnlyOneSource
      ,IsFollowonToCompetedAction
	  ,IsUrgency
	  ,cc.IsIDV
      ,cc.multipleorsingleawardidc
      --,AddMultipleOrSingleAwardIDC
      --,cc.AwardOrIDVcontractActionType
	        ,cc.Award_Type_Code
	  ,cc.IDV_Type_Code
from contract.ContractCompetitionVehicle cc

		--End of your query
		END
	END






GO


