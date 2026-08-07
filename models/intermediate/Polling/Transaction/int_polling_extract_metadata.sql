with orders as (select * from {{ ref("stg_saad_woocommerce_polling__orders") }}),

unnested as (select o.order_number, meta
from orders as o, unnest(JSON_QUERY_ARRAY(meta_data)) as meta),

meta_data_extract as (select
order_number,
--connectpos---
max(
    if(
        json_value(meta, '$.key') = 'Source',
        json_value(meta, '$.value'),
        null
        )) as cpos_source,
max(
    if(
        json_value(meta, '$.key') = '_cpos_payment_status',
        json_value(meta, '$.value'),
        null
        )) as cpos_payment_status,
max(
    if(
        json_value(meta, '$.key') = '_cpos_fulfillment_status',
        json_value(meta, '$.value'),
        null
        )) as cpos_fulfillment_status,
--web data---
max(
    if(
        json_value(meta, '$.key') = '_wc_order_attribution_utm_source',
        json_value(meta, '$.value'),
        null
        )) as utm_source,
max(
    if(
        json_value(meta, '$.key') = '_aftership_tracking_number',
        json_value(meta, '$.value'),
        null
        )) as tracking_number,
--ACF data---
max(
    if(
        json_value(meta, '$.key') = 'gender',
        json_value(meta, '$.value'),
        null
        )) as gender,
max(
    if(
        json_value(meta, '$.key') = 'age',
        json_value(meta, '$.value'),
        null
        )) as age,
max(
    if(
        json_value(meta, '$.key') = 'nationality',
        json_value(meta, '$.value'),
        null
        )) as nationality,
max(
    if(
        json_value(meta, '$.key') = 'purchase_reason',
        json_value(meta, '$.value'),
        null
        )) as purchase_reason,

max(
    if(
        json_value(meta, '$.key') = 'reference',
        json_value(meta, '$.value'),
        null
        )) as reference,
--stripe--
max(
    if(
        json_value(meta, '$.key') = '_stripe_fee',
        json_value(meta, '$.value'),
        null
        )) as stripe_fee,
max(
    if(
        json_value(meta, '$.key') = '_stripe_net',
        json_value(meta, '$.value'),
        null
        )) as stripe_net,

max(
    if(
        json_value(meta, '$.key') = '_stripe_currency',
        json_value(meta, '$.value'),
        null
        )) as stripe_currency,
--paypal--
max(
    if(
        json_value(meta, '$.key') = '_paypal_fee',
        json_value(meta, '$.value'),
        null
        )) as paypal_fee,
max(
    if(
        json_value(meta, '$.key') = '_paypal_net',
        json_value(meta, '$.value'),
        null
        )) as paypal_net,

max(
    if(
        json_value(meta, '$.key') = 'wmc_order_info',
        JSON_QUERY(meta, '$.value'),
        null
        )) as exchange_rates

from unnested
group by order_number),

joined as (select o.*,
IF(TRIM(a.cpos_source) = '', Null, a.cpos_source) as cpos_source, 
IF(TRIM(a.cpos_payment_status) = '', NULL, a.cpos_payment_status) as cpos_payment_status, 
IF(TRIM(a.cpos_fulfillment_status) = '', Null, a.cpos_fulfillment_status) as cpos_fulfillment_status,

--attributes--
COALESCE(NULLIF(TRIM(a.gender), ''), 'unsure') AS gender,
COALESCE(NULLIF(TRIM(a.age), ''), 'unsure') AS age,

case 
    when o.created_via = 'checkout' then COALESCE(NULLIF(TRIM(o.shipping_country), ''), 'unsure')
    else COALESCE(NULLIF(TRIM(a.nationality), ''), 'unsure')
end as nationality,

CASE
  WHEN o.created_via = 'checkout'
    THEN COALESCE(NULLIF(TRIM(a.utm_source), ''), 'unsure')
  ELSE COALESCE(NULLIF(TRIM(a.reference), ''), 'unsure')
END AS reference,

COALESCE(NULLIF(TRIM(a.purchase_reason), ''), 'unsure') AS purchase_reason,
case
    when a.cpos_source = "in_store" then o.shipping_address_1
    when o.created_via = "checkout" then "Website"
    when a.cpos_source = "phone" then "Message/Phone"
end as purchase_location,

IF(TRIM(a.tracking_number) = '', NULL, a.tracking_number) as tracking_number, 
--payment fees--
IF(TRIM(a.stripe_fee) = '', NULL, a.stripe_fee) as stripe_fee, 
IF(TRIM(a.stripe_net) = '', NULL, a.stripe_net) as stripe_net, 
IF(TRIM(a.stripe_currency) = '', NULL, a.stripe_currency) as stripe_currency,
IF(TRIM(a.paypal_fee) = '', NULL, a.paypal_fee) as paypal_fee, 
IF(TRIM(a.paypal_net) = '', NULL, a.paypal_net) as paypal_net, 
IF(TRIM(a.exchange_rates) = '', NULL, a.exchange_rates) as exchange_rates
from orders as o
left join
    meta_data_extract as a
    using (order_number)
)

select 
*
from joined