-- TPC TPC-H Parameter Substitution (Version 2.17.0 build 0)
-- using default substitutions


select c_orders.c_count, count(*) as custdist
from
(
    select c_custkey, count(o_orderkey) as c_count
    from customer left outer join orders
    on c_custkey = o_custkey and o_comment not like '%special%requests%'
    group by c_custkey
) as c_orders
group by c_orders.c_count
order by custdist desc, c_orders.c_count desc;
