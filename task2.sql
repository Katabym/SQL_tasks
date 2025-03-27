-- Исходные данные
-- Создаю таблицы

create table tranches
	(
		inn text
		, credit_num text
		, account text
		, operation_datetime timestamp
		, operation_sum numeric
		, doc_id numeric
	);


create table transactions
	(
		inn int
		, account text
		, operation_datetime timestamp
		, operation_sum numeric
		, ctrg_inn int
		, ctrg_account text
		, doc_id text
	);

-- Заполняю таблицы

insert into tranches (inn, credit_num, account, operation_datetime, operation_sum, doc_id) values
	 ('1234567890', 'CREDIT001', '40817810000000000001', '2023-01-01 10:00:00', 1000.00, 1)
	, ('1234567890', 'CREDIT002', '40817810000000000002', '2023-01-05 12:00:00', 1500.00, 2)
	, ('1234567890', 'CREDIT003', '40817810000000000003', '2023-01-10 14:00:00', 2000.00, 3)
	, ('1345678901', 'CREDIT004', '40817810000000000004', '2023-02-15 09:30:00', 3000.00, 4)
	, ('1456789012', 'CREDIT005', '40817810000000000005', '2023-03-20 16:45:00', 5000.00, 5)
	, ('11567890123', 'CREDIT006', '40817810000000000006', '2023-04-25 11:15:00', 7500.00, 6)
	, ('1678901234', 'CREDIT007', '40817810000000000007', '2023-05-30 14:20:00', 10000.00, 7)
	, ('1789012345', 'CREDIT008', '40817810000000000008', '2023-06-10 13:00:00', 12500.00, 8)
	, ('1890123456', 'CREDIT009', '40817810000000000009', '2023-07-15 10:45:00', 15000.00, 9)
	, ('1901234567', 'CREDIT010', '40817810000000000010', '2023-08-20 15:30:00', 20000.00, 10);

insert into transactions (inn, account, operation_datetime, operation_sum, ctrg_inn, ctrg_account, doc_id) values
	 (123456789, '40817810000000000001', '2023-01-01 10:05:00', 1000.00, 987654321, '40817810000000000004', 'T1')
	, (123456789, '40817810000000000002', '2023-01-06 12:05:00', 1500.00, 987654321, '40817810000000000005', 'T2')
	, (123456789, '40817810000000000003', '2023-01-15 14:05:00', 2500.00, 987654321, '40817810000000000006', 'T3')
	, (234567890, '40817810000000000004', '2023-02-16 10:10:00', 3200.00, 876543219, '40817810000000000007', 'T4')
	, (345678901, '40817810000000000005', '2023-03-22 15:20:00', 5500.00, 765432109, '40817810000000000008', 'T5')
	, (456789012, '40817810000000000006', '2023-04-27 11:30:00', 8000.00, 654321098, '40817810000000000009', 'T6')
	, (567890123, '40817810000000000007', '2023-06-01 14:40:00', 11000.00, 543210986, '40817810000000000010', 'T7')
	, (678901234, '40817810000000000008', '2023-06-12 13:50:00', 13000.00, 432109865, '40817810000000000011', 'T8')
	, (789012345, '40817810000000000009', '2023-07-18 10:15:00', 16000.00, 321098654, '40817810000000000012', 'T9')
	, (890123456, '40817810000000000010', '2023-08-22 15:25:00', 21000.00, 210986543, '40817810000000000013', 'T10')
	, (123456789, '40817810000000000001', '2023-01-02 10:10:00', 900.00, 987654210, '40817810000000000014', 'T11')
	, (234567890, '40817810000000000004', '2023-02-17 11:20:00', 3500.00, 876532109, '40817810000000000015', 'T12')
	, (345678901, '40817810000000000005', '2023-03-23 16:30:00', 5800.00, 765321098, '40817810000000000016', 'T13');




-- Запрос для решения задания

WITH matching_data AS (
    SELECT 
        t.inn, t.credit_num, t.account, t.operation_datetime, 
        t.operation_sum, t.doc_id,
        tr.operation_datetime AS tr_datetime, tr.operation_sum AS tr_sum,
        tr.ctrg_inn, tr.ctrg_account, tr.doc_id AS tr_doc_id,
        CASE 
            WHEN tr.operation_sum = t.operation_sum THEN 1  -- точное совпадение
            WHEN tr.operation_sum > t.operation_sum THEN 2  -- превышение суммы
            ELSE 0
        END AS match_type,
        ROW_NUMBER() OVER (PARTITION BY t.doc_id ORDER BY match_type) AS rn
    FROM tranches t
    JOIN transactions tr ON CAST(t.inn AS int) = tr.inn
        AND t.account = tr.account
        AND tr.operation_datetime BETWEEN t.operation_datetime AND t.operation_datetime + INTERVAL '10 days'
        AND (tr.operation_sum = t.operation_sum OR tr.operation_sum > t.operation_sum)
)
SELECT 
    inn AS tranche_inn, credit_num, account AS tranche_account, 
    operation_datetime AS tranche_datetime, operation_sum AS tranche_sum, 
    doc_id AS tranche_doc_id, CAST(inn AS int) AS transaction_inn, 
    account AS transaction_account, tr_datetime AS transaction_datetime,
    tr_sum AS transaction_sum, ctrg_inn, ctrg_account, tr_doc_id AS transaction_doc_id,
    match_type
FROM matching_data
WHERE (match_type = 1) OR (match_type = 2 AND rn = 1)
ORDER BY tranche_datetime, transaction_datetime;
