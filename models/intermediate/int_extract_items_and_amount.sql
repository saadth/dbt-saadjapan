with orders as (
  select *
  from {{ ref('stg_saad_woocommerce_api__raw_woocommerce_orders') }}
),

items as(
 select
    o.order_id,
    o.status,
    o.date_modified,
    SAFE_CAST(o.total as FLOAT64) as total,
    JSON_VALUE(item_json, '$.sku') as sku,
    SAFE_CAST(JSON_VALUE(item_json, '$.quantity') AS INT64) as quantity,
    SAFE_CAST(JSON_VALUE(item_json, '$.subtotal') AS FLOAT64) as subtotal
  from orders o,
  UNNEST(o.items_details) as item_json),

aggregated as(
  select
  order_id,
  status,
  date_modified,
  total,
  string_agg(sku,", ") as line_sku,
  string_agg(SAFE_CAST(quantity as string),", ") as line_quantity,
  string_agg(SAFE_CAST(subtotal as string),", ") as line_subtotal,
  sum(quantity) as quantity,
  sum(subtotal) as subtotal,
  from items
  group by order_id, date_modified, status, total )

joined as (
  select
    a.*,
    o.* except(order_id, date_modified , status, total)
  from aggregated as a
  left join orders as o 
  on a.order_id=o.order_id and a.status=o.status and a.date_modified=o.date_modified
)

select *
from joined