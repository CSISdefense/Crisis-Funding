select multipleorsingleawardidc
,multiple_or_single_award_idv_name
,award_type_code
,award_type_name
,idv_type_code
,idv_type_name
,parent_award_type_code
,parent_award_type_name
,parent_award_single_or_multiple_code
,parent_award_single_or_multiple_name
,sum(obligatedamount)
,count(*) as transactioncount
from errorlogging.FPDSbetaViolatesConstraint
group by multipleorsingleawardidc
,multiple_or_single_award_idv_name
,award_type_code
,award_type_name
,idv_type_code
,idv_type_name
,parent_award_type_code
,parent_award_type_name
,parent_award_single_or_multiple_code
,parent_award_single_or_multiple_name

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Unseperated]
      ,[contractactiontype]
      ,[contractactiontypeText]
      ,[addmultipleorsingawardidc]
      ,[addmodified]
      ,[ForAwardUseExtentCompeted]
      ,[ForIDVUseFairOpportunity]
      ,[isdeliveryorder]
  FROM [FPDSTypeTable].[ContractActionType]


  SELECT 	isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) as multipleorsingleawardidc 
		,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) as addmultipleorsingawardidc				
		,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) as AwardOrIDVcontractactiontype
		,iif(ctid.IsIDV=1 or ctid.CSISidvmodificationID is not null,1,0) as IsIDV
		,award_type_code
		,idv_type_code
		,parent_award_type_code
		,parent_award_single_or_multiple_code
		,sum(ObligatedAmount) as ObligatedAmount
	,count(*) as TransactionCount
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
		on coalesce(idvmod.multipleorsingleawardidc,idv.multipleorsingleawardidc)=IDVMulti.multipleorsingleawardidc
	Left JOIN FPDSTypeTable.ContractActionType as Ctype
		on C.ContractActionType=Ctype.unseperated
	Left JOIN FPDSTypeTable.ContractActionType as IDVtype
		on coalesce(idvmod.ContractActionType,idv.ContractActionType)=IDVtype.unseperated
	left outer join FPDSTypeTable.lettercontract UCA
		on c.lettercontract=UCA.LetterContract
		where fiscal_year=2015
		group by isnull(IDVmulti.multipleorsingleawardidctext, Cmulti.multipleorsingleawardidctext) 
		,isnull(IDVtype.addmultipleorsingawardidc,ctype.addmultipleorsingawardidc) 
		,isnull(idvtype.contractactiontypetext,ctype.contractactiontypetext) 
		,iif(ctid.IsIDV=1 or ctid.CSISidvmodificationID is not null,1,0) 
		,award_type_code
		,idv_type_code
		,parent_award_type_code
		,parent_award_single_or_multiple_code
		