#############################################################
# package Cost-Latex, v 0.2
# A library of SGML-to-LaTeX conversion utilities for Cost
#
# Work in progress.
#
# $Id: latex.tcl,v 1.11 2002/02/28 02:13:04 joe Exp $
# $Date: 2002/02/28 02:13:04 $
#############################################################

package require Cost

package provide Cost-Latex 0.2

namespace eval latex {

    variable outfp stdout
    variable spec ::latex::NoSpecification

    environment ::latex::latexEnv {
	textEscape 	::latex::textEscape
    }
    variable textEscape ::latex::textEscape

    set Latex(documentClass) ""		;# document class
    set Latex(classOptions) [list]	;# class options
    set Latex(packages) [list]		;# extra packages
    set Latex(preamble)	{}		;# extra preamble text

    set Latex(defaultDocumentClass)	article

    set Latex(closeOutput) 0		;# flag: close $outfp when done?
    set Latex(documentElement) {}	;# node address of main body element
    set Latex(divtypes) {}

    # Document metainformation:
    set Latex(m.author) 	[list]
    set Latex(m.title)		[list]
    set Latex(m.date)		[list]

    variable LatexClasses  ;
    array set LatexClasses {
	article {
	    divtypes {section subsection subsubsection paragraph subparagraph}
	}
	book {
	    divtypes {chapter section subsection subsubsection 
	    		paragraph subparagraph}
	}
	report {
	    divtypes {chapter section subsection subsubsection 
	    		paragraph subparagraph}
	}
    }
}

#############################################################
#
# Declaration routines:
#
# These can be called in any order;
# they will be written out in the proper order when latex::beginDocument
# is called.
#

proc latex::configure {args} {
    foreach {option value} $args {
	return -code error "Bad option $option"
    }
}

# latex::useSpec <specname>
#	<specname> is the Cost specification to use.
#	%%% See latex::processElement for a description of the parameters.
#
proc latex::useSpec {specname} {
    variable spec $specname
}

# latex::outputTo fp
# latex::outputFile filename --
#	Specify where output goes.
#
proc latex::outputTo {fp} {
    variable outfp $fp
}

proc latex::outputFile {filename} {
    variable outfp [open $filename w]
    set Latex(closeOnExit) 1
}

# NoSpecification --
#	Stub routine, issues an error if the user forgot to call latex::useSpec
#
proc latex::NoSpecification {args} {
    return -code error "Must call 'latex::useSpec <specification> first"
}

# documentClass class  ? class-options ... ?
#	Specify which LaTeX document class to use.
#
proc latex::documentClass {class args} {
    variable Latex
    variable LatexClasses
    if {[llength $args] == 1} { set args [lindex $args 0] }
    set Latex(documentClass) $class
    foreach arg $args {
    	lappend Latex(classOptions) $arg
    }
    if {[info exists LatexClasses($class)]} {
    	array set Latex $LatexClasses($class)
    }
}

# usePackage package ? package-options... ?
#	Arranges for \usepackage{package} to be inserted into the preamble,
#	with options ? package-options ... ?
#	Package options accumulate.
#
proc latex::usePackage {package args} {
    variable Latex
    if {[llength $args] == 1} { set args [lindex $args 0] }

    if {[lsearch $Latex(packages) $package] == -1} {
    	lappend Latex(packages) $package
	set Latex(packageOptions.$package) [list]
    }

    foreach option $args {
    	if {[lsearch $Latex(packageOptions.$package) $option] == -1} {
	    lappend Latex(packageOptions.$package) $option
	}
    }
}

# preambleText <cmds>
#	Inserts <cmds> into the preamble.
#

proc latex::preambleText {text} {
    variable Latex
    append Latex(preamble) "\n$text"
}

#############################################################
#
# Utility routines:
#


