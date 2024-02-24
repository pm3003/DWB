#
# textutil.tcl
# March 1995
# Simple text-formatting utilities
# 

proc repeatstr {str n} {
	set result "";
	while {$n > 0} {
		append result $str;
		incr n -1
	}
	return $result
}

### Line-oriented procedures:

# replace tabs with spaces.
proc detabline {line {tabstop 8}} {
    if {[string first "\t" $line] == -1} {return $line} 
    set spaces 0
    set result ""
    set col 0
    foreach chunk [split $line "\t"] {
	append result [repeatstr { } $spaces]
	append result $chunk
	incr col $spaces
	incr col [string length $chunk]
	set spaces [expr $tabstop - $col % $tabstop]
    }
    return $result
}

# padline line len
# pad 'line' with blanks on the right until it is 'len' chars long
proc padline {line {linelen 70}} {
	set line [string trimright $line]
	set l [string length $line] 
	while {$l < $linelen} {
		incr l
		append line " "
	}
	return $line
}

# rjustline, centerline
# right-justify and center a line
proc rjustline {line {linelen 70}} {
    return "[repeatstr { } [expr $linelen - [string length $line]]]$line"
}

proc centerline {line {linelen 70}} {
    return "[repeatstr { } [expr ($linelen - [string length $line])/2]]$line"
}

# make a three-part line with left, center, and right parts
# (useful for headers, footers)
#
proc threepart {lft mid rgt {linelen 70}} {
    set space [expr ($linelen - [string length $mid])]
    set lpad [expr $space/2 - [string length $lft]]
    set rpad [expr $space/2 - [string length $rgt]]
    if {$space % 2 == 1} { incr rpad }
    return "${lft}[repeatstr { } $lpad]${mid}[repeatstr { } $rpad]${rgt}"
}

### Line list routines:

proc maxwidth {lines} {
	set width 0
	foreach line $lines {
		if {[string length $line] > $width} {
			set width [string length $line]
		}
	}
	return $width
}

proc rjust {lines {linelen 70}} {
    set result ""
    foreach line $lines {
	set line [string trim $line]
	lappend result \
	    "[repeatstr { } [expr $linelen - [string length $line]]]$line"
    }
    return $result
}
proc ljust {lines {linelen 70}} {
    set result ""
    foreach line $lines {
	set line [string trim $line]
	lappend result [padline $line $linelen]
    }
    return $result
}
proc center {lines {linelen 70}} {
    set result ""
    foreach line $lines {
	set line [string trim $line]
	lappend result [centerline $line $linelen]
    }
    return $result
}
proc indent {lines indent} {
    set result {}
    set spc [repeatstr { } $indent]
    foreach line $lines {
	lappend result "$spc[string trimright $line]"
    }
    return $result
}

proc adjoin {lines1 lines2 {sep { }}} {
    set result "" ;
    set len1 [string length [lindex $lines1 0]]
    set len2 [string length [lindex $lines2 0]]
    if {[llength $lines1] <= [llength $lines2]} {
	foreach line $lines1 {
	    lappend result "${line}${sep}[lindex $lines2 0]"
	    set lines2 [lreplace $lines2 0 0]
	}
	set sep "[repeatstr { } $len1]${sep}"
	foreach line $lines2 {
	    lappend result "${sep}${line}"
	}
    } else {
	foreach line $lines2 {
	    lappend result "[lindex $lines1 0]$sep$line"
	    set lines1 [lreplace $lines1 0 0]
	}
	set sep "$sep[repeatstr { } $len2]"
	foreach line $lines1 {
	    lappend result "$line$sep"
	}
    }
    return $result
}

proc underscore {lines {score =}} {
    lappend lines [repeatstr $score [maxwidth $lines]]
    return $lines
}

proc boxlines {lines {width 0}} {
	set margin 1;
	set result "";
	set lm "|[repeatstr " " $margin]"
	set rm "[repeatstr " " $margin]|"
	if {$width == 0} { set width [maxwidth $lines] }
	set vline ".[repeatstr - [expr $margin + $margin + $width]]."
	lappend result $vline;
	foreach line $lines {
		lappend result "$lm[padline $line $width]$rm"
	}
	lappend result $vline
	return $result
}

proc upcase {lines} { return [string toupper $lines] }
proc downcase {lines} { return [string tolower $lines] }

proc putlines {lines {fp stdout}} {
    foreach line $lines { puts $fp $line }
    return ""
}

proc wordwrap {words {linelen 70}} {
	set lines {}
	set curlen 0
	set curline ""

	foreach word $words {
	    if [set wordlen [string length $word]] {
		if {[incr curlen $wordlen] > $linelen} {
		    lappend lines [string trimright $curline]
		    set curline ""
		    set curlen $wordlen
		}
		append curline "$word "
		incr curlen;	# account for final space
	    }
	}
	if {$curline != ""} {
	    lappend lines [string trimright $curline]
	}
	return $lines
}

