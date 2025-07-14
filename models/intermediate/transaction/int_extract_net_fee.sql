with
    items_amount as (select * from {{ ref("int_extract_items_and_amount") }}),

    column_needed as (
        select pk, payment_method, meta
        from items_amount, unnest(meta_data) as meta
   ),

   thb_fees_and_net as (
        select
            pk,
                max(
                    case
                        when
                            payment_method like '%stripe%'
                            and json_value(meta, '$.key') = '_stripe_fee'
                        then safe_cast(json_value(meta, '$.value') as float64)

                        when
                            payment_method like '%ppcp%'
                            and json_value(meta, '$.key') = '_ppcp_paypal_fees'
                        then
                            safe_cast(
                                json_value(meta, '$.value.paypal_fee.value') as float64)
                                 * safe_cast(json_value(meta, '$.value.exchange_rate.value') as float64)
                    end
                ) as fees,

                max(
                    case
                        when
                            payment_method like '%stripe%'
                            and json_value(meta, '$.key') = '_stripe_net'
                        then safe_cast(json_value(meta, '$.value') as float64)
                        when
                            payment_method like '%ppcp%'
                            and json_value(meta, '$.key') = '_ppcp_paypal_fees'
                        then
                            safe_cast(
                                json_value(
                                    meta, '$.value.receivable_amount.value'
                                ) as float64
                            )
                    end
                )as net

        from column_needed
        group by pk

   ),

   joined_thb_fees_and_net as (
    select i.*,
    -1*(coalesce(f.fees,0)) as thb_fees,
    coalesce(f.net, i.total) as thb_net
    from items_amount as i
    left join thb_fees_and_net as f
    using (pk)
   )
    
select *
from joined_thb_fees_and_net
