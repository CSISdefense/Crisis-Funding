USE [DIIG]
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
	  	 ,iif(addmodified=1 and ismodified=1,'Modified ','')+
		case
			when addmultipleorsingawardidc=1 
			then case 
				when multipleorsingleawardidc is null
				then 'Unlabeled '+AwardOrIDVcontractactiontype
				else multipleorsingleawardidc+' '+AwardOrIDVcontractactiontype
				--Blank multipleorsingleawardIDC
			end
			else AwardOrIDVcontractactiontype 
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
      ,[ContingencyHumanitarianPeacekeepingOperation]
      ,[ContingencyHumanitarianPeacekeepingOperationText]
      ,[ContractCrisisFunding]
      ,[nationalinterestactioncode]
      ,[nationalinterestactioncodeText]
      ,[NIAcrisisFunding]
      ,[CrisisFunding]
      ,[localareasetaside]
   ,iif(NIAcrisisFunding='Disaster' or
		  ContractCrisisFunding='Disaster' or 
		  l.CCRexception = '3' --Contracting officers conductingemergency operations
		  --or l.localareasetaside='Y' --For disasters investigate this later.
		  ,1,0) as IsDisasterCrisisFunding
	,iif(NIAcrisisFunding='ARRA' or  ContractCrisisFunding='ARRA',1,0) as IsARRAcrisisFunding
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
	,iif(isnull(pscOCOcrisiScore,0) 
		- iif(l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366,1,0) >2,2,isnull(pscOCOcrisiScore,0)- iif(l.OMBagencyCode=7 and l.OMBbureauCode in (15, 20) and --Procurement or RDT&E
		[UnmodifiedUltimateDuration]> 366,1,0))
	--Place of Performance and Contracting Office, up to 4 points, as little as -2 points
	+iif(isnull(placeOCOcrisisScore,0) + isnull(OfficeOCOcrisisScore,0) >4,4,
		isnull(placeOCOcrisisScore,0) + isnull(OfficeOCOcrisisScore,0))
	+round(isnull(PercentFundingAccountOCO,0)*4,0) as OCOcrisisScore
	,pscOCOcrisiScore
	,placeOCOcrisisScore
	,PercentFundingAccountOCO
	,OfficeOCOcrisisScore

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
  FROM [DIIG].[Vendor].[LocationVendorHistoryBucketSubCustomerPartial] l
  left outer join agency.BureauCode bc
  on bc.OMBagencyCode=l.OMBagencycode and
  bc.BureauCode=l.OMBbureaucode












GO


