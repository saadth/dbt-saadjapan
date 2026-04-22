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

from unnested
group by order_id),

joined as (select o.*,
IF(TRIM(a.cpos_source) = '', NULL, a.cpos_source) as cpos_source, 
IF(TRIM(a.cpos_payment_status) = '', NULL, a.cpos_payment_status) as cpos_payment_status, 
IF(TRIM(a.cpos_fulfillment_status) = '', NULL, a.cpos_fulfillment_status) as cpos_fulfillment_status,
IF(TRIM(a.gender) = '', NULL, a.gender) as gender, 
IF(TRIM(a.age) = '', NULL, a.age) as age, 
IF(TRIM(a.reference) = '', NULL, a.reference) as reference,
IF(TRIM(a.purchase_reason) = '', NULL, a.purchase_reason) as purchase_reason
from orders as o
left join
    meta_data_extract as a
    using (order_id)
)

select *
from joined