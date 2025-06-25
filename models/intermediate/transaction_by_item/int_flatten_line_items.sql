with
    orders as (
        select * from {{ ref("stg_saad_woocommerce_api__raw_woocommerce_orders") }}
    ),
flatten as(
select
    o.pk,
    if(json_value(item_json, '$.sku')='',json_value(item_json, '$.name'),json_value(item_json, '$.sku')) as sku,
    safe_cast(json_value(item_json, '$.quantity') as int64) as quantity,
    safe_cast(json_value(item_json, '$.subtotal') as float64) / safe_cast(json_value(item_json, '$.quantity') as int64) as price,
    safe_cast(json_value(item_json, '$.price') as float64) as price_after_discount,
    safe_cast(json_value(item_json, '$.subtotal') as float64) as subtotal,
    safe_cast(json_value(item_json, '$.total') as float64) as total,
    currency,
    created_via,
    payment_method
from orders o, unnest(o.items_details) as item_json
)

select *
from flatten