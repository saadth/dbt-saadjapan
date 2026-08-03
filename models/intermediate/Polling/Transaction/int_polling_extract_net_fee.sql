with int_polling_extract_metadata as (select * from {{ ref("int_polling_extract_metadata") }}),

exchange_rate as 
(select 
    *,
    CASE currency
        WHEN 'THB' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.THB.rate') as float64)
        WHEN 'MYR' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.MYR.rate') as float64)
        WHEN 'USD' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.USD.rate') as float64)
        WHEN 'JPY' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.JPY.rate')as float64)
        WHEN 'HKD' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.HKD.rate')as float64)
        WHEN 'TWD' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.TWD.rate')as float64)
        WHEN 'SGD' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.SGD.rate')as float64)
        WHEN 'KRW' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.KRW.rate')as float64)
        WHEN 'GBP' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.GBP.rate')as float64)
        WHEN 'EUR' THEN SAFE_CAST(JSON_VALUE(exchange_rates, '$.EUR.rate')as float64)
        ELSE NULL
    END AS extracted_exchange_rate
from int_polling_extract_metadata),

thb_amount_calc as (
select
*,
SAFE_DIVIDE(safe_cast(discount_total as float64),safe_cast(extracted_exchange_rate
 as float64)) as thb_discount_total,
SAFE_DIVIDE(safe_cast(total as float64),safe_cast(extracted_exchange_rate
 as float64)) as thb_total
from exchange_rate
)

select *
from thb_amount_calc