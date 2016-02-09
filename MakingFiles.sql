/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP 1000 [ID]
      ,[ProgramElement]
      ,[ProgramElementTitle]
      ,[BudgetActivity]
      ,[BudgetActivityTitle]
      ,[Account]
      ,[Classified]
      ,[FiscalYear]
      ,[PB]
      ,[App]
      ,[Actual]
      ,[CR]
      ,[CR_OCO]
      ,[OCO_PB]
      ,[OCO_App]
      ,[OCO_Sup]
  FROM [LWV].[dbo].[Long_RnD_Budget_Database_Export]



   select distinct ProgramElement
	  ,ProgramElementTitle
      ,classified
	 into dbo.ProgramElement
	FROM [LWV].[dbo].[Long_RnD_Budget_Database_Export] r
	 

	  select *
  from [LWV].[dbo].[ProgramElement] p
  where p.programelement in 
  (select ProgramElement
  FROM [LWV].[dbo].[ProgramElement]
  group by ProgramElement
  having count(*)>=2)
  order by programelement




  --Delete Cases where in one case classified is label and in the other it is null
  	delete p
  from [LWV].[dbo].[ProgramElement] p
  where p.programelement in 
  (select ProgramElement
  FROM [LWV].[dbo].[ProgramElement]
  group by ProgramElement
  having count(*)>=2 and max(classified) = 'U') and classified=''
  
  --Delete other duplicates based on examination. The BAs are avaialble for detailed breakdown 
  	delete p
  from [LWV].[dbo].[ProgramElement] p
  where p.programelement in 
  (select ProgramElement
  FROM [LWV].[dbo].[ProgramElement]
  group by ProgramElement
  having count(*)>=2 ) 
  and ProgramElementTitle in ('Precision Attack Systems Procurement' -- Precision Attack Systems 
  ,'Integrated Broadcast Service - Dem/Val' -- Integrated Broadcast Service
  ,'Other Programs' -- Classified Programs
  ,'SOF Technology Development' -- Special Operations Technology Development
  ,'SOF Advanced Technology Development' -- Special Operations Advanced Technology Development
  ,'Next Generation Aerial Refueling Aircraft' -- KC-46
  ,'Test, Evaluation Science and Technology' -- Test & Evaluation Science & Technology
  ,'Joint Spectrum Center' -- Defense Spectrum Organization
  ,'Intelligence Support to Information Operations (IO) (JMIP)' -- Cyber Intelligence
  )
  
  
  select *
  from dbo.Long_RnD_Budget_Database_Export
  where ProgramElement in ('0303153K','0305193F' )
  order by ProgramElement, FiscalYear

	--These two have multiple BAs and have different titles depending on the BAs

  update [LWV].[dbo].[ProgramElement] 
  set ProgramElementTitle = 'Defense Spectrum Organization / Joint Spectrum Center'
  where programelement='0303153K' and programelementtitle='Defense Spectrum Organization'

  update [LWV].[dbo].[ProgramElement] 
  set ProgramElementTitle = 'Cyber Intelligence / Intelligence Support to Information Operations (IO) (JMIP)'
  where programelement='0305193F' and programelementtitle='Cyber Intelligence'

	alter table dbo.ProgramElement
	alter column ProgramElement varchar(10) not null


		alter table dbo.Long_RnD_Budget_Database_Export
		add constraint FK_ProgramElement foreign key (programelement) references dbo.ProgramElement(ProgramElement)
	  

   select distinct account
   , [BudgetActivity]
      ,[BudgetActivityTitle]
      --,[Account]
	 --into dbo.ProgramElement
	  into dbo.BudgetActivityAccount
	FROM [LWV].[dbo].[Long_RnD_Budget_Database_Export] r
	  order by budgetactivity

	alter table dbo.BudgetActivityAccount
	alter column account smallint not null



	alter table dbo.BudgetActivityAccount
	alter column BudgetActivity smallint not null

	alter table dbo.ProgramElement
	add constraint pk_PrimaryElement primary key (ProgramElement)
	  
	alter table dbo.BudgetActivityAccount
	add constraint pk_BudgetActivity primary key (account,BudgetActivity)



select *
from [LWV].[dbo].BudgetActivityAccount p
order by BudgetActivity

 select *
  from [LWV].[dbo].BudgetActivityAccount p
  inner join 
  (select [BudgetActivity],Account
  FROM [LWV].[dbo].BudgetActivityAccount
  group by [BudgetActivity],Account
  having count(*)>=2) d
  on p.budgetactivity=d.budgetactivity
  and p.account=d.account
  order by p.[BudgetActivity],p.Account





delete p
   from [LWV].[dbo].BudgetActivityAccount p
  inner join 
  (select [BudgetActivity],Account
  FROM [LWV].[dbo].BudgetActivityAccount
  group by [BudgetActivity],Account
  having count(*)>=2) d
  on p.budgetactivity=d.budgetactivity
  and p.account=d.account
  where BudgetActivityTitle=''

  delete p
   from [LWV].[dbo].BudgetActivityAccount p
  inner join 
  (select [BudgetActivity],Account
  FROM [LWV].[dbo].BudgetActivityAccount
  group by [BudgetActivity],Account
  having count(*)>=2) d
  on p.budgetactivity=d.budgetactivity
  and p.account=d.account
  where BudgetActivityTitle in ('Research, Development, Test, And Evaluation'
	,'Advanced Component Development And Prototypes'
	,'Operational system development'
	,'Management Support'
	,'Advanced Technology Development'
	,'System Development And Demonstration')


alter table dbo.Long_RnD_Budget_Database_Export
		add constraint FK_BudgetActivityAccount foreign key (account,BudgetActivity) references dbo.BudgetActivityAccount(account,BudgetActivity)
	  
