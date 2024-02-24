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

#
# main Tcl-Script for queries
# ---------------------------------------------------------


# ---------------------------------------------------------
# init query values
# ---------------------------------------------------------

proc InitQueryVariables {} {
   global dwb_vars font resList

   set dwb_vars(QUERY,choice,0) [tix getimage orsymb]
   set dwb_vars(QUERY,tooltip,1) "ODER-Verknüpfung"
   set dwb_vars(QUERY,choice,1) [tix getimage andsymb]
   set dwb_vars(QUERY,tooltip,2) "UND-Verknüpfung"
   set dwb_vars(QUERY,choice,2) [tix getimage notsymb]
   set dwb_vars(QUERY,tooltip,3) "NICHT-Verknüpfung"
   set dwb_vars(QUERY,choice,3) [tix getimage unselected]
   set dwb_vars(QUERY,tooltip,0) ""

   for {set i 0} {$i < 4} {incr i} {
      set n [expr ($i+1)%4]
      set \
         dwb_vars(QUERY,choice,$dwb_vars(QUERY,choice,$i),next) \
         $dwb_vars(QUERY,choice,$n)
   }

   for {set i 3} {$i >= 0} {set i [expr $i - 1]} {
      set n [expr ($i-1)%4]
      set \
         dwb_vars(QUERY,choice,$dwb_vars(QUERY,choice,$i),prev) \
         $dwb_vars(QUERY,choice,$n)
   }

   set dwb_vars(tabwidgets) {gram source sigle dialect etym \
      fulltext}
   foreach el $dwb_vars(tabwidgets) {
      set dwb_vars(count_selected,$el) 0
   }

   set dwb_vars(QUERY,choice,open) [tix getimage book05]
   set dwb_vars(QUERY,choice,closed) [tix getimage book13]

   set dwb_vars(QUERY,choice,$dwb_vars(QUERY,choice,open),next) \
      $dwb_vars(QUERY,choice,closed)
   set dwb_vars(QUERY,choice,$dwb_vars(QUERY,choice,closed),next) \
      $dwb_vars(QUERY,choice,open)

   set dwb_vars(QUERY,style,1) [tixDisplayStyle imagetext \
      -fg maroon -bg grey90 -font $font(t,b,i,14)]
   set dwb_vars(QUERY,style,2) [tixDisplayStyle imagetext \
      -fg black -bg grey90 -font $font(t,b,i,12)]
   set dwb_vars(QUERY,style,3) [tixDisplayStyle imagetext \
      -fg black -bg grey90 -font $font(t,b,i,12)]
   set dwb_vars(QUERY,style,grimm) [tixDisplayStyle imagetext \
      -fg black -bg grey90 -font $font(z,m,i,12)]
   set dwb_vars(QUERY,style,4) [tixDisplayStyle imagetext \
      -fg black -bg grey90 -font $font(t,b,i,12)]
   set dwb_vars(QUERY,style,5) [tixDisplayStyle imagetext \
      -fg black -bg grey90 -font $font(t,b,i,12)]

   set dwb_vars(QUERY,wbs) { "DWB" open }

   #SetSourceQueryValues
   # SetDialectQueryValues
   InitTagHits
}

# ---------------------------------------------------------
# pack query area into MDI child window
# ---------------------------------------------------------

proc OpenQueryArea {top} {
   global dwb_vars

   set part $dwb_vars(WBAREA,DWB,ACTIVETAB)
   set pos [lsearch $dwb_vars(WBSECTIONS) $part]
   if {$pos >= 0} {
      $dwb_vars(WBAREA,DWB).ts select [expr $pos+2]
   } else {
      GotoArticle GA00001 0
   }
   $dwb_vars(tocbook) select 1
   
}

# ---------------------------------------------------------
# create query area
# ---------------------------------------------------------

proc MkQueryArea {top id} {
   global dwb_vars font

   set settings [frame $top.settings]
   MkFullSearchArea $settings

   # -- query settings area
   set searcharea [frame $settings.searcharea]

   # -- different query fields in notebook
   set dwb_vars(active_tab) "searchbook.gram"
   set searchbook [tabset $searcharea.book -side top -relief flat \
      -bd 1 -tiers 1 -tabborderwidth 0 -gap 0 -selectpad 3 \
      -dashes 0 -tearoff 0 -samewidth no -selectforeground black \
      -outerpad 0 -highlightthickness 0 -cursor top_left_arrow]
   set dwb_vars(searchbook) $searchbook

   set w [frame $searchbook.result]
   $searchbook insert end result -text "Suchergebnis" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) -state normal \
      -font $font(h,m,r,14) -window $w -fill both
 
   set w [frame $searchbook.options]
   $searchbook insert end options -text "Erweitert" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both

   set w [frame $searchbook.prevqueries]
   $searchbook insert end prevqueries -text "Bisherige Anfragen" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) -state normal \
      -font $font(h,m,r,14) -window $w -fill both \
      -command "DisplayPrevQueries"

   MkOptionArea $searchbook.options
   MkResultArea $searchbook.result $id
   MkPrevQueryArea $searchbook.prevqueries $id

   pack $searchbook -side top -expand yes -fill both
   pack $searcharea -side left -expand yes -fill both

   pack $settings -side top -fill both -expand yes

   set dwb_vars(QUERY,area) $settings

   update

   return $settings
}

# ---------------------------------------------------------
# iconify bookmark window
# ---------------------------------------------------------

proc MkResultArea {top id} {
   global dwb_vars font
   
   # -- hitlist display
   set hitlist [frame $top.hitlist]
   set dwb_vars(QUERY,hitarea) $hitlist

   set head [frame $hitlist.head -relief sunken -bd 1]
   set lefthits [MkFlatButton $head lefthits ""]
   $lefthits config -image [tix getimage arrleft] -command \
      "ScrollHitlistBack" -state disabled -background $dwb_vars(DWB,TABBACK)
   $dwb_vars(BHLP) bind $lefthits -msg "Vorherige Treffer"

   set leftendhits [MkFlatButton $head leftendhits ""]
   $leftendhits config -image [tix getimage arrleftend] -command \
      "ScrollHitlistToLeftEnd" -state disabled -background $dwb_vars(DWB,TABBACK)
   $dwb_vars(BHLP) bind $leftendhits -msg "Anfang der Trefferliste"

   label $head.lbl -text "Suchergebnis:" -font $font(h,m,r,14) \
      -pady 3 -padx 5 -relief raised -borderwidth 1 -anchor w \
      -textvariable dwb_vars(QUERY,hitlisthead) -background $dwb_vars(DWB,TABBACK) -foreground black
   set dwb_vars(QUERY,hitlisthead) "Suchergebnis:"

   set rightendhits [MkFlatButton $head rightendhits ""]
   $rightendhits config -image [tix getimage arrrightend] -command \
      "ScrollHitlistToRightEnd" -state disabled -background $dwb_vars(DWB,TABBACK)
   $dwb_vars(BHLP) bind $rightendhits -msg "Ende der Trefferliste"

   set righthits [MkFlatButton $head righthits ""]
   $righthits config -image [tix getimage arrright] -command \
      "ScrollHitlistFore" -state disabled -background $dwb_vars(DWB,TABBACK)
   $dwb_vars(BHLP) bind $righthits -msg "Nächste Treffer"

   pack $head.lbl -side left -expand yes -fill both
   pack $rightendhits -side right -fill y -ipadx 3
   pack $righthits -side right -fill y -ipadx 3
   pack $lefthits -side right -fill y -ipadx 3
   pack $leftendhits -side right -fill y -ipadx 3

   set hitarea [tixScrolledText $hitlist.hitarea -scrollbar both]
   set hittextw [$hitarea subwidget text]
   $hittextw config -height 15 -width 44 -padx 10 -pady 5 \
      -wrap none -background "grey97" -relief raised -bd 1 \
      -spacing1 1 -spacing2 1 -spacing3 1 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 right 35 left 45 left } \
      -exportselection yes -selectforeground white \
      -selectbackground grey80 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(h,m,r,8)

   ConfigureHitTextwTags $hittextw

   set dwb_vars(QUERY,hits) $hitarea

   pack $head -side top -fill x
   pack $hitarea -side top -expand yes -fill both
   pack $hitlist -side top -expand yes -fill both
}


# ---------------------------------------------------------
# iconify bookmark window
# ---------------------------------------------------------

proc IconifyQueryWindow {child} {
   global MDI_cvars MDI_vars
   global dwb_vars

   return

   set father [winfo parent $MDI_cvars($child,this)]

   if {[winfo exists $father.iconb$child] == 0} {
      set image [tix getimage iconsearch]
      set icon [MkFlatButton $father iconb$child ""]
      $icon config -borderwidth 1 -relief groove -image $image \
         -padx 2 -pady 2 -command "MDI_DeiconifyChild $child" \
         -background linen

      $dwb_vars(BHLP) bind $icon -msg \
         "Suche in der Datenbank"

      pack $icon -side left -anchor s -padx 5 -pady 5

      lower $icon
   }
}


# ---------------------------------------------------------
# save query to user database
# ---------------------------------------------------------

proc SaveQuery {} {
   global dwb_vars
   
   set entryset 0
   foreach cat $dwb_vars(QUERY,cats) {
      if {$dwb_vars(${cat}_eing_o) != ""} {
         set entryset 1
      }
   }

   if {!$entryset} {
      tk_messageBox -message "Eingabefelder unbesetzt!\nSuche kann nicht gespeichert werden"
      return
   }

   set date [clock format [clock seconds] -format "%d.%m.%Y %H:%M:%S"]
   set hits $dwb_vars(QUERY,totalhits)
   set input ""
   set sep ""
   foreach cat $dwb_vars(QUERY,cats) {
      if {$dwb_vars(${cat}_eing_o) != ""} {
         append input "$sep$cat=$dwb_vars(${cat}_eing_o)"
         set sep "\n"
      }
   }

   set qn [mk::view size UDB.QUERY]
   mk::set UDB.QUERY!$qn DATE $date INPUT $input NHITS $hits
   DisplayPrevQueries
}


