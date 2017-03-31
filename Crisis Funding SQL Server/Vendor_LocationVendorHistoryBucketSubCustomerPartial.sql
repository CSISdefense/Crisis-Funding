USE [DIIG]
GO

/****** Object:  View [Vendor].[LocationVendorHistoryBucketSubCustomer]    Script Date: 10/31/2016 8:02:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




Create VIEW [Vendor].[LocationVendorHistoryBucketSubCustomerPartial]
AS
SELECT 
C.fiscal_year
,t.CSIScontractID
--Customer
, ISNULL(CAgency.Customer, CAgency.AgencyIDtext) AS ContractingCustomer
	, CAgency.SubCustomer as ContractingSubCustomer
	, COALESCE(FAgency.Customer, FAgency.AgencyIDText, CAgency.Customer, CAgency.AGENCYIDText) as FundingAgency
	, COALESCE(FAgency.SubCustomer, FAgency.AgencyIDText, CAgency.SubCustomer, CAgency.AGENCYIDText) as FundingSubAgency
	,mcid.MajorCommandID
			,mcid.ContractingOfficeID
			,mcid.ContractingOfficeName
			
--ProductOrServiceCode
,PSC.ServicesCategory
,Scat.IsService
,PSC.Simple
,PSC.ProductOrServiceArea
,PSC.DoDportfolio
,PSC.ProductOrServiceCode
,PSC.ProductOrServiceCodeText
--Geography and Vendor
,c.isforeignownedandlocated
,c.isforeigngovernment
,c.isinternationalorganization
,c.organizationaltype
,PlaceCountryCode.IsInternational as PlaceIsInternational
,PlaceCountryCode.Country3LetterCodeText as PlaceCountryText
,PlaceISO.CrisisFundingTheater
,OriginCountryCode.IsInternational as OriginIsInternational
,OriginCountryCode.Country3LetterCodeText as OriginCountryText
,VendorCountryCode.IsInternational as VendorIsInternational
,VendorCountryCode.Country3LetterCodeText as VendorCountryText
,pom.placeofmanufactureText
	,originiso.[USAID region] as OriginUSAIDregion
	,vendoriso.[USAID region] as VendorUSAIDregion
	,placeiso.[USAID region] as PlaceUSAIDregion
	,coalesce(placeiso.[USAID region],vendoriso.[USAID region], originiso.[USAID region]) as GuessUSAIDregion
,case 
			when PlaceCountryCode.IsInternational=0 
				and coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational) = 0
			then 'Domestic US'
			when PlaceCountryCode.IsInternational=0 
				and coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational)= 1
			then 'Foreign Vendor in US'
			when PlaceCountryCode.ISOcountryCode=
				isnull(vendorcountrycode.ISOcountryCode,origincountrycode.isocountrycode)
			then 'Host Nation Vendor'
			when PlaceCountryCode.ISOcountryCode=origincountrycode.isocountrycode
			then 'Possible Host Nation Vendor with contradiction'
			when PlaceCountryCode.IsInternational=1 
				and  coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational) =0 
			then 'US Vendor abroad'
			when PlaceCountryCode.IsInternational=1 and 
				coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational)=1
			then 'Third Country Vendor abroad'
			when PlaceCountryCode.IsInternational=1 and 
				coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational) is null
			then 'Unknown vendor abroad' 
			when PlaceCountryCode.IsInternational=0 and 
				coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational) is null
			then 'Unknown vendor in US' 
			when PlaceCountryCode.IsInternational is null and 
				coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational)=0
			then 'US vendor, unknown location' 
			when PlaceCountryCode.IsInternational is null and 
				coalesce(parent.isforeign,VendorCountryCode.IsInternational,OriginCountryCode.IsInternational)=1
			then 'Foreign vendor, unknown location' 
			else 'Unlabeled'
			end as VendorPlaceType
, CASE
		WHEN Parent.Top6=1 and Parent.JointVenture=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 6 JV (Small Subsidiary)'
		WHEN Parent.Top6=1 and Parent.JointVenture=1
		THEN 'Large: Big 6 JV'
		WHEN Parent.Top6=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large: Big 6 (Small Subsidiary)'
		WHEN Parent.Top6=1
		THEN 'Large: Big 6'
		WHEN Parent.IsPreTop6=1
		THEN 'Large: Pre-Big 6'
		WHEN Parent.LargeGreaterThan3B=1 and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Large (Small Subsidiary)'
		WHEN Parent.LargeGreaterThan3B=1
		THEN 'Large'
		WHEN Parent.LargeGreaterThan1B=1  and C.contractingofficerbusinesssizedetermination in ('s','y')
		THEN 'Medium >1B (Small Subsidiary)'
		WHEN Parent.LargeGreaterThan1B=1
		THEN 'Medium >1B'
		WHEN C.contractingofficerbusinesssizedetermination='s' or C.contractingofficerbusinesssizedetermination='y'
		THEN 'Small'
		when Parent.UnknownCompany=1
		Then 'Unlabeled'
		ELSE 'Medium <1B'
	END AS VendorSize
--Values
,C.obligatedAmount
,C.numberOfActions
--Contract Description
,pricing.TypeofContractPricingtext
	-- ,iif(addmodified=1 and ismodified=1,'Modified ','')+
	--	case
	--		when addmultipleorsingawardidc=1 
	--		then case 
	--			when multipleorsingleawardidc is null
	--			then 'Unlabeled '+AwardOrIDVcontractactiontype
	--			else multipleorsingleawardidc+' '+AwardOrIDVcontractactiontype
	--			--Blank multipleorsingleawardIDC
	--		end
	--		else AwardOrIDVcontractactiontype 
	--end		as VehicleClassification
,C.NumberOfOffersReceived
	--,(SELECT CompetitionClassification from FPDSTypeTable.ClassifyCompetition(
	--	c.numberofoffersreceived --@NumberOfOffers as decimal(19,4)
	--,c.UseFairOpportunity --@UseFairOpportunity as bit
	--,c.ExtentIsFullAndOpen--@ExtentIsFullAndOpen as bit
	--,c.ExtentIsSomeCompetition--@extentissomecompetition as bit
	--,c.ExtentIsfollowontocompetedaction 
 --   ,c.ExtentIsOnlyOneSource 
 --   ,c.ReasonNotIsfollowontocompetedaction 
	--,c.is6_302_1exception--@is6_302_1exception as bit
	--,c.FairIsSomeCompetition--@fairissomecompetition as bit
	--,c.FairIsfollowontocompetedaction--@FairIsfollowontocompetedaction as bit
	--,c.FairIsonlyonesource--@FairIsonlyonesource as bit
	--	)) as CompetitionClassification
	--,(SELECT ClassifyNumberOfOffers from Fpdstypetable.ClassifyNumberOfOffers(
	--	c.numberofoffersreceived
	--	,c.UseFairOpportunity	--,@UseFairOpportunity as bit
	--	,c.ExtentIsSomeCompetition	--,@extentissomecompetition as bit
	--	,c.FairIsSomeCompetition	--,@fairissomecompetition as bit
	--	)) as ClassifyNumberOfOffers
--CrisiFundingClassification
,c	.ContingencyHumanitarianPeacekeepingOperation
,conhum.ContingencyHumanitarianPeacekeepingOperationText
	, t.CrisisFunding as ContractCrisisFunding
	, n.nationalinterestactioncode
	, n.nationalinterestactioncodeText
	, n.CrisisFunding as NIAcrisisFunding
	, coalesce(t.CrisisFunding,n.CrisisFunding) as CrisisFunding
	,c.localareasetaside --For disasters investigate this later.
	,iif(n.CrisisFunding='Disaster' or
		  t.CrisisFunding='Disaster' or 
		  c.CCRexception = '3' --Contracting officers conductingemergency operations
		  --or c.localareasetaside='Y' --For disasters investigate this later.
		  ,1,0) as IsDisasterCrisisFunding
	,iif(n.CrisisFunding='ARRA' or  t.CrisisFunding='ARRA',1,0) as IsARRAcrisisFunding
	,case 
	--National Intrest Action Code
	when n.CrisisFunding='OCO'
	then 1
	--Manually labeled contract (not presently used)
	when t.CrisisFunding='OCO'
	then 1
	--Labeled as Contigency or Huanitarian Operation
	when ConHum.IsOCOcrisisFunding=1
	then 1
	--CCRexception is Contracting Officers deployed in the course of military operations
	when c.CCRexception = '4' --Contracting Officers deployed in the course of military operations
	then 1
	--OMB standards 
	--Specifies stricter standard relacement, repair, modification, and procurement of equipment; 
	--New criteria specifying a 12-month time frame for obligating funds. 
	--Funding for research and development must be for projects required for combat operations in the theater that can be delivered in 12 months
	when ombbureau.OMBagencyCode=7 and ombbureau.bureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366
	then 0
	else NULL
	end as IsOCOcrisisFunding
	--Duration
	,case 
		when cdur.UnmodifiedUltimateDuration is null or cdur.UnmodifiedUltimateDuration <0
		then NULL
		when cdur.UnmodifiedUltimateDuration <= 61 
		then '<=2 Months'
		when cdur.UnmodifiedUltimateDuration <= 214 
		then '>2-7 Months'
		when cdur.UnmodifiedUltimateDuration <= 366
		then '>7-12 Months'
		when cdur.UnmodifiedUltimateDuration <= 731
		then '>1-2 Years'
		when cdur.UnmodifiedUltimateDuration <= 1461
		then '>2-4 Years'
		else '>4 years'
	end as UnmodifiedUltimateDurationCategory
	,cdur.UnmodifiedUltimateDuration
--Funding Account
	--FA: OMB
, isnull(ombbureau.OMBagencyCode,ombagency.OMBagencyCode) as OMBagencycode
, ombbureau.bureaucode as OMBbureaucode
--FA: Greenbook

, progsource.treasuryagencycode
, progsource.mainaccountcode
, progsource.subaccountcode
, coalesce(nullif(c.account_title,''),progsource.AccountTitle, sac.AccountTitle,mac.AccountTitle) as AccountTitle
--, coalesce(sac.BEAcategory,mac.BEAcategory) as BEAcategory
FROM Contract.FPDS as C
		LEFT OUTER JOIN
			FPDSTypeTable.AgencyID AS CAgency ON C.contractingofficeagencyid = CAgency.AgencyID
left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory mcid
		on c.contractingofficeagencyid=mcid.contractingagencyid and
		c.contractingofficeid=mcid.contractingofficeid and
		c.fiscal_year=mcid.fiscal_year
	
		LEFT OUTER JOIN
			FPDSTypeTable.AgencyID AS FAgency ON C.fundingrequestingagencyid = FAgency.AgencyID
	LEFT JOIN FPDSTypeTable.ProductOrServiceCode AS PSC
		ON C.productorservicecode=PSC.ProductOrServiceCode
	LEFT JOIN FPDSTypeTable.Country3lettercode as PlaceCountryCode
		ON C.placeofperformancecountrycode=PlaceCountryCode.Country3LetterCode
	left outer join location.CountryCodes as PlaceISO
		on PlaceCountryCode.ISOcountryCode =placeiso.[alpha-2]
	LEFT JOIN FPDSTypeTable.Country3lettercode as OriginCountryCode
		ON C.countryoforigin=OriginCountryCode.Country3LetterCode
	left outer join location.CountryCodes as OriginISO
		on OriginCountryCode.ISOcountryCode =OriginISO.[alpha-2]
	LEFT JOIN FPDSTypeTable.vendorcountrycode as VendorCountryCodePartial
		ON C.vendorcountrycode=VendorCountryCodePartial.vendorcountrycode
	LEFT JOIN FPDSTypeTable.Country3lettercode as VendorCountryCode
		ON vendorcountrycode.Country3LetterCode=VendorCountryCodePartial.Country3LetterCode
	left outer join location.CountryCodes as VendorISO
		on VendorCountryCode.ISOcountryCode=VendorISO.[alpha-2]
	LEFT JOIN ProductOrServiceCode.ServicesCategory As Scat
		ON Scat.ServicesCategory = PSC.ServicesCategory
	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DUNS
		ON C.fiscal_year = DUNS.FiscalYear 
		AND C.DUNSNumber = DUNS.DUNSNUMBER
	LEFT OUTER JOIN Contractor.ParentContractor as PARENT
		ON DUNS.ParentID = PARENT.ParentID
	left outer join FPDSTypeTable.placeofmanufacture as PoM
		on c.placeofmanufacture=pom.placeofmanufacture
left outer join Contract.CSIStransactionIDlabel t
	on c.CSIStransactionID=t.CSIStransactionID
              left join contract.CSISidvmodificationID as idvmod
                     on idvmod.CSISidvmodificationID=t.CSISidvmodificationID
left join contract.CSISidvpiidID as idv
                     on idv.CSISidvpiidID=idvmod.CSISidvpiidID
             
		LEFT OUTER JOIN FPDSTypeTable.typeofcontractpricing AS pricing
		ON pricing.TypeOfContractPricing=C.TypeofContractPricing 
	

	--Block of vehicle lookups
		Left JOIN FPDSTypeTable.multipleorsingleawardidc as Cmulti
			on C.multipleorsingleawardidc=Cmulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.multipleorsingleawardidc as IDVmulti
			on isnull(idvmod.multipleorsingleawardidc,idv.multipleorsingleawardidc)=IDVMulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.ContractActionType as Ctype
			on C.ContractActionType=Ctype.unseperated
		Left JOIN FPDSTypeTable.ContractActionType as IDVtype
			on isnull(idvmod.ContractActionType,idv.ContractActionType)=IDVtype.unseperated	LEFT JOIN FPDSTypeTable.reasonformodification as Rmod
		ON C.reasonformodification=Rmod.reasonformodification


left outer join Assistance.NationalInterestActionCode n
	on c.nationalinterestactioncode=n.nationalinterestactioncode
left join (select CSIScontractID
	, cd.UnmodifiedUltimateCompletionDate
	, DATEDIFF(day, cd.MinOfEffectiveDate, cd.UnmodifiedUltimateCompletionDate) as UnmodifiedUltimateDuration
	from contract.ContractDiscretization cd) as cdur
	on t.CSIScontractID=cdur.CSIScontractID
left outer join Assistance.ContingencyHumanitarianPeacekeepingOperation conhum
	on conhum.contingencyhumanitarianpeacekeepingoperation=c.ContingencyHumanitarianPeacekeepingOperation			



--Translate from prog source to standardized budget codes
left outer join budget.progsource progsource
	on c.progsourceagency=progsource.progsourceagency
	and c.progsourceaccount=progsource.progsourceaccount
	and c.progsourcesubacct=progsource.progsourcesubacct

--Account Code link ups
left outer join agency.TreasuryAgencyCode as tac
	on progsource.treasuryagencycode=tac.TreasuryAgencyCode
left outer join budget.MainAccountCode mac
	on progsource.mainaccountcode=mac.MainAccountCode
		and progsource.treasuryagencycode=mac.TreasuryAgencyCode
left outer join budget.subAccountCode sac
	on progsource.subaccountcode=sac.subaccountcode
		and progsource.mainaccountcode=sac.MainAccountCode
		and progsource.treasuryagencycode=sac.TreasuryAgencyCode



--Link OMBagencycode and OMBbureaucode
	left outer join agency.OMBagencyCode ombagency
		on ombagency.OMBagencyCode=coalesce(sac.agencycode,mac.agencycode,tac.agencycode) 
	left outer join agency.BureauCode ombbureau
		on ombbureau.OMBagencyCode=coalesce(sac.agencycode,mac.agencycode,tac.agencycode) 
		and ombbureau.bureaucode=coalesce(sac.bureaucode,mac.bureaucode,tac.bureaucode)









GO


