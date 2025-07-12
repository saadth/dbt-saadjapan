with sns as (
    select * 
    from {{ ref('join_sns_data') }}
),

ordered as (
    select
    date,
    ig_follower_count,
    ig_total_followers,
    line_total_followers,
    line_total_reach,
    line_follower_count,
    line_reach_count,
    tiktok_followers_count,
    tiktok_total_followers
    from sns
    order by date asc
)

select *
from ordered