# ---------------------------------------------------------
# deletes all entries in the currently active notebook-tab
# ---------------------------------------------------------

proc ResetQuery {} {
   global dwb_vars
  
   foreach type $dwb_vars(QUERY,cats) {
      set dwb_vars(${type}_eing_o) ""
      check_entry_fields $dwb_vars(QUERY,entryarea) $type
   }
   
   set dwb_vars(QUERY,RESULT,NROFSR) 0
   set dwb_vars(QUERY,SEARCHED) ""
   set dwb_vars(QUERY,totalhits) $dwb_vars(QUERY,NOTEXECUTED)
   set dwb_vars(DWBQUERY,tagnames) ""

   set dwb_vars(secn_eing_o) ""
   check_entry_fields $dwb_vars(QUERY,constrainarea) secn
   set dwb_vars(year_eing_o) ""
   check_entry_fields $dwb_vars(QUERY,constrainarea) year
   
   set dwb_vars(QUERY,sorting) 1
   
   set dwb_vars(QUERY,NORMSEARCH) 1
   set dwb_vars(QUERY,SENSECASE) 0
}


# ---------------------------------------------------------
# start query, prepare for cancellation
# ---------------------------------------------------------

proc StartQuery {} {
   global dwb_vars font

   set dwb_vars(QUERY,dlg) [DisplayInfoPopup .workarea \
      "Suche im Wörterbuch läuft..." black $dwb_vars(Special,TABBACK) 0]
   set dwb_vars(INFOLABEL) "Suche im Wörterbuch läuft (Abbruch im Moment nicht möglich)..."

   $dwb_vars(QUERY,REPORTAREA) config -state normal
   $dwb_vars(QUERY,REPORTAREA) delete 1.0 end
   $dwb_vars(QUERY,REPORTAREA) config -state disabled
   
   grab $dwb_vars(QUERY,CancelButton) 
   bind . <KeyPress-Escape> "CancelQuery"
   update
      
   set dwb_vars(execQuery) 1
   set res [ExecQuery]
   
   grab release $dwb_vars(QUERY,CancelButton)
   if {$res != "@0@@"} {
      $dwb_vars(searchbook) select 0
   }
   update
}


# ---------------------------------------------------------
# cancel query
# ---------------------------------------------------------

proc CancelQuery {} {
   global dwb_vars

   set dwb_vars(execQuery) 0
   update
   
   if {[info exists dwb_vars(QUERY,dlg)]} {
      if {[winfo exists $dwb_vars(QUERY,dlg)]} {
         grab release $dwb_vars(QUERY,dlg)
         destroy $dwb_vars(QUERY,dlg)
      }
   }
   grab release $dwb_vars(QUERY,CancelButton)
}


# ---------------------------------------------------------
# execute query
# ---------------------------------------------------------

proc ExecQuery {} {
   global dwb_vars resList kwic_list
   global MDI_cvars MDI_vars

   foreach el [array names resList] {
      if {[info exists resList($el)]} {
         unset resList($el)
      }
   }
   
   foreach el [array names kwic_list] {
      if {[info exists kwic_list($el)]} {
         unset kwic_list($el)
      }
   }

   if {[info exists dwb_vars(QUERY,SEARCHED)]} {
      foreach pair $dwb_vars(QUERY,SEARCHED) {
         if {[info exists dwb_vars(QUERY,RESULT,$pair)]} {
            unset dwb_vars(QUERY,RESULT,$pair)
         }
      }
   }
   
   set dwb_vars(QUERY,RESULT,NROFSR) 0
   set dwb_vars(QUERY,SEARCHED) ""
   set dwb_vars(QUERY,totalhits) $dwb_vars(QUERY,NOTEXECUTED)
   set dwb_vars(DWBQUERY,tagnames) ""

   set dwb_vars(CURRENTHITINDEX,DWB) -1
   set dwb_vars(FIRSTHITINDEX,DWB) -1
   set dwb_vars(LASTHITINDEX,DWB) -1
   set dwb_vars(HITNUMBER,DWB) 0
   set dwb_vars(QUERY,HITPOS) ""

   set dwb_vars(tmpTableNumber) 1

   set dwb_vars(QUERY,or_result,DWB) {}
   set dwb_vars(QUERY,and_result,DWB) {}
   set dwb_vars(QUERY,not_result,DWB) {}
   set resList(__empty__) {}

   set wehavetext 0
   foreach name $dwb_vars(QUERY,cats) {
      if {$dwb_vars(${name}_eing_o) != ""} {
         set wehavetext 1
         break
      }
   }
   if {!$wehavetext} {
      tk_messageBox -message "Sie haben keine Suchbegriffe eingegeben." \
         -icon error
      if {[winfo exists $dwb_vars(QUERY,dlg)]} {
         grab release $dwb_vars(QUERY,dlg)
         destroy $dwb_vars(QUERY,dlg)
      }
      return @0@@
   }

   if {[EvalQuerySettingsFulltext] == "@0@@"} {
      if {[winfo exists $dwb_vars(QUERY,dlg)]} {
         grab release $dwb_vars(QUERY,dlg)
         destroy $dwb_vars(QUERY,dlg)
      }
      return @0@@
   }
   set cqres [CompleteQuery]
   if {$cqres == "ok"} {
      set dwb_vars(QUERY,reslist) [SetupHitlist [CombineResults]]
      set dwb_vars(QUERY,totalhits) [mk::view size RESDB.result@$dwb_vars(QUERY,reslist)]
   }

   if {[winfo exists $dwb_vars(QUERY,dlg)]} {
      grab release $dwb_vars(QUERY,dlg)
      destroy $dwb_vars(QUERY,dlg)
   }

   if {$cqres == "ok"} {
      ShowHitlist 0
   }
   return
}


# ---------------------------------------------------------
# create persistent hitlist table 
# ---------------------------------------------------------

proc SetupHitlist {table} {
   global dwb_vars
   
   if {!$dwb_vars(execQuery)} {
      return
   }
   
   if {$table == ""} {
      return ""
   }
   
   set tablename result@$dwb_vars(tableNumber)
   set tnr $dwb_vars(tableNumber)
   incr dwb_vars(tableNumber)
   mk::view layout RESDB.$tablename {DATA IDS}
   mk::view size RESDB.$tablename 0

   set idlist ""
   for {set i 0} {$i < [mk::view size RESDB.result@$table]} {incr i} {
      #update
      if {!$dwb_vars(execQuery)} {
         return
      }
      set id [mk::get RESDB.result@$table!$i IDS]    
      set letter [string range $id 1 1]

      if {($dwb_vars(QUERY,sorting) == 1 || $dwb_vars(QUERY,sorting) == 2) &&
           $dwb_vars(QUERY,years) == ""} {
         set year 2000
      } else {
         set row [performQuery IDXDWB LEMMA "ID==$id"]
         if {[lindex $row 0] != ""} {
            set lfg [mk::get DBDWB.LEMMA![lindex $row 0] LFGNR:I]
            if {[mk::view size DBDWB.LFG] < $lfg} {
               set year 2000
            } else {
               set year [mk::get DBDWB.LFG!$lfg JAHR]
            }
         } else {
            set year 2000
         }
      }
      if {($dwb_vars(QUERY,sections) == "" && $dwb_vars(QUERY,years) == "") ||
          ($dwb_vars(QUERY,years) == "" && [lsearch $dwb_vars(QUERY,sections) $letter] >= 0) ||
          ($dwb_vars(QUERY,sections) == "" && [lsearch $dwb_vars(QUERY,years) $year] >= 0) ||
          ([lsearch $dwb_vars(QUERY,sections) $letter] >= 0 && [lsearch $dwb_vars(QUERY,years) $year] >= 0)} {
         if {$dwb_vars(QUERY,sorting) == 1 || $dwb_vars(QUERY,sorting) == 2} {
            lappend idlist "${id}@${year}@$i"
         } else {
            lappend idlist "${year}@${id}@$i"
         }
      }
   }
   if {$dwb_vars(QUERY,sorting) == 1 || $dwb_vars(QUERY,sorting) == 3} {
      set idlist [lsort $idlist]
   } else {
      set idlist [lsort -decreasing $idlist]
   }

   set r 0
   foreach item $idlist {
      set i [lindex [split $item "@"] 2]
      eval mk::set RESDB.$tablename!$r [mk::get RESDB.result@$table!$i]
      incr r
   }
   unset idlist
   
   #for {set i 0} {$i < [mk::view size RESDB.result@$table]} {incr i} {
   #   set id [mk::get RESDB.result@$table!$i IDS]    
   #   set letter [string range $id 1 1]
   #   if {$dwb_vars(QUERY,sections) == "" || [lsearch $dwb_vars(QUERY,sections) $letter] >= 0} {
   #   	 set data [mk::get RESDB.result@$table!$i DATA]
   #      eval mk::set RESDB.$tablename!$r DATA $data IDS $id
   #      incr r
   #   }
   #}
   mk::file commit RESDB
   
   return $tnr
}



# ---------------------------------------------------------
# display hits from db-query
# ---------------------------------------------------------

