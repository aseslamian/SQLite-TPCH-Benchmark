-- TPC TPC-H Parameter Substitution (Version 2.17.0 build 0)
-- using default substitutions


with q17_avg as (
    select
        l_partkey,
        0.2 * avg(l_quantity) as t_avg_quantity
    from
        lineitem
        inner join part on l_partkey = p_partkey
    where
        p_brand = 'Brand#23'
        and p_container = 'MED BOX'
    group by
        l_partkey
)

select cast(sum(l_extendedprice) / 7.0 as decimal(32,2)) as avg_yearly
from
    lineitem
    inner join part on lineitem.l_partkey = p_partkey
    inner join q17_avg on q17_avg.l_partkey = lineitem.l_partkey
where 
    p_brand = 'Brand#23'
    and p_container = 'MED BOX'
    and l_quantity < t_avg_quantity;