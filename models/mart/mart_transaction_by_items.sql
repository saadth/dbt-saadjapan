with
    joined_xe as (select * from {{ ref('int_join_xe_and_convert') }}),

organized as (
    select 
    order_id,
    date_modified,
    date_created,
    status,
    sku,
    quantity,
    price,
    price_after_discount,
    subtotal,
    total,
    currency,
    exchange_rate,
    thb_price,
    thb_price_after_discount,
    thb_subtotal,
    thb_total,
    created_via,
    payment_method
    
    from joined_xe
    where status = 'completed' and date_created > '2025-06-09'
    order by date_created asc , order_id asc
 )

select *
from organized