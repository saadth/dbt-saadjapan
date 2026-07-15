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
from transactions
where created_via != "checkout" and billing_email != "support@saadjapan.com"
)

select *
from organized