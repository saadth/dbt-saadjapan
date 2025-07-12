with 

source as (

    select * from {{ source('saad_sns', 'tiktok_saadsilver_th') }}

),

renamed as (

    select
        safe_cast(date as date),
        followers_count as tiktok_followers_count,
        total_followers_count as tiktok_total_followers

    from source

)

select * from renamed
