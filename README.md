# **Demo proejct**
  1. Sales data is daily data and consists of item_id, account_id, base_date, qty, and amt.
  2. We have account_mst and item_mst tables where id and code are mapped.
  3. As a result, we will create a table of sales data by week consisting of item_cd, account_cd, base_date, qty, and amt.

  - seed data:
    - `account_mst.csv`
      ```bash
       $ head -n1 seeds/account_mst.csv
       ID,ACCOUNT_CD,ACCOUNT_NM,DEL_YN,ACTV_YN,CREATE_BY,CREATE_DTTM,MODIFY_BY,MODIFY_DTTM
      ```

    - `item_mst.csv`
      ```bash
      $ head -n1 seeds/item_mst.csv
      ID,ITEM_CD,ITEM_NM,DEL_YN,CREATE_BY,CREATE_DTTM,MODIFY_BY,MODIFY_DTTM
      ```
    - `sales.csv`
      ```bash
      $ head -n1 seeds/sales.csv
      ID,ITEM_MST_ID,ACCOUNT_ID,BASE_DATE,QTY,AMT
      ```

  - Desired Results Table
    - weekly sales data with item_cd, account_cd, base_date, qty, amt
    ```
    ITEM_CD,ACCOUNT_CD,BASE_DATE,QTY,AMT
    ```


## **Create dbt project**
---
1. Make sure you have dbt Core installed and check the version using the dbt --version command:
```bash
$ dbt --version

Core:
  - installed: 1.3.1
  - latest:    1.3.1 - Up to date!

Plugins:
  - duckdb: 1.3.2 - Up to date!
```

2. Initiate the jaffle_shop project using the init command:
```bash
$ dbt init jaffle_shop

00:24:22  Running with dbt=1.3.1
00:24:22  Creating dbt configuration folder at /home/sc/.dbt
Which database would you like to use?
[1] duckdb

(Don't see the one you want? https://docs.getdbt.com/docs/available-adapters)

Enter a number: 1
00:24:28  No sample profile found for duckdb.
00:24:28
Your new dbt project "jaffle_shop" was created!

For more information on how to configure the profiles.yml file,
please consult the dbt documentation here:

  https://docs.getdbt.com/docs/configure-your-profile

One more thing:

Need help? Don't hesitate to reach out to us via GitHub issues or on Slack:

  https://community.getdbt.com/

Happy modeling!
```

3. Change directory name to your project's name, in my case `dbt_demo`
```
mv jaffle_shop dbt_demo
```

3. Navigate into your project's directory:
```
cd dbt_demo
```

4. Use a code editor like Atom or VSCode to open the project directory you created in the previous steps, which we named <your_project>. The content includes folders and .sql and .yml files generated by the init command.


5. Update the following values in the `dbt_project.yml` file:

`dbt_project.yml`
``` yaml
name: jaffle_shop # Change from the default, `my_new_project`

...

profile: jaffle_shop # Change from the default profile name, `default`

...

models:
  jaffle_shop: # Change from `my_new_project` to match the previous value for `name:`
    ...
```

## **Connect to duckdb**
  - When developing locally, dbt connects to your data warehouse using a profile, which is a yaml file with all the connection details to your warehouse.

  1. Create a file in the `~/.dbt/` directory named `profiles.yml`.
  2. Copy the following and paste into the new `profiles.yml` file. Make sure you update the values where noted.
  ``` yaml
  dbt_demo:

    target: dev
    outputs:
      dev:
        type: duckdb
        path: 'dbt_demo.duckdb'
        threads: 24
  ```
  
  3. Run the `debug` command from your project to confirm that you can successfully connect:
  ```bash
  $ dbt debug

  00:36:07  Running with dbt=1.3.1
  dbt version: 1.3.1
  python version: 3.9.15
  python path: /home/sc/anaconda3/envs/dbt/bin/python
  os info: Linux-5.4.72-microsoft-standard-WSL2-x86_64-with-glibc2.31
  Using profiles.yml file at /mnt/c/Users/suchang/zionex/workspace/duckdb/dbt-duckdb/dbt_demo/profiles.yml
  Using dbt_project.yml file at /mnt/c/Users/suchang/zionex/workspace/duckdb/dbt-duckdb/dbt_demo/dbt_project.yml

  Configuration:
    profiles.yml file [OK found and valid]
    dbt_project.yml file [OK found and valid]

  Required dependencies:
   - git [OK found]
  
  Connection:
    database: main
    schema: main
    path: dbt_demo.duckdb
    Connection test: [OK connection ok]

  All checks passed!
  ``` 


