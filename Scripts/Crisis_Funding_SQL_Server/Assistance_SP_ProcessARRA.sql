alter PROCEDURE [Assistance].[SP_ProcessARRA]
as

--Find Unmatched Rows
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

update t
set ContractLabelID=case
when t.ContractLabelID is null
then 1057 --ARRA
when t.ContractLabelID =6
then 1058 --ARRA ZBL
else t.ContractLabelID --Otherwise remain the seme
end
from contract.ARRAcontractIdentifiers a
inner join contract.CSISidvpiidID i
on a.ReferencedIDVPIID=i.idvpiid
inner join contract.csiscontractid c
on c.CSISidvpiidID=i.CSISidvpiidID
and c.piid=a.PIID
inner join Contract.CSIStransactionID t
on t.CSIScontractID=c.CSIScontractID
and t.modnumber=a.ModificationNumber
and (t.transactionnumber=a.TransactionNumber or 
	(t.transactionnumber is null and a.TransactionNumber is null))
left outer join Contract.ContractLabelID l
on t.ContractLabelID=l.ContractLabelID
where l.CrisisFunding  is null or l.CrisisFunding <>'ARRA'


--List all rows with existing labels
select i.CSISidvpiidID
,i.ContractLabelID as iContractLabelID
,c.CSIScontractID
,c.ContractLabelID as CContractLabelID
,t.CSIStransactionID 
,t.ContractLabelID as TContractLabelID
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
left outer join Contract.ContractLabelID l
on t.ContractLabelID=l.ContractLabelID
where ((l.CrisisFunding  is null or l.CrisisFunding <>'ARRA')
	and
	t.ContractLabelID is not null) or 
	c.ContractLabelID is not null or 
	i.ContractLabelID is not null

select *
from contract.ContractLabelID
where ContractLabelID in (6,1051,1057,1058)


select transactionnumber 
from Contract.ARRAcontractIdentifiers
where try_convert(bigint, transactionnumber ) is null
and transactionnumber  is not null

--update Contract.ARRAcontractIdentifiers
--set transactionnumber=NULL
--where transactionnumber='NA'

