/****** Object:  View [Contract].[ContractCompetitionVehicle]    Script Date: 3/27/2018 3:51:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











ALTER VIEW [Contract].[ContractCompetitionVehicle]
AS
select M.CSIScontractID
--NumberOfOffersReceived
,iif(M.MinOfNumberOfOffersReceived=MaxOfNumberOfOffersReceived,
	MaxOfNumberOfOffersReceived
	,NULL) as NumberOfOffersReceived
,iif(M.MinOfUseFairOpportunity=MaxOfUseFairOpportunity,
	MaxOfUseFairOpportunity
	,NULL) as UseFairOpportunity
--IsFullAndOpen
,iif(M.MinOfIsFullAndOpen=MaxOfIsFullAndOpen,
	MaxOfIsFullAndOpen
	,NULL) as IsFullAndOpen
--IsSomeCompetition	
,ObligatedAmountIsSomeCompetition
,iif(M.MinOfIsSomeCompetition	=MaxOfIsSomeCompetition	,
	MaxOfIsSomeCompetition	
	,NULL) as IsSomeCompetition	
--IsOnlyOneSource=MaxOfIsOnlyOneSource
,iif(M.MinOfIsOnlyOneSource=MaxOfIsOnlyOneSource,
	MaxOfIsOnlyOneSource
	,NULL) as IsOnlyOneSource
--IsFollowonToCompetedAction
,iif(M.MinOfIsFollowonToCompetedAction=MaxOfIsFollowonToCompetedAction,
	MaxOfIsFollowonToCompetedAction
	,NULL) as IsFollowonToCompetedAction
--IsIDV
,iif(M.MinOfIsIDV=MaxOfIsIDV,
	MaxOfIsIDV
	,NULL) as IsIDV
--multipleorsingleawardidc
,iif(M.MinOfmultipleorsingleawardidc=MaxOfmultipleorsingleawardidc,
	MaxOfmultipleorsingleawardidc
	,NULL) as MultipleOrSingleAwardIDC
--addmultipleorsingawardidc
--,iif(M.MinOfaddmultipleorsingawardidc=MaxOfaddmultipleorsingawardidc,
--	MaxOfaddmultipleorsingawardidc
--	,NULL) as AddMultipleOrSingleAwardIDC
--AwardOrIDVcontractactiontype
--,iif(M.MinOfAwardOrIDVcontractactiontype=MaxOfAwardOrIDVcontractactiontype,
--	MaxOfAwardOrIDVcontractactiontype
--	,NULL) as AwardOrIDVcontractActionType
--Award_Type_Code
,iif(M.MinOfAward_Type_Code=MaxOfAward_Type_Code,
	MaxOfAward_Type_Code
	,NULL) as Award_Type_Code
--MaxOfidv_type_code
,iif(M.MinOfidv_type_code=MaxOfidv_type_code,
	MaxOfidv_type_code
	,NULL) as idv_type_code

from (SELECT      
	c.CSIScontractID
     /* ,C.extentcompeted5Category
      ,C.reasonnotcompeted4category
      ,C.extentcompetedtext
	  ,C.ReasonNotCompetedtext*/	
	
	--Number Of Offers
	, Min(nullif(C.numberofoffersreceived,0)) AS MinOfNumberOfOffersReceived
	, Max(nullif(C.numberofoffersreceived,0)) AS MaxOfNumberOfOffersReceived
	--UseFairOpportunity
	, min(c.UseFairOpportunity) as MinOfUseFairOpportunity
	, max(c.UseFairOpportunity) as MaxOfUseFairOpportunity
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
	,sum(iif((c.UseFairOpportunity=1 and isnull(c.FairIsSomeCompetition,c.ExtentIsSomeCompetition)=1) or 
			(c.UseFairOpportunity=0 and isnull(c.ExtentIsSomeCompetition,c.FairIsSomeCompetition)=1)
			,ObligatedAmount
			,NULL) 
	) as ObligatedAmountIsSomeCompetition
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
	--Vehicle
	, Min(C.multipleorsingleawardidc) AS MinOfmultipleorsingleawardidc
	, Max(C.multipleorsingleawardidc) AS MaxOfmultipleorsingleawardidc
	, Min(convert(int,C.IsIDV)) AS MinOfIsIDV
	, Max(convert(int,C.IsIDV)) AS MaxOfIsIDV
	--, Min(convert(int,C.addmultipleorsingawardidc)) AS MinOfaddmultipleorsingawardidc
	--, Max(convert(int,C.addmultipleorsingawardidc)) AS MaxOfaddmultipleorsingawardidc
	, Min(C.Award_Type_Code) AS MinOfAward_Type_Code
	, Max(C.Award_Type_Code) AS MaxOfAward_Type_Code
		, Min(C.idv_type_code) AS MinOfidv_type_code
	, Max(C.idv_type_code) AS MaxOfidv_type_code

  FROM contract.[ContractCompetitionVehiclePartial] as C
group by CSIScontractID ) as M













GO


