with orders as (
  select *
  from {{ ref('stg_saad_woocommerce_api__raw_woocommerce_orders') }}
),

items_exploded as (
  select
    o.order_id,
    o.total,
    item_json,
    JSON_VALUE(item_json, '$.sku') as sku,
    SAFE_CAST(JSON_VALUE(item_json, '$.quantity') AS INT64) as quantity,
    SAFE_CAST(JSON_VALUE(item_json, '$.subtotal') AS FLOAT64) as subtotal
  from orders o,
  UNNEST(o.items_details) as item_json  -- ✅ FIXED: no JSON_QUERY_ARRAY
),

aggregated as (
  select
    order_id,
    STRING_AGG(sku, ', ') as line_sku,
    STRING_AGG(CAST(quantity AS STRING), ', ') as line_quantity,
    STRING_AGG(CAST(subtotal AS STRING), ', ') as line_subtotal,
    SUM(quantity) as quantity,
    SUM(subtotal) as subtotal
  from items_exploded
  group by order_id
),

final as (
  select
    o.*,
    a.line_sku,
    a.line_quantity,
    a.line_subtotal,
    a.quantity,
    a.subtotal,
    SAFE_CAST(o.total AS FLOAT64) - a.subtotal as discount
  from orders o
  left join aggregated a using(order_id)
)

select * from final
