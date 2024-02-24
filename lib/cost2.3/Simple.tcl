# 
#	$Id: Simple.tcl,v 1.8 2000/08/11 17:03:13 joe Exp $
#	Simple, one-pass translation module for Cost 2.
#

package provide Cost-Simple 1.0

global translateSpec 
set translateSpec "translate"

environment translateEnv  \
	cdataFilter identity  \
	sdataFilter identity

proc identity {text}	{ return $text }
proc output {text}	{ puts -nonewline stdout $text }

eventHandler translateHandler -global {
    START {
	output [subst [$translateSpec get before ""]]
	translateEnv save
	foreach param {cdataFilter sdataFilter} {
	    if [$translateSpec has $param] {
		translateEnv set $param [$translateSpec get $param]
	    }
	}
	$translateSpec do startAction
	output [subst [$translateSpec get prefix ""]]
    }
    END { 
	output [subst [$translateSpec get suffix ""]]
	$translateSpec do endAction
	translateEnv restore
	output [subst [$translateSpec get after ""]]
    }
    CDATA	{ output [[translateEnv get cdataFilter] [query content]] }
    RE  	{ output [[translateEnv get cdataFilter] "\n"] }
    SDATA	{ output [[translateEnv get sdataFilter] [query content]] }
}

eventHandler contentHandler {
    CDATA   { append result [[translateEnv get cdataFilter] [q content]] }
    SDATA   { append result [[translateEnv get sdataFilter] [q content]] }
    RE      { append result [[translateEnv get cdataFilter] "\n"] }
}

proc translateContent {} {
    set result ""
    process contentHandler
    return $result
}

proc main {} {
    fconfigure stdout -buffering full
    translateHandler 
}

#*EOF*
