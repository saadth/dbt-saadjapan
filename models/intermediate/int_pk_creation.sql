with orders as(
select *
from {{ ref('stg_saad_woocommerce_api__raw_woocommerce_orders') }}),

make_pk as(
select
*,
concat(safe_cast(order_id as string),'_',status) as pk
from orders)

select 
*
from make_pk