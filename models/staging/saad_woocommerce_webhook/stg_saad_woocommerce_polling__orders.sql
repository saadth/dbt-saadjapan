with 

source as (

    select * from {{ source('saad_woocommerce_polling', 'orders') }}

),

renamed as (

    select
        id,
        parent_id,
        status,
        currency,
        version,
        prices_include_tax,
        date_created,
        date_modified,
        discount_total,
        discount_tax,
        shipping_total,
        shipping_tax,
        cart_tax,
        total,
        total_tax,
        customer_id,
        order_key,
        billing,
        shipping,
        payment_method,
        payment_method_title,
        transaction_id,
        customer_ip_address,
        customer_user_agent,
        created_via,
        customer_note,
        date_completed,
        date_paid,
        cart_hash,
        number,
        meta_data,
        line_items,
        tax_lines,
        shipping_lines,
        fee_lines,
        coupon_lines,
        refunds,
        payment_url,
        is_editable,
        needs_payment,
        needs_processing,
        date_created_gmt,
        date_modified_gmt,
        date_completed_gmt,
        date_paid_gmt,
        email,
        final_amount,
        currency_symbol,
        _links

    from source

)

select * from renamed