with
    orders as (
        select * from {{ ref("int_polling_extract_net_fee") }}
    ),

unnested as (
    select
        o.*,
        SAFE_CAST(JSON_VALUE(item_json, '$.name') as string) as product_name,
        IF(
            JSON_VALUE(item_json, '$.sku') = '' OR JSON_VALUE(item_json, '$.sku') IS NULL,
            JSON_VALUE(item_json, '$.name'),
            JSON_VALUE(item_json, '$.sku')
        ) AS sku,

        IF(
            JSON_VALUE(item_json, '$.variation_id') = '' OR JSON_VALUE(item_json, '$.variation_id') IS NULL OR JSON_VALUE(item_json, '$.variation_id') = '0',
            JSON_VALUE(item_json, '$.product_id'),
            JSON_VALUE(item_json, '$.variation_id')
        ) AS product_id,        
        SAFE_CAST(JSON_VALUE(item_json, '$.quantity') AS INT64) AS quantity,
        SAFE_DIVIDE(
            (SAFE_CAST(JSON_VALUE(item_json, '$.subtotal') AS FLOAT64) + SAFE_CAST(JSON_VALUE(item_json, '$.subtotal_tax') AS FLOAT64)),
            SAFE_CAST(JSON_VALUE(item_json, '$.quantity') AS INT64)
        ) AS price,
        SAFE_CAST(JSON_VALUE(item_json, '$.subtotal') AS FLOAT64) + SAFE_CAST(JSON_VALUE(item_json, '$.subtotal_tax') AS FLOAT64) AS item_subtotal,
        SAFE_CAST(JSON_VALUE(item_json, '$.total') AS FLOAT64) + SAFE_CAST(JSON_VALUE(item_json, '$.total_tax') AS FLOAT64) AS item_total,
    FROM orders o, UNNEST(JSON_QUERY_ARRAY(line_items)) AS item_json
),

exchange_rate as (
    select
        *,
        SAFE_DIVIDE(
            SAFE_CAST(price AS FLOAT64),
            SAFE_CAST(extracted_exchange_rate AS FLOAT64)
        ) AS thb_price,
        SAFE_DIVIDE(
            SAFE_CAST(item_subtotal AS FLOAT64),
            SAFE_CAST(extracted_exchange_rate AS FLOAT64)
        ) AS thb_item_subtotal,
        SAFE_DIVIDE(
            SAFE_CAST(item_total AS FLOAT64),
            SAFE_CAST(extracted_exchange_rate AS FLOAT64)
        ) AS thb_item_total
    from unnested
)

select *
from exchange_rate