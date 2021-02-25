/****** Script for SelectTopNRows command from SSMS  ******/
SELECT min([fiscal_year]) as MinOffiscal_year
,max([fiscal_year]) as MaxOffiscal_year
      ,[CSIScontractID]
      --,[ContractingCustomer]
      --,[ContractingSubCustomer]
      --,[ContractingAgencyText]
      --,[ContractingAgencyID]
      --,[FundingAgency]
      --,[FundingSubAgency]
      --,[MajorCommandID]
      --,[ContractingOfficeID]
      --,[ContractingOfficeName]
      --,[ContractingOfficeCity]
      --,[ContractingOfficeState]
      --,[ContractingOfficeCountry]
      --,[ContractingOfficeStartDate]
      --,[ContractingOfficeEndDate]
      --,[ServicesCategory]
      --,[IsService]
      --,[Simple]
      --,[ProductOrServiceArea]
      --,[DoDportfolio]
      --,[ProductOrServiceCode]
      --,[ProductOrServiceCodeText]
      --,[HostNation3Category]
      --,[isforeignownedandlocated]
      --,[isforeigngovernment]
      --,[isinternationalorganization]
      --,[organizationaltype]
      --,[PlaceIsInternational]
      --,[PlaceCountryText]
      --,[PlaceISOalpha3]
      --,[CrisisFundingTheater]
      --,[OriginIsInternational]
      --,[OriginCountryText]
      --,[VendorIsInternational]
      --,[VendorCountryText]
      --,[placeofmanufactureText]
      --,[OriginUSAIDregion]
      --,[VendorUSAIDregion]
      --,[PlaceUSAIDregion]
      --,[GuessUSAIDregion]
      --,[VendorPlaceType]
      --,[VendorSize]
      ,sum([obligatedAmount]) as [obligatedAmount]
      ,sum([numberOfActions]) as [numberOfActions]
      --,[TypeofContractPricingtext]
      --,[ReasonNotIsfollowontocompetedaction]
      --,[is6_302_1exception]
      --,[reasonnotcompetedText]
      --,[ExtentIsFullAndOpen]
      --,[ExtentIsSomeCompetition]
      --,[ExtentIsonlyonesource]
      --,[ExtentIsfollowontocompetedaction]
      --,[FairIsfollowontocompetedaction]
      --,[FairIsonlyonesource]
      --,[FairIsSomeCompetition]
      --,[statutoryexceptiontofairopportunityText]
      --,[typeofsetaside2category]
      --,[NumberOfOffersReceived]
      --,[UseFairOpportunity]
      --,[multipleorsingleawardidc]
      --,[Award_Type_Code]
      --,[idv_type_code]
      --,[Award_Type_Name]
      --,[idv_type_Name]
      --,[IDVtypeofIDC]
      --,[IsModified]
      --,[IsUndefinitizedAction]
      --,[IsLetterContract]
      --,[ContingencyHumanitarianPeacekeepingOperation]
      --,[ContingencyHumanitarianPeacekeepingOperationText]
      --,[ConHumIsOCOcrisisFunding]
      ,max(iif([ContractCrisisFunding]='ARRA',1,0)) as ContractCrisisFundingIsARRA
	   ,sum(iif([ContractCrisisFunding]='ARRA',[obligatedAmount],NULL)) as ContractCrisisFundingIsARRAObligated
      --,[nationalinterestactioncode]
      --,[nationalinterestactioncodeText]
      --,[NIAcrisisFunding]
      ,max(iif([RFisARRA]=1,1,0)) as RFisARRA
	  ,sum(iif([RFisARRA]=1,[obligatedAmount],NULL)) as RFisARRAObligated
      --,[CrisisFunding]
      --,[localareasetaside]
      --,[CCRexception]
      --,[pscOCOcrisisScore]
      --,[placeOCOcrisisScore]
      --,[IsOMBocoList]
      --,[isforeign]
      --,[pscOCOcrisisPercent]
      --,[pscOCOcrisisPoint]
      --,[PercentFundingAccountOCO]
      --,[FundingAccountOCOpoint]
      --,[OfficeOCOcrisisScore]
      --,[OfficeOCOcrisisPercent]
      --,[OfficeOCOcrisisPoint]
      --,[UnmodifiedUltimateDuration]
      --,[OMBagencycode]
      --,[OMBbureaucode]
      --,[treasuryagencycode]
      --,[mainaccountcode]
      --,[subaccountcode]
      --,[AccountTitle]
  FROM [Vendor].[LocationVendorHistoryBucketSubCustomerPartial]
  group by [CSIScontractID]
  having max(iif([ContractCrisisFunding]='ARRA',1,0)) =1 or max(iif([RFisARRA]=1,1,0)) =1