# Substitution for text mode:
#
# Changes LaTeX markup characters into their command equivalents.
# Inserts " %" before newlines to avoid spurious paragraph breaks.
# Protects "[" and "]" with squiggle brackets, since these are magic
#   when they follow control sequences like \item.
# Replaces "TeX" and "LaTeX" with the conventional logos.
#
substitution ::latex::textEscape {
	"\n"	" %\n"

	"#"	"\\#"
	"$"	"\\\$"
	"%"	"\\%"
	"&"	"\\&"
	"_"	"\\_"
	"\{"	"\\\{"
	"\}"	"\\\}"
	"~"	"\\textasciitilde{}"
	"^"	"\\textasciicircum{}"
	"\\"	"\\textbackslash{}"
	"<"	"\\textless{}"
	">"	"\\textgreater{}"
	"|"	"\\textbar{}"

	"["	"\{[\}"
	"]"	"\{]\}"

	"TeX"	"\\TeX{}"
	"LaTeX"	"\\LaTeX{}"

}
substitution ::latex::allttEscape {
	"#"	"\\#"
	"$"	"\\\$"
	"%"	"\\%"
	"&"	"\\&"
	"_"	"\\_"
	"\{"	"\\\{"
	"\}"	"\\\}"
	"~"	"\\textasciitilde{}"
	"^"	"\\textasciicircum{}"
	"\\"	"\\textbackslash{}"
}

# write   <code> 	--
# writeln <code>
#	Output <code> literally (no substitutions)
#
proc latex::write {text} {
    variable outfp
    puts -nonewline $outfp $text
}

proc latex::writeln {{text {}}} {
    variable outfp
    puts $outfp $text
}

# bgroup/egroup --
#	Output '{' and '}' characters
#
proc latex::bgroup {} { variable outfp ; puts $outfp \{ nonewline }
proc latex::egroup {} { variable outfp ; puts $outfp \} nonewline }

# text <text> --
#	Output <text> as character data, escaping magic characters
#
# %%% TODO: possibly: different substitutions based on context
#
proc latex::text {text} {
    variable textEscape
    puts $::latex::outfp [$textEscape $text] nonewline
}

# cs {csname} --
# 	Output control sequence \csname
#
proc latex::cs {csname} {
    puts $::latex::outfp "\\$csname" nonewline
}

proc latex::macro {csname args} {
    set macroargs ""
    foreach arg $args {
   	if {[string match "\[\\\[\\\{\]*" $arg]} {
	    append macroargs $arg
	} else {
	    append macroargs "{$arg}"
	}
    }
    puts $::latex::outfp "\\${csname}${macroargs}" nonewline
}

