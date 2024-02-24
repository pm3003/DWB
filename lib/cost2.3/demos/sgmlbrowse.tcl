#! wish8.0
############################################################
# $Id: sgmlbrowse.tcl,v 1.7 1999/07/31 01:46:11 joe Exp $
# Cost demo program -- browse SGML/XML document hierarchy
# Created: 4 Feb 1999
############################################################
#
# TODO:
#	+ either insert nl both after EStag and before SEtag or neither
#	+ don't display text if child nodes are pruned
#	+ arrow keys -- use Windows Explorer behaviour for fold/unfold
#	+ load/save/edit stylesheets (+save as CSS/XSL?)
#	+ export to Brian Oakley's "text dump" format
#		(needs to be batch-processable as well)
#	+ support for hyperlinks
#	+ use Tcl namespaces
#	+ add online help
#	+ add text search feature, with next/prev buttons
#	+ add query feature (highlight elements), with next/prev buttons
#
# This is meant to be hacked.
#

package require Tk 8.0
package require Cost 2.2

option add *Scrollbar.takeFocus 0
option add *Entry.background	white
option add *Text.background	white

# Debugging aids:
#
# 	Alt-Shift-R reloads the current script.
#	Control-Alt-Shift C-T fires up a TkCon console.
#	Control-L refreshes the display in case it gets messed up.
#
bind all <Control-Key-l> 	{ sdb:Preview }
bind all <Alt-Shift-Key-R> 	[list source [info script]]
bind all {<Control-Alt-Shift-Key-C> <Control-Alt-Shift-Key-T>} \
	{ set argv {}; source [file dirname [info library]]/tkcon.tcl }

############################################################
# Low-level utilities:
############################################################
#
#  withBusyCursor { cmds ... }
#
#	Changes the cursor (of every window in the application)
#	to a watch, evaluates 'cmds', then restores the cursor.
#
#  Source: busy.tcl, Revision: 1.7
#
proc withBusyCursor {cmd} {
    global errorInfo errorCode
    set busy {}
    set list {.}
    while {$list != ""} {
        set next {}
        foreach w $list {
            catch {set cursor [$w cget -cursor]}
            if {[winfo toplevel $w] == $w || $cursor != ""} {
                lappend busy $w $cursor
		set cursor {}
            }
            set next [concat $next [winfo children $w]]
        }
        set list $next
    }
    foreach {w _} $busy {
        catch {$w configure -cursor watch}
    }
    update ;# idletasks
    set rc [catch {uplevel 1 $cmd} result]
    set ei $errorInfo
    set ec $errorCode
    foreach {w cursor} $busy {
        catch {$w configure -cursor $cursor}
    }
    return -code $rc -errorinfo $ei -errorcode $ec $result
}

# makeScrolledText w --
#	Creates a text widget, adds scrollbars, hooks them together,
#	and handles layout.
#
#	Returns: name of the new text widget.
#	    This will be $w.t; the widget $w is actually a container.
#
proc makeScrolledText {w} {
    frame $w
    scrollbar $w.h -orient horizontal -command [list $w.t xview]
    scrollbar $w.v -orient vertical -command [list $w.t yview]
    text $w.t \
	    -yscrollcommand [list $w.v set] \
	    -xscrollcommand [list $w.h set]
    grid $w.t $w.v	-sticky news
    grid $w.h		-sticky news
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1
    return $w.t
}

# makeMenu parentMenu menuLabel --
#	Creates a submenu (cascade entry) of $parentMenu
#	with label $menuLabel, and associated resources.
#	If $menuLabel contains an '&', the next character is
#	used as the mnemonic (e.g., "&File", "E&xit").
#
#	Returns: new child menu.
#
proc makeMenu {m label} {
    set underline [string first & $label]
    regsub -all "&" $label "" label
    set name [string tolower $label]
    regsub -all {[^a-z]} $name {} name
    set submenu [menu $m.${name}Menu -tearoff false]
    $m add cascade -label $label -underline $underline -menu $submenu
    return $submenu
}

# findMark W x y pattern --
#    %W is a text widget; %x and %y are window coordinates;
#    $pattern is a glob-style pattern.
#
#    Returns the closest mark at or before position @$x,$y
#    whose name matches $pattern, or "" if none found.
#
#    (This is useful in <ButtonPress> bindings)
#
proc findMark {W x y pattern} {
    $W mark set clicked [$W index @$x,$y]
    for {set m clicked} {$m != ""} {set m [$W mark previous $m]} {
	if {[string match $pattern $m]} { break }
    }
    return $m
}

