/****** Object:  StoredProcedure [Contract].[SP_ContractTerminationExamination]    Script Date: 5/23/2019 11:13:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractTerminationExamination]
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
		,max(cc.isDefaultOrCause) as isDefaultOrCause
,sum(iif(f.SignedDate<cc.MaxTerminatedDate,ObligatedAmount,0)) as ObligatedBeforeMaxTerminatedDate
,sum(iif(f.SignedDate=cc.MaxTerminatedDate,ObligatedAmount,0)) as ObligatedOnMaxTerminatedDate
,sum(iif(f.SignedDate>cc.MaxTerminatedDate,ObligatedAmount,0)) as ObligatedAfterMaxTerminatedDate
,max(cc.MaxTerminatedDate) as MaxTerminatedDate
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


