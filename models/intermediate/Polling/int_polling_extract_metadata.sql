with orders as (select * from {{ ref("stg_saad_woocommerce_polling__orders") }}),

unnested as (select o.order_id, meta
from orders as o, unnest(JSON_QUERY_ARRAY(meta_data)) as meta),

meta_data_extract as (select
order_id,
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
group by order_id),

joined as (select o.*,
IF(TRIM(a.cpos_source) = '', NULL, a.cpos_source) as cpos_source, 
IF(TRIM(a.cpos_payment_status) = '', NULL, a.cpos_payment_status) as cpos_payment_status, 
IF(TRIM(a.cpos_fulfillment_status) = '', NULL, a.cpos_fulfillment_status) as cpos_fulfillment_status,
IF(TRIM(a.gender) = '', NULL, a.gender) as gender, 
IF(TRIM(a.age) = '', NULL, a.age) as age, 
IF(TRIM(a.reference) = '', NULL, a.reference) as reference,
IF(TRIM(a.purchase_reason) = '', NULL, a.purchase_reason) as purchase_reason,
IF(TRIM(a.stripe_fee) = '', NULL, a.stripe_fee) as stripe_fee, 
IF(TRIM(a.stripe_net) = '', NULL, a.stripe_net) as stripe_net, 
IF(TRIM(a.stripe_currency) = '', NULL, a.stripe_currency) as stripe_currency,
IF(TRIM(a.paypal_fee) = '', NULL, a.paypal_fee) as paypal_fee, 
IF(TRIM(a.paypal_net) = '', NULL, a.paypal_net) as paypal_net, 
IF(TRIM(a.exchange_rates) = '', NULL, a.exchange_rates) as exchange_rates
from orders as o
left join
    meta_data_extract as a
    using (order_id)
)

select *
from joined