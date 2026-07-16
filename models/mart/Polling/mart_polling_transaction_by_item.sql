with
    transactions as (select * from {{ ref('int_polling_extract_item_orders') }}),
organized as (
    select
    order_id,
    id as product_id,
    date_modified,
    date_created,
    status,
    product_name,
    sku,
    quantity,
    currency,
    created_via,
    payment_method,
    extracted_exchange_rate as exchange_rate,
    thb_price,
    thb_subtotal,
    thb_total,
    from transactions)

select *
from organized
where date_created > '2025-08-18'
order by date_created desc