# incr! var --
#	Just like [incr var], but sets 'var' to 1 if it does
#	not already exist.
#
proc incr! {var} {
    upvar 1 $var v
    if {[info exists v]} { incr v } { set v 1 }
}

############################################################
# Application data:
############################################################

global SDB
array set SDB {
    showTags		1
    showAttributes	0
    showText		0

    currentFile		{}
    status 		"SGML Browser"
    newline		0
    neednl		0

    outputWidget	-
    currentElement	-
    currentTag  	-
    FileTypes		{
			    {XML  {.xml}}
			    {SGML {.sgml .sgm .htm .html .doc}}
			    {ESIS {.esis}}
			}
}

### Output routines:
#
proc sdb:Status {msg} {
    global SDB
    set SDB(status) $msg
}

proc sdb:Output {text {tags {}}} {
    global SDB
    $SDB(outputWidget) insert insert $text $tags
    set SDB(newline) [string match "*\n*" $text]
}

proc sdb:Mark {markName} {
    global SDB
    $SDB(outputWidget) mark set $markName insert
    $SDB(outputWidget) mark gravity $markName left
}

proc sdb:ClearOutput {} {
    global SDB
    set t $SDB(outputWidget)
    $t delete 1.0 end
    set SDB(newline) 1
}

proc sdb:Newline {} {
    global SDB
    if {!$SDB(newline)} { $SDB(outputWidget) insert insert "\n" }
    array set SDB { newline 1 neednl 0 }
}

proc sdb:NeedNewline {} {
    global SDB
    set SDB(neednl) 1
}
proc sdb:Indent {indent} {
    global SDB
    for {set tabs ""; set i 0} {$i < $indent} {incr i} {append tabs "\t"}
    $SDB(outputWidget) insert insert  $tabs
}

### Main window
#

proc sdb:MainWindow {} {
global SDB
set w .top
catch {destroy $w} ; toplevel $w

set menubar [menu $w.menubar]
$w configure -menu $menubar

set fileMenu [makeMenu $menubar "&File" ]
set viewMenu [makeMenu $menubar "&View" ]
set toolMenu [makeMenu $menubar "&Tools" ]

$fileMenu add command -label "Open..."		-command sdb:OpenDialog
$fileMenu add command -label "Reload"		-command sdb:ReloadFile
$fileMenu add separator
$fileMenu add command -label "Fold"		-command sdb:FoldElement \
						-accelerator ^F
$fileMenu add command -label "Unfold"		-command sdb:UnfoldElement \
						-accelerator ^U
$fileMenu add command -label "Unroll"		-command sdb:UnrollElement \
						-accelerator ^R
$fileMenu add separator
$fileMenu add command -label Exit		-command { destroy . }

$toolMenu add command -label "Analyze..."	-command sdb:Analyze
$toolMenu add command -label "Query..."		-command sdb:QueryDialog

$viewMenu add checkbutton -label "Show Attributes" \
	-variable SDB(showAttributes) -command sdb:Preview
$viewMenu add checkbutton -label "Show Text" \
	-variable SDB(showText) -command sdb:Preview

bind $w <Control-Key-u>	{ sdb:UnfoldElement; break }
bind $w <Control-Key-f>	{ sdb:FoldElement; break }
bind $w <Control-Key-r>	{ sdb:UnrollElement; break }

bind $w <Key-Down>	{ sdb:Move {child forward} 0; break }
bind $w <Control-Key-Down>	{ sdb:Move {next forward child} 0; break }
bind $w <Control-Key-Up>	{ sdb:Move {prev parent} 0; break }
bind $w <Key-Up>	{ sdb:Move backward 0; break }
bind $w <Key-Left>	{ sdb:Move parent; break }
bind $w <Key-Right>	{ sdb:Move {child forward} 1; break }
bind $w <Shift-Key-Left> \
			{ sdb:FoldElement; sdb:Move parent; break }
bind $w <Control-Shift-Key-Left> \
			{ sdb:Move parent; sdb:FoldElement; break }

set SDB(outputWidget) [makeScrolledText $w.view]

frame $w.status
label $w.status.dummy -text "STATUS" -textvariable SDB(status)
pack $w.status.dummy

pack $w.status -side bottom -expand false -fill x
pack $w.view -side top -expand true -fill both

### Configure text widget:
#

set t $SDB(outputWidget)

$t configure -background white -wrap word -exportselection false
$t configure -tabs 0.15i

$t tag configure hilite -background #FFFF00

$t tag configure tag		-foreground #5F0000 -lmargin1 0   -lmargin2 300
$t tag configure attname	-foreground #00005F
$t tag configure attval 	-foreground #005F00
$t tag configure sdata 		-foreground #FF0000
$t tag configure pi  		-foreground #FF0000
$t tag configure text 		-foreground #5F005F -background #EEEEEE \
				-lmargin1 100 -lmargin2 100 -justify left

#
# Text tags: ought to have ranked tags based on depth,
# with different -lmargin1 & -lmargin2.
#

# %%% Not sure which is the best event to do this in...
#
bind $t <ButtonPress-1> { if {[sdb:Click %W %x %y]} break }
$t tag bind tag <ButtonPress-1> { if {[sdb:Click %W %x %y]} break }
$t tag bind tag <ButtonRelease-1> { if {[sdb:Click %W %x %y]} break }


return $w
}

