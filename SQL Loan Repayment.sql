use banking
go

;with xyz
as
(
select distinct
	 c.client_id client_id
	,d.account_id account_id
	,t.[type] [type]
	,case 
		when cast(substring(c.[birth_number],3,2)as int) - 50 between 0 and 9 then cast('19'+ left(c.[birth_number],2) + '0' + cast(cast(substring(c.[birth_number],3,2)as int) - 50 as varchar(2)) + right(c.[birth_number],2) as date)
		when cast(substring(c.[birth_number],3,2)as int) - 50 between 10 and 12 then cast('19'+ left(c.[birth_number],2) + cast(cast(substring(c.[birth_number],3,2)as int) - 50 as varchar(50)) + right(c.[birth_number],2) as date)
		else cast('19' +c.[birth_number] as date)
	end dob
	,convert(decimal(10,2),cast(l.[payments] as float)) loan_payment
	,cast('19' + t.[date] as date) trans_date
	,case
		when t.[type] like 'VYDAJ' then -1*cast(t.amount as decimal) 
		else cast(t.amount as decimal)
	end trans_amount
	,cast(t.balance as decimal) trans_balance
	,cast('19' + l.[date] as date) date_loan_start
	,cast(l.payments as decimal) loan_monthly_repayment
	,cast(l.[duration] as int) loan_duration
from dbo.client c
inner join dbo.disp d
on c.client_id = d.client_id
inner join dbo.account a
on d.account_id = a.account_id
inner join dbo.loan l
on a.account_id = l.account_id
inner join dbo.[order] o
on a.account_id = o.account_id
inner join dbo.trans t
on a.account_id = t.account_id
)
, loan_repayment
as
(
select --anchor query
	client_id
	,account_id
	,date_loan_start
	,loan_monthly_repayment
	,loan_duration
	,trans_amount
	,trans_balance
from xyz
union all

select --iterative query
	 client_id
	,account_id
	,dateadd(MM,1,date_loan_start) next_loan_payment_date
	,loan_monthly_repayment
	,loan_duration - 1 loan_duration
	,trans_amount
	,trans_balance - loan_monthly_repayment [trans_balance]
from loan_repayment	
where loan_duration > 0
)

select distinct top 100
	*
from loan_repayment
where client_id = 12095
--order by client_id asc