with
    transactions as (select * from {{ ref('int_polling_extract_net_fee') }}),
organized as (
    select
    order_id,
    date_created,
    date_modified,
    status,
    currency,
    customer_id,
    billing_email as email,
    shipping_first_name as first_name,
    shipping_last_name as ast_name,
    shipping_city as city,
    shipping_state as state,
    shipping_postcode as postcode,
    shipping_country as country,
    payment_method,
    created_via,
    cpos_source,
    cpos_payment_status,
    gender,
    age,
    reference,
    purchase_reason,
    extracted_exchange_rate as exchange_rate,
    thb_total,
    thb_discount_total,
    thb_final_amount
    from transactions)

select *
from organized