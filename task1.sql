-- Исходные данные
-- Создаю таблицы

create table users
	(
		id integer primary key
		, username varchar not null
		, created_at date not null
	);

create table user_activity
	(
		id integer primary key
		, user_id integer not null
		, activity_type_id integer not null
		, activity_date date not null
		, foreign key (user_id) references users(id)
	);

create table activity_types
	(
		id integer primary key
		, name varchar not null
	);

create table user_roles
	(
		id integer primary key
		, user_id integer not null
		, role varchar not null
		, assigned_at date not null
		, foreign key (user_id) references users(id)
	);

-- Заполняю таблицы

insert into users (id, username, created_at) values
	(1, 'user1', '2023-01-01')
	, (2, 'user2', '2023-02-15')
	, (3, 'user3', '2023-03-10')
	, (4, 'user4', '2023-04-01')
	, (5, 'user5', '2023-05-01')
	, (6, 'user6', '2023-06-01');

insert into activity_types (id, name) values
	(1, 'login')
	, (2, 'logout')
	, (3, 'purchase');

insert into user_activity (id, user_id, activity_type_id, activity_date) values
	(1, 1, 1, '2023-10-01')
	, (2, 1, 2, '2023-10-05')
	, (3, 1, 1, '2023-10-10')
	, (4, 2, 1, '2023-10-15')
	, (5, 2, 3, '2023-09-20')
	, (6, 3, 1, '2023-08-25')
	, (7, 4, 1, '2023-10-22')
	, (8, 4, 2, '2023-10-25')
	, (9, 6, 1, '2023-10-05')
	, (10, 6, 3, '2023-10-10')
	, (11, 6, 1, '2023-09-30');

insert into user_roles (id, user_id, role, assigned_at) values
	(1, 1, 'admin', '2023-10-01')
	, (2, 1, 'moderator', '2023-10-05')
	, (3, 2, 'user', '2023-10-10')
	, (4, 4, 'guest', '2023-10-20')
	, (5, 6, 'editor', '2023-10-15');


-- Задание:
-- 1.	Активность пользователей
-- Формулировка задачи:
-- Напишите SQL-запрос, который возвращает список пользователей с их ролями 
-- и количеством активностей за последний месяц. Учитывайте только те активности, 
-- которые были зарегистрированы в течение этого периода. Результаты должны быть 
-- отсортированы по количеству активностей в порядке убывания.


-- Запрос для решения задания

SELECT 
    u.id,
    u.username,
    STRING_AGG(DISTINCT ur.role, ', ') AS roles,
    COUNT(ua.id) AS activity_count
FROM 
    users u
LEFT JOIN 
    user_roles ur ON u.id = ur.user_id
LEFT JOIN 
    user_activity ua ON u.id = ua.user_id 
	AND ua.activity_date >= '2023-10-01' 
	AND ua.activity_date < '2023-11-01'
GROUP BY 
    u.id
ORDER BY 
    activity_count DESC;
