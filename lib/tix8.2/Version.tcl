# Version.tcl --
#
#	[Obsolete] Use the tix_version and tix_patchLevel variables
#       instead.
#
# Copyright (c) 1993-1999 Ioi Kim Lam.
# Copyright (c) 2000-2001 Tix Project Group.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# $Id: Version.tcl,v 1.4 2000/12/29 02:10:46 ioilam Exp $

proc tixScriptVersion {} {
    global tix_version
    return $tix_version
}
proc tixScriptPatchLevel {} {
    global tix_patchLevel
    return $tix_patchLevel
}