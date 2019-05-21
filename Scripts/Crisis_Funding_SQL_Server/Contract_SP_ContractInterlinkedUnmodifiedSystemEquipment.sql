USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractInterlinkedUnmodifiedSystemEquipment]    Script Date: 9/14/2017 4:28:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO










-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractInterlinkedUnmodifiedSystemEquipment]
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
	select  csec.CSIScontractID
		--Links by System Equipment Code
		,csec.unmodifiedSystemequipmentcode 
		,count(distinct secmatch.CSIScontractID) as SystemEquipmentInterlinked
		from [SystemEquipment].[CSIScontractIDforIdentifiedSystemEquipment] csec
		inner join [SystemEquipment].[CSIScontractIDforIdentifiedSystemEquipment] secMatch
			on csec.systemequipmentcode=secMatch.systemequipmentcode
			and csec.minofsigneddate>secMatch.MinOfSignedDate
			and (csec.minofsigneddate<=secMatch.LastUltimateCompletionDate or secMatch.LastUltimateCompletionDate is null )
		where csec.csiscontractid in (
			select distinct ct.CSIScontractID
			from contract.fpds f
			inner join contract.CSIStransactionID ct
				on f.CSIStransactionID=ct.CSIStransactionID
			inner join FPDSTypeTable.agencyid a
				on f.contractingofficeagencyid=a.AgencyID
			where  a.customer=@Customer
		)
		group by  csec.CSIScontractID
		,csec.unmodifiedSystemequipmentcode 
	


	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		
	select
	  csec.CSIScontractID
		--Links by System Equipment Code
		,csec.unmodifiedSystemequipmentcode 
		,count(distinct secmatch.CSIScontractID) as SystemEquipmentInterlinked
		,NULL as OfficePlatformInterlinked
		,1 as IsLabeled
		from [SystemEquipment].[CSIScontractIDforIdentifiedSystemEquipment] csec
		inner join [SystemEquipment].[CSIScontractIDforIdentifiedSystemEquipment] secMatch
			on csec.systemequipmentcode=secMatch.systemequipmentcode
			and csec.minofsigneddate>=secMatch.MinOfSignedDate
			and csec.minofsigneddate<=secMatch.LastUltimateCompletionDate
			and csec.CSIScontractID<>secMatch.CSIScontractID
		group by  csec.CSIScontractID
		,csec.unmodifiedSystemequipmentcode 
			END
	END
















GO


