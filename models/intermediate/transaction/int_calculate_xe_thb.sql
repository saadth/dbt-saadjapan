with
    net_fee as (
        select * from {{ ref("int_extract_net_fee") }}
    ),


add_exchange_rate as (
        select *, 
        coalesce(
        case 
        when payment_method like '%stripe%' 
        then (thb_fees + thb_net) / total

        --paypal fees is in orgiginal currency hence in the denominator
        when payment_method like '%ppcp%' 
        then (thb_fees+thb_net)/total
        end, 1) as exchange_rate
        from net_fee
    ),
    thb_conversion as (
    select
    *,
    safe_cast(total as float64) * safe_cast(exchange_rate as float64) as thb_total,
    safe_cast(subtotal as float64) * safe_cast(exchange_rate as float64) as thb_subtotal,
    safe_cast(shipping_fee as float64) * safe_cast(exchange_rate as float64) as thb_shipping_fee,
    safe_cast(discount as float64) * safe_cast(exchange_rate as float64) as thb_discount
    from add_exchange_rate
)

select *
from thb_conversion
where payment_method like '%ppcp%'

