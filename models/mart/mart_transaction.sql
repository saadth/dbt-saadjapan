with
    xe as (select * from {{ ref('int_calculate_xe_thb') }}),

organized as (
select
order_id,
date_modified,
date_created,
status,
customer_id,
first_name,
last_name,
country,
email,
line_sku,
line_quantity,
quantity,
line_subtotal,
subtotal,
shipping_fee,
discount,
total,
currency,
thb_subtotal,
thb_shipping_fee,
thb_discount,
thb_total,
thb_fees,
thb_net,
exchange_rate,
payment_method,
created_via,
gender,
age,
nationality,
reference,
pos_user
from xe
where date_created > '2025-06-09'
order by date_created asc, order_id asc, date_modified asc
)

Select
*
from organized