proc ShowHitlist {first} {
   global dwb_vars font wbr

   if {[winfo exists .infopopup]} {
      return
   }

   if {!$dwb_vars(execQuery)} {
      return
   }
   
   $dwb_vars(searchbook) select 0
   update
   
   set hittextw [$dwb_vars(QUERY,hits) subwidget text]
   $hittextw config -state normal
   foreach t [$hittextw tag names] {
      if {$t != "hitnr" && [string range $t 0 2] == "hit"} {
         $hittextw tag delete $t
      }	
   }
   $hittextw delete 1.0 end

   set n [mk::view size RESDB.result@$dwb_vars(QUERY,reslist)]
   if {$n > [expr $first+10]} {
      set m [expr $first+10]
   } else {
      set m $n
   }
   if {$n == 0} {
      set dwb_vars(QUERY,hitlisthead) "Ergebnis: kein Treffer"
      $dwb_vars(QUERY,hitarea).head.lefthits config -state disabled
      $dwb_vars(QUERY,hitarea).head.righthits config -state disabled
      $dwb_vars(QUERY,hitarea).head.leftendhits config -state disabled
      $dwb_vars(QUERY,hitarea).head.rightendhits config -state disabled
      #[$dwb_vars(QUERY,CONTROL).lf2 subwidget frame].export config -state disabled
      return
   } else {
      set dwb_vars(QUERY,hitlisthead) "Ergebnis: Artikel [expr $first+1] bis $m von $n"
      #[$dwb_vars(QUERY,CONTROL).lf2 subwidget frame].export config -state normal
   }

   set dlg [DisplayInfoPopup .workarea \
      "Erstelle Ergebnisübersicht..." black $dwb_vars(Special,TABBACK)]
   set dwb_vars(INFOLABEL) "Erstelle Ergebnisübersicht..."
   grab set $dlg
   update
      
   set i $first
   set in 0
   while {$i < $m && $i < $n} {
      set hitvals [mk::get RESDB.result@$dwb_vars(QUERY,reslist)!$i]
      set item [lindex $hitvals 3]
      set data [lindex $hitvals 1]
      
      set wbletter [string range $item 0 0]
      set index [expr [lsearch $dwb_vars(wbname) $wbletter] -1]
      set wbname [lindex $dwb_vars(wbname) $index]
      set wb [string toupper $wbname]

      set table "LEMMA"
      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $table "ID==$item"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $table "ID==$item"]
      }
      if {[lindex $row 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set lemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
         } else {
            set lemma [HTTPget "$wbname/$wbname" $table [lindex $row 0] NAME]
         }
         set anzahl [llength [lsort -unique [split $data "+"]]]
      } else {
         set lemma ""
         set anzahl 0
      }

      set table "GRAM"
      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $table "ID==$item"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $table "ID==$item"]
      }
      if {[lindex $row 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set gram "[mk::get DB$wbname.$table![lindex $row 0] TYPE]."
         } else {
            set gram "[HTTPget "$wbname/$wbname" $table [lindex $row 0] TYPE]."
         }
         set sep ","
      } else {
         set gram ""
         set sep ""
      }
      
      label $hittextw.lbl$i -image $wbr(empty) -bd 0
      $hittextw win cr end -win $hittextw.lbl$i -align baseline
      $hittextw ins e "\t[expr $i+1]:  " "hitnr hit$item hit@$i"
      $hittextw ins e "\t$lemma$sep" "lemma hit$item"
      if {$gram != ""} {
         $hittextw ins e " $gram" "gram hit$item"
      }
      if {$anzahl > 1} {
         $hittextw ins e " ($anzahl) " "matches hit$item"
      }
      $hittextw ins e "\n"
      
      $hittextw tag bind hit$item <Triple-1> [eval "list GotoSelectedHit $i $n 0"]
      $hittextw tag bind hit$item <Double-1> [eval "list GotoSelectedHit $i $n 0"]
      $hittextw tag bind hit$item <1> [eval "list GotoSelectedHit $i $n 0"]
      $hittextw tag bind hit$item <Enter> [eval "list HighSelectedHit $hittextw $item"]
      $hittextw tag bind hit$item <Leave> [eval "list LowSelectedHit $hittextw $item"]

      $hittextw ins e "\t\t"
      DisplayKWIC $hittextw $in $item $data $i $n
      $hittextw ins e "\n"
      update

      incr i
      incr in
   }
   $hittextw config -state disabled

   if {$n > [expr $first+10]} {
      $dwb_vars(QUERY,hitarea).head.righthits config -state normal
      $dwb_vars(QUERY,hitarea).head.rightendhits config -state normal
   } else {
      $dwb_vars(QUERY,hitarea).head.righthits config -state disabled
      $dwb_vars(QUERY,hitarea).head.rightendhits config -state disabled
   }

   if {$first > 9} {
      $dwb_vars(QUERY,hitarea).head.lefthits config -state normal
      $dwb_vars(QUERY,hitarea).head.leftendhits config -state normal
   } else {
      $dwb_vars(QUERY,hitarea).head.lefthits config -state disabled
      $dwb_vars(QUERY,hitarea).head.leftendhits config -state disabled
   }

   set dwb_vars(QUERY,firsthit) $first

   grab release $dlg
   destroy $dlg

   update
}

# ---------------------------------------------------------
# get keyword context for hit
# ---------------------------------------------------------

proc DisplayKWIC {w in item data hitnr hitanz} {
   #global dwb_vars kwic_list
   global dwb_vars
   
   set dwb_vars(contextLength) 6
   set letter [string range $item 1 1]
   mk::file open DB$letter $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.CDAT -readonly
   mk::file open IDX$letter $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.IDX -readonly
   #   lappend dwb_vars(openSections) $letter

   #set ridx [lindex $hitvals 3]  
   set poslist [split $data "+"]
   set p [string range [lindex $poslist 0] 1 end]
   
   set subrow [performQuery IDX$letter ARTICLE "FIRSTPOS:I<=$p" memory 1]
   set idx [lindex $subrow 0]
   set sidx [mk::get DB$letter.ARTICLE!$idx FIRSTPOS:I]
   if {$idx < [expr [mk::view size DB$letter.ARTICLE] - 1]} {
      set nextpos [mk::get DB$letter.ARTICLE![expr $idx+1] FIRSTPOS:I]
   } else {
      set nextpos -1
   }

   set ivlist ""
   set ppos ""
   foreach pos $poslist {
      if {$pos == $ppos} {
         continue
      } else {
         set ppos $pos
      }
      set pos [string range $pos 1 end]
      #puts "POSIX=$pos"
      set opos [expr $pos-$dwb_vars(contextLength)]
      #puts "OPOS=$opos, SIDX=$sidx"
      if {$opos < $sidx} {
         set opos $sidx
      }
      set cpos [expr $pos+$dwb_vars(contextLength)]
      #puts "CPOS=$cpos, NEXTPOS=$nextpos"
      if {$cpos >= $nextpos && $nextpos >= 0} {
      	 set cpos [expr $nextpos-1]
      }
      lappend ivlist [format "%08dA" $opos]
      lappend ivlist [format "%08dB" $pos]
      lappend ivlist [format "%08dC" $cpos]
   }
   
   set ivlist [lsort -unique $ivlist]
   set line 0
   set wp [lindex $ivlist 0]      
   set openIv 1
   set pi 1
   set p1 [string trimleft [string range $wp 0 7] "0"]
   if {$p1 == ""} {
      set p1 0
   }
   set t1 [string range $wp 8 8]
   while {$pi < [llength $ivlist]} {
      flush stdout
      set wpn [lindex $ivlist $pi]
      
      set p2 [string trimleft [string range $wpn 0 7] "0"]
      if {$p2 == ""} {
      	 set p2 0
      }
      set t2 [string range $wpn 8 8]
      
      for {set i $p1} {($i < $p2 && $openIv && $p1 != $p2) || ($i <= $p2 && $openIv && $p1 == $p2 && $t1 == "B")} {incr i} {    
      	 set ridx $i 
         set cridx [expr $ridx/1000]
         set iridx [expr $ridx%1000]
         if {$cridx < 0 || $cridx >= [mk::view size DB$letter.TEXT]} {
            return
         }
         if {![info exists kwic_list(tag,$letter,$cridx)]} {
            set kwic_list(tag,$letter,$cridx) [inflate [mk::get DB$letter.TEXT!$cridx TAG:B]]
         }
         if {$iridx >= [llength $kwic_list(tag,$letter,$cridx)]} {
            break
         }
         set tag [lindex $dwb_vars(textTypes) [lindex $kwic_list(tag,$letter,$cridx) $iridx]]
         if {![info exists kwic_list(word,$letter,$cridx)]} {
            set kwic_list(word,$letter,$cridx) [inflate [mk::get DB$letter.TEXT!$cridx WORD:B]]
         }
         set word [lindex $kwic_list(word,$letter,$cridx) $iridx]
         regsub -all "\\\\'" $word "\'" word
         regsub -all "\\\[" $word "\\\[" word
         regsub -all "\\\]" $word "\\\]" word
         regsub -all "\\\$" $word "\\\$" word
         if {$dwb_vars(MENU,subsign)} {
            set word [SubsSpecialChars $word]
         }
         set word [SubsChars $word]
         
         if {($t1 == "B" && $i == $p1)} {
            #if {![info exists kwic_list(pos,$letter,$cridx)]} {
            #   set kwic_list(pos,$letter,$cridx) [inflate [mk::get DB$letter.TEXT!$cridx POS:B]]
            #}
            #set pos [lindex $kwic_list(pos,$letter,$cridx) $iridx]
            set code "$w ins e \"$word\" \"keyword hit$item.$line $tag\""
            eval $code
            $w ins e " " "context hit$item.$line $tag"
         } else {
            set code "$w ins e \"$word \" \"context hit$item.$line $tag\""
            eval $code
         }
      }
           
      if {$t2 == "A"} {
      	 incr openIv
      }
      if {$t2 == "C"} {
      	 incr openIv -1
      }

      if {!$openIv} {
         $w ins e "\n\t" context 
         $w tag bind hit$item.$line <1> [eval "list GotoSelectedHit $hitnr $hitanz 0 $pos"]
         $w tag bind hit$item.$line <Enter> [eval "list HighSelectedHit $w $item $line"]
         $w tag bind hit$item.$line <Leave> [eval "list LowSelectedHit $w $item $line"]
         incr line
      }

      set p1 $p2
      set t1 $t2
      
      incr pi
   }
   mk::file close DB$letter
   mk::file close IDX$letter
}


