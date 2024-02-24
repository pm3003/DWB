#
#	$Id: Verify.tcl,v 1.2 2000/10/13 14:48:43 idiscovery Exp $
#
# Verify.tcl --
#
#	Config option verification routines.
#
# Copyright (c) 1996, Expert Interface Technologies
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

proc tixVerifyBoolean {val} {
    return [tixGetBoolean $val]
}

proc tixVerifyDirectory {val} {
    if {![file isdir $val]} {
	error "\"$val\" is not a directory"
    }
    return $val
}

