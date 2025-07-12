With 
ig as (
    select *
    from {{ ref('join_ig_data') }}

),
line as (
    select *
    from {{ ref('create_line_follow_counts') }}

),
tiktok as (
    select *
    from {{ ref('stg_saad_sns__tiktok_saadsilver_th') }}

)

joined as (
select *
from ig
left join line using (date)
left join tiktok using (date)
)

select *
from joined