#!perl -w

#-----------------------------------------------------------------------#
#  INSTALL.pl
#
#  Author: Thomas Wegner 
#  Date: 2001-Nov-11
#
#-----------------------------------------------------------------------#
#  This script installs the DBD-DtfSQLmac-0.2201 distribution.
#
#  (This script is based on code found in Chris Nandor's 
#   INSTALL.plx script that comes with his cpan-mac
#   distribution. Credits to Chris.)
#-----------------------------------------------------------------------#

use 5.6.0;
use strict;
use warnings;

use File::Copy;
use File::Find;
use File::Path;
use AutoSplit;

our ($fromdir, $todir, $auto_dir);
my $blib_dir = ':blib:';
my $distribution = "DBD-DtfSQLmac-0.2201";

$todir = "$ENV{MACPERL}site_perl:";

my $readme = <<"EOT";

Readme...


*** PLEASE NOTE                           (You have to do that manually)
==========================================================================
             
The Mac::DtfSQL module needs the dtF/SQL 2.01 shared library for PPC in 
order to work. This lib has to be placed in the proper location on your 
harddisk: 

After installation of this module, either put the dtF/SQL 2.01 shared 
library "dtFPPCSV2.8K.shlb" (or at least an alias to it) in the *same* 
folder as the shared library "DtfSQL" built from the interface module 
(by default, the folder is :site_perl:MacPPC:auto:Mac:DtfSQL:) or put 
the dtF/SQL 2.01 shared library in the *system extensions* folder.

==========================================================================



This script automatically installs all modules and shared libraries that
come with the $distribution distribution into the

    $todir
	
folder. You are able to override this default. Enter a new destination
directory if the default doesn't fit your needs. Of course, this should
be (or should become) one of your search paths for library modules, or 
MacPerl might not find the new modules. The script will continue to prompt 
the (new) destination directory until you simply hit <Return> or <Enter> 
(in the MPW-Shell) for confirmation. 

NOTE: You may also enter "quit" or "exit" to terminate this script.

EOT

print $readme;
while (1) { # loop forever
   
   	print "\nDestination [$todir]> ";

    my $newdir = <STDIN>;
    chomp $newdir;

	# under MPW, the whole line including the prompt is the
	# input, so get rid of the prompt	
	$newdir =~ s/^Destination \[$todir\]>\s*//;
    
	if ($newdir ne '') {
		exit(0) if (($newdir =~ /^\s*QUIT\s*$/i) || ($newdir =~ /^\s*EXIT\s*$/i));
		$todir = $newdir;
	} else {
		last;	
	}
}

print "\n\n";
$todir = "$todir:" unless $todir =~ /:$/; # ensure a trailing ':'

# create auto dir for Autoloader (avoid autosplit warning)
$auto_dir = $todir . 'auto:';
mkpath($auto_dir, 1); 

opendir(DIR, $blib_dir) or die $!;
while (defined(my $d = readdir(DIR))) {
    next unless -d "$blib_dir$d:";
    $fromdir = "$blib_dir$d:";
    find(\&copyit, $fromdir);
}
closedir(DIR);
print "\nDone.\n";


sub copyit {
    local($_) = $_;
    my ($newdir, $name) = ($File::Find::dir, $File::Find::name);
    $newdir =~ s/\Q$fromdir\E/$todir/;
    $name   =~ s/.*\Q$fromdir\E//;
    return if -d $_ || $name =~ /:Icon\015$/;
    print "\nCopying  $name\n";
	print "     to  $newdir\n";
    mkpath($newdir, 0);
    copy($_, "$newdir$_") ||Êdie $^E;
    autosplit("$newdir$_", $auto_dir, 0, 1, 1) if /\.pm$/;
}
