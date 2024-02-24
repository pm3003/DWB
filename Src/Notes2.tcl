#----------------------------------------------------------------------
# insert mark
#----------------------------------------------------------------------
proc InsertMark {twidget wbname type xp yp lemid} {
   global dwb_vars
   #puts "InsertMark twidget $twidget wbname $wbname type $type xp $xp yp $yp lemid $lemid"
   set dbhdl "UDB"
   set table "NOTES"

   set pos [GetMarkInsertPosition $twidget $xp $yp $lemid]
   set taglist [$twidget tag names $pos]
   set expsection -1
   foreach tag $taglist {
      if {[string range $tag 0 5] == "expsec"} {
         set expsection [lindex [split $tag "@"] 1]
      }	
   }

   set context [GetNWords 6 "right" $pos $twidget]
   #set context [$twidget get $pos $pos+40c]
   #append context [GetNWords 6 "right" $pos $twidget]
   
   set apos [lindex [$twidget tag ranges lem$lemid] 0]
   foreach {l1 c1} [split $pos "."] {}
   foreach {l2 c2} [split $apos "."] {}
   set relpos "[expr $l1-$l2].[expr $c1-$c2]"
     
   set lastrow [mk::view size $dbhdl.$table]
   set markname " [expr $lastrow+1] "
   for {set i 0} {$i < $lastrow} {incr i} {
      set vals [mk::get $dbhdl.$table!$i]
      set vid [lindex $vals 1]
      set rpos [lindex $vals 5]
      if {$vid == $lemid} {
         set rline [lindex [split $rpos "."] 0]
         set rchar [lindex [split $rpos "."] 1]
         if {$rline == [expr $l1-$l2]} {
            tk_messageBox -message "Sie dürfen nur eine Anmerkung pro Abschnitt anlegen" \
               -icon warning
            return
         }        	
      }	
   }
   
   mk::set $dbhdl.$table!$lastrow ID $lemid NR $lastrow POS $relpos\
      CONTEXT $context TYPE $type TEXT "" EXPMARK $expsection
   mk::file commit $dbhdl
   
   $twidget config -state normal
   $twidget ins $pos " " "nz fz2"
   set nc [expr $lastrow +1 ]
   if {$type == 0} {
      $twidget insert $pos "$nc" "nz bm bmk$lastrow"
   } else {
      $twidget insert $pos "$nc" "nz bm bmk$lastrow"
   }
   $twidget tag bind bmk$lastrow <Button-1> \
      [eval list "MDI_PopupNotes . $lastrow"]

   $twidget ins $pos " " "nz fz2"
   $twidget config -state disabled

   if {$type == 1} {
      MDI_PopupNotes . $lastrow
   }
   
   # tk_messageBox -message "mk::get $dbhdl.$table!$lastrow text"
   set notetext [mk::get $dbhdl.$table!$lastrow text]
   # tk_messageBox -message $notetext
   if {[string length $notetext] > 25} {
      set colmsg "[string range $notetext 0 20]..."
   } else {
      if {$notetext != ""} {
         set colmsg $notetext
      } else {
         set colmsg "- bisher keine Anmerkung eingegeben -"
      }
   }
   $twidget tag bind bmk$lastrow <Enter> \
      [eval list "DisplayInstInfo {$colmsg} %W %x %y"]
   $twidget tag bind bmk$lastrow <Leave> \
      "place forget .lfginfo"             

   ListBookmarks
}


#----------------------------------------------------------------------
# edit note
#----------------------------------------------------------------------
proc EditNote {twidget markname} {
   #edit note text
   # -read note text from db
   # -open popup window with content
   
   global dwb_vars
   
   #this should be done globally of course ... later!
   set dbhdl "UDB"
   set table "NOTES"
   
   #get note text
   set id [lindex [split $markname "|"] 1]
   set nr [lindex [split $markname "|"] 2]
   set edrow [lindex \
      [mk::select $dbhdl.$table -exact ID $id NR $nr] end]
   if {$edrow == ""} {
      #mark not found in DB
      return
   } else {
      set txt [mk::get $dbhdl.$table!$edrow TEXT]
   }
   
   #open popup window
   PopupNotesWindow $txt
   set txt $dwb_vars(NOTESWINDOWTEXT)
   #if txt is empty, return and delete mark
   if {[string trim $txt] == ""} {
      DeleteMark $twidget $markname
      return
   }
   
   #update DB
   if {$txt == ""} {
      mk::set $dbhdl.$table!$edrow TEXT \"\"
   } else {
      mk::set $dbhdl.$table!$edrow TEXT $txt
   }
   
   GotoArticle $id 0
}


