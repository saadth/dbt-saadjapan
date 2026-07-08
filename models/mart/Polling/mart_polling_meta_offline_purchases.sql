with
    transactions as (select * from {{ ref('int_polling_add_line_items_to_transaction') }}),

organized as (
select
order_id,
billing_email as email,
billing_first_name as fn,
billing_last_name as ln,
date_created as event_time,
currency,
total as value,
'Purchase' as event_name,
billing_country as country
from transactions
where created_via != "checkout" and billing_email != "support@saadjapan.com"
)

select *
from organized