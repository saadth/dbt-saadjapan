with 

source as (

    select * from {{ source('saad_sns', 'ig_saadsilver_intl_total_followers') }}

),

renamed as (

    select
        followers_count as total_followers,
        today as date

    from source

)

select * from renamed
