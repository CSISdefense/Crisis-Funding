USE [DIIG]
GO

/****** Object:  View [Vendor].[LocationVendorHistoryBucketSubCustomer]    Script Date: 10/31/2016 8:02:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [Vendor].[LocationVendorHistoryBucketSubCustomer]
AS
SELECT 
C.fiscal_year
--,getdate() AS Query_Run_Date
--, ISNULL(CAgency.Customer, CAgency.AgencyIDtext) AS ContractingCustomer
--	, CAgency.SubCustomer as ContractingSubCustomer
--	, COALESCE(FAgency.Customer, FAgency.AgencyIDText, CAgency.Customer, CAgency.AGENCYIDText) as FundingAgency
--	, COALESCE(FAgency.SubCustomer, FAgency.AgencyIDText, CAgency.SubCustomer, CAgency.AGENCYIDText) as FundingSubAgency
--	,originiso.[USAID region] as OriginUSAIDregion
--	,vendoriso.[USAID region] as VendorUSAIDregion
--	,placeiso.[USAID region] as PlaceUSAIDregion
--	,coalesce(placeiso.[USAID region],vendoriso.[USAID region], originiso.[USAID region]) as GuessUSAIDregion
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
,PSC.ServicesCategory
,Scat.IsService
,PSC.Simple
,PSC.ProductOrServiceArea
,PSC.DoDportfolio
,c.isforeignownedandlocated
,c.isforeigngovernment
,c.isinternationalorganization
,c.organizationaltype
,PlaceCountryCode.IsInternational as PlaceIsInternational
,PlaceCountryCode.Country3LetterCodeText as PlaceCountryText
,OriginCountryCode.IsInternational as OriginIsInternational
,OriginCountryCode.Country3LetterCodeText as OriginCountryText
,VendorCountryCode.IsInternational as VendorIsInternational
,VendorCountryCode.Country3LetterCodeText as VendorCountryText
,pom.placeofmanufactureText
,C.obligatedAmount
,C.numberOfActions
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
	, t.CrisisFunding as ContractCrisisFunding
	, n.nationalinterestactioncodeText
	, n.CrisisFunding as NIAcrisisFunding
	, coalesce(t.CrisisFunding,n.CrisisFunding) as CrisisFunding
FROM Contract.FPDS as C
		LEFT OUTER JOIN
			FPDSTypeTable.AgencyID AS CAgency ON C.contractingofficeagencyid = CAgency.AgencyID
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
left outer join Assistance.NationalInterestActionCode n
on c.nationalinterestactioncode=n.nationalinterestactioncode













GO


