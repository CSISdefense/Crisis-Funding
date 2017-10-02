USE [DIIG]
GO

/****** Object:  StoredProcedure [Contract].[SP_ContractDefenseSubCustomer]    Script Date: 9/14/2017 4:30:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		Greg Sanders
-- Create date: 2/01/2013
-- Description:	Break down contracts by size.
-- =============================================
ALTER PROCEDURE [Contract].[SP_ContractDefenseSubCustomer]
	-- Add the parameters for the stored procedure here
	--@ServicesOnly Bit
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statementIDVPIID.
	SET NOCOUNT ON;

	-- Insert statements for procedure here


		SELECT  [CSIScontractID]
      ,[Customer]
      ,[UnmodifiedCustomer]
      ,[SubCustomer]
      ,[UnmodifiedSubCustomer]
      ,[ObligatedAmountIsArmy]
      ,[ObligatedAmountIsNavy]
      ,[ObligatedAmountIsAirForce]
      ,[ObligatedAmountIsOtherDoD]
  FROM [DIIG].[Contract].[ContractDefenseSubCustomer]


	END






GO


