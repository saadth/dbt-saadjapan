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
fees as thb_fees,
net as thb_net,
exchange_rate,
payment_method,
created_via,
gender,
age,
nationality,
reference,
pos_user
from xe
order by date_created asc
)

Select
*
from organized