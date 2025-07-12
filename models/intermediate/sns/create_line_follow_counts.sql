with line as (

    select *
    from {{ ref('stg_saad_sns__line_saadsilver_intl') }}
),

table_1 as (
select *
, row_number () over (order by date asc) as index
from line
),

table_2 as (
    select 
    date as prev_date,
    line_total_followers as prev_total_followers,
    line_total_reach as prev_total_reach,
    index+1 as index
from table_1
),

inner_join as (
select
date,
line_total_followers,
line_total_reach,
line_total_followers - prev_total_followers as line_follower_count,
line_total_reach - prev_total_reach as line_reach_count
from table_1
left join table_2 as prev using (index)
)

select *
from inner_join