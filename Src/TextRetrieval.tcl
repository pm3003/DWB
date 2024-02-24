# =========================================================
#     DEUTSCHES WÖRTERBUCH VON JACOB UND WILHELM GRIMM
#                        
#   ENTWICKELT IM FACH GERMANISTIK DER UNIVERSITÄT TRIER
#                IN ZUSAMMENARBEIT MIT DEM
#  KOMPETENZZENTRUM FÜR ELEKTRONISCHE ERSCHLIESSUNGS- UND
#    PUBLIKATIONSVERFAHREN IN DEN GEISTESWISSENSCHAFTEN
# ---------------------------------------------------------
#                     BEARBEITET VON
#     HANS-WERNER BARTZ, THOMAS BURCH, RUTH CHRISTMANN,
#      KURT GÄRTNER, VERA HILDENBRANDT, THOMAS SCHARES
#
#        COPYRIGHT (C) 1998, 1999, 2000, 2001, 2002
# BY KOMPETENZZENTRUM FÜR ELEKTRONISCHE ERSCHLIESSUNGS- UND
#    PUBLIKATIONSVERFAHREN IN DEN GEISTESWISSENSCHAFTEN
#                 AN DER UNIVERSITÄT TRIER
#
# All Rights reserved.
# No part of this publication may be reprinted or reporduced
# or utilized in any form or by any electronic (online or
# offline), mechnical or other means without permissions in
# writing from the publisher.
# CD-ROM copyright by HWB, TB, RC, KG, VH and TS.
# 
# Trier, November 2002
# =========================================================

# ---------------------------------------------------------
# create query area, 6 query-entry fields
# ---------------------------------------------------------

proc InitTagHits {} {
   global dwb_vars

   set dwb_vars(TEXTTAGS,1) "l1,l2"
   set dwb_vars(TEXTTAGS,2) "g1,g2"
   set dwb_vars(TEXTTAGS,3) "au1,au2,t1,t2,b1,b2,a1,a2,ra1,ra2"
   set dwb_vars(TEXTTAGS,4) "bir1,bir2,subir1,subir2"
   set dwb_vars(TEXTTAGS,5) "d1,d2"
   set dwb_vars(TEXTTAGS,6) "q1,q2"
   set dwb_vars(TEXTTAGS,7) "e1,e2,laa1,laa2,la1,la2,gr1,gr2"
   set dwb_vars(TEXTTAGS,8) "s1,s2"

   set dwb_vars(HITTAGS,LEMMA)    1
   set dwb_vars(HITTAGS,GRAM)     2
   set dwb_vars(HITTAGS,SIGLE)    3
   set dwb_vars(HITTAGS,SIGLEREF) 4
   set dwb_vars(HITTAGS,DEF)      5
   set dwb_vars(HITTAGS,BELEG)    6
   set dwb_vars(HITTAGS,ETYM)     7
   set dwb_vars(HITTAGS,REST)     8
   set dwb_vars(HITTAGS,ALL)      1,2,3,4,5,6,7,8
}


# ---------------------------------------------------------
# query-entry field
# ---------------------------------------------------------

proc MkEntryField {parent name text {mode 0}} {
   global dwb_vars font

   set box [frame $parent.$name]
   tixLabelEntry $box.lbe -label "$text: " -labelside left \
      -borderwidth 0 -relief flat
   $box.lbe subwidget label config -anchor e -width 22 \
      -font $font(h,m,r,14)
   set ew [$box.lbe subwidget entry]
   $ew config -textvariable dwb_vars(${name}_eing_o) \
      -font $font(h,b,r,14) -foreground blue
   set dwb_vars(${name}_eing_o) ""
   bind $ew <Return> "StartQuery"
   if {$name != "secn" && $name != "year"} {
      label $box.check -image $dwb_vars(QUERY,choice,3)
      if {!$mode} {
         bind $box.check <1> "IncCheckMark $name $ew $box.check"
         bind $box.check <3> "DecCheckMark $name $ew $box.check"
      }
      pack $box.check -side right -padx 5
   }
   
   bind $ew <KeyRelease> "
      check_entry_fields $parent $name
      ConvertEntities $ew 0
   "
   
   pack $box.lbe -side left -fill x -expand yes

   set dwb_vars(QUERY,TEXT,CHECK,$name) $box.check
   if {!$mode} {
      lappend dwb_vars(QUERY,cats) $name
   }
   set dwb_vars(${name}_check) 0
   set dwb_vars(${name}_label) $text

   return $box
}

# ---------------------------------------------------------
# create query area, 8 query-entry fields
# ---------------------------------------------------------

proc MkFullSearchArea {top} {
   global dwb_vars font

   set entrylist [frame $top.elist]

   set dwb_vars(QUERY,cats) ""
   set e1 [MkEntryField $entrylist full "Gesamter Text"]
   set e2 [MkEntryField $entrylist objs "Nicht kursive Abschnitte"]
   set e3 [MkEntryField $entrylist bess "Kursive Abschnitte"]
   set e4 [MkEntryField $entrylist keyw "Stichwort"]
   set e5 [MkEntryField $entrylist gram "Wortart"]
   set e6 [MkEntryField $entrylist sigl "Sigle"]
   set e7 [MkEntryField $entrylist vers "Verszitat"]
   #set e8 [MkEntryField $entrylist pros "Prosazitat"]

   frame $entrylist.space0 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space1 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space2 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space3 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space4 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space6 -height 10 -borderwidth 1 -relief flat

   set dwb_vars(QUERY,NORMSEARCH) 1
   set dwb_vars(QUERY,SENSECASE) 0
   set dwb_vars(full_types) ""
   set dwb_vars(objs_types) "0 2 4 5 8 10 11 12 15"
   set dwb_vars(bess_types) "1 3 6 7 9 13 14"
   set dwb_vars(keyw_types) "7 8"
   set dwb_vars(gram_types) "6"
   set dwb_vars(sigl_types) "0 3 4 13"
   set dwb_vars(vers_types) "14 15"
   set dwb_vars(pros_types) "1 2"
   
   set dwb_vars(full_tags) "ciau2 crau2 b1 b2 bir1 bir2 da2 g1 l1 l2 s1 s2 sgr2 sn2 t1 t2 v1 v2 sl1 sl2 cc lfg"
   set dwb_vars(objs_tags) "ciau2 crau2 b2 bir2 da2 l2 s2 sgr2 sn2 v2 t2 sl2 cc lfg"
   set dwb_vars(bess_tags) "b1 bir1 g1 l1 s1 t1 v1 sl1 cclfg"
   set dwb_vars(keyw_tags) "l1 l2 sl1 sl2 cc lfg"
   set dwb_vars(gram_tags) "g1"
   set dwb_vars(sigl_tags) "ciau2 crau2 bir1 bir2 t1 t2 cc lfg"
   set dwb_vars(vers_tags) "v1 v2 cc lfg"
   set dwb_vars(pros_tags) "b1 b2 cc lfg"

   foreach name $dwb_vars(QUERY,cats) {
      set dwb_vars(${name}_tagids) 0
      foreach el $dwb_vars(${name}_types) {
         set dwb_vars(${name}_tagids) [expr $dwb_vars(${name}_tagids)|(1<<$el)]
      }
   }
   set dwb_vars(full_tagids) 131071
   
   #frame $entrylist.cmd -relief flat
   
   tixLabelFrame $entrylist.cmd -label "Suche"
   set f [$entrylist.cmd subwidget frame]
   [$entrylist.cmd subwidget label] config -font $font(h,m,r,12)
   
   set ok [MkFlatButton $f ok "Ausführen"]
   $ok config -command "StartQuery" -font $font(h,m,r,12)
   set stop [MkFlatButton $f stop "Abbrechen"]
   $stop config -command "CancelQuery" -font $font(h,m,r,12) \
      -state normal
   set dwb_vars(QUERY,CancelButton) $stop
   set save [MkFlatButton $f save "Speichern"]
   $save config -command "SaveQuery" -font $font(h,m,r,12) \
      -state normal
   set clear [MkFlatButton $f clear "Zurücksetzen"]
   $clear config -command "ResetQuery" -font $font(h,m,r,12) \
      -state normal
   #set help [MkFlatButton $f help "Hilfe"]
   #$help config -command "MDI_SearchHelpPopup $top" -font $font(h,m,r,12) \
   #   -state normal

   #pack $ok $stop $save $clear $help -side left -padx 2
   pack $ok $stop $save $clear -side left -padx 2

   pack $entrylist.space0 $e1 $entrylist.space1 \
      $e2 $e3 $entrylist.space4 $e4 $e5 $e6 $e7 \
      -side top -anchor e -fill x
   pack $entrylist.space2 -side top -fill x
   pack $entrylist.cmd $entrylist.space6 -side top 

   pack $entrylist -fill x -anchor n
   
   set dwb_vars(QUERY,entryarea) $entrylist

   return
}


