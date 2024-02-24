#############################################################
# RTF.spec 
# SGML-to-RTF translation specification for Cost
# $Id: RTF.spec,v 1.16 2002/05/11 03:02:28 joe Exp $
# $Date: 2002/05/11 03:02:28 $
#############################################################
#
# Copyright (C) 1996 Joe English
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted.
#
# THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#############################################################
# RATFINK lives at <URL:http://www.flightlab.com/cost/ratfink/>
#############################################################

package require Cost

cost::require rtflib.tcl
package provide RATFINK 1.0

# Reroute RATFINK warnings to Cost warnings:

interp alias {} rtf::warning {} cost::warning

global rtfSpec ; set rtfSpec "rtfSpec"

proc identity {text} { return $text }
proc rtf::nullFilter {text} { return "" }

cost::declareOption output -variable RATFINK(output) -command {
    puts stderr "OUTPUT: $RATFINK(output)"
    rtf::configure -outputFile  	$RATFINK(output)
    rtf::configure -contentsFile	"[file root $RATFINK(output)].cnt"
}

environment rtfEnv {
    sdataFilter identity
    cdataFilter identity
    RE	"" 
    currentStyle default
}
proc rtf::convert {specname} {
    global rtfSpec
    set oldSpec $rtfSpec
    set rtfSpec $specname
    rtfConvert
    set rtfSpec $oldSpec
}

proc rtf::currentParaStyle {} {
    global rtfSpec
    foreachNode ancestor el {
	if {[$rtfSpec has continuedStyle]} {
	    return [$rtfSpec get continuedStyle]
	}
    }
    return [rtfEnv get currentStyle]
}

proc rtf::preprocess {rtfSpec} {
    variable TopicCounter 0
    relation subtopic parent child
    withNode docroot { process rtfPPHandler }
}
environment rtfPPEnv {
    parentNode	{}
}
eventHandler rtfPPHandler {
    START {
	rtfPPEnv save
    	if {![string compare [lindex [$rtfSpec get rtf -] 0] "topic"]} {
	    set topicID [subst [$rtfSpec get id "#AUTO"]]
	    set title [subst [$rtfSpec get title ""]]

	    set parentNode [rtfPPEnv get parentNode]
	    if {"$parentNode" != ""} {
		addlink subtopic \
		    parent	"node $parentNode" \
		    child	origin \
	    }

	    incr ::rtf::TopicCounter
	    if {![string compare $topicID "#AUTO"]} {
	    	set topicID "TOPIC-$::rtf::TopicCounter"
	    }
	    setprop rtfTopicID $topicID
	    setprop rtfTopicTitle $title
	    setprop rtfWindowType [subst [$rtfSpec get windowType ""]] 
	    rtfPPEnv set parentNode [query address]
	}
	if {[string length [set anchor [subst [$rtfSpec get anchor ""]]]]} {
	    setprop rtfAnchor $anchor
	}
    }
    END {
    	rtfPPEnv restore
    }
}

