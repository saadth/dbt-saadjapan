with 

source as (

    select * from {{ source('saad_woocommerce_polling', 'orders') }}

),

renamed as (

    select
        safe_cast(id as int64) as order_id,
        safe_cast(number as int64) as order_number,
        safe_cast(parent_id as int64) as parent_id,
        safe_cast(date_created as timestamp) as date_created,
        safe_cast(date_modified as timestamp) as date_modified,
        safe_cast(date_paid as timestamp) as date_paid,
        safe_cast(date_completed as timestamp) as date_completed,
        safe_cast(status as string) as status,
        safe_cast(currency as string) as currency,
        safe_cast(total as float64) as total,
        safe_cast(discount_total as float64) as discount_total,
        safe_cast(shipping_total as float64) as shipping_total,
        safe_cast(customer_id as int64) as customer_id,
        refunds,
        safe_cast(json_value(billing, '$.first_name') as string) as billing_first_name,
        safe_cast(json_value(billing, '$.last_name') as string) as billing_last_name,
        safe_cast(json_value(billing, '$.city') as string) as billing_city,
        safe_cast(json_value(billing, '$.state') as string) as billing_state,
        safe_cast(json_value(billing, '$.postcode') as string) as billing_postcode,
        safe_cast(json_value(billing, '$.country') as string) as billing_country,
        safe_cast(json_value(billing, '$.email') as string) as billing_email,
        safe_cast(json_value(shipping, '$.first_name') as string) as shipping_first_name,
        safe_cast(json_value(shipping, '$.last_name') as string) as shipping_last_name,
        safe_cast(json_value(shipping, '$.address_1') as string) as shipping_address_1,
        safe_cast(json_value(shipping, '$.city') as string) as shipping_city,
        safe_cast(json_value(shipping, '$.state') as string) as shipping_state,
        safe_cast(json_value(shipping, '$.postcode') as string) as shipping_postcode,
        safe_cast(json_value(shipping, '$.country') as string) as shipping_country,
        safe_cast(payment_method as string) as payment_method,
        safe_cast(payment_method_title as string) as payment_method_title,
        safe_cast(created_via as string) as created_via,
        meta_data as meta_data,
        line_items as line_items,
        tax_lines as tax_lines,
        shipping_lines as shipping_lines ,
        fee_lines as fee_lines ,
        coupon_lines as coupon_lines
    from source

)

select * 
from renamed