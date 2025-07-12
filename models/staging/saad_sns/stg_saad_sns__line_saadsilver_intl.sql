with 

source as (

    select * from {{ source('saad_sns', 'line_saadsilver_intl') }}

),

renamed as (

    select
        safe_cast (date as date),
        followers__blocks as line_block_count,
        followers__followers as line_total_followers,
        followers__targeted_reaches as line_total_reach

    from source

)

select * from renamed
