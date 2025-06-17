with items_amount as (
  select *
  from {{ ref('int_extract_items_and_amount') }}
),

column_needed as (
select
    order_id,
    status,
    date_modified,
    payment_method,
    total,
    meta
from items_amount, unnest(meta_data) as meta
),

fees_and_net as (
    select
order_id,
status,
date_modified,
total,
COALESCE (max(case
    when payment_method like '%stripe%' and JSON_VALUE(meta, '$.key') = '_stripe_fee'
    then SAFE_CAST(JSON_VALUE(meta, '$.value') as FLOAT64)
    
    when payment_method like '%ppcp%' and JSON_VALUE(meta, '$.key') = '_ppcp_paypal_fees'
    then SAFE_CAST(JSON_VALUE(meta, '$.value.paypal_fee.value') as FLOAT64)*SAFE_CAST(JSON_VALUE(meta, '$.value.exchange_rate.value') as FLOAT64)
    end),0) as fees,

COALESCE(max(case
    when payment_method like '%stripe%' and JSON_VALUE(meta, '$.key') = '_stripe_net'
    then SAFE_CAST(JSON_VALUE(meta, '$.value') as FLOAT64)
    when payment_method like '%ppcp%' and JSON_VALUE(meta, '$.key') = '_ppcp_paypal_fees'
    then SAFE_CAST(JSON_VALUE(meta, '$.value.receivable_amount.value')as FLOAT64)
    end),total) as net

from column_needed
group by order_id, status, date_modified,total

),

exchange_rate as(
select
*,
(fees+net)/total as exchange_rate

from fees_and_net
),

joined as (
select
i.*,
e.fees,
e.net,
e.exchange_rate
from items_amount as i
left join exchange_rate as e 
on i.order_id=e.order_id and i.status=e.status and i.date_modified=e.date_modified
)

select *
from joined