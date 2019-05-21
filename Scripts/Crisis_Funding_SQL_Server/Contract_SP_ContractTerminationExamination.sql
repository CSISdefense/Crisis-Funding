USE [CSIS360]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractUnmodifiedandOutcomeDetailsCustomer]    Script Date: 9/14/2017 4:27:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
CREATE PROCEDURE [Contract].[SP_ContractTerminationExamination]
	-- Add the parameters for the stored procedure here
	--@IsDefense varchar(255)
	--@ServicesOnly Bit

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here

	 
		select  cc.CSIScontractID
,sum(iif(f.SignedDate<cc.MaxTerminatedDate,ObligatedAmount,NULL)) as ObligatedBeforeMaxTerminatedDate
,sum(iif(f.SignedDate=cc.MaxTerminatedDate,ObligatedAmount,NULL)) as ObligatedOnMaxTerminatedDate
,sum(iif(f.SignedDate>cc.MaxTerminatedDate,ObligatedAmount,NULL)) as ObligatedAfterMaxTerminatedDate
from contract.fpds f
inner join contract.CSIStransactionID ct
on ct.CSIStransactionID=f.CSIStransactionID
inner join contract.ContractDiscretization cc
on ct.CSIScontractID=cc.CSIScontractID
--Terminated Contracts Only
where cc.IsTerminated=1
group by cc.CSIScontractID
	END
	









GO


