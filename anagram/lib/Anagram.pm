package Anagram;
# vim: noet:

use 5.016;
use warnings;
use Encode qw(decode encode);
use DDP;
use utf8;
binmode(STDOUT,':utf8');

=encoding UTF8

=head1 SYNOPSIS

Поиск анаграмм

=head1 anagram($arrayref)

Функция поиска всех множеств анаграмм по словарю.

Входные данные для функции: ссылка на массив - каждый элемент которого - слово на русском языке в кодировке utf8

Выходные данные: Ссылка на хеш множеств анаграмм.

Ключ - первое встретившееся в словаре слово из множества
Значение - ссылка на массив, каждый элемент которого слово из множества, в том порядке в котором оно встретилось в словаре в первый раз.

Множества из одного элемента не должны попасть в результат.

Все слова должны быть приведены к нижнему регистру.
В результирующем множестве каждое слово должно встречаться только один раз.
Например

anagram(['пятак', 'ЛиСток', 'пятка', 'стул', 'ПяТаК', 'слиток', 'тяпка', 'столик', 'слиток'])

должен вернуть ссылку на хеш


{
	'пятак'  => ['пятак', 'пятка', 'тяпка'],
	'листок' => ['листок', 'слиток', 'столик'],
}

=cut

sub get_key($) {
	return join '', sort split("",fc shift);
}

sub anagram {
	my $words_list = shift;
	my %buf_hash;
	my %result;
	for my $word (@{$words_list}) {
		$word = fc($word);
		my $key = get_key($word);
		$buf_hash{$key} //= [];
		push @{$buf_hash{$key}}, $word;
	}
	for my $key(keys %buf_hash) {
		my %seen;
		$buf_hash{$key} = [ grep {!$seen{$_}++} @{$buf_hash{$key}} ];
		my $new_key = $buf_hash{$key}->[0];
		$result{$new_key} = $buf_hash{$key};
		delete $result{$new_key} if @{$result{$new_key}} == 1;
	}
	return \%result;
}

1;
