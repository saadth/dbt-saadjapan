with
    orders as (
        select * from {{ ref("int_extract_items_and_amount") }}
    ),

meta_data as (
select
concat(order_id,'_',date_modified,'_',status) as pk,
unnested_meta_data
from orders , unnest(meta_data) as unnested_meta_data
where status = 'shipped'),

extracted_shipping as (
select
pk,
max(if(json_value(unnested_meta_data,'$.key')= '_aftership_tracking_number',json_value(unnested_meta_data,'$.value'),null )
) as tracking_number,
max(if(json_value(unnested_meta_data,'$.key')= '_aftership_tracking_provider_name',json_value(unnested_meta_data,'$.value'),null )
) as shipping_company

from meta_data
group by pk ),

joined as (
    select *
    from orders
    left join extracted_shipping using (pk)
    where status = 'shipped'

),

shipping_info as (
select *,
concat('s',UNIX_SECONDS(timestamp(date_modified))) as shipping_id,
concat('https://saadltd.aftership.com/',tracking_number) as tracking_url
from joined )

select *
from shipping_info