proc MkOptionArea {top} {
   global dwb_vars font
   
   set entrylist [frame $top.elist]

   set e1 [MkEntryField $entrylist secn "Wortstrecke" 1]
   $dwb_vars(BHLP) bind [$e1.lbe subwidget entry] -msg "Einschränkung der Suche\nauf Wortstrecken, z.B. A;G-J;Z"

   set e2 [MkEntryField $entrylist year "Erscheinungsjahr" 1]
   $dwb_vars(BHLP) bind [$e2.lbe subwidget entry] -msg "Einschränkung der Suche\nauf Erscheinungsjahre, z.B. 1933-1945"

   #set e3 [MkEntryField $entrylist band "Band (DTV-Ausgabe)" 1]
   #$dwb_vars(BHLP) bind [$e3.lbe subwidget entry] -msg "Einschränkung der Suche\nauf Einzelbände, z.B. 1-3;10-12"
   
   frame $entrylist.space0 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space1 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space2 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space3 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space4 -height 10 -borderwidth 1 -relief flat

   tixLabelFrame $entrylist.sort -label "Ergebnis sortieren"
   set f [$entrylist.sort subwidget frame]
   [$entrylist.sort subwidget label] config -font $font(h,m,r,12)
   
   set dwb_vars(QUERY,sorting) 1
   set r1 [radiobutton $f.r1 -text "A > Z" \
      -variable dwb_vars(QUERY,sorting) -value 1 -font $font(h,m,r,12)]
   set r2 [radiobutton $f.r2 -text "Z > A" \
      -variable dwb_vars(QUERY,sorting) -value 2 -font $font(h,m,r,12)]
   set r3 [radiobutton $f.r3 -text "1852 > 1960" \
      -variable dwb_vars(QUERY,sorting) -value 3 -font $font(h,m,r,12)]
   set r4 [radiobutton $f.r4 -text "1960 > 1852" \
      -variable dwb_vars(QUERY,sorting) -value 4 -font $font(h,m,r,12)]
        
   pack $r1 $r2 $r3 $r4 -side left -expand yes

   set dwb_vars(QUERY,constrainarea) $entrylist

   set statarea [frame $entrylist.statarea -relief flat]

   set reportarea [tixScrolledText $statarea.report -scrollbar y]
   set textw [$reportarea subwidget text]
   $textw config -height 22 -width 44 -padx 10 -pady 5 \
      -wrap word -background "grey97" -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 30 } \
      -exportselection yes -selectforeground white \
      -selectbackground grey80 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(h,m,r,12)
   pack $reportarea -fill both -expand yes
   set dwb_vars(QUERY,REPORTAREA) $textw

   pack $entrylist.space0 $e1 $entrylist.space1 $e2 \
      $entrylist.space3 $entrylist.sort \
      $entrylist.space4 -side top -anchor e -fill x
      
   pack $statarea -side bottom -fill x

   pack $entrylist -fill both -anchor n -expand yes
}

# ---------------------------------------------------------
# checks whether entry fields are empty or not
# ---------------------------------------------------------

proc check_entry_fields {parent name} {
   global dwb_vars

   set entry $parent.$name.lbe
   set check $parent.$name.check
   
   set etext [[$entry subwidget entry] get]
   if {$etext != ""} {
      if {$dwb_vars(${name}_check) == 0} {
      	 set dwb_vars(${name}_check) 2
      }
      if {$name != "secn" && $name != "year"} {
         set value [lindex [$check config -image] 4]
         if {$value == $dwb_vars(QUERY,choice,3)} {
            $check config -image $dwb_vars(QUERY,choice,1)
         }
         $dwb_vars(BHLP) bind $check -msg $dwb_vars(QUERY,tooltip,$dwb_vars(${name}_check))
      }
      if {$name == "secn"} {
         set utext [string toupper $etext]
         set textisok 1
         foreach el [split $utext ";"] {
            foreach letter [split $el "-"] {
               if {[lsearch $dwb_vars(WBSECTIONS) $letter] < 0} {
                  set textisok 0
               }
            }
         }
         if {!$textisok} {
            [$entry subwidget entry] config -foreground red
         } else {
            [$entry subwidget entry] config -foreground blue
         }
      }
      if {$name == "year"} {
         set textisok 1
         foreach el [split $etext ";"] {
            foreach year [split $el "-"] {
               for {set i 0} {$i < [string length $year]} {incr i} {
                  set c [string range $year $i $i]
                  if {[string first $c $dwb_vars(ALLOWEDYEARCHARS)] < 0} {
                     set textisok 0
                  }
               }
               if {$year < 1852 || $year > 1961} {
                  set textisok 0
               }
            }
         }
         if {!$textisok} {
            [$entry subwidget entry] config -foreground red
         } else {
            [$entry subwidget entry] config -foreground blue
         }        	       	
      }
      if {$name == "band"} {
         set textisok 1
         foreach el [split $etext ";"] {
            foreach band [split $el "-"] {
               if {$band < 1 || $band > 32} {
                  set textisok 0
               }
            }
         }
         if {!$textisok} {
            [$entry subwidget entry] config -foreground red
         } else {
            [$entry subwidget entry] config -foreground blue
         }        	       	
      }
   } else {
      if {$name != "secn" && $name != "year"} {
         $check config -image $dwb_vars(QUERY,choice,3)
         set dwb_vars(${name}_check) 0
         $dwb_vars(BHLP) bind $check -msg $dwb_vars(QUERY,tooltip,$dwb_vars(${name}_check))
      }
      [$entry subwidget entry] config -foreground blue
   }
   
   set dwb_vars(QUERY,RESULT,NROFSR) 0
   set dwb_vars(QUERY,SEARCHED) ""
   set dwb_vars(QUERY,totalhits) $dwb_vars(QUERY,NOTEXECUTED)
   if {$name == "secn" || $name == "year"} {      
      foreach pair $dwb_vars(QUERY,SEARCHED) {
         unset dwb_vars(QUERY,RESTABLE,$pair)
      }               	
   }
}

# ---------------------------------------------------------
# prepares fulltext query
# ---------------------------------------------------------

