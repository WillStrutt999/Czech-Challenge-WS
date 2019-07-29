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
	,cast(l.amount as int) loan_amount
	,cast(('19' +l.[date]) as date) date_loan_granted
	,convert(decimal(10,2),cast(l.[payments] as float)) loan_payment
	,cast('19' + t.[date] as date) trans_date
	,case
		when t.[type] like 'VYDAJ' then -1*convert(decimal(10,2),(cast(t.amount as float))) 
		else convert(decimal(10,2),(cast(t.amount as float)))
	end trans_amount
	,convert(decimal(10,2),(cast(t.balance as float))) trans_balance
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
, abc
as
(
select distinct
	 client_id
	,account_id
	,[type]
	,case
		when datediff(yy,dob,trans_date) between 0 and 9 then '0-9'
		when datediff(yy,dob,trans_date) between 10 and 19 then '10-19'
		when datediff(yy,dob,trans_date) between 20 and 29 then '20-29'
		when datediff(yy,dob,trans_date) between 30 and 39 then '30-39'
		when datediff(yy,dob,trans_date) between 40 and 49 then '40-49'
		when datediff(yy,dob,trans_date) between 50 and 59 then '50-59'
		when datediff(yy,dob,trans_date) between 60 and 69 then '60-69'
		when datediff(yy,dob,trans_date) between 70 and 79 then '70-79'
		when datediff(yy,dob,trans_date) between 80 and 89 then '80-89'
		else '90+'
	end age_bins_trans
	,loan_amount
	,trans_amount
	,trans_balance 
from xyz
where trans_balance < 0
)

select distinct
	  age_bins_trans
	 ,round(count(*) over(partition by age_bins_trans)/cast(count(*) over() as float)*100,2) percentage_people_in_bin_in_negative_balance
	 ,avg(trans_balance) over (partition by age_bins_trans) account_balance
from abc
order by account_balance