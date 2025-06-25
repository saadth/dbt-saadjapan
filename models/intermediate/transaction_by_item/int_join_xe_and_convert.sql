with
    flatten as (
        select * from {{ ref('int_flatten_line_items') }}
    ),

    xe as (
        select 
        pk,
        safe_cast(exchange_rate as float64)as exchange_rate
        from {{ ref('int_calculate_xe_thb') }}
    ),

    joined as (
    select 
    *
    from flatten as i
    left join xe as e
        using (pk)
    ),
currency_convert as (
    select
    *,
    price * exchange_rate as thb_price,
    price_after_discount * exchange_rate as thb_price_after_discount,
    subtotal * exchange_rate as thb_subtotal,
    total * exchange_rate as thb_total
    from joined 
)

select *
from currency_convert