proc EvalQuerySettingsFulltext {} {
   global dwb_vars

   foreach name $dwb_vars(QUERY,cats) {
      set dwb_vars(QUERY,srchexp,$name) ""
   }
   set dwb_vars(QUERY,RESULT,NROFSR) 0
   set dwb_vars(QUERY,SEARCHED) ""
   set dwb_vars(QUERY,totalhits) $dwb_vars(QUERY,NOTEXECUTED)
   set dwb_vars(DWBQUERY,tagnames) ""

   set fc [lindex [$dwb_vars(QUERY,constrainarea).secn.lbe.frame.entry config -foreground] 4]
   if {$fc == "red"} {
      tk_messageBox -message "Wortstreckenauswahl \"$dwb_vars(secn_eing_o)\" fehlerhaft" \
         -icon error
      return @0@@
   }
   set dwb_vars(QUERY,sections) [EvalSectionSetting]
     
   set fc [lindex [$dwb_vars(QUERY,constrainarea).year.lbe.frame.entry config -foreground] 4]
   if {$fc == "red"} {
      tk_messageBox -message "Jahresauswahl \"$dwb_vars(year_eing_o)\" fehlerhaft" \
         -icon error
      return @0@@
   }
   set dwb_vars(QUERY,years) [EvalNumSetting year]
   
   foreach name $dwb_vars(QUERY,cats) {
      set dwb_vars(${name}_eval) ""
      set dwb_vars(${name}_hits) ""
      set dwb_vars(RESLIST,$name) ""
      set dwb_vars(${name}_eing) [PPSearchExpression [PreParseSearchExpression $dwb_vars(${name}_eing_o)]]
      if {$dwb_vars(${name}_eing) == "@0@@"} {
         return @0@@
      }
      if {[llength $dwb_vars(${name}_eing)] > 0} {
         foreach tag $dwb_vars(${name}_tags) {
            if {[lsearch $dwb_vars(DWBQUERY,tagnames) $tag] < 0} {
               lappend dwb_vars(DWBQUERY,tagnames) $tag
            }
         }
         set res [subs_alt $dwb_vars(${name}_eing)]
         if {$res == "@0@@"} {
            return @0@@
         }
         set dwb_vars(${name}_eing) $res
         if {[fullsearch $name $dwb_vars(${name}_eing)] == "@0@@"} {
            return @0@@
         }
      }
   }
}


proc EvalSectionSetting {} {
   global dwb_vars
   
   if {$dwb_vars(secn_eing_o) == ""} {
      return ""
   }
   set usecn_eing [ConvertToUppercase $dwb_vars(secn_eing_o)]
   set secns ""
   foreach range [split $usecn_eing ";"] {
      set borders [split $range "-"]
      if {[llength $borders] == 1} {
         if {[lsearch $secns [lindex $borders 0]] < 0} {
            lappend secns [lindex $borders 0]
         }
      } else {
      	 set first [lindex $borders 0]
      	 set last [lindex $borders 1]
      	 set fidx [lsearch $dwb_vars(WBSECTIONS) $first]
      	 set lidx [lsearch $dwb_vars(WBSECTIONS) $last]
      	 if {$lidx < $fidx} {
      	    set hidx $fidx
      	    set fidx $lidx
      	    set lidx $hidx
      	 }
      	 for {set i $fidx} {$i <= $lidx} {incr i} {
      	    set letter [lindex $dwb_vars(WBSECTIONS) $i]
      	    if {[lsearch $secns $letter] < 0} {
      	       lappend secns $letter
      	    }
      	 }
      }	
   }
   return [lsort $secns]	
}


proc EvalNumSetting {name} {
   global dwb_vars
   
   if {$dwb_vars(${name}_eing_o) == ""} {
      return ""
   }

   set res ""
   foreach range [split $dwb_vars(${name}_eing_o) ";"] {
      set borders [split $range "-"]
      if {[llength $borders] == 1} {
         if {[lsearch $res [lindex $borders 0]] < 0} {
            lappend res [lindex $borders 0]
         }
      } else {
      	 set first [lindex $borders 0]
      	 set last [lindex $borders 1]
      	 if {$first > $last} {
      	    set hidx $first
      	    set first $last
      	    set last $hidx
      	 }
      	 for {set i $first} {$i <= $last} {incr i} {
      	    if {[lsearch $res $i] < 0} {
      	       lappend res $i
      	    }
      	 }
      }	
   }
   return [lsort -integer $res]   	
}


# ---------------------------------------------------------
# performs fulltext db-query
# ---------------------------------------------------------

proc fullsearch {type srchexp} {
   global dwb_vars
   
   set prsdsrchexp [ParseSearchExpression $srchexp]
   if {$prsdsrchexp == "@0@@"} {
      tk_messageBox -message "Fehlerhafter Suchausdruck: \"$srchexp\"" \
         -icon error
      return @0@@
   } elseif {$prsdsrchexp == "@1@@"} {
      return @0@@
   }
   set dwb_vars(QUERY,srchexp,$type) $prsdsrchexp

   set _stkLevel 0
   foreach el $prsdsrchexp {
      if {$el == "\&" || $el == "!" || $el == "|" || \
          [regexp (\<)(\[0-9\]*)(\<) $el all mode dist] || \
          [regexp (=)(\[0-9\]*)(=) $el all mode dist]} {
      } else {
         if {!$dwb_vars(QUERY,SENSECASE)} {
            set sensecase 0
            if {!$dwb_vars(QUERY,NORMSEARCH)} {
               set word "[ConvertToLowercase $el]"
            } else {
               set word "[NormalizeWord [ConvertToLowercase $el]]"
            }
         } else {
            set sensecase 1
            if {!$dwb_vars(QUERY,NORMSEARCH)} {
               set word "$el"
            } else {
               set word "[NormalizeWord $el]"
            }
         }
         
         TraceSearch "Suche nach \"$word\" in $dwb_vars(${type}_label):\n"
         set row [performWordQuery LEXICON "WORD=$word" $sensecase 1 $dwb_vars(${type}_tagids)]
         set x 0
         set sep ""
         set tracetext ""
         set y 0
         foreach r $row {
            set w [string trimleft [lindex [split $r "+"] 0] "@"]
            set xn [lindex [split $r "+"] 1]
            if {[string range $w 0 0] == "\#"} {
               set w [InvertWord [string range $w 1 end]]
            }
            append tracetext "$sep$w ($xn)"
            set sep ", "
            incr x $xn
            incr y
            if {$y > 100} {
               append tracetext "... und [expr [llength $row]-$y] weitere ..."
               break
            }
            #update
         }
         TraceSearch "$tracetext\n"
         update
         append dwb_vars(${type}_eval) " $word ($x)"
         if {!$dwb_vars(execQuery)} {
            return
         }
         set dwb_vars(QUERY,RESULT,$type,$word) $row
         lappend dwb_vars(QUERY,SEARCHED) "$type,$word"
            
         incr dwb_vars(QUERY,RESULT,NROFSR)
      }
   }
}


# ---------------------------------------------------------
# joins the different subresult lists
# ---------------------------------------------------------

proc CombineResults {} {
   global dwb_vars

   if {!$dwb_vars(execQuery)} {
      return
   }
   
   set res -1
   foreach type $dwb_vars(QUERY,cats) {
      if {$dwb_vars(${type}_check) == 1} {
         if {$res < 0} {
            set res $dwb_vars(RESLIST,$type)
         } else {
            set res [MergeResTables $res $dwb_vars(RESLIST,$type)]
         }
      }
   }
   foreach type $dwb_vars(QUERY,cats) {
      if {$dwb_vars(${type}_check) == 2} {
         if {$res < 0} {
            set res $dwb_vars(RESLIST,$type)
         } else {
            set res [JoinResTables $res $dwb_vars(RESLIST,$type)]
         }
      }
   }
   foreach type $dwb_vars(QUERY,cats) {
      if {$dwb_vars(${type}_check) == 3} {
         if {$res < 0} {
            set res $dwb_vars(RESLIST,$type)
         } else {
            set res [SubResTables $res $dwb_vars(RESLIST,$type)]
         }
      }
   }
 
   return $res
}


