with
    order_item as (
        select * from {{ ref("int_polling_extract_item_orders") }}
    ),
    transactions as (
        select * from {{ ref("int_polling_extract_net_fee") }}
    ),

aggregated as (
select 
order_id,
string_agg(sku, ", ") as line_sku,
string_agg(product_name, ", ") as line_product_name,
string_agg(safe_cast(quantity as string), ", ") as line_quantity,
string_agg(safe_cast(thb_price as string), ", ") as line_price,
string_agg(safe_cast(thb_item_subtotal as string), ", ") as line_subtotal,
string_agg(safe_cast(thb_item_total as string), ", ") as line_total,
ARRAY_AGG(
        JSON_OBJECT(
            'id',CAST(id as int64),
            'quantity', quantity        
            )
    ) AS contents
from order_item
group by order_id
),
joined as (
select *
from transactions
left join
aggregated as a
using (order_id))

select *
from joined
