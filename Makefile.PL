use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'		=> 'Apache::Htaccess',
    'VERSION_FROM'	=> 'Htaccess.pm', 
    'PREREQ_PM'		=> {}, 
	'AUTHOR' => 'Matt Cashner',
	'ABSTRACT' => 'Create and manipulate Apache .htaccess files',
);
