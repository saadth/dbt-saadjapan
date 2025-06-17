with
    orders as (
        select * from {{ ref("stg_saad_woocommerce_api__raw_woocommerce_orders") }}
    ),

    items as (
        select
            o.order_id,
            o.status,
            o.date_modified,
            safe_cast(o.total as float64) as total,
            json_value(item_json, '$.sku') as sku,
            safe_cast(json_value(item_json, '$.quantity') as int64) as quantity,
            safe_cast(json_value(item_json, '$.subtotal') as float64) as subtotal
        from orders o, unnest(o.items_details) as item_json
    ),

    aggregated as (
        select
            order_id,
            status,
            date_modified,
            total,
            string_agg(sku, ", ") as line_sku,
            string_agg(safe_cast(quantity as string), ", ") as line_quantity,
            string_agg(safe_cast(subtotal as string), ", ") as line_subtotal,
            sum(quantity) as quantity,
            sum(subtotal) as subtotal,
        from items
        group by order_id, date_modified, status, total
    ),

    joined as (
        select a.*, o.* except (order_id, date_modified, status, total)
        from aggregated as a
        left join
            orders as o
            on a.order_id = o.order_id
            and a.status = o.status
            and a.date_modified = o.date_modified
    )

select *
from joined
