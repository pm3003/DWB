#############################################################
# RATFINK v1.0
# A library of RTF output utilities
# $Id: rtflib.tcl,v 1.22 2002/05/15 01:26:50 joe Exp $
# Created 4 Dec 1995 / Last updated $Date: 2002/05/15 01:26:50 $
#############################################################
#
# Copyright (C) 1996-2002 Joe English
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for any purpose and without fee is hereby granted.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#############################################################
# RATFINK lives at <URL:http://www.flightlab.com/cost/ratfink/>
#############################################################

# %%% TODO: Rework rtf_state(inXXX) checks -- this is getting
# %%%   too complicated to do "by hand" (topics, sections, paragraphs,
# %%%   tables, links; etc.).  Try an FSM derived from RTF meta-DTD.
# %%% TODO: allow true/false/on/off/etc for boolean attributes
# %%% TODO: rtf::zapFunkyCharacters for docTitle, contents file output, &c
# %%% TODO: make sure all topics in a browse sequence use same window type

package provide rtflib 1.0

namespace eval rtf { }

proc rtf::warning {text} {
    puts stderr "RTF warning: $text"
}
proc rtf::undefined {class value} {
    global RTFUndefined
    if {![info exists RTFUndefined($class.$value)]} {
	set RTFUndefined($class.$value) 1
	rtf::warning "undefined $class '$value'"
    }
}

###
### Character formatting attributes
###

array set rtf::CharAttrs {
    Font	{table rtf::FontTable "f"}
    FontSize	{halfpts "fs"}
    Bold	{boolean "b"}
    Italic	{boolean "i"}
    Hidden	{boolean "v"}

    AllCaps	{boolean "caps"}
    SmallCaps	{boolean "scaps"}
    StrikeThru	{boolean "strike"}

    Underline {enum {
	{0 ulnone} {None ulnone}
	{1 ul} {Continuous ul} {Single ul}
	{Dot uld}
	{Double uldb}
	{Word ulw}
    }}

    Subscript		{flag "sub"}
    Superscript		{flag "super"}
    NoSuperSub		{flag "nosupersub"}
    ShiftDown		{halfpts "dn"}
    ShiftUp		{halfpts "up"}

    FGColor		{table rtf::ColorTable "cf"}
    BGColor		{table rtf::ColorTable "cb"}

    LetterSpace		{dimension "expndtw"}
    KernAbove		{halfpts "kerning"}

    TextDirection {enum {
	{RTL	"rtlch"}
	{LTR	"ltrch"}
    }}
    Charset	{table rtf::CharsetTable  "cchs"}
    Language	{table rtf::LanguageTable "lang"}
}

###
### Paragraph formatting attributes
###
array set rtf::ParaAttrs {
    TabStops    	{proc rtf::ExpandTabStops}
    FirstIndent 	{dimension "fi"}
    LeftIndent  	{dimension "li"}
    RightIndent 	{dimension "ri"}
    SpaceBefore 	{dimension "sb"}
    SpaceAfter  	{dimension "sa"}
    LineSpacing 	{dimension "sl"}
    KeepTogether	{flag "keep"}
    KeepWithNext	{flag "keepn"}
    PageBreakBefore	{flag "pagebb"}
    Hyphenate   	{boolean "hyphpar"}
    Quadding {enum {
	    {Left	"ql"}
	    {Right	"qr"}
	    {Justify	"qj"}
	    {Center	"qc"}
    }}
    InnerBorders	{flag "brdrbtw"}
    Box 		{proc rtf::ExpandRuleStyle "box"}
    TopBorder		{proc rtf::ExpandRuleStyle "brdrt"}
    BottomBorder	{proc rtf::ExpandRuleStyle "brdrb"}
    LeftBorder		{proc rtf::ExpandRuleStyle "brdrl"}
    RightBorder		{proc rtf::ExpandRuleStyle "brdrr"}
    OutsideBorder	{proc rtf::ExpandRuleStyle "brdrbar"}
}
# All character attributes are also paragraph attributes:
array set rtf::ParaAttrs [array get rtf::CharAttrs]


###
### Section formatting attributes
###
array set rtf::SectAttrs {
    PageWidth    	{dimension "pgwsxn"}
    PageHeight    	{dimension "pghsxn"}
    LeftMargin    	{dimension "marglsxn"}
    RightMargin    	{dimension "margrsxn"}
    TopMargin    	{dimension "margtsxn"}
    BottomMargin	{dimension "margbsxn"}
    GutterWidth        	{dimension "guttersxn"}
    Landscape		{flag "lndscpsxn"}
    HasTitlePage	{flag "titlepg"}
    HeaderPosition	{dimension "headery"}
    FooterPosition	{dimension "footery"}
    SectionBreak {enum {
	    {None	"sbknone"}
	    {Page	"sbkpage"}
	    {EvenPage	"sbkeven"}
	    {OddPage	"sbkodd"}
    }}
    VAlign {enum {
	    {Top	"vertalt"}
	    {Bottom	"vertalb"}
	    {Middle	"vertalc"} {Center	"vertalc"}
	    {Justify	"vertalj"}
    }}
    FirstPageNumber 	{integer starts}
    RestartPageNumbers {enum {
	{0 "pgncont"}
    	{1 "pgnrestart"}
    }}
    PageNumbering {enum {
	{Arabic 	"pgndec"} {Decimal "pgndec"}
	{UCRoman	"pgnucrm"}
	{LCRoman	"pgnlcrm"}
	{UCAlpha	"pgnucltr"}
	{LCAlpha	"pgnlcltr"}
    }}

    Columns		{integer "cols"}
    ColumnSepSpace	{dimension "colsx"}
    ColumnLine		{flag "linebetcol"}
    ColumnDirection	{enum {
	{RTL "rtlsect"}
	{LTR "ltrsect"}
    }}
}

###
### Table attributes:
###

# nb: CellPosition is really a dimension
array set rtf::TableAttrs {
    CellPosition	{integer "cellx"}
    RowGap		{dimension "trgaph"}
    RowHeight		{dimension "trrh"}
    HeadingRow		{flag "trhdr"}
    Align		{enum {
			    {Left	"trql"}
			    {Right	"trqr"}
			    {Center	"trqc"}
			}}
    CellBorderBottom	{table rtf_RuleTable "clbrdrb"}
    CellBorderTop	{table rtf_RuleTable "clbrdrt"}
    CellBorderLeft	{table rtf_RuleTable "clbrdrl"}
    CellBorderRight	{table rtf_RuleTable "clbrdrr"}
}

global rtf_tableSettings rtf_tableDefaults
array set rtf_tableDefaults {
    width	6in
    numcols	1
    numcells	1
    rowgap	0pt
    rowsep	-
    colsep	-
    frame	-
    toprule	-
    botrule	-
    rowalign	Center
}
array set rtf_tableSettings [array get rtf_tableDefaults]

