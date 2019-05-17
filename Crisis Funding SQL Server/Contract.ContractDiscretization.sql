ALTER VIEW [Contract].[ContractDiscretization]
AS

SELECT 
	ccid.IDVPIID
	,ccid.piid
	,isnull(ccid.ContractLabelID,ciid.contractlabelid) as ContractLabelID
	,iif(nullif(ciid.idvpiid,'') is null,0,1) as IsIDV
	,total.CSIScontractID
	,total.StartFiscal_Year
	,total.MinOfFiscal_Year
	,total.maxoffiscal_year
	,total.CountofModnumber
	,Total.SumOfnumberOfActions
	,Total.SumofObligatedAmount
	,total.IsModified
	,total.IsTerminated
	--Dates
	,total.MaxOfSignedDate
	,total.MinOfSignedDate
	,total.MaxOfEffectiveDate
	,total.MinOfEffectiveDate
	--ProductOrServiceCodes
	,isAnyRnD1to5
	,obligatedAmountRnD1to5
	,firstSignedDateRnD1to5
	,UnmodifiedRnD1to5
	--Unmodified
	,total.UnmodifiedCurrentCompletionDate
	,total.UnmodifiedLastDateToOrder
	,total.UnmodifiedUltimateCompletionDate
	,case
	--No exercised options data
	when  SumOfUnmodifiedbaseandexercisedoptionsvalue is null or SumOfUnmodifiedbaseandexercisedoptionsvalue <=0
	then null 
	--No total ceiling data
	when SumOfUnmodifiedbaseandalloptionsvalue is null or SumOfUnmodifiedbaseandalloptionsvalue  <=0
	then null
	--Spending exceeds 
	when isnull(SumOfUnmodifiedobligatedAmount,0) > SumOfUnmodifiedbaseandexercisedoptionsvalue  
	then null
	--No gap
	when SumOfUnmodifiedbaseandexercisedoptionsvalue >= SumOfUnmodifiedbaseandalloptionsvalue  
	then 0
	when SumOfUnmodifiedbaseandexercisedoptionsvalue < SumOfUnmodifiedbaseandalloptionsvalue  
	then 1
	end as AnyUnmodifiedUnexercisedOptions
	,case
	--No exercised options data
	when  SumOfUnmodifiedbaseandexercisedoptionsvalue is null or SumOfUnmodifiedbaseandexercisedoptionsvalue <=0
	then 'No exercise' 
	--No total ceiling data
	when SumOfUnmodifiedbaseandalloptionsvalue is null or SumOfUnmodifiedbaseandalloptionsvalue  <=0
	then 'No all'
	--Spending exceeds 
	when isnull(SumOfUnmodifiedobligatedAmount,0) > SumOfUnmodifiedbaseandexercisedoptionsvalue  
	then 'Spending>exercise'
	--No gap
	when SumOfUnmodifiedbaseandexercisedoptionsvalue >= SumOfUnmodifiedbaseandalloptionsvalue  
	then 'exercise >= all'
	when SumOfUnmodifiedbaseandexercisedoptionsvalue < SumOfUnmodifiedbaseandalloptionsvalue  
	then 'exercise < all'
	else 'Else'
	end as AnyUnmodifiedUnexercisedOptionsWhy

	,ExercisedOptions
	--Change Order
	,total.SumOfisChangeOrder
	,total.MaxOfisChangeOrder
	,ChangeOrderObligatedAmount
	,ChangeOrderBaseAndExercisedOptionsValue
	,ChangeOrderBaseAndAllOptionsValue
	,ChangeOrderCeilingGrowth
	--New Work
	,total.SumOfisNewWork
	,total.MaxOfisNewWork
	,NewWorkObligatedAmount
	,NewWorkBaseAndExercisedOptionsValue
	,NewWorkBaseAndAllOptionsValue
	--Closed
	,total.IsClosed
	,ClosedObligatedAmount
	,ClosedBaseAndExercisedOptionsValue
	,ClosedBaseAndAllOptionsValue
	--OffersReceive
		,iif(total.MinOfUnmodifiedNumberOfOffersReceived=total.MaxOfUnmodifiedNumberOfOffersReceived,
			total.MinOfUnmodifiedNumberOfOffersReceived,
			NULL
		) as UnmodifiedNumberOfOffersReceived
		,(SELECT size from contract.ClassifyContractSize(Total.SumofObligatedAmount)) as SizeOfObligatedAmount
		,Total.SumOfbaseandexercisedoptionsvalue
		,(SELECT size from contract.ClassifyContractSize(Total.SumOfbaseandexercisedoptionsvalue)) as SizeofSumofbaseandexercisedoptionsvalue
		,Total.SumOfbaseandalloptionsvalue
		,(SELECT size from contract.ClassifyContractSize(Total.SumOfbaseandalloptionsvalue)) as SizeofSumOfbaseandalloptionsvalue
		, Total.SumofUnmodifiedObligatedAmount
		,(SELECT size from contract.ClassifyContractSize(Total.SumofUnmodifiedObligatedAmount)) as SizeOfUnmodifiedObligatedAmount
		,Total.SumOfUnmodifiedbaseandexercisedoptionsvalue
		,(SELECT size from contract.ClassifyContractSize(Total.SumOfUnmodifiedbaseandexercisedoptionsvalue)) as SizeOfUnmodifiedSumOfbaseandexercisedoptionsvalue
		,Total.SumOfUnmodifiedbaseandalloptionsvalue
		,(SELECT size from contract.ClassifyContractSize(Total.SumOfUnmodifiedbaseandalloptionsvalue)) as SizeOfUnmodifiedSumOfbaseandalloptionsvalue
	FROM (
	SELECT 
		ccid.CSIScontractID
		, iif(min(iif(rmod.ismodified=1,1,0))=0,min(c.fiscal_year),NULL) as StartFiscal_Year
		, min(c.fiscal_year) as MinOfFiscal_Year
		, max(c.fiscal_year) as MaxOfFiscal_Year
		, min(effectivedate) as MinOfEffectivedate
		, max(effectivedate) as MaxOfEffectivedate
		, min(signeddate) as MinOfSignedDate
		, max(signeddate) as MaxOfSignedDate
		, max(currentcompletiondate) as MaxOfCurrentCompletionDate
		, max(ultimatecompletiondate) as MaxOfUltimateCompletionDate
		, max(lastdatetoorder) as MaxOfLastDateToOrder
		, Count(DISTINCT C.modnumber) as CountofModnumber
		, Sum(C.obligatedAmount) AS SumOfobligatedAmount
		, Sum(C.numberOfActions) AS SumOfnumberOfActions
		, Sum(C.baseandexercisedoptionsvalue) AS SumOfbaseandexercisedoptionsvalue
		, Sum(C.baseandalloptionsvalue) AS SumOfbaseandalloptionsvalue

		--ProductOrServiceCode
		, max(iif(psc.isRnD1to5=1,1,iif(psc.isRnD1to5=0,0,NULL))) as isAnyRnD1to5
		, sum(iif(psc.isRnD1to5=1,C.obligatedAmount,null)) as obligatedAmountRnD1to5
		, min(iif(psc.isRnD1to5=1,C.signeddate,null)) as firstSignedDateRnD1to5
		, max(iif((C.modnumber='0' or C.modnumber is null),iif(psc.isRnD1to5=1,1,iif(psc.isRnD1to5=0,0,null)),null)) AS UnmodifiedRnD1to5

		--Unmodified
		, Sum(iif(C.modnumber='0' or C.modnumber is null,C.obligatedAmount,0)) AS SumOfUnmodifiedobligatedAmount
		, Sum(iif(C.modnumber='0' or C.modnumber is null,C.baseandexercisedoptionsvalue,0)) AS SumOfUnmodifiedbaseandexercisedoptionsvalue
		, Sum(iif(C.modnumber='0' or C.modnumber is null,C.baseandalloptionsvalue,0)) AS SumOfUnmodifiedbaseandalloptionsvalue
		, min(iif(C.modnumber='0' or C.modnumber is null,C.currentcompletiondate,NULL)) AS UnmodifiedCurrentCompletionDate
		, min(iif(C.modnumber='0' or C.modnumber is null,C.ultimatecompletiondate,NULL)) AS UnmodifiedUltimateCompletionDate
		, min(iif(C.modnumber='0' or C.modnumber is null,C.lastdatetoorder,NULL)) AS UnmodifiedLastDateToOrder

		--Change Orders
		, max(iif(rmod.isChangeOrder=1,1,0)) as MaxOfisChangeOrder
		, sum(iif(rmod.isChangeOrder=1,1,0)) as SumOfisChangeOrder
		, Sum(iif(rmod.isChangeOrder=1,C.obligatedAmount,0)) AS ChangeOrderObligatedAmount
		, Sum(iif(rmod.isChangeOrder=1,C.baseandexercisedoptionsvalue,0)) AS ChangeOrderBaseAndExercisedOptionsValue
		, Sum(iif(rmod.isChangeOrder=1,C.baseandalloptionsvalue,0)) AS ChangeOrderBaseAndAllOptionsValue
		, sum(iif(rmod.isChangeOrder=1 and 
			baseandalloptionsvalue>=0
		,baseandalloptionsvalue,0)) as ChangeOrderCeilingGrowth
		--New Work
		, max(iif(rmod.isNewWork=1,1,0)) as MaxOfisNewWork
		, sum(iif(rmod.isNewWork=1,1,0)) as SumOfisNewWork
		, Sum(iif(rmod.isNewWork=1,C.obligatedAmount,0)) AS NewWorkObligatedAmount
		, Sum(iif(rmod.isNewWork=1,C.baseandexercisedoptionsvalue,0)) AS NewWorkBaseAndExercisedOptionsValue
		, Sum(iif(rmod.isNewWork=1,C.baseandalloptionsvalue,0)) AS NewWorkBaseAndAllOptionsValue

		--Exercised Options
		, sum(iif(rmod.MayBeExercisedOption=1 and 
			baseandexercisedoptionsvalue>0 and
			baseandalloptionsvalue<=0
		,baseandexercisedoptionsvalue,0)) as ExercisedOptions

		--Closed
		, max(iif(rmod.isClosed=1,1,0)) as IsClosed
		, Sum(iif(rmod.isClosed=1,C.obligatedAmount,0)) AS ClosedObligatedAmount
		, Sum(iif(rmod.isClosed=1,C.baseandexercisedoptionsvalue,0)) AS ClosedBaseAndExercisedOptionsValue
		, Sum(iif(rmod.isClosed=1,C.baseandalloptionsvalue,0)) AS ClosedBaseAndAllOptionsValue
	
		--Number Of Offers
		, Min(iif(C.modnumber='0' or C.modnumber is null,C.numberofoffersreceived,0)) AS MinOfUnmodifiedNumberOfOffersReceived
		, Max(iif(C.modnumber='0' or C.modnumber is null,C.numberofoffersreceived,0)) AS MaxOfUnmodifiedNumberOfOffersReceived
		, max(iif(rmod.isTerminated=1,1,0)) as IsTerminated
		, max(iif(rmod.ismodified=1,1,0)) as IsModified
	
		FROM Contract.FPDS as C
		left outer join FPDStypetable.productorservicecode psc
			on c.productorservicecode=psc.productorservicecode
		left outer join FPDSTypeTable.reasonformodification rmod
			on rmod.reasonformodification=c.reasonformodification
		inner join contract.CSIStransactionID ctid
			on c.CSIStransactionID=ctid.CSIStransactionID
		inner join contract.CSIScontractID ccid
			on ctid.CSIScontractID=ccid.CSIScontractID
	
		GROUP BY ccid.CSIScontractID
	) as TOTAL
inner join contract.CSIScontractID ccid
	on total.CSIScontractID=ccid.CSIScontractID
inner join contract.CSISidvpiidID ciid
	on ccid.CSISidvpiidID=ciid.CSISidvpiidID





GO
