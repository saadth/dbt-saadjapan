with orders as(
select *
from {{ ref('stg_saad_woocommerce_api__raw_woocommerce_orders') }}),

status_cleaned as (

        select *
        from orders
        where status not in ('pos-open', 'pending') and total is not null
    ),

    test_cleaned as (

        select *
        from status_cleaned
        where lower(first_name) not in ('test')
    ),

    duplicate_cleaned as (
        select * except (row_num)
        from
            (
                select
                    *,
                    row_number() over (
                        partition by order_id, status order by date_modified desc
                    ) as row_num
                from test_cleaned
            )
        where row_num = 1
    ),

make_pk as(
select
*,
concat(safe_cast(order_id as string),'_',status) as pk
from duplicate_cleaned)

select 
*
from make_pk