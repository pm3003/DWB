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

# Tcl-Script for wb area
# ---------------------------------------------------------


# ---------------------------------------------------------
# pack wb components into MDI child window
# ---------------------------------------------------------

proc MDI_QVZComponents {top menu name xp yp mode} {
   global dwb_vars
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild $name]
   set dwb_vars(WBAREA,MDI,$name) $n
   MDIchild_CreateWindow $n 1 1 0
   set indexarea [MkQVZComponents $MDI_cvars($n,client_path) $name]
   set MDI_cvars($n,hide_cmd) "IconifyWBWindow $n $name"

   if {$dwb_vars(use_user_conf)} {
      set MDI_cvars($n,width) $dwb_vars(userwindowsize,$name,x)
      set MDI_cvars($n,height) $dwb_vars(userwindowsize,$name,y)
      set xp $dwb_vars(userwindowpos,$name,x)
      set yp $dwb_vars(userwindowpos,$name,y)
   } else {
      set MDI_cvars($n,width) $dwb_vars(WBTEXT_WIDTH,$dwb_vars(DISPLAYMODE))
      set MDI_cvars($n,height) $dwb_vars(WBTEXT_HEIGHT,$dwb_vars(DISPLAYMODE))
   }

   if {$xp >= 0} {
      set MDI_cvars($n,xw) $xp
   } else {
      set MDI_cvars($n,xw) [expr [winfo width .workarea]-[winfo \
         reqwidth $MDI_cvars($n,this)]+$xp]
   }
   if {$yp >= 0} {
      set MDI_cvars($n,yw) $yp
   } else {
      set MDI_cvars($n,yw) [expr [winfo height .workarea]-[winfo \
         reqheight $MDI_cvars($n,this)]+$yp]
   }

   MDIchild_Show $n
   lower $MDI_cvars($n,this)

   if {$dwb_vars(use_user_conf)} {
      if {$dwb_vars(userwindowhide,$name)} {
         set mode 0
      } else {
         set mode 1
      }
   }

   if {$mode == 0} {
      MDIchild_Hide $n
      lower $MDI_cvars($n,this)
   }
   update

   .toolframe.wb.wb[string range $name 0 0] config \
      -command "MDI_DeiconifyChild $n; MDI_ActivateChild $n"
}


# ---------------------------------------------------------
# create index components
# ---------------------------------------------------------

proc MkQVZComponents {top wbname} {
   global dwb_vars

   MkQVZDisplayArea $top $wbname
   update
}


# ---------------------------------------------------------
# create index display area
# ---------------------------------------------------------

proc MkQVZDisplayArea {top wbname} {
   global dwb_vars font wbr

   set wbID [string range $wbname 0 0]
   set wbarea [frame $top.wbarea -background grey -borderwidth 1 \
      -relief flat]
   set dwb_vars(WBAREA,$wbname) $wbarea

   # create tabset
   set ts [tabset $wbarea.ts -side right -samewidth yes \
      -relief flat -bd 1 -tiers 2 -tabborderwidth 0 -gap 0 \
      -selectpad 1 -outerpad 0 -highlightthickness 0 \
      -dashes 0 -tearoff 0]

   for {set i 1} {$i <= $dwb_vars(MAXWBDISPLAY)} {incr i} {
      set w [frame $ts.f$i]
      set dwb_vars(WBAREAFRAME,$wbname) $w

      # --- create index main area
      set main [frame $w.main]

      # --- create lemma display area
      set lemma [frame $main.lemma]

      set lemmaarea [tixScrolledText $lemma.lemmaarea -scrollbar y]
      set wbtextw [$lemmaarea subwidget text]
      $wbtextw config -height 22 -width 44 -padx 10 -pady 5 \
         -wrap word -background "grey97" -relief sunken -bd 1 \
         -spacing1 1 -spacing2 1 -spacing3 1 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 40 80 }

      set dwb_vars($wbname,CURRSIGLE) ""

      set vsb [$lemmaarea subwidget vsb]
      $vsb config -troughcolor $dwb_vars($wbname,TABBACK)
      # $vsb config -command "ScrollWBText $wbtextw $wbname"

      set dwb_vars(WBTEXT,$wbname,$i) [$lemmaarea subwidget text]

      set cmd [format "Configure%sTags" $wbname]
      $cmd $i

      # --- create control area
      set control [frame $lemma.control -bd 1 -relief sunken]

      set page_back [MkFlatButton $control back ""]
      $page_back config -image [tix getimage arrleft] -command \
         "BackOneQVZSection $wbname" -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $page_back -msg \
         "Abschnitt zurückblättern"

      frame $control.sep -bd 1 -relief raised \
         -background $dwb_vars($wbname,TABBACK)
      frame $control.sep2 -bd 1 -relief raised -width 25 \
         -background $dwb_vars($wbname,TABBACK)

      set page_fore [MkFlatButton $control fore ""]
      $page_fore config -image [tix getimage arrright] -command \
         "ForeOneQVZSection $wbname" -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $page_fore -msg \
         "Abschnitt vorblättern"

      set hit_back [MkFlatButton $control hback ""]
      $hit_back config -image [tix getimage arrleft] -command \
         "BackOneQVZHit $wbname" -background $dwb_vars($wbname,TABBACK) \
         -state disabled
      $dwb_vars(BHLP) bind $hit_back -msg \
         "Im Suchergebnis zurückblättern"

      set hit_lbl [label $control.hitlbl -relief raised -bd 1 \
         -background $dwb_vars($wbname,TABBACK) -textvariable dwb_vars(QVZQUERY,HITPOS)]

      set hit_fore [MkFlatButton $control hfore ""]
      $hit_fore config -image [tix getimage arrright] -command \
         "ForeOneQVZHit $wbname" -background $dwb_vars($wbname,TABBACK) \
         -state disabled
      $dwb_vars(BHLP) bind $hit_fore -msg \
         "Im Suchergebnis vorblättern"

      pack $control.sep -side left -fill both -expand yes
      pack $control.hback -side left -fill y -ipadx 3
      pack $control.hitlbl -side left -fill y -ipadx 3
      pack $control.hfore -side left -fill y -ipadx 3
      pack $control.sep2 -side left -fill y
      pack $control.fore -side right -fill y -ipadx 3
      pack $control.back -side right -fill y -ipadx 3

      pack $control -side bottom -fill x
      pack $lemmaarea -side top -fill both -expand yes

      pack $lemma -side left -expand yes -fill both

      pack $main -side top -fill both -expand yes
   }

   set dwb_vars($wbname,loaded) {}
   set dwb_vars($wbname,loadpos) {}
   set dwb_vars(WBSUBSECS,$wbname,1,curr) 0
   set dwb_vars(HISTORY,$wbname,list) {}
   set dwb_vars(HISTORY,$wbname,pos) -1

   foreach sec $dwb_vars(WBSECTIONS) {

      set filename [format "$dwb_vars(driveletter)/Data/QVZ/%s.DAT" $sec]
      if {[file exists $filename]} {
         set state normal
      } else {
         set state disabled
      }

      set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
      set wb [lindex $dwb_vars(wbname) [expr $wbidx+1]]

      set id [format "Q%s0001" $sec]
      $ts insert end $sec -window $w -fill both \
         -font $font(h,m,r,14) -text $sec -state $state \
         -background $dwb_vars($wbname,TABBACK) \
         -selectbackground $dwb_vars($wbname,TABSELBACK) \
         -activebackground $dwb_vars($wbname,TABACTBACK) -command \
         "GotoQVZArticle $id 0"
   }

   set title [CreateWBTitle $ts $wbname]
   set cmd "SelectIntroduction$wbname"
   $cmd $title

   $ts insert 0 title1 -window $title -fill both \
      -font $font(h,m,i,14) -text "T." \
      -background $dwb_vars(Special,TABBACK) \
      -selectbackground $dwb_vars(Special,TABSELBACK) \
      -activebackground $dwb_vars(Special,TABACTBACK) \
      -command "set dwb_vars(WBAREA,QVZ,ACTIVETAB) title1"


   #$ts bind title1 <Enter> [eval list "DisplayInstInfo {Titelseite aufschlagen} %W %x %y"]
   #$ts bind title1 <Leave> [eval list "place forget .lfginfo"]

   set preface [MkPrefaceArea $ts $wbname "qv"]
   
   $ts insert 1 preface -window $preface -fill both \
      -font $font(h,m,i,14) -text "V." \
      -background $dwb_vars(Special,TABBACK) \
      -selectbackground $dwb_vars(Special,TABSELBACK) \
      -activebackground $dwb_vars(Special,TABACTBACK) \
      -command "OpenPreface $preface \"qv\""

   #$ts bind preface <Enter> [eval list "DisplayInstInfo {Vorworte aufschlagen} %W %x %y"]
   #$ts bind preface <Leave> [eval list "place forget .lfginfo"]

   pack $ts -fill both -expand yes

   pack $wbarea -side top -fill both -expand yes
   update

   set dwb_vars(WBAREA,$wbname,ACTIVETAB) title1
   $ts invoke 0
}


