# $Id: Makefile.PL,v 1.3 2002/02/28 11:44:10 comdog Exp $

use ExtUtils::MakeMaker;

my $text = eval { require Text::Diff };
my $file = eval { require File::Copy };

print <<"HERE" unless $text && $file;


Some of the tests for this module use modules that Apache::Htaccess
does not need itself.  If you do not have these modules installed
I will not force you to install them.  The appropriate tests will
be skipped during `make test`.

	parse.t		- needs Text::Diff and File::Copy

HERE

print "I could not find Text::Diff\n" unless $text;
print "I could not find File::Copy\n" unless $file;

print "\n\n" unless $text && $file;

WriteMakefile(
    NAME		    => 'Apache::Htaccess',
    VERSION_FROM	=> 'lib/Htaccess.pm', 
    PM              => 
    	{
		'lib/Htaccess.pm'  => '$(INST_LIBDIR)/Htaccess.pm',
		},
    PREREQ_PM		=> {}, 
	AUTHOR        	=> 'brian d foy <bdfoy@cpan.org>',
	ABSTRACT        => 'Create and manipulate Apache .htaccess files',
	);
