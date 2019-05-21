USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractSampleCriteriaDetailsCustomer]    Script Date: 9/14/2017 4:10:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractSampleCriteriaDetailsCustomer]
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
	 
		select  cc.CSIScontractID
		,cc.StartFiscal_Year
		,cc.SumofObligatedAmount
--,cc.SumOfbaseandalloptionsvalue
--,cc.Sumofbaseandexercisedoptionsvalue
, cc.IsClosed
		, max(iif(cc.maxofsigneddate=f.signeddate,f.lastdatetoorder,NULL)) as LastSignedLastDateToOrder
		, max(iif(cc.maxofsigneddate=f.signeddate,f.ultimatecompletiondate,NULL)) as LastUltimateCompletionDate
		, max(iif(cc.maxofsigneddate=f.signeddate,f.CurrentCompletionDate,NULL)) as LastCurrentCompletionDate
		, MinOfSignedDate
		, MinOfEffectiveDate
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where a.customer='Defense'
group by
cc.CSIScontractID
,cc.StartFiscal_Year
		,cc.SumofObligatedAmount
--,cc.SumOfbaseandalloptionsvalue
--,cc.Sumofbaseandexercisedoptionsvalue
, cc.IsClosed
, MinOfSignedDate
		, MinOfEffectiveDate
	END
	ELSE --Begin sub path wall Customers will be returned
		BEGIN
		--Copy the start of your query here
		select
		cc.CSIScontractID
		,cc.StartFiscal_Year
		,cc.SumofObligatedAmount
--,cc.SumOfbaseandalloptionsvalue
--,cc.Sumofbaseandexercisedoptionsvalue
, cc.IsClosed
		, max(iif(cc.maxofsigneddate=f.signeddate,f.lastdatetoorder,NULL)) as LastSignedLastDateToOrder
		, max(iif(cc.maxofsigneddate=f.signeddate,f.ultimatecompletiondate,NULL)) as LastUltimateCompletionDate
		, max(iif(cc.maxofsigneddate=f.signeddate,f.CurrentCompletionDate,NULL)) as LastCurrentCompletionDate
		, MinOfSignedDate
		, MinOfEffectiveDate
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
group by
cc.CSIScontractID
,cc.StartFiscal_Year
		,cc.SumofObligatedAmount
--,cc.SumOfbaseandalloptionsvalue
--,cc.Sumofbaseandexercisedoptionsvalue
, cc.IsClosed
, MinOfSignedDate
		, MinOfEffectiveDate
		--End of your query
		END
	END












GO