# ---------------------------------------------------------
# highlight selected hit
# ---------------------------------------------------------

proc HighSelectedHit {w item {line ""}} {
   global dwb_vars

   if {$line == ""} {
      $w tag configure hit$item -relief solid -borderwidth 0 \
         -background $dwb_vars(Special,TABBACK) -bgstipple gray50
   } else {
      $w tag configure hit$item.$line -relief solid -borderwidth 0 \
         -background $dwb_vars(Special,TABBACK) -bgstipple gray50
   }
}

# ---------------------------------------------------------
# lowlight selected hit
# ---------------------------------------------------------

proc LowSelectedHit {w item {line ""}} {

   if {$line == ""} {
      $w tag configure hit$item -background grey97 \
         -borderwidth 1 -relief flat
   } else {
      $w tag configure hit$item.$line -background grey97 \
         -borderwidth 1 -relief flat
   }
   $w tag raise keyword       
}


# ---------------------------------------------------------
# select hit from list
# ---------------------------------------------------------

proc GotoSelectedHit {item hitanz mode {pos ""}} {
   #global dwb_vars wbr kwic_list
   global dwb_vars wbr

   if {[winfo exists .infopopup]} {
      return
   }

   set lemma_id [mk::get RESDB.result@$dwb_vars(QUERY,reslist)!$item IDS]
   set wbID [string range $lemma_id 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wbID]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]
   set active_textwidget $dwb_vars(WBTEXT,$wbname,1)

   #if {$mode} 
      set hittextw [$dwb_vars(QUERY,hits) subwidget text]
      $hittextw config -state normal
      if {$dwb_vars(CURRENTHITINDEX,$wbname) >= 0} {
         $hittextw tag config hit@$dwb_vars(CURRENTHITINDEX,$wbname) \
            -foreground black -background grey97 \
            -relief flat -borderwidth 0 -bgstipple ""
      #	 if {[winfo exists $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname)]} {
      #      $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname) \
      #         config -image $wbr(empty)
      #   }
      }
      $hittextw config -state disabled
   #

   if {$item < [expr $hitanz-1]} {
      $dwb_vars(WBAREAFRAME,$wbname).main.pane.lemma.f.pane.lemma.control.hfore config -state normal
   } else {
      $dwb_vars(WBAREAFRAME,$wbname).main.pane.lemma.f.pane.lemma.control.hfore config -state disabled
   }
   if {$item > 0} {
      $dwb_vars(WBAREAFRAME,$wbname).main.pane.lemma.f.pane.lemma.control.hback config -state normal
   } else {
      $dwb_vars(WBAREAFRAME,$wbname).main.pane.lemma.f.pane.lemma.control.hback config -state disabled
   }
   set dwb_vars(QUERY,HITPOS) "[expr $item+1] / $hitanz"

   GotoArticle $lemma_id 1

   set dlg [DisplayInfoPopup .workarea \
      "Markiere Treffer im Text..." black $dwb_vars(Special,TABBACK)]
   set dwb_vars(INFOLABEL) "Markiere Treffer im Text..."
   grab set $dlg
   update

   if {!$mode} {
      set data [mk::get RESDB.result@$dwb_vars(QUERY,reslist)!$item DATA]
      set letter [string range $lemma_id 1 1]
         mk::file open DB$letter $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.CDAT -readonly
         mk::file open IDX$letter $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.IDX -readonly
         #lappend dwb_vars(openSections) $letter

      set expsecs ""
      set allmarks [$active_textwidget mark names]
      set alltags [$active_textwidget tag names]
      
      set foma ""
      foreach ip [split $data "+"] {
         set ip [string range $ip 1 end]
         set cridx [expr $ip/1000]
         set iridx [expr $ip%1000]
         if {![info exists kwic_list(pos,$letter,$cridx)]} {
            set kwic_list(pos,$letter,$cridx) [inflate [mk::get DB$letter.TEXT!$cridx POS:B]]
         }
         set pos [lindex $kwic_list(pos,$letter,$cridx) $iridx]
         if {![info exists kwic_list(word,$letter,$cridx)]} {
            set kwic_list(word,$letter,$cridx) [inflate [mk::get DB$letter.TEXT!$cridx WORD:B]]
         }
         set word [lindex $kwic_list(word,$letter,$cridx) $iridx]

         set maxsec -1
         set maxwp -1
         set maxfp -1
         foreach m $allmarks {
            if {[string range $m 0 11] == "expwp$lemma_id"} {
               #$active_textwidget config -state normal
               #$active_textwidget insert $m "$m" boing
               #$active_textwidget tag configure boing -background yellow
               #$active_textwidget config -state disabled
               set xm [lindex [split $m "@"] 2]
               set xf [lindex [split $m "@"] 3]
               if {$pos >= $xf && $xf > $maxfp} {
                  set maxsec [lindex [split $m "@"] 1]
                  set maxwp $xm
                  set maxfp $xf
               }
               puts "M=$m, POS=$pos, XF=$xf, MAXFP=$maxfp, MAXSEC=$maxsec, XM=$xm"
            }
         }
         if {$maxsec >= 0 && $pos >= [expr $maxwp-5] && [lsearch $expsecs $maxsec] < 0 &&
             [lsearch $alltags srk${lemma_id}@$maxsec] < 0} {
            ExpandParagraph $lemma_id $maxsec 1
            lappend expsecs $maxsec
         }
         lappend foma $word
      }
      forAllMatches $lemma_id $active_textwidget [lsort -unique $foma] DWB
      #foreach sec [lsort -integer -decreasing $expsecs] {
      #   ExpandParagraph $lemma_id $sec 1
      #}	
      mk::file close IDX$letter
      mk::file close DB$letter
   }
   #TagFulltextHits $lemma_id $item $pos
   #return
   
   grab release $dlg
   destroy $dlg

   $active_textwidget tag configure emphasis \
      -background $dwb_vars(Special,TABBACK) -bgstipple gray50 -relief solid -borderwidth 0
   set pos [$active_textwidget tag ranges emphasis]
   if {[llength $pos] > 0} {
      $active_textwidget see [lindex $pos 0]
      SetLemmaHeader $active_textwidget $wbname
   }

   update

   if {$item > [expr $dwb_vars(QUERY,firsthit)+9] || $item < $dwb_vars(QUERY,firsthit)} {
      ShowHitlist [expr int($item/10)*10]
   } 
   
   set dwb_vars(CURRENTHITINDEX,$wbname) $item
   set hittextw [$dwb_vars(QUERY,hits) subwidget text]
   $hittextw tag config hit@$item -foreground blue \
      -background grey80 -relief solid -borderwidth 1
   #$hittextw.lbl$item config -image $wbr(exparticle)
   $hittextw config -state disabled
   set pos [$hittextw tag ranges hit$lemma_id]
   if {[llength $pos] > 0} {
      $hittextw see [lindex $pos 0]
   }
}

# ---------------------------------------------------------
# goto next hit
# ---------------------------------------------------------

proc ForeOneHit {wbname} {
   global dwb_vars wbr

   set hittextw [$dwb_vars(QUERY,hits) subwidget text]
   $hittextw tag config hit@$dwb_vars(CURRENTHITINDEX,$wbname) \
       -foreground black -background grey97 \
       -relief flat -borderwidth 0 -bgstipple ""
   #if {[winfo exists $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname)]} {
   #   $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname) \
   #      config -image $wbr(empty)
   #}

   incr dwb_vars(CURRENTHITINDEX,$wbname)
   set i $dwb_vars(CURRENTHITINDEX,$wbname)
   set hit [mk::get RESDB.result@$dwb_vars(QUERY,reslist)!$i]
   set item [lindex $hit 1]
   
   GotoSelectedHit $i [mk::view size RESDB.result@$dwb_vars(QUERY,reslist)] 0
}

# ---------------------------------------------------------
# goto previous hit
# ---------------------------------------------------------

proc BackOneHit {wbname} {
   global dwb_vars wbr

   set hittextw [$dwb_vars(QUERY,hits) subwidget text]
   $hittextw tag config hit@$dwb_vars(CURRENTHITINDEX,$wbname) \
      -foreground black -background grey97 \
      -relief flat -borderwidth 0 -bgstipple ""
   #if {[winfo exists $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname)]} {
   #   $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname) \
   #      config -image $wbr(empty)
   #}

   incr dwb_vars(CURRENTHITINDEX,$wbname) -1
   set i $dwb_vars(CURRENTHITINDEX,$wbname)
   set hit [mk::get RESDB.result@$dwb_vars(QUERY,reslist)!$i]
   set item [lindex $hit 1]

   GotoSelectedHit $i [mk::view size RESDB.result@$dwb_vars(QUERY,reslist)] 0
}

# ---------------------------------------------------------
# search in text-widget ...
# ---------------------------------------------------------

