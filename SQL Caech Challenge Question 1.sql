use banking
go

select top 10 * from dbo.account



select -- account
	cast(account_id as int) account_id
	,cast(district_id as int) district_id 
	,case
		when rtrim(ltrim(upper([frequency]))) like 'POPLATEK MESICNE' then 'Monthly Issuance'
		when rtrim(ltrim(upper([frequency]))) like 'POPLATEK TYDNE' then 'Weekly Issuance'
		when rtrim(ltrim(upper([frequency]))) like 'POPLATEK PO OBRATU' then 'Issuance After Transaction'
	end frequency_of_statement_issuance
	,cast('19' +[date] as date) account_creation_date
from dbo.account


select top 100 -- card
	 cast(["card_id"] as int) card_id
	 ,cast(["disp_id"] as int) disp_id
	,cast('19' + left(["issued"],6) as date) date_of_issue
	,["type"]
from dbo.card

select top 100 -- client
	cast(client_id as int) client_id
	,case 
		when cast(substring([birth_number],3,2)as int) - 50 between 0 and 9 then cast('19'+ left([birth_number],2) + '0' + cast(cast(substring([birth_number],3,2)as int) - 50 as varchar(2)) + right([birth_number],2) as date)
		when cast(substring([birth_number],3,2)as int) - 50 between 10 and 12 then cast('19'+ left([birth_number],2) + cast(cast(substring([birth_number],3,2)as int) - 50 as varchar(50)) + right([birth_number],2) as date)
		else cast('19' +[birth_number] as date)
	end dob
	,case 
		when cast(substring([birth_number],3,2)as int) < 50 then 'M'
		else 'F'
	end gender
from dbo.client

select top 100 -- disposition
	cast(disp_id as int) disp_id
	,cast(client_id as int) client_id
	,cast(account_id as int) account_id
	,case
		when ltrim(rtrim(upper([type]))) like 'OWNER' then 'permanent orders and loan permission'
		when ltrim(rtrim(upper([type]))) like 'USER' then 'no permissions'
		else null
	end permission_allowed
from dbo.disp

select top 100 -- district
	 [A1] as district_identifier
	,[A2] as district_name
	,[A3] as region
	,[A4] as no_inhabitants
	,[A5] as no_of_municipalities_people_0_to_499
	,[A6] as no_of_municipalities_people_500_1999
	,[A7] as no_of_municipalities_people_2000_to_9999
	,[A8] as no_of_municipalities_people_10000_or_more
	,[A9] as no_of_cities
	,[A10] as ratio_urban_inhabitants
	,[A11] as average_salary
	,[A12] as unemployment_rate_1995
	,[A13] as unemployment_rate_1996
	,[A14] as no_enterpreneurs_per_1000_inhabitants
	,[A15] as no_crimes_commited_1995
	,[A16] as no_crimes_commited_1996
from dbo.district

select  --loan
	cast(loan_id as int) disp_id
	,cast(account_id as int) account_id
	,cast(('19' +[date]) as date) date_loan_granted
	,cast(amount as int) amount
	,cast(duration as int) duration
	,convert(decimal(10,2),cast(payments as float)) payments
	,case
		when upper([status]) like 'A' then 'contract finished, no problems'
		when upper([status]) like 'B' then 'contract finished, loan unpaid'
		when upper([status]) like 'C' then 'running contract, OK so far'
		when upper([status]) like 'D' then 'running contract, client in debt'
		else null
	end loan_status_translation
from dbo.loan

select top 100 --permanent orders
	cast(order_id as int) order_id
	,cast(account_id as int) account_id
	,convert(decimal(10,2),cast(amount as float)) amount
	,case
		when ltrim(rtrim(upper([k_symbol]))) like 'POJISTNE' then 'insurance'
		when ltrim(rtrim(upper([k_symbol]))) like 'SIPO' then 'household'
		when ltrim(rtrim(upper([k_symbol]))) like 'LEASING' then 'leasing'
		when ltrim(rtrim(upper([k_symbol]))) like 'UVER' then 'loan'
		else null
	end payment_type
from dbo.[order]


select -- transaction
	cast(trans_id as int) trans_id
	,cast(account_id as int) account_id
	,cast('19'+date as date) [date]
	,case
		when upper([type]) like 'PRIJEM' then 'credit'
		when upper([type]) like 'VYDAJ' then 'debit (withdrawal)'
		else null
	end debit_or_credit_transaction
	,case
		when upper([operation]) like 'VYBER KARTOU' then 'credit card withdrawal'
		when upper([operation]) like 'VKLAD' then 'credit in cash'
		when upper([operation]) like 'PREVOD Z UCTU' then 'collection from another bank'
		when upper([operation]) like 'VYBER' then 'withdrawal in cash'
		when upper([operation]) like 'PREVOD NA UCET' then 'remittance to another bank'
		else null
	end mode_of_transaction
	,convert(decimal(10,2),cast(amount as float)) amount
	,convert(decimal(10,2),cast(balance as float)) balance
	,case
		when upper([k_symbol]) like 'POJISTNE' then 'insurance payment'
		when upper([k_symbol]) like 'SLUZBY' then 'payment of statement'
		when upper([k_symbol]) like 'UROK' then 'interest credited'
		when upper([k_symbol]) like 'SANKC. UROK' then 'sanction interest if negative balance'
		when upper([k_symbol]) like 'SIPO' then 'household payment'
		when upper([k_symbol]) like 'DUCHOD' then 'old-age pension payment'
		when upper([k_symbol]) like 'UVER' then 'loans payment'
		else null
	end characterisation_of_transaction
	,nullif(bank,'') bank
	,nullif(account,'') account
from dbo.trans
