with
    orders as (
        select * from {{ ref("stg_saad_woocommerce_api__raw_woocommerce_orders") }}
    )

select
    o.order_id,
    o.date_modified,
    o.status,
    json_value(item_json, '$.sku') as sku,
    safe_cast(json_value(item_json, '$.quantity') as int64) as quantity,
    safe_cast(json_value(item_json, '$.subtotal') as float64) as subtotal,
from orders o, unnest(o.items_details) as item_json