proc forAllMatches {id widget foma wb} {
   global dwb_vars

   # set splitchars "^|\\\[|\\\]|!|,|:|;|<|>|%|=|«|»|§|'|\\\(|\\\)|/|\\\"|\\\.|\\\?|\\\&|\\\$|\\\*|\\\+|\\\-|\\\\|\\\}|\\\{|\\\n|\\\t| |[format "%c" 173]"
   set splitchars "$|^|\\\[|\\\]|!|,|:|;|<|>|%|=|«|»|§|'|\\\(|\\\)|/|\\\"|\\\.|\\\?|\\\&|\\\$|\\\*|\\\+|\\\-|\\\\|\\\}|\\\{|\\\n|\\\t| |[format %c 160]"

   #consider only those ranges that are relevant
   set ranges [$widget tag ranges lem$id]
   set articlestart [lindex $ranges 0]
   set articleend [lindex $ranges 1]
   foreach {first last} $ranges {
      if {[$widget compare $first <= $articlestart]} {
         set articlestart $first
      }
      if {[$widget compare $last >= $articleend]} {
         set articleend $last
      }
   }
   
   set ranges {}
   foreach tag $dwb_vars(${wb}QUERY,tagnames) {
      set range [$widget tag ranges $tag]
      foreach {first last} $range {
         if {[$widget compare $articlestart <= $first] && \
             [$widget compare $last <= $articleend]} {
            lappend ranges $first
            lappend ranges $last
         }
      }
   }

   set ranges "1.0 end"
   set ranges [$widget tag ranges lem$id]
   #puts "RANGES=$ranges"
   #$widget tag add boing [lindex $ranges 0] [lindex $ranges 1]
   #$widget tag configure boing -background yellow

   set nwords [llength $foma]
   set iword 0
   set prevword ""
   foreach word $foma {
   if {$word == $prevword} {
      continue
   }
   if {$dwb_vars(MENU,subsign)} {
      set word [SubsSpecialChars $word]
   }
   set word [SubsChars $word]

   set prevword $word
   set word [string trim $word $splitchars]
   set spcword [SpaceWord $word]
   if {$dwb_vars(QUERY,SENSECASE)} {
      set caseop ""
   } else {
      set caseop "-nocase"
      #set word [AlternateDiacs $word]
      #set spcword [AlternateDiacs $spcword]
   }

   set pct [format "%.2f" [expr 100.0*$iword/$nwords]]
   set dwb_vars(INFOLABEL) "Markiere Treffer im Text (${pct}%)..."
   update

   foreach {start_index end_index} $ranges {
      set start_line [lindex [split $start_index "."] 0]
      set end_line [lindex [split $end_index "."] 0]

      if {$start_line == $end_line} {
         set hit $start_index
         set end [lindex [split $end_index "."] 1]
         set pos [lindex [split $hit "."] 1]

         while {$pos < $end} {
            if {$dwb_vars(QUERY,SENSECASE)} {
               set hit [$widget search -count range \
                  -regexp ($splitchars|^)(($word)|($spcword))(($splitchars)) $hit-1c \
                  $end_index]
            } else {
               set n_hit [$widget search -nocase -count n_range \
                  -regexp ($splitchars|^)(($word))(($splitchars)) $hit-1c \
                  $end_index]
               set s_hit [$widget search -nocase -count s_range \
                  -regexp ($splitchars|^)(($spcword))(($splitchars)) $hit-1c \
                  $end_index]
            }
            if {$n_hit != ""} {
               set spos [lindex [split $n_hit "."] 1]
               set htext [$widget get $start_line.$spos $start_line.$spos+${n_range}c]
               if {[string tolower [string range $htext 0 0]] != [string range $word 0 0]} {
                  incr spos
                  incr n_range -1
               }
               if {[string tolower [string range $htext end end]] != [string range $word end end]} {
                  incr n_range -1
               }
               set start_of_word "$start_line.$spos"
               set zeile [lindex [split $n_hit "."] 0]
               set position [expr $spos + $n_range]
               set end_of_word "$zeile.$position"
               foreach ht [$widget tag names $n_hit] {
                  if {[lsearch $dwb_vars(${wb}QUERY,tagnames) $ht] >= 0} {
                     #puts "2: $widget tag add emphasis $start_of_word $end_of_word"
                     $widget tag add emphasis $start_of_word $end_of_word
                  }
               }      
               #puts "$widget tag add emphasis $start_of_word $end_of_word"
               #$widget tag add emphasis $start_of_word $end_of_word
               set hit $end_of_word
               set pos [lindex [split $hit "."] 1]
            } 
            if {$s_hit != ""} {
               set spos [lindex [split $s_hit "."] 1]
               set htext [$widget get $start_line.$spos $start_line.$spos+${s_range}c]
               #puts "HTEXT=|$htext|, spcword=|$spcword|"
               if {[string tolower [string range $htext 0 0]] != [string range $spcword 0 0]} {
                  incr spos
                  incr s_range -1
               }
               if {[string tolower [string range $htext end end]] != [string range $spcword end end]} {
                  incr s_range -1
               }
               set start_of_word "$start_line.$spos"
               set zeile [lindex [split $s_hit "."] 0]
               set position [expr $spos + $s_range]
               set end_of_word "$zeile.$position"
               foreach ht [$widget tag names $s_hit] {
                  if {[lsearch $dwb_vars(${wb}QUERY,tagnames) $ht] >= 0} {
                     #puts "2: $widget tag add emphasis $start_of_word $end_of_word"
                     $widget tag add emphasis $start_of_word $end_of_word
                  }
               }               
               #puts "$widget tag add emphasis $start_of_word $end_of_word"
               #$widget tag add emphasis $start_of_word $end_of_word
               set hit $end_of_word
               set pos [lindex [split $hit "."] 1]
            } 
            if {$n_hit == "" && $s_hit == ""} {
               break
            }

            #end of while:
         }
      } else {
         set hit $start_index
         set end $end_index
               
         while {[$widget compare $hit < $end]} {
            if {$dwb_vars(QUERY,SENSECASE)} {
               set hit [$widget search -count range \
                  -regexp ($splitchars|^)(($word)|($spcword))(($splitchars)) $hit-1c \
                  $end_index]
            } else {
               set n_hit [$widget search -nocase -count n_range \
                  -regexp ($splitchars|^)(($word))(($splitchars)) $hit-1c \
                  $end_index]
               set s_hit [$widget search -nocase -count s_range \
                  -regexp ($splitchars|^)(($spcword))(($splitchars)) $hit-1c \
                  $end_index]
            }
            if {$n_hit != ""} {
               set spos [lindex [split $n_hit "."] 1]
               set htext [$widget get $start_line.$spos $start_line.$spos+${n_range}c]
               
               if {[string tolower [string range $htext 0 0]] != [string range $word 0 0]} {
                  incr spos
                  incr n_range -1
               }
               if {[string tolower [string range $htext end end]] != [string range $word end end]} {
                  incr n_range -1
               }
               #incr n_range -1
               #set spos [lindex [split $n_hit "."] 1]
               #set zeile [lindex [split $n_hit "."] 0]
               #set firstchar [$widget get $zeile.$spos]
               #if {[string first $firstchar $splitchars] >= 0} {
               #   incr spos
               #   incr n_range -1
               #}
               set zeile [lindex [split $n_hit "."] 0]
               set position [expr $spos + $n_range]
               set start_of_word "$zeile.$spos"
               #set position [expr $spos + [string length $word]]
               #set position [expr $spos + $n_range]
               set end_of_word "$zeile.$position"
               foreach ht [$widget tag names $n_hit] {
                  if {[lsearch $dwb_vars(${wb}QUERY,tagnames) $ht] >= 0} {
                     #puts "2: $widget tag add emphasis $start_of_word $end_of_word"
                     $widget tag add emphasis $start_of_word $end_of_word
                  }
               }
               set hit $end_of_word
            } 
            if {$s_hit != ""} {
               #incr s_range -1
               set spos [lindex [split $s_hit "."] 1]
               set zeile [lindex [split $s_hit "."] 0]
               set htext [$widget get $start_line.$spos $start_line.$spos+${s_range}c]
               if {[string tolower [string range $htext 0 0]] != [string range $spcword 0 0]} {
                  incr spos
                  incr s_range -1
               }
               if {[string tolower [string range $htext end end]] != [string range $spcword end end]} {
                  incr s_range -1
               }
               #set firstchar [$widget get $zeile.$spos]
               #if {[string first $firstchar $splitchars] >= 0} {
               #   incr spos
               #   incr s_range -1
               #}
               set start_of_word "$zeile.$spos"
               set position [expr $spos + [string length $word]]
               set position [expr $spos + $s_range]
               set end_of_word "$zeile.$position"
               foreach ht [$widget tag names $s_hit] {
                  if {[lsearch $dwb_vars(${wb}QUERY,tagnames) $ht] >= 0} {
                     #puts "2: $widget tag add emphasis $start_of_word $end_of_word"
                     $widget tag add emphasis $start_of_word $end_of_word
                  }
               }
               set hit $end_of_word
            } 
            if {$n_hit == "" && $s_hit == ""} {
               set hit $end_index
            }

            #end of while:
         }

         #end of if-else:       
      }

      #end of for:
   }
   incr iword
   }
}

# ---------------------------------------------------------
# tag the hits from the fulltext query/-ies in the text widget
# ---------------------------------------------------------

