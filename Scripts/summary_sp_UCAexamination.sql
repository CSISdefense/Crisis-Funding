select lc.IsUndefinitizedAction
,lc.UndefinitizedActionText
,f.lettercontract
,a.Customer
,f.fiscal_year
,a.SubCustomer
,sum(f.obligatedamount) as obligatedamount
,count(ctid.csistransactionid) as transactioncount
,count(distinct ctid.csiscontractid) as contactcount
from contract.fpds f
left outer join FPDSTypeTable.lettercontract lc
on f.lettercontract=lc.LetterContract
left outer join FPDSTypeTable.AgencyID a
on f.contractingofficeagencyid=a.AgencyID
left outer join contract.csistransactionid ctid
on f.CSIStransactionID=ctid.CSIStransactionID
where a.Customer='Defense' 
group by lc.IsUndefinitizedAction
,lc.UndefinitizedActionText
,a.Customer
,f.lettercontract
,a.Customer
,f.fiscal_year
,a.SubCustomer




select lc.IsUndefinitizedAction
,a.Customer
,f.fiscal_year
,sum(f.obligatedamount) as obligatedamount
,count(ctid.csistransactionid) as transactioncount
,count(distinct ctid.csiscontractid) as contactcount
from contract.fpds f
left outer join FPDSTypeTable.lettercontract lc
on f.lettercontract=lc.LetterContract
left outer join FPDSTypeTable.AgencyID a
on f.contractingofficeagencyid=a.AgencyID
left outer join contract.csistransactionid ctid
on f.CSIStransactionID=ctid.CSIStransactionID
where a.Customer='Defense' 
group by lc.IsUndefinitizedAction
,a.Customer
,f.fiscal_year
