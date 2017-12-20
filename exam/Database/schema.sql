#Будем использовать Postgresql
psql

#Создаем пользователя, создаем базу, даем ему права на базу
create role notes with login password 'notes';

create database notes;

GRANT ALL on DATABASE notes to  notes;

#Заходим под пользователем
psql -h localhost -d notes -U notes

#Создаем таблицы и индексы к ним
create table users (
	id serial primary key,
	username varchar(15),
	password text
);

create index users_username_index on users (username);

create table notes (
	id bigint primary key,
	create_time timestamp,
	expire_time timestamp,
	title varchar(255),
	owner bigint references users(id)
);

create index notes_owner_index on users (username);

create table permissions (
	id serial primary key,
	perm char
);

create table users_notes (
	user_id bigint references users(id),
	note_id bigint references notes(id),
	perm_id integer references permissions(id),
	primary key (user_id, note_id)
);

create table moderators (
	user_id bigint references users(id) primary key
);

#Заполним сразу таблицу permissions

insert into permissions(perm) values ('r');

insert into permissions(perm) values ('w');
