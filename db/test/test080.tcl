# See the file LICENSE for redistribution information.
#
# Copyright (c) 2000-2003
#	Sleepycat Software.  All rights reserved.
#
# $Id: test080.tcl,v 1.2 2004/03/30 01:24:09 jtownsen Exp $
#
# TEST	test080
# TEST	Test of DB->remove()
proc test080 { method {tnum "080"} args } {
	source ./include.tcl

	set args [convert_args $method $args]
	set omethod [convert_method $method]

	puts "Test$tnum: Test of DB->remove()"

	# Determine full path
	set curdir [pwd]
	cd $testdir
	set fulldir [pwd]
	cd $curdir

	# Test both relative and absolute path
	set paths [list $fulldir $testdir]

	set encrypt 0
	set encargs ""
	set args [split_encargs $args encargs]

	# If we are using an env, then skip this test.
	# It needs its own.
	set eindex [lsearch -exact $args "-env"]
	if { $eindex != -1 } {
		incr eindex
		set e [lindex $args $eindex]
		puts "Skipping test080 for env $e"
		return
	}

	foreach path $paths {

		set dbfile test$tnum.db
		set testfile $path/$dbfile
		set eargs $encargs

		# Loop through test using the following remove options
		# 1. no environment, not in transaction
		# 2. with environment, not in transaction
		# 3. remove with auto-commit
		# 4. remove in committed transaction
		# 5. remove in aborted transaction

			foreach op "noenv env auto commit abort" {

			# Make sure we're starting with a clean slate.
			env_cleanup $testdir
			if { $op == "noenv" } {
				set dbfile $testfile
				set e NULL
				set envargs ""
			} else {
				if { $op == "env" } {
					set largs ""
				} else {
					set largs " -txn"
				}
				if { $encargs != "" } {
					set eargs " -encrypt "
				}
				set e [eval {berkdb_env -create -home $path} \
				    $encargs $largs]
				set envargs "-env $e"
				error_check_good env_open [is_valid_env $e] TRUE
			}

			puts "\tTest$tnum: dbremove with $op in $path"
			puts "\tTest$tnum.a.1: Create file"
			set db [eval {berkdb_open -create -mode 0644} \
			    $omethod $envargs $eargs $args {$dbfile}]
			error_check_good db_open [is_valid_db $db] TRUE

			# The nature of the key and data are unimportant;
			# use numeric key so record-based methods don't need
			# special treatment.
			set key 1
			set data [pad_data $method data]

			error_check_good dbput [$db put $key $data] 0
			error_check_good dbclose [$db close] 0
			error_check_good file_exists_before \
				    [file exists $testfile] 1

			# Use berkdb dbremove for non-transactional tests
			# and $env dbremove for transactional tests
			puts "\tTest$tnum.a.2: Remove file"
			if { $op == "noenv" || $op == "env" } {
				error_check_good remove_$op [eval \
				    {berkdb dbremove} $eargs $envargs $dbfile] 0
			} elseif { $op == "auto" } {
				error_check_good remove_$op \
				    [eval {$e dbremove} -auto_commit $dbfile] 0
			} else {
				# $op is "abort" or "commit"
				set txn [$e txn]
				error_check_good remove_$op \
				    [eval {$e dbremove} -txn $txn $dbfile] 0
				error_check_good txn_$op [$txn $op] 0
			}

			puts "\tTest$tnum.a.3: Check that file is gone"
			# File should now be gone, unless the op is an abort.
			if { $op != "abort" } {
				error_check_good exists_after \
				    [file exists $testfile] 0
			} else {
				error_check_good exists_after \
				    [file exists $testfile] 1
			}

			if { $e != "NULL" } {
				error_check_good env_close [$e close] 0
			}

			set dbfile test$tnum-old.db
			set testfile $path/$dbfile
		}
	}
}