eventHandler rtfConvert -global {
    START {
	$rtfSpec do beforeAction
	rtf::write [subst [$rtfSpec get before ""]]
	rtfEnv save
	# %%% Document this:
	foreach param {cdataFilter sdataFilter currentStyle RE} {
	    if {[$rtfSpec has $param]} {
		rtfEnv set $param [$rtfSpec get $param]
	    }
	}

	switch [$rtfSpec get rtf unknown] {
	    #IMPLIED	{ }
	    #IGNORE	{
	   	rtfEnv set cdataFilter rtf::nullFilter  RE ""
	    }
	    none	{ }
	    special 	{ }
	    para {
		rtfEnv set RE " "
	    	rtf::startPara [subst [$rtfSpec get paraStyle]]
	    }
	    phrase {
	    	rtf::startPhrase [subst [$rtfSpec get charStyle]] 
	    }
	    block { rtfEnv set RE " " }
	    section {
	    	rtfEnv set RE "" 
		rtf::startSection [subst [$rtfSpec get sectStyle]]
	    }
	    linespecific {
		rtf::startPara [subst [$rtfSpec get paraStyle]]
		rtfEnv set RE "\\line\n"
	    }
	    topic { 
		winhelp_beginTopic $rtfSpec
		rtf::startTopic \
			-title 	  [subst [$rtfSpec get title ""]] \
			-topicID  [query propval rtfTopicID] \
			-keywords [subst [$rtfSpec get keywords {}]] \
			-windowType [query propval rtfWindowType]
		# %%% this doesn't work as expected:
		# %%% rtf::contentsLevel +1
	    }
	    unknown	{ cost::undefined GI [q gi] }
	    default	{
		cost::undefined GI "[q gi] rtf=[$rtfSpec get rtf]"
	    }
	}
	$rtfSpec do startAction
	rtf::write [subst [$rtfSpec get prefix ""]]
    }
    END {
	rtf::write [subst [$rtfSpec get suffix ""]]
	$rtfSpec do endAction
	switch [$rtfSpec get rtf unknown] {
	    para 	{ rtf::endPara }
	    phrase 	{ rtf::endPhrase }
	    topic	{ 
	    	if {$winhelpState(intopic)} { winhelp_finishTopic $rtfSpec } 
		# %%% rtf::contentsLevel -1
	    }
	    special	{ }
	    section	{ rtf::endSection }
	    linespecific { rtf::endPara }
	    default	{ }
	}
	rtfEnv restore
	rtf::write [subst [$rtfSpec get after ""]]
	$rtfSpec do afterAction
    }
    CDATA	{ rtf::text [[subst [rtfEnv get cdataFilter]] [content]] }
    RE  	{ if {$rtf_state(inpara)} { rtf::write [rtfEnv get RE] }}
    SDATA	{ rtf::write [[subst [rtfEnv get sdataFilter]] [content]] }
    DATAENT	{ $rtfSpec do content }
    PI		{ rtf::processPI [content] }
}

# %%% This is a hack, needed to get around bugs in Winhelp TOC viewer.
#
proc rtf::processPI {pival} {
    set pitarget [lindex $pival 0]
    set pivalue ""; regsub {^[^ ]* *} $pival {} pivalue
    switch -glob -- $pitarget {
	WINHELP:TOCHEADING {
	    rtf::contentsLine $pivalue
	}
	WINHELP:* {
	    cost::undefined "processing instruction" $pival
	}
    }
}

###
### WINHELP stuff:
###

global winhelpState;
array set winhelpState {
    intopic		0
    topicNode		-
}

proc winhelp_beginTopic {rtfSpec} {
    global winhelpState
    if {$winhelpState(intopic)} {
	winhelp_finishTopic $rtfSpec
    }
    set winhelpState(intopic)	1
    set winhelpState(topicNode)	[query address]
}

proc winhelp_finishTopic {rtfSpec} {
    global winhelpState
    if {$winhelpState(intopic)}  {
    	withNode node $winhelpState(topicNode) {
	    uplevel #0 [list $rtfSpec do topicFooter]
	}
    }
    set winhelpState(intopic) 0
    set winhelpState(topicNode) -
}

###
### Cross-reference management:
###

#
# rtf::linkpos --
#	Returns WINHELP jump target which will jump to the current node.
#	Use this to get the link target for rtf::startLink.
#
proc rtf::LinkTarget {} {
    foreachNode ancestor {
	foreach prop {rtfAnchor rtfTopicID} {
	    if {[query? hasprop $prop]} {
		return [query propval $prop]
	    }
	}
    }
}

# rtf::addAnchor
#	Adds an anchor ("midtopic jump label") for the current node.
#
proc rtf::addAnchor {} {
    withNode ancestor hasprop rtfAnchor {
	# @@@ TODO: don't emit same anchor multiple times
	rtf::magicFootnote topicID [query propval rtfAnchor]
    }
}

proc rtf::linkpos {} {
    set linkTarget [rtf::LinkTarget]
    # Now figure out window type:
    withNode ancestor hasprop rtfTopicID {
	set windowType [query propval rtfWindowType]
	if {$windowType == "#POPUP"} {
	    set linkTarget "^${linkTarget}"
	} elseif {[string length $windowType]} {
	    set linkTarget "${linkTarget}>$windowType"
	}
	return $linkTarget
    }
    cost::warning \
    	"RATFINK: Cannot find link target for [query gi][elementNumber]"
    return ""
}
#
# rtf::topicID -- 
#	Returns WINHELP topic ID of topic to which current node belongs.
#
proc rtf::topicID {} {
    return [query ancestor hasprop rtfTopicID propval rtfTopicID]
}
proc rtf::topicTitle {} {
    return [query ancestor hasprop rtfTopicID propval rtfTopicTitle]
}

#*EOF*