proc sdb:Click {W x y} {
    set m [findMark $W $x $y {[SE][SE].*:*}]
    if {$m != ""} {
	sdb:SelectTag [string range $m 1 end]
	return 1
    }
    return 0
}

### Main utilities:
#
# sdb:OpenFile --
# 	File|Open dialog box.
# sdb:LoadFile --
#	Loads the file.
# sdb:ReloadFile
#	Re-reads last file opened.
#

proc sdb:OpenDialog {} {
    global SDB
    set filename [tk_getOpenFile -filetypes $SDB(FileTypes)]
    if {$filename != ""} { sdb:LoadFile $filename }
}
proc sdb:LoadFile {filename} {
    global SDB
    # Guess file type based on extension:
    set fileType SGML		;# default
    set extension [string tolower [file extension $filename]]
    # %%% ARGH!  'eval concat $SDB(FileTypes) doesn't work, due to \n s.
    foreach {type extlist} [join $SDB(FileTypes) " "] {
    	if {[lsearch -exact $extlist $extension] != -1} {
	    set fileType $type
	    break
	}
    }
    # Load file:
    switch $fileType {
    	SGML	{ loaddoc $filename }
    	XML	{ loadxmldoc $filename }
    	ESIS	{ loadfile $filename }
	default	{ error "Can't cope with file type $extension" }
    }
    # Display file:
    wm title .top [file tail $filename]
    sdb:Status "Loaded $filename"
    set SDB(currentFile) $filename
    foreachNode doctree el { setprop visible 0 }
    foreachNode docroot child el { setprop visible 1 }
    foreachNode docroot child child el { setprop visible 1 }
    foreachNode doctree pel {
	if {[string match "*\n*" [content]]} { setprop hasRE 1 } 
    }
    foreachNode doctree re { setprop hasRE 1 }
    # %%% for loadxml (no REs or PELs %%%)
    foreachNode doctree cdata {
	if {[string match "*\n*" [q content]]} { setprop hasRE 1 } 
    }
    array set SDB {
    	showTags 	1
	showAttributes	0
	showText	0
    }
    sdb:Preview
}
proc sdb:ReloadFile {} {
    global SDB
    if {$SDB(currentFile) == ""} { sdb:OpenDialog }
    sdb:LoadFile $SDB(currentFile)
}

############################################################
# ...
############################################################

environment sdbEnv {
    visible	1
}

substitution sdb:cdataFilter {
    "\n"	" "
}