# ---------------------------------------------------------
# regular substitutions for wildcards etc.
# ---------------------------------------------------------

proc PPSearchExpression {zkette} {

   if {$zkette == ""} {
      return $zkette
   }

   set zkette [string trim $zkette]
   while {[regexp "  " $zkette]} {
      regsub -all "  " $zkette " " zkette
   }

   regsub -all "\\." $zkette "" zkette
   regsub -all "," $zkette "" zkette
   regsub -all ";" $zkette "" zkette
   regsub -all "\\\[\\\]" $zkette "" zkette
   regsub -all "\\\[" $zkette "\[" zkette
   regsub -all "\\\]" $zkette "\]" zkette
   regsub -all "\"\"" $zkette "" zkette
   regsub -all " UND " $zkette "\\&" zkette
   regsub -all " \\& " $zkette "\\&" zkette
   regsub -all " ODER " $zkette "|" zkette
   regsub -all " \\\| " $zkette "|" zkette
   regsub -all " NICHT " $zkette "!" zkette
   regsub -all " ! " $zkette "!" zkette
   regsub -all "\\\( " $zkette "\(" zkette
   #regsub -all " \\\(" $zkette "\(" zkette
   #regsub -all "\\\) " $zkette "\)" zkette
   regsub -all " \\\)" $zkette "\)" zkette
   regsub -all " <" $zkette "<" zkette
   regsub -all "< " $zkette "<" zkette
   regsub -all " =" $zkette "=" zkette
   regsub -all "= " $zkette "=" zkette
   
   regsub -all " " $zkette " \\& " zkette
   regsub -all "\&" $zkette " \& " zkette
   regsub -all "!" $zkette " ! " zkette
   regsub -all "\\\|" $zkette " \| " zkette
   regsub -all "\\\(" $zkette " \( " zkette
   regsub -all "\\\)" $zkette " \) " zkette
   regsub -all "(\<)(\[0-9\]*)(\<)" $zkette " & " zkette
   regsub -all "(=)(\[0-9\]*)(=)" $zkette " & " zkette

   return $zkette
}


proc PreParseSearchExpression {str} {
   global dwb_vars

   set vstr $str
   
   set illchars ""
   for {set i 0} {$i < [string length $str]} {incr i} {
      set c [string range $str $i $i]
      if {[string first $c $dwb_vars(ALLOWEDQUERYCHARS)] < 0} {
         append illchars $c
      }     
   }
   if {$illchars != ""} {
      tk_messageBox -message "Suchausdruck \"$vstr\" enthält nicht erlaubte Zeichen: $illchars" \
         -icon error
      return @0@@
   }
      
   set str [string trim $str]
   while {[regexp "  " $str]} {
      regsub -all "  " $str " " str
   }

   regsub -all " \"" $str "\"" str
   regsub -all "\" " $str "\"" str

   set slength [string length $str]
   set pos {}
   set newstr ""
   for {set i 0} {$i < $slength} {incr i} {
      set char [string index $str $i]
      if {$char == "\""} {
         lappend pos $i
      }
   }
   if {[llength $pos] > 0 && [expr [llength $pos] % 2] != 0 && $str != ""} {
      tk_messageBox -message "Fehlerhafter Suchausdruck: \"$vstr\"" \
         -icon error
      return @0@@
   } elseif {[llength $pos] == 0} {
      return $str 
   } else {
      set c 0
      foreach {p1 p2} $pos {
         if {[llength $p2] == 0} {
            #unbalanced quote, closing marks missing
            #delete the single quote sign
            append newstr [string range $str $prev_p2 [expr $p1 - 1]]
            append newstr [string range $str [expr $p1 + 1] end]
            break
         }
         set range [string range $str $p1 $p2]
         set range [string trim $range "\""]
         set range [GenerateBrackets $range]
         
         if {$c == 0} {
            set newstr [string range $str 0 [expr $p1 - 1]]
            incr c
         } else {
            append newstr [string range $str $prev_p2 [expr $p1 - 1]]
         }
         set prev_p2 [expr $p2 + 1]
         append newstr $range         
      }
      return $newstr
   }
   return $str
}


proc GenerateBrackets {str} {
   
   set wordList [split $str " "]
   set wnr 0
   set newstr ""
   foreach word $wordList {
      if {$wnr > 1} {
         set newstr "($newstr)"
      }
      if {$wnr > 0} {
         #append newstr " <1< "
         append newstr " =1= "
      }
      append newstr "$word"
      incr wnr
   }

   return [string trim $newstr]
}

# ---------------------------------------------------------
# parse search expression
# ---------------------------------------------------------

proc ParseSearchExpression {text} {

   set stkLevel 0
   
   foreach el $text {
      if {$el == "\&"} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  op
         incr stkLevel
      } elseif {$el == "|"} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  op
         incr stkLevel
      } elseif {$el == "!"} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  op
         incr stkLevel
      } elseif {[regexp (\\.|\<)(\[0-9\]*)(\\.|\<) $el all mode dist]} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  op
         incr stkLevel
      } elseif {[regexp (=)(\[0-9\]*)(=) $el all mode dist]} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  op
         incr stkLevel
      } elseif {$el == "("} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  open
         incr stkLevel
      } elseif {$el == ")"} {
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  close
         incr stkLevel
      } else {
      	 if {[string range $el 0 0] == "*" || [string range $el 0 0] == "?"} {
      	    if {[string range $el end end] == "*" || [string range $el end end] == "?"} {
               tk_messageBox -message "Ausdruck: \"$el\" - Gleichzeitige Links- und Rechtstrunkierung\nwird nicht unterstützt." \
                  -icon warning
               return @1@@
            }
      	 }
         set _expStack($stkLevel,value) $el
         set _expStack($stkLevel,type)  id
         incr stkLevel
      }

      set red 1
      while {$red && $stkLevel > 2} {
         if {$_expStack([expr $stkLevel-1],type) == "id" && \
             $_expStack([expr $stkLevel-2],type) == "op" && \
             $_expStack([expr $stkLevel-3],type) == "id"} {
            set value "$_expStack([expr $stkLevel-3],value) $_expStack([expr $stkLevel-1],value) $_expStack([expr $stkLevel-2],value)"
            incr stkLevel -3
            set _expStack($stkLevel,value) $value
            set _expStack($stkLevel,type)  id
            incr stkLevel
         } elseif {$_expStack([expr $stkLevel-1],type) == "close" && \
                   $_expStack([expr $stkLevel-2],type) == "id" && \
                   $_expStack([expr $stkLevel-3],type) == "open"} {
            set value "$_expStack([expr $stkLevel-2],value)"
            incr stkLevel -3
            set _expStack($stkLevel,value) $value
            set _expStack($stkLevel,type)  id
            incr stkLevel
         } else {
            set red 0
         }
      }
   }
   
   if {$stkLevel != 1} {
      return @0@@
   } elseif {$_expStack(0,type) != "id"} {
      return @0@@
   }
   
   return $_expStack(0,value)
}


# ---------------------------------------------------------
# checks for []-like constructs and substitutes them
# ---------------------------------------------------------

