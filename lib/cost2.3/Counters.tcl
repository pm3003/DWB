############################################################
# $Id: Counters.tcl,v 1.2 1999/07/09 16:53:22 jenglish Exp $
# Created: 2 Feb 1999
# Updated: 5 Jul 1999
############################################################
#
# Utilities for counters and section numbering.
#
# Usage:
#	ctr:defineCounter name [options...]
#	ctr:setCounter name value
#	ctr:stepCounter name
#	ctr:counterValue name
#	ctr:useCounter name
#
# TODO: Allow secnumdepth controls, secnumheight controls.
# TODO: Document this...
# Need: counter:configureCounter
# Need: specify different formats for different recursive levels
# TODO: %%% Decide what to do if -parent counter is recursive
#

require Numerals.tcl

global __costPriv_Counter

# ctr:defineCounter name 
#	[ -value initialval  -format [arabic | [ul]croman | [ul]calpha | ...]
#	  [ [-parent countername | -recursive 1] -separator string ] ]
#
# Defines a new counter named 'name'.
#
# The -format argument can actually be any Tcl command.  
#
# If -parent is specified, then ctr:formatCounter will
# prepend the parent counter's current value, followed
# by the -separator string, to the value of the new counter.
# In addition, the counter will be reset whenever the parent 
# counter is incremented or reset.
#
# If -recursive is set to 1, defines a multi-level counter.
# Use ctr:increaseLevel and ctr:decreaseLevel to change levels.
#
proc ctr:defineCounter {ctr args} {
    upvar #0 __costPriv_Counter Counter
    array set defaults {
	format 		arabic
	value   	0
	parent		{}
	recursive 	0
	separator 	"."
    }
    foreach {option value} $args {
	regsub {^-*} $option {} opt;	# trim leading "-"
	if {![info exists defaults($opt)]} {
	    error "Bad option $opt: legal values are [array names defaults]"
	}
	set defaults($opt) $value
    }

    # More settings defaults that shouldn't be specified by user:
    #
    array set defaults {
	children	{}
	level		0
    }

    foreach {k v} [array get defaults] { set Counter($ctr.$k) $v }
    if {$defaults(recursive)} {
	set Counter($ctr.level) 1
	set defaults(recursive) 0
	set Counter($ctr.defaults) [array get defaults]
	set ctr "${ctr}1"
	foreach {k v} [array get defaults] {
	    set Counter($ctr.$k) $v
	}
    }
    set parent $defaults(parent)
    if {$parent != ""} {
	if {![info exists Counter($parent.value)]} {
	    error "Parent counter $parent not defined"
	}
	lappend Counter($parent.children) $ctr
    }
}

# ctr:stepCounter ctr
#	Increments counter value by one.
#
proc ctr:stepCounter {ctr} {
    upvar #0 __costPriv_Counter Counter
    if {$Counter($ctr.recursive)} { set ctr "$ctr$Counter($ctr.level)" }
    foreach child $Counter($ctr.children) {
	ctr:resetCounter $child
    }
    incr Counter($ctr.value)
}

# ctr:resetCounter ctr --
#	Resets counter to zero.
#
proc ctr:resetCounter {ctr} {
    upvar #0 __costPriv_Counter Counter
    if {$Counter($ctr.recursive)} { set ctr "$ctr$Counter($ctr.level)" }
    foreach child $Counter($ctr.children) {
	ctr:resetCounter $child
    }
    set Counter($ctr.value) 0
}

# ctr:formatCounter ctr --
#	Returns formatted value of counter,
#	based on format, parent counter value and separator.
#
proc ctr:formatCounter {ctr} {
    upvar #0 __costPriv_Counter Counter
    if {$Counter($ctr.recursive)} {
	set ctr "$ctr$Counter($ctr.level)"
    }
    set value [$Counter($ctr.format) $Counter($ctr.value)]
    set parent $Counter($ctr.parent)
    while {$parent != {}} {
	set value [join [list \
		    [$Counter($parent.format) $Counter($parent.value)] \
		    $Counter($ctr.separator) \
		    $value ] "" ]
	set ctr $parent
	set parent $Counter($ctr.parent)
    }
    return $value
}

# ctr:useCounter ctr --
#	Steps the counter, returns new formatted value.
#
proc ctr:useCounter {ctr} {
    ctr:stepCounter $ctr
    return [ctr:formatCounter $ctr]
}

# Routines for recursive counters:
#
# ctr:increaseLevel ctr	-- 	move down a level (e.g., 1.1 --> 1.1.1)
# ctr:decreaseLevel ctr	--	move up a level (1.1.1 --> 1.1)
# ctr:currentLevel ctr	--	current level; 0 for nonrecursive counters
# 
proc ctr:currentLevel {ctr} {
    upvar #0 __costPriv_Counter Counter
    return $Counter($ctr.level)
}

proc ctr:increaseLevel {ctr} {
    upvar #0 __costPriv_Counter Counter
    if {!$Counter($ctr.recursive)} {
	error "Counter $ctr not recursive"
    }
    set oldlevel $Counter($ctr.level)
    set newlevel [incr Counter($ctr.level)]
    if {![info exists Counter($ctr$newlevel.value)]} {
	foreach {k v} $Counter($ctr.defaults) {
	    set Counter($ctr$newlevel.$k) $v
	}
	set Counter($ctr$newlevel.parent) $ctr$oldlevel
	lappend Counter($ctr$oldlevel.children) $ctr$newlevel
    }
}

proc ctr:decreaseLevel {ctr} {
    upvar #0 __costPriv_Counter Counter
    incr Counter($ctr.level) -1
}

#
# SGML preprocessing:
#
# processCounters <spec> --
#
#	<spec> is a Cost specification.  Sets the 'refnumber'
#	property to the current value of the counter specified
#	by the 'useCounter' parameter in <spec>.
#
# Example:
#	ctr:defineCounter section -recursive 1
#	ctr:defineCounter appendix -format ucalpha
#	specification foo {
#	    {element SECT}	{ useCounter section }
#	    {element APPENDIX}	{ useCounter appendix }
#	}
#	ctr:processCounters foo
#	foreachNode doctree element SECT { puts [query propval refnumber]] }
#
proc ctr:processCounters {spec} {
    upvar #0 __costPriv_Counter Counter
    process ctr:CounterHandler
}

eventHandler ctr:CounterHandler {
    START {
	if {[$spec has useCounter]} {
	    set counter [$spec get useCounter]
	    setprop refnumber [ctr:useCounter $counter]
	    if {$Counter($counter.recursive)} {
		ctr:increaseLevel $counter
	    }
	}
    }
    END {
	set counter [$spec get useCounter -]
	if {$counter != "-" && $Counter($counter.recursive)} {
	    ctr:decreaseLevel $counter
	}
    }
}

#*EOF*
