package Model::Notes::Note;
use Moose;
use 5.016;
use DDP;
use Dancer2;
use Dancer2::Plugin::Database;
use Moose::Util::TypeConstraints;
use FindBin;
use lib "$FindBin::Bin/../";
use Model::Users::User;

subtype 'timestamp'
	=> as 'Int'
	=> where { $_ >= 0 }
	=> message { "$_ is not a stimestamp" }; 

has 'create_time' => (
	is => 'ro',
	required => 1,
	isa => 'timestamp',
);

has 'expire_time' => (
	is => 'ro',
	required => 1,
	isa => 'timestamp',
);

subtype 'title'
	=> as 'Int'
	=> where { length $_ <= 255 }
	=> message { "$_ is not a tittle" };

has 'title' => (
	is => 'ro',
	required => 1,
	isa => 'title',
);

#получает пользователя, возращает его права на себя
sub get_perm_for_user {

}

1;