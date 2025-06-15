with 

source as (

    select * from {{ source('saad_woocommerce_api', 'raw_woocommerce_orders') }}

),

renamed as (
    Select
    CAST(id as int64) as order_id,
    JSON_VALUE(raw_payload, '$.date_modified') as date_modified,
    JSON_VALUE(raw_payload, '$.date_modified') as dummy,
    extract( date from timestamp(JSON_VALUE(raw_payload, '$.date_created'))) as date_created,
    JSON_VALUE(raw_payload, '$.billing.first_name') as first_name,
    JSON_VALUE(raw_payload, '$.billing.last_name') as last_name,
    JSON_VALUE(raw_payload, '$.status') as status,
    JSON_VALUE(raw_payload, '$.customer_id') as customer_id,
    JSON_VALUE(raw_payload, '$.shipping.country') as country,
    JSON_VALUE(raw_payload, '$.billing.email') as email,
    JSON_VALUE(raw_payload, '$.shipping_total') as shipping_fee,
    JSON_VALUE(raw_payload, '$.final_amount') as total,
    JSON_VALUE(raw_payload, '$.currency') as currency,
    JSON_VALUE(raw_payload, '$.payment_method') as payment_method,
    JSON_VALUE(raw_payload, '$.created_via') as created_via,
    JSON_VALUE(raw_payload, '$.pos_user') as pos_user,
    JSON_EXTRACT_ARRAY(raw_payload, '$.line_items') as items_details,
    JSON_EXTRACT_ARRAY(raw_payload, '$.meta_data') as meta_data,

    raw_payload
    from source 

)

select * from renamed
