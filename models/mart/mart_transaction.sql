with
    meta_data as (select * from {{ ref('int_extract_meta_data') }}),

thb_conversion as (
    select
    * except(items_details,meta_data),
    safe_cast(total as float64) * safe_cast(exchange_rate as float64) as thb_total,
    safe_cast(subtotal as float64) * safe_cast(exchange_rate as float64) as thb_subtotal,
    safe_cast(shipping_fee as float64) * safe_cast(exchange_rate as float64) as thb_shipping_fee,
    safe_cast(discount as float64) * safe_cast(exchange_rate as float64) as thb_discount
    from meta_data
),

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
from thb_conversion
order by date_created asc
)

Select
*
from organized