# ---------------------------------------------------------
# configure wb display
# ---------------------------------------------------------

proc ConfigureQVZTags {pos} {
   global dwb_vars font

   set textw $dwb_vars(WBTEXT,QVZ,1)

   $textw tag configure s1 -font $font(z,m,i,14) -justify left
   $textw tag configure s2 -font $font(z,m,r,14) -justify left
   $textw tag configure a1 -font $font(z,m,i,14) -justify left -foreground blue
   $textw tag configure a2 -font $font(z,m,r,14) -justify left -foreground blue
   $textw tag configure d1 -font $font(z,m,i,14) -justify left
   $textw tag configure d2 -font $font(z,m,r,14) -justify left
   $textw tag configure cia1 -font $font(z,m,i,14) -justify left -foreground blue
   $textw tag configure cia2 -font $font(z,m,r,14) -justify left -foreground blue
   $textw tag configure cra1 -font $font(z,m,i,12) -justify left -foreground blue
   $textw tag configure cra2 -font $font(z,m,r,12) -justify left -foreground blue
   $textw tag configure sus1 -font $font(z,m,i,12) -justify left -offset 4p
   $textw tag configure sus2 -font $font(z,m,r,12) -justify left -offset 4p
   $textw tag configure sua1 -font $font(z,m,i,12) -justify left -offset 4p
   $textw tag configure sua2 -font $font(z,m,r,12) -justify left -offset 4p
   $textw tag configure sud1 -font $font(z,m,i,12) -justify left -offset 4p
   $textw tag configure sud2 -font $font(z,m,r,12) -justify left -offset 4p

   #$textw tag configure s1 -font $font(z,m,i,14) -justify left
   #$textw tag configure s2 -font $font(z,m,r,14) -justify left
   #$textw tag configure cis2 -font $font(z,m,r,14) -justify left
   #$textw tag configure crs2 -font $font(z,m,r,12) -justify left
   #$textw tag configure l1 -font $font(z,m,i,14) -justify left
   #$textw tag configure l2 -font $font(z,m,r,14) -justify left

   $textw tag configure art0 -lmargin1 0 -lmargin2 40
   $textw tag configure art1 -lmargin1 0 -lmargin2 40
   $textw tag configure art2 -lmargin1 0 -lmargin2 40
   $textw tag configure art3 -lmargin1 0 -lmargin2 40
   $textw tag configure art6 -lmargin1 0 -lmargin2 40
   $textw tag configure art4 -lmargin1 40 -lmargin2 80
   $textw tag configure art5 -lmargin1 40 -lmargin2 80
   $textw tag configure art7 -lmargin1 40 -lmargin2 80
   $textw tag configure art9 -lmargin1 40 -lmargin2 80
}

# ---------------------------------------------------------
# select wb section
# mode 0: open section without selecting article
#      1: open section and select article
# ---------------------------------------------------------