proc TagFulltextHits {id hitidx wpos} {
   global dwb_vars kwic_list

   set wb [string range $id 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set active_textwidget $dwb_vars(WBTEXT,$wbname,$dpidx)
   #delete tags that have possibly previously been set
   $active_textwidget tag delete emphasis

   set ipl [mk::get RESDB.result@$dwb_vars(QUERY,reslist)!$hitidx DATA]
   #set wpl ""
   #foreach ip [split $ipl "+"] {
   #   set ip [string range $ip 1 end]
   #   set cridx [expr $ip/1000]
   #   set iridx [expr $ip%1000]
   #   if {![info exists kwic_list(pos,$part,$cridx)]} {
   #      set kwic_list(pos,$part,$cridx) [inflate [mk::get DB$part.TEXT!$cridx POS:B]]
   #   }
   #   set pos [lindex $kwic_list(pos,$part,$cridx) $iridx]
   #   lappend wpl $pos
   #}
   
   #set explist {}
   #set maxsec -1
   #set maxwp -1
   #set maxfp -1
   #foreach m [$active_textwidget mark names] {
   #   if {[string range $m 0 11] == "expwp$id"} {
   #      set xm [lindex [split $m "@"] 2]
   #      set xf [lindex [split $m "@"] 3]
   #      if {$wpos >= $xf && $xf > $maxfp} {
   #         set maxsec [lindex [split $m "@"] 1]
   #         set maxwp $xm
   #         set maxfp $xf
   #      }
   #   }
   #}
   #puts "MAXSEC=$maxsec, WPOS=$wpos"
   #if {$maxsec >= 0 && $wpos >= $maxwp} {
   #   ExpandParagraph $id $maxsec 1	
   #}
   
   #return
   #set explist [lsort -decreasing $explist]
   
   #set mlist {}
   #foreach {word pl} $wpl {
   #   foreach pos $wpl {
   #      set pos [format "%08d" $pos]
   #      set i 0
   #      while {$i < [llength $explist]} {
   #         set el [lindex $explist $i]
   #         if {$pos > [string range $el 0 7]} {
   #            if {[string range $el 8 8] == "E"} {
   #               if {[lsearch -exact $mlist $el] < 0} {
   #                  lappend mlist $el
   #               }
   #            }
   #           break
   #         }
   #         incr i
   #      }
   #   }
   #}
   #foreach m $mlist {
   #   ExpandSubsection $active_textwidget $id $m
   #}

   #foreach ip [split $ipl "+"] {
   #   set ip [string range $ip 1 end]
   #   set cridx [expr $ip/1000]
   #   set iridx [expr $ip%1000]
   #   if {![info exists kwic_list(word,$part,$cridx)]} {
   #      set kwic_list(word,$part,$cridx) [inflate [mk::get DB$part.TEXT!$cridx WORD:B]]
   #   }
   #   set word [lindex $kwic_list(word,$part,$cridx) $iridx]
   #   
   #   if {[string range $word 0 2] == "@t@"} {
   #      set articlerange [$active_textwidget tag range lem$id]
   #      set articlestart [lindex $articlerange 0]
   #      set articleend [lindex $articlerange 1]
   #      set tag [string range $word 3 end]
   #      set tagranges [$active_textwidget tag range $tag]
   #      foreach {first last} $tagranges {
   #         if {[$active_textwidget compare $articlestart <= $first] && \
   #             [$active_textwidget compare $last <= $articleend]} {
   #            #$active_textwidget tag add emphasis$wpos $first $last
   #            $active_textwidget tag add emphasis $first $last
   #         }
   #      }
   #      $active_textwidget tag configure emphasis \
   #         -background $dwb_vars(Special,TABBACK) -bgstipple gray50 -relief solid -borderwidth 0
   #   } else {
   #      forAllMatches $id $active_textwidget $word $wpos
   #      $active_textwidget tag configure emphasis \
   #         -background $dwb_vars(Special,TABBACK) -bgstipple gray50 -relief solid -borderwidth 0
   #   }
   #}

   #forAllMatches $id $active_textwidget $word $wpos DWB
   $active_textwidget tag configure emphasis \
      -background $dwb_vars(Special,TABBACK) -bgstipple gray50 -relief solid -borderwidth 0

   if {$wpos == ""} {
      set pos [$active_textwidget tag ranges emphasis]
      if {[llength $pos] > 0} {
         $active_textwidget see [lindex $pos 0]
         SetLemmaHeader $active_textwidget $wbname
      }
   } else {
      set pos [$active_textwidget tag ranges emphasis]
      if {[llength $pos] > 0} {
         $active_textwidget see [lindex $pos 0]
         SetLemmaHeader $active_textwidget $wbname
      }
   }
}


# ---------------------------------------------------------
# scroll hitlist to left end
# ---------------------------------------------------------

proc ScrollHitlistToLeftEnd {} {
   global dwb_vars

   ShowHitlist 0
}


# ---------------------------------------------------------
# scroll hitlist to right end
# ---------------------------------------------------------

proc ScrollHitlistToRightEnd {} {
   global dwb_vars

   set n [mk::view size RESDB.result@$dwb_vars(QUERY,reslist)]
   set p [expr (($n-1)/10)*10+0]

   ShowHitlist $p
}


# ---------------------------------------------------------
# scroll hitlist forward
# ---------------------------------------------------------

proc ScrollHitlistFore {} {
   global dwb_vars

   ShowHitlist [expr $dwb_vars(QUERY,firsthit)+10]
}


# ---------------------------------------------------------
# scroll hitlist backward
# ---------------------------------------------------------

proc ScrollHitlistBack {} {
   global dwb_vars

   ShowHitlist [expr $dwb_vars(QUERY,firsthit)-10]
}


# ---------------------------------------------------------
# pack export area into MDI child window
# ---------------------------------------------------------

proc MDI_ExportArea {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild "Treffer exportieren"]
   MDIchild_CreateWindow $n 1 0 1
   set exportarea [exp_options $MDI_cvars($n,client_path) $n]
   set title "Treffer exportieren"
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,xw) 150
   set MDI_cvars($n,yw) 100
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]                       

   MDIchild_Show $n

   set dwb_vars(EXPORTAREA,MDI) $n
}


# ---------------------------------------------------------
# call up dialog for export options and file selection
# ---------------------------------------------------------

proc exp_options {top child} {
   global dwb_vars

   set exp_box [frame $top.exp_box]
   set dwb_vars(export,dialog) $child
   set dwb_vars(export,dialogtop) $top
   pack $exp_box -fill both -expand true
        set of_box [frame $exp_box.of_box]
   set opt_box [frame $of_box.opt_box]
   set format_box [frame $of_box.format_box]
   set name_box [frame $exp_box.name_box]

   set headline [label $name_box.headline -text "Bitte einen \
      Dateinamen eingeben oder eine Datei wählen:"]
   set headline2 [label $opt_box.headline2 -text \
      "Welche Informationen sollen\ngespeichert werden?"]
   set headline3 [label $format_box.headline3 -text "In welchem Format \
      soll\ngespeichert werden?"]

   set id [checkbutton $opt_box.id -variable dwb_vars(export,ID) \
      -text "LemmaID"]
   $id deselect
   set wb [checkbutton $opt_box.wb -variable dwb_vars(export,WB) \
      -text "Wörterbuchname"]
   $wb deselect
   set le [checkbutton $opt_box.le -variable dwb_vars(export,LE) \
      -text "Lemma"]
   $le select
   $le config -state disabled
   set gr [checkbutton $opt_box.gr -variable dwb_vars(export,GR) \
      -text "Grammat. Angaben"]
   $gr select
   $gr config -state disabled

   set html [radiobutton $format_box.html -text "HTML" -value "html" \
      -variable dwb_vars(export,FILE_TYPE)]
   set txt [radiobutton $format_box.txt -text "Nur Text" -value "txt" \
      -variable dwb_vars(export,FILE_TYPE)]
   $txt select

   #file select dialog:
   set fdialog [tixExFileSelectBox $name_box.fdialog]
   $fdialog config -filetypes {{{*} {* - Alle Dateitypen}}
        {{*.txt} {*.txt - Nur Textdateien}}
        {{*.html *.htm} {*.html - Nur HTML-Dateien}}}
   $fdialog config -command check_for_file
   $fdialog subwidget dir config -label "Verzeichnis"
   $fdialog subwidget file config -label "Dateiname"
   $fdialog subwidget types config -label "Filter"
   $fdialog subwidget hidden config -text "Versteckte Dateien \
      anzeigen"
   $fdialog subwidget cancel config -text "Abbrechen"
   $fdialog subwidget cancel config -command \
      "MDIchild_Delete $child"

   pack $of_box -side left -fill both -expand yes
        pack $opt_box -side top -fill both -expand yes -in $of_box
        pack $headline2 $id $wb $le $gr -in $opt_box -anchor w -padx 5 -pady 5
        pack $format_box -side bottom -fill both -expand yes -in $of_box
        pack $headline3 $html $txt -in $format_box -anchor w -padx 5 -pady 5
        pack $name_box -side right -anchor n
        pack $headline $fdialog -in $name_box -expand true -fill both -padx 8 -pady 8 -side top
        update
}


# ---------------------------------------------------------
# check if file exists - question user before overwriting
# ---------------------------------------------------------

proc check_for_file {file} {

   set overwrite "no"
   if {[file exists $file] == 1} {

      set frm [toplevel .frm]
      wm title $frm "Datei speichern"
      set top [label $frm.top -padx 20 -pady 10 -border 1 \
         -relief raised -anchor c -text "Datei \"$file\" existiert \
         schon\nÜberschreiben?"]
      set box [tixButtonBox $frm.box -orientation horizontal]
      $box add yes -text Ja -underline 0 -width 5 -command "
            destroy $frm
            export_data $file
         "
      $box add no -text Nein -underline 0 -width 5 -command \
         "destroy $frm"
      pack $box -in $frm -side bottom -fill x
      pack $top -in $frm -side top -fill x
      focus [$box subwidget yes]
   } else {
      export_data $file
   }
}