## **dbt seed**
  > The dbt seed command will load csv files located in the seed-paths directory of your dbt project into your data warehouse. seed-paths is defined in ./dbt_project.yml

  So lets take one of the CSV filenames and use that:

  ```bash
  $ ls -l seeds

  total 33012
  -rwxrwxrwx 1 sc 1000     2285 Nov 23 09:44 account_mst.csv
  -rwxrwxrwx 1 sc 1000    25707 Nov 23 09:44 item_mst.csv
  -rwxrwxrwx 1 sc 1000 33768182 Nov 23 09:46 sales.csv
  ```

  ``` bash
  $ dbt seed --models account_mst

  00:56:46  Running with dbt=1.3.1
  00:56:46  Partial parse save file not found. Starting full parse.
  00:56:47  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 292 macros, 0 operations, 3 seed files, 0 sources, 0 exposures, 0 metrics
  00:56:47
  00:56:47  Concurrency: 24 threads (target='dev')
  00:56:47
  00:56:47  1 of 1 START seed file main.account_mst ........................................ [RUN]
  00:56:47  1 of 1 OK loaded seed file main.account_mst .................................... [INSERT 25 in 0.11s]
  00:56:47
  00:56:47  Finished running 1 seed in 0 hours 0 minutes and 0.26 seconds (0.26s).
  00:56:47
  00:56:47  Completed successfully
  00:56:47
  00:56:47  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
  ```

  The table???s been created by dbt
  ``` bash
  $ duckcli dbt_demo.duckdb

  dbt_demo.duckdb> \dt
  +-------------+
  | table_name  |
  +-------------+
  | account_mst |
  +-------------+
  Time: 0.008s

  dbt_demo.duckdb> select * from account_mst limit 5;
  +----------------------------------+------------+--------------------+--------+---------+-----------+---------------+-----------+-------------+
  | ID                               | ACCOUNT_CD | ACCOUNT_NM         | DEL_YN | ACTV_YN | CREATE_BY | CREATE_DTTM   | MODIFY_BY | MODIFY_DTTM |
  +----------------------------------+------------+--------------------+--------+---------+-----------+---------------+-----------+-------------+
  | 4DADB194293648C58EF1D34D4365DCDB | ACC-14     | L2discountstore    | N      | Y       | admin     | 1/1/1980 0:00 | admin     | 38:56.4     |
  | 02E1E6CA4EF548198BCE292DA1DA4997 | ACC-19     | L2GSsuper          | N      | Y       | admin     | 1/1/1980 0:00 | admin     | 58:08.4     |
  | 1C987205FD8147F0A9D354F1DDB34C67 | ACC-22     | ent division       | N      | Y       | admin     | 1/1/1980 0:00 | admin     | 58:08.5     |
  | 22752CE57C244ED697783AA7A6AD1463 | ACC-6      | L-2_de[par]t(ment) | N      | Y       | admin     | 1/1/1980 0:00 | admin     | 59:02.8     |
  | 3350EB1CC36545FBA7658C38B5E7AD87 | ACC-7      | L2export           | N      | Y       | admin     | 1/1/1980 0:00 | admin     | 59:30.7     |
  +----------------------------------+------------+--------------------+--------+---------+-----------+---------------+-----------+-------------+
  ```

  Let???s run the rest of the seed steps (including the one we???ve been changing):
  ``` bash
  $ dbt seed

  01:00:16  Running with dbt=1.3.1
  01:00:16  Found 2 models, 4 tests, 0 snapshots, 0 analyses, 292 macros, 0 operations, 3 seed files, 0 sources, 0 exposures, 0 metrics
  01:00:16
  01:00:16  Concurrency: 24 threads (target='dev')
  01:00:16
  01:00:16  1 of 3 START seed file main.account_mst ........................................ [RUN]
  01:00:16  2 of 3 START seed file main.item_mst ........................................... [RUN]
  01:00:16  3 of 3 START seed file main.sales .............................................. [RUN]
  01:00:17  1 of 3 OK loaded seed file main.account_mst .................................... [INSERT 25 in 0.57s]
  01:00:17  2 of 3 OK loaded seed file main.item_mst ....................................... [INSERT 333 in 0.62s]
  01:00:35  3 of 3 OK loaded seed file main.sales .......................................... [INSERT 272015 in 19.40s]
  01:00:35
  01:00:35  Finished running 3 seeds in 0 hours 0 minutes and 19.58 seconds (19.58s).
  01:00:35
  01:00:35  Completed successfully
  01:00:35
  01:00:35  Done. PASS=3 WARN=0 ERROR=0 SKIP=0 TOTAL=3
  ```

## staging: Preparing our atomic building blocks
  - the most standard types of staging model transformations are:
    - ??? Renaming
    - ??? Type casting
    - ??? Basic computations (e.g. cents to dollars)
    - ??? Joins ??? the goal of staging models is to clean and prepare individual source conformed concepts for downstream usage.
    - ??? Aggregations ??? aggregations entail grouping, and we're not doing that at this stage. Remember - staging models are your place to create the building blocks you???ll use all throughout the rest of your project
    - ??? Materialized as views. 
      - Any downstream model (discussed more in marts) referencing our staging models will always get the freshest data possible from all of the component views it???s pulling together and materializing
      - It avoids wasting space in the warehouse on models that are not intended to be queried by data consumers, and thus do not need to perform as quickly or efficiently
      `dbt_project.yml`
      ```yaml
      models:
        dbt_demo:
          staging:
            +materialized: view
      ```
  - create staging models in `models/staging/`
    - `models/staging/schema.yml`
      ```yaml
      version: 2

      models:
        - name: stg_account
          columns:
            - name: account_id
              tests:
                - unique
                - not_null

        - name: stg_item
          columns:
            - name: item_id
              tests:
                - unique
                - not_null
      ```
    - `models/staging/stg_item.sql`
    ```sql
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
    ```
    - `models/staging/stg_account.sql`
    ```sql
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
    ```

