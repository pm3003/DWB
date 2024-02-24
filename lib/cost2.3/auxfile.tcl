#
# auxfile.tcl
# Maintain external "auxilliary" file, a la LaTeX.
# Used for "external two-pass" strategies.
# $Id: auxfile.tcl,v 1.3 1995/06/02 23:33:46 joe Exp $
# 

global auxfilename;
set auxfilename "cost.aux"
global curauxinfo; 			# aux info from this pass
global auxinfo;				# aux info from last pass

set curauxinfo(x) x; unset curauxinfo(x)
set auxinfo(x) x; unset auxinfo(x)

proc auxfilename {filename} {
    global auxfilename
    set auxfilename $filename
}

proc getauxinfo {class name} {
    global auxinfo curauxinfo
    set key "${class}.${name}"
    if [info exists curauxinfo($key)] {
	return $curauxinfo($key)
    } elseif {[info exists auxinfo($key)]} {
	return $auxinfo($key)
    } else {
	DEBUG auxinfo "$key not found"
	return ""
    }
}

proc setauxinfo {class name value} {
    global curauxinfo 
    set key "${class}.${name}"
    if [info exists curauxinfo($key)] {
	puts stderr "AUXINFO: redefined $key ($curauxinfo($key) / $value"
    }
    set curauxinfo($key) $value
}

# Execute this at startup (after defining 'auxfilename')
proc readauxfile {} {
    global auxfilename
    if [file exists $auxfilename] {
	uplevel #0 source $auxfilename
    } else {
	DEBUG auxinfo "$auxfilename not found"
    }
}

# Execute this at end :
proc writeauxfile {} {
    global auxfilename curauxinfo

    set fp [open $auxfilename w]
    foreach key [lsort [array names curauxinfo]] {
	puts $fp [list set "auxinfo($key)" $curauxinfo($key)]
    }
    close $fp
}