# ---------------------------------------------------------
# collect and format data
# ---------------------------------------------------------

proc export_data {file} {
   global dwb_vars

   busy hold . -cursor watch
   update

   #set context_range $dwb_vars(export,context)
   set id_selected $dwb_vars(export,ID)
   set wb_selected $dwb_vars(export,WB)
   set file_type $dwb_vars(export,FILE_TYPE)

   if {$file_type == "html"} {
      set br "<br>\n"
   } else {
      set br "\n"
   }

   #generate header with info concerning query
   set query_info "Ihre Suchanfrage lautete:$br$br"

   append query_info "Gramm. Angaben:"
   set gram 0
   if {[llength $dwb_vars(export,gram,or_txt)] != 0} {
      append query_info $br "ODER: $dwb_vars(export,gram,or_txt)"
      set gram 1
   }
   if {[llength $dwb_vars(export,gram,and_txt)] != 0} {
      append query_info $br "UND: $dwb_vars(export,gram,and_txt)"
      set gram 1
   }
   if {[llength $dwb_vars(export,gram,not_txt)] != 0} {
      append query_info $br "NICHT: $dwb_vars(export,gram,not_txt)"
      set gram 1
   }
   if {$gram == 0} {
      append query_info " -$br$br"
   } else {
      append query_info $br$br
   }

   append query_info "Belegstellen:"
   set sigl 0
   if {[llength $dwb_vars(export,sigl,txt)] != 0} {
      regsub -all {LOCS} $dwb_vars(export,sigl,txt) \
         {BELEGSTELLEN} dwb_vars(export,sigl,txt)
      regsub -all {SIGS} $dwb_vars(export,sigl,txt) \
         {SIGLEN} dwb_vars(export,sigl,txt)
      regsub -all {and} $dwb_vars(export,sigl,txt) \
         {und} dwb_vars(export,sigl,txt)
      append query_info $br "$dwb_vars(export,sigl,txt)"
      set sigl 1
   }
   if {$sigl == 0} {
      append query_info " -$br$br"
   } else {
      append query_info $br$br
   }

   append query_info "Textsorten:"
   set sourc 0
   if {[llength $dwb_vars(export,source,or_txt)] != 0} {
      append query_info $br "ODER: $dwb_vars(export,source,or_txt)"
      set sourc 1
   }
   if {[llength $dwb_vars(export,source,and_txt)] != 0} {
      append query_info $br "UND: $dwb_vars(export,source,and_txt)"
      set sourc 1
   }
   if {[llength $dwb_vars(export,source,not_txt)] != 0} {
      append query_info $br \
         "NICHT: $dwb_vars(export,source,not_txt)"
      set sourc 1
   }
   if {$sourc == 0} {
      append query_info " -$br$br"
   } else {
      append query_info $br$br
   }

   append query_info "Sprachen:"
   set etym 0
   if {[llength $dwb_vars(export,etym,or_txt)] != 0} {
      append query_info $br "ODER: $dwb_vars(export,etym,or_txt)"
      set etym 1
   }
   if {[llength $dwb_vars(export,etym,and_txt)] != 0} {
      append query_info $br "UND: $dwb_vars(export,etym,and_txt)"
      set etym 1
   }
   if {[llength $dwb_vars(export,etym,not_txt)] != 0} {
      append query_info $br "NICHT: $dwb_vars(export,etym,not_txt)"
      set etym 1
   }
   if {$etym == 0} {
      append query_info " -$br$br"
   } else {
      append query_info $br$br
   }

   append query_info "Volltext:"
   set full 0
   if {$dwb_vars(full_eing_o) != ""} {
      append query_info $br "Volltext: $dwb_vars(full_eing_o)"
      set full 1
   }
   if {$dwb_vars(keyw_eing_o) != ""} {
      append query_info $br "Stichwort: $dwb_vars(keyw_eing_o)"
      set full 1
   }
   if {$dwb_vars(gram_eing_o) != ""} {
      append query_info $br "Gramm. Angaben: $dwb_vars(gram_eing_o)"
      set full 1
   }
   if {$dwb_vars(sigl_eing_o) != ""} {
      append query_info $br "Sigle: $dwb_vars(sigl_eing_o)"
      set full 1
   }
   if {$dwb_vars(sens_eing_o) != ""} {
      append query_info $br \
         "Bedeutungsangaben: $dwb_vars(sens_eing_o)"
      set full 1
   }
   if {$dwb_vars(etym_eing_o) != ""} {
      append query_info $br "Etymologie: $dwb_vars(etym_eing_o)"
      set full 1
   }
   if {$full == 0} {
      append query_info " -$br$br"
   } else {
      append query_info $br$br
   }

   append query_info "Sie haben in folgenden Wörterbüchern gesucht: \
       $br$dwb_vars(wbs)$br$br Die Treffer:"

   if {$file_type == "html"} {
      set top \
         "<html>\n<head></head>\n<body>\n$query_info$br$br<table \
         border=1>\n"
      set bottom "\n</table>\n</body>\n</html>"
      set linestart "<tr><td>"
      set lineend "</td></tr>"
      set separator "</td><td>"
   } else {
      set top "$query_info$br$br"
      set bottom ""
      set linestart ""
      set lineend ""
      set separator "|"
   }

   set exp_data ""
   #collect necessary/requested data from various tables:
   set count -1
   foreach id $dwb_vars(QUERY,result) {
      set wbletter [string range $id 0 0]
      set index [expr [lsearch $dwb_vars(wbname) $wbletter] -1]
      set wbname [lindex $dwb_vars(wbname) $index]

      #get lemma:
      set table "LEMMA"
      set row [performQuery IDX$wbname $table "ID==$id"]
      if {[lindex $row 0] != ""} {
         set lemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
      } else {
         set lemma ""
      }

      #get gramm. angaben:
      set table "GRAM"
      set row [performQuery IDX$wbname $table "ID==$id"]
      if {[lindex $row 0] != ""} {
         set gramm [mk::get DB$wbname.$table![lindex $row 0] TYPE]
      } else {
         set gramm ""
      }

      incr count
      set entry ""
      set newline 0

      if {$id_selected == 1} {
         append entry $linestart$id$separator
         set newline 1
      }
      if {$wb_selected == 1} {
         if {$newline == 0} {
            append entry $linestart$wbname$separator
         } else {
            append entry $wbname$separator
         }
         set newline 1
      }
      if {$newline == 0} {
         append entry $linestart$lemma$separator$gramm$lineend
      } else {
         append entry $lemma$separator$gramm$lineend
      }
      #if {$context_range > 0} {
      #1 ermitteln der Umgebung(en)
      #2 eventuell mehrere Vorkommen des Lemmas im Artikel -->
      #  für jedes Vorkommen Kontext in extra Zeile, aber das
      #  davor nicht wiederholen
      #3        einfügen
      #  append entry $separator$context
      #}

      #add the entry-line to the text, new line
      append exp_data $entry\n
   }
   #number of entries = count+1

   #add header and foot
   set exp_data $top$exp_data$bottom

   busy release .
   update

   save_file $file $exp_data
}


# ---------------------------------------------------------
# save file
# ---------------------------------------------------------

proc save_file {file result} {
   global dwb_vars

   set fileID [open $file w]
   puts $fileID $result
   close $fileID

   set button [tk_messageBox -icon info -type ok -message \
      "Die Datei wurde gespeichert!" -title "Datei speichern"]

   ##unset dwb_vars(export,context)
   unset dwb_vars(export,ID)
   unset dwb_vars(export,LE)
   unset dwb_vars(export,GR)
   unset dwb_vars(export,WB)
   unset dwb_vars(export,FILE_TYPE)
   MDIchild_Delete $dwb_vars(EXPORTAREA,MDI)
   # MDI_DestroyChild $dwb_vars(export,dialogtop)
   unset dwb_vars(export,dialog)
   #unset dwb_vars(export,gram,or_txt)
   #unset dwb_vars(export,gram,and_txt)
   #unset dwb_vars(export,gram,not_txt)
   #unset dwb_vars(export,source,or_txt)
   #unset dwb_vars(export,source,and_txt)
   #unset dwb_vars(export,source,not_txt)
   #unset dwb_vars(export,etym,or_txt)
   #unset dwb_vars(export,etym,and_txt)
   #unset dwb_vars(export,etym,not_txt)
}


# ---------------------------------------------------------
# combine query results
# ---------------------------------------------------------

proc CombineLists {listname op} {
   global dwb_vars

   # combine or-queries in view

   foreach wb $dwb_vars(wbs) {
      while {[llength $dwb_vars(QUERY,$listname,$wb)] > 1} {
         set dwb_vars(QUERY,$listname,$wb) \
            [lsort $dwb_vars(QUERY,$listname,$wb)]

         foreach {restab1 restab2} $dwb_vars(QUERY,$listname,$wb) {
            break
         }

         set tab1 [lindex $restab1 1]
         set tab2 [lindex $restab2 1]
         
         if {$op == "or"} {
            set tab3 [MergeResTables $wb $tab1 $tab2]
         } elseif {$op == "and"} {
            set tab3 [JoinResTables $wb $tab1 $tab2]
         }
         set nres [format "%08d" [mk::view size RESDB.$tab3]]

         set dwb_vars(QUERY,$listname,$wb) \
            [lreplace $dwb_vars(QUERY,$listname,$wb) 0 1]

         lappend dwb_vars(QUERY,$listname,$wb) "$nres $tab3"
      }
   }
}


