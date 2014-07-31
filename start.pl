#!/usr/bin/env perl

# use v5.20.0;
use utf8;
use strict;
use warnings;
use feature qw/say switch/;
# use open (:utf8 :std);

use Coro;
use File::Slurp;
use Coro::LWP;
use LWP::UserAgent;

##################################
my $threads = 100;
##################################
mkdir('result') unless (-d 'result');

my @links = read_file('urls.txt');
my @coros;

for (1..$threads) {
	push @coros, async {
		my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.8.1.6) Gecko/20070817 IceWeasel/2.0.0.6-g2',
			timeout => 360
		);

		while (my $link = shift(@links)) {
			chomp($link);

			my $result = $ua->get($link);
			say '['.$result->code.'] '.$link;
			write_file( 'result/'.$result->code.'.txt', {append => 1}, $link."\n" );
		}
	};
}

$_->join for (@coros);