###
### Style attribute handling
###

proc rtf::ExpandAttributes {tblName attlist} {
    upvar #0 $tblName table
    set result ""
    while {[llength $attlist] >= 2} {
	set param [lindex $attlist 0]
	set value [lindex $attlist 1]
	set attlist [lrange $attlist 2 end]

	if {![info exists table($param)]} {
	    rtf::warning "No parameter $param in $tblName"
	    continue
	}

	set key $table($param)

	switch [lindex $key 0] {
	    unknown {
		rtf::warning "Don't grok parameter $param=$value in $tblName"
		continue
	    }

	    boolean {
		set csname [lindex $key 1]
		if {$value} {
		    set cs "\\$csname"
		} else {
		    set cs "\\${csname}0"
		}
	    }

	    flag {
		set csname [lindex $key 1]
		if {$value} {
		    set cs "\\$csname"
		} else {
		    rtf::warning "Parameter $param can only be turned on"
		}
	    }

	    integer {
		if {![regexp -- {^-?[0-9]+$} $value]} {
		    rtf::warning "bad integer $value in parameter $param"
		    continue
		}
		set csname [lindex $key 1]
		set cs "\\${csname}$value"
	    }

	    dimension {
		set csname [lindex $key 1]
		set cs "\\${csname}[rtf::cvTwips $value]"
	    }

	    halfpts {
		set csname [lindex $key 1]
		set cs "\\${csname}[rtf::cvHalfpts $value]"
	    }

	    enum {
		catch {unset cs}
		set enumnames {}
		foreach enumpair [lindex $key 1] {
		    set enumname [lindex $enumpair 0]
		    if {[string match $value $enumname]} {
			set cs "\\[lindex $enumpair 1]";
			break;
		    }
		    lappend enumnames $enumname;
		}
		if {![info exists cs]} {
		    rtf::warning \
		"Unknown value $param $value: must be one of $enumnames"
		    continue
		}
	    }

	    table {
		set subtblName [lindex $key 1]
		upvar #0 $subtblName subtable
		if {![info exists subtable($value)]} {
		    rtf::warning "$param: no mapping for $value in $subtblName"
		    continue
		}
		if {[llength $key] == 3} {
		    set cs "\\[lindex $key 2]$subtable($value)"
		} else {
		    set cs $subtable($value)
		}
	    }

	    proc {
		set procName [lindex $key 1]
		set cs [$procName $value]
		if {[llength $key] == 3} {
		    set cs "\\[lindex $key 2]$cs"
		}
	    }

	    pseudo {
		# pseudo-argument; ignore
		set cs ""
	    }

	    default {
		rtf::warning "Bad parameter type [lindex $key 0] for $param"
		continue
	    }
	}
	append result $cs
    }
    if {[llength $attlist] != 0} {
	rtf::warning "Leftover arguments: <$attlist>"
    }
    return $result
}

# Expand attributes from associative array.
# 'paramlist' if present specifies the desired output order.
#
proc rtf::ExpandArray {tblName specsName {paramlist {}}} {
    upvar #0 $tblName table
    upvar 1 $specsName specs

    set speclist {}
    if {$paramlist == {}} { set paramlist [array names specs] }
    foreach param $paramlist {
	if {[info exists specs($param)]} {
	    lappend speclist $param $specs($param)
	}
    }
    # error-check:
    foreach param [array names specs] {
	if {![info exists table($param)]} {
	    rtf::warning "No parameter $param in $tblName"
	}
    }

    return [rtf::ExpandAttributes $tblName $speclist]
}

###
### Stylesheet management
###

global rtf_styleSheet; 	# key: $styleName,(DESC|NUM|DEF|TYPE|BASEDON)
global rtf_styleNames;	set rtf_styleNames {}
global rtf_styleNum; 	set rtf_styleNum 1

proc rtf::paraStyle {name desc args} { rtf::defineStyle PARA $name $desc $args }
proc rtf::charStyle {name desc args} { rtf::defineStyle CHAR $name $desc $args }
proc rtf::sectStyle {name desc args} { rtf::defineStyle SECT $name $desc $args }

