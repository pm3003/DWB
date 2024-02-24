#############################################################
# HTMLLIB
# A library of SGML-to-HTML conversion utilities for Cost
#
# NOTE: Work in progress, I don't recommend using this just yet...
#
# $Id: HTML.spec,v 1.3 2002/04/30 17:48:10 joe Exp $
# $Date: 2002/04/30 17:48:10 $
#############################################################

package require Cost
cost:require htmllib.tcl
package provide Cost-HTML 0.7

############################################################
#
# High-level utilities:
#
# %%% Describe this...
# %%% which specs are used, which props are set.
# %%% allow configuration options (?)
# %%% Check: make sure that if HTMLNode is specified, html == #NODE*
# %%% Check: in processNode, vice versa.
#

namespace eval html {

# Extra options for SGML-to-HTML conversion:

array set options {
    filePrefix		"node"
    fileExtension	".html"
    sourceSpec		NoSourceSpec
    verbose		1
    headScript		{}
}

# SDATA entities: (@@ quick hack)
#
variable html_SDATAMap
array set html_SDATAMap {
    [copy]	&copy;
}

}

cost::declareOption outputdir  -variable ::html::options(outputDir) 
cost::declareOption stylesheet -variable ::html::options(stylesheet) -command {
    if {    [string length $::html::options(stylesheet)]
    	 && [string length $::html::options(outputDir)]
	 && ![file exists [set stylesheetDst \
	 	[file join $::html::options(outputDir) $::html::options(stylesheet)]]]
    } {
	if {[catch {
	    set stylesheetSrc [cost:findFile $::html::options(stylesheet)]
	} result]} {
	    warning $result
	} else {
	    html::message "Writing $stylesheetDst"
	    file copy $stylesheetSrc $stylesheetDst
	}
    }
}
cost::declareOption output \
    -variable ::html::options(output)  \
    -command { html::createFile $::html::options(output) }


proc html::preprocess {} {
    variable options
    set spec 	$options(sourceSpec)
    set prefix 	$options(filePrefix)
    set ext 	$options(fileExtension)
    set counter	0
    foreachNode doctree el {
	set nodeName   [subst [$spec get nodeName   #IMPLIED]]
	set anchorName [subst [$spec get anchorName #IMPLIED]]
	switch -- $nodeName {
	    #IMPLIED	{ }
	    #AUTO       { setprop HTMLNode \
	    			"$prefix[format %03d [incr counter]]$ext" }
	    default	{ setprop HTMLNode "${nodeName}$ext" }
	}
	switch -- $anchorName {
	    #IMPLIED	{ }
	    #AUTO	{ setprop HTMLAnchor \
	    			"[q gi][format %04d [elementNumber]]" }
	    default	{ setprop HTMLAnchor $anchorName }
	}
    }
}

proc html::sdata {sdata} {
    variable html_SDATAMap
    if {[info exists html_SDATAMap($sdata)]} {
    	html::write $html_SDATAMap($sdata)
    } else {
	cost:undefined SDATA $sdata
	html::element SPAN class sdata { html::text $sdata }
    }
}

############################################################
#
# Cross-reference management:
#
# html::hrefpos [query ... ]
#	Returns a (relative) URL which will link to node specified
#	by 'query...', or to the current node if 'query' is omitted.
#
#	If the node isn't directly addressable in the HTML output,
#	returns a link to the nearest ancestor which is.
#
# %%% Also need: convenient way to generate <A NAME="..."> elements
# %%% at appropriate places.
#
proc html::hrefpos {args} {
    set anchor ""
    set node ""
    withNode ! {
	if {![eval selectNode $args]} {
	    warning "query $args failed"
	    return ""
	}
	foreachNode ancestor {
	    if {[query? hasprop HTMLAnchor] && $anchor == ""} {
		set anchor [query propval HTMLAnchor]
	    }
	    if {[query? hasprop HTMLNode]} {
		set node [query propval HTMLNode]
		break;
	    }
	}
	if {[string length $anchor]} {
	    return "$node#$anchor"
	} elseif {[string length $node]} {
	    return $node
	} ;# else
	warning \
 	 "Cannot find HTML locator for node [q gi].[elementNumber]"
    }
    return ""
}

#
# html::anchorName --
#	%%% Describe
#
proc html::anchorName {} {
    return [query ancestor propval HTMLAnchor]
}

############################################################
#
# SGML-to-HTML conversion.
#
# html::processNode --
#	Process the current source node, depending on
#	options specified in current sourceSpec.
#
# %%% TODO: allow configuration options on processNode, processChildren
#
proc html::processNode {} {
    variable options
    switch -- [query nodetype] {
	EL	{ #see below }
	CDATA	{ html::text [query content]; return }
	SDATA	{ html::sdata [query content]; return }
	RE	{ html::write "\n" ; return; }
	PEL	-
	SD	{ foreachNode child html::processNode ; return }
	PI	{ return; # no-op }
	DATAENT -
	ENTREF  -
	default	{ cost:undefined NODETYPE [query nodetype]; return }
    }

    # Processing for EL nodes:
    #
    set spec $options(sourceSpec)
    uplevel #0 $spec do startAction
    set result [subst [$spec get html #UNDEFINED]]
    set gi [lindex $result 0]
    set atts [lrange $result 1 end]
    switch $gi {
    	#IGNORE		{ # no-op }
	#NODE		{ error "NYI" }
	#TEMPLATE	{ error "NYI" }
	#UNDEFINED	{ cost:undefined GI [query gi];
			  html::processChildren }
	#IMPLIED 	-
	default		{
	    set implied [string match "#IMPLIED*" $result]
	    if {!$implied} { 
		set atts [concat $atts [subst [$spec get attributes {}]]]
	    	html::startTag $gi $atts 
	    }
	    html::write [subst [$spec get prefix ""]]
	    uplevel #0 [list $spec do content {
		foreachNode child html::processNode
	    }]
	    html::write [subst [$spec get suffix ""]]
	    if {!$implied} { html::endTag $gi }
	}
    }
    uplevel #0 $spec do endAction
    return;
}

proc html::processChildren {} {
    foreachNode child html::processNode
}

############################################################
#
# Default main routine:
#

html::metaInfo Creator "Cost $::COST(VERSION)"

proc html::main {args} {
    variable options
    if {![string compare $options(sourceSpec) "NoSourceSpec"]} {
    	return -code error \
	    "No source specification.  Use html::configure -sourceSpec ..."
    }
    html::preprocess
    html::beginDocument
    html::element HEAD {
	html::writeHeader
	uplevel #0 $options(headScript) 
    }
    withNode docroot html::processNode
    html::endDocument
}

proc main {args} { html::main }

#*EOF*
