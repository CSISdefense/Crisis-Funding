USE [DIIG]
GO

/****** Object:  View [Contract].[ContractLocation]    Script Date: 3/29/2017 5:32:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [Contract].[ContractLocation]
AS
select M.CSIScontractID
--PlaceCountryISO3
,iif(M.MinOfPlaceCountryISO3=MaxOfPlaceCountryISO3,
	MaxOfPlaceCountryISO3
	,NULL) as PlaceCountryISO3
,iif(M.MinOfUnmodifiedPlaceCountryISO3=MaxOfUnmodifiedPlaceCountryISO3,
	MaxOfUnmodifiedPlaceCountryISO3
	,NULL) as UnmodifiedPlaceCountryISO3
--Place Binaries IsInternational
,ObligatedAmountPlaceIsInternational
,MaxOfPlaceIsInternational as AnyPlaceInternational
,iif(M.MinOfPlaceIsInternational=MaxOfPlaceIsInternational,
	MaxOfPlaceIsInternational
	,NULL) as PlaceIsInternational
,iif(M.MinOfUnmodifiedIsInternational=MaxOfUnmodifiedIsInternational,
	MaxOfUnmodifiedIsInternational
	,NULL) as UnmodifiedPlaceIsInternational
--VendorCountryISO3
,iif(M.MinOfVendorCountryISO3	=MaxOfVendorCountryISO3	,
	MaxOfVendorCountryISO3	
	,NULL) as VendorCountryISO3	
,iif(M.MinOfUnmodifiedVendorCountryISO3	=MaxOfUnmodifiedVendorCountryISO3	,
	MaxOfUnmodifiedVendorCountryISO3	
	,NULL) as UnmodifiedVendorCountryISO3	
--Vendor Binaries IsInternational
,ObligatedAmountVendorIsInternational
,MaxOfVendorIsInternational as AnyVendorInternational
,iif(M.MinOfVendorIsInternational=MaxOfVendorIsInternational,
	MaxOfVendorIsInternational
	,NULL) as VendorIsInternational
,iif(M.MinOfUnmodifiedVendorIsInternational=MaxOfUnmodifiedVendorIsInternational,
	MaxOfUnmodifiedVendorIsInternational
	,NULL) as UnmodifiedVendorIsInternational
--OriginCountryISO3
,iif(M.MinOfOriginCountryISO3	=MaxOfOriginCountryISO3	,
	MaxOfOriginCountryISO3	
	,NULL) as OriginCountryISO3	
,iif(M.MinOfUnmodifiedOriginCountryISO3	=MaxOfUnmodifiedOriginCountryISO3	,
	MaxOfUnmodifiedOriginCountryISO3	
	,NULL) as UnmodifiedOriginCountryISO3	
--Origin Binaries IsInternational
,ObligatedAmountOriginIsInternational
,MaxOfOriginIsInternational as AnyOriginInternational
,iif(M.MinOfOriginIsInternational=MaxOfOriginIsInternational,
	MaxOfOriginIsInternational
	,NULL) as OriginIsInternational
,iif(M.MinOfUnmodifiedOriginIsInternational=MaxOfUnmodifiedOriginIsInternational,
	MaxOfUnmodifiedOriginIsInternational
	,NULL) as UnmodifiedOriginIsInternational
from (SELECT      
	ctid.CSIScontractID
	--PlaceCountryISO3
	, min(PlaceCountryCode.isoAlpha3) as MinOfPlaceCountryISO3
	, max(PlaceCountryCode.isoAlpha3) as MaxOfPlaceCountryISO3
	, min(iif(C.modnumber='0' or C.modnumber is null,PlaceCountryCode.isoAlpha3,NULL)) as MinOfUnmodifiedPlaceCountryISO3
	, max(iif(C.modnumber='0' or C.modnumber is null,PlaceCountryCode.isoAlpha3,NULL)) as MaxOfUnmodifiedPlaceCountryISO3
	--Place Binaries IsInternational
	,sum(iif(PlaceCountryCode.IsInternational=1,ObligatedAmount,NULL)) as ObligatedAmountPlaceIsInternational
	, Min(convert(int,PlaceCountryCode.IsInternational)) AS MinOfPlaceIsInternational
	, Max(convert(int,PlaceCountryCode.IsInternational)) AS MaxOfPlaceIsInternational
		, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,PlaceCountryCode.IsInternational),NULL)) AS MinOfUnmodifiedIsInternational
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,PlaceCountryCode.IsInternational),NULL)) AS MaxOfUnmodifiedIsInternational
	--VendorCountryISO3
	,min(VendorCountryCode.isoAlpha3) as MinOfVendorCountryISO3	
	,max(VendorCountryCode.isoAlpha3) as MaxOfVendorCountryISO3	
	, Min(iif(C.modnumber='0' or C.modnumber is null,VendorCountryCode.isoAlpha3,NULL)) AS MinOfUnmodifiedVendorCountryISO3
		, Max(iif(C.modnumber='0' or C.modnumber is null,VendorCountryCode.isoAlpha3,NULL)) AS MaxOfUnmodifiedVendorCountryISO3
	----Vendor Binaries IsInternational
	,sum(iif(VendorCountryCode.IsInternational=1,ObligatedAmount,NULL)) as ObligatedAmountVendorIsInternational
	,min(convert(int,VendorCountryCode.IsInternational)) as MinOfVendorIsInternational
	,max(convert(int,VendorCountryCode.IsInternational)) as MaxOfVendorIsInternational
		, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,VendorCountryCode.IsInternational),NULL)) AS MinOfUnmodifiedVendorIsInternational
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,VendorCountryCode.IsInternational),NULL)) AS MaxOfUnmodifiedVendorIsInternational
--OriginCountryISO3
	, Min(convert(int,OriginCountryCode.isoAlpha3)) AS MinOfOriginCountryISO3	
	, Max(convert(int,OriginCountryCode.isoAlpha3)) AS MaxOfOriginCountryISO3	
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,OriginCountryCode.isoAlpha3),NULL)) AS MinOfUnmodifiedOriginCountryISO3	
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,OriginCountryCode.isoAlpha3),NULL)) AS MaxOfUnmodifiedOriginCountryISO3	
	----Origin Binaries IsInternational
	,sum(iif(OriginCountryCode.IsInternational=1,ObligatedAmount,NULL)) as ObligatedAmountOriginIsInternational
	,min(convert(int,OriginCountryCode.IsInternational)) as MinOfOriginIsInternational
	,max(convert(int,OriginCountryCode.IsInternational)) as MaxOfOriginIsInternational
		, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,OriginCountryCode.IsInternational),NULL)) AS MinOfUnmodifiedOriginIsInternational
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,OriginCountryCode.IsInternational),NULL)) AS MaxOfUnmodifiedOriginIsInternational

  FROM contract.FPDS as C
 	LEFT JOIN FPDSTypeTable.Country3lettercode as PlaceCountryCode
		ON C.placeofperformancecountrycode=PlaceCountryCode.Country3LetterCode
	LEFT JOIN FPDSTypeTable.Country3lettercode as OriginCountryCode
		ON C.countryoforigin=OriginCountryCode.Country3LetterCode
	LEFT JOIN FPDSTypeTable.vendorcountrycode as VendorCountryCodePartial
		ON C.vendorcountrycode=VendorCountryCodePartial.vendorcountrycode
	LEFT JOIN FPDSTypeTable.Country3lettercode as VendorCountryCode
		ON vendorcountrycode.Country3LetterCode=VendorCountryCodePartial.Country3LetterCode
	left outer join FPDSTypeTable.placeofmanufacture as PoM
		on c.placeofmanufacture=pom.placeofmanufacture
	left outer join fpdstypetable.statecode as StateCode
		on c.pop_state_code=statecode.statecode
	left outer join contract.CSIStransactionID ctid
		on c.CSIStransactionID=ctid.CSIStransactionID
group by CSIScontractID ) as M















GO


