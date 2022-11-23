with source as (
    {#-
    Normally we would select from the table here, but we are using seeds to load
    our data in this project
    #}
    select * from {{ ref('account_mst') }}
),
renamed as (
    select
        id as account_id,
        account_cd,
        account_nm,
        del_yn,
        actv_yn
    from source
)
select * from renamed
