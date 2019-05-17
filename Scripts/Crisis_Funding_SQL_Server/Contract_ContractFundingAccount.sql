USE [CSIS360]
GO

/****** Object:  View [Contract].[ContractFundingAccount]    Script Date: 3/29/2017 5:32:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [Contract].[ContractFundingAccount]
AS
select M.CSIScontractID
--TreasuryAgencyCode
,iif(M.MinOfTreasuryAgencyCode=MaxOfTreasuryAgencyCode,
	MaxOfTreasuryAgencyCode
	,NULL) as TreasuryAgencyCode
,iif(M.MinOfUnmodifiedTreasuryAgencyCode=MaxOfUnmodifiedTreasuryAgencyCode,
	MaxOfUnmodifiedTreasuryAgencyCode
	,NULL) as UnmodifiedTreasuryAgencyCode
--Place Binaries IsInternational
,iif(coalesce(M.MinOfTreasuryAgencyCode,MaxOfTreasuryAgencyCode) is NOT NULL,
	1
	,NULL) as AnyTreasuryAgencyCode
,iif(coalesce(M.MinOfUnmodifiedTreasuryAgencyCode,MaxOfUnmodifiedTreasuryAgencyCode) is NOT NULL,
	1
	,NULL) as AnyUnmodifiedTreasuryAgencyCode
--MainAccountCode
,iif(M.MinOfMainAccountCode	=MaxOfMainAccountCode	,
	MaxOfMainAccountCode	
	,NULL) as MainAccountCode	
,iif(M.MinOfUnmodifiedMainAccountCode	=MaxOfUnmodifiedMainAccountCode	,
	MaxOfUnmodifiedMainAccountCode	
	,NULL) as UnmodifiedMainAccountCode	
--Vendor Binaries IsInternational
,iif(coalesce(M.MinOfMainAccountCode,MaxOfMainAccountCode) is NOT NULL,
	1
	,NULL) as AnyMainAccountCode
,iif(coalesce(M.MinOfUnmodifiedMainAccountCode,MaxOfUnmodifiedMainAccountCode) is NOT NULL,
	1
	,NULL) as AnyUnmodifiedMainAccountCode
--SubAccountCode
,iif(M.MinOfSubAccountCode	=MaxOfSubAccountCode	,
	MaxOfSubAccountCode	
	,NULL) as SubAccountCode	
,iif(M.MinOfUnmodifiedSubAccountCode	=MaxOfUnmodifiedSubAccountCode	,
	MaxOfUnmodifiedSubAccountCode	
	,NULL) as UnmodifiedSubAccountCode	
--Origin Binaries IsInternational
,iif(coalesce(M.MinOfSubAccountCode,MaxOfSubAccountCode) is NOT NULL,
	1
	,NULL) as AnySubAccountCode
,iif(coalesce(M.MinOfUnmodifiedSubAccountCode,MaxOfUnmodifiedSubAccountCode) is NOT NULL,
	1
	,NULL) as AnyUnmodifiedSubAccountCode
from (SELECT      
	ctid.CSIScontractID
	--TreasuryAgencyCode
	, min(tac.TreasuryAgencyCode) as MinOfTreasuryAgencyCode
	, max(tac.TreasuryAgencyCode) as MaxOfTreasuryAgencyCode
	, min(iif(C.modnumber='0' or C.modnumber is null,tac.TreasuryAgencyCode,NULL)) as MinOfUnmodifiedTreasuryAgencyCode
	, max(iif(C.modnumber='0' or C.modnumber is null,tac.TreasuryAgencyCode,NULL)) as MaxOfUnmodifiedTreasuryAgencyCode
	--MainAccountCode
	,min(mac.MainAccountCode) as MinOfMainAccountCode	
	,max(mac.MainAccountCode) as MaxOfMainAccountCode	
	, Min(iif(C.modnumber='0' or C.modnumber is null,mac.MainAccountCode,NULL)) AS MinOfUnmodifiedMainAccountCode
		, Max(iif(C.modnumber='0' or C.modnumber is null,mac.MainAccountCode,NULL)) AS MaxOfUnmodifiedMainAccountCode
--SubAccountCode
	, Min(sac.SubAccountCode) AS MinOfSubAccountCode	
	, Max(sac.SubAccountCode) AS MaxOfSubAccountCode	
	, Min(iif(C.modnumber='0' or C.modnumber is null,sac.SubAccountCode,NULL)) AS MinOfUnmodifiedSubAccountCode	
	, Max(iif(C.modnumber='0' or C.modnumber is null,sac.SubAccountCode,NULL)) AS MaxOfUnmodifiedSubAccountCode	

  FROM contract.FPDS as C


--Translate from prog source to standardized budget codes
left outer join budget.progsource progsource
	on c.progsourceagency=progsource.progsourceagency
	and c.progsourceaccount=progsource.progsourceaccount
	and c.progsourcesubacct=progsource.progsourcesubacct
left outer join budget.rec_flag rf
on c.rec_flag=rf.rec_flag

--Account Code link ups
left outer join agency.TreasuryAgencyCode as tac
	on progsource.treasuryagencycode=tac.TreasuryAgencyCode
left outer join budget.MainAccountCode mac
	on progsource.MainAccountCode=mac.MainAccountCode
		and progsource.treasuryagencycode=mac.TreasuryAgencyCode
left outer join budget.SubAccountCode sac
	on progsource.SubAccountCode=sac.SubAccountCode
		and progsource.MainAccountCode=sac.MainAccountCode
		and progsource.treasuryagencycode=sac.TreasuryAgencyCode
left outer join Budget.OCOMainAccountCodeHistory ocomac
	on ocomac.MainAccountCode=mac.MainAccountCode
	and ocomac.TreasuryAgencyCode=mac.TreasuryAgencyCode
	and ocomac.FiscalYear=c.fiscal_year


	left outer join contract.CSIStransactionID ctid
		on c.CSIStransactionID=ctid.CSIStransactionID
group by CSIScontractID ) as M















GO