proc GotoQVZArticle {lemma_id mode {lineidx ""}} {
   global dwb_vars wbi wbr wbm
   global MDI_vars MDI_cvars

   if {[winfo exists .infopopup]} {
      return
   }

   $dwb_vars(tocbook) select 3
   
   set wb [string range $lemma_id 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   #MDI_DeiconifyChild $dwb_vars(WBAREA,MDI,$wbname)
   #MDI_ActivateChild $dwb_vars(WBAREA,MDI,$wbname)

   set ts $dwb_vars(WBAREA,$wbname).ts

   set part [string range $lemma_id 1 1]
   set id [string range $lemma_id 2 end]
   set nr [string trimleft $id "0"]
   set section [expr ($nr-1)/$dwb_vars(SECTIONSIZE,QVZ)+1]

   puts "ID=$lemma_id, P=$part, AT=$dwb_vars(WBAREA,$wbname,ACTIVETAB)"

   if {$mode != 2} {
      AppendToHistory $wbname
   }

   if {$dwb_vars(WBAREA,$wbname,ACTIVETAB) != $part} {
      # have to select another tab

      set pos [lsearch $dwb_vars($wbname,loaded) $part]
      if {$pos >= 0} {
         # it is already in the queue, so bring it to the top

         set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
         $ts tab configure $part -window $ts.f$dpidx

         # move it to the end of the queue
         set dwb_vars($wbname,loaded) \
            [MoveToEnd $dwb_vars($wbname,loaded) $pos $part]
         set dwb_vars($wbname,loadpos) \
            [MoveToEnd $dwb_vars($wbname,loadpos) $pos $dpidx]
      } else {
         # it is not in the queue

         if {[llength $dwb_vars($wbname,loaded)] >= \
            $dwb_vars(MAXWBDISPLAY)} {
            # the queue is filled, so exchange the last one

            set dpidx [lindex $dwb_vars($wbname,loadpos) 0]
            $ts tab configure $part -window $ts.f$dpidx

            set dwb_vars($wbname,loaded) \
               [MoveToEnd $dwb_vars($wbname,loaded) 0 $part]
            set dwb_vars($wbname,loadpos) \
               [MoveToEnd $dwb_vars($wbname,loadpos) 0 $dpidx]
         } else {
            # the queue is not filled, so create new element

            set dpidx [expr [lindex $dwb_vars($wbname,loadpos) \
               end] + 1]
            $ts tab configure $part -window $ts.f$dpidx

            set dwb_vars($wbname,loaded) \
               [lappend dwb_vars($wbname,loaded) $part]
            set dwb_vars($wbname,loadpos) \
               [lappend dwb_vars($wbname,loadpos) $dpidx]
         }
         set dwb_vars(WBSUBSECS,$wbname,$part,curr) 0
      }
      set dwb_vars(WBAREA,$wbname,ACTIVETAB) $part
      if {$mode != 0} {
         $ts tab configure $part -command ""
      }
      set pos [lsearch $dwb_vars(WBSECTIONS) $part]
      $ts select [expr $pos+2]
      if {$mode != 0} {
         set id [format "Q%s00001" $part]
         $ts tab configure $part -command "GotoQVZArticle $id 0"
      }
   } else {
      set pos [lsearch $dwb_vars($wbname,loaded) $part]
      set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   }

   if {$dwb_vars(WBSUBSECS,$wbname,$part,curr) != $section} {
      # new section, load wb text

      set dlg [DisplayInfoPopup $dwb_vars(WBTEXT,$wbname,1) \
         "Schlage neuen Abschnitt auf..." black $dwb_vars(QVZ,TABBACK)]
      set dwb_vars(INFOLABEL) "Schlage neuen Abschnitt auf..."
      update

      $dwb_vars(WBTEXT,$wbname,1) config -state normal
      $dwb_vars(WBTEXT,$wbname,1) delete 1.0 end

      set w $dwb_vars(WBTEXT,$wbname,1)

      set first [expr ($section-1)*$dwb_vars(SECTIONSIZE,QVZ)+1]
      set last [expr $section*$dwb_vars(SECTIONSIZE,QVZ)]

      set firstID [format "%s%s%05d" $wb $part $first]
      set lastID [format "%s%s%05d" $wb $part $last]

      mk::file open TCLDB $dwb_vars(driveletter)/Data/QVZ/$part.DAT -readonly
      mk::file open TCLIDX $dwb_vars(driveletter)/Data/QVZ/$part.IDX -readonly

      set in 1
      set id $first
      while {$id <= $last} {
         set lemid [format "Q%s%05d" $part $id]
         set row [performQuery TCLIDX TCLCODE "ID==$lemid"]
         if {[lindex $row 0] != ""} {
            set tclcode [mk::get TCLDB.TCLCODE![lindex $row 0] CODE]
            if {[catch { eval $tclcode }]} {
               puts "error evaluating tclcode... ($lemid)"
            } else {
               # ok
            }
            #eval $tclcode
            # ShowQVZClassification $w $lemid
            $w ins e "\n"
         } else {
            break
         }
         incr id
      }

      mk::file close TCLDB
      mk::file close TCLIDX

      $dwb_vars(WBTEXT,$wbname,1) config -state disabled

      set dwb_vars(WBSUBSECS,QVZ,$part,curr) $section

      grab release $dlg
      destroy $dlg

      update
   }

   if {$lineidx != ""} {
      $dwb_vars(WBTEXT,QVZ,1) yview $lineidx
   } else {
      set tags [$dwb_vars(WBTEXT,QVZ,1) tag ranges \
         lem$lemma_id]
      if {[llength $tags] > 0} {
         $dwb_vars(WBTEXT,QVZ,1) yview [lindex $tags 0]
      }
   }
}


# ---------------------------------------------------------
# create image for wb hyperlink
# ---------------------------------------------------------

proc CrQVZImg {w src tgt mode} {
   global dwb_vars wbr wbm

   if {$tgt != 0} {
      set wbID [string range $tgt 0 0]
   } else {
      set wbID 0
   }

   label $w.lbl$dwb_vars(imagenr) -image $wbr(exparticle) -bd 0
   if {$wbID != 0} {
      bind $w.lbl$dwb_vars(imagenr) <1> [eval list "GotoQVZArticle $tgt 0"]
   }
   $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg $wbm($wbID)
   $w win cr end -win $w.lbl$dwb_vars(imagenr) -align baseline

   incr dwb_vars(imagenr)
}


# ---------------------------------------------------------
# goto next section in wb
# ---------------------------------------------------------

proc ForeOneQVZSection {wbname} {
   global dwb_vars

   set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
   set wb [lindex $dwb_vars(wbname) [expr $wbidx+1]]
   set nsecs [llength $dwb_vars(WBSECTIONS)]

   set section $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set sectionnr [lsearch $dwb_vars(WBSECTIONS) $section]
   set partno $dwb_vars(WBSUBSECS,$wbname,$section,curr)

   set id [format "%s%s%05d" $wb $section \
      [expr $partno*$dwb_vars(SECTIONSIZE,$wbname)+1]]

   GotoQVZArticle $id 1
}


# ---------------------------------------------------------
# goto previous section in wb
# ---------------------------------------------------------

proc BackOneQVZSection {wbname} {
   global dwb_vars

   set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
   set wb [lindex $dwb_vars(wbname) [expr $wbidx+1]]

   set nsecs [llength $dwb_vars(WBSECTIONS)]

   set section $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set sectionnr [lsearch $dwb_vars(WBSECTIONS) $section]
   set partno $dwb_vars(WBSUBSECS,$wbname,$section,curr)
   incr partno -1
   if {$partno <= 0} {
      return
   }

   set maxid [format "%s%s%05d" $wb $section \
      [expr ($partno-1)*$dwb_vars(SECTIONSIZE,$wbname)+1]]

   GotoQVZArticle $maxid 1
}



proc OpenQVZArea {top} {
   global dwb_vars

   set part $dwb_vars(WBAREA,DWB,ACTIVETAB)
   set pos [lsearch $dwb_vars(WBSECTIONS) $part]
   if {$pos >= 0} {
      $dwb_vars(WBAREA,DWB).ts select [expr $pos+2]
   } else {
      GotoArticle GA00001 0
   }
   $dwb_vars(tocbook) select 3
}


proc MkQVZQueryArea {top wbname} {
   global dwb_vars font
   
   set settings [frame $top.settings]
   MkQVZFullSearchArea $settings
   MkQVZResultArea $settings

   pack $settings -side top -fill both -expand yes

   set dwb_vars(QVZQUERY,area) $settings

   update

   return $settings	
}


proc MkQVZFullSearchArea {top} {
   global dwb_vars font

   set entrylist [frame $top.elist]

   set dwb_vars(QVZQUERY,cats) ""
   set e1 [MkQVZEntryField $entrylist qtxt "Gesamter Text"]
   set e2 [MkQVZEntryField $entrylist auto "Autoren"]
   set e3 [MkQVZEntryField $entrylist date "Datierung"]

   frame $entrylist.space0 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space1 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space2 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space3 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space4 -height 10 -borderwidth 1 -relief flat
   frame $entrylist.space6 -height 10 -borderwidth 1 -relief flat

   set dwb_vars(qtxt_types) ""
   set dwb_vars(auto_types) "0"
   set dwb_vars(date_types) "5"
   
   set dwb_vars(qtxt_tags) "ciau2 crau2 b1 b2 bir1 bir2 da2 g1 l1 l2 s1 s2 sgr2 sn2 t1 v1 v2 a2 a1 cra2 d2"
   set dwb_vars(auto_tags) "ciau2 crau2 a2 a1 s2 cra2"
   set dwb_vars(date_tags) "da2 d2 s2"

   foreach name $dwb_vars(QVZQUERY,cats) {
      set dwb_vars(${name}_tagids) 0
      foreach el $dwb_vars(${name}_types) {
         set dwb_vars(${name}_tagids) [expr $dwb_vars(${name}_tagids)|(1<<$el)]
      }
   }
   set dwb_vars(qtxt_tagids) 131071

   tixLabelFrame $entrylist.cmd -label "Suche"
   set f [$entrylist.cmd subwidget frame]
   [$entrylist.cmd subwidget label] config -font $font(h,m,r,12)
   
   set ok [MkFlatButton $f ok "Ausführen"]
   $ok config -command "StartQVZQuery" -font $font(h,m,r,12)
   set stop [MkFlatButton $f stop "Abbrechen"]
   $stop config -command "CancelQVZQuery" -font $font(h,m,r,12)
   set dwb_vars(QVZQUERY,CancelButton) $stop
   #set save [MkFlatButton $f save "Speichern"]
   #$save config -command "SaveQuery" -font $font(h,m,r,12) \
   #   -state normal
   set clear [MkFlatButton $f clear "Zurücksetzen"]
   $clear config -command "ResetQVZQuery" -font $font(h,m,r,12) \
      -state normal
   #set help [MkFlatButton $f help "Hilfe"]
   #$help config -command "MkSearchHelpArea" -font $font(h,m,r,12) \
   #   -state normal

   pack $ok $stop $clear -side left -padx 2

   pack $entrylist.space0 $e1 $entrylist.space1 \
      $e2 $e3 $entrylist.space4 \
      -side top -anchor e -fill x
   pack $entrylist.space2 -side top -fill x
   pack $entrylist.cmd $entrylist.space6 -side top 

   pack $entrylist -fill x -anchor n
   
   set dwb_vars(QVZQUERY,entryarea) $entrylist

   return
}


proc MkQVZResultArea {top} {
   global dwb_vars font
   
   # -- hitlist display
   set hitlist [frame $top.hitlist]
   set dwb_vars(QVZQUERY,hitarea) $hitlist

   set head [frame $hitlist.head -relief sunken -bd 1]
   set lefthits [MkFlatButton $head lefthits ""]
   $lefthits config -image [tix getimage arrleft] -command \
      "ScrollQVZHitlistBack" -state disabled -background $dwb_vars(QVZ,TABBACK)
   $dwb_vars(BHLP) bind $lefthits -msg "Vorherige Treffer"

   set leftendhits [MkFlatButton $head leftendhits ""]
   $leftendhits config -image [tix getimage arrleftend] -command \
      "ScrollQVZHitlistToLeftEnd" -state disabled -background $dwb_vars(QVZ,TABBACK)
   $dwb_vars(BHLP) bind $leftendhits -msg "Anfang der Trefferliste"

   label $head.lbl -text "Suchergebnis:" -font $font(h,m,r,14) \
      -pady 3 -padx 5 -relief raised -borderwidth 1 -anchor w \
      -textvariable dwb_vars(QVZQUERY,hitlisthead) -background $dwb_vars(QVZ,TABBACK) -foreground black
   set dwb_vars(QVZQUERY,hitlisthead) "Suchergebnis:"

   set rightendhits [MkFlatButton $head rightendhits ""]
   $rightendhits config -image [tix getimage arrrightend] -command \
      "ScrollQVZHitlistToRightEnd" -state disabled -background $dwb_vars(QVZ,TABBACK)
   $dwb_vars(BHLP) bind $rightendhits -msg "Ende der Trefferliste"

   set righthits [MkFlatButton $head righthits ""]
   $righthits config -image [tix getimage arrright] -command \
      "ScrollQVZHitlistFore" -state disabled -background $dwb_vars(QVZ,TABBACK)
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
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 right 35 left 45 left } \
      -exportselection yes -selectforeground white \
      -selectbackground grey80 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(z,m,r,12)

   ConfigureHitTextwTags $hittextw

   set dwb_vars(QVZQUERY,hits) $hitarea

   pack $head -side top -fill x
   pack $hitarea -side top -expand yes -fill both
   pack $hitlist -side top -expand yes -fill both
}


