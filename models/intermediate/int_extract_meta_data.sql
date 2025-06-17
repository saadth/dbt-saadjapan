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
            coalesce(
                max(
                    if(
                        json_value(meta, '$.key') = '_pos_user',
                        json_value(meta, '$.value'),
                        null
                    )
                ),
                'website'
            ) as pos_user_id
        from unnested
        group by order_id, status, date_modified, country
    ),

    assign_user_name as (
        select
            * except (pos_user_id),
            case
                when pos_user_id = '37'
                then 'Mustufa'
                when pos_user_id = '134'
                then 'Golf'
                when pos_user_id = '124'
                then 'Ann'
                when pos_user_id = '47'
                then 'Ayesha'
                when pos_user_id = '3'
                then 'Haider'
                when pos_user_id = 'website'
                then 'Website'
            end as pos_user
        from meta_data_extract
    ),

    joined as (
        select o.*, a.gender, a.age, a.nationality, a.reference, a.pos_user
        from net_fees_xe as o
        left join
            assign_user_name as a
            on a.order_id = o.order_id
            and a.status = o.status
            and a.date_modified = o.date_modified
    )

Select *
from joined