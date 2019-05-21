/****** Object:  View [Contract].[ContractUnmodifiedCompetitionVehicle]    Script Date: 4/10/2018 5:34:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









ALTER VIEW [Contract].[ContractUnmodifiedCompetitionVehicle]
AS
select M.CSIScontractID
--NumberOfOffersReceived
,iif(M.MinOfNumberOfOffersReceived=MaxOfNumberOfOffersReceived,
	MaxOfNumberOfOffersReceived
	,NULL) as UnmodifiedNumberOfOffersReceived
--IsFullAndOpen
,iif(M.MinOfIsFullAndOpen=MaxOfIsFullAndOpen,
	MaxOfIsFullAndOpen
	,NULL) as UnmodifiedIsFullAndOpen
--IsSomeCompetition	
,iif(M.MinOfIsSomeCompetition	=MaxOfIsSomeCompetition	,
	MaxOfIsSomeCompetition	
	,NULL) as UnmodifiedIsSomeCompetition	
--IsOnlyOneSource=MaxOfIsOnlyOneSource
,iif(M.MinOfIsOnlyOneSource=MaxOfIsOnlyOneSource,
	MaxOfIsOnlyOneSource
	,NULL) as UnmodifiedIsOnlyOneSource
--IsFollowonToCompetedAction
,iif(M.MinOfIsFollowonToCompetedAction=MaxOfIsFollowonToCompetedAction,
	MaxOfIsFollowonToCompetedAction
	,NULL) as UnmodifiedIsFollowonToCompetedAction
--IsUrgency
,iif(M.MinOfIsUrgency=MaxOfIsUrgency,
	MaxOfIsUrgency
	,NULL) as UnmodifiedIsUrgency
--multipleorsingleawardidc
,iif(M.MinOfmultipleorsingleawardidc=MaxOfmultipleorsingleawardidc,
	MaxOfmultipleorsingleawardidc
	,NULL) as Unmodifiedmultipleorsingleawardidc
--addmultipleorsingawardidc
--,iif(M.MinOfaddmultipleorsingawardidc=MaxOfaddmultipleorsingawardidc,
--	MaxOfaddmultipleorsingawardidc
--	,NULL) as Unmodifiedaddmultipleorsingawardidc
----AwardOrIDVcontractactiontype
--,iif(M.MinOfAwardOrIDVcontractactiontype=MaxOfAwardOrIDVcontractactiontype,
--	MaxOfAwardOrIDVcontractactiontype
--	,NULL) as UnmodifiedAwardOrIDVcontractactiontype
--	,MaxOfIsUndefinitizedAction
--Award_Type_Code
,iif(M.MinOfAward_Type_Code=MaxOfAward_Type_Code,
	MaxOfAward_Type_Code
	,NULL) as unmodifiedAward_Type_Code
--MaxOfidv_type_code
,iif(M.MinOfidv_type_code=MaxOfidv_type_code,
	MaxOfidv_type_code
	,NULL) as unmodifiedidv_type_code

from (SELECT      
	c.CSIScontractID
     /* ,C.extentcompeted5Category
      ,C.reasonnotcompeted4category
      ,C.extentcompetedtext
	  ,C.ReasonNotCompetedtext*/	
	
	--Number Of Offers
	, Min(nullif(C.numberofoffersreceived,0)) AS MinOfNumberOfOffersReceived
	, Max(nullif(C.numberofoffersreceived,0)) AS MaxOfNumberOfOffersReceived
	--Competition Binaries IsFullAndOpen
	, Min(convert(int,iif(c.UseFairOpportunity=1
		,0
		,c.ExtentIsFullAndOpen
	))) AS MinOfIsFullAndOpen
	, Max(convert(int,iif(c.UseFairOpportunity=1
		,0
		,c.ExtentIsFullAndOpen
	))) AS MaxOfIsFullAndOpen
	
	--Competition Binaries IsSomeCompetition
	,min(convert(int,iif(c.UseFairOpportunity=1
		,isnull(c.FairIsSomeCompetition,c.ExtentIsSomeCompetition)
		,isnull(c.ExtentIsSomeCompetition,c.FairIsSomeCompetition)
	))) as MinOfIsSomeCompetition	
	,max(convert(int,iif(c.UseFairOpportunity=1
		,isnull(c.FairIsSomeCompetition,c.ExtentIsSomeCompetition)
		,isnull(c.ExtentIsSomeCompetition,c.FairIsSomeCompetition)
	))) as MaxOfIsSomeCompetition	
		--Competition Binaries IsOnlyOneSource
	,min(convert(int,iif(c.UseFairOpportunity=1
		,coalesce(c.FairIsonlyonesource,c.ExtentIsOnlyOneSource,c.is6_302_1exception)
		,coalesce(c.ExtentIsOnlyOneSource,c.is6_302_1exception,c.FairIsonlyonesource)
	))) as MinOfIsOnlyOneSource
	,max(convert(int,iif(c.UseFairOpportunity=1
		,coalesce(c.FairIsonlyonesource,c.ExtentIsOnlyOneSource,c.is6_302_1exception)
		,coalesce(c.ExtentIsOnlyOneSource,c.is6_302_1exception,c.FairIsonlyonesource)
	))) as MaxOfIsOnlyOneSource
	--Competition Binaries IsFollowonToCompetedAction
	,min(convert(int,iif(c.UseFairOpportunity=1
		,coalesce(c.FairIsfollowontocompetedaction,c.Extentisfollowontocompetedaction,c.isfollowontocompetedaction)
		,coalesce(c.Extentisfollowontocompetedaction,c.isfollowontocompetedaction,c.FairIsfollowontocompetedaction)
	))) as MinOfIsFollowonToCompetedAction
	,max(convert(int,iif(c.UseFairOpportunity=1
		,coalesce(c.FairIsfollowontocompetedaction,c.Extentisfollowontocompetedaction,c.isfollowontocompetedaction)
		,coalesce(c.Extentisfollowontocompetedaction,c.isfollowontocompetedaction,c.FairIsfollowontocompetedaction)
	))) as MaxOfIsFollowonToCompetedAction
	--Competition Binaries IsUrgency
	,max(convert(int,iif(c.UseFairOpportunity=1
		,coalesce(c.FairIsUrgency,c.IsUrgency)
		,coalesce(c.IsUrgency,c.FairIsUrgency)
	))) as MaxOfIsUrgency
	,min(convert(int,iif(c.UseFairOpportunity=1
		,coalesce(c.FairIsUrgency,c.IsUrgency)
		,coalesce(c.IsUrgency,c.FairIsUrgency)
	))) as MinOfIsUrgency
	--Vehicle
	, Min(C.multipleorsingleawardidc) AS MinOfmultipleorsingleawardidc
	, Max(C.multipleorsingleawardidc) AS MaxOfmultipleorsingleawardidc
	--, Min(convert(int,C.addmultipleorsingawardidc)) AS MinOfaddmultipleorsingawardidc
	--, Max(convert(int,C.addmultipleorsingawardidc)) AS MaxOfaddmultipleorsingawardidc
	--, Min(C.AwardOrIDVcontractactiontype) AS MinOfAwardOrIDVcontractactiontype
	--, Max(C.AwardOrIDVcontractactiontype) AS MaxOfAwardOrIDVcontractactiontype
	--, Max(convert(int,C.IsUndefinitizedAction)) as MaxOfIsUndefinitizedAction
		, Min(C.Award_Type_Code) AS MinOfAward_Type_Code
	, Max(C.Award_Type_Code) AS MaxOfAward_Type_Code
		, Min(C.idv_type_code) AS MinOfidv_type_code
	, Max(C.idv_type_code) AS MaxOfidv_type_code

  FROM contract.[ContractCompetitionVehiclePartial] as C
  where c.[IsUnmodified]=1
group by CSIScontractID ) as M











GO


