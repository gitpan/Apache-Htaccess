# $Id: parse.t,v 1.1 2002/02/27 15:06:09 comdog Exp $

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use Apache::Htaccess;
use File::Copy ();
use Text::Diff;
$loaded = 1;
print "ok\n";

my @test_files = qw( t/test.ht t/htaccess );

File::Copy::copy( @test_files );

eval {
	my $obj = Apache::Htaccess->new( $test_files[-1] );
	print $obj ? '' : 'not ', "ok\n";
	};

my $diff = Text::Diff::diff( @test_files );
print $diff ? 'not ' : '', "ok\n";
if( $diff ) { print STDERR "\n$diff" };

unlink $test_files[-1];