proc MkQVZEntryField {parent name text {mode 0}} {
   global dwb_vars font

   set box [frame $parent.$name]
   tixLabelEntry $box.lbe -label "$text: " -labelside left \
      -borderwidth 0 -relief flat
   $box.lbe subwidget label config -anchor e -width 22 \
      -font $font(h,m,r,14)
   set ew [$box.lbe subwidget entry]
   $ew config -textvariable dwb_vars(${name}_qeing_o) \
      -font $font(h,b,r,14) -foreground blue
   set dwb_vars(${name}_qeing_o) ""
   bind $ew <Return> "StartQVZQuery"
   label $box.check -image $dwb_vars(QUERY,choice,3)
   if {!$mode} {
      bind $box.check <1> "IncCheckMark $name $ew $box.check"
      bind $box.check <3> "DecCheckMark $name $ew $box.check"
   }
   bind $ew <KeyRelease> "
      check_entry_fields $parent $name
      ConvertEntities $ew 0
   "
   
   pack $box.check -side right -padx 5
   pack $box.lbe -side left -fill x -expand yes

   set dwb_vars(QVZQUERY,TEXT,CHECK,$name) $box.check

   lappend dwb_vars(QVZQUERY,cats) $name
   set dwb_vars(${name}_check) 0
   set dwb_vars(${name}_label) $text

   return $box
}