#----------------------------------------------------------------------
# delete mark
#----------------------------------------------------------------------
proc DeleteMark {c} {
   global dwb_vars
   
   set choice [tk_messageBox -type yesno -default yes \
      -message "Wollen Sie das Lesezeichen Nr. [expr $c+1] wirklich löschen?" \
      -icon question]
      
   if {$choice == "no"} {
      return
   }

   set dbhdl "UDB"
   set table "NOTES"
   
   mk::row delete $dbhdl.$table!$c
         
   if {[$dwb_vars(wbtextw) tag ranges bmk$c] != ""} {
      $dwb_vars(wbtextw) config -state normal
      set apos [lindex [$dwb_vars(wbtextw) tag ranges bmk$c] 0]
      set epos [lindex [$dwb_vars(wbtextw) tag ranges bmk$c] 1]
      $dwb_vars(wbtextw) delete $apos $epos
      $dwb_vars(wbtextw) config -state disabled
   }
    
   ListBookmarks
   ReloadCurrentArticle DWB
}


#----------------------------------------------------------------------
# get n words to left/right of position (context)
#----------------------------------------------------------------------
proc GetNWords {n dir pos twidget} {
   #n: integer
   #dir: left / right
   #pos: textwidget index "line.char"
   #twidget: dto
   
   #get the content of the whole line
   set linenr [lindex [split $pos "."] 0]
   set charnr [lindex [split $pos "."] 1]
   set txt [$twidget get $linenr.0 $linenr.end]
   
   #consider also the line before/after
   #if {$dir == "right"} {
   #   append txt " " [$twidget get [expr $linenr + 1].0 \
   #      [expr $linenr + 1].end]      
   #} else {
   #   set txt2 [$twidget get [expr $linenr - 1].0 \
   #      [expr $linenr - 1].end]     
   #   set i [string length $txt2]
   #   append txt2 " " $txt
   #   set txt $txt2
   #   incr charnr $i
   #}   
  
   #get n words to side "dir"
   if {$dir == "right"} {    
      set rchar [GetNthPos $n $txt $charnr]    
      set context [string range $txt $charnr $rchar]
      set context [string range $txt $charnr [expr $charnr+20]]
      return $context
   } else {
      #side=left, reverse the string for lookup and adjust position
      set rtxt [ReverseString $txt]
      set revcharnr [expr [string length $txt] - 1 - $charnr]
      set rchar [GetNthPos $n $rtxt $revcharnr]
      set lchar [expr [string length $txt] - 1 - $rchar]
      set context [string range $txt $lchar $charnr]
      return $context
   }
}


#----------------------------------------------------------------------
# get the index of the end of the n-th word in string
#----------------------------------------------------------------------
proc GetNthPos {n txt rchar} {
   #return the index of the end of the n-th word in string "txt"
   #starting from string index "rchar"
   
   for {set i 0} {$i < $n} {incr i} {
      set next_word_pos [regexp -inline -indices -start $rchar \
         {[[:alnum:]]} $txt]

      if {[llength $next_word_pos] == 0} {
         set rchar "end"
      } else {
         set rchar [lindex [lindex $next_word_pos 0] 0]
      }

      set rchar [string wordend $txt $rchar]
   }
   
   return $rchar
}


#----------------------------------------------------------------------
# reverse a string
#----------------------------------------------------------------------
proc ReverseString {s} {
   #s: string
  
   set res ""
   set i [string length $s]
   while {$i >= 0} {
      set res "$res[string index $s [incr i -1]]"
   }
    
   return $res
}


#----------------------------------------------------------------------
# get mark-insert position
#----------------------------------------------------------------------
proc GetMarkInsertPosition {twidget xp yp lemid} {
   #determine the exact position (line.char) where to insert the mark
   #always at the beginning of a word
   
   #check if at beginning of word, else go there
   set char [$twidget get @$xp,$yp]
   if {[string trim $char] == ""} {
      #clicked on some whitespace char, use pos as it is
      set pos [$twidget index @$xp,$yp]
   } else {
      #retrace to the left to find beginning of the word
      set stop_idx "1.0"
      set pos [$twidget search -backwards -regexp {[[:space:]]|^} \
         @$xp,$yp $stop_idx]
      if {$pos == ""} {
         #found nothing
         set pos $stop_idx
      }
   }
   
   if {[lindex [split $pos "."] 1] != 0} {
      set pos [$twidget index $pos+1chars]
   }
      
   return $pos
}