# latex::begin environment ?envargs?
# latex::end environment
#	\begin{environment} / \end{environment} pairs.
#
proc latex::begin {envname {arglist {}}} {
    variable outfp
    set envargs ""
    foreach arg $arglist {
    	switch -- [string index $arg 0] {
	\{ -
	\[ 		{ append envargs $arg }
	default 	{ append envargs "{$arg}" }
	}
    }
    puts $outfp "\\begin{$envname}${envargs}"
}

proc latex::end {envname} {
    variable outfp
    puts $outfp "\n\\end{$envname}"
}

proc latex::includeGraphics {filepath} {
    latex::writeln "\\includegraphics{$filepath}"
}

#
# beginDocument --
#	Call at the beginning of translation.
#	Generates the \documentclass{} command and preamble,
#	NB: does *not* generate \begin{document}
#
proc latex::beginDocument {} {
    variable Latex
    set msg "Generated by Cost $::COST(VERSION)"
    if {[info exists ::COST(INPUTFILE)]} {
	append msg " from $::COST(INPUTFILE)"
    }
    latex::writeln "% $msg"

    # \documentclass:
    #
    if {![llength $Latex(documentClass)]} {
    	latex::documentClass $Latex(defaultDocumentClass)
    }
    if {[llength $Latex(classOptions)]} {
    	set classopts "\[[join $Latex(classOptions) "," ]\]"
    } else {
    	set classopts ""
    }
    latex::writeln "\\documentclass${classopts}{$Latex(documentClass)}"

    # Packages:
    #
    foreach package $Latex(packages) {
    	if {[llength [set opts $Latex(packageOptions.$package)]]} {
	    latex::writeln "\\usepackage\[[join $opts ,]\]{$package}"
	} else {
	    latex::writeln "\\usepackage{$package}"
	}
    }

    # Metainformation:
    #
    foreach {cat sep} {
	title 	{\\}
	author	{\and}
	date	{\\}
    } {
	if {[llength $Latex(m.$cat)]} {
	    latex::writeln "\\$cat{[join $Latex(m.$cat) " $sep\n"]}"
	}
    }

    # Extra preamble text:
    #
    latex::writeln $Latex(preamble)

    # Done.
    #
    return;
}

# latex::endDocument --
#	Cleanup at the end of translation.
#
proc latex::endDocument {} {
    variable Latex
    latex::writeln
    if {$Latex(closeOutput)} { close $outfp }
}

#############################################################
#
# Main body:
#

# Latex translation preprocessing phase:
#
proc latex::preprocess {} {
    variable spec
    variable Latex

    #
    # Look for (unique) node with latex=document
    # Set 'reflabel' property
    # Accumulate metainfo parameters.
    #
    foreachNode doctree el {
      switch -- [lindex [set arcform [$spec get latex "#UNDEFINED"]] 0] {
	document {
	    if {[string length $Latex(documentElement)]} {
	    	error "Multiple 'document' elements found"
	    }
	    set Latex(documentElement) [query address]
	    if {[$spec has documentClass]} {
	    	latex::documentClass \
		    [$spec get documentClass] \
		    [$spec get classOptions {}]
	    }
	    foreach package [$spec get packages {}] {
	    	latex::usePackage $package
	    }
	    # %%% ALSO: classoptions, etc
	}
	division {
	    if {[query? hasatt id]} {
	    	setprop reflabel "D-[query attval id]"
	    } else {
	    	setprop reflabel "D-[query address]"
	    }
	    if {[llength $arcform] >= 2} {
	    	set divtype [lindex $arcform 1]
	    } else {
		set secdepth [query# ancestor hasprop divtype]
	    	set divtype [lindex $Latex(divtypes) $secdepth]
	    }
	    if {![string length $divtype]} {
	    	cost::warning "Cannot determine division type"
	    } else {
		setprop divtype $divtype
	    }
	}
	metainfo {
	    switch -- [set category [lindex $arcform 1]] {
		title	-
		author	-
		date 	{ lappend Latex(m.$category) [content] }
		default { cost::undefined latex-metainfo $category }
	    }
	}
      }
    }
}

# processElement --
#	Processing for EL nodes.
#
proc latex::processElement {} {
    variable spec

    uplevel #0 [list $spec do beforeAction {latex::insertParam before}]
    latexEnv save 
    if {[$spec has textEscape]} {
	latexEnv set textEscape [set ::latex::textEscape [$spec get textEscape]]
    }
    set arcform [$spec get latex "#UNSPECIFIED"]
    switch -- [lindex $arcform 0] {
	para {
	    latex::processContent
	    latex::write "\n\n"
	}
	environment {
	    set env [lindex $arcform 1]
	    latex::begin $env
	    latex::processContent
	    latex::end $env
	}
	verbatim {
	    if {[llength $arcform] == 2} {
	    	set env [lindex $arcform 1]
	    } else {
	    	set env verbatim
	    }
	    latexEnv set textEscape \
	    	[set ::latex::textEscape [$spec get textEscape identity]]
	    latex::begin $env
	    latex::processContent
	    latex::end $env
	}
	macro {
	    set macro [lindex $arcform 1]
	    latex::write "\\${macro}{"
	    	latex::processContent
	    latex::write "}"
	}
	listitem {
	    latex::write "\n\\item{} "
	    latex::processContent
	}
	itemtag {
	    latex::write "\n\\item\["
	    latex::processContent
	    latex::write "\]"
	    latex::writeln " %"
	}
	taggeditem {
	    latex::write "\n\\item\["
	    $spec do itemtag { latex::insertParam tagtext }
	    latex::write "\]"
	    latex::writeln " %"
	    latex::processContent
	}
	itembody {
	    latex::processContent
	}
	heading {
	    if {[llength $arcform] >= 2} {
		set headingtype [lindex $arcform 1]
	    } elseif {[query? ancestor hasprop divtype]} {
	    	set headingtype [query ancestor propval divtype]
	    } else {
	    	cost::warning "Division type not specified"
		set headingtype "section"
	    }

	    latex::writeln;
	    latex::write "\\${headingtype}{"
	    latex::processContent
	    latex::write "}"
	    latex::writeLabel [query ancestor propval reflabel]
	    latex::writeln
	    # %%% ALSO: short title for TOC; headingmark for running head/foot
	    # %%% ALSO: check for unnumbered forms
	}

	document {
	    latex::begin document
	    latex::processContent
	    latex::end document
	}

	division 	{ latex::processContent }

	xref {
	    uplevel #0 [list $spec do prefixAction {latex::insertParam prefix}]
	    set reflabel [subst [$spec get reflabel]]; # %%%
	    switch -- [set reftype [$spec get reftype "ref"]] {
	    	ref	-
		pageref { latex::write "\\$reftype{$reflabel}" }
		cite	-
		default { cost:undefined reftype $reftype }
	    }
	    uplevel #0 [list $spec do suffixAction {latex::insertParam suffix}]
	}

	metainfo	{ # handled in ::preprocess }
	#IGNORE 	{ # no-op }
	#IMPLIED	{ latex::processContent }
	#UNSPECIFIED	{ cost:undefined GI [query gi];latex::processContent }

	default {
	    cost:undefined latex-form [lindex $arcform 0]
	    latex::processContent
	}
    }
    latexEnv restore
    set ::latex::textEscape [latexEnv get textEscape]
    uplevel #0 [list $spec do afterAction {latex::insertParam after}]
    return;
}


proc latex::writeLabel {label} {
    variable Labels
    if {![string length $label] || [info exists Labels($label)]} {
	# %%% quick hack: prevent duplicate labels.
    	return;
    }
    latex::write " \\label{$label}"
    set Labels($label) [query address]
}

# latex::processContent --
#	Processes content of the current node;
#	default action: processChildren.
#
proc latex::processContent {} {
    variable spec
    $spec do content latex::processChildren
}

# latex::processChildren --
#	Process all children of the node, plus prefix and suffix actions
#
proc latex::processChildren {} {
    variable spec
    uplevel #0 [list $spec do prefixAction {latex::insertParam prefix}]
    foreachNode child { latex::processNode }
    uplevel #0 [list $spec do suffixAction {latex::insertParam suffix}]
}

# insertParam --
#	Helper routine: inserts the value of parameter 'prefix',
#	after passing it through Tcl 'subst' command.
#
proc latex::insertParam {param} {
    variable spec
    variable outfp
    puts $outfp [uplevel #0 [list subst [$spec get $param ""]]] nonewline
}

proc latex::processNode {} {
    switch [query nodetype] {
    	EL	{ latex::processElement }
	CDATA	{ latex::text [query content] }
	RE	{ latex::text [query content] }
	PEL -
	SD	{ latex::processContent }
	PI	{ if {[regexp {^latex (.*)$} [content] -> pival]} {
		    latex::write $pival
		  }
		}
	default { cost:undefined nodetype [query nodetype] }
    }
}

# Default main routine:
#
proc latex::main {} {
    variable spec
    variable Latex
    latex::preprocess
    latex::beginDocument
    if {[string length $Latex(documentElement)]} {
	withNode node $Latex(documentElement) { latex::processNode }
    } else {
	latex::begin document
	withNode docroot { latex::processNode }
	latex::end document
    }
    latex::endDocument
    return;
}

#*EOF*
