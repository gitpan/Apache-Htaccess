# $Header: /usr/local/apache/cvs/usermanage/Apache/Htaccess.pm,v 1.7 2000/09/29 12:50:11 matt Exp $

=head1 NAME

Apache::Htaccess - Create and modify Apache .htaccess files

=head1 SYNOPSIS

	use Apache::Htaccess;

	my $obj = Apache::Htaccess->new("htaccess");

	$obj->global_require(@groups);

	$obj->directives(CheckSpelling => 'on');
	
	$obj->requires('admin.cgi',@groups);

	$obj->save();


=head1 DESCRIPTION

This module provides an OO interface to Apache .htaccess files. Currently
the ability exists to read and write simple htaccess files. 

=head1 AUTHOR 

Matt Cashner <matt@cre8tivegroup.com>

=head1 COPYRIGHT

All code is copyright (c) 2000 by The Creative Group. It 
may be distributed under the terms of Perl itself.

=head1 METHODS

=over 5

=cut

package Apache::Htaccess;

use strict;
use warnings;
use vars qw($CVSVERSION $VERSION);

use Carp;

( $CVSVERSION ) = '$Revision: 1.7 $ ' =~ /\$Revision:\s+([^\s]+)/;

$VERSION = 0.2;


#####################################################
# parse
# - Private function -
# In/Out Param: an Apache::Htaccess object
# Function: opens the content stored in $self->{HTACCESS} and converts it to 
#			Apache::Htaccess' internal data structure.
# Note: this will act on the object in place (note the prototype).

