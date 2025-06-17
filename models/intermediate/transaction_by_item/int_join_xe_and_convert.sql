with
    flatten as (
        select * from {{ ref('int_flatten_line_items') }}
    ),

    xe as (
        select 
        order_id,
        date_modified,
        status,
        safe_cast(exchange_rate as float64)as exchange_rate
        from {{ ref('int_extract_net_fee_xe') }}
    ),

    joined as (
    select 
    i.*,
    e.* except(order_id,status,date_modified)
    from flatten as i
    left join xe as e
        on i.order_id = e.order_id
        and i.status = e.status
        and i.date_modified = e.date_modified
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