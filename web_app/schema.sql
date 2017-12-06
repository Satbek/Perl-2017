PostgreSQL

psql

create role web_notes with login password 'web_notes';

create database web_notes;

psql -h localhost -d web_notes -U web_notes 

create table users (
	id serial primary key,
	username varchar(15),
	password text
);

create index users_id_index on users using hash ( id );

create index user_names_index on users using hash ( username );

create table notes (
	id serial primary key,
	title varchar(30),
	owner integer references users(id)
);

create index notes_owner_index on notes using hash ( owner );

create table users_notes (
	user_id integer references users(id),
	note_id integer references notes(id),
	primary key (user_id, note_id)
);

create index users_notes_user_id_index on users_notes using hash ( user_id );

create index users_notes_note_id_index on users_notes using hash ( note_id );