eventHandler sdb:PreviewHandler -global {
    START {
	sdbEnv save
	if {[q? hasprop visible]} {
	    sdbEnv set visible [q propval visible]
	}
	if {[sdbEnv get visible] && $SDB(showTags)} {
	    sdb:Newline
	    sdb:Indent $sdbIndent
	    sdb:Mark "SS.[q address]"
	    sdb:Output "<[query gi]" tag
	    if {$SDB(showAttributes)} {
		# %%% need to escape attval
		foreachNode attlist {
		    if {![q? parent hasatt [q attname]]} { continue }
		    sdb:Output " [q attname]="  {tag attname}
		    sdb:Output "\"[q content]\"" {tag attval}
		}
	    }
	    if {[query? child]} {
		sdb:Output ">" tag
		sdb:Mark "ES.[q address]"
	    } else {
		sdb:Mark "SE.[q address]"
		sdb:Output "/>" tag
		sdb:Mark "ES.[q address]"
		sdb:Mark "EE.[q address]"
		sdb:Newline
	    }
	    if {$SDB(showText) && [query? child withpropval hasRE 1]} {
		sdb:Newline
	    }
	}
	incr sdbIndent
    }
    END {
	incr sdbIndent -1
	if {[sdbEnv get visible] && $SDB(showTags) && [query? child]} {
	    if {$SDB(neednl)} { sdb:Newline }
	    if {$SDB(newline)} { sdb:Indent $sdbIndent }
	    sdb:Mark "SE.[q address]"
	    sdb:Output "</[query gi]>" tag
	    sdb:Mark "EE.[q address]"
	    sdb:Newline
	}
	sdbEnv restore
    }
    CDATA {
	if {    $SDB(showText)
	     && [sdbEnv get visible]
	} {
	    sdb:Output [sdb:cdataFilter [q content]] text
	    if {[q? withpropval hasRE 1]} { sdb:NeedNewline }
	    # %%% Factor this:
	    if {![incr sdbPreviewTick -1]} {
		update idletasks
		set sdbPreviewTick 100
	    }
	}
    }
    RE {
	if {[sdbEnv get visible] && $SDB(showText)} {
	    sdb:NeedNewline;	# Not exactly ...
	    sdb:Output " " text
	}
    }
    SDATA {
	if {[sdbEnv get visible] && $SDB(showText)} {
	    sdb:Output [q content] sdata
	}
    }
    PI {
	if {[sdbEnv get visible]} {
	    sdb:Newline
	    sdb:Output "<?[q content]?>" pi
	    sdb:Newline
	}
    }
}

proc sdb:Preview {} {
    global SDB sdbPreviewTick sdbIndent
    sdb:ClearOutput
    set sdbPreviewTick 100
    set sdbIndent 0
    withBusyCursor {
	withNode docroot { sdb:PreviewHandler }
	sdb:SelectTag S.[q docroot child el address]
    }
}

proc sdb:RedrawElement {address} {
    global SDB sdbPreviewTick sdbIndent
    set t $SDB(outputWidget)
    # withBusyCursor {}
    $t mark set insert SS.${address}
    $t delete \
	[$t search -backwards "\n" SS.${address} ] \
	[$t search -forward   "\n" EE.${address} ]
    withNode node $address {
	set sdbPreviewTick 100
	set sdbIndent [expr [query depth] - 2]
	set SDB(newline) 0
	process sdb:PreviewHandler
	# Get rid of extra \n :
	$t delete insert
    }
    sdb:SelectTag S.${address}
}

############################################################
# ...
############################################################

# %%% TO DO -- produce gprof-style output...
# %%% TO DO -- options for child/parent, sibling/next sibling,
#		sibling/prev sibling tabulations in addition to
#		parent/child tabulation.
#

