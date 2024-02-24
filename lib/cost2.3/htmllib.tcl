#############################################################
# HTMLLIB -- HTML output utilities.
# $Id: htmllib.tcl,v 1.19 2002/04/30 17:48:10 joe Exp $
# $Date: 2002/04/30 17:48:10 $
#############################################################

package provide htmllib 0.7

namespace eval html {


variable outfp stdout

# Configuration options:
#
variable options ; array set options {
    doctype	"-//W3C//DTD HTML 4.0 Transitional//EN"
    verbose	1
    outputDir	"."
    stylesheet	""
}

variable metaInfo [list]		;# list of name/content pairs


# List of elements whose end-tags should be omitted:
# These are those with EMPTY declared content (BR, IMG, etc),
# and those with optional end-tags that are frequently
# accidentally terminated (P, LI, etc.)
#
variable HTMLOmitEnd;	# Array
foreach _omitEnd {
    BR AREA LINK IMG PARAM HR INPUT COL META
    FRAME ISINDEX BASE
    P DT DD LI
} {
    set HTMLOmitEnd($_omitEnd) 1
}

variable htmlStringMap {
    &	&amp;
    <	&lt;
    >	&gt;
    @	&#64;
}
variable attvalStringMap $htmlStringMap;
lappend attvalStringMap {'} {&sqot;} {"} {&quot;}

}

# html::configure option value ...
#	Sets configuration options.
#
proc html::configure {args} {
    variable options
    foreach {option value} $args {
	regsub -- {^-*} $option {} option
	if {![info exists options($option)]} {
	    set validopts [join [lsort [array names options]] ","]
	    return -code error \
	    	"Bad option $option:\nValid options are $validopts"
	}
	set options($option) $value
    }
}

# html::metaInfo name content --
#	Record data for <META> elements to be produced by html::writeHeader
#
proc html::metaInfo {name content} {
    variable metaInfo
    lappend metaInfo $name $content
}

# html::defaultAttributes gi attname attval ...
#	Specify default attribute values for specified element type.
#
#
proc html::defaultAttributes {gi args} {
    # %%% NYI
}

proc html::message {text} {
    variable options
    if {$options(verbose)} {
    	puts stderr "$text"
    }
}


# html::escape text --
# html::escapeAttval text --
#	Replace SGML delimiters in $text with entity references.
#
proc html::escape {text} {
    variable htmlStringMap
    return [string map $htmlStringMap $text]
}
proc html::escapeAttval {text} {
    variable attvalStringMap
    return [string map $attvalStringMap $text]
}

# html::write text --
#	Insert 'text' literally into the output stream
#
proc html::write {text} {
    variable outfp
    puts -nonewline $outfp $text
}

# html::text {cdata} --
#	Insert character data into the output stream
#	after escaping special characters
#
proc html::text {cdata} {
    html::write [html::escape $cdata]
}

# html::startTag gi [ attspecs ... ]
#
#  Emit a start-tag for element 'gi'.
#
#  'attspecs...' is a paired list of attribute-name/attribute-value pairs.
#
proc html::startTag {gi args} {
    html::write "<$gi"
    if {[llength $args] == 1} {
	set args [lindex $args 0]
    }
    if {[llength $args] % 2} {
    	return -code error "Odd number of attribute-value pairs: $gi $args"
    }
    foreach {attname attval} $args {
	if {$attname == $attval} {
	    # Handle HTML-style 'ATTNAME=ATTNAME' minimization:
	    html::write " $attname"
	} else {
	    html::write " $attname=\"[html::escapeAttval $attval]\""
	}
    }
    html::write "\n>"
}

# emptyElement --
#	Same as startTag.
#
proc html::emptyElement [info args html::startTag] [info body html::startTag]

# html::endTag gi
#
#	Emit an end-tag for element 'gi',
#	unless end-tag omission is specified for element type 'gi'.
#
proc html::endTag {gi} {
    variable HTMLOmitEnd
    if {![info exists HTMLOmitEnd([string toupper $gi])]} {
	html::write "</$gi>"
    }
}

# html::element  gi ?attname attval...? script
#
# 	Convenience function: Emit start tag, evaluate script,
#	then emit end tag.
#
proc html::element {gi args} {
    set script [lindex $args end]
    set atts [lrange $args 0 [expr [llength $args] - 2]]
    if {[llength $atts] == 1} { set atts [lindex $atts 0] }
    html::startTag $gi $atts
    uplevel 1 $script
    html::endTag $gi
}

# html::document filename body --
#	Creates new HTML document.
#
proc html::document {filename body} {
    variable options
    variable outfp
    set oldfp $outfp;
    html::createFile $filename
    html::beginDocument

    set rc [catch { uplevel 1 $body } result]
    set ei $::errorInfo; set ec $::errorCode

    html::endDocument
    close $outfp
    set outfp $oldfp
    return -code $rc -errorcode $ec -errorinfo $ei $result
}

############################################################
#
# File management routines:
#
# html::createFile filename --
#	Creates new file in output directory, and diverts 
#	subsequent output to that file.
#
proc html::createFile {filename} {
    variable options
    variable outfp
    set filename [file join $options(outputDir) $filename]
    html::message "Writing $filename..."
    set outfp [open $filename "w"]
    fconfigure $outfp -buffering full
}

#
# html::beginDocument [options...]
#
#	Start an HTML document:	<!DOCTYPE ...> declaration and HTML start-tag
#
proc html::beginDocument {args} {
    variable options

    html::write "<!DOCTYPE HTML PUBLIC \"$options(doctype)\">\n"
    html::write "<!-- This file was automatically generated -->\n"
    html::startTag HTML
}

proc html::endDocument {} {
    html::endTag HTML
    html::write "\n"
}

# Header information:
#
proc html::writeHeader {} {
    variable options
    variable metaInfo
    foreach {name content} $metaInfo {
	html::startTag META NAME $name CONTENT $content
    }
    if {[string length $options(stylesheet)]} {
	html::startTag LINK REL STYLESHEET TYPE "text/css" \
	    HREF $options(stylesheet)
    }
}

#*EOF*
