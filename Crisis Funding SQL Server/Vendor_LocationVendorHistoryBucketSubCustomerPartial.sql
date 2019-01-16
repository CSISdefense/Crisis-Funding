/****** Object:  View [Vendor].[LocationVendorHistoryBucketSubCustomerPartial]    Script Date: 11/24/2018 10:21:30 AM ******/
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
			when PlaceCountryCode.ISOalpha3=
				isnull(vendorcountrycode.ISOalpha3,origincountrycode.ISOalpha3)
			then 'Host Nation Vendor'
			when PlaceCountryCode.ISOalpha3=origincountrycode.ISOalpha3
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
					,notcompeted.IsUrgency
			,competed.IsFullAndOpen as ExtentIsFullAndOpen
			,competed.IsSomeCompetition as ExtentIsSomeCompetition
			,competed.isonlyonesource as ExtentIsonlyonesource
			,competed.IsFollowOnToCompetedAction as ExtentIsfollowontocompetedaction
			,Fairopp.isfollowontocompetedaction as FairIsfollowontocompetedaction
			,Fairopp.isonlyonesource as FairIsonlyonesource
			,Fairopp.IsSomeCompetition as FairIsSomeCompetition
			,FairOpp.statutoryexceptiontofairopportunityText
							,Fairopp.IsUrgency as FairIsUrgency
			,setaside.typeofsetaside2category
			
,C.NumberOfOffersReceived
		
			,CASE 
				--Award or IDV Type show only (‘Definitive Contract’, ‘Purchase Order’)
				WHEN atype.UseExtentCompeted=1
				then 0 --Use extent competed
				
				--IDV Type show only (‘FSS’, ‘GWAC’)
				when idvtype.UseFairOpportunity=1  
				then 1 --Use fair opportunity

				--For IDC, BPA/BPA Call, and BOA, check if is multiaward  is filled in and use that
				--We don't have BPA type 8 or 13 available so we're using single/multi for that
				when isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) is not null
					then isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward)
				
				--Otherwise, use fair opportunity if available
				when fairopp.statutoryexceptiontofairopportunitytext is not null
				then 1
				else 0
			end as UseFairOpportunity
			
	,isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) as multipleorsingleawardidc 
--,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) as addmultipleorsingawardidc				
--,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) as AwardOrIDVcontractactiontype
,CType.Award_Type_Code
,IDVtype.idv_type_code
,AType.Award_Type_Name
,IDVtype.idv_type_Name
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
	, rf.IsArra as RFisARRA
	, coalesce(t.CrisisFunding,n.CrisisFunding) as CrisisFunding
	,c.localareasetaside --For disasters investigate this later.
	,c.CCRexception
	--Scoring
	,psc.OCOcrisisScore as pscOCOcrisisScore
	,PlaceISO.OCOcrisisScore as placeOCOcrisisScore
	,PlaceISO.IsOMBocoList
	,PlaceISO.isforeign
	,psc.OCOcrisisPercent as pscOCOcrisisPercent
	,iif(psc.OCOcrisisPercent>=0.04,1,0)  as pscOCOcrisisPoint
	,ocomac.PercentFundingAccountOCO
	,iif(ocomac.PercentFundingAccountOCO>=0.25,1,0)  as FundingAccountOCOpoint
	,officecode.OCOcrisisScore as OfficeOCOcrisisScore
	,officecode.OCOcrisisPercent as OfficeOCOcrisisPercent
	,iif(officecode.OCOcrisisPercent>=0.05,1,0)  as OfficeOCOcrisisPoint
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


		--Block of location lookups
 	LEFT JOIN FPDSTypeTable.Country3lettercode as PlaceCountryCode
		ON C.placeofperformancecountrycode=PlaceCountryCode.Country3LetterCode
		left outer join location.CountryCodes as PlaceISO
		on PlaceCountryCode.isoAlpha3 =placeiso.[alpha-3]
	LEFT JOIN FPDSTypeTable.Country3lettercode as OriginCountryCode
		ON C.countryoforigin=OriginCountryCode.Country3LetterCode
	left outer join location.CountryCodes as OriginISO
		on OriginCountryCode.isoAlpha3 =OriginISO.[alpha-3]
	LEFT JOIN FPDSTypeTable.vendorcountrycode as VendorCountryCodePartial
		ON C.vendorcountrycode=VendorCountryCodePartial.vendorcountrycode
	LEFT JOIN FPDSTypeTable.Country3lettercode as VendorCountryCode
		ON vendorcountrycode.Country3LetterCode=VendorCountryCodePartial.Country3LetterCode
	left outer join location.CountryCodes as VendorISO
		on VendorCountryCode.isoAlpha3=VendorISO.[alpha-3]
	left outer join FPDSTypeTable.placeofmanufacture as PoM
		on c.placeofmanufacture=pom.placeofmanufacture
	left outer join fpdstypetable.statecode as StateCode
		on c.pop_state_code=statecode.statecode


		

		



	LEFT JOIN ProductOrServiceCode.ServicesCategory As Scat
		ON Scat.ServicesCategory = PSC.ServicesCategory
	LEFT OUTER JOIN Contractor.DunsnumbertoParentContractorHistory as DUNS
		ON C.fiscal_year = DUNS.FiscalYear 
		AND C.DUNSNumber = DUNS.DUNSNUMBER
	LEFT OUTER JOIN Contractor.ParentContractor as PARENT
		ON DUNS.ParentID = PARENT.ParentID
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
		Left JOIN FPDSTypeTable.Award_Type_Code as Atype
		on C.Award_Type_Code=Atype.Award_Type_Code
	Left JOIN FPDSTypeTable.ContractActionType as Ctype
		on C.ContractActionType=Ctype.ContractActionType
	Left JOIN FPDSTypeTable.IDV_Type_Code as IDVtype
		on coalesce(c.parent_award_type_code,idvmod.idv_type_code,idv.idv_type_code)=IDVtype.idv_type_code

			
			
			LEFT JOIN FPDSTypeTable.reasonformodification as Rmod
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
left outer join budget.rec_flag rf
on c.rec_flag=rf.rec_flag

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