my $parse = sub (\$) { 
	my $self = shift;


	#Suck off comments
	$self->{HTACCESS} =~ s/[\#\;].*?\n//sg;


	#Suck off and store <files> directives
	my @files = $self->{HTACCESS} =~ m|(<files.+?/files>)|sig;
	$self->{HTACCESS} =~ s|<files.+?/files>||sig;


	#Munge <files> directives into the data structure
	foreach my $directive (@files) {
		my ($filelist) = $directive =~ /<files\s+(.+?)>/sig;
		my @filelist = split(/\s+/,$filelist);
		
		my ($groups) = $directive =~ /require group\s+(.+?)\n/sig;
		my @groups = split(/\s+/,$groups);
		
		foreach my $file (@filelist) {
			foreach (@groups) {
				$self->{REQUIRE}->{$file}->{$_}++;
			}
		}
	}		


	#Suck off and store global require directives
	my ($global_req) = $self->{HTACCESS} =~ /require group\s+(.+?)\n/is;
	$self->{HTACCESS} =~ s/require group.+?\n//is;

	
	#Suck off and store all remaining directives
	while($self->{HTACCESS} =~ /(?<=\n)(.+?)(?=\n)/sg) {
		push @{$self->{DIRECTIVES}}, split(/\s+/,$1,2);
	}

	chomp @{$self->{DIRECTIVES}};


	#dump the remaining file bits
	delete $self->{HTACCESS};
};



#####################################################
# deparse
# - Private function -
# In/Out Param: an Apache::Htaccess object
# Function: takes the object's internal data structures and generates an htaccess file.
#           the htaccess file contents are stored in $self->{HTACCESS}
# Note: this will act on the object in place (note the prototype).

my $deparse = sub (\$) {
	my $self = shift;
	my $content;
	
	$content .= "# This htaccess file created by Apache::Htaccess\n# Send questions and comments to matt\@cre8tivegroup.com\n\n";
	
	if($self->{GLOBAL_REQ}) { 
		$content .= "require group @{$self->{GLOBAL_REQ}}\n";
	}
	
	if(exists($self->{DIRECTIVES})) {	
		my $i;
		for($i = 0; $i < @{$self->{DIRECTIVES}}; $i++) {
			my $key = $self->{DIRECTIVES}[$i];
			my $value = $self->{DIRECTIVES}[++$i];
			next unless ($key && $value);
			$content .= "$key $value\n";
		}
	}
	
	$content .= "\n";	

	if(exists($self->{REQUIRE})) {
		foreach (keys %{$self->{REQUIRE}}) {
			next unless exists $self->{REQUIRE}->{$_};
			
			my $groups = join " " , sort keys %{$self->{REQUIRE}->{$_}};
			next unless $groups;
			
			$content .= "<files $_>\n";
			$content .= "\trequire group $groups\n";
			$content .= "</files>\n";
		}
	}

	$self->{HTACCESS} = $content;

};



##########################################################

=head2 B<new()>

	my $obj = Apache::Htaccess->new($path_to_htaccess);

Creates a new Htaccess object either with data loaded from an existing
htaccess file or from scratch

=cut
		  
sub new {
	my $class = shift;
	croak "Must provide a path to the .htaccess file" unless my $file = shift;
	my $self = {};
	$self->{FILENAME} = $file;
	if(-e $file) {
		open(FILE,$file);
		{	local $/; 
			$self->{HTACCESS} = <FILE>;
		}
		close FILE;
		&$parse($self);
	}

	bless $self, $class;
	return $self;
}



###########################################################

=head2 B<save()>

	$obj->save();

Saves the htaccess file to the filename designated at object creation.
This method is automatically called on object destruction.

=cut

sub save {
	my $self = shift;
	&$deparse($self);
	open(FILE,"+>$self->{FILENAME}") or return 0;
	print FILE $self->{HTACCESS};
	close FILE;
	return 1;
}

sub DESTROY {
	my $self = shift;
	$self->save();
}



###########################################################

=head2 B<global_require()>

	$obj->global_require(@groups);

Sets a global group requirement. If no params are provided,
will return a list of the current groups listed in the global
require.

=cut

sub global_require {
	my $self = shift;
	@_ ? push @{$self->{GLOBAL_REQ}}, @_
	   : return @{$self->{GLOBAL_REQ}};
	return 1;
}




###########################################################

=head2 B<requires()>

	$obj->requires($file,@groups);

Sets a group requirement for a file. If no params are given,
returns a list of the current groups listed in the files
require directive.

=cut

sub requires {
	my $self = shift;
	my $file = shift or return 0;
	if(@_) {
		foreach my $group (@_) {
			$self->{REQUIRE}->{$file}->{$group}++;
		}
	} else {
	   return sort keys %{$self->{REQUIRE}->{$file}};
	}
	return 1;
}



###########################################################

=head2 B<directives()>

	$obj->directives(CheckSpelling => 'on');

Sets misc directives not directly supported by the API. If
no params are given, returns a list of current directives 
and their values. Note: as of 0.2, passing this method a 
parameter list causes the directive list to be overwritten
with your parameters. see L<add_directive()>.

=cut

sub directives {
	my $self = shift;
	@_ ? @{$self->{DIRECTIVES}} = @_
	   : return @{$self->{DIRECTIVES}};
	return 1;
}




############################################################

=head2 B<add_directive()>

	$obj->add_directive(CheckSpelling => 'on');

Sets a directive (or directives) nondestructively. Use this
if you just want to add a few directives without messing
with all of the directive entries.

=cut

sub add_directive {
	my $self = shift;
	@_ ? push @{$self->{DIRECTIVES}}, @_
	   : return 0;
	return 1;
}


1;

=back

=head1 HISTORY

	$Log: Htaccess.pm,v $
	Revision 1.7  2000/09/29 12:50:11  matt
	made directives() destructive and created the add_directive method()
	
	Revision 1.6  2000/09/27 18:43:23  matt
	added more return values. its amazing the little things i forget
	
	Revision 1.5  2000/09/27 18:30:34  matt
	fixed silly pod problem
	
	Revision 1.4  2000/09/27 18:23:46  matt
	added useful return values to save().
	
	Revision 1.3  2000/09/27 18:19:34  matt
	parse now works and can parse htaccess files the module has created (or very similar files). added more docs
	
	Revision 1.2  2000/09/27 14:19:26  matt
	deparse now working, additional docs added
	
	Revision 1.1  2000/09/26 21:20:24  matt
	first nonfunctional version :)  data structures are set up and accessor methods to those structures are ready. input and output of the file (note: the useful sections) are not yet written.
	

=cut
