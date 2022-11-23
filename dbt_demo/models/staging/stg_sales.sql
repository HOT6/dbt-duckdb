with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('sales') }}
),
renamed as (
    select
        account_id,
        item_mst_id,
        cast(base_date as date) as ds,
        qty,
        amt
    from source
)
select * from renamed
