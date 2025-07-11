with 

source as (

    select * from {{ source('saad_sns', 'line_saadsilver_intl') }}

),

renamed as (

    select
        date,
        followers__blocks,
        followers__followers,
        followers__targeted_reaches

    from source

)

select * from renamed