#----------------------------------------------------------------------
# generate mark name
#----------------------------------------------------------------------
proc GenerateMarkName {article_id} {
   #generates and markname: M|article_id|nr
   # -article_id: the ID of the article
   # -nr: the running notes number + 1 for this article

   #this should be done globally of course ... later!
   set dbhdl "UDB"
   set table "NOTES"

   set markname M

   #get max_number for this article_id in NotesDB
   set r [mk::select $dbhdl.$table -exact ID $article_id -sort NR]
   set row [lindex $r end]
   if {[llength $row] == 0} {
      #there are no notes for this article
      set nr 0
   } else {
      set nr [mk::get UDB.NOTES!$row NR]     
      incr nr
   }

   append markname "|" $article_id "|" $nr
  
   return $markname
}


# ---------------------------------------------------------
# pack intro window into MDI child window
# ---------------------------------------------------------

proc MDI_PopupNotes {top noteidx} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {[info exists dwb_vars(NOTEWINDOWOPEN,$noteidx)]} {
      return
   }
      
   set title "Anmerkung Nr. [expr $noteidx+1] bearbeiten"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,close_cmd) "CloseNoteWindow $n $noteidx"
   MDIchild_CreateWindow $n 0 0 1
   set w [PopupNotesWindow $MDI_cvars($n,client_path) $n $noteidx]

   set MDI_cvars($n,xw) [expr ([winfo width $top]- [winfo reqwidth \
      $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo height $top]- \
      [winfo reqheight $MDI_cvars($n,this)])/3]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]
   update
   
   MDIchild_Show $n
   MDI_ActivateChild $n
   update
   
   #grab set $w
   tkwait window $w
   return $w
}


# ---------------------------------------------------------
# create popup window for note-text
# ---------------------------------------------------------
proc PopupNotesWindow {top n noteidx} { 
   global dwb_vars font
   
   set dbhdl "UDB"
   set table "NOTES"
   set row [mk::get $dbhdl.$table!$noteidx]

   set popuparea [frame $top.popuparea -borderwidth 1 -relief raised]
   
   #create text window
   set txt [text $popuparea.txt -width 50 -height 12 \
      -relief flat -bd 0 -background lightyellow -font $font(h,m,r,14) \
      -wrap word -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -tabs { 20 30 } -padx 10 -pady 5]

   $txt insert end [lindex $row 11]
   
   #create buttons to confirm (ok), reset (re), cancel (ca)
   set buttonarea [frame $popuparea.buttonarea]
   set ok [MkFlatButton $buttonarea ok "Speichern"]
   $ok config -command "SaveNote $noteidx $txt;MDI_DestroyChild $n;unset dwb_vars(NOTEWINDOWOPEN,$noteidx);ReloadCurrentArticle DWB"
   set re [MkFlatButton $buttonarea re "Löschen"]
   $re config -command "$txt delete 1.0 end"
   set ca [MkFlatButton $buttonarea ca "Abbrechen"]
   $ca config -command "MDI_DestroyChild $n;unset dwb_vars(NOTEWINDOWOPEN,$noteidx)" 

   pack $ok $re $ca -padx 1 -side left
   pack $txt -expand yes -fill both
   pack $buttonarea          
   update
   
   set xpos [winfo rootx $dwb_vars(wbtextw)]
   set ypos [winfo rooty $dwb_vars(wbtextw)]
   set width [winfo width $dwb_vars(wbtextw)]
   set newx [expr ($xpos + $width)]
   pack $popuparea -fill both -expand yes
   update
   
   set dwb_vars(NOTEWINDOWOPEN,$noteidx) 1
   
   return $popuparea
}


proc SaveNote {noteidx txt} {

   set dbhdl "UDB"
   set table "NOTES"

   set text [string trim [$txt get 1.0 end]]
   mk::set $dbhdl.$table!$noteidx TEXT $text
   if {$text == ""} {
      mk::set $dbhdl.$table!$noteidx TYPE 0
   }
   ListBookmarks
}


