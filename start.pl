#!/usr/bin/env perl

# use v5.26;
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

my $results = {};
for (1..$threads) {
	push @coros, async {
		my $ua = LWP::UserAgent->new(
			agent => 'Mozilla/5.0 (X11; U; Linux i686 (x86_64); en-US; rv:1.8.1.6) Gecko/20070817 IceWeasel/2.0.0.6-g2',
			timeout => 360
		);

		while (my $link = shift(@links)) {
			chomp($link);

			my $result = $ua->get($link);
			say '['.$result->code.'] '.'['.$result->message.'] '.$link;
			write_file('result/'.$result->code.'.txt', {append => 1}, $link."\n");
			unless (exists $results->{$result->code}) {
				$results->{$result->code} = []
			}
			push @{$results->{$result->code}}, $link;
		}
	};
}

$_->join for (@coros);

my $report = '';
for my $k (sort keys %{$results}) {
	my $log_part = "\nCode: $k\n" . ('-' x 200) . "\n" . join("\n", @{$results->{$k}}) . "\n" . ('-' x 200) . "\n";
	say $log_part;
	$report .= $log_part;
}
write_file('result/report.txt', {append => 0}, $report );