proc rtf::defineStyle {type name desc arglist} {
    global rtf_styleNum rtf_styleSheet rtf_styleNames

    set rtf_styleSheet($name,NUM) $rtf_styleNum
    set rtf_styleSheet($name,DESC) $desc
    set rtf_styleSheet($name,TYPE) $type
    set styledef ""

    set rankGroup #NONE

    while {[string match "-*" [lindex $arglist 0]]} {
	set option [lindex $arglist 0]
	set value [lindex $arglist 1]
	set arglist [lrange $arglist 2 end]
	switch -- $option {
	    -basedon {
		if {![string length $value]} { continue }
		if {![info exists rtf_styleSheet($value,DEF)]} {
		    rtf::undefined style $value
		    continue
		}
		if {$rtf_styleSheet($value,TYPE) != $type} {
		    rtf::warning "$name based on style of different type"
		    continue
		}
		set rtf_styleSheet($name,BASEDON) $value
		append styledef "$rtf_styleSheet($value,DEF)"
	    }
	    -rankgroup {
	    	variable rankGroups
		set rankGroup $value
		if {![info exists rankGroups($rankGroup.styles)]} {
		    rtf::undefined rankGroup $rankGroup
		    rtf::rankGroup $rankGroup
		}
		lappend rankGroups($rankGroup.styles) $name
	    }
	    default {
		rtf::warning "rtf::defineStyle -- bad option $option"
	    }
	}
    }
    set attlist [lindex $arglist 0]
    switch $type {
	PARA { set styletable rtf::ParaAttrs }
	CHAR { set styletable rtf::CharAttrs }
	SECT { set styletable rtf::SectAttrs }
    }
    set stylespec [rtf::ExpandAttributes $styletable $attlist]
    append styledef $stylespec

    set rtf_styleSheet($name,DEF) $styledef

    if {[string compare $rankGroup #NONE]} {
    	set rtf_styleSheet(${name}0,DEF) $styledef
    	set rtf_styleSheet(${name}0,NUM) $rtf_styleNum
    }

    incr rtf_styleNum
    lappend rtf_styleNames $name

    return;
}

###
### Ranked styles.
###

proc rtf::rankGroup {name} {
    variable rankGroups
    set rankGroups($name.styles) [list]
    set rankGroups($name.level) 0
}

proc rtf::rankedStyle {baseName rankLevel styleSpec} {
    global rtf_styleSheet
    rtf::defineStyle PARA "${baseName}${rankLevel}" \
    	"$rtf_styleSheet($baseName,DESC) level $rankLevel" \
	[list -basedon $baseName $styleSpec] \
	;
}

proc rtf::rankLevel {group incr} {
    global rtf_styleSheet
    variable rankGroups

    set level [incr rankGroups($group.level) $incr]
    foreach baseStyle $rankGroups($group.styles) {
	set curStyle "${baseStyle}${level}"
	if {![info exists rtf_styleSheet($curStyle,NUM)]} {
	    rtf::undefined rank $curStyle
	    continue
	}
	set rtf_styleSheet($baseStyle,NUM) $rtf_styleSheet($curStyle,NUM)
	set rtf_styleSheet($baseStyle,DEF) $rtf_styleSheet($curStyle,DEF)
    }
}

###
### Emit stylesheet.
###

proc rtf::writeStyleSheet {} {
    global rtf_styleNames rtf_styleSheet
    rtf::bgroup
    rtf::write "\\stylesheet"
    foreach style $rtf_styleNames {
	rtf::bgroup
	switch $rtf_styleSheet($style,TYPE) {
	    PARA { set styletype "\\s" }
	    CHAR { set styletype "\\cs" }
	    SECT { set styletype "\\ds" }
	}
	rtf::write "$styletype$rtf_styleSheet($style,NUM)"
	rtf::write "$rtf_styleSheet($style,DEF)"
	if {[info exists rtf_styleSheet($style,BASEDON)]} {
	    set basedon $rtf_styleSheet($style,BASEDON)
	    rtf::write "\\sbasedon$rtf_styleSheet($basedon,NUM)"
	}
	rtf::write " $rtf_styleSheet($style,DESC);"
	rtf::egroup
    }
    rtf::egroup
}

###
### Dimensions
###
global rtf_twipsMap
array set rtf_twipsMap "
	twip	1
	pt	20
	halfpt	10
	in	[expr 72 * 20]
	pc	[expr 12 * 20]
	pica	[expr 12 * 20]
	cm	567
	mm	56.7
"

# %%% The conversion factor 56.7 for 'mm' was determined --
# %%% by experimentation -- so RATFINK's definition of A4 paper (210mm x 297mm)
# %%% matches WFW95v7's definition (\paperw11907\paperh16840)
# %%% after rounding.  [expr (72 * 20) / 25.4] == 56.6929
# %%% is a *little* bit smaller than what Word appears to use.

proc rtf::cvTwips {dim} {
    global rtf_twipsMap
    if {![regexp -- {^(-?[0-9\.]+)([a-z]+)$} $dim dummy qty units]} {
	rtf::warning "Bad dimension $dim"
	return 0
    }
    if {![info exists rtf_twipsMap($units)]} {
	rtf::warning "Bad units $units"
	return 0
    }
    set scale $rtf_twipsMap($units)
    return [expr round($qty * $scale)]
}

proc rtf::cvHalfpts {dim} {
    if {[regexp -- {^-?([0-9\.]+)$} $dim]} {
	return $dim
    }
    return [expr round([rtf::cvTwips $dim] / 10)]
}

###
### Fonts
###
global rtf_fonttbl rtf_numberFonts
set rtf_fonttbl [join {
	{{\f0\froman\fcharset0\fprq2 Times New Roman;}}
	{{\f1\fswiss\fcharset0\fprq2 Arial;}}
	{{\f2\fmodern\fcharset0\fprq1 Courier New;}}
    } "" ]
array set rtf::FontTable {
	roman	0
	sans	1
	mono	2
}
set rtf_numberFonts 3

proc rtf::defineFont {id fontname args} {
    global rtf::FontTable rtf_numberFonts
    set rtf::FontTable($id) $rtf_numberFonts
    append rtf_fonttbl "{\\f$rtf_numberFonts\\fnil $fontname}"
    incr rtf_numberFonts
}

proc rtf::writeFontTable {} {
    #+%%%
    global rtf_fonttbl;
    rtf::bgroup
    rtf::write "\\fonttbl $rtf_fonttbl"
    rtf::egroup
}

###
### Color table:
### Unlike the font table and stylesheet, there is no "define color"
### RTF control word.  Instead, colors are specified by their
### position in the color table, which is simply a list of 
### \red\green\blue values separated by semicolons.
###
### For consistency, RATFINK maps symbolic color names to 
### color indexes in the same way as it does other parameters.
###
array set rtf::ColorTable {
    black	1
    white	2
}
set rtf_numberColors 2
set rtf_colortbl {\red0\green0\blue0;\red255\green255\blue255;}

proc rtf::defineColor {id spec} {
    global rtf::ColorTable rtf_colortbl rtf_numberColors

    # Parse color spec: #hhhhhh, #hhhhhhhhh, or #hhhhhhhhhhhh
    set hd {[0-9a-fA-F]};
    set h2 "$hd$hd"; set h3 "$hd$hd$hd"; set h4 "$hd$hd$hd"
    if     {[regexp "^#($h2)($h2)($h2)$" $spec - r g b]} { set m 0 } \
    elseif {[regexp "^#($h3)($h3)($h3)$" $spec - r g b]} { set m 4 } \
    elseif {[regexp "^#($h4)($h4)($h4)$" $spec - r g b]} { set m 8 } \
    else {
    	error "Bad color specification $spec"
    }
    foreach {v cs} {r red g green b blue} {
	scan [set $v] %x rgbval
	set rgbval [expr $rgbval >> $m]
	append rtf_colortbl "\\$cs$rgbval"
    }
    append rtf_colortbl ";\n"
    incr rtf_numberColors
    set rtf::ColorTable($id) $rtf_numberColors
}

proc rtf::writeColorTable {} {
    global rtf_colortbl;
    rtf::bgroup
    rtf::write "\\colortbl; $rtf_colortbl"
    rtf::egroup
}

###
### Tab stops
###

# The order of the control words must be <kind>? <leaders>? <position>,
array set rtf_TabAttrs {
    Align {enum {
	{Left	"tql"}
	{Right	"tqr"}
	{Center	"tqc"}
	{Decimal "tqdec"}
    }}
    Leaders {enum {
	{Dot	"tldot"}
	{Hyphen	"tlhyph"}
	{Under	"tlul"}
	{Thick	"tlth"}
	{Equal	"tleq"}
    }}
    Position {dimension "tx"}
}
proc rtf::tabStops {name stops} {
    global rtf_TabTable
    if {[info exists rtf_TabTable($name)]} {
	rtf::warning "Redefining tab settings $name"
    }
    set rtf_TabTable($name) [rtf::ExpandTabStops $stops]
}

proc rtf::ExpandTabStops {stops} {
    global rtf_TabAttrs rtf_TabTable
    set result ""
    if {[regexp {^[a-zA-Z][-_a-zA-Z0-9]*$} $stops]} {
	if {[info exists rtf_TabTable($stops)]} {
	    return $rtf_TabTable($stops)
	} else {
	    rtf::warning "Tab settings <$stops> not defined"
	    return ""
	}
    }
    foreach stop $stops {
	catch {unset tmp}
	set tmp(Position) [lindex $stop 0]
	array set tmp [lrange $stop 1 end];
	append result \
		[rtf::ExpandArray rtf_TabAttrs tmp "Align Leaders Position"]
    }
    return $result
}

###
### Rule styles
###

# Order of control words is:
# <brdrk>, <width>?, <space>?, <color>?
# <brdrk> == 'Style' is mandatory and must be first.
#
array set rtf_RuleAttrs {
    Style {enum {
	{Normal	"brdrs"}
	{Thick	"brdrth"}
	{Double	"brdrdb"}
	{Shadow	"brdrsh"}
	{Dot	"brdrdot"}
	{Dash	"brdrdash"}
	{Hairline	"brdrhair"}
    }}
    Margin	{dimension "brsp"}
    Thickness	{dimension "brdrw"}
    Color	{table rtf::ColorTable "brdrcf"}
}
proc rtf::ruleStyle {name attlist} {
    global rtf_RuleTable
    if {[info exists rtf_RuleTable($name)]} {
	rtf::warning "Redefining rule style $name"
    }
    set rtf_RuleTable($name) [rtf::ExpandRuleStyle $attlist]
}
proc rtf::ExpandRuleStyle {attlist} {
    global rtf_RuleAttrs rtf_RuleTable
    if {[llength $attlist] == 1} {
	global rtf_RuleTable
	if {[info exists rtf_RuleTable($attlist)]} {
	    return $rtf_RuleTable($attlist)
	} else {
	    rtf::warning "No rule style <$attlist> defined"
	    return ""
	}
    }
    set tmp(Style) Normal;	# 'Style' is mandatory; set default
    array set tmp $attlist
    return [rtf::ExpandArray rtf_RuleAttrs tmp "Style Margin Thickness Color"]
}
# Pre-defined rule styles:
rtf::ruleStyle thin	{ Style Normal  Thickness 0.75pt }
rtf::ruleStyle thick 	{ Style Normal  Thickness 1.50pt }
rtf::ruleStyle double 	{ Style Double  Thickness 0.75pt }

###
### Document-wide attributes
###
array set rtf::DocAttrs {

    PaperWidth		{dimension "paperw"}
    PaperHeight		{dimension "paperh"}
    LeftMargin		{dimension "margl"}
    RightMargin		{dimension "margr"}
    TopMargin		{dimension "margt"}
    BottomMargin	{dimension "margb"}
    DefaultTabWidth	{dimension "deftab"}

    TwoSide		{flag "facingp"}
    MirrorMargins	{flag "margmirror"}
    Landscape		{flag "landscape"}
    FirstPageNumber	{integer "pgnstart"}
    WidowControl	{flag "widowctrl"}
    GutterWidth		{dimension "gutter"}

    SaveAsRTF			{flag "defformat"}
    Protection	{enum {
    	{Forms   	"formprot"}
    	{Revisions	"revisions\\revprot"}
    	{Annotations	"annotprot"}
    	{AllProtected	"allprot"}
    }}

    Hyphenate			{boolean "hyphauto"}
    HyphenationHotZone		{dimension "hyphhotz"}
    HyphenationLadderCount	{integer "hyphconsec"}
    HyphenateAllCaps		{boolean "hyphcaps"}

    FootnoteNumbering {enum {
    	{Arabic 	"ftnnar"}
    	{LCAlpha	"ftnnalc"}
    	{UCAlpha	"ftnnauc"}
    	{LCRoman	"ftnnrlc"}
    	{UCRoman	"ftnnruc"}
    	{Chicago	"ftnnchi"}
    }}
    FootnoteLocation {enum {
	{EndOfSection	"endnotes"}
	{EndOfDocument	"enddoc"}
    }}
    FootnotePlacement {enum {
    	{PageBottom	"ftnbj"}
    	{BeneathText	"ftntj"}
    }}
    FirstFootnoteNumber	{integer "ftnstart"}
    FootnoteRestart {enum {
	{Continuous	"ftnrstcont"}
	{AtSection	"ftnrestart"}
    	{AtPage		"ftnrstpg"}
    }}
}
# Add 'papersize' document options:
set tmp {}; foreach psz {
	{ A4    	210mm	297mm	}
	{ A5    	148mm	210mm	}
	{ B5    	176mm	250mm	}
	{ Letter	8.5in	11in 	}
	{ Legal 	8.5in	14in 	}
	{ Executive	7.25in	10.5in	}
} {
    set pszn [lindex $psz 0]
    set pszw [rtf::cvTwips [lindex $psz 1]]
    set pszh [rtf::cvTwips [lindex $psz 2]]
    lappend tmp [list $pszn "paperw$pszw\\paperh$pszh"]
}
set rtf::DocAttrs(PaperSize) "enum { $tmp }"

proc rtf::documentFormat {params} {
    global rtf_DocumentFormat
    array set rtf_DocumentFormat $params
}
proc rtf::writeDocumentFormat {} {
    global rtf_DocumentFormat
    if {[info exists rtf_DocumentFormat]} {
	rtf::write [rtf::ExpandArray rtf::DocAttrs rtf_DocumentFormat]
	rtf::write " "
    }
}

###
### Information group
###
proc rtf::writeInformationGroup {} {
    global rtf_state
    # %%% fake it for now...
    rtf::bgroup
    rtf::write "\\info"
	rtf::bgroup
	rtf::write "\\doccomm Created by RATFINK/Cost"
	if {$rtf_state(docTitle) != ""} {
	    rtf::write "\\title $rtf_state(docTitle)"
	}
	rtf::egroup
    rtf::egroup
}

###
### Output
###
global rtf_fp
set rtf_fp stdout

proc rtf::write {text} {
    global rtf_fp
    puts -nonewline $rtf_fp $text
}
proc rtf::bgroup {} {
    rtf::write \{
}
proc rtf::egroup {} {
    rtf::write \}
}

# Note: 
#	In RTF, the way to get a literal "{" is with "\{".
#	In Winhelp-style RTF, though, "\{" itself is sometimes magic!
#	So, we insert some extra junk (an invisible period, \v .) after
#	each literal open-bracket to prevent HCW from misinterpreting
#	it as a WINHELP directive.
#
if {[array exists COST]} {
    substitution rtf::Escape {
	"{"	"\\{{\\v .}"
	"}"	"\\}"
	"\\"	"\\\\"
	"\t"	"\\tab "
	"\n"	" "
	"`"	"\\lquote "
	"'"	"\\rquote "
	"``"	"\\ldblquote "
	"''"	"\\rdblquote "
	"--"	"\\endash "
	"---"	"\\emdash "
    }
    substitution rtf::EscapeLineSpecific {
	"{"	"\\{{\\v .}"
	"}"	"\\}"
	"\\"	"\\\\"
	"\t"	"\\tab "
	"\n"	"\\line\n"
    }
} else {
    proc rtf::Escape {text} {
	regsub -all {[{}\\]} $text {\\&} text
	return $text
    }
}
proc rtf::text {text} {
    global rtf_state
    if {!$rtf_state(inpara) && [string length [string trim $text]]} {
    	rtf::startPara [rtf::currentParaStyle]
    }
    rtf::write [rtf::Escape $text]
}
proc rtf::insert {data} {
    global rtf_state
    if {!$rtf_state(inpara)} {rtf::startPara [rtf::currentParaStyle]}
    rtf::write $data
}

# may be overridden by applications:
proc rtf::currentParaStyle {} {
    rtf::warning "No current paragraph style defined"
    return "-"
}

array set rtfSpecial {
    Tab			"\\tab "
    LineBreak		"\\line "
    PageBreak		"\\page "
    ColumnBreak		"\\column "

    EmDash		"\\emdash "
    EnDash		"\\endash "
    EmSpace		"{\\emspace  }"
    EnSpace		"{\\enspace  }"
    Bullet		"\\bullet "

    LSQuote		"\\lquote "
    RSQuote		"\\rquote "
    LDQuote		"\\ldblquote "
    RDQuote		"\\rdblquote "

    PageNumber		"\\chpgn "
    SectionNumber	"\\sectnum "
    FootnoteNumber	"\\chftn "
}
#    Ellipsis		"{\\expndtw20 ...}" ???
# There is reportedly an ellipsis character in the Symbol character set...

#
# 
# Built-in bitmaps for Winhelp (see [DOH], p. 236)
#
array set rtfWinhelpSpecial {
    Bullet		"\\{bmct bullet.bmp\\}"
    EmDash		"\\{bmct emdash.bmp\\}"
    Shortcut		"\\{bmct shortcut.bmp\\}"
    Onestep		"\\{bmct onestep.bmp\\}"
    Open		"\\{bmct open.bmp\\}"
    Closed		"\\{bmct closed.bmp\\}"
    Document		"\\{bmct document.bmp\\}"
    Do-It		"\\{bmct do-it.bmp\\}"
    Chiclet		"\\{bmct chiclet.bmp\\}"
    PRCArrow		"\\{bmct prcarrow.bmp\\}"
}

proc rtf::special {code} {
    global rtfSpecial
    if {[info exists rtfSpecial($code)]} {
	rtf::insert $rtfSpecial($code)
    } else {
	rtf::warning "Unrecognized special <$code>"
    }
}

proc rtf::tab {} 	{ rtf::write "\\tab " }
proc rtf::lineBreak {} 	{ rtf::write "\\line " }
proc rtf::pageBreak {} 	{ rtf::write "\\page " }
proc rtf::columnBreak {}	{ rtf::write "\\column " }

###
### Document structure
###

global rtf_state
array set rtf_state {
    inpara	0
    insection	0
    intable	0
    inrow	0
    incell	0
    cellno	0
    diversion	""

    winhelpMode		0
    docTitle		""
    outputFile		{}
    contentsFile	{}
    tocfp		{}
    toclevel		1
    browseseq		""
    topicno		0
    currentTopic	""

    intopic		0
    inlink		0
}

proc rtf::start {} {
    global rtf_state rtf_fp
    fconfigure $rtf_fp -buffering full
    if {$rtf_state(outputFile) != ""} {
    	set rtf_fp [open $rtf_state(outputFile) w]
	fconfigure $rtf_fp -buffering full
    }
    if {$rtf_state(winhelpMode)} { rtf::startContentsFile }

    rtf::bgroup
# Header:
    rtf::write "\\rtf1\\ansi\\deff0"
    rtf::writeFontTable
    #- fileTable
    rtf::writeColorTable
    rtf::writeStyleSheet
    #- revisionTable
# Document:
    rtf::writeInformationGroup
    rtf::writeDocumentFormat
# section text follows...
}
proc rtf::end {} {
    global rtf_state rtf_fp
    rtf::egroup
    if {$rtf_state(outputFile) != ""} {
    	close $rtf_fp
    }
    if {$rtf_state(winhelpMode)} {
    	rtf::endContentsFile
    }
}

proc rtf::startSection {{style -}} {
    global rtf_state rtf_styleSheet
    rtf::endSection
    rtf::write "\\sectd"
    if {$style != "-"} {
	if {![info exists rtf_styleSheet($style,DEF)] \
		|| $rtf_styleSheet($style,TYPE) != "SECT"} {
	    rtf::warning "Style <$style> not a section style"
	} else {
	    rtf::write $rtf_styleSheet($style,DEF)
	}
	rtf::write " "
    }
    set rtf_state(insection) 1
}
proc rtf::endSection {} {
    global rtf_state
    if {$rtf_state(insection)} {
	rtf::write "\\sect "
    }
    set rtf_state(insection) 0
}

proc rtf::startPara {style} {
    global rtf_styleSheet rtf_state
    if {$rtf_state(inpara)} { rtf::endPara }
    rtf::write "\\pard\\plain "
    if {$rtf_state(intable)} { rtf::write "\\intbl " }
    if {[info exists rtf_styleSheet($style,DEF)]} {
	if {$rtf_styleSheet($style,TYPE) != "PARA"} {
	    rtf::warning "$style not a paragraph style"
	} else {
	    rtf::write "\\s$rtf_styleSheet($style,NUM)"
	}
	rtf::write "$rtf_styleSheet($style,DEF) "
    } elseif {$style != "-"} {
	rtf::undefined style $style
    }
    set rtf_state(inpara) 1
}
proc rtf::endPara {} {
    global rtf_state
    if {$rtf_state(inpara)} {
	rtf::write "\\par\n"
    }
    set rtf_state(inpara) 0
}

proc rtf::startPhrase {style} {
    rtf::bgroup
    rtf::setCharStyle $style
}
proc rtf::endPhrase {} {
    rtf::egroup
}

proc rtf::setCharStyle {style} {
    global rtf_styleSheet rtf_state
    if {!$rtf_state(inpara)} { rtf::startPara [rtf::currentParaStyle] }
    if {[info exists rtf_styleSheet($style,DEF)]} {
	if {$rtf_styleSheet($style,TYPE) != "CHAR"} {
	    rtf::warning "$style not a character style"
	} else {
	    rtf::write "\\cs$rtf_styleSheet($style,NUM)"
	}
	rtf::write "$rtf_styleSheet($style,DEF) "
    } else {
	rtf::warning "No definition for character style <$style>"
    }
}

###
### Tables
###

#
# Different ways to specify number and widths of columns:
#
#  + number of columns and total width (equal-sized columns)
#  + list of relative widths and total width
#  + list of absolute widths
# 
proc rtf::tableRelativeWidths {colwidths} {
    global rtf_tableSettings rtf_cellPositions
    set tablewidth [rtf::cvTwips $rtf_tableSettings(width)]
    set sumwidths 0
    foreach colwidth $colwidths { incr sumwidths $colwidth }
    set colend 0
    set colnum 0
    foreach colwidth $colwidths {
	incr colend [expr round(($tablewidth*$colwidth)/$sumwidths)]
	incr colnum
	set rtf_cellPositions($colnum) $colend
    }
    set rtf_tableSettings(numcols) $colnum
}

proc rtf::TableAbsoluteWidths {colwidths} {
    global rtf_tableSettings rtf_cellPositions
    set colend 0
    set colnum 0
    foreach colwidth $colwidths {
	incr colend [rtf::cvTwips $colwidth]
	incr colnum
	set rtf_cellPositions($colnum) $colend
    }
    set rtf_tableSettings(width) $colend
    set rtf_tableSettings(numcols) $colnum
}

proc rtf::TableEqualWidths {numcols} {
    global rtf_tableSettings rtf_cellPositions
    set rtf_tableSettings(numcols) $numcols
    set tablewidth [rtf::cvTwips $rtf_tableSettings(width)]
    set colnum 0
    while {$colnum < $numcols} {
	incr colnum
	set rtf_cellPositions($colnum) \
		[expr round($tablewidth*$colnum/$numcols)]
    }
}

proc rtf::startTable {args} {
    global rtf_state rtf_tableSettings rtf_tableDefaults
    if {$rtf_state(intable)} {
	rtf::warning "Already in table"
	return;
    }
    array set rtf_tableSettings [array get rtf_tableDefaults]
    catch {unset rtf_cellPositions}
    set option ""
    foreach arg $args {
	if {$option == ""} { set option $arg; continue; }
	switch -- $option {
	    -width	{ set rtf_tableSettings(width) $arg }
	    -align	{ set rtf_tableSettings(rowalign) $arg }
	    -numcols 	{ rtf::TableEqualWidths $arg }
	    -relwidths	{ rtf::TableRelativeWidths $arg }
	    -abswidths	{ rtf::TableAbsoluteWidths $arg }
	    -toprule 	{ set rtf_tableSettings(toprule) $arg }
	    -colsep 	{ set rtf_tableSettings(colsep) $arg }
	    -rowsep 	{ set rtf_tableSettings(rowsep) $arg }
	    -frame 	{ set rtf_tableSettings(frame) $arg
			  set rtf_tableSettings(toprule) $arg }
	    default { rtf::warning "rtf::startTable: bad option $option" }
	}
	set option ""
    }
    if {$option != ""} {
	rtf::warning "rtf::startTable: no argument for option $option"
    }
    set rtf_tableSettings(botrule) $rtf_tableSettings(rowsep)
    array set rtf_state { intable 1  inrow 0  incell 0  cellno 0 }
}

proc rtf::startRow {args} {
    global rtf_state rtf_tableSettings

    if {!$rtf_state(intable)} {
	rtf::warning "Not in a table"
    }
    if {$rtf_state(inrow)} { rtf::endRow }

    set isheading 0
    set colspans ""
    set option ""
    foreach arg $args {
	if {$option == ""} { set option $arg; continue; }
	switch -- $option {
	    -colspans	{ set colspans $arg }
	    -toprule 	{ set rtf_tableSettings(toprule) $arg }
	    -botrule 	{ set rtf_tableSettings(botrule) $arg }
	    -colsep 	{ set rtf_tableSettings(colsep) $arg }
	    -heading	{ set isheading $arg }
	    default	{
		rtf::warning "rtf::startRow: bad option $option" 
	    }
	}
	set option ""
    }
    if {$option != ""} {
	rtf::warning "rtf::startRow: no argument for option $option"
    }

    set rowatts [list \
	RowGap	$rtf_tableSettings(rowgap) \
	Align	$rtf_tableSettings(rowalign) ]
    if {$isheading} {
	lappend rowatts HeadingRow $isheading
    }
    rtf::write "\\trowd[rtf::ExpandAttributes rtf::TableAttrs $rowatts]\n"

    if {$colspans != ""} {
	set rtf_tableSettings(numcells) [llength $colspans]
	set colno 1
	foreach span $colspans {
	    rtf::cellDef $colno $span
	    incr colno $span
	}
    } else {
	set rtf_tableSettings(numcells) $rtf_tableSettings(numcols)
	for {set colno 1} {$colno <= $rtf_tableSettings(numcols)} {incr colno} {
	    rtf::cellDef $colno
	}
    }
    rtf::write "\n"
    array set rtf_state { inrow 1 incell 0 cellno 0 }
}

proc rtf::cellDef {colno {span 1}} {
    global rtf_tableSettings rtf_cellPositions
    set start $colno
    set end [expr $colno + $span - 1]
    if {$end > $rtf_tableSettings(numcols)} {
	rtf::warning "Cell spans too many columns"
	return
    }
    if {$start == 1} {
	set border(Left) $rtf_tableSettings(frame) 
    } else {
	set border(Left) $rtf_tableSettings(colsep) 
    }
    if {$end == $rtf_tableSettings(numcols)} {
	set border(Right) $rtf_tableSettings(frame) 
    } else { 
	set border(Right) $rtf_tableSettings(colsep)
    }
    set border(Top)   	$rtf_tableSettings(toprule)
    set border(Bottom)	$rtf_tableSettings(botrule)
    set cellAtts {}
    foreach b {Top Bottom Left Right} {
	if {$border($b) != "-"} {
	    lappend cellAtts "CellBorder$b" $border($b)
	}
    }
    # cellx must be last
    lappend cellAtts CellPosition $rtf_cellPositions($end)
    rtf::write [rtf::ExpandAttributes rtf::TableAttrs $cellAtts]
}

# ... need to distinguish between cells which contain paragraphs
# ... and those which only contain inline stuff;
# ... for the latter apply paragraph properties when the cell starts

proc rtf::startCell {{style -}} {
    global rtf_state
    if {$rtf_state(incell)} { rtf::endCell }
    set rtf_state(incell) 1
    incr rtf_state(cellno)
    rtf::startPara $style
}
proc rtf::endCell {} {
    global rtf_state
    if {!$rtf_state(incell)} { rtf::warning "Not in a cell"; return }
    rtf::write "\\cell\n"
    array set rtf_state { inpara 0 incell 0 }
}

proc rtf::endRow {} {
    global rtf_state rtf_tableSettings
    if {!$rtf_state(inrow)} {
	rtf::warning "Not in a table row"
	return
    }
    if {$rtf_state(incell)} rtf::endCell
    if {$rtf_state(cellno) != $rtf_tableSettings(numcells)} {
	rtf::warning \
	    "$rtf_state(cellno) cells; should be $rtf_tableSettings(numcells)"
    }
    rtf::write "\\row\n"
    set rtf_state(inrow) 0
    set rtf_tableSettings(toprule) $rtf_tableSettings(botrule)
    set rtf_tableSettings(botrule) $rtf_tableSettings(rowsep)
}

proc rtf::endTable {} {
    global rtf_state
    if {!$rtf_state(intable)} {
	rtf::warning "Not in a table"
	return
    }
    if {$rtf_state(inrow)} { rtf::endRow }
    # without this, Word sometimes crashes...
    rtf::write "\\pard\\par\n"
    set rtf_state(intable) 0
}

###
### Bookmarks
###

proc rtf::startBookmark {name} {
    rtf::bgroup
    rtf::write "{\\*\\bkmkstart $name}"
    rtf::egroup
}

proc rtf::endBookmark {name} {
    rtf::bgroup
    rtf::write "{\\*\\bkmkend $name}"
    rtf::egroup
}

###
### Fields
###

proc rtf::startField {inst} {
    rtf::bgroup
	rtf::write "\\field"
	rtf::bgroup
	    rtf::write "\\*\\fldinst "
	    rtf::write [rtf::Escape $inst]
	rtf::egroup
	rtf::bgroup
	    rtf::write "\\fldrslt "
}
proc rtf::endField {} {
	rtf::egroup
    rtf::egroup
}
proc rtf::insertField {inst {rslt ""}} {
  rtf::write \
    "{\\field{\\*\\fldinst [rtf::Escape $inst]}{\\fldrslt [rtf::Escape $rslt]}}"
}
# %%% note: syntax productions in spec disagree with examples,
# %%% what Word actually does, and common sense.

###
### Destination groups
###
array set rtf_Destinations {
    Header		"header"
    LeftHeader		"headerl"
    RightHeader 	"headerr"
    FirstPageHeader	"headerf"
    Footer		"footer"
    FirstPageFooter	"footerf"
    LeftFooter  	"footerl"
    RightFooter  	"footerr"
    Footnote		"footnote"
    Endnote		"footnote\\ftnalt"
}
# %%% Should stack diversions, current state &c;
# %%% NB: For RTF magic footnotes, use rtf::magicFootnote instead;
# %%% the Winhelp compiler doesn't like the "\*" control sequence.
#
proc rtf::divert {diversion} {
    global rtf_state rtf_Destinations rtf_savedState
    if {$rtf_state(diversion) != ""} {
	rtf::warning "Diversion $diversion within $rtf_state(diversion)"
    }
    if {![info exists rtf_Destinations($diversion)]} {
	rtf::warning "Bad destination $diversion"
	return
    }
    rtf::bgroup
    rtf::write "\\*\\$rtf_Destinations($diversion) "
    array set rtf_savedState [array get rtf_state]
    array set rtf_state {inpara 0 insection 0 incell 0 inrow 0 intable 0}
    set rtf_state(diversion) $diversion
    return
}

proc rtf::undivert {} {
    global rtf_state rtf_savedState
    if {$rtf_state(diversion) == ""} {
	rtf::warning "No current diversion"
	return
    }
    rtf::egroup
    array set rtf_state [array get rtf_savedState]
    unset rtf_savedState
    set rtf_state(diversion) ""
    return;
}

###
### Winhelp stuff:
###
#
# Useful reference:
# 	[DOH]	"Developing Online Help for Windows 95",
#		Scott Boggan, David Farkas, and Joe Welinske
#

# rtf::winhelpMode --
#	Sets things up for generating WINHELP-style RTF.
#	Call this before defining any stylesheet entries.
#
proc rtf::winhelpMode {args} {
    global rtf_state
    if {$rtf_state(winhelpMode)} {
    	# already set
	return
    }
    set rtf_state(winhelpMode) 1
    #
    # Remove unsupported CharAttrs, ParaAttrs, and SectAttrs entries:
    # %%% Missing quite a few ...
    #
    global rtf::CharAttrs rtf::ParaAttrs rtf::SectAttrs
    foreach {old new} {
	KeepWithNext	Banner
    	KeepTogether 	NoWrap
    } {
	set rtf::ParaAttrs($new) [ set rtf::ParaAttrs($old)]
	unset rtf::ParaAttrs($old)
    }
    unset rtf::SectAttrs
    proc ::rtf::SectStyle {args} { 
    	rtf::warning "rtf::SectStyle can't be used in WINHELP mode"
    }
    #
    # Add WINHELP-specific special characters:
    #
    global rtfSpecial rtfWinhelpSpecial
    array set rtfSpecial [array get rtfWinhelpSpecial]
    # %%% TODO: disable rtf::pageBreak, other stuff that shouldn't
    # %%% appear in WINHELP-format RTF.
}

# rtf::winhelpOnly -- 
#	Internal utility.  Make sure we're in Winhelp mode 
#
proc rtf::winhelpOnly {{msg ""}} {
    global rtf_state
    if {!$rtf_state(winhelpMode)} { error "must be in Winhelp mode: $msg" }
}

###
### WINHELP "magic footnotes":
###
array set rtf_magicFootnotes {
    topicID 	#
    title   	$
    browseseq	+
    keyword	K
    alink	A
    comment	@
    helpmacro	!
    windowType	>
}
proc rtf::magicFootnote {key value} {
    global rtf_magicFootnotes
    rtf::write $rtf_magicFootnotes($key)
    rtf::divert Footnote
    rtf::write $value
    rtf::undivert
}

proc rtf::startBrowseSequence {bsname} {
    global rtf_state
    rtf::winhelpOnly rtf::StartBrowseSequence
    if {![info exists rtf_state(bs.$bsname.seqno)]} {
    	set rtf_state(bs.$bsname.seqno) 0
    }
    if {$rtf_state(browseseq) != ""} {
    	rtf::warning "Cannot nest browse sequences 
		($rtf_state(browseseq)) in $bsname"
    }
    set rtf_state(browseseq) $bsname
}

proc rtf::endBrowseSequence {} {
    global rtf_state
    set rtf_state(browseseq) ""
}

#
# rtf::startTopic --
# 	%%% Document me
# 	%%% "keywords" (K footnotes) are really more like "index entries"
#	%%% "A footnotes" are more like "keywords"
#
proc rtf::startTopic {args} {
    global rtf_state

    incr rtf_state(topicno)
    array set pageOpts {
	id		""
    	title		""
	keywords	{}
	tocentry	1
	windowType	{}
    }
    set pageOpts(browseseq)	"$rtf_state(browseseq)"
    foreach {option value} $args {
    	switch -- $option {
	    -topicID	{ set pageOpts(id) $value }
	    -title	{ set pageOpts(title) $value }
	    -keyword	{ lappend pageOpts(keywords) $value }
	    -keywords	{
	    	set pageOpts(keywords) [concat $pageOpts(keywords) $value]
	    }
	    -browseSequence	{ set pageOpts(browseseq) $value }
	    -windowType	{ set pageOpts(windowType) $value }
	    default	{
	    	error "Unrecognized option $option"
	    }
	}
    }
    if {$pageOpts(id) == ""} {
	set pageOpts(id) "TOPIC$rtf_state(topicno)"
    }

    set bsname $pageOpts(browseseq)
    if {$bsname != ""} {
	if {![info exists rtf_state(bs.$bsname.seqno)]} {
	    # %%% rtf::startBrowseSequence; end at end
	    set rtf_state(bs.$bsname.seqno) 0
	}
	set bseqno [incr rtf_state(bs.$bsname.seqno)]
    }

    # Make sure we're not in the middle of anything else...
    #
    if {$rtf_state(inpara)} { rtf::endPara }
    if {$rtf_state(intopic)} { rtf::endTopic }

    # Generate topic header:
    #
    rtf::pageBreak
    rtf::magicFootnote topicID $pageOpts(id)
    if {$pageOpts(title) != ""} { rtf::magicFootnote title $pageOpts(title) }
    if {$pageOpts(windowType) != ""} { 
    	rtf::magicFootnote windowType $pageOpts(windowType)
    }
    foreach kw $pageOpts(keywords) { rtf::magicFootnote keyword $kw }
    #if {[llength $pageOpts(keywords)] != 0} {
    #	set keywordSep ";"
    #	rtf::magicFootnote keyword [join $pageOpts(keywords) $keywordSep]
    #}
    if {$bsname != ""} {
    	rtf::magicFootnote browseseq "$bsname:[format %05d $bseqno]"
    }

    # Add contents line:
    #
    if {$pageOpts(tocentry)} {
    	set linkTarget $pageOpts(id)
	if {$pageOpts(windowType) != ""} {
	    append linkTarget ">$pageOpts(windowType)" 
	}
    	rtf::contentsLine $pageOpts(title) $linkTarget
    }
    set rtf_state(intopic) 1
    set rtf_state(currentTopic) $pageOpts(id)
}

proc rtf::endTopic {} {
    global rtf_state
    if {$rtf_state(inlink)} { rtf::warning "Topic ended inside a link" }
    set rtf_state(intopic) 0
    set rtf_state(currentTopic) ""
}

proc rtf::currentTopic {} { return $::rtf_state(currentTopic) }

#
# startLink/endLink 
# %%% TODO: keep track of defined/referenced topics, make sure they match.
# %%% TODO: handle pop-up targets, other target types (ALINK,secondary win,&c)
# %%% Possibly: call this startJump for consistency w/WINHELP docs.
#
# WINHELP-RTF syntax for link targets:
#	['%'|'*']? ( topicID ['@' helpFile ]? ['>' targetWindow]?
#		    | '!' helpMacro )
#	'*' at beginning of target spec makes link text appear in normal color,
#	'%' does the same and also removes underlining.
#
# As a special case, if the link target starts with '^',
# rtf::startLink generates a pop-up link.  (In WINHELP-RTF,
# this is specified by single-underlining the link text).
#
# rtf::startKLink is like rtf::startLink, but it makes a keyword-link instead.
#
proc rtf::startLink {linkTarget} {
    global rtf_state
    rtf::winhelpOnly
    if { $rtf_state(inlink) } { rtf::warning "Nested link!" }
    if {[string match "^*" $linkTarget]} {
	# Pop-up link
    	set ulstyle Single
	set linkTarget [string range $linkTarget 1 end]
    } else {
	# Normal link
	set ulstyle Double
    }
    rtf::bgroup
    rtf::write "[rtf::ExpandAttributes rtf::CharAttrs [list Underline $ulstyle ]] "
    set rtf_state(LinkTarget) $linkTarget
    set rtf_state(inlink) 1
}

proc rtf::startKLink {keyword} {
    global rtf_state
    rtf::winhelpOnly
    if { $rtf_state(inlink) } { rtf::warning "Nested link!" }
    rtf::bgroup
    rtf::write "[rtf::ExpandAttributes rtf::CharAttrs [list Underline Double]] "
    set rtf_state(LinkTarget) "!KLink($keyword)"
    set rtf_state(inlink) 1
}

proc rtf::endLink {} {
    global rtf_state
    rtf::egroup
    rtf::bgroup
    rtf::write "[rtf::ExpandAttributes rtf::CharAttrs { Hidden 1 }] "
    rtf::write $rtf_state(LinkTarget)
    rtf::egroup
    unset rtf_state(LinkTarget)
    set rtf_state(inlink) 0
}

# rtf::uriLink uri --
#	Returns a link target (suitable for rtf::startLink)
#	that references the specified URI.
#
proc rtf::uriLink {uri} {
    return "!ExecFile(`$uri',,0,)"
    # "!ShellExecute($uri)" is supposed to work, but doesn't
}

# rtf::button label macro1 ... macroN
#	Generates an in-line pushbutton with label "label"
#	that invokes Winhelp macros macro1 ... macroN.
#	If "label" is empty, generates a square, blank button.
#	See [DOH], pp.290-292.
#
proc rtf::button {label args} {
    rtf::winhelpOnly
    rtf::write "\\{button [rtf::Escape $label],[join $args :]\\}"
}

###
### Winhelp contents file:
###
proc rtf::startContentsFile {} {
    global rtf_state
    if {!$rtf_state(winhelpMode) || $rtf_state(contentsFile) == ""} {
    	return
    }
    set fp [open $rtf_state(contentsFile) w]
    if {$rtf_state(docTitle) != ""} {
    	puts $fp ":TITLE $rtf_state(docTitle)"
	# %%% Default: specified in .HPJ file
    }
    # %%% this is not quite right...
    set helpFilename "[file tail [file rootname $rtf_state(contentsFile)]].HLP"
    puts $fp ":BASE $helpFilename"
    set rtf_state(tocfp) $fp
}
proc rtf::endContentsFile {} {
    global rtf_state
    if {$rtf_state(contentsFile) != ""} {
	close $rtf_state(tocfp)
    }
}
proc rtf::contentsLine {title {linkTarget ""}} {
    global rtf_state
    rtf::winhelpOnly "rtf::contentsLine"
    set fp $rtf_state(tocfp)
    if {$fp == ""} { return }
    regsub -all {\n} $title " " title
    if {[string match "^*" $linkTarget]} {
	rtf::warning "Pop-up window referenced in table of contents"
	set linkTarget [string range $linkTarget 1 end]
    }
    if {$linkTarget != ""} {
	puts $fp "$rtf_state(toclevel) $title=$linkTarget"
    } else {
	puts $fp "$rtf_state(toclevel) $title"
    }
}
proc rtf::contentsLevel {n} {
    global rtf_state
    incr rtf_state(toclevel) $n
}


###
### RATFINK configuration options:
###
proc rtf::configure {args} {
    global rtf_state
    foreach {option value} $args {
    	switch -- $option {
	    -outputFile		{ set rtf_state(outputFile) $value }
	    -contentsFile	{ set rtf_state(contentsFile) $value }
	    -mapFile		{ rtf::warning "-mapFile not yet implemented" }
	    -docTitle		{ set rtf_state(docTitle) $value }
	    default {
	    	error "Unrecognized option $option = $value"
	    }
	}
    }
}

#*EOF*
