#!/usr/bin/perl
# 2012, WTFPL.

use strict;
use warnings;
use Cache::Memcached;

my @mds;

open(my $netstat, 'netstat -lnept4|');

while (<$netstat>) {
    if (/\s(\S*):(\d+).*memcache/) {
        push @mds, "$1:$2";
    }
}

my $memc = new Cache::Memcached;
$memc->set_servers(\@mds);
my $stats = $memc->stats();
#print Dumper($stats);

for my $host (keys %{$stats->{hosts}}) {
	$host =~ /:(\d+)/;
	my $port = $1;
	open (my $z, ">/tmp/_zabbix_memcached_stat_$port");

	for my $key (keys %{$stats->{hosts}{$host}{misc}}) {
		print $z "STAT $key $stats->{hosts}{$host}{misc}{$key}\n";
	}

	close ($z);
}
