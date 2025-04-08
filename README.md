# Решения задач SQL

## Запуск и проверка задания 1:

СУБД используемая для тестирования - [Postgres 16 ver](https://hub.docker.com/_/postgres)

Запрос и исходные данные лежат в файле **task1.sql**

БД была развернута на виртуальной машине в Docker контейнере.

#### Образы всех решений можно поставить и запустить, создав `docker-compose.yml` с таким содержимым:
```
services:
  postgres:
    image: borovinsckyyaroslaw319/sql_task_номер_задания:1.1
    ports:
      - "5435:5435"
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### Вывод результатов работы запроса с максимальным захватом данных в таблицах.
```
sql_task_1 |
sql_task_1 |
sql_task_1 | /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql
sql_task_1 | CREATE TABLE
sql_task_1 | CREATE TABLE
sql_task_1 | CREATE TABLE
sql_task_1 | CREATE TABLE
sql_task_1 | INSERT 0 6
sql_task_1 | INSERT 0 3
sql_task_1 | INSERT 0 11
sql_task_1 | INSERT 0 5
sql_task_1 |  user_id | username |      roles       | activity_count
sql_task_1 | ---------+----------+------------------+----------------
sql_task_1 |        1 | user1    | admin, moderator |              3
sql_task_1 |        6 | user6    | editor           |              3
sql_task_1 |        2 | user2    | user             |              2
sql_task_1 |        4 | user4    | guest            |              2
sql_task_1 |        3 | user3    |                  |              1
sql_task_1 |        5 | user5    |                  |              0
sql_task_1 | (6 rows)
sql_task_1 |
sql_task_1 |

```

## Запуск и проверка задания 2:

СУБД используемая для тестирования - [Postgres 16 ver](https://hub.docker.com/_/postgres)

Запрос и исходные данные лежат в файле **task2.sql**

В файле с заданием и исходными данными для ИНН указаны неподходящие типы данных:
```
create table tranches
	(
		inn text  <---------
		, credit_num text
		, account text
		, operation_datetime timestamp
		, operation_sum numeric
		, doc_id numeric
	);


create table transactions
	(
		inn int                     <---------
		, account text
		, operation_datetime timestamp
		, operation_sum numeric
		, ctrg_inn int              <---------
		, ctrg_account text
		, doc_id text
	);
```

Вместимости типа данных **int** не хватает чтобы вместить номера ИНН кредиторов с 4 по 10 номер.

Принял решение изменить типы данных на **bigint** при создании таблиц.

Впрочем если данные таблицы уже созданы и их изменение возможно - можно либо изменить тип данных на **bigint**:
```
ALTER TABLE tranches ALTER COLUMN inn TYPE bigint;
ALTER TABLE transactions ALTER COLUMN inn TYPE bigint;
ALTER TABLE transactions ALTER COLUMN ctrg_inn TYPE bigint;
```

Либо поменять тип данных в таблице *transactions* на **text** и преобразовывать данные уже в самом запросе:
```
 t.inn::bigint AS tranche_inn,
```

В файле с заданием и исходными данными обнаружил ошибки которые ломали запросы вставки:
```
insert into tranches (inn, credit_num, account, operation_datetime, operation_sum, doc_id) values
----->	, ('1234567890', 'CREDIT001', '40817810000000000001', '2023-01-01 10:00:00', 1000.00, 1)
	, ('1234567890', 'CREDIT002', '40817810000000000002', '2023-01-05 12:00:00', 1500.00, 2)
	, ('1234567890', 'CREDIT003', '40817810000000000003', '2023-01-10 14:00:00', 2000.00, 3)
	, ('2345678901', 'CREDIT004', '40817810000000000004', '2023-02-15 09:30:00', 3000.00, 4)
	, ('3456789012', 'CREDIT005', '40817810000000000005', '2023-03-20 16:45:00', 5000.00, 5)
	, ('4567890123', 'CREDIT006', '40817810000000000006', '2023-04-25 11:15:00', 7500.00, 6)
	, ('5678901234', 'CREDIT007', '40817810000000000007', '2023-05-30 14:20:00', 10000.00, 7)
	, ('6789012345', 'CREDIT008', '40817810000000000008', '2023-06-10 13:00:00', 12500.00, 8)
	, ('7890123456', 'CREDIT009', '40817810000000000009', '2023-07-15 10:45:00', 15000.00, 9)
	, ('8901234567', 'CREDIT010', '40817810000000000010', '2023-08-20 15:30:00', 20000.00, 10);

insert into transactions (inn, account, operation_datetime, operation_sum, ctrg_inn, ctrg_account, doc_id) values
----->	, (1234567890, '40817810000000000001', '2023-01-01 10:05:00', 1000.00, 9876543210, '40817810000000000004', 'T1')
	, (1234567890, '40817810000000000002', '2023-01-06 12:05:00', 1500.00, 9876543210, '40817810000000000005', 'T2')
	, (1234567890, '40817810000000000003', '2023-01-15 14:05:00', 2500.00, 9876543210, '40817810000000000006', 'T3')
	, (2345678901, '40817810000000000004', '2023-02-16 10:10:00', 3200.00, 8765432109, '40817810000000000007', 'T4')
	, (3456789012, '40817810000000000005', '2023-03-22 15:20:00', 5500.00, 7654321098, '40817810000000000008', 'T5')
	, (4567890123, '40817810000000000006', '2023-04-27 11:30:00', 8000.00, 6543210987, '40817810000000000009', 'T6')
	, (5678901234, '40817810000000000007', '2023-06-01 14:40:00', 11000.00, 5432109876, '40817810000000000010', 'T7')
	, (6789012345, '40817810000000000008', '2023-06-12 13:50:00', 13000.00, 4321098765, '40817810000000000011', 'T8')
	, (7890123456, '40817810000000000009', '2023-07-18 10:15:00', 16000.00, 3210987654, '40817810000000000012', 'T9')
	, (8901234567, '40817810000000000010', '2023-08-22 15:25:00', 21000.00, 2109876543, '40817810000000000013', 'T10')
	, (1234567890, '40817810000000000001', '2023-01-02 10:10:00', 900.00, 9876543210, '40817810000000000014', 'T11')
	, (2345678901, '40817810000000000004', '2023-02-17 11:20:00', 3500.00, 8765432109, '40817810000000000015', 'T12')
	, (3456789012, '40817810000000000005', '2023-03-23 16:30:00', 5800.00, 7654321098, '40817810000000000016', 'T13');

```

Запятая сразу после values приводит к синтаксической ошибке.

БД была развернута на виртуальной машине в Docker контейнере.

Образ с рабочим решением можно скачать и запустить создав docker-compose.yml с таким содержимым:
```
services:
  postgres:
    image: borovinsckyyaroslaw319/sql_task_2:1.1
    ports:
      - "5435:5435"
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### Вывод результатов работы запроса:
```
sql_task_2 |
sql_task_2 | /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql
sql_task_2 | CREATE TABLE
sql_task_2 | CREATE TABLE
sql_task_2 | INSERT 0 10
sql_task_2 | INSERT 0 13
sql_task_2 |  tranche_inn | credit_num |   tranche_account    |  tranche_datetime   | tranche_sum | tranche_doc_id | transaction_inn | transaction_account  | transaction_datetime | transaction_sum |  ctrg_inn  |     ctrg_account     | transaction_doc_id | match_type
sql_task_2 | -------------+------------+----------------------+---------------------+-------------+----------------+-----------------+----------------------+----------------------+-----------------+------------+----------------------+--------------------+-------------
sql_task_2 |   1234567890 | CREDIT001  | 40817810000000000001 | 2023-01-01 10:00:00 |     1000.00 |              1 |      1234567890 | 40817810000000000001 | 2023-01-01 10:05:00  |         1000.00 | 9876543210 | 40817810000000000004 | T1                 | exact_match
sql_task_2 |   1234567890 | CREDIT002  | 40817810000000000002 | 2023-01-05 12:00:00 |     1500.00 |              2 |      1234567890 | 40817810000000000002 | 2023-01-06 12:05:00  |         1500.00 | 9876543210 | 40817810000000000005 | T2                 | exact_match
sql_task_2 |   1234567890 | CREDIT003  | 40817810000000000003 | 2023-01-10 14:00:00 |     2000.00 |              3 |      1234567890 | 40817810000000000003 | 2023-01-15 14:05:00  |         2500.00 | 9876543210 | 40817810000000000006 | T3                 | overpayment
sql_task_2 |   2345678901 | CREDIT004  | 40817810000000000004 | 2023-02-15 09:30:00 |     3000.00 |              4 |      2345678901 | 40817810000000000004 | 2023-02-17 11:20:00  |         3500.00 | 8765432109 | 40817810000000000015 | T12                | overpayment
sql_task_2 |   3456789012 | CREDIT005  | 40817810000000000005 | 2023-03-20 16:45:00 |     5000.00 |              5 |      3456789012 | 40817810000000000005 | 2023-03-23 16:30:00  |         5800.00 | 7654321098 | 40817810000000000016 | T13                | overpayment
sql_task_2 |   4567890123 | CREDIT006  | 40817810000000000006 | 2023-04-25 11:15:00 |     7500.00 |              6 |      4567890123 | 40817810000000000006 | 2023-04-27 11:30:00  |         8000.00 | 6543210987 | 40817810000000000009 | T6                 | overpayment
sql_task_2 |   5678901234 | CREDIT007  | 40817810000000000007 | 2023-05-30 14:20:00 |    10000.00 |              7 |      5678901234 | 40817810000000000007 | 2023-06-01 14:40:00  |        11000.00 | 5432109876 | 40817810000000000010 | T7                 | overpayment
sql_task_2 |   6789012345 | CREDIT008  | 40817810000000000008 | 2023-06-10 13:00:00 |    12500.00 |              8 |      6789012345 | 40817810000000000008 | 2023-06-12 13:50:00  |        13000.00 | 4321098765 | 40817810000000000011 | T8                 | overpayment
sql_task_2 |   7890123456 | CREDIT009  | 40817810000000000009 | 2023-07-15 10:45:00 |    15000.00 |              9 |      7890123456 | 40817810000000000009 | 2023-07-18 10:15:00  |        16000.00 | 3210987654 | 40817810000000000012 | T9                 | overpayment
sql_task_2 |   8901234567 | CREDIT010  | 40817810000000000010 | 2023-08-20 15:30:00 |    20000.00 |             10 |      8901234567 | 40817810000000000010 | 2023-08-22 15:25:00  |        21000.00 | 2109876543 | 40817810000000000013 | T10                | overpayment
sql_task_2 | (10 rows)
sql_task_2 |
```


## Запуск и проверка задания 3:

СУБД используемая для тестирования - [Postgres 16 ver](https://hub.docker.com/_/postgres)

Запрос и исходные данные лежат в файле **task3.sql**

В файле с заданием и исходными данными выявил синтаксические ошибки:
```
create table accounts
	(
		account_id serial primary key,     <------------
		, client_id int references clients(client_id) on delete cascade
		, balance decimal(15, 2) not null check (balance >= 0)
		, open_date date not null
	);


insert into clients (name, age, registration_date) values
------>	, ('Иван Иванов', 30, '2019-05-15')
	, ('Мария Петрова', 25, '2020-01-10')
	, ('Алексей Сидоров', 40, '2021-03-22')
	, ('Елена Кузнецова', 35, '2020-07-19')
	, ('Дмитрий Смирнов', 28, '2022-11-05')
	, ('Ольга Васнецова', 50, '2018-12-30')
	, ('Сергей Козлов', 33, '2020-06-14')
	, ('Анна Морозова', 29, '2021-09-01')
	, ('Павел Новиков', 45, '2019-08-25')
	, ('Татьяна Павлова', 31, '2020-04-17');
	
	insert into transactions (account_id, amount, transaction_date, transaction_type) values
----->	, (1, 1000.00, '2023-01-05', 'deposit')
	, (1, 500.00, '2023-01-10', 'withdrawal')
	, (2, 2000.00, '2023-02-15', 'deposit')
	, (2, 1000.00, '2023-02-20', 'withdrawal')
	, (3, 3000.00, '2023-03-25', 'deposit')
	, (3, 1500.00, '2023-03-30', 'withdrawal')
	, (4, 4000.00, '2023-04-05', 'deposit')
	, (4, 2000.00, '2023-04-10', 'withdrawal')
	, (5, 5000.00, '2023-05-15', 'deposit')
	, (5, 2500.00, '2023-05-20', 'withdrawal')
	, (6, 6000.00, '2023-06-25', 'deposit')
	, (6, 3000.00, '2023-06-30', 'withdrawal')
	, (7, 7000.00, '2023-07-05', 'deposit')
	, (7, 3500.00, '2023-07-10', 'withdrawal')
	, (8, 8000.00, '2023-08-15', 'deposit')
	, (8, 4000.00, '2023-08-20', 'withdrawal')
	, (9, 9000.00, '2023-09-25', 'deposit')
	, (9, 4500.00, '2023-09-30', 'withdrawal')
	, (10, 10000.00, '2023-10-05', 'deposit')
	, (10, 5000.00, '2023-10-10', 'withdrawal');
```
Запятая сразу после values приводит к синтаксической ошибке. 

При создании таблицы accounts две запятой подряд приводят к синтаксической ошибке.

### Время выполнения исходного запроса
```
 -- Первый запуск
 Buffers: shared hit=7 read=1
 Planning Time: 2.252 ms
 Execution Time: 1.265 ms
(64 rows)

 -- Пятый запуск
 Planning Time: 0.430 ms
 Execution Time: 1.135 ms
(62 rows)
```

### Время выполения оптимизированного запроса
```
 -- Первый запуск
 Planning Time: 0.380 ms
 Execution Time: 0.165 ms
(32 rows)

 -- Пятый запуск
 Planning Time: 0.244 ms
 Execution Time: 0.172 ms
(32 rows)
```

### Анализ выполнения исходного запроса:
```
                                                                        QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=12311.66..12311.91 rows=103 width=282) (actual time=1.030..1.035 rows=7 loops=1)
   Sort Key: ((SubPlan 2)) DESC
   Sort Method: quicksort  Memory: 25kB
   Buffers: shared hit=309
   ->  Seq Scan on clients c  (cost=0.00..12308.21 rows=103 width=282) (actual time=0.531..1.018 rows=7 loops=1)
         Filter: (registration_date >= '2020-01-01'::date)
         Rows Removed by Filter: 3
         Buffers: shared hit=309
         SubPlan 1
           ->  Aggregate  (cost=27.52..27.53 rows=1 width=8) (actual time=0.055..0.056 rows=1 loops=7)
                 Buffers: shared hit=7
                 ->  Seq Scan on accounts a  (cost=0.00..27.50 rows=7 width=0) (actual time=0.053..0.053 rows=1 loops=7)
                       Filter: (client_id = c.client_id)
                       Rows Removed by Filter: 10
                       Buffers: shared hit=7
         SubPlan 2
           ->  Aggregate  (cost=27.52..27.53 rows=1 width=32) (actual time=0.004..0.004 rows=1 loops=7)
                 Buffers: shared hit=7
                 ->  Seq Scan on accounts a_1  (cost=0.00..27.50 rows=7 width=18) (actual time=
0.001..0.002 rows=1 loops=7)
                       Filter: (client_id = c.client_id)
                       Rows Removed by Filter: 10
                       Buffers: shared hit=7
         SubPlan 3
           ->  Aggregate  (cost=32.14..32.15 rows=1 width=8) (actual time=0.029..0.029 rows=1 loops=7)
                 Buffers: shared hit=147
                 ->  Nested Loop  (cost=0.16..32.14 rows=1 width=0) (actual time=0.019..0.028 rows=1 loops=7)
                       Buffers: shared hit=147
                       ->  Seq Scan on transactions t  (cost=0.00..15.75 rows=2 width=4) (actual time=0.002..0.005 rows=10 loops=7)
                             Filter: ((transaction_type)::text = 'deposit'::text)
                             Rows Removed by Filter: 10
                             Buffers: shared hit=7
                       ->  Memoize  (cost=0.16..8.18 rows=1 width=4) (actual time=0.002..0.002 rows=0 loops=70)
                             Cache Key: t.account_id
                             Cache Mode: logical
                             Hits: 0  Misses: 70  Evictions: 60  Overflows: 0  Memory Usage: 1kB
                             Buffers: shared hit=140
                             ->  Index Scan using accounts_pkey on accounts a_2  (cost=0.15..8.17 rows=1 width=4) (actual time=0.001..0.001 rows=0 loops=70)
                                   Index Cond: (account_id = t.account_id)
                                   Filter: (client_id = c.client_id)
                                   Rows Removed by Filter: 1
                                   Buffers: shared hit=140
         SubPlan 4
           ->  Aggregate  (cost=32.14..32.15 rows=1 width=8) (actual time=0.024..0.024 rows=1 loops=7)
                 Buffers: shared hit=147
                 ->  Nested Loop  (cost=0.16..32.14 rows=1 width=0) (actual time=0.014..0.023 rows=1 loops=7)
                       Buffers: shared hit=147
                       ->  Seq Scan on transactions t_1  (cost=0.00..15.75 rows=2 width=4) (actual time=0.001..0.004 rows=10 loops=7)
                             Filter: ((transaction_type)::text = 'withdrawal'::text)
                             Rows Removed by Filter: 10
                             Buffers: shared hit=7
                       ->  Memoize  (cost=0.16..8.18 rows=1 width=4) (actual time=0.002..0.002 rows=0 loops=70)
                             Cache Key: t_1.account_id
                             Cache Mode: logical
                             Hits: 0  Misses: 70  Evictions: 60  Overflows: 0  Memory Usage: 1kB
                             Buffers: shared hit=140
                             ->  Index Scan using accounts_pkey on accounts a_3  (cost=0.15..8.17 rows=1 width=4) (actual time=0.001..0.001 rows=0 loops=70)
                                   Index Cond: (account_id = t_1.account_id)
                                   Filter: (client_id = c.client_id)
                                   Rows Removed by Filter: 1
                                   Buffers: shared hit=140
```

### Анализ выполенения нового запроса
```
                                                                     QUERY PLAN                                                          
----------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=106.40..106.65 rows=103 width=282) (actual time=0.107..0.110 rows=7 loops=1)
   Sort Key: (COALESCE(ad.total_balance, '0'::numeric)) DESC
   Sort Method: quicksort  Memory: 25kB
   Buffers: shared hit=3
   ->  Hash Left Join  (cost=88.81..102.95 rows=103 width=282) (actual time=0.093..0.099 rows=7 loops=1)
         Hash Cond: (c.client_id = ad.client_id)
         Buffers: shared hit=3
         ->  Seq Scan on clients c  (cost=0.00..13.88 rows=103 width=226) (actual time=0.013..0.015 rows=7 loops=1)
               Filter: (registration_date >= '2020-01-01'::date)
               Rows Removed by Filter: 3
               Buffers: shared hit=1
         ->  Hash  (cost=86.31..86.31 rows=200 width=60) (actual time=0.072..0.074 rows=10 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               Buffers: shared hit=2
               ->  Subquery Scan on ad  (cost=81.81..86.31 rows=200 width=60) (actual time=0.059..0.070 rows=10 loops=1)
                     Buffers: shared hit=2
                     ->  HashAggregate  (cost=81.81..84.31 rows=200 width=60) (actual time=0.058..0.067 rows=10 loops=1)
                           Group Key: a.client_id
                           Batches: 1  Memory Usage: 40kB
                           Buffers: shared hit=2
                           ->  Hash Right Join  (cost=41.50..57.31 rows=1400 width=140) (actual time=0.020..0.034 rows=21 loops=1)
                                 Hash Cond: (t.account_id = a.account_id)
                                 Buffers: shared hit=2
                                 ->  Seq Scan on transactions t  (cost=0.00..14.60 rows=460 width=122) (actual time=0.003..0.005 rows=20 loops=1)
                                       Buffers: shared hit=1
                                 ->  Hash  (cost=24.00..24.00 rows=1400 width=26) (actual time=0.011..0.012 rows=11 loops=1)
                                       Buckets: 2048  Batches: 1  Memory Usage: 17kB
                                       Buffers: shared hit=1
                                       ->  Seq Scan on accounts a  (cost=0.00..24.00 rows=1400 width=26) (actual time=0.003..0.006 rows=11 loops=1)
                                             Buffers: shared hit=1
```

### Вывод результатов работы запроса.
```
sql_task_3 |
sql_task_3 | /usr/local/bin/docker-entrypoint.sh: running /docker-entrypoint-initdb.d/init.sql
sql_task_3 | CREATE TABLE
sql_task_3 | CREATE TABLE
sql_task_3 | CREATE TABLE
sql_task_3 | INSERT 0 10
sql_task_3 | INSERT 0 11
sql_task_3 | INSERT 0 20
sql_task_3 |  client_id |      name       | age | total_accounts | total_balance | total_deposits | total_withdrawals
sql_task_3 | -----------+-----------------+-----+----------------+---------------+----------------+-------------------
sql_task_3 |          3 | Алексей Сидоров |  40 |              2 |      60000.00 |              1 |                 1
sql_task_3 |          5 | Дмитрий Смирнов |  28 |              2 |      50000.00 |              1 |                 1
sql_task_3 |          2 | Мария Петрова   |  25 |              2 |      40000.00 |              1 |                 1
sql_task_3 |          8 | Анна Морозова   |  29 |              2 |      36000.00 |              1 |                 1
sql_task_3 |          7 | Сергей Козлов   |  33 |              2 |      24000.00 |              1 |                 1
sql_task_3 |          4 | Елена Кузнецова |  35 |              2 |      20000.00 |              1 |                 1
sql_task_3 |         10 | Татьяна Павлова |  31 |              1 |      15000.00 |              0 |                 0
sql_task_3 | (7 rows)
sql_task_3 |
```