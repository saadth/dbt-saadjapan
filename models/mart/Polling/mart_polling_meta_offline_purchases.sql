with
    transactions as (select * from {{ ref('int_polling_add_line_items_to_transaction') }}),

organized as (
select
order_number,
billing_email as email,
billing_first_name as fn,
billing_last_name as ln,
UNIX_SECONDS(date_created) as event_time,
currency,
total as value,
'Purchase' as event_name,
billing_country as country,
contents
from transactions
where created_via != "checkout" and billing_email not in ( "support@saadjapan.com", "guest@connectpos.com") and billing_email != ""
)

select *
from organized