proc StartQVZQuery {} {
   global dwb_vars font

   set dwb_vars(QUERY,dlg) [DisplayInfoPopup .workarea \
      "Suche im Quellenverzeichnis läuft..." black $dwb_vars(Special,TABBACK)]
   set dwb_vars(INFOLABEL) "Suche im Quellenverzeichnis läuft..."

   grab $dwb_vars(QVZQUERY,CancelButton) 
   update

   set dwb_vars(execQuery) 1
   ExecQVZQuery
   
   grab release $dwb_vars(QVZQUERY,CancelButton)
   update
}


# ---------------------------------------------------------
# cancel query
# ---------------------------------------------------------

proc CancelQVZQuery {} {
   global dwb_vars

   set dwb_vars(execQuery) 0
   update

   if {[info exists dwb_vars(QUERY,dlg)]} {
      if {[winfo exists $dwb_vars(QUERY,dlg)]} {
         grab release $dwb_vars(QUERY,dlg)
         destroy $dwb_vars(QUERY,dlg)
      }
   }
   grab release $dwb_vars(QVZQUERY,CancelButton)
}


# ---------------------------------------------------------
# deletes all entries in the currently active notebook-tab
# ---------------------------------------------------------

proc ResetQVZQuery {} {
   global dwb_vars
  
   foreach type $dwb_vars(QVZQUERY,cats) {
      set dwb_vars(${type}_qeing_o) ""
      check_entry_fields $dwb_vars(QVZQUERY,entryarea) $type
   }
}


proc ExecQVZQuery {} {
   global dwb_vars resList kwic_list
   global MDI_cvars MDI_vars

   foreach el [array names resList] {
      unset resList($el)
   }
   
   foreach el [array names kwic_list] {
      unset kwic_list($el)
   }

   set dwb_vars(CURRENTHITINDEX,QVZ) -1
   set dwb_vars(FIRSTHITINDEX,QVZ) -1
   set dwb_vars(LASTHITINDEX,QVZ) -1
   set dwb_vars(HITNUMBER,QVZ) 0
   set dwb_vars(QVZQUERY,HITPOS) ""

   set dwb_vars(tmpTableNumber) 1

   set dwb_vars(QUERY,or_result,QVZ) {}
   set dwb_vars(QUERY,and_result,QVZ) {}
   set dwb_vars(QUERY,not_result,QVZ) {}
   set resList(__empty__) {}

   EvalQVZQuerySettingsFulltext
   CompleteQVZQuery
   set dwb_vars(QVZQUERY,reslist) [SetupQVZHitlist [CombineQVZResults]]
   set dwb_vars(QVZQUERY,totalhits) [mk::view size RESDB.result@$dwb_vars(QVZQUERY,reslist)]

   if {[winfo exists $dwb_vars(QUERY,dlg)]} {
      grab release $dwb_vars(QUERY,dlg)
      destroy $dwb_vars(QUERY,dlg)
   }
   ShowQVZHitlist 0

   return
}


proc EvalQVZQuerySettingsFulltext {} {
   global dwb_vars

   foreach name $dwb_vars(QVZQUERY,cats) {
      set dwb_vars(QVZQUERY,srchexp,$name) ""
   }
   set dwb_vars(QVZQUERY,RESULT,NROFSR) 0
   set dwb_vars(QVZQUERY,SEARCHED) ""
   set dwb_vars(QVZQUERY,totalhits) ""
   set dwb_vars(QVZQUERY,tagnames) ""

   foreach name $dwb_vars(QVZQUERY,cats) {
      set dwb_vars(${name}_eval) ""
      set dwb_vars(${name}_hits) ""
      set dwb_vars(${name}_qeing) [PPSearchExpression [PreParseSearchExpression $dwb_vars(${name}_qeing_o)]]
      if {[llength $dwb_vars(${name}_qeing)] > 0} {
         foreach tag $dwb_vars(${name}_tags) {
            if {[lsearch $dwb_vars(QVZQUERY,tagnames) $tag] < 0} {
               lappend dwb_vars(QVZQUERY,tagnames) $tag
            }
         }
         set dwb_vars(${name}_qeing) [subs_alt $dwb_vars(${name}_qeing)]
         QVZfullsearch $name $dwb_vars(${name}_qeing)
      }
   }
}


proc QVZfullsearch {type srchexp} {
   global dwb_vars
  
   set prsdsrchexp [ParseSearchExpression $srchexp]
   set dwb_vars(QVZQUERY,srchexp,$type) $prsdsrchexp
   
   set _stkLevel 0
   foreach el $prsdsrchexp {
      if {$el == "\&" || $el == "!" || $el == "|" || \
          [regexp (\<)(\[0-9\]*)(\<) $el all mode dist] || \
          [regexp (=)(\[0-9\]*)(=) $el all mode dist]} {
      } else {
         set word "[NormalizeWord [ConvertToLowercase $el]]"
         
         set row [performWordQuery QVZLEXICON "WORD=$word" 0 1 $dwb_vars(${type}_tagids)]
         set x 0
         foreach r $row {
            set w [string trimleft [lindex [split $r "+"] 0] "@"]
            set xn [lindex [split $r "+"] 1]
            incr x $xn
         }
         append dwb_vars(${type}_eval) " $word ($x)"
         if {!$dwb_vars(execQuery)} {
            return
         }
         set dwb_vars(QVZQUERY,RESULT,$type,$word) $row
         lappend dwb_vars(QVZQUERY,SEARCHED) "$type,$word"
            
         incr dwb_vars(QVZQUERY,RESULT,NROFSR)
      }
   }
}


