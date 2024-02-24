#
# costinit.tcl
# Initialization file for Cost 2
# $Revision: 1.26 $
#

global COST COSTLIB env
namespace eval cost { }

if {![info exists COST] || $COST(MAJOR) != 2 || $COST(MINOR) != 3} {
    set errmsg "Warning: Cost version mismatch: expected Cost 2.3"
    if {[info exists COST]} { append errmsg ", got $COST(VERSION)" }
    puts stderr $errmsg
}

set COSTLIB [file dirname [info script]]

# Set up search path for 'require' command
#
global COST(searchPath)
if {[info exists env(COSTPATH)]} {
    set COST(searchPath) [split $env(COSTPATH) ":"]
}
lappend COST(searchPath) $COSTLIB

# Set default Cost parameters:
#
set COST(mainProcedure) main
foreach {param envar default} {
    PARSER	COST_PARSER		nsgmls
    SGMLDECL	SGML_DECLARATION	""
} {
    if {[info exists env($envar)]} {
	set COST($param) $env($envar)
    } else {
	set COST($param) $default
    }
}

# Load core utilities:
#
source $COSTLIB/Core.tcl
source $COSTLIB/Options.tcl
set dir $COSTLIB
package ifneeded Cost-HTML 0.7	[list source [file join $dir HTML.spec]]
package ifneeded RATFINK 1.0	[list source [file join $dir RTF.spec]]
package ifneeded Cost-Simple 1.0 [list source [file join $dir Simple.tcl]]
package ifneeded Cost-Latex 0.2	[list source [file join $dir latex.tcl]]
package ifneeded Cost-Numerals 1.1 [list source [file join $dir Numerals.tcl]]

### costsh-specific commandline processing:
#
# 'cost::commandLine' is called from Tcl_AppInit() in costsh,
# after initializing the package; it may also be called from
# top-level user specifications:
#
#	if {![string compare [info script] $::argv0]} { cost::commandLine }
# or:
#	cost::specificationMain ?main-routine?
#
# (If main-routine is specified, it overrides the default [main] procedure)
#
proc cost::commandLine {} {
    global COST
    global argv

    set filter 0
    if {![string compare [lindex $argv 0] "-S"]} {
    	# Backwards-compatibility:
	if {[llength $argv] < 2} {
	    return -code error "Missing required argument to -S flag"
	}
	set filter 1
	set specFile [lindex $argv 1]
	set argv [lrange $argv 2 end]
    } else {
	foreach arg $argv {
	    if {[regexp -- {--(.*)=(.*)} $arg _ option value]} {
		switch -glob -- $option {
		    input	{ set inputFile $value }
		    spec	{ set specFile $value }
		    format	{ set inputFormat $value }
		    sgmldecl	{ set COST(SGMLDECL) $value }
		    *		{ cost::configure $option $value }
		}
	    } elseif {[string match "--no-*" $arg]} {
	    	cost::configure [string range $arg 5 end] 0
	    } elseif {[string match "--*" $arg]} {
		cost::configure [string range $arg 2 end] 1
	    } else {
	    	set inputFile $arg
	    }
	}
    }

    #
    # Load input file:
    #
    if {$filter} {
	loadsgmls stdin
	set COST(INPUTFILE) -
    } elseif {[info exists inputFile]} {
	if {![info exists inputFormat]} {
	    switch -- [string tolower [file extension $inputFile]] {
	    	.xml	{ set inputFormat xml  }
		default	{ set inputFormat sgml }
	    }
	}
	switch  -- [string tolower $inputFormat] {
	    sgml 	{ loaddoc  $inputFile }
	    esis 	{ loadfile $inputFile }
	    xml  	{ loadxmldoc $inputFile }
	    default {
		return -code error "Unrecognized input format $inputFormat"
	    }
	}
	set COST(INPUTFILE) $inputFile
    }
    if {[info exists specFile]} {
	cost:require $specFile
    }

    # Process any options found in PIs in the input document:
    if {[info exists COST(INPUTFILE)]} {
	if {[info exists specFile]} {
	    cost::processPIs $specFile
	} else {
	    cost::processPIs
	}
    } 

    cost::executeOptions

    namespace eval :: {
	if { [llength [info procs $COST(mainProcedure)]] } {
	    set ::tcl_interactive 0
	    cost::EnsureInputFile
	    $COST(mainProcedure)
	    exit
	}
    }
}

proc cost::EnsureInputFile {} {
    global COST
    variable COSTOPTIONS
    if {![info exists COST(INPUTFILE)]} {
	variable COSTOPTIONS
	puts stderr "$::argv0: No input document specified"
	puts stderr "Avaliable options: [join $COSTOPTIONS(options) ", "]"
	exit 1
    }
}

# Can be called at the end of top-level specification files:
#
proc cost::specificationMain {{mainProcedure main}} {
    global COST
    if {![string compare $::argv0 [info script]]} { 
	set COST(mainProcedure) $mainProcedure
    	cost::commandLine 
    }
}

# Alias for backwards-compatibility:
proc cost_commandline \
    [info args cost::commandLine] [info body cost::commandLine]

#*EOF*
