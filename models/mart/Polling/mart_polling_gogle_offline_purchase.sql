with
    transactions as (select * from {{ ref('int_polling_add_line_items_to_transaction') }}),

organized as (
select
order_id,
billing_email as email_address,
date_created,
currency,
total as conversion_value,
'Purchase' as conversion_name,
'GRANTED' AS ad_user_data_consent,
'GRANTED' AS ad_personalization_consent
from transactions
where created_via != "checkout" and billing_email not in("support@saadjapan.com","guest@connectpos.com") AND billing_email IS NOT NULL
  AND TRIM(billing_email) != ''
)

select *
from organized