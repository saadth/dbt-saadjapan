with
    transactions as (select * from {{ ref('int_polling_add_line_items_to_transaction') }}),
organized as (
    select
    order_number,
    date_created,
    date_modified,
    status,
    currency,
    customer_id,
    billing_email as email,
    shipping_first_name as first_name,
    shipping_last_name as last_name,
    shipping_address_1 as address_1,
    purchase_location,
    shipping_city as city,
    shipping_state as state,
    shipping_postcode as postcode,
    shipping_country as purchased_country,
    payment_method,
    created_via,
    cpos_source,
    cpos_payment_status,
    gender,
    age,
    nationality,
    reference,
    purchase_reason,
    extracted_exchange_rate as exchange_rate,
    thb_discount_total,
    thb_total,
    total_refund,
    thb_final_amount,
    line_sku,
    line_product_name,
    line_quantity,
    line_price,
    line_subtotal,
    line_total,
    from transactions)

select *
from organized
order by date_created desc