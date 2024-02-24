#
# Core.tcl
# Core Cost utilities
#
# $Revision: 1.16 $
#

namespace eval cost { }

### Debugging and warning message handling:

proc DEBUG {key msg} {}

proc cost::message {msg} {
    puts stderr $msg
}

proc cost::warning {msg} {
    set context [list]
    catch {
	foreachNode rootpath el {
	    # Build context string:
	    if {[query? hasatt "id"]} {
		set ctx "id=[query attval id]"
	    } elseif {[query? hasatt "name"]} {
		set ctx "name=[query attval name]"
	    } else {
		set ctx [childNumber]
	    }
	    lappend context "[query gi]($ctx)"
	}
    }
    puts stderr "Warning: $msg\n\t[join $context /]"
}

proc cost::undefined {class value} {
    variable CostUndefined
    if {![info exists CostUndefined($class.$value)]} {
	set CostUndefined($class.$value) 1
	cost::warning "Undefined $class '$value'"
    }
}

### Convenience functions for reading SGMLS output

# load SGMLS output from file
proc loadfile {filename} {
    set fp [open $filename r]
    set handle [loadsgmls $fp]
    close $fp
    return $handle
}

# invoke nsgmls as a subprocess
#
proc loaddoc {filename} {
    global COST
    set fp [open "|$COST(PARSER) $COST(SGMLDECL) $filename" r]
    set handle [loadsgmls $fp]
    if {[catch {close $fp} errorOutput]} {
	puts stderr $errorOutput
    }
    return $handle
}

# load XML document: 
#
proc loadxmldoc {filename} {
    set fp [open $filename r]
    set handle [loadxml $fp]
    close $fp
    return $handle
}

proc identity x { return $x }

### List processing utilities:

# luniq: remove duplicate entries from a list
proc luniq {l} {
    set l [lsort $l]
    set lastel [lindex $l 0]
    set result [list $lastel]
    foreach el $l {
	if {$el != $lastel} {
	    lappend result $el
	    set lastel $el
	}
    }
    return $result
}

# lreverse: reverse a list
proc lreverse {l} {
    set result ""
    set i [expr [llength $l]-1 ]
    while {$i >= 0} {
	lappend result [lindex $l $i]
	incr i -1
    }
    return $result
}

# shift: remove element from head of list
proc shift {varname} {
    upvar $varname l
    set head [lindex $l 0]
    set l [lrange $l 1 end]
    return $head
}


### Extra SGML utilities:

# From DSSSL:
# "The _child number_  of an element is the number of
# element siblings of the current element that are before or 
# equal to the current element and that have the same
# generic identifier as the current element." 
# Useful for constructing section numbers, etc.
#
proc childNumber {} {
    return [expr 1 + [query# prev el withGI [query gi]]]
}

proc elementNumber {} {
    return [expr 1 + [query# backward el withGI [query gi]]]
}

# hierarchyNumbers gi: 
# rough equivalent of DSSSL "hierarchical-number-recursive";
# returns a list of the child numbers of each ancestor
# with generic identifier 'gi'
#
proc hierarchyNumbers {gi} {
    set hn {}
    foreachNode rootpath el withGI $gi {
	lappend hn [childNumber]
    }
    return $hn
}


### Source file management:
### 'cost::require $filename' looks in the Cost search path 
### for the specified file and loads it as a Tcl script.
### 
### 'cost::findFile $filename' looks in the search path
### and returns the full pathname, if found;
### 'cost::openFile $filename' does the same, but opens the file
### for reading and returns the new handle.

proc cost::require {filename} {
    global COST_LOADED_FILES COST
    if {[info exists COST_LOADED_FILES($filename)]} { return }
    foreach dir [concat {{}} $COST(searchPath)] {
	set fullpath [file join $dir $filename]
	if {[file exists $fullpath]} {
	    uplevel #0 [list source $fullpath]
	    set COST_LOADED_FILES($filename) $fullpath
	    return;
	}
    }
    error "cost::require: Can't find $filename"
}

proc cost::findFile {filename} {
    global COST
    set searchPath .
    if {[info exists COST(INPUTFILE)]} {
    	lappend searchPath [file dirname $COST(INPUTFILE)]
    }
    foreach dir [concat $searchPath $COST(searchPath)] {
	if {[file exists [set fullpath [file join $dir $filename]]]} {
	    return $fullpath
	 }
    }
    error "cost::findFile: Can't find $filename"
}

proc cost::extendPath {pathname} {
    global COST
    if {[lsearch $COST(searchPath) $pathname] < 0} {
    	lappend COST(searchPath) $pathname
    }
}

proc cost::openFile {filename} {
    return [open [cost::findFile $filename] r]
}

#
# cost::provenance --
# cost::provenanceString --
#	Useful debugging string to insert into generated output files.
#
proc cost::provenanceString {} {
	return [join [cost::provenance] " "]
}

proc cost::provenance {} {
    return [list \
	by 	$::tcl_platform(user) \
	at	[clock format [clock seconds] -format {%d %b %Y}] \
	in	[pwd] \
	on	[info hostname] \
	with	"$::argv0 $::argv" \
	using	[join [list \
		    Tcl  $::tcl_patchLevel \
		    Cost $::COST(VERSION) \
		] ] \
    ]
}

# Unnamespaced aliases for backwards-compatibility:
#
interp alias {} require {} cost::require
interp alias {} warning {} cost::warning
interp alias {} cost:require {} cost::require
interp alias {} cost:findFile {} cost::findFile
interp alias {} cost:openFile {} cost::openFile
interp alias {} cost:undefined {} cost::undefined
interp alias {} cost:warning {} cost::warning

#*EOF*