# ---------------------------------------------------------
# list bookmarks for lemid in corrsp. tabset
# ---------------------------------------------------------
proc ListBookmarks {} {
   global dwb_vars
   
   set dbhdl "UDB"
   set table "NOTES"
   

   set textw [$dwb_vars(BOOKMARKAREA) subwidget text]
   $textw config -state normal
   $textw delete 1.0 end
   
   set previd ""
   set row [mk::select $dbhdl.$table -sort "ID NR"]
   puts "ROW=$row"
   set i 0
   foreach c $row {
      set vals [mk::get $dbhdl.$table!$c ID NR TYPE POS EXPMARK TEXT CONTEXT]
      set lemid [lindex $vals 0]
      set nr [lindex $vals 1]
      set type [lindex $vals 2]
      set pos [lindex $vals 3]
      set expmarker [lindex $vals 4]
      set notetext [lindex $vals 5]         
      set context [lindex $vals 6]         

      if {$lemid != $previd} {
         set tablename "LEMMA"
         set row [performQuery IDXDWB $tablename "ID==$lemid"]
         if {[lindex $row 0] != ""} {
            set position [eval mk::get DBDWB.$tablename![lindex $row 0] POSITION]
            set lemma [eval mk::get DBDWB.$tablename![lindex $row 0] NAME]
            set grow [performQuery IDXDWB GRAM "ID==$lemid"]
            if {[lindex $grow 0] != ""} {
               set gram "[mk::get DBDWB.GRAM![lindex $grow 0] TYPE]."
               set sep ", "
            } else {
               set gram ""
               set sep ""
            }
            if {$previd != ""} {
               $textw ins e "\n" lemma
            }
            $textw ins e $lemma lemma
            $textw ins e "$sep$gram\n" gram
         }
         set previd $lemid
      }
    
      label $textw.c$i -image [tix getimage notsymb] -bd 0
      $textw win cr insert -win $textw.c$i
      $dwb_vars(BHLP) bind $textw.c$i -msg "Eintrag löschen"
      bind $textw.c$i <1> [eval list "DeleteMark $c"]

      $textw ins insert "\t" bmk$i
      set nc [expr $c +1 ]
      if {$type == 0} {
         $textw insert insert "$nc" "bm bmk$i"
      } else {
         $textw insert insert "$nc" "bm bmk$i"
      }
    
      regsub -all "\n" $context " " context
      $textw ins insert " $context" "context bmk$i"
      $textw ins insert "\n" bmk$i
      
      if {[string length $notetext] > 25} {
         set colmsg "[string range $notetext 0 20]..."
      } else {
         if {$notetext != ""} {
            set colmsg $notetext
         } else {
            set colmsg "- bisher keine Anmerkung eingegeben -"
         }
      }
      $textw tag bind bmk$i <ButtonPress-1> \
         [eval list "GotoArticle $lemid 1"]
      $textw tag bind bmk$i <ButtonPress-1> \
         +[eval list "ScrollToBookmark $c"]
      $textw tag bind bmk$i <Enter> \
         "$textw tag config bmk$i -background grey80 -bgstipple gray50"
      $textw tag bind bmk$i <Enter> \
         +[eval list "DisplayInstInfo {$colmsg} %W %x %y"]
      $textw tag bind bmk$i <Leave> \
         "$textw tag config bmk$i -background grey97"
      $textw tag bind bmk$i <Leave> \
         +[eval list "place forget .lfginfo"]
      
      incr i
   }
   $textw config -state disabled
}


# ---------------------------------------------------------
# add oder subtract 1c from the position of affected marks
# ---------------------------------------------------------
proc AdjustMarkPositions {dir twidget markname} {
   #dir: backward/forward=subtract/add 1c if marks are deleted/inserted
   
   #this should be done globally of course ... later!
   set dbhdl "UDB"
   set table "NOTES"

   #alle marken hinter bearbeiteter marke innerhalb der 
   #lemid-tagrange ermitteln (since we're using relative positions)
   #ihren cursor in DB ermitteln
   #von diesen cursorn die positionen verändern
   
   #get the names and positions of all marks after "current"
   #mark in the textwidget
   set startpos [$twidget index $markname]
   set tagname "lem"
   set lemid [lindex [split $markname "|"] 1]
   append tagname $lemid
   set ranges [$twidget tag ranges $tagname]
   #this is the last idx that is tagged with lemid, i.e. the end
   #of the article:
   set endpos [lindex [lindex $ranges end] end]
   
   set dumplist [$twidget dump -mark $startpos $endpos]
   set len [expr [llength $dumplist] - 1]
   #collect all marknames from dumplist, ignore the first
   #triple since this is the "current" mark which need
   #not be modified
   set marklist {}
   set poslist {}
   for {set i 3} {$i <= $len} {incr i 3} {
      if {[regexp {"M\|.+\|.+"} [lindex $dumplist [expr $i+1]]]} {
         append marklist [lindex $dumplist [expr $i+1]]
         append poslist [lindex $dumplist [expr $i+2]]
      }
   }
      
   for {set i 0} {$i < [llength $marklist]} {incr i} {
      set markname [lindex $marklist $i]
      set pos [lindex $poslist $i]
      set lemid [lindex [split $markname "|"] 1]
      set nr [lindex [split $markname "|"] 2]
      set c [lindex \
         [mk::select $dbhdl.$table -exact ID $lemid NR $nr] end]

      #now increase/decrease the position
      if {$dir == "backward"} {            
         append pos "-1c"
      } else {
         append pos "+1c"
      }
      
      #add changed position to DB
      set new_pos [$twidget index $pos]
      mk::set $dbhdl.$table!$c POS $new_pos
   }
}


