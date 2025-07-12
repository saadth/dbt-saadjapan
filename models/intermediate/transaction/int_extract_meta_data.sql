with
    int_pk_creation as (select * from {{ ref("int_cleaning_pk_creation") }}),

    unnested as (
        select p.pk, p.created_via, meta
        from int_pk_creation as p, unnest(meta_data) as meta
    ),

    meta_data_extract as (
        select
            pk,
            max(
                if(
                    json_value(meta, '$.key') = 'customer_gender',
                    json_value(meta, '$.value'),
                    ''
                )
            ) as gender,
            max(
                if(
                    json_value(meta, '$.key') = 'customer_age',
                    json_value(meta, '$.value'),
                    ''
                )
            ) as age,
                max(
                    if(
                        json_value(meta, '$.key') = 'customer_nationality',
                        json_value(meta, '$.value'),
                        ''
                    )
                ) as nationality,
            coalesce(max(
                case
                    when json_value(meta, '$.key') = 'customer_reference'
                    then json_value(meta, '$.value')

                    when
                        json_value(meta, '$.key') = '_wc_order_attribution_utm_source'
                        and created_via = 'checkout'
                    then json_value(meta, '$.value')
                end
            ),'') as reference,
                max(
                    if(
                        json_value(meta, '$.key') = 'pos_cashier_name' and created_via='woocommerce-pos',
                        json_value(meta, '$.value'),
                        ''
                    )
                )
             as pos_user
        from unnested
        group by pk),

    joined as (
        select o.*
        ,a.gender, a.age, coalesce(a.nationality,o.country) as nationality, a.reference, a.pos_user
        from int_pk_creation as o
        left join
            meta_data_extract as a
            using (pk)
    )

Select *
from joined