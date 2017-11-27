create table users (
	name text,
	surname text,
	id serial primary key
);

create table users_relations (
	id1 integer references users(id),
	id2 integer references users(id),
	primary key (id1, id2)
);

create index user_relations_id1_index ON users_relations (id1);

create index user_relations_id2_index ON users_relations (id2);
