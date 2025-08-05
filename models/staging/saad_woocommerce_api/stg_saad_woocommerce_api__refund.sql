with 

source as (

    select * from {{ source('saad_woocommerce_api', 'refund') }}

),

renamed as (

    select
        order_id,
        date_modified,
        date_created,
        status,
        customer_id,
        first_name,
        last_name,
        country,
        email,
        line_sku,
        line_quantity,
        quantity,
        line_subtotal,
        subtotal,
        shipping_fee,
        discount,
        total,
        currency,
        thb_subtotal,
        thb_shipping_fee,
        thb_discount,
        thb_total,
        thb_fees,
        thb_net,
        exchange_rate,
        payment_method,
        created_via,
        gender,
        age,
        nationality,
        reference,
        pos_user

    from source

)

select * from renamed