# ---------------------------------------------------------
# Add marks to article when it is loaded; expand article if applicable
# ---------------------------------------------------------
proc AddMarks {lemid twidget} {
   global dwb_vars

   set dbhdl "UDB"
   set table "NOTES"
   
   #determine if there are any bookmarks/notes set in this article
   set row [mk::select $dbhdl.$table -exact ID $lemid -rsort EXPMARK]
   set len [llength $row]
   if {$len == 0} {
      #no marks set, do nothing
   } else {    
      set alltags [$twidget tag names]
      set expsecs ""
      foreach m [$twidget mark names] {
         if {[string range $m 0 9] == "srk$lemid"} { 
            set section [lindex [split [string range $m 11 end] "@"] 0]
            lappend expsecs $section
         }
      }
      for {set i 0} {$i < $len} {incr i} {         
         set c [lindex $row $i]
         set vals [mk::get $dbhdl.$table!$c NR TYPE POS EXPMARK TEXT CONTEXT]
         set nr [lindex $vals 0]
         set type [lindex $vals 1]
         set relpos [lindex $vals 2]
         set expsection [lindex $vals 3]
         set notetext [lindex $vals 4]         
         set context [lindex $vals 5]

         set apos [lindex [$twidget tag ranges lem$lemid] 0]
         set epos [lindex [$twidget tag ranges lem$lemid] 1]
         foreach {l1 c1} [split $relpos "."] {}
         foreach {l2 c2} [split $apos "."] {}
         set pos "[expr $l1+$l2].[expr $c1+$c2]"
         
         #see if there's an expansion marker before this mark

         if {$expsection >= 0 && [lsearch $expsecs $expsection] < 0} {
            ExpandParagraph $lemid $expsection 1
            lappend expsecs $expsection
         }

         set cpos [$twidget search $context 1.0 end]
         if {$cpos < 0} {
            continue
         }
    	 set pos $cpos
                    
         $twidget ins $pos " " "nz bmk$c"
         set nc [expr $c +1 ]
         if {$type == 0} {
            $twidget insert $pos "$nc" "nz bm bmk$c"
         } else {
            $twidget insert $pos "$nc" "nz am bmk$c"
         }
         $twidget tag bind bmk$c <Button-1> \
            [eval list "MDI_PopupNotes . $c"]
         
         if {[string length $notetext] > 25} {
            set colmsg "[string range $notetext 0 20]..."
         } else {
            if {$notetext != ""} {
               set colmsg $notetext
            } else {
               set colmsg "- bisher keine Anmerkung eingegeben -"
            }
         }
         $twidget tag bind bmk$c <Enter> \
            [eval list "DisplayInstInfo {$colmsg} %W %x %y"]
         $twidget tag bind bmk$c <Leave> \
            "place forget .lfginfo"
               
         $twidget ins $pos " " "nz bmk$c"

         incr dwb_vars(imagenr)   
      }
   }
}


proc reverse_list {l} {
   set rev ""
   
   foreach i $l {
      set rev [linsert $rev 0 $i]
   }
   
   return $rev
}


proc CloseNoteWindow {n noteidx} {
   global dwb_vars

   MDI_DestroyChild $n
   unset dwb_vars(NOTEWINDOWOPEN,$noteidx)
}


proc ScrollToBookmark {noteidx} {
   global dwb_vars
   
   set w $dwb_vars(WBTEXT,DWB,1)
   
   set range [$w tag range bmk$noteidx]
   puts "$w tag range bmk$noteidx = $range"
   if {$range != ""} {
      $w see [lindex $range 0]
   }
}