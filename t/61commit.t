#! perl -w
#
#
#   This is testing the transaction support.
#

$^W = 1;


use DBI qw(:sql_types);
use vars qw($NO_FLAG $COL_NULLABLE $COL_PRIMARY_KEY $verbose);

#
#   Make -w happy
#
$test_dsn = '';
$test_user = '';
$test_password = '';


#
#   Include lib.pl
#

$file = "lib.pl"; 
do $file; 
if ($@) { 
	print "Error while executing lib.pl: $@\n";
	exit 10;
}



use vars qw($gotWarning);
sub CatchWarning ($) {
    $gotWarning = 1;
}


sub NumRows($$$) {
    my($dbh, $table, $num) = @_;
    my($sth, $got);

    if (!($sth = $dbh->prepare("SELECT * FROM $table"))) {
	return "Failed to prepare: err " . $dbh->err . ", errstr "
	    . $dbh->errstr;
    }
    if (!$sth->execute) {
	return "Failed to execute: err " . $dbh->err . ", errstr "
	    . $dbh->errstr;
    }
    $got = 0;
    while ($sth->fetchrow_arrayref) {
	++$got;
    }
    if ($got ne $num) {
	return "Wrong result: Expected $num rows, got $got.\n";
    }
    return '';
}

#
#   Main loop; leave this untouched, put tests after creating
#   the new table.
#
while (Testing()) {
    #
    #   Connect to the database
	#
	### Test 1
    Test($state or ($dbh = DBI->connect($test_dsn, $test_user,
					$test_password)),
	 undef,
	 "Attempting to connect.\n")
	or ErrMsgF("Cannot connect: Error (%s): %s\n\n",
		   $DBI::err, $DBI::errstr);

    #
    #   Find a possible new table name
    #
	#
	### Test 2
    Test($state or $table = FindNewTable($dbh))
	or ErrMsgF("Cannot determine a legal table name: Error %s.\n",
		   $dbh->errstr);

    #
    #   Create a new table
    #
	#
	### Test 3
    Test($state or ($def = TableDefinition($table,
					   ["id",   SQL_INTEGER(),  0,  0, $NO_FLAG], # column name, DBI SQL code, size/precision, scale, flags
					   ["name", SQL_VARCHAR(),  64, 0, $NO_FLAG]),
		    $dbh->do($def)))
	or ErrMsgF("Cannot create table: Error %s.\n",
		   $dbh->errstr);

	#
	### Test 4
    Test($state or $dbh->{AutoCommit})
	or ErrMsg("AutoCommit is off\n");

    #
    #   Tests for databases that do support transactions
    #
    if (HaveTransactions()) {
	# Turn AutoCommit off
	$dbh->{AutoCommit} = 0;

	#
	### Test 5
	Test($state or (!$dbh->err && !$dbh->errstr && !$dbh->{AutoCommit}))
	    or ErrMsgF("Failed to turn AutoCommit off: err %s, errstr %s\n",
		       $dbh->err, $dbh->errstr);

	# Check rollback

	#
	### Test 6
	Test($state or $dbh->do("INSERT INTO $table VALUES (1, 'Thomas')"))
	    or ErrMsgF("Failed to insert value: err %s, errstr %s.\n",
		       $dbh->err, $dbh->errstr);
	my $msg;
	#
	### Test 7
	Test($state or !($msg = NumRows($dbh, $table, 1)))
	    or ErrMsg($msg);

	#
	### Test 8
	Test($state or $dbh->rollback)
	    or ErrMsgF("Failed to rollback: err %s, errstr %s.\n",
		       $dbh->err, $dbh->errstr);

	#
	### Test 9
	Test($state or !($msg = NumRows($dbh, $table, 0)))
	    or ErrMsg($msg);

	# Check commit
	#
	### Test 10
	Test($state or $dbh->do("DELETE FROM $table WHERE id = 1"))
	    or ErrMsgF("Failed to insert value: err %s, errstr %s.\n",
		       $dbh->err, $dbh->errstr);
	#
	### Test 11
	Test($state or !($msg = NumRows($dbh, $table, 0)))
	    or ErrMsg($msg);

	#
	### Test 12
	Test($state or $dbh->commit)
	    or ErrMsgF("Failed to rollback: err %s, errstr %s.\n",
		       $dbh->err, $dbh->errstr);

	#
	### Test 13
	Test($state or !($msg = NumRows($dbh, $table, 0)))
	    or ErrMsg($msg);

	# Check auto rollback after disconnect

	#
	### Test 14
	Test($state or $dbh->do("INSERT INTO $table VALUES (1, 'Thomas')"))
	    or ErrMsgF("Failed to insert: err %s, errstr %s.\n",
		       $dbh->err, $dbh->errstr);

	#
	### Test 15
	Test($state or !($msg = NumRows($dbh, $table, 1)))
	    or ErrMsg($msg);

	#
	### Test 16
	Test($state or $dbh->disconnect)
	    or ErrMsgF("Failed to disconnect: err %s, errstr %s.\n",
		       $dbh->err, $dbh->errstr);

	#
	### Test 17
	Test($state or ($dbh = DBI->connect($test_dsn, $test_user,
					    $test_password)))
	    or ErrMsgF("Failed to reconnect: err %s, errstr %s.\n",
		       $DBI::err, $DBI::errstr);

	#
	### Test 18
	Test($state or !($msg = NumRows($dbh, $table, 0)))
	    or ErrMsg($msg);

	# Check whether AutoCommit is on again

	#
	### Test 19
	Test($state or $dbh->{AutoCommit})
	    or ErrMsg("AutoCommit is off\n");

    #
    #   Tests for databases that don't support transactions => DtfSQLsupports transactions
    #
    } else {
	if (!$state) {
	    $@ = '';
	    eval { $dbh->{AutoCommit} = 0; }
	}

	#
	### Test 5
	Test($state or $@)
	    or ErrMsg("Expected fatal error for AutoCommit => 0\n");
		
    }# end if HaveTransactions
	
	

    #   Check whether AutoCommit mode works.
	#
	### Test 20 / 6
    Test($state or $dbh->do("INSERT INTO $table VALUES (1, 'Thomas')"))
	or ErrMsgF("Failed to delete: err %s, errstr %s.\n",
		   $dbh->err, $dbh->errstr);

	#
	### Test 21 / 7
    Test($state or !($msg = NumRows($dbh, $table, 1)))
	or ErrMsg($msg);

	#
	### Test 22 / 8
    Test($state or $dbh->disconnect)
	or ErrMsgF("Failed to disconnect: err %s, errstr %s.\n",
		   $dbh->err, $dbh->errstr);

	#
	### Test 23 / 9
    Test($state or ($dbh = DBI->connect($test_dsn, $test_user,
					$test_password)))
	or ErrMsgF("Failed to reconnect: err %s, errstr %s.\n",
		   $DBI::err, $DBI::errstr);

	#
	### Test 24 / 10
    Test($state or !($msg = NumRows($dbh, $table, 1)))
	or ErrMsg($msg);

    #   Check whether commit issues a warning in AutoCommit mode

	#
	### Test 25 / 11
    Test($state or $dbh->do("INSERT INTO $table VALUES (2, 'Tim')"))
	or ErrMsgF("Failed to insert: err %s, errstr %s.\n",
		   $dbh->err, $dbh->errstr);
    my $result;
    if (!$state) {
	$@ = '';
	$SIG{__WARN__} = \&CatchWarning;
	$gotWarning = 0;
	eval { $result = $dbh->commit; };
	$SIG{__WARN__} = 'DEFAULT';
    }

	#
	### Test 26 / 12 
    Test($state or $gotWarning)
	or ErrMsg("Missing warning when committing in AutoCommit mode");

    #   Check whether rollback issues a warning in AutoCommit mode
    #   We accept error messages as being legal, because the DBI
    #   requirement of just issueing a warning seems scary.

	#
	### Test 27 / 13
    Test($state or $dbh->do("INSERT INTO $table VALUES (3, 'Ally')"))
	or ErrMsgF("Failed to insert: err %s, errstr %s.\n",
		   $dbh->err, $dbh->errstr);
    if (!$state) {
	$@ = '';
	$SIG{__WARN__} = \&CatchWarning;
	$gotWarning = 0;
	eval { $result = $dbh->rollback; };
	$SIG{__WARN__} = 'DEFAULT';
    }

	#
	### Test 28 / 14
    Test($state or $gotWarning or $dbh->err)
	or ErrMsg("Missing warning when rolling back in AutoCommit mode");


    #
    #   Finally drop the test table.
    #
	#
	### Test 29 / 15
    Test($state or $dbh->do("DROP TABLE $table"))
	or ErrMsgF("Cannot DROP test table $table: %s.\n",
		   $dbh->errstr);
	#
	### Test 30 / 16
    Test($state or $dbh->disconnect())
	or ErrMsgF("Cannot DROP test table $table: %s.\n",
		   $dbh->errstr);
}
