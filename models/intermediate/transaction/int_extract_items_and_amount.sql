with
    extract_meta_data as (
        select * from {{ ref("int_extract_meta_data") }}
    ),

    items as (
        select
            m.pk,
            if(json_value(item_json, '$.sku')='',json_value(item_json, '$.name'),json_value(item_json, '$.sku')) as sku,
            safe_cast(json_value(item_json, '$.quantity') as int64) as quantity,
            safe_cast(json_value(item_json, '$.subtotal') as float64) as subtotal
        from extract_meta_data m, unnest(m.items_details) as item_json
    ),

    aggregated as (
        select
            pk,
            string_agg(sku, ", ") as line_sku,
            string_agg(safe_cast(quantity as string), ", ") as line_quantity,
            string_agg(safe_cast(subtotal as string), ", ") as line_subtotal,
            sum(quantity) as quantity,
            sum(subtotal) as subtotal,
        from items
        group by pk
    ),

    joined as (
        select *
        from extract_meta_data as m
        left join
            aggregated as a
            using (pk)
    ),

discount as (
        select *,
        (total-(subtotal+shipping_fee)) as discount
        from joined
)
select *
from discount
