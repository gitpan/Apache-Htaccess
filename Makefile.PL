use ExtUtils::MakeMaker;

print <<'HERE';
=====================================================================
             This module is looking for a maintainer!

No one is maintaining this module, but you can take up its care
and feeding by requesting CPAN persmissions from modules@perl.org.

This version is assigned to the ADOPTME CPAN user and hosted in
GitHub:

	https://github.com/CPAN-Adopt-Me/apache-htaccess

=====================================================================
HERE

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
	AUTHOR        	=> 'Matt Cashner <matt@cre8tivegroup.com>',
	ABSTRACT        => 'Create and manipulate Apache .htaccess files',

	'META_MERGE' => {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url  => 'https://github.com/CPAN-Adopt-Me/apache-htaccess',
				web  => 'https://github.com/CPAN-Adopt-Me/apache-htaccess',
				},
			},
		},
	);
