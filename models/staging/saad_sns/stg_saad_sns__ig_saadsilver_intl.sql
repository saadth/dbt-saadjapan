with 

source as (

    select * from {{ source('saad_sns', 'ig_saadsilver_intl') }}

),

renamed as (

    select
        date,
        follower_count_1d as ig_follower_count

    from source

)

select * from renamed