# ---------------------------------------------------------
# trace search process
# ---------------------------------------------------------

proc TraceSearch {infotext} {
   global dwb_vars

   $dwb_vars(QUERY,REPORTAREA) config -state normal
   regsub -all "\"" $infotext "\\\"" infotext
   regsub -all "\\\[" $infotext "\\\[" infotext
   set code "$dwb_vars(QUERY,REPORTAREA) insert end \"$infotext\""
   eval $code
   $dwb_vars(QUERY,REPORTAREA) config -state disabled
   
   $dwb_vars(QUERY,REPORTAREA) yview moveto 1.0
   update
}


# ---------------------------------------------------------
# configure hittextw display
# ---------------------------------------------------------

proc ConfigureHitTextwTags {w} {
   global dwb_vars font

   $w tag configure hitnr -font $font(h,b,r,14)      
   $w tag configure lemma -font $font(z,b,r,14)
   $w tag configure gram -font $font(z,b,i,14)
   $w tag configure matches -font $font(z,b,r,14)
   $w tag configure context -lmargin2 45 -lmargin1 35
   $w tag configure keyword -lmargin2 45 -lmargin1 35 \
      -background grey60 -bgstipple gray50
   $w tag configure ln1 -font $font(z,b,i,12) -lmargin1 20 -offset 6p
   $w tag configure ln2 -font $font(z,b,r,12) -lmargin1 20 -offset 6p
   $w tag configure l1 -font $font(z,m,i,18) -lmargin1 20
   $w tag configure l2 -font $font(z,m,r,18) -lmargin1 20
   $w tag configure g1 -font $font(z,m,i,14)
   $w tag configure g2 -font $font(z,m,r,14)
   $w tag configure cit2 -font $font(z,m,r,14)
   $w tag configure crt2 -font $font(z,m,r,12)
   $w tag configure cis2 -font $font(z,m,r,14)
   $w tag configure crs2 -font $font(z,m,r,12)
   $w tag configure ciau2 -font $font(z,m,r,14)
   $w tag configure crau2 -font $font(z,m,r,12)
   $w tag configure ia1 -font $font(z,m,i,14)
   $w tag configure ia2 -font $font(z,m,r,14)
   $w tag configure au1 -font $font(z,m,i,12)
   $w tag configure au2 -font $font(z,m,r,12)
   $w tag configure s1 -font $font(z,m,i,14) -lmargin1 10 -lmargin2 0
   $w tag configure s2 -font $font(z,m,r,14) -lmargin1 10 -lmargin2 0
   $w tag configure subs1 -font $font(z,m,i,12) -offset -4p
   $w tag configure subs2 -font $font(z,m,r,12) -offset -4p
   $w tag configure sn1 -font $font(z,m,i,14) -lmargin1 10 -lmargin2 0
   $w tag configure sn2 -font $font(z,m,r,14) -lmargin1 10 -lmargin2 0
   $w tag configure sngr1 -font $font(g,m,i,14)
   $w tag configure sngr2 -font $font(g,m,i,14)
   $w tag configure snhb1 -font $font(a,m,i,14)
   $w tag configure snhb2 -font $font(a,m,r,14)
   $w tag configure sus1 -font $font(z,m,i,12) -offset 4p
   $w tag configure sus2 -font $font(z,m,r,12) -offset 4p
   $w tag configure sut1 -font $font(z,m,i,12) -offset 4p
   $w tag configure sut2 -font $font(z,m,r,12) -offset 4p
   $w tag configure bir1 -font $font(z,m,i,14)
   $w tag configure bir2 -font $font(z,m,r,14)
   $w tag configure subir2 -font $font(z,m,r,12) -offset 4p
   $w tag configure br -font $font(z,m,r,14)
   $w tag configure brs -font $font(z,m,r,12) -offset 4p
   $w tag configure e1 -font $font(z,m,i,14)
   $w tag configure e2 -font $font(z,m,r,14)
   $w tag configure laa -font $font(z,m,i,14)
   $w tag configure la1 -font $font(z,m,i,14)
   $w tag configure la2 -font $font(z,m,r,14)
   $w tag configure q1 -font $font(z,m,i,14)
   $w tag configure q2 -font $font(z,m,r,14)
   $w tag configure rl -font $font(z,m,r,14)
   $w tag configure rla -font $font(z,m,i,14)
   $w tag configure d1 -font $font(z,m,i,14)
   $w tag configure d2 -font $font(z,m,r,14)
   $w tag configure t1 -font $font(z,m,i,14)
   $w tag configure t2 -font $font(z,m,r,14)
   $w tag configure b1 -font $font(z,m,i,14)
   $w tag configure b2 -font $font(z,m,r,14)
   $w tag configure p1 -font $font(z,m,i,14)
   $w tag configure p2 -font $font(z,m,r,14)
   $w tag configure v1 -font $font(z,m,i,12) -spacing1 3
   $w tag configure v2 -font $font(z,m,r,12) -spacing1 3
   $w tag configure rd -font $font(z,m,i,14)
   $w tag configure da1 -font $font(z,m,i,14)
   $w tag configure da2 -font $font(z,m,r,14)
   $w tag configure xr1 -font $font(z,m,i,14)
   $w tag configure xr2 -font $font(z,m,r,14)

   # fuer autorangaben in versen, spaeter korrigieren
   $w tag configure cibir2 -font $font(z,m,r,14)
   $w tag configure crbir2 -font $font(z,m,r,12)

   $w tag configure gr1 -font $font(g,m,i,14)
   $w tag configure gr2 -font $font(g,m,i,14)
   $w tag configure sgr1 -font $font(g,m,i,14)
   $w tag configure sgr2 -font $font(g,m,i,14)

   $w tag configure shb1 -font $font(a,m,r,14)
   $w tag configure shb2 -font $font(a,m,r,14)
}


proc MkPrevQueryArea {top id} {
   global dwb_vars font
   
   set queryarea [tixScrolledText $top.queryarea -scrollbar both]
   set querytextw [$queryarea subwidget text]
   $querytextw config -height 15 -width 44 -padx 10 -pady 5 \
      -wrap none -background "grey97" -relief raised -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 right 35 left 45 left } \
      -exportselection yes -selectforeground white \
      -selectbackground grey80 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(h,m,r,12)

   set dwb_vars(QUERY,prevquery) $queryarea
   $querytextw tag configure DATUM -font $font(h,b,r,12)
   $querytextw tag configure EINGABE -font $font(h,m,r,12)
   $querytextw tag configure ERGEBNIS -font $font(h,b,r,12)

   pack $queryarea -side top -expand yes -fill both
}


proc DisplayPrevQueries {} {
   global dwb_vars
   
   set w [$dwb_vars(QUERY,prevquery) subwidget text]
   $w config -state normal
   $w delete 1.0 end
   
   for {set i 0} {$i < [mk::view size UDB.QUERY]} {incr i} {
      set date [mk::get UDB.QUERY!$i DATE]
      set input [mk::get UDB.QUERY!$i INPUT]
      set hits [mk::get UDB.QUERY!$i NHITS]
      
      label $w.e$i -image [tix getimage orsymb] -bd 0
      $w win cr insert -win $w.e$i
      $dwb_vars(BHLP) bind $w.e$i -msg "Eintrag in Suchmaske übernehmen"
      bind $w.e$i <1> [eval list "SetQuery $w $i"]
      
      $w ins insert " "

      label $w.c$i -image [tix getimage notsymb] -bd 0
      $w win cr insert -win $w.c$i
      $dwb_vars(BHLP) bind $w.c$i -msg "Eintrag löschen"
      bind $w.c$i <1> [eval list "DeleteQuery $w $i"]
      
      $w ins insert "   $date" DATUM
      foreach pair [split $input "\n"] {
         set cat [lindex [split $pair "="] 0]
         set text [lindex [split $pair "="] 1]
         $w ins insert "   $dwb_vars(${cat}_label): $text" EINGABE
      }
      if {$hits != $dwb_vars(QUERY,NOTEXECUTED)} {
         $w ins insert "   Ergebnis: $hits Wortartikel" ERGEBNIS
      } else {
         $w ins insert "   $dwb_vars(QUERY,NOTEXECUTED)" ERGEBNIS
      }
      $w ins insert "\n"
   }
   
   $w config -state disabled	
}


proc SetQuery {w n} {
   global dwb_vars
   
   set input [mk::get UDB.QUERY!$n INPUT]
   
   ResetQuery
   
   foreach pair [split $input "\n"] {
      set cat [lindex [split $pair "="] 0]
      set text [lindex [split $pair "="] 1]
      set dwb_vars(${cat}_eing_o) $text
      check_entry_fields $dwb_vars(QUERY,entryarea) $cat
   }   	
}


proc DeleteQuery {w n} {
   global dwb_vars
   
   set choice [tk_messageBox -type yesno -default yes \
      -message "Wollen Sie den Eintrag wirklich löschen?" \
      -icon question]
      
   if {$choice == "no"} {
      return
   }
   
   for {set i $n} {$i < [expr [mk::view size UDB.QUERY]-1]} {incr i} {
      eval mk::set UDB.QUERY!$i [mk::get UDB.QUERY![expr $i+1]]
   }	
   
   mk::view size UDB.QUERY $i
   mk::file commit UDB
   DisplayPrevQueries
}


proc ScrollToNextHit {w xp yp} {

   set tr [$w tag nextrange emphasis @$xp,$yp]
   puts "TR=$tr"
   if {[lindex $tr 0] == ""} {
      return
   }
   
   $w see [lindex $tr 0]        
}