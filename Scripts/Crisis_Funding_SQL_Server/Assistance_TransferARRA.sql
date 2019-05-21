alter PROCEDURE [Assistance].[SP_ProcessARRA]
as

--
select i.CSISidvpiidID
,c.CSIScontractID
,t.CSIStransactionID
,a.ReferencedIDVPIID
,a.PIID
,a.ModificationNumber
,a.TransactionNumber
from contract.ARRAcontractIdentifiers a
left outer join contract.CSISidvpiidID i
on a.ReferencedIDVPIID=i.idvpiid
left outer join contract.csiscontractid c
on c.CSISidvpiidID=i.CSISidvpiidID
and c.piid=a.PIID
left outer join Contract.CSIStransactionID t
on t.CSIScontractID=c.CSIScontractID
and t.modnumber=a.ModificationNumber
and (t.transactionnumber=a.TransactionNumber or 
	(t.transactionnumber is null and a.TransactionNumber is null))
where t.CSIStransactionID is null


select i.CSISidvpiidID
,c.CSIScontractID
,t.CSIStransactionID
,a.ReferencedIDVPIID
,a.PIID
,a.ModificationNumber
,a.TransactionNumber
from contract.ARRAcontractIdentifiers a
left outer join contract.CSISidvpiidID i
on a.ReferencedIDVPIID=i.idvpiid
left outer join contract.csiscontractid c
on c.CSISidvpiidID=i.CSISidvpiidID
and c.piid=a.PIID
left outer join Contract.CSIStransactionID t
on t.CSIScontractID=c.CSIScontractID
and t.modnumber=a.ModificationNumber
and (t.transactionnumber=a.TransactionNumber or 
	(t.transactionnumber is null and a.TransactionNumber is null))
where t.CSIStransactionID is null




select transactionnumber 
from Contract.ARRAcontractIdentifiers
where try_convert(bigint, transactionnumber ) is null
and transactionnumber  is not null

alter table Contract.ARRAcontractIdentifiers
alter column TransactionNumber bigint

update Contract.ARRAcontractIdentifiers
set transactionnumber=NULL
where transactionnumber='NA'