proc subs_alt {zkette} {
   global dwb_vars

   set result ""
   foreach word $zkette {

      #check whether there are [x,y]-like constructs in zkette and \
         count them:
      set pairs [count_pairs $word]
      if {$pairs < 0} {
         return @0@@
      }

      #begin substitution only when word contains \
         []-structure (pairs > 0):
      if {$pairs > 0} {

         #check, whether word consists of two or more quoted words:	
         if {[llength $word] > 1} {
            set quoted 1
         } else {
            set quoted 0
         }

         #quoted=0, i.e. word is not a phrase:
         if {$quoted == 0} {
            #generate words from the word with the []-structure:
            set res [generate_words $word]
            #more than one []-structure - call generate_words:
            for {set j 1} {$j < $pairs} {incr j} {
               set res [generate_words $res]
            }
         } else {
            #quoted=1, i.e. word is a phrase (and contains \
               []-structure):
            set res [generate_phrases $word $pairs]
         }

         #add the newly generated words to the result-list, include \
            ! and &
         if {[lindex $result end] == "!"} {
            set n 1
            while {$n < [llength $res]} {
               set res [linsert $res $n !]
               set n [expr $n+2]
            }
         } \
         elseif {[lindex $result end] == "\&"} {
            set n 1
            while {$n < [llength $res]} {
               set res [linsert $res $n \&]
               set n [expr $n+2]
            }
         }
         set result [concat $result $res]

      } else {
         #pairs = 0, add the word to result-list, no need for \
            substitution:
         set result [concat $result \"$word\"]
         #end of if "pairs > 0 - else"
      }

      #end of foreach word:	
   }

   return $result
}


# ---------------------------------------------------------
# generates words from []-structures
# ---------------------------------------------------------

proc generate_words {wordlist} {

   set res ""
   set result ""
   foreach word $wordlist {
      set word_length [string length $word]
      set open_bracket 0
      set close_bracket 0

      #iterate over the word until [x,y]-like structure is found:
      for {set i 0} {$i < $word_length} {incr i} {
         if {$open_bracket == 0} {
            if {[string index $word $i] == "\["} {
               set open_bracket 1
               set open_pos $i
            }
         } else {
            if {[string index $word $i] == "\]"} {
               set close_bracket 1
               set close_pos $i
            }
         }

         if {($open_bracket == 1) && ($close_bracket == 1)} {
            set num_new [expr [expr $close_pos - $open_pos] - 1]
            for {set j 1} {$j <= $num_new} {incr j} {
               #build new word and a temporary result-list:
               set new($j) ""
               append new($j) [string range $word 0 [expr $open_pos \
                  - 1]] [string index $word [expr $open_pos + $j]] \
                  [string range $word [expr $close_pos + 1] end]
               set res [concat $res $new($j)]
            }
            set open_bracket 0
            set close_bracket 0
            break
         }
      }
   }

   set result [concat $result $res]
   regsub -all " " $result " | " result

   return $result
}


# ---------------------------------------------------------
# generates phrase-list from phrase that contained []-structure(s)
# ---------------------------------------------------------

proc generate_phrases {wordlist pairs} {

   set result ""

   for {set i 0} {$i < [llength $wordlist]} {incr i} {
      set word [lindex $wordlist $i]
      set count [count_pairs $word]
      if {$count > 0} {
         #one or more [] in one word:
         set w($i) [generate_words $word]
         for {set j 1} {$j < $count} {incr j} {
            set w($i) [generate_words $w($i)]
            #w now contains a list with !many! alternatives
         }
      } else {
         #no [] at all, keep original word:
         set w($i) $word
         #w is equal to original word, no substitutions performed
      }
   }

   set phrases {""}
   for {set i 0} {$i < [llength $wordlist]} {incr i} {

      if {[llength $w($i)] == 1} {
         for {set j 0} {$j < [llength $phrases]} {incr j} {
            set new_p [concat [lindex $phrases $j] $w($i)]
            set phrases [lreplace $phrases $j $j $new_p]
         }
      } else {
         set new_list {}
         for {set j 0} {$j < [llength $phrases]} {incr j} {
            for {set k 0} {$k < [llength $w($i)]} {incr k} {
               set new_phrase($k) [concat [lindex $phrases $j] \
                  [lindex $w($i) $k]]
               lappend new_list $new_phrase($k)
            }
         }
         set phrases $new_list
      }
   }
   set result $phrases

   return $result
}


# ---------------------------------------------------------
# removes duplicates, list must be sorted
# ---------------------------------------------------------

proc removeDuplicates {reslist} {

   set res ""
   if {[llength $reslist] == 0} {
      return ""
   }
     
   set prevdata [lindex [split [lindex $reslist 0] "@"] 1]
   set previd [lindex [split [lindex $reslist 0] "@"] 0]

   set i 1
   while {$i < [llength $reslist]} {
      set id [lindex [split [lindex $reslist $i] "@"] 0]

      if {$id == $previd} {
      	 append prevdata "+[lindex [split [lindex $reslist $i] "@"] 1]"
      } else {
      	 lappend res "$previd@$prevdata"
         set prevdata [lindex [split [lindex $reslist $i] "@"] 1]
         set previd $id
      }
      incr i
   }
   lappend res "$previd@$prevdata"

   return $res   
}


# ---------------------------------------------------------
# counts [x,y]-structures in a word
# ---------------------------------------------------------

proc count_pairs {word} {

   set word_length [string length $word]
   set count 0
   set open_bracket 0
   set close_bracket 0

   for {set j 0} {$j < $word_length} {incr j} {

     if {[string index $word $j] == "\["} {
     	if {$open_bracket} {
           tk_messageBox -message "Fehlerhafter Suchausdruck: \"$word\"" \
              -icon error
     	   return -1
     	}
        set open_bracket 1
     }
     if {[string index $word $j] == "\]"} {
        if {$open_bracket} {
           incr count
           set open_bracket 0
        } else {
           tk_messageBox -message "Fehlerhafter Suchausdruck: \"$word\"" \
              -icon error
           return -1
        }
      }
   }
   
   if {$open_bracket} {
      tk_messageBox -message "Fehlerhafter Suchausdruck: \"$word\"" \
         -icon error
      return -1     
   }

   return $count
}


# ---------------------------------------------------------
# increase marks of entry fields
# ---------------------------------------------------------

proc IncCheckMark {name entry box} {
   global dwb_vars

   if {[$entry get] == ""} {
      return
   }

   set value [lindex [$box config -image] 4]
   set newvalue $dwb_vars(QUERY,choice,$value,next)

   if {$newvalue == $dwb_vars(QUERY,choice,3)} {
      set newvalue $dwb_vars(QUERY,choice,0)
   }

   $box config -image $newvalue
   
   incr dwb_vars(${name}_check)
   set dwb_vars(${name}_check) [expr $dwb_vars(${name}_check)%4]
   if {$dwb_vars(${name}_check) == 0} {
      set dwb_vars(${name}_check) 1
   }

   $dwb_vars(BHLP) bind $box -msg $dwb_vars(QUERY,tooltip,$dwb_vars(${name}_check))
}

# ---------------------------------------------------------
# decrease marks of entry fields
# ---------------------------------------------------------

proc DecCheckMark {name entry box} {
   global dwb_vars

   if {[$entry get] == ""} {
      return
   }

   set value [lindex [$box config -image] 4]
   set newvalue $dwb_vars(QUERY,choice,$value,prev)

   if {$newvalue == $dwb_vars(QUERY,choice,3)} {
      set newvalue $dwb_vars(QUERY,choice,2)
   }

   $box config -image $newvalue
   
   incr dwb_vars(${name}_check) -1
   set dwb_vars(${name}_check) [expr $dwb_vars(${name}_check)%4]
   if {$dwb_vars(${name}_check) == 0} {
      set dwb_vars(${name}_check) 1
   }

   $dwb_vars(BHLP) bind $box -msg $dwb_vars(QUERY,tooltip,$dwb_vars(${name}_check))
}


# ---------------------------------------------------------
# select words from intermediate search result
# ---------------------------------------------------------

