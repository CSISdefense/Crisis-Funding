USE [CSIS360]
GO

/****** Object:  View [Contract].[CSIStransactionIDomnibus]    Script Date: 10/31/2016 5:35:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








alter VIEW [Contract].[CSIStransactionIDlabel]
AS
SELECT i.CSISidvpiidID
	,t.[CSIScontractID]
      ,t.[idvmodificationnumber]
      ,t.[modnumber]
      ,t.[transactionnumber]
      ,t.[CSIStransactionID]
      ,t.[CSISidvmodificationID]
      ,t.[isIDV]
      ,t.[CSISsourceIDVmodificationID]
      ,t.[CSISmodifiedBy]
      ,t.[CSISmodifiedDate]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.ContractLabelID
	  when lc.ContractLabelID is not null
	  then lc.ContractLabelID
	  when li.ContractLabelID is not null
	  then li.ContractLabelID
	  end as ContractLabelID
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[ContractLabelText]
	  when lc.ContractLabelID is not null
	  then lc.[ContractLabelText]
	  when li.ContractLabelID is not null
	  then li.[ContractLabelText]
	  end as [ContractLabelText]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[TFBSOoriginated]
	  when lc.ContractLabelID is not null
	  then lc.[TFBSOoriginated]
	  when li.ContractLabelID is not null
	  then li.[TFBSOoriginated]
	  end as [TFBSOoriginated]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[TFBSOmentioned]
	  when lc.ContractLabelID is not null
	  then lc.[TFBSOmentioned]
	  when li.ContractLabelID is not null
	  then li.[TFBSOmentioned]
	  end as [TFBSOmentioned]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[IsPerformanceBasedLogistics]
	  when lc.ContractLabelID is not null
	  then lc.[IsPerformanceBasedLogistics]
	  when li.ContractLabelID is not null
	  then li.[IsPerformanceBasedLogistics]
	  end as [IsPerformanceBasedLogistics]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[IsOrganicPBL]
	  when lc.ContractLabelID is not null
	  then lc.[IsOrganicPBL]
	  when li.ContractLabelID is not null
	  then li.[IsOrganicPBL]
	  end as [IsOrganicPBL]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[IsOfficialPBL]
	  when lc.ContractLabelID is not null
	  then lc.[IsOfficialPBL]
	  when li.ContractLabelID is not null
	  then li.[IsOfficialPBL]
	  end as [IsOfficialPBL]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[PrimaryProjectID]
	  when lc.ContractLabelID is not null
	  then lc.[PrimaryProjectID]
	  when li.ContractLabelID is not null
	  then li.[PrimaryProjectID]
	  end as [PrimaryProjectID]
	  ,case 
	  when lt.ContractLabelID is not null
	  then lt.[CrisisFunding]
	  when lc.ContractLabelID is not null
	  then lc.[CrisisFunding]
	  when li.ContractLabelID is not null
	  then li.[CrisisFunding]
	  end as [CrisisFunding]
  FROM [Contract].[CSIStransactionID] t
  left outer join COntract.CSIScontractID c
  on c.CSIScontractID = t.CSIScontractID
left outer join COntract.CSISidvpiidID i
  on i.CSISidvpiidID = c.CSISidvpiidID
  left outer join Contract.ContractLabelID lt
  on lt.ContractLabelID=t.ContractLabelID
  left outer join Contract.ContractLabelID lc
  on lc.ContractLabelID=c.ContractLabelID
  left outer join Contract.ContractLabelID li
  on li.ContractLabelID=i.ContractLabelID
	
