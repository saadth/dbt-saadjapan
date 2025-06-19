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
            json_value(raw_payload, '$.billing.first_name') as first_name,
            json_value(raw_payload, '$.billing.last_name') as last_name,
            json_value(raw_payload, '$.status') as status,
            safe_cast(json_value(raw_payload, '$.customer_id') as int64) as customer_id,
            json_value(raw_payload, '$.shipping.country') as country,
            json_value(raw_payload, '$.billing.email') as email,
            safe_cast(json_value(raw_payload, '$.shipping_total')as float64) as shipping_fee,
            safe_cast(json_value(raw_payload, '$.final_amount') as float64) as total,
            json_value(raw_payload, '$.currency') as currency,
            json_value(raw_payload, '$.payment_method') as payment_method,
            json_value(raw_payload, '$.created_via') as created_via,
            json_extract_array(raw_payload, '$.line_items') as items_details,
            json_extract_array(raw_payload, '$.meta_data') as meta_data,
        from source

    ),

    status_cleaned as (

        select *
        from renamed
        where status not in ('pos-open', 'pending') and total is not null
    ),

    duplicate_cleaned as (
        select * except (row_num)
        from
            (
                select
                    *,
                    row_number() over (
                        partition by order_id, status order by date_modified desc
                    ) as row_num
                from status_cleaned
            )
        where row_num = 1
    )

select *
from duplicate_cleaned
