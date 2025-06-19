with
    net_fees_xe as (select * from {{ ref("int_extract_net_fee_xe") }}),

    unnested as (
        select n.order_id, n.status, n.date_modified, n.country, n.created_via, meta
        from net_fees_xe as n, unnest(meta_data) as meta
    ),

    meta_data_extract as (
        select
            order_id,
            status,
            date_modified,
            country,
            max(
                if(
                    json_value(meta, '$.key') = 'customer_gender',
                    json_value(meta, '$.value'),
                    null
                )
            ) as gender,
            max(
                if(
                    json_value(meta, '$.key') = 'customer_age',
                    json_value(meta, '$.value'),
                    null
                )
            ) as age,
            coalesce(
                max(
                    if(
                        json_value(meta, '$.key') = 'customer_nationality',
                        json_value(meta, '$.value'),
                        null
                    )
                ),
                country
            ) as nationality,
            max(
                case
                    when json_value(meta, '$.key') = 'customer_reference'
                    then json_value(meta, '$.value')

                    when
                        json_value(meta, '$.key') = '_wc_order_attribution_utm_source'
                        and created_via = 'checkout'
                    then json_value(meta, '$.value')
                end
            ) as reference,
                max(
                    if(
                        json_value(meta, '$.key') = 'pos_cashier_name' and created_via='woocommerce-pos',
                        json_value(meta, '$.value'),
                        null
                    )
                )
             as pos_user
        from unnested
        group by order_id, status, date_modified, country),

    joined as (
        select o.*, a.gender, a.age, a.nationality, a.reference, a.pos_user
        from net_fees_xe as o
        left join
            meta_data_extract as a
            on a.order_id = o.order_id
            and a.status = o.status
            and a.date_modified = o.date_modified
    )

Select *
from joined