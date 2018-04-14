USE [CSIS360]
GO

/****** Object:  View [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]    Script Date: 9/26/2017 5:02:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER VIEW [Vendor].[LocationVendorHistoryBucketSubCustomerClassification]
AS
SELECT  [fiscal_year]
      ,[CSIScontractID]
      ,[ContractingCustomer]
      ,[ContractingSubCustomer]
      ,[FundingAgency]
      ,[FundingSubAgency]
      ,[MajorCommandID]
      ,[ContractingOfficeID]
      ,[ContractingOfficeName]
	  ,ContractingOfficeCity
			,ContractingOfficeState
			,ContractingOfficeCountry
			,ContractingOfficeStartDate
			,ContractingOfficeEndDate
      ,[ServicesCategory]
      ,[IsService]
      ,[Simple]
      ,[ProductOrServiceArea]
	  ,HostNation3Category
      ,[DoDportfolio]
      ,[ProductOrServiceCode]
      ,[ProductOrServiceCodeText]
      ,[isforeignownedandlocated]
      ,[isforeigngovernment]
      ,[isinternationalorganization]
      ,[organizationaltype]
      ,[PlaceIsInternational]
      ,[PlaceCountryText]
	  ,PlaceISOalpha3
      ,[CrisisFundingTheater]
      ,[OriginIsInternational]
      ,[OriginCountryText]
      ,[VendorIsInternational]
      ,[VendorCountryText]
      ,[placeofmanufactureText]
      ,[OriginUSAIDregion]
      ,[VendorUSAIDregion]
      ,[PlaceUSAIDregion]
      ,[GuessUSAIDregion]
      ,[VendorPlaceType]
      ,[VendorSize]
      ,[obligatedAmount]
      ,[numberOfActions]
      ,[TypeofContractPricingtext]
	  ,IsUndefinitizedAction
	  ,case
			when idv_type_code='B'
			then case 
				when multipleorsingleawardidc is null
				then 'Unlabeled '+idv_type_Name
				else multipleorsingleawardidc+' '+idv_type_Name
				--Blank multipleorsingleawardIDC
			end
			else coalesce(idv_type_Name,Award_Type_Name) 
	end		as VehicleClassification
      ,[NumberOfOffersReceived]
	  	,(SELECT CompetitionClassification from FPDSTypeTable.ClassifyCompetition(
		l.numberofoffersreceived --@NumberOfOffers as decimal(19,4)
	,l.UseFairOpportunity --@UseFairOpportunity as bit
	,l.ExtentIsFullAndOpen--@ExtentIsFullAndOpen as bit
	,l.ExtentIsSomeCompetition--@extentissomecompetition as bit
	,l.ExtentIsfollowontocompetedaction 
    ,l.ExtentIsOnlyOneSource 
    ,l.ReasonNotIsfollowontocompetedaction 
	,l.is6_302_1exception--@is6_302_1exception as bit
	,l.FairIsSomeCompetition--@fairissomecompetition as bit
	,l.FairIsfollowontocompetedaction--@FairIsfollowontocompetedaction as bit
	,l.FairIsonlyonesource--@FairIsonlyonesource as bit
		)) as CompetitionClassification
	,(SELECT ClassifyNumberOfOffers from Fpdstypetable.ClassifyNumberOfOffers(
		l.numberofoffersreceived
		,l.UseFairOpportunity	--,@UseFairOpportunity as bit
		,l.ExtentIsSomeCompetition	--,@extentissomecompetition as bit
		,l.FairIsSomeCompetition	--,@fairissomecompetition as bit
		)) as ClassifyNumberOfOffers
      ,[ContractCrisisFunding]
      ,[nationalinterestactioncode]
	  ,[nationalinterestactioncodetext]
      ,[NIAcrisisFunding]
      ,[CrisisFunding]
	  ,ContingencyHumanitarianPeacekeepingOperation
	  ,ContingencyHumanitarianPeacekeepingOperationtext
	  ,ConHumIsOCOcrisisFunding
	  ,l.CCRexception
	  ,localareasetaside
   ,iif(NIAcrisisFunding='Disaster' or
		  ContractCrisisFunding='Disaster' or 
		  l.CCRexception = '3' --Contracting officers conductingemergency operations
		  --or l.localareasetaside='Y' --For disasters investigate this later.
		  ,1,0) as IsDisasterCrisisFunding
	,iif(NIAcrisisFunding='ARRA' or  ContractCrisisFunding='ARRA'
		or IsARRA=1,1,0) as IsARRAcrisisFunding
	,case 
	--National Intrest Action Code
	when NIAcrisisFunding='OCO'
	then 1
	--Manually labeled contract (not presently used)
	when ContractCrisisFunding='OCO'
	then 1
	--Labeled as Contigency or Huanitarian Operation
	when ConHumIsOCOcrisisFunding=1
	then 1
	--CCRexception is Contracting Officers deployed in the course of military operations
	when l.CCRexception = '4' --Contracting Officers deployed in the course of military operations
	then 1
	else NULL
	end as IsOCOcrisisFunding
	
	--OMB test for procurement and R&D with duration > 1 year
	, iif(l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366,1,0) as IsMultipleYearProcRnD
	

	--Point Version
	--Product or Service Code score and OMB standards. Up to 2 points, as little as -2 points
	--OMB standards 
	--Specifies stricter standard relacement, repair, modification, and procurement of equipment; 
	--New criteria specifying a 12-month time frame for obligating funds. 
	--Funding for research and development must be for projects required for combat operations in the theater that can be delivered in 12 months
	,iif(isnull(pscOCOcrisisScore,0) 
		- iif(l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366,1,0) >2,2,isnull(pscOCOcrisisScore,0)- iif(l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366,1,0))
	--Place of Performance and Contracting Office, up to 4 points, as little as -2 points
	+iif(isnull(placeOCOcrisisScore,0) + isnull(OfficeOCOcrisisScore,0) >4,4,
		isnull(placeOCOcrisisScore,0) + isnull(OfficeOCOcrisisScore,0))
	+round(isnull(PercentFundingAccountOCO,0)*4,0) as OCOcrisisScore
	,pscOCOcrisisScore
	,pscOCOcrisisPercent
	,placeOCOcrisisScore
	,IsOMBocoList
	,isforeign
	,PercentFundingAccountOCO
	,OfficeOCOcrisisScore
	,OfficeOCOcrisisPercent

	
	--DecisionTree
	,case
	--Step 1A
	when ContractCrisisFunding is not null 
	then ContractCrisisFunding
	--Step 1b 
	when ConHumIsOCOcrisisFunding=1
	then 'OCO'
	--Step 1C
	when NIAcrisisFunding is not null and
		(nationalinterestactioncode<>'W081' or --Excluding a majore ($26 billion mislabelling case)
		fiscal_year>=2008) 

	then NIAcrisisFunding 
	when PlaceCountryText in ('Afghanistan','Iraq')
	then 'OCO'
	when l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366
	then 'Excluded'
	when pscOCOcrisisScore=-1 or OfficeOCOcrisisScore=-1
	then 'Excluded'
	when (pscOCOcrisisPoint + FundingAccountOCOpoint + OfficeOCOcrisisPoint)>=1 and
		IsOMBocoList=1
	then 'OCO'
	when (pscOCOcrisisPoint + FundingAccountOCOpoint + OfficeOCOcrisisPoint)>=2 and
		PlaceIsInternational=1
	then 'OCO'
	when (pscOCOcrisisPoint + FundingAccountOCOpoint + OfficeOCOcrisisPoint)>=3
	then 'OCO'
	else NULL
	end as DecisionTree
	--DecisionTree
	,case
	--Step 1A
	when ContractCrisisFunding is not null 
	then ContractCrisisFunding
	--Step 1b 
	when ConHumIsOCOcrisisFunding=1
	then 'OCO'
	--Step 1C
	when NIAcrisisFunding is not null and
		(nationalinterestactioncode<>'W081' or --Excluding a majore ($26 billion mislabelling case)
		fiscal_year>=2008) 
	then NIAcrisisFunding 
	when PlaceCountryText in ('Afghanistan','Iraq')
	then 'OCO'
	when l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366
	then 'Excluded'
	when pscOCOcrisisScore=-1 or OfficeOCOcrisisScore=-1
	then 'Excluded'
	else NULL
	end as DecisionTreeStep4
	,pscOCOcrisisPoint
	,FundingAccountOCOpoint
	,OfficeOCOcrisisPoint
	   	,case 
		when l.UnmodifiedUltimateDuration is null or l.UnmodifiedUltimateDuration <0
		then NULL
		when l.UnmodifiedUltimateDuration <= 61 
		then '<=2 Months'
		when l.UnmodifiedUltimateDuration <= 214 
		then '>2-7 Months'
		when l.UnmodifiedUltimateDuration <= 366
		then '>7-12 Months'
		when l.UnmodifiedUltimateDuration <= 731
		then '>1-2 Years'
		when l.UnmodifiedUltimateDuration <= 1461
		then '>2-4 Years'
		else '>4 years'
	end as UnmodifiedUltimateDurationCategory

      ,[UnmodifiedUltimateDuration]
      ,bc.agencyname as OMBagencyName
	  ,bc.BureauCode as OMBbureauName
	  ,l.OMBagencycode
      ,l.[OMBbureaucode]
      ,[treasuryagencycode]
      ,[mainaccountcode]
      ,[subaccountcode]
	  ,[AccountTitle]
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerPartial] l
  left outer join agency.BureauCode bc
  on bc.OMBagencyCode=l.OMBagencycode and
  bc.BureauCode=l.OMBbureaucode
  











GO