## model (dbt run)
  - When you execute dbt run, you are running a model that will transform your data without that data ever leaving your warehouse.
  - create models in `models` directory
  - `models/weekly_sales.sql`
  ```sql
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
  ```

## dbt build
  - end to end (dbt seed, dbt run, ...)

  ``` bash
  $ dbt build
  02:33:44  Running with dbt=1.3.1
  02:33:44  Found 4 models, 4 tests, 0 snapshots, 0 analyses, 292 macros, 0 operations, 3 seed files, 0 sources, 0 exposures, 0 metrics
  02:33:44
  02:33:45  Concurrency: 24 threads (target='dev')
  02:33:45
  02:33:45  1 of 11 START seed file main.account_mst ....................................... [RUN]
  02:33:45  2 of 11 START seed file main.item_mst .......................................... [RUN]
  02:33:45  3 of 11 START seed file main.sales ............................................. [RUN]
  02:33:46  2 of 11 OK loaded seed file main.item_mst ...................................... [INSERT 333 in 1.19s]
  02:33:46  1 of 11 OK loaded seed file main.account_mst ................................... [INSERT 25 in 1.24s]
  02:33:46  4 of 11 START sql view model main.stg_item ..................................... [RUN]
  02:33:46  5 of 11 START sql view model main.stg_account .................................. [RUN]
  02:33:48  4 of 11 OK created sql view model main.stg_item ................................ [OK in 1.62s]
  02:33:48  5 of 11 OK created sql view model main.stg_account ............................. [OK in 1.69s]
  02:33:48  6 of 11 START test not_null_stg_item_item_id ................................... [RUN]
  02:33:48  7 of 11 START test unique_stg_item_item_id ..................................... [RUN]
  02:33:48  8 of 11 START test not_null_stg_account_account_id ............................. [RUN]
  02:33:48  9 of 11 START test unique_stg_account_account_id ............................... [RUN]
  02:33:50  7 of 11 PASS unique_stg_item_item_id ........................................... [PASS in 2.07s]
  02:33:51  6 of 11 PASS not_null_stg_item_item_id ......................................... [PASS in 2.20s]
  02:33:51  8 of 11 PASS not_null_stg_account_account_id ................................... [PASS in 2.11s]
  02:33:51  9 of 11 PASS unique_stg_account_account_id ..................................... [PASS in 2.13s]
  02:34:12  3 of 11 OK loaded seed file main.sales ......................................... [INSERT 272015 in 26.78s]
  02:34:12  10 of 11 START sql view model main.stg_sales ................................... [RUN]
  02:34:12  10 of 11 OK created sql view model main.stg_sales .............................. [OK in 0.17s]
  02:34:12  11 of 11 START sql table model main.weekly_sales ............................... [RUN]
  02:34:13  11 of 11 OK created sql table model main.weekly_sales .......................... [OK in 0.91s]
  02:34:13
  02:34:13  Finished running 3 seeds, 3 view models, 4 tests, 1 table model in 0 hours 0 minutes and 28.38 seconds (28.38s).
  02:34:13
  02:34:13  Completed successfully
  02:34:13
  02:34:13  Done. PASS=11 WARN=0 ERROR=0 SKIP=0 TOTAL=11
  ```

## check result table

```bash
$ duckcli dbt_demo.duckdb
dbt_demo.duckdb> select * from weekly_sales order by item_cd, account_cd, ds limit 10;

+---------+------------+------------+-----+--------+
| ITEM_CD | ACCOUNT_CD | ds         | qty | amt    |
+---------+------------+------------+-----+--------+
| 40048   | ACC-10     | 2019-01-01 | 39  | 39000  |
| 40048   | ACC-10     | 2019-01-07 | 68  | 68000  |
| 40048   | ACC-10     | 2019-01-14 | 83  | 83000  |
| 40048   | ACC-10     | 2019-01-21 | 39  | 39000  |
| 40048   | ACC-10     | 2019-01-28 | 40  | 40000  |
| 40048   | ACC-10     | 2019-02-04 | 43  | 43000  |
| 40048   | ACC-10     | 2019-02-11 | 35  | 35000  |
| 40048   | ACC-10     | 2019-02-18 | 66  | 66000  |
| 40048   | ACC-10     | 2019-02-25 | 40  | 40000  |
| 40048   | ACC-10     | 2019-03-04 | 103 | 103000 |
+---------+------------+------------+-----+--------+
```
