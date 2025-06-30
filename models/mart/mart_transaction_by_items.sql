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
    where status = 'completed'
    order by date_modified asc
 )

select *
from organized