proc WordSelection {textw word table} {
   global dwb_vars font resList
       
   if {[llength $dwb_vars(QUERY,RESULT,$table,$word)] == 0} {
      return
   }

   [$dwb_vars(RESULT,CONTROL).lf subwidget frame].all config -state normal
   [$dwb_vars(RESULT,CONTROL).lf subwidget frame].none config -state normal
   [$dwb_vars(RESULT,CONTROL).lf subwidget frame].part.min config -state normal
   [$dwb_vars(RESULT,CONTROL).lf subwidget frame].part.part config -state normal

   [$dwb_vars(QUERY,CONTROL).lf1 subwidget frame].cont config -state normal
   
   $textw tag configure WORD -font $font(h,b,r,14)
   $textw tag configure OCCURS -font $font(h,b,r,14)
   $textw tag configure KEYWORD -foreground blue

   set selwords ""
   set s $dwb_vars(QUERY,RESULT,NROFSR)
      
   $textw config -state normal
   $textw insert end "Suche nach "
   $textw insert end $word KEYWORD
   $textw insert end " in $dwb_vars(tableDesc,$table) ergab:\n"
   set rc 0
   foreach {w n x t} $dwb_vars(QUERY,RESULT,$table,$word) {
      set w [string trimleft $w "@"]
      set nv 0
      foreach v [split $n "@"] {
      	 incr nv $v
      }  	
      $textw insert end "\t"
      $textw insert end "\t$w" "WORD selw$x.$t.$n.$s"
      $textw insert end "  ($nv)    " "OCCURS selw$x.$t.$n.$s"
      $textw tag configure selw$x.$t.$n.$s -foreground black
      
      incr dwb_vars(totalmatches) $nv
      
      incr rc
      if {[expr $rc%2] == 0} {
         $textw insert end "\n"
      }
      if {[expr $rc%1000] == 0} {
         set dwb_vars(QUERY,TEXT,HEADER) "Diese Anfrage liefert $dwb_vars(totalmatches) mögliche Stellen"
         update
      }
   }
   $textw insert end "\n\n"
   $textw config -state disabled
   
   set dwb_vars(QUERY,TEXT,HEADER) "Diese Anfrage liefert $dwb_vars(totalmatches) mögliche Stellen"
   update
}


# ---------------------------------------------------------
# trace article in list
# ---------------------------------------------------------

proc TraceSearchResult {top textw xp yp} {
   global dwb_vars

   set tagnames [$textw tag names @$xp,$yp]
   foreach tag $tagnames {
      if {[string range $tag 0 3] == "selw" && $tag != \
         $dwb_vars(QUERY,TEXT,selw)} {
         if {$dwb_vars(QUERY,TEXT,selw) != ""} {
            $textw tag configure \
               $dwb_vars(QUERY,TEXT,selw) -background grey90 \
                  -borderwidth 0 -relief flat
         }
         $textw tag configure $tag -background $dwb_vars(DWB,TABBACK) \
            -borderwidth 1 -relief raised
         set dwb_vars(QUERY,TEXT,selw) $tag
      }
   }
}


proc ToggleSearchResult {top textw xp yp} {
   global dwb_vars

   set tagnames [$textw tag names @$xp,$yp]
   foreach tag $tagnames {
      if {[string range $tag 0 3] == "selw"} {
      	 set fg [lindex [$textw tag configure $tag -foreground] 4]
         set n [lindex [split $tag "."] 2]
      	 if {$fg == "black"} {
            $textw tag configure $tag -foreground grey60
            foreach v [split $n "@"] {
               incr dwb_vars(totalmatches) [expr -$v]
            }
         } else {
            $textw tag configure $tag -foreground black
            foreach v [split $n "@"] {
               incr dwb_vars(totalmatches) $v
            }
         }     
      }
   }
   set dwb_vars(QUERY,TEXT,HEADER) "Diese Anfrage liefert $dwb_vars(totalmatches) mögliche Stellen"
}


proc SearchResultSelect {mode} {
   global dwb_vars

   set textw $dwb_vars(HPTEXT)
   set tagnames [$textw tag names]
   set dwb_vars(totalmatches) 0
   foreach tag $tagnames {
      if {[string range $tag 0 3] == "selw"} {
         set n [lindex [split $tag "."] 2]
      	 if {$mode} {
            $textw tag configure $tag -foreground black
            foreach v [split $n "@"] {
               incr dwb_vars(totalmatches) $v
            }
         } else {
            $textw tag configure $tag -foreground grey60
         }
      }
   }	
   set dwb_vars(QUERY,TEXT,HEADER) "Diese Anfrage liefert $dwb_vars(totalmatches) mögliche Stellen"
}

proc SearchResultSelectByMatches {ew} {
   global dwb_vars
   
   set v [$ew get]
   if {$v == ""} {
      return
   }
   if {![regexp (\[0-9\]*) $v]} {
      return
   }
   
   set v [string trimleft $v "0"]
   if {$v == ""} {
      set v 0
   }
   
   set textw $dwb_vars(HPTEXT)
   set tagnames [$textw tag names]
   set dwb_vars(totalmatches) 0
   foreach tag $tagnames {
      if {[string range $tag 0 3] == "selw"} {
         set n [lindex [split $tag "."] 2]
         if {$n <= $v} {
            $textw tag configure $tag -foreground black
            foreach v [split [lindex [split $tag "."] 2] "@"] {
               incr dwb_vars(totalmatches) $v
            }
         } else {
            $textw tag configure $tag -foreground grey60
         }
      }
   }   
   set dwb_vars(QUERY,TEXT,HEADER) "Diese Anfrage liefert $dwb_vars(totalmatches) mögliche Stellen"
}


