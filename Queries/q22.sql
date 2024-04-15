-- TPC TPC-H Parameter Substitution (Version 2.17.0 build 0)
-- using default substitutions
create view if not exists q22_customer_tmp_cached as
select
	c_acctbal,
	c_custkey,
	substr(c_phone, 1, 2) as cntrycode
from
	customer
where
	substr(c_phone, 1, 2) = '13' or
	substr(c_phone, 1, 2) = '31' or
	substr(c_phone, 1, 2) = '23' or
	substr(c_phone, 1, 2) = '29' or
	substr(c_phone, 1, 2) = '30' or
	substr(c_phone, 1, 2) = '18' or
	substr(c_phone, 1, 2) = '17';
 
create view if not exists q22_customer_tmp1_cached as
select
	avg(c_acctbal) as avg_acctbal
from
	q22_customer_tmp_cached
where
	c_acctbal > 0.00;

create view if not exists q22_orders_tmp_cached as
select
	o_custkey
from
	orders
group by
	o_custkey;

select
	cntrycode,
	count(1) as numcust,
	sum(c_acctbal) as totacctbal
from (
	select
		cntrycode,
		c_acctbal,
		avg_acctbal
	from
		q22_customer_tmp1_cached ct1 join (
			select
				cntrycode,
				c_acctbal
			from
			q22_customer_tmp_cached ct
				left outer join q22_orders_tmp_cached ot
				on ot.o_custkey = ct.c_custkey 
			where
				o_custkey is null
		) ct2
) a
where
	c_acctbal > avg_acctbal
group by
	cntrycode
order by
	cntrycode;
	
--drop view q22_customer_tmp_cached;
--drop view q22_customer_tmp1_cached;
--drop view q22_orders_tmp_cached ;
