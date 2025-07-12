with 

source as (

    select * from {{ source('saad_sns', 'ig_saadsilver_intl_total_followers') }}

),

renamed as (

    select
        today as date,
        followers_count as ig_total_followers
        

    from source

)

select * from renamed
