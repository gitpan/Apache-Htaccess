# $Id: Makefile.PL,v 1.2 2001/10/20 18:05:40 comdog Exp $

use ExtUtils::MakeMaker;

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

    dist             => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },

	);
