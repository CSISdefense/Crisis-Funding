USE [DIIG]
GO

/****** Object:  View [Vendor].[LocationVendorHistoryBucketSubCustomerPartial]    Script Date: 9/26/2017 5:05:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [Vendor].[LocationVendorHistoryBucketSubCustomerPartial]
AS
SELECT 
C.fiscal_year
,t.CSIScontractID
--Customer
, ISNULL(CAgency.Customer, CAgency.AgencyIDtext) AS ContractingCustomer
	, CAgency.SubCustomer as ContractingSubCustomer
	, CAgency.AgencyIDtext as ContractingAgencyText
	, CAgency.AgencyID as ContractingAgencyID
	, COALESCE(FAgency.Customer, FAgency.AgencyIDText, CAgency.Customer, CAgency.AGENCYIDText) as FundingAgency
	, COALESCE(FAgency.SubCustomer, FAgency.AgencyIDText, CAgency.SubCustomer, CAgency.AGENCYIDText) as FundingSubAgency
	,mcid.MajorCommandID
			,c.ContractingOfficeID
			,officecode.ContractingOfficeName
			,officecode.AddressCity as ContractingOfficeCity
			,officecode.AddressState as ContractingOfficeState
			,officecode.CountryCode as ContractingOfficeCountry
			,officecode.StartDate as ContractingOfficeStartDate
			,officecode.EndDate as ContractingOfficeEndDate
			
			
--ProductOrServiceCode
,PSC.ServicesCategory
,Scat.IsService
,PSC.Simple
,PSC.ProductOrServiceArea
,PSC.DoDportfolio
,PSC.ProductOrServiceCode
,PSC.ProductOrServiceCodeText
,PSC.HostNation3Category
--Geography and Vendor
,c.isforeignownedandlocated
,c.isforeigngovernment
,c.isinternationalorganization
,c.organizationaltype
,PlaceCountryCode.IsInternational as PlaceIsInternational
,PlaceCountryCode.Country3LetterCodeText as PlaceCountryText
,PlaceCountryCode.isoAlpha3 as PlaceISOalpha3
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
,notcompeted.isfollowontocompetedaction as ReasonNotIsfollowontocompetedaction
			,notcompeted.is6_302_1exception
			,NotCompeted.reasonnotcompetedText
			,competed.IsFullAndOpen as ExtentIsFullAndOpen
			,competed.IsSomeCompetition as ExtentIsSomeCompetition
			,competed.isonlyonesource as ExtentIsonlyonesource
			,competed.IsFollowOnToCompetedAction as ExtentIsfollowontocompetedaction
			,Fairopp.isfollowontocompetedaction as FairIsfollowontocompetedaction
			,Fairopp.isonlyonesource as FairIsonlyonesource
			,Fairopp.IsSomeCompetition as FairIsSomeCompetition
			,FairOpp.statutoryexceptiontofairopportunityText
			,setaside.typeofsetaside2category
			
,C.NumberOfOffersReceived
		,CASE 
				--Award or IDV Type show only (‘Definitive Contract’, ‘IDC’, ‘Purchase Order’)
				WHEN ctype.ForAwardUseExtentCompeted=1
				then 0 --Use extent competed
				--Award or IDV Type show only (‘Delivery Order’, ‘BPA Call’)
				--IDV Part 8 or Part 13 show only (‘Part 13’)
				--When  **Part 8 or Part 13  is not available!**
				--then 0 --Use extent competed

				--Award or IDV Type show only (‘Delivery Order’)
				--IDV Multiple or Single Award IDV show only (‘S’)
				when ctype.isdeliveryorder=1
					and isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =0
				then 0
				--Fair Opportunity / Limited Sources show only (‘Fair Opportunity Given’)
				--Award or IDV Type show only (‘Delivery Order’)
				--IDV Type show only (‘FSS’, ‘GWAC’, ‘IDC’)
				--	IDV Multiple or Single Award IDV show only (‘M’)
				when idvtype.ForIDVUseFairOpportunity=1 and 
					ctype.isdeliveryorder=1 and 
					isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =1
				then 1 --Use fair opportunity

				--	Number of Offers Received show only (‘1’)
				-- Award or IDV Type show only (‘BPA Call’, ‘BPA’)
				-- Part 8 or Part 13 show only (‘Part 8’)
				--When  **Part 8 or Part 13  is not available!**
				--then 0 --Use extent competed

				when fairopp.statutoryexceptiontofairopportunitytext is not null
				then 1
				else 0
			end as UseFairOpportunity
			,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) as AwardOrIDVcontractactiontype
			,isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) 
				as multipleorsingleawardidc 
			,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) as addmultipleorsingawardidc
			,isnull(IDVtype.addmodified,ctype.addmodified) as addmodified
			,isnull(idvmod.typeofidc,idv.typeofidc) as IDVtypeofIDC
			,Rmod.IsModified
			,letter.IsUndefinitizedAction
			,letter.IsLetterContract
	
--CrisisFundingClassification
,c.ContingencyHumanitarianPeacekeepingOperation
,conhum.ContingencyHumanitarianPeacekeepingOperationText
,conhum.IsOCOcrisisFunding as ConHumIsOCOcrisisFunding
	, t.CrisisFunding as ContractCrisisFunding
	, n.nationalinterestactioncode
	, n.nationalinterestactioncodeText
	, n.CrisisFunding as NIAcrisisFunding
	, coalesce(t.CrisisFunding,n.CrisisFunding) as CrisisFunding
	,c.localareasetaside --For disasters investigate this later.
	,c.CCRexception
	--Scoring
	,psc.OCOcrisisScore as pscOCOcrisiScore
	,PlaceISO.OCOcrisisScore as placeOCOcrisisScore
	,ocomac.PercentFundingAccountOCO
	,officecode.OCOcrisisScore as OfficeOCOcrisisScore

	--Duration
	,DATEDIFF(day, cdur.MinOfEffectiveDate, cdur.UnmodifiedUltimateCompletionDate) as UnmodifiedUltimateDuration
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
left outer join office.contractingofficecode officecode
on officecode.ContractingOfficeCode=c.contractingofficeid
left outer join office.ContractingAgencyIDofficeIDtoMajorCommandIDhistory mcid
		on c.contractingofficeagencyid=mcid.contractingagencyid and
		c.contractingofficeid=mcid.contractingofficeid and
		c.fiscal_year=mcid.fiscal_year
	
	left outer join FPDSTypeTable.lettercontract letter
	on letter.LetterContract=c.lettercontract

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
           --Contract Implementation
		LEFT OUTER JOIN FPDSTypeTable.typeofcontractpricing AS pricing
		ON pricing.TypeOfContractPricing=C.TypeofContractPricing 
		LEFT OUTER JOIN FPDSTypeTable.TypeOfSetAside AS SetAside 
		ON C.typeofsetaside = SetAside.TypeOfSetAside 
	LEFT OUTER JOIN FPDSTypeTable.extentcompeted AS Competed 
		ON C.extentcompeted = Competed.extentcompeted 
	LEFT OUTER JOIN FPDSTypeTable.ReasonNotCompeted AS NotCompeted 
		ON C.reasonnotcompeted = NotCompeted.reasonnotcompeted 
	LEFT OUTER JOIN FPDSTypeTable.statutoryexceptiontofairopportunity as FairOpp 
		ON C.statutoryexceptiontofairopportunity=FAIROpp.statutoryexceptiontofairopportunity


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
left join contract.ContractDiscretization as cdur
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
left outer join Budget.OCOmainAccountCodeHistory ocomac
	on ocomac.MainAccountCode=mac.MainAccountCode
	and ocomac.TreasuryAgencyCode=mac.TreasuryAgencyCode
	and ocomac.FiscalYear=c.fiscal_year


--Link OMBagencycode and OMBbureaucode
	left outer join agency.OMBagencyCode ombagency
		on ombagency.OMBagencyCode=coalesce(sac.agencycode,mac.agencycode,tac.agencycode) 
	left outer join agency.BureauCode ombbureau
		on ombbureau.OMBagencyCode=coalesce(sac.agencycode,mac.agencycode,tac.agencycode) 
		and ombbureau.bureaucode=coalesce(sac.bureaucode,mac.bureaucode,tac.bureaucode)










GO


