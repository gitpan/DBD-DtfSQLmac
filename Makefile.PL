#
# Installation Makefile for DBD::DtfSQLmac
#
# Author: Thomas Wegner 
# Date: 2001-Feb-21
#

use ExtUtils::MakeMaker;


print "\n\nInstall DBD::DtfSQLmac and the interface module Mac::DtfSQL ...\n\n";

if ($^O eq 'MacOS') {
	print "OS is $^O.\n";
} else {
	die "This module is for Mac OS only. Your OS is $^O.";
}


print <<EOT_README;


ReadMe ...


*** PLEASE NOTE                                (You have to do that manually)
===============================================================================
             
The Mac::DtfSQL module needs the dtF/SQL 2.01 shared library for PPC in order 
to work. This lib has to be placed in the proper location on your harddisk: 

After installation of this module, either put the dtF/SQL 2.01 shared library 
"dtFPPCSV2.8K.shlb" (or at least an alias to it) in the *same* folder as the 
shared library "DtfSQL" built from the interface module (the folder is 
:site_perl:MacPPC:auto:Mac:DtfSQL:) or put the dtF/SQL 2.01 shared library in 
the *system extensions* folder.

===============================================================================



EOT_README


undef $@;
eval 'use DBI';

if ($@) {
    print <<EOT;
	
The DBI module is not installed on your Macintosh.

If you want to install DBD::DtfSQLmac, you must install DBI before installing 
this driver. Visit the MacPerl Module Porters Page at http://pudge.net/mmp/ to 
get a copy of DBI 1.08, Mac build. 

Exit.

EOT
	
	exit (1);
}#if


print "Found DBI version $DBI::VERSION.\n\n";

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'	=> 'Mac::DtfSQL',
	'DISTNAME' => 'DBD::DtfSQLmac',
	'PREREQ_PM' => ['DBI' => '1.08'],
	'LIBS'		=> [''],   # e.g., '-lm' 
    'VERSION_FROM' => 'DtfSQL.pm', # finds $VERSION

);
