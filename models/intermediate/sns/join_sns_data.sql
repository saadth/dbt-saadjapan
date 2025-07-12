With ig_total as (
    select *
    from {{ ref('stg_saad_sns__ig_saadsilver_intl_total_followers') }}

),
ig as (
    select *
    from {{ ref('stg_saad_sns__ig_saadsilver_intl') }}

),
line as (
    select *
    from {{ ref('create_line_follow_counts') }}

),
tiktok as (
    select *
    from {{ ref('stg_saad_sns__tiktok_saadsilver_th') }}

)

select *
from tiktok