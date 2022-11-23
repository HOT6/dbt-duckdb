with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('item_mst') }}
),
renamed as (
    select
        id as item_id,
        item_cd,
        item_nm,
        del_yn,

    from source
)
select * from renamed