proc CompleteQuery {} {
   global dwb_vars resList font
   
   if {!$dwb_vars(execQuery)} {
      return
   }
   
   if {$dwb_vars(QUERY,SEARCHED) == ""} {
      return
   }
   
   foreach el [array names resList] {
      unset resList($el)
   }
 

   #set dwb_vars(tableNumber) 0
   foreach pair $dwb_vars(QUERY,SEARCHED) {
      if {![info exists dwb_vars(QUERY,RESTABLE,$pair)]} {
         set type [lindex [split $pair ","] 0]
         set searchword [lindex [split $pair ","] 1]
         set tablename result@$dwb_vars(tableNumber)
         mk::view layout RESDB.$tablename {DATA IDS}
         mk::view size RESDB.$tablename 0
         set reslist ""
         set tothits 0
      
         set dlist ""
         set dsep ""
         foreach r $dwb_vars(QUERY,RESULT,$pair) {
            set dataidx [lindex [split $r "+"] 2]         
            set offset [mk::get LEXICON.WORDIDX!$dataidx OFFSET:I]
            seek $dwb_vars(LEXICONDATA) $offset
            set data [gets $dwb_vars(LEXICONDATA)]
            append dlist "$dsep$data"
            set dsep ","
         }

         set dlist [lsort [split $dlist ","]]
         set prevletter ""      
         set letter ""      
         foreach div $dlist {
      	    set letter [string range $div 0 0]
      	    if {[lsearch $dwb_vars(avlSections) $letter] >= 0 &&
      	        ($dwb_vars(QUERY,sections) == "" ||
      	        ($dwb_vars(QUERY,sections) != "" && [lsearch $dwb_vars(QUERY,sections) $letter] >= 0))} {
      	       if {$letter != $prevletter} {
                  if {$prevletter != ""} {
                     mk::file close DB$prevletter
                     mk::file close IDX$prevletter
                  }
      	          mk::file open DB$letter $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.CDAT -readonly
      	          mk::file open IDX$letter $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.IDX -readonly
                  set prevletter $letter
                  set dwb_vars(INFOLABEL) "Suche im Wörterbuch läuft... ($tothits Treffer)"
                  if {$tothits > 100000} {
                     tk_messageBox -message "Die Suche nach \"$searchword\" lieferte bereits $tothits Treffer.\nDie Suche wird abgebrochen."
                     mk::file close DB$prevletter
                     mk::file close IDX$prevletter
                     return
                  }                         	
               }
               set pos [string range $div 1 end]
               set secdata [inflate [mk::get IDX$letter.WORDIDX!$pos DATA:B]]
               set secids [inflate [mk::get IDX$letter.WORDIDX!$pos IDS:B]]
               set sectags [inflate [mk::get IDX$letter.WORDIDX!$pos TAG:B]]
               
               regsub -all "," $secdata " " secdata
               regsub -all "," $secids " " secids
               regsub -all "," $sectags " " sectags
               set abspos 0
               for {set i 0} {$i < [llength $secdata]} {incr i} {
                  update
                  if {!$dwb_vars(execQuery)} {
                     mk::file close DB$prevletter
                     mk::file close IDX$prevletter
                     return
                  }
                  set idn [lindex $secids $i]
                  if {[string range $idn 0 0] == "G"} {
                     set id $idn
                  } else {
                     set id [format "G%s%05d" $letter $idn]
                  }
                  set tag [lindex $sectags $i]
                  set relpos [lindex $secdata $i]
                  incr abspos $relpos
                  #set id [lindex $secids $i]
                  if {$type == "full" || [lsearch $dwb_vars(${type}_types) $tag] >= 0} {
                     lappend reslist "$id@$letter$abspos"
                     incr tothits
                  } else {
                     #puts "$pair --> $tag no match!"
                  }
               }

               if {!$dwb_vars(execQuery)} {
                  mk::file close DB$prevletter
                  mk::file close IDX$prevletter
                  return
               } 
            }
         }
         if {$letter != ""} {
            mk::file close DB$prevletter
            mk::file close IDX$prevletter        
         }
         
         set reslist [lsort $reslist]
         set reslist [removeDuplicates $reslist]
         set dwb_vars(INFOLABEL) "Suche im Wörterbuch läuft... ($tothits Treffer) in [llength $reslist] Wortartikel"
         set i 0
         foreach el $reslist {
      	    set lv [split $el "@"]
      	    mk::set RESDB.$tablename!$i DATA [lindex $lv 1] IDS [lindex $lv 0]
      	    incr i
         }
         set dwb_vars(QUERY,RESTABLE,$pair) $dwb_vars(tableNumber)
         incr dwb_vars(tableNumber)
         unset reslist
         set dwb_vars(QUERY,tothits) $tothits
      }
   }

   set sridx 0
   foreach type $dwb_vars(QUERY,cats) { 	      
      set _stkLevel 0
      if {[info exists dwb_vars(RESLIST,$type)]} {
      	 unset dwb_vars(RESLIST,$type)
      }
      foreach el $dwb_vars(QUERY,srchexp,$type) {
         if {$el == "\&"} {
            set l1 $_expStack([expr $_stkLevel-2])
            set l2 $_expStack([expr $_stkLevel-1])
            set r [JoinResTables $l1 $l2]
            incr _stkLevel -2
            set _expStack($_stkLevel) $r
            incr _stkLevel
         } elseif {$el == "!"} {
            set l1 $_expStack([expr $_stkLevel-2])
            set l2 $_expStack([expr $_stkLevel-1])
            set r [SubResTables $l1 $l2]
            incr _stkLevel -2
            set _expStack($_stkLevel) $r
            incr _stkLevel
         } elseif {$el == "|"} {
            set l1 $_expStack([expr $_stkLevel-2])
            set l2 $_expStack([expr $_stkLevel-1])
            set r [MergeResTables $l1 $l2]
            incr _stkLevel -2
            set _expStack($_stkLevel) $r
            incr _stkLevel
         } elseif {[regexp (\<)(\[0-9\]*)(\<) $el all mode dist]} {
            set l1 $_expStack([expr $_stkLevel-2])
            set l2 $_expStack([expr $_stkLevel-1])
            set r [JoinResTables $l1 $l2 $dist]
            incr _stkLevel -2
            set _expStack($_stkLevel) $r
            incr _stkLevel
         } elseif {[regexp (=)(\[0-9\]*)(=) $el all mode dist]} {
            set l1 $_expStack([expr {$_stkLevel-2}])
            set l2 $_expStack([expr {$_stkLevel-1}])
            set r [JoinResTables $l1 $l2 $dist ordered]
            incr _stkLevel -2
            set _expStack($_stkLevel) $r
            incr _stkLevel
         } else {
            #set _expStack($_stkLevel) $sridx
            #removeDuplicates $sridx
            set word "[NormalizeWord [ConvertToLowercase $el]]"
            if {[info exists dwb_vars(QUERY,RESTABLE,$type,$word)]} {
               set _expStack($_stkLevel) $dwb_vars(QUERY,RESTABLE,$type,$word)
               incr _stkLevel
               incr sridx
            } else {
               return
            }
         }
      }
      if {$dwb_vars(QUERY,srchexp,$type) != ""} {
         set dwb_vars(RESLIST,$type) $_expStack(0)
         set dwb_vars(${type}_hits) [mk::view size RESDB.result@$dwb_vars(RESLIST,$type)]
         for {set i 0} {$i < [mk::view size RESDB.result@$dwb_vars(RESLIST,$type)]} {incr i} {
            set data [mk::get RESDB.result@$dwb_vars(RESLIST,$type)!$i DATA]
            regsub -all "\\\-" $data "+" data
            mk::set RESDB.result@$dwb_vars(RESLIST,$type)!$i DATA $data
         }
      }
   }  
   mk::file commit RESDB
   return ok
}              


proc JoinHitlists {} {
   global dwb_vars resList
   
   set res ""
   if {![info exists dwb_vars(RESLIST,full)]} {
      if {![info exists dwb_vars(RESLIST,keyw)]} {
      	 return $res
      } else {
      	 return $dwb_vars(RESLIST,keyw)
      }
   } else {
      if {![info exists dwb_vars(RESLIST,keyw)]} {
         return $dwb_vars(RESLIST,full)
      } else {
      	 return [JoinResTables $dwb_vars(RESLIST,keyw) $dwb_vars(RESLIST,full)]
      }   
   }
}


proc ClearResultDisplay {} {
   global dwb_vars
   
   set textw $dwb_vars(HPTEXT)
   
   $dwb_vars(HPTEXT) config -state normal
   $dwb_vars(HPTEXT) delete 1.0 end
   set dwb_vars(totalmatches) 0

   set tagnames [$textw tag names]
   foreach tag $tagnames {
      if {[string range $tag 0 3] == "selw"} {
         $textw tag delete $tag
      }
   }
   
   $dwb_vars(HPTEXT) config -state disabled
}

#---------------------------------------------------------
# create searchhelp display area
#---------------------------------------------------------

proc MkSearchHelpArea {top n} {
   global font dwb_vars
   #global hlp hlphead hlptext hlpcancel hlparea hlpw

   if {[winfo exists $top.help] == 0} {
   
      set hlp [frame $top.help -relief raised -bd 1]
   
      set hlphead [frame $hlp.hlphead]      
      #set hlptext [frame $hlp.hlptext]   
      set hlpcancel [frame $hlp.hlpcancel]      
   
      set hlparea [tixScrolledText $hlp.help -scrollbar y]
      set hlpw [$hlparea subwidget text]
      
      label $hlphead.head -text "- Wie werden Suchanfragen formuliert? -" \
         -bd 1 -relief flat -anchor c -background $dwb_vars(DWB,TABBACK) 
      
      button $hlpcancel.cancel -text "Schließen" \
         -command "CloseHelpWindow $n"
      DisplaySearchHelpText $hlpw
   }
 
   pack $hlphead -fill x
   #pack $hlptext -fill both
   pack $hlphead.head -fill x
   pack $hlparea -fill both -expand yes
   pack $hlpcancel
   pack $hlpcancel.cancel
   
   pack $hlp -fill both -expand yes
   update
   #place $hlp -x 100 -y 100
   return $hlp
}

