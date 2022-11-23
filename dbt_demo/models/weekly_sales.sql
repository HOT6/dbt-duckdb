with account as (
    select * from {{ ref('stg_account') }}
),
item as (
    select * from {{ ref('stg_item') }}
),
sa as (
    select * from {{ ref('stg_sales') }}
),
weekly_sales as (
    select i.item_cd,
           a.account_cd,
           extract(isoyear from ds) as yr,
           extract(week from ds) as wk,
           min(s.ds) as ds,
           sum(s.qty) as qty,
           sum(s.amt) as amt
    from sa s
    inner join account a on s.account_id = a.account_id
    inner join item i on s.item_mst_id = i.item_id
    group by 1, 2, 3, 4
),
final as (
    select item_cd,
           account_cd,
           ds,
           qty,
           amt
    from weekly_sales
)
select * from final
