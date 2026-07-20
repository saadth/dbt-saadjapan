with
    transactions as (select * from {{ ref('int_polling_extract_item_orders') }}),
organized as (
    select
    order_id,
    customer_id,
    product_id,
    date_modified,
    date_created,
    status,
    product_name,
    sku,
    quantity,
    currency,
    created_via,
    gender,
    age,
    nationality,
    reference,
    purchase_reason,
    purchase_location,
    shipping_country as purchased_country,
    shipping_address_1,
    payment_method,
    extracted_exchange_rate as exchange_rate,
    thb_price,
    thb_item_subtotal,
    thb_item_total,
    
    from transactions)

select *
from organized
where date_created > '2025-08-18'
order by date_created desc