with
    extracted_shipping as (select * from {{ ref('int_extract_shipping_details') }}),

organized as (
select
        shipping_id,
        order_id,
        date_modified,
        extract(date from date_modified) as shipping_date,
        date_created as purchased_date,
        first_name,
        last_name,
        shipping_company,
        tracking_number,
        line_sku,
        line_quantity,
        tracking_url,
        country,
        state,
        address_1,
        address_2,
        postcode,
        email,
        phone,
        shipping_fee,
        from extracted_shipping
        order by date_modified
)

select *
from organized