package notes;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';

};

#todo, используя классы User, Moderator, Notes обработывать запросы.
#вся логика будет в Model, здесь будут только интерфейсы

true;
