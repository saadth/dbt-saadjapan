With ig_total as (
    select *
    from {{ ref('stg_saad_sns__ig_saadsilver_intl_total_followers') }}

),
ig as (
    select *
    from {{ ref('stg_saad_sns__ig_saadsilver_intl') }}
)

select
*
from ig
full join ig_total using (date)