proc sdb:AnalyzeWindow {} {
    set w .analyze

    if {![catch { wm deiconify $w ; raise $w }]} { return $w.text.t; #%%% }
    toplevel $w
    wm title $w "Element statistics"

    set t [makeScrolledText $w.text]
    pack $w.text -fill both -expand true

    set tabstop 200
    $t configure -tabs $tabstop -wrap word
    $t tag configure heading -foreground purple
    $t tag configure col1 -foreground red
    $t tag configure col2 -foreground blue -lmargin2 $tabstop

    return $t
}

proc sdb:Analyze {} {
    withBusyCursor {
	foreachNode doctree el {
	    set gi [query gi]
	    incr! elementCount($gi)
	    if {[q? parent el]} {
		set parentGI [q parent gi]
		lappend childElements($parentGI) $gi
	    }
	}
	foreachNode doctree pel {
	    lappend childElements([q parent gi]) #PCDATA
	}
	foreach parentGI [array names childElements] {
	    catch {unset childCount}
	    foreach gi $childElements($parentGI) {
		incr! childCount($gi)
	    }
	    set children {}
	    foreach gi [lsort [array names childCount]] {
		lappend children "${gi}($childCount($gi))"
	    }
	    set childList($parentGI) $children
	}
    }

    set t [sdb:AnalyzeWindow]
    $t delete 1.0 end
    $t insert end "GI\tChildren\n" heading
    foreach gi [lsort [array names elementCount]] {
	$t insert end "${gi}($elementCount($gi))" col1
	if {[info exists childList($gi)]} {
	    $t insert end "\t$childList($gi)" col2
	} else {
	    $t insert end "\t(leaf)" col2
	}
	$t insert end "\n"
    }
    # %%% HERE
}

############################################################
# ...
############################################################

proc sdb:SelectTag {tag} {
    global SDB
    set SDB(currentTag) $tag
    set SDB(currentElement) [string range $tag 2 end]
    set t $SDB(outputWidget)
    $t tag remove hilite 1.0 end
    $t tag add hilite S${tag} E${tag}
    $t see S${tag}
    $t mark set insert S${tag}
    withNode node $SDB(currentElement) {
	sdb:Status "[q gi] ([q address]) -- [q# child] children"
    }
}

proc sdb:Move {directions {unfold 0}} {
    global SDB
    foreach dirn $directions {
	foreachNode node $SDB(currentElement) $dirn el {
	    if {![query propval visible]} {
		if {$unfold} {
		    sdb:UnfoldElement [q parent address]
		} else {
		    continue;
		}
	    }
	    sdb:SelectTag S.[q address]
	    return 1
	}
    }
    return 0
}

proc sdb:FoldElement {{address -}} {
    global SDB
    set t $SDB(outputWidget)
    if {$address == "-"} {
	set address $SDB(currentElement)
    }
    $t delete ES.${address} SE.${address}
    foreachNode node $address descendant {
	setprop visible 0
    }
}

proc sdb:UnfoldElement {{address -}} {
    if {$address == "-"} {
	global SDB
	set address [string range $SDB(currentTag) 2 end]
    }
    foreachNode node $address child {
	setprop visible 1
    }
    sdb:RedrawElement $address
}

proc sdb:UnrollElement {{address -}} {
    if {$address == "-"} {
	global SDB
	set address [string range $SDB(currentTag) 2 end]
    }
    foreachNode node $address subtree {
	setprop visible 1
    }
    sdb:RedrawElement $address
}

############################################################
# Query window:
############################################################

proc sdb:QueryDialog {} {
    global SDB

    set w .queryDialog
    catch {destroy $w} ; toplevel $w

    wm title $w "Query dialog..."

    entry $w.query  -textvariable SDB(query)
    set t [makeScrolledText $w.result]

    $t tag configure query -foreground red
    $t tag configure result -foreground blue

    set SDB(queryResultsWidget) $t
    set SDB(histNumber) 0
    set SDB(queryHistory) {}

    pack $w.query -side top -expand false -fill x
    pack $w.result -side top -expand true -fill both

    bind $w.query <Key-Return> 	{ sdb:QueryExecute }
    bind $w.query <Key-Up>	{ sdb:QueryHistory -1 }
    bind $w.query <Key-Down>	{ sdb:QueryHistory +1 }

    focus $w.query

    return
}

proc sdb:QueryExecute {} {
    global SDB
    set t $SDB(queryResultsWidget)
    withBusyCursor {
	$t delete 1.0 end
	$t insert end $SDB(query) query "\n"
	$t insert end [eval $SDB(query)] result
    }
    if {$SDB(query) != [lindex $SDB(queryHistory) $SDB(histNumber)]} {
	lappend SDB(queryHistory) $SDB(query)
	set SDB(histNumber) [llength $SDB(queryHistory)]
    }
}

proc sdb:QueryHistory {delta} {
    global SDB
    set n $SDB(histNumber)
    incr n $delta
    if {$n >= 0 && $n < [llength $SDB(queryHistory)]} {
	set SDB(histNumber) $n
	set SDB(query) [lindex $SDB(queryHistory) $n]
    }
}

############################################################
# Program startup:
############################################################

global argv

wm withdraw .
set w [sdb:MainWindow]
wm protocol $w WM_DELETE_WINDOW { destroy . }

if {[llength $argv] == 1} {
    set filename [lindex $argv 0]
    after idle [list sdb:LoadFile $filename]
    # Note: load file in an 'after idle' callback so that
    # error messages go to the Tk error dialog box
    # instead of stderr.
}

#*EOF*
