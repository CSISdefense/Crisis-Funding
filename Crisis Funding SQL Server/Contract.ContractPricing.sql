/****** Object:  View [Contract].[ContractPricing]    Script Date: 3/27/2018 3:49:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER VIEW [Contract].[ContractPricing]
AS
select M.CSIScontractID
--TypeOfContractPricing
,iif(M.MinOfTypeOfContractPricing=MaxOfTypeOfContractPricing,
	MaxOfTypeOfContractPricing
	,NULL) as TypeOfContractPricing
,iif(M.MinOfUnmodifiedTypeOfContractPricing=MaxOfUnmodifiedTypeOfContractPricing,
	MaxOfUnmodifiedTypeOfContractPricing
	,NULL) as UnmodifiedTypeOfContractPricing
--IsLabeledPricing
,IsLabeledPricing
--IsFixedPrice
,ObligatedAmountIsFixedPrice
,iif(M.MinOfIsFixedPrice=MaxOfIsFixedPrice,
	MaxOfIsFixedPrice
	,NULL) as IsFixedPrice
,iif(M.MinOfUnmodifiedIsFixedPrice=MaxOfUnmodifiedIsFixedPrice,
	MaxOfUnmodifiedIsFixedPrice
	,NULL) as UnmodifiedIsFixedPrice
--IsCostBased	
,ObligatedAmountIsCostBased
,iif(M.MinOfIsCostBased	=MaxOfIsCostBased	,
	MaxOfIsCostBased	
	,NULL) as IsCostBased	
,iif(M.MinOfUnmodifiedIsCostBased	=MaxOfUnmodifiedIsCostBased	,
	MaxOfUnmodifiedIsCostBased	
	,NULL) as UnmodifiedIsCostBased	
--IsCombination=MaxOfIsCombination
,ObligatedAmountIsCombination
,iif(M.MinOfIsCombination=MaxOfIsCombination,
	MaxOfIsCombination
	,NULL) as IsCombination
,iif(M.MinOfUnmodifiedIsCombination=MaxOfUnmodifiedIsCombination,
	MaxOfUnmodifiedIsCombination
	,NULL) as UnmodifiedIsCombination
--IsIncentive
,ObligatedAmountIsIncentive
,iif(M.MinOfIsIncentive=MaxOfIsIncentive,
	MaxOfIsIncentive
	,NULL) as IsIncentive
,iif(M.MinOfUnmodifiedIsIncentive=MaxOfUnmodifiedIsIncentive,
	MaxOfUnmodifiedIsIncentive
	,NULL) as UnmodifiedIsIncentive
--IsAwardFee
,ObligatedAmountIsAwardFee
,iif(M.MinOfIsAwardFee=MaxOfIsAwardFee,
	MaxOfIsAwardFee
	,NULL) as IsAwardFee
,iif(M.MinOfUnmodifiedIsAwardFee=MaxOfUnmodifiedIsAwardFee,
	MaxOfUnmodifiedIsAwardFee
	,NULL) as UnmodifiedIsAwardFee
--IsFFPorNoFee
,ObligatedAmountIsFFPorNoFee
,iif(M.MinOfIsFFPorNoFee=MaxOfIsFFPorNoFee,
	MaxOfIsFFPorNoFee
	,NULL) as IsFFPorNoFee
,iif(M.MinOfUnmodifiedIsFFPorNoFee=MaxOfUnmodifiedIsFFPorNoFee,
	MaxOfUnmodifiedIsFFPorNoFee
	,NULL) as UnmodifiedIsFFPorNoFee
--IsFixedFee
,ObligatedAmountIsFixedFee
,iif(M.MinOfIsFixedFee=MaxOfIsFixedFee,
	MaxOfIsFixedFee
	,NULL) as IsFixedFee
,iif(M.MinOfUnmodifiedIsFixedFee=MaxOfUnmodifiedIsFixedFee,
	MaxOfUnmodifiedIsFixedFee
	,NULL) as UnmodifiedIsFixedFee
--IsOtherFee
,ObligatedAmountIsOtherFee
,iif(M.MinOfIsOtherFee=MaxOfIsOtherFee,
	MaxOfIsOtherFee
	,NULL) as IsOtherFee
,iif(M.MinOfUnmodifiedIsOtherFee=MaxOfUnmodifiedIsOtherFee,
	MaxOfUnmodifiedIsOtherFee
	,NULL) as UnmodifiedIsOtherFee
--IsUndefinitizedAction
,ObligatedAmountIsUndefinitizedAction
,iif(M.MinOfIsUndefinitizedAction=MaxOfIsUndefinitizedAction,
	MaxOfIsUndefinitizedAction
	,NULL) as IsUndefinitizedAction
,iif(M.MinOfUnmodifiedIsUndefinitizedAction=MaxOfUnmodifiedIsUndefinitizedAction,
	MaxOfUnmodifiedIsUndefinitizedAction
	,NULL) as UnmodifiedIsUndefinitizedAction

from (SELECT      
	ctid.CSIScontractID
	--TypeOfContractPricing
	, min(c.TypeOfContractPricing) as MinOfTypeOfContractPricing
	, max(c.TypeOfContractPricing) as MaxOfTypeOfContractPricing
	, min(iif(C.modnumber='0' or C.modnumber is null,c.TypeOfContractPricing,NULL)) as MinOfUnmodifiedTypeOfContractPricing
	, max(iif(C.modnumber='0' or C.modnumber is null,c.TypeOfContractPricing,NULL)) as MaxOfUnmodifiedTypeOfContractPricing
		--Competition Binaries IsFixedPrice
	, Max(convert(int,t.IsLabeled)) AS IsLabeledPricing
	--Competition Binaries IsFixedPrice
	,sum(iif(t.IsFixedPrice=1,ObligatedAmount,NULL)) as ObligatedAmountIsFixedPrice
	, Min(convert(int,t.IsFixedPrice)) AS MinOfIsFixedPrice
	, Max(convert(int,t.IsFixedPrice)) AS MaxOfIsFixedPrice
		, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsFixedPrice),NULL)) AS MinOfUnmodifiedIsFixedPrice
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsFixedPrice),NULL)) AS MaxOfUnmodifiedIsFixedPrice
	--Competition Binaries IsCostBased
	,sum(iif(t.IsCostBased=1,ObligatedAmount,NULL)) as ObligatedAmountIsCostBased
	,min(convert(int,t.IsCostBased)) as MinOfIsCostBased	
	,max(convert(int,t.IsCostBased)) as MaxOfIsCostBased	
	, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsCostBased),NULL)) AS MinOfUnmodifiedIsCostBased
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsCostBased),NULL)) AS MaxOfUnmodifiedIsCostBased
	--Competition Binaries IsCombination  #iif(c.TypeOfContractPricing=1
	,sum(iif(t.IsCombination=1,ObligatedAmount,NULL)) as ObligatedAmountIsCombination
	,min(convert(int,IsCombination)) as MinOfIsCombination
	,max(convert(int,IsCombination)) as MaxOfIsCombination
		, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsCombination),NULL)) AS MinOfUnmodifiedIsCombination
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsCombination),NULL)) AS MaxOfUnmodifiedIsCombination
	--IsIncentive
	,sum(iif(t.IsIncentive=1,ObligatedAmount,NULL)) as ObligatedAmountIsIncentive
	, Min(convert(int,t.IsIncentive)) AS MinOfIsIncentive
	, Max(convert(int,t.IsIncentive)) AS MaxOfIsIncentive
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsIncentive),NULL)) AS MinOfUnmodifiedIsIncentive
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsIncentive),NULL)) AS MaxOfUnmodifiedIsIncentive
	--IsAwardFee
	,sum(iif(t.IsAwardFee=1,ObligatedAmount,NULL)) as ObligatedAmountIsAwardFee
	, Min(convert(int,t.IsAwardFee)) AS MinOfIsAwardFee
	, Max(convert(int,t.IsAwardFee)) AS MaxOfIsAwardFee
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsAwardFee),NULL)) AS MinOfUnmodifiedIsAwardFee
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsAwardFee),NULL)) AS MaxOfUnmodifiedIsAwardFee
	--IsFFPorNoFee
	,sum(iif(t.IsFFPorNoFee=1,ObligatedAmount,NULL)) as ObligatedAmountIsFFPorNoFee
	, Min(convert(int,t.IsFFPorNoFee)) AS MinOfIsFFPorNoFee
	, Max(convert(int,t.IsFFPorNoFee)) AS MaxOfIsFFPorNoFee
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsFFPorNoFee),NULL)) AS MinOfUnmodifiedIsFFPorNoFee
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsFFPorNoFee),NULL)) AS MaxOfUnmodifiedIsFFPorNoFee
	--IsFixedFee
	,sum(iif(t.IsFixedFee=1,ObligatedAmount,NULL)) as ObligatedAmountIsFixedFee
	, Min(convert(int,t.IsFixedFee)) AS MinOfIsFixedFee
	, Max(convert(int,t.IsFixedFee)) AS MaxOfIsFixedFee
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsFixedFee),NULL)) AS MinOfUnmodifiedIsFixedFee
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsFixedFee),NULL)) AS MaxOfUnmodifiedIsFixedFee
	--IsOtherFee
	,sum(iif(t.IsOtherFee=1,ObligatedAmount,NULL)) as ObligatedAmountIsOtherFee
	, Min(convert(int,t.IsOtherFee)) AS MinOfIsOtherFee
	, Max(convert(int,t.IsOtherFee)) AS MaxOfIsOtherFee
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsOtherFee),NULL)) AS MinOfUnmodifiedIsOtherFee
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,t.IsOtherFee),NULL)) AS MaxOfUnmodifiedIsOtherFee
	--IsUndefinitizedAction
	,sum(iif(UCA.IsUndefinitizedAction=1,ObligatedAmount,NULL)) as ObligatedAmountIsUndefinitizedAction
	, Min(convert(int,UCA.IsUndefinitizedAction)) AS MinOfIsUndefinitizedAction
	, Max(convert(int,UCA.IsUndefinitizedAction)) AS MaxOfIsUndefinitizedAction
			, Min(iif(C.modnumber='0' or C.modnumber is null,convert(int,UCA.IsUndefinitizedAction),NULL)) AS MinOfUnmodifiedIsUndefinitizedAction
		, Max(iif(C.modnumber='0' or C.modnumber is null,convert(int,UCA.IsUndefinitizedAction),NULL)) AS MaxOfUnmodifiedIsUndefinitizedAction


  FROM contract.FPDS as C
  left outer join fpdstypetable.typeofcontractpricing t
  on c.typeofcontractpricing =t.typeofcontractpricing
  	left outer join FPDSTypeTable.lettercontract UCA
		on c.lettercontract=UCA.LetterContract

  left outer join contract.CSIStransactionID ctid
  on c.CSIStransactionID=ctid.CSIStransactionID
group by CSIScontractID ) as M

















GO


