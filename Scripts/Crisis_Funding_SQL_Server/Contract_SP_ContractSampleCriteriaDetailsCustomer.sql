/****** Object:  StoredProcedure [Contract].[SP_ContractSampleCriteriaDetailsCustomer]    Script Date: 5/23/2019 11:52:21 PM ******/
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
	 
		select  cc.CSIScontractID
		--,cc.StartFiscal_Year
		,cc.SumofObligatedAmount
--,cc.SumOfbaseandalloptionsvalue
--,cc.Sumofbaseandexercisedoptionsvalue
, cc.IsClosed
		--, max(iif(cc.maxofsigneddate=f.signeddate,f.lastdatetoorder,NULL)) as LastSignedLastDateToOrder
		--, max(iif(cc.maxofsigneddate=f.signeddate,f.ultimatecompletiondate,NULL)) as LastUltimateCompletionDate
		, max(iif(cc.maxofsigneddate=f.signeddate,f.CurrentCompletionDate,NULL)) as LastCurrentCompletionDate
		, MinOfSignedDate
		, MaxOfSignedDate
		, MinOfEffectiveDate
		--, case 
		----If not closed or terminated, then 
		--when (IsClosed=0 or IsClosed is null) and (IsTerminated=0 or IsTerminated is null)
		--then max(iif(cc.maxofsigneddate=f.signeddate,f.CurrentCompletionDate,NULL))
		--end 
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization cc
on ct.CSIScontractID=cc.CSIScontractID
inner join FPDSTypeTable.agencyid a
on f.contractingofficeagencyid=a.AgencyID
where @IsDefense=0 or @IsDefense is null or a.customer='Defense'
group by
cc.CSIScontractID
,cc.StartFiscal_Year
		,cc.SumofObligatedAmount
--,cc.SumOfbaseandalloptionsvalue
--,cc.Sumofbaseandexercisedoptionsvalue
, cc.IsClosed
, MinOfSignedDate
,MaxOfSignedDate
		, MinOfEffectiveDate
	
	END












GO