#---------------------------------------------------------
# forget help window
#---------------------------------------------------------

proc CloseHelpWindow {n} {
   global dwb_vars
   
   MDIchild_Delete $n
   update
   set dwb_vars(OPENSRCHELP) -1
}


proc MDI_SearchHelpPopup {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENSRCHELP) >= 0} {
      return
   }
   
   set title "Erläuterungen zur Suche"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,close_cmd) "CloseHelpWindow $n"
   MDIchild_CreateWindow $n 0 0 1
   set w [MkSearchHelpArea $MDI_cvars($n,client_path) $n]
   
   set MDI_cvars($n,xw) [expr ([winfo width .workarea]- [winfo reqwidth \
      $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo height .workarea]- \
      [winfo reqheight $MDI_cvars($n,this)])/3]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]
   update
   
   MDIchild_Show $n
   MDI_ActivateChild $n
   update
   
   set dwb_vars(OPENSRCHELP) $n
   
   return $w
}


# ---------------------------------------------------------
# display help text for fulltext search
# ---------------------------------------------------------

proc DisplaySearchHelpText {textw} {
   global font

   $textw config -state normal -wrap word
   $textw ins e "Logische Operatoren:" b1
   $textw ins e " Mit den Schlüsselwörtern " n1
   $textw ins e "UND" kw
   $textw ins e ", " n1
   $textw ins e "ODER" kw
   $textw ins e " und " n1
   $textw ins e "NICHT" kw
   $textw ins e " können Teilanfragen kombiniert werden. Die Suche nach " n1
   $textw ins e "herz NICHT liebe" kw
   $textw ins e " liefert alle Artikel, in denen das Wort " n1
   $textw ins e "herz" kw
   $textw ins e ", nicht aber das Wort " n1
   $textw ins e "liebe" kw
   $textw ins e " vorkommt. " n1
   $textw ins e "UND" kw
   $textw ins e " kann auch weggelassen werden.\n" n1

   $textw ins e "\nTrunkierung:" b1
   $textw ins e " Der Platzhalter " n1
   $textw ins e "*" kw
   $textw ins e " steht für" n1
   $textw ins e " kein oder beliebig viele Zeichen" b1
   $textw ins e ". Die Suche nach " n1
   $textw ins e "herz*" kw
   $textw ins e " liefert alle Artikel, in denen Wörter vorkommen, die mit " n1
   $textw ins e "herz" kw
   $textw ins e " beginnen, also " n1
   $textw ins e "herz" kw
   $textw ins e ", " n1
   $textw ins e "herzachtung" kw
   $textw ins e ", " n1
   $textw ins e "herzader" kw
   $textw ins e ", usw." n1
   $textw ins e " Der Platzhalter " n1
   $textw ins e "?" kw
   $textw ins e " steht für" n1
   $textw ins e " genau ein beliebiges Zeichen" b1
   $textw ins e ". Die Suche nach " n1
   $textw ins e "h?tzen" kw
   $textw ins e " liefert also " n1
   $textw ins e "hetzen" kw
   $textw ins e " (antreiben), " n1
   $textw ins e "hitzen" kw
   $textw ins e " (heiß sein oder werden), " n1
   $textw ins e "hotzen" kw
   $textw ins e " (sich auf und nieder bewegen) und " n1
   $textw ins e "hutzen" kw
   $textw ins e " (kriechen, rutschen) als Ergebnis.\n" n1
   #$textw ins e " Beachten Sie: in der Betaversion wird nur Rechts-Trunkierung, d.h. keine Suchen der Form " n1
   #$textw ins e "*text" kw
   #$textw ins e " oder " n1
   #$textw ins e "*text*" kw
   #$textw ins e " unterstützt.\n" n1

   $textw ins e "\nSuchen nach Varianten:" b1
   $textw ins e " Mit Hilfe von in eckigen Klammern eingeschlossenen Alternativen können Varianten von Wörtern gesucht werden, z.B. " n1
   $textw ins e "z\[uü\]cken" kw
   $textw ins e " für " n1
   $textw ins e "zucken" kw
   $textw ins e " oder " n1
   $textw ins e "zücken" kw
   $textw ins e " oder, kombiniert mit Platzhaltern " n1
   $textw ins e "spr\[iü\]chw\[oö\]rt*" kw
   $textw ins e " für " n1
   $textw ins e "sprichwort" kw
   $textw ins e ", " n1
   $textw ins e "sprüchwort" kw
   $textw ins e ", " n1
   $textw ins e "sprichwörter" kw
   $textw ins e ", " n1
   $textw ins e "sprichwörtlich" kw
   $textw ins e " usw.\n" n1

   $textw ins e "\nNachbarschaftssuche:" b1
   $textw ins e " Durch Angabe eines Abstandes können Vorkommen von Wörtern eingeschränkt werden, z.B. sucht " n1
   $textw ins e "herz <2< liebe" kw
   $textw ins e " alle Passagen, in denen die Wörter " n1
   $textw ins e "herz" kw
   $textw ins e " und " n1
   $textw ins e "liebe" kw
   $textw ins e " höchstens zwei Wörter voneinander entfernt sind, d.h. zwischen ihnen steht höchstens ein anderes Wort." n1
   $textw ins e "\n\n\n\n" n1


   $textw tag config b1 -font $font(h,b,r,14) -lmargin2 20
   $textw tag config n1 -font $font(h,m,r,14) -lmargin2 20
   $textw tag config kw -font $font(h,b,r,14) -lmargin2 20 -foreground blue
   $textw config -state disabled -wrap word
}


proc UnifyWordSelection {word table} {
   global dwb_vars

   if {[llength $dwb_vars(QUERY,RESULT,$table,$word)] == 0} {
      return
   }
   set dwb_vars(QUERY,RESULT,$table,$word) [lsort $dwb_vars(QUERY,RESULT,$table,$word)]
   
   set res ""
   set el [lindex $dwb_vars(QUERY,RESULT,$table,$word) 0]
   set pw [lindex [split $el "+"] 0]
   set pn [lindex [split $el "+"] 1]
   set px [lindex [split $el "+"] 2]
   set pt [lindex [split $el "+"] 3]

   set i 1
   while {$i < [llength $dwb_vars(QUERY,RESULT,$table,$word)]} {
      set el [lindex $dwb_vars(QUERY,RESULT,$table,$word) $i]
      set w [lindex [split $el "+"] 0]
      set n [lindex [split $el "+"] 1]
      set x [lindex [split $el "+"] 2]
      set t [lindex [split $el "+"] 3]
    
      if {$w == $pw} {
      	 append pn "@$n"
      	 append px "@$x"
      	 append pt "@$t"
      } else {
      	 lappend res $pw
      	 lappend res $pn
      	 lappend res $px
      	 lappend res $pt
      	 set pw $w
      	 set pn $n
      	 set px $x
      	 set pt $t
      }   
   
      incr i
   }
   lappend res $pw
   lappend res $pn
   lappend res $px
   lappend res $pt
   
   set dwb_vars(QUERY,RESULT,$table,$word) $res
}
