package Local::DateTypes;
use Moose::Util::TypeConstraints;

subtype 'day'
	=> as 'Int'
	=> where { $_ >= 1 && $_ <= 31 }
	=> message { "$_ can't be a day of month!" };

subtype 'month'
	=> as 'Int'
	=> where { $_ >= 1 && $_ <= 12 }
	=> message { "$_ can't be a day of month!" };

subtype 'year'
	=> as 'Int'
	=> where { $_ >= 1900 && $_ <= 2038 }
	=> message { "$_ can't be a year or not supported!" };
#в документации написано, что по стандрату 
#time_t поддерживает такой промежуток

subtype 'hours'
	=> as 'Int'
	=> where { $_ >= 0 && $_ <= 23 }
	=> message { "$_ can't be an hour!" };

subtype 'minutes'
	=> as 'Int'
	=> where { $_ >= 0 && $_ <= 59 }
	=> message { "$_ can't be a minutes!" };

subtype 'seconds'
	=> as 'Int'
	=> where { $_ >= 0 && $_ <= 59 }
	=> message { "$_ can't be a second!" };


1;