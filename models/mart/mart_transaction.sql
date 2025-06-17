with
    meta_data as (select * from {{ ref('int_extract_meta_data') }})

    select
    *
    from meta_data