proc CompleteQVZQuery {} {
   global dwb_vars resList font
   
   if {!$dwb_vars(execQuery)} {
      return
   }

   foreach el [array names resList] {
      unset resList($el)
   }
 
   #set dwb_vars(tableNumber) 0
   foreach pair $dwb_vars(QVZQUERY,SEARCHED) {
      set type [lindex [split $pair ","] 0]
      set tablename result@$dwb_vars(tableNumber)
      mk::view layout RESDB.$tablename {DATA IDS}
      mk::view size RESDB.$tablename 0
      set reslist ""
      
      if {![info exists dwb_vars(QVZQUERY,RESTABLE,$pair)]} {
      foreach r $dwb_vars(QVZQUERY,RESULT,$pair) {

         set dataidx [lindex [split $r "+"] 2]         
         set data [mk::get QVZLEXICON.WORDIDX!$dataidx DATA:S]
            
         foreach div [split $data ","] {
      	    set letter [string range $div 0 0]
      	    if {[lsearch $dwb_vars(avlQVZSections) $letter] >= 0} {
               if {[lsearch $dwb_vars(openQVZSections) $letter] < 0} {
      	          mk::file open QDB$letter $dwb_vars(driveletter)/Data/QVZ/QVZ$letter.CDAT -readonly
      	          mk::file open QIDX$letter $dwb_vars(driveletter)/Data/QVZ/QVZ$letter.IDX -readonly
                  lappend dwb_vars(openQVZSections) $letter
               }
               set pos [string range $div 1 end]
               set secdata [inflate [mk::get QIDX$letter.WORDIDX!$pos DATA:B]]
               set secids [inflate [mk::get QIDX$letter.WORDIDX!$pos IDS:B]]
               set sectags [inflate [mk::get QIDX$letter.WORDIDX!$pos TAG:B]]

               regsub -all "," $secdata " " secdata
               regsub -all "," $secids " " secids
               regsub -all "," $sectags " " sectags
               #set next [mk::view size RESDB.$tablename]
               set abspos 0
               for {set i 0} {$i < [llength $secdata]} {incr i} {
                  update
                  if {!$dwb_vars(execQuery)} {
                     return
                  }
                  set idn [lindex $secids $i]
                  if {[string range $idn 0 0] == "G"} {
                     set id $idn
                  } else {
                     set id [format "Q%s%05d" $letter $idn]
                  }
                  set tag [lindex $sectags $i]
                  set relpos [lindex $secdata $i]
                  incr abspos $relpos
                  #set id [lindex $secids $i]
                  if {$type == "qtxt" || [lsearch $dwb_vars(${type}_types) $tag] >= 0} {
                     #puts "mk::set RESDB.$tablename!$next DATA [lindex $secdata $i] IDS [lindex $secids $i]"
                     #mk::set RESDB.$tablename!$next DATA [lindex $secdata $i] IDS [lindex $secids $i]
                     lappend reslist "$id@$letter$abspos"
                     #incr next
                  } else {
                     #puts "$pair --> $tag no match!"
                  }
               }

               if {!$dwb_vars(execQuery)} {
                  return
               } 
            }
         }                  	
      }
      set reslist [lsort $reslist]
      #puts "R=$reslist"
      set reslist [removeDuplicates $reslist]
      set i 0
      foreach el $reslist {
      	 set lv [split $el "@"]
      	 mk::set RESDB.$tablename!$i DATA [lindex $lv 1] IDS [lindex $lv 0]
      	 incr i
      }
      set dwb_vars(QVZQUERY,RESTABLE,$pair) $dwb_vars(tableNumber)
      incr dwb_vars(tableNumber)
   }
   }

   set dwb_vars(QVZQUERY,TEXT,HEADER) "Kombiniere Teilergebnisse"
   update

   set sridx 0
   foreach type $dwb_vars(QVZQUERY,cats) { 	      
      set _stkLevel 0
      if {[info exists dwb_vars(RESLIST,$type)]} {
      	 unset dwb_vars(RESLIST,$type)
      }
      foreach el $dwb_vars(QVZQUERY,srchexp,$type) {
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
            set _expStack($_stkLevel) $dwb_vars(QVZQUERY,RESTABLE,$type,$word)
            incr _stkLevel
            incr sridx
         }
      }
      if {$dwb_vars(QVZQUERY,srchexp,$type) != ""} {
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
}   


proc ShowQVZHitlist {first} {
   global dwb_vars font wbr

   if {[winfo exists .infopopup]} {
      return
   }

   if {!$dwb_vars(execQuery)} {
      return
   } 
   
   set hittextw [$dwb_vars(QVZQUERY,hits) subwidget text]
   $hittextw config -state normal
   $hittextw delete 1.0 end

   set n [mk::view size RESDB.result@$dwb_vars(QVZQUERY,reslist)]
   if {$n > [expr $first+10]} {
      set m [expr $first+10]
   } else {
      set m $n
   }
   if {$n == 0} {
      set dwb_vars(QVZQUERY,hitlisthead) "Ergebnis: kein Treffer"
      $dwb_vars(QVZQUERY,hitarea).head.lefthits config -state disabled
      $dwb_vars(QVZQUERY,hitarea).head.righthits config -state disabled
      $dwb_vars(QVZQUERY,hitarea).head.leftendhits config -state disabled
      $dwb_vars(QVZQUERY,hitarea).head.rightendhits config -state disabled
      return
   } else {
      set dwb_vars(QVZQUERY,hitlisthead) "Ergebnis: Artikel [expr $first+1] bis $m von $n"
   }

   set dlg [DisplayInfoPopup .workarea \
      "Erstelle Ergebnisübersicht..." black $dwb_vars(Special,TABBACK)]
   set dwb_vars(INFOLABEL) "Erstelle Ergebnisübersicht..."
   grab set $dlg
   update

   set i $first
   set in 0
   while {$i < $m && $i < $n} {
      set hitvals [mk::get RESDB.result@$dwb_vars(QVZQUERY,reslist)!$i]
      set item [lindex $hitvals 3]
      set data [lindex $hitvals 1]
          
      label $hittextw.lbl$i -image $wbr(empty) -bd 0
      $hittextw win cr end -win $hittextw.lbl$i -align baseline
      $hittextw ins e "\t[expr $i+1]:" "hitnr hit$item hit@$i"
      $hittextw ins e "\t"
      
      $hittextw tag bind hit$item <1> [eval "list GotoSelectedQVZHit $i $n 1"]
      $hittextw tag bind hit$item <Enter> [eval "list HighSelectedHit $hittextw $item"]
      $hittextw tag bind hit$item <Leave> [eval "list LowSelectedHit $hittextw $item"]

      update
      DisplayQVZKWIC $hittextw $in $item $data $i $n
      $hittextw ins e "\n"

      incr i
      incr in
      flush stdout
   }
   $hittextw config -state disabled

   if {$n > [expr $first+10]} {
      $dwb_vars(QVZQUERY,hitarea).head.righthits config -state normal
      $dwb_vars(QVZQUERY,hitarea).head.rightendhits config -state normal
   } else {
      $dwb_vars(QVZQUERY,hitarea).head.righthits config -state disabled
      $dwb_vars(QVZQUERY,hitarea).head.rightendhits config -state disabled
   }

   if {$first > 9} {
      $dwb_vars(QVZQUERY,hitarea).head.lefthits config -state normal
      $dwb_vars(QVZQUERY,hitarea).head.leftendhits config -state normal
   } else {
      $dwb_vars(QVZQUERY,hitarea).head.lefthits config -state disabled
      $dwb_vars(QVZQUERY,hitarea).head.leftendhits config -state disabled
   }

   set dwb_vars(QVZQUERY,firsthit) $first

   grab release $dlg
   destroy $dlg

   update
}


proc DisplayQVZKWIC {w in item data hitnr hitanz} {
   global dwb_vars kwic_list
   
   set dwb_vars(contextLength) 6
   set letter [string range $item 1 1]
   if {[lsearch $dwb_vars(openQVZSections) $letter] < 0} {
      mk::file open QDB$letter $dwb_vars(driveletter)/Data/QVZ/QVZ$letter.CDAT -readonly
      mk::file open QIDX$letter $dwb_vars(driveletter)/Data/QVZ/QVZ$letter.IDX -readonly
      lappend dwb_vars(openQVZSections) $letter
   }

   #set ridx [lindex $hitvals 3]  
   set poslist [split $data "+"]
   set p [string range [lindex $poslist 0] 1 end]
   
   set subrow [performQuery QIDX$letter ARTICLE "FIRSTPOS:I<=$p" memory 1]
   set idx [lindex $subrow 0]
   puts "letter=$letter, IDX=$idx"
   set sidx [mk::get QDB$letter.ARTICLE!$idx FIRSTPOS:I]
   if {$idx < [expr [mk::view size QDB$letter.ARTICLE] - 1]} {
      set nextpos [mk::get QDB$letter.ARTICLE![expr $idx+1] FIRSTPOS:I]
   } else {
      set nextpos -1
   }

   set ivlist ""
   foreach pos $poslist {
      set pos [string range $pos 1 end]
      set opos [expr $pos-$dwb_vars(contextLength)]
      if {$opos < $sidx} {
         set opos $sidx
      }
      set cpos [expr $pos+$dwb_vars(contextLength)]
      if {$cpos >= $nextpos} {
      	 set cpos [expr $nextpos-1]
      }
      lappend ivlist [format "%08dA" $opos]
      lappend ivlist [format "%08dB" $pos]
      lappend ivlist [format "%08dC" $cpos]
   }
   
   set ivlist [lsort $ivlist]
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
         if {$cridx < 0 || $cridx >= [mk::view size QDB$letter.TEXT]} {
            return
         }
         if {![info exists kwic_list(tag,$letter,$cridx)]} {
            set kwic_list(tag,$letter,$cridx) [inflate [mk::get QDB$letter.TEXT!$cridx TAG:B]]
         }
         set tag [lindex $dwb_vars(textTypes) [lindex $kwic_list(tag,$letter,$cridx) $iridx]]
         if {![info exists kwic_list(word,$letter,$cridx)]} {
            set kwic_list(word,$letter,$cridx) [inflate [mk::get QDB$letter.TEXT!$cridx WORD:B]]
         }
         set word [lindex $kwic_list(word,$letter,$cridx) $iridx]
         regsub -all "\\\\'" $word "\'" word
         regsub -all "\\\[" $word "\\\[" word
         regsub -all "\\\]" $word "\\\]" word

         if {($t1 == "B" && $i == $p1)} {
            if {![info exists kwic_list(pos,$letter,$cridx)]} {
               set kwic_list(pos,$letter,$cridx) [inflate [mk::get QDB$letter.TEXT!$cridx POS:B]]
            }
            set pos [lindex $kwic_list(pos,$letter,$cridx) $iridx]
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
         $w ins e "\n" context 
         $w tag bind hit$item.$line <1> [eval "list GotoSelectedQVZHit $hitnr $hitanz 1 $pos"]
         $w tag bind hit$item.$line <Enter> [eval "list HighSelectedHit $w $item $line"]
         $w tag bind hit$item.$line <Leave> [eval "list LowSelectedHit $w $item $line"]
         incr line
      }

      set p1 $p2
      set t1 $t2
      
      incr pi
   }
}


proc CombineQVZResults {} {
   global dwb_vars

   if {!$dwb_vars(execQuery)} {
      return
   }

   set res -1
   foreach type $dwb_vars(QVZQUERY,cats) {
      if {$dwb_vars(${type}_check) == 1} {
         if {$res < 0} {
            set res $dwb_vars(RESLIST,$type)
         } else {
            set res [MergeResTables $res $dwb_vars(RESLIST,$type)]
         }
      }
   }
   foreach type $dwb_vars(QVZQUERY,cats) {
      if {$dwb_vars(${type}_check) == 2} {
         if {$res < 0} {
            set res $dwb_vars(RESLIST,$type)
         } else {
            set res [JoinResTables $res $dwb_vars(RESLIST,$type)]
         }
      }
   }
   foreach type $dwb_vars(QVZQUERY,cats) {
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


proc SetupQVZHitlist {table} {
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

   set r 0
   for {set i 0} {$i < [mk::view size RESDB.result@$table]} {incr i} {
      set id [mk::get RESDB.result@$table!$i IDS]    
      set letter [string range $id 1 1]
      set data [mk::get RESDB.result@$table!$i DATA]
      eval mk::set RESDB.$tablename!$r DATA $data IDS $id
      incr r
   }
   mk::file commit RESDB
   
   return $tnr
}


proc OpenQVZQueryArea {top} {
   global dwb_vars

   set part $dwb_vars(WBAREA,DWB,ACTIVETAB)
   set pos [lsearch $dwb_vars(WBSECTIONS) $part]
   if {$pos >= 0} {
      $dwb_vars(WBAREA,DWB).ts select [expr $pos+2]
   } else {
      GotoArticle GA00001 0
   }
   $dwb_vars(tocbook) select 4
}


# ---------------------------------------------------------
# scroll hitlist to left end
# ---------------------------------------------------------

proc ScrollQVZHitlistToLeftEnd {} {
   global dwb_vars

   ShowQVZHitlist 0
}


# ---------------------------------------------------------
# scroll hitlist to right end
# ---------------------------------------------------------

proc ScrollQVZHitlistToRightEnd {} {
   global dwb_vars

   set n [mk::view size RESDB.result@$dwb_vars(QVZQUERY,reslist)]
   set p [expr ($n/10)*10+0]

   ShowQVZHitlist $p
}


# ---------------------------------------------------------
# scroll hitlist forward
# ---------------------------------------------------------

proc ScrollQVZHitlistFore {} {
   global dwb_vars

   ShowQVZHitlist [expr $dwb_vars(QVZQUERY,firsthit)+10]
}


# ---------------------------------------------------------
# scroll hitlist backward
# ---------------------------------------------------------

proc ScrollQVZHitlistBack {} {
   global dwb_vars

   ShowQVZHitlist [expr $dwb_vars(QVZQUERY,firsthit)-10]
}


proc GotoSelectedQVZHit {item hitanz mode {pos ""}} {
   global dwb_vars wbr

   if {[winfo exists .infopopup]} {
      return
   }
 
   set lemma_id [mk::get RESDB.result@$dwb_vars(QVZQUERY,reslist)!$item IDS]
   set wbID [string range $lemma_id 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wbID]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   if {$mode} {
      set hittextw [$dwb_vars(QVZQUERY,hits) subwidget text]
      $hittextw config -state normal
      if {$dwb_vars(CURRENTHITINDEX,$wbname) >= 0} {
      	 if {[winfo exists $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname)]} {
            $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname) \
               config -image $wbr(empty)
         }
      }
      $hittextw config -state disabled
   }

   GotoQVZArticle $lemma_id 1
   if {$item < [expr $hitanz-1]} {
      $dwb_vars(WBAREAFRAME,$wbname).main.lemma.control.hfore config -state normal
   } else {
      $dwb_vars(WBAREAFRAME,$wbname).main.lemma.control.hfore config -state disabled
   }
   if {$item > 0} {
      $dwb_vars(WBAREAFRAME,$wbname).main.lemma.control.hback config -state normal
   } else {
      $dwb_vars(WBAREAFRAME,$wbname).main.lemma.control.hback config -state disabled
   }
   set dwb_vars(QVZQUERY,HITPOS) "[expr $item+1] / $hitanz"

   TagFulltextQVZHits $lemma_id $item $pos
   
   if {$item > [expr $dwb_vars(QVZQUERY,firsthit)+9] || $item < $dwb_vars(QVZQUERY,firsthit)} {
      ShowQVZHitlist [expr int($item/10)*10]
   } 
   
   set dwb_vars(CURRENTHITINDEX,$wbname) $item
   set hittextw [$dwb_vars(QVZQUERY,hits) subwidget text]
   $hittextw.lbl$item config -image $wbr(exparticle)
   $hittextw config -state disabled
   set pos [$hittextw tag ranges hit$lemma_id]
   if {[llength $pos] > 0} {
      $hittextw see [lindex $pos 0]
   }
}


proc ForeOneQVZHit {wbname} {
   global dwb_vars wbr

   set hittextw [$dwb_vars(QVZQUERY,hits) subwidget text]
   if {[winfo exists $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname)]} {
      $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname) \
         config -image $wbr(empty)
   }

   incr dwb_vars(CURRENTHITINDEX,$wbname)
   set i $dwb_vars(CURRENTHITINDEX,$wbname)
   set hit [mk::get RESDB.result@$dwb_vars(QVZQUERY,reslist)!$i]
   set item [lindex $hit 1]
   
   GotoSelectedQVZHit $i [mk::view size RESDB.result@$dwb_vars(QVZQUERY,reslist)] 0
}

# ---------------------------------------------------------
# goto previous hit
# ---------------------------------------------------------

proc BackOneQVZHit {wbname} {
   global dwb_vars wbr

   set hittextw [$dwb_vars(QVZQUERY,hits) subwidget text]
   if {[winfo exists $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname)]} {
      $hittextw.lbl$dwb_vars(CURRENTHITINDEX,$wbname) \
         config -image $wbr(empty)
   }

   incr dwb_vars(CURRENTHITINDEX,$wbname) -1
   set i $dwb_vars(CURRENTHITINDEX,$wbname)
   set hit [mk::get RESDB.result@$dwb_vars(QVZQUERY,reslist)!$i]
   set item [lindex $hit 1]

   GotoSelectedQVZHit $i [mk::view size RESDB.result@$dwb_vars(QVZQUERY,reslist)] 0
}


proc TagFulltextQVZHits {id hitidx wpos} {
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

   set ipl [mk::get RESDB.result@$dwb_vars(QVZQUERY,reslist)!$hitidx DATA]
   set wpl ""
   foreach ip [split $ipl "+"] {
      set ip [string range $ip 1 end]
      set cridx [expr $ip/1000]
      set iridx [expr $ip%1000]
      if {![info exists kwic_list(pos,$part,$cridx)]} {
         set kwic_list(pos,$part,$cridx) [inflate [mk::get QDB$part.TEXT!$cridx POS:B]]
      }
      set pos [lindex $kwic_list(pos,$part,$cridx) $iridx]
      lappend wpl $pos
   }
   
   foreach ip [split $ipl "+"] {
      set ip [string range $ip 1 end]
      set cridx [expr $ip/1000]
      set iridx [expr $ip%1000]
      if {![info exists kwic_list(word,$part,$cridx)]} {
         set kwic_list(word,$part,$cridx) [inflate [mk::get QDB$part.TEXT!$cridx WORD:B]]
      }
      set word [lindex $kwic_list(word,$part,$cridx) $iridx]
      
      if {[string range $word 0 2] == "@t@"} {
         set articlerange [$active_textwidget tag range lem$id]
         set articlestart [lindex $articlerange 0]
         set articleend [lindex $articlerange 1]
         set tag [string range $word 3 end]
         set tagranges [$active_textwidget tag range $tag]
         foreach {first last} $tagranges {
            if {[$active_textwidget compare $articlestart <= $first] && \
                [$active_textwidget compare $last <= $articleend]} {
               #$active_textwidget tag add emphasis$wpos $first $last
               $active_textwidget tag add emphasis $first $last
            }
         }
         $active_textwidget tag configure emphasis \
            -background $dwb_vars(Special,TABBACK) -bgstipple gray50 -relief solid -borderwidth 0
      } else {
         forAllMatches $id $active_textwidget $word QVZ
         $active_textwidget tag configure emphasis \
            -background $dwb_vars(Special,TABBACK) -bgstipple gray50 -relief solid -borderwidth 0
      }
   }

   #if {$wpos == ""} {
   #   set pos [$active_textwidget tag ranges emphasis]
   #   if {[llength $pos] > 0} {
   #      $active_textwidget see [lindex $pos 0]
   #      SetLemmaHeader $active_textwidget $wbname
   #  }
   #} else {
   #   set pos [$active_textwidget tag ranges emphasis]
   #   if {[llength $pos] > 0} {
   #      $active_textwidget see [lindex $pos 0]
   #      SetLemmaHeader $active_textwidget $wbname
   #   }
   #}
}