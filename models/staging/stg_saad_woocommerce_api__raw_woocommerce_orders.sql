with

    source as (

        select * from {{ source("saad_woocommerce_api", "raw_woocommerce_orders") }}

    ),

    renamed as (
        select
            safe_cast(id as int64) as order_id,
            DATETIME(json_value(raw_payload, '$.date_modified')) as date_modified,
            extract(
                date from timestamp(json_value(raw_payload, '$.date_created'))
            ) as date_created,
            safe_cast(json_value(raw_payload, '$.billing.first_name') as string) as first_name,
            safe_cast(json_value(raw_payload, '$.billing.last_name') as string) as last_name,
            safe_cast(json_value(raw_payload, '$.status') as string) as status,
            safe_cast(json_value(raw_payload, '$.customer_id') as int64) as customer_id,
            safe_cast(json_value(raw_payload, '$.shipping.country') as string) as country,
            safe_cast(json_value(raw_payload, '$.billing.email') as string) as email,
            safe_cast(json_value(raw_payload, '$.shipping_total')as float64) as shipping_fee,
            safe_cast(json_value(raw_payload, '$.final_amount') as float64) as total,
            safe_cast(json_value(raw_payload, '$.currency') as string) as currency,
            safe_cast(json_value(raw_payload, '$.payment_method') as string) as payment_method,
            safe_cast(json_value(raw_payload, '$.created_via') as string) as created_via,
            json_extract_array(raw_payload, '$.line_items') as items_details,
            json_extract_array(raw_payload, '$.meta_data') as meta_data,
        from source

    )

select 
*
from renamed
