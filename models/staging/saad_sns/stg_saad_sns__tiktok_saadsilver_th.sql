with 

source as (

    select * from {{ source('saad_sns', 'tiktok_saadsilver_th') }}

),

renamed as (

    select
        date,
        followers_count,
        total_followers_count as total_followers

    from source

)

select * from renamed
