/****** Object:  View [Contract].[ContractCompetitionVehiclePartial]    Script Date: 3/26/2018 11:40:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER VIEW [Contract].[ContractCompetitionVehiclePartial]
AS   
SELECT ctid.CSIScontractID
		,iif(C.modnumber='0' or C.modnumber is null,1,0) as IsUnmodified
  		,notcompeted.isfollowontocompetedaction
		,notcompeted.is6_302_1exception
		,competed.IsFullAndOpen as ExtentIsFullAndOpen
		,competed.IsSomeCompetition as ExtentIsSomeCompetition
		,competed.isfollowontocompetedaction as ExtentIsfollowontocompetedaction
		,competed.isonlyonesource as ExtentIsonlyonesource
		,Fairopp.isfollowontocompetedaction as FairIsfollowontocompetedaction
		,Fairopp.isonlyonesource as FairIsonlyonesource
		,Fairopp.IsSomeCompetition as FairIsSomeCompetition
		,setaside.typeofsetaside2category
				--Number Of Offers
		, C.numberofoffersreceived	
		,CASE 
		--Award or IDV Type show only (�Definitive Contract�, �IDC�, �Purchase Order�)
			WHEN ctype.ForAwardUseExtentCompeted=1
				then 0 --Use extent competed
				--Award or IDV Type show only (�Delivery Order�, �BPA Call�)
				--IDV Part 8 or Part 13 show only (�Part 13�)
				--When  **Part 8 or Part 13  is not available!**
				--then 0 --Use extent competed

				--Award or IDV Type show only (�Delivery Order�)
				--IDV Multiple or Single Award IDV show only (�S�)
			when ctype.isdeliveryorder=1
					and isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =0
				then 0	
				--Fair Opportunity / Limited Sources show only (�Fair Opportunity Given�)
				--Award or IDV Type show only (�Delivery Order�)
				--IDV Type show only (�FSS�, �GWAC�, �IDC�)
				--	IDV Multiple or Single Award IDV show only (�M�)
			when idvtype.ForIDVUseFairOpportunity=1 and 
					ctype.isdeliveryorder=1 and 
					isnull(IDVmulti.ismultipleaward, Cmulti.ismultipleaward) =1
				then 1 --Use fair opportunity

			--	Number of Offers Received show only (�1�)
			-- Award or IDV Type show only (�BPA Call�, �BPA�)
			-- Part 8 or Part 13 show only (�Part 8�)
			--When  **Part 8 or Part 13  is not available!**
			--then 0 --Use extent competed
			when fairopp.statutoryexceptiontofairopportunitytext is not null
				then 1
			else 0
		end as UseFairOpportunity
		,isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) as multipleorsingleawardidc 
		--,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) as addmultipleorsingawardidc				
		--,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) as AwardOrIDVcontractactiontype
		,CType.Award_Type_Code
		,IDVtype.idv_type_code
		,iif(ctid.IsIDV=1 or ctid.CSISidvmodificationID is not null,1,0) as IsIDV
		,UCA.IsUndefinitizedAction
		,UCA.IsLetterContract
		,ObligatedAmount

	FROM Contract.FPDS AS C
	LEFT OUTER JOIN FPDSTypeTable.ProductOrServiceCode AS PSC 
		ON C.productorservicecode = PSC.ProductorServiceCode 
	LEFT OUTER JOIN FPDSTypeTable.AgencyID AS Agency 
		ON C.contractingofficeagencyid = Agency.AgencyID 
	LEFT OUTER JOIN FPDSTypeTable.TypeOfSetAside AS SetAside 
		ON C.typeofsetaside = SetAside.TypeOfSetAside 
		
	LEFT OUTER JOIN FPDSTypeTable.extentcompeted AS Competed 
		ON C.extentcompeted = Competed.extentcompeted 
	LEFT OUTER JOIN FPDSTypeTable.ReasonNotCompeted AS NotCompeted 
		ON C.reasonnotcompeted = NotCompeted.reasonnotcompeted 
	LEFT OUTER JOIN FPDSTypeTable.statutoryexceptiontofairopportunity as FairOpp 
		ON C.statutoryexceptiontofairopportunity=FAIROpp.statutoryexceptiontofairopportunity
	
	--Block of CSISIDjoins
	left join contract.csistransactionid as CTID
		on c.CSIStransactionID=ctid.CSIStransactionID
	left join contract.CSISidvmodificationID as idvmod
		on ctid.CSISidvmodificationID=idvmod.CSISidvmodificationID
	left join contract.CSISidvpiidID as idv
		on idv.CSISidvpiidID=idvmod.CSISidvpiidID
	--Block of vehicle lookups
	Left JOIN FPDSTypeTable.multipleorsingleawardidc as Cmulti
		on C.multipleorsingleawardidc=Cmulti.multipleorsingleawardidc
	Left JOIN FPDSTypeTable.multipleorsingleawardidc as IDVmulti
		on isnull(idvmod.multipleorsingleawardidc,idv.multipleorsingleawardidc)=IDVMulti.multipleorsingleawardidc
		Left JOIN FPDSTypeTable.Award_Type_Code as Atype
		on C.Award_Type_Code=Atype.Award_Type_Code
	Left JOIN FPDSTypeTable.ContractActionType as Ctype
		on C.ContractActionType=Ctype.ContractActionType
	Left JOIN FPDSTypeTable.ContractActionType as IDVtype
		on coalesce(c.parent_award_type_code,idvmod.idv_type_code,idv.idv_type_code)=IDVtype.idv_type_code
	left outer join FPDSTypeTable.lettercontract UCA
		on c.lettercontract=UCA.LetterContract















GO


