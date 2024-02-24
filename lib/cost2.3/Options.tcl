#
# $Id: Options.tcl,v 1.4 2000/09/26 19:36:48 joe Exp $
#
# Command-line option processing for Cost
#
# Usage:
#
# In main script and subpackages:
#
#	cost::declareOption option [ -variable varname ] [ -command cmd ]
#		[ ... etc ]
#
#	 'option' should not include any leading hyphens.
#
# In setup phase:
#
#	cost::configure option value [ option value ... ]
#
# Before main processing phase:
#
#	cost::executeOptions
#
# NOTES:
#	cost::main calls cost::configure for each of the command-line options.
#	cost::configure only records which options have been specified;
#	actual execution of the options (setting variables & calling
#	commands) is done by cost::executeOptions, after all packages
#	have been loaded.  This way options can be specified before
#	they are declared.
#

namespace eval cost {
    variable COSTOPTIONS
    variable COSTCONFIG
    set COSTOPTIONS(options) [list]
}

proc cost::declareOption {option args} {
    variable COSTOPTIONS
    if {[lsearch $COSTOPTIONS(options) $option] != -1} {
    	return -code error "Option $option already declared"
    }

    lappend COSTOPTIONS(options) $option
    array set COSTOPTIONS [list \
    	"$option.variable" "::COST::COSTOPTIONS($option.value)" \
	"$option.command" {} \
    ]

    set COSTOPIONS($option.variable) ::COST::COSTOPTIONS($option.value)
    foreach {arg val} $args {
	switch -- $arg {
	    -variable 	{ set COSTOPTIONS($option.variable) $val }
	    -command 	{ set COSTOPTIONS($option.command) $val }
	    default 	{ return -code error "Bad option $option" }
	}
    }
}

proc cost::configure {args} {
    variable COSTCONFIG
    foreach {option value} $args {
	 regsub {^-*} $option {} option
	 set COSTCONFIG($option) $value
    }
}

proc cost::executeOptions {} {
    variable COSTOPTIONS
    variable COSTCONFIG
    set commands [list]
    foreach option $COSTOPTIONS(options) {
    	if {![info exists COSTCONFIG($option)]} {
	    continue;
	}
	set value $COSTCONFIG($option)
	uplevel #0 [list set $COSTOPTIONS($option.variable) $value]
	lappend commands $COSTOPTIONS($option.command)
	unset COSTCONFIG($option)
    }
    foreach {option value} [array get COSTCONFIG] {
	warning "Undeclared option $option"
    }
    foreach command $commands {
	uplevel #0 $command
    }
}

# cost::processPIs --
# 	Process any <?cost ...> PIs found in the document:
#	<?cost(.specFile)
#
proc cost::processPIs {{specFile {}}} {
    set optvals [list]
    foreachNode doctree pi {
	if {[regexp -- {^cost(\.[^ ]*)? (.*)$} [q content] _ spec pival]} {
	    if {    [string length $spec] 
		 && [string compare [string range $spec 1 end] \
				    [file tail [file root $specFile]]] 
	    } {
		# PI for a different specification
		# %%% this isn't right...
		continue;
	    }
	    while {[regexp -- \
			{^([-_a-zA-Z0-9]*)='([^']*)'(.*)$} \
			[string trim $pival] _ option value rest]
		||  [regexp -- \
			{^([-_a-zA-Z0-9]*)="([^\"]*)"(.*)$} \
			[string trim $pival] _ option value rest]
	    } {
		    lappend optvals $option $value
		    set pival $rest
	    }
	    if {[string length [string trim $pival]]} {
		warning "Unrecognized Cost PI: $pival"
	    }
	}
    }
    foreach {option value} $optvals {
	cost::configure $option $value
    }
}

#*EOF*
