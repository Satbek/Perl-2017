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
