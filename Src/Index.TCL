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
# create index display area
# ---------------------------------------------------------

proc MkRIDisplayArea {top wbname} {
   global dwb_vars font wbr

   set wbID [string range $wbname 0 0]
   set wbarea [frame $top.wbarea -background grey -borderwidth 1 \
      -relief flat]
   set dwb_vars(WBAREA,$wbname) $wbarea

   set w [frame $wbarea.f1]

   # --- create index main area
   set main [frame $w.main]

   # --- create lemma display area
   set lemma [frame $main.lemma]

   set lemmaarea [tixScrolledText $lemma.lemmaarea -scrollbar both]
   set wbtextw [$lemmaarea subwidget text]
   $wbtextw config -height 22 -width 44 -padx 10 -pady 5 \
      -wrap none -background "grey97" -relief sunken -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 180 right 400 right } \
      -font $font(t,b,r,12)

   set dwb_vars($wbname,CURRSIGLE) ""
   
   InitIndexTextField $wbtextw

   set vsb [$lemmaarea subwidget vsb]
   $vsb config -troughcolor $dwb_vars($wbname,TABBACK)
   # $vsb config -command "ScrollWBText $wbtextw $wbname"

   set dwb_vars(WBTEXT,$wbname,1) [$lemmaarea subwidget text]

   set cmd [format "Configure%sTags" $wbname]
   $cmd 1

   pack $lemmaarea -side top -fill both -expand yes
   pack $lemma -side left -expand yes -fill both
   pack $main -side top -fill both -expand yes
   pack $w -side top -fill both -expand yes
   
   set section [frame $wbarea.control]
   
   tixLabelFrame $section.lf -label "Wortendung eingeben" \
      -bg $dwb_vars($wbname,TABBACK)
   set f [$section.lf subwidget frame]
   $f config -bg $dwb_vars($wbname,TABBACK)
   [$section.lf subwidget label] config -font $font(h,m,r,12) \
      -bg $dwb_vars($wbname,TABBACK)
   $section.lf.border config -bg $dwb_vars($wbname,TABBACK)
   $section.lf.border.pad config -bg $dwb_vars($wbname,TABBACK)

   entry $f.search -width 20 -font $font(h,b,r,14)
   $dwb_vars(BHLP) bind $f.search -msg \
      "Wortendung angeben"
   bind $f.search <KeyRelease> "
      CheckInput $f.search
   "
   bind $f.search <Return> [eval "list LoadRISubindex $f.search"]
   pack $f.search -side bottom -fill x
   pack $section.lf -side bottom -fill x

   set dwb_vars($wbname,loaded) {}
   set dwb_vars($wbname,loadpos) {}
   set dwb_vars(WBSUBSECS,$wbname,1,curr) 0
   set dwb_vars(HISTORY,$wbname,list) {}
   set dwb_vars(HISTORY,$wbname,pos) -1

   pack $section -fill x -side bottom
   pack $wbarea -side top -fill both -expand yes
   update
}


# ---------------------------------------------------------
# configure wb display
# ---------------------------------------------------------

proc ConfigureRITags {pos} {
   global dwb_vars font

   set textw $dwb_vars(WBTEXT,RI,1)

   $textw tag configure l1 -font $font(z,b,r,12)
   $textw tag configure g1 -font $font(z,b,i,12)
  
   $textw tag configure head -font $font(h,m,r,12) \
       -background $dwb_vars(DWB,TABBACK) -justify center
   $textw tag configure rr -justify right
}


proc LoadRIndex {mode sec {suffix ""}} {
   global dwb_vars font
   
   if {!$mode} {
      set dlg [DisplayInfoPopup $dwb_vars(WBTEXT,RI,1) \
         "Erstelle Stichwortliste..." black $dwb_vars(Special,TABBACK)]
      set dwb_vars(INFOLABEL) "Erstelle Stichwortliste mit Endung ${suffix}${sec}..."
   } else {
      set dlg [DisplayInfoPopup $dwb_vars(WBTEXT,RI,1) \
         "Wörterbuch wird vorbereitet..." black $dwb_vars(Special,TABBACK)]
      set dwb_vars(INFOLABEL) "Wörterbuch wird vorbereitet..."
   }
   blt::busy hold .
   update

   set invsuffix [InvertWord $suffix]
   #set ts $dwb_vars(WBAREA,RI).ts
   set pos [lsearch $dwb_vars(WBSECTIONS) $sec]
   #$ts select [expr $pos+0]
   #$ts tab configure $sec -window $ts.f1
   set row [performLikeQuery IDXDWB LEMMA "INVNAME=${sec}${invsuffix}*" nocase]
   set t [mk::view size IDXDWB.LEMMAINVNAMEIDX]
   set l [llength $row]
   set w $dwb_vars(WBTEXT,RI,1)

   if {!$mode} {
      set dwb_vars(INFOLABEL) "Erstelle Stichwortliste mit Endung ${suffix}${sec} ($l Treffer)..."
      update
   }
   set cnt [winfo parent [winfo parent $dwb_vars(WBTEXT,RI,1)]]
   set twc [winfo parent $dwb_vars(WBTEXT,RI,1)]
   
   if {$l > 10000} {
      tk_messageBox -message "Die Liste enthält mehr als 10000 Einträge.\nAngezeigt werden die ersten 10000."
      set l 10000
   }

   destroy $twc       

   set lemmaarea [tixScrolledText $cnt.lemmaarea -scrollbar both]
   set wbtextw [$lemmaarea subwidget text]
   $wbtextw config -height 22 -width 44 -padx 10 -pady 5 \
      -wrap none -background "grey97" -relief sunken -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 180 right 400 right } \
      -font $font(t,b,r,12)

   pack $lemmaarea -fill both -expand yes
   ConfigureRITags 1

   set w $wbtextw
   $w config -state normal
   #$w delete 1.0 end
   $w insert end "Stichwörter mit Endung ${suffix}${sec} ($l von $t)\n" head
   set m [expr ($l+1)/2]
   set ix 0
   for {set i 0} {$i < $l} {incr i} {
      if {!$mode && [expr $ix % 1000] == 0} {
         set pct [format "%.2f" [expr 100.0*$ix/$l]]
         set dwb_vars(INFOLABEL) "Erstelle Stichwortliste mit Endung ${suffix}${sec} ($l Treffer, ${pct}%)..."
         update
      }
      set r1 [lindex $row $i] 
      set vals [mk::get DBDWB.LEMMA!$r1]
      set id [lindex $vals 1]
      set gram ""
      set subrow [performQuery IDXDWB GRAM "ID==$id"]
      if {[lindex $subrow 0] != ""} {
         set gram [eval mk::get DBDWB.GRAM![lindex $subrow 0] TYPE]
      }
      #$w insert end "\t"
      if {$gram != ""} {
         $w insert end "$gram., " "g1 ri$id rr"
      }
      #$w insert end "[ConvertToUppercase [lindex $vals 9]]" "l1 ri$id rr"
      $w insert end "[lindex $vals 3]" "l1 ri$id rr"
      $w tag bind ri$id <Enter> "$w tag config ri$id -background grey80 -bgstipple gray50"
      $w tag bind ri$id <Leave> "$w tag config ri$id -background grey97"
      $w tag bind ri$id <ButtonPress-1> "GotoArticle $id 1"
      incr ix
      
      #set r2 [lindex $row [expr $i+$m]]
      #if {$r2 != ""} {
      #   set vals [mk::get DBDWB.LEMMA!$r2]
      #   set id [lindex $vals 1]
      #   set gram ""
      #   set subrow [performQuery IDXDWB GRAM "ID==$id"]
      #   if {[lindex $subrow 0] != ""} {
      #      set gram [eval mk::get DBDWB.GRAM![lindex $subrow 0] TYPE]
      #   }
      #   $w insert end "\t"
      #   if {$gram != ""} {
      #      $w insert end "$gram., " "g1 ri$id"
      #   }
      #   $w insert end "[ConvertToUppercase [lindex $vals 9]]" "l1 ri$id"
      #   $w tag bind ri$id <Enter> "$w tag config ri$id -background grey80 -bgstipple gray50"
      #   $w tag bind ri$id <Leave> "$w tag config ri$id -background grey97"
      #   $w tag bind ri$id <ButtonPress-1> "GotoArticle $id 1"
      #}
      $w insert end "\n"
      #incr ix
   }
   $w config -state disabled

   grab release $dlg
   destroy $dlg
   blt::busy release .
   blt::busy forget .
}


proc LoadRISubindex {w} {

   set text [NormalizeWord [$w get]]
   if {$text == ""} {
      return
   }

   set sec [string range $text end end]
   if {[string length $text] > 1} {
      set suffix [string range $text 0 [expr [string length $text]-2]]
   } else {
      set suffix ""
   }
   
   LoadRIndex 0 $sec $suffix	
}


proc OpenRIArea {top} {
   global dwb_vars

   set part $dwb_vars(WBAREA,DWB,ACTIVETAB)
   set pos [lsearch $dwb_vars(WBSECTIONS) $part]
   if {$pos >= 0} {
      $dwb_vars(WBAREA,DWB).ts select [expr $pos+2]
   } else {
      GotoArticle GA00001 0
   }
   $dwb_vars(tocbook) select 5
}


proc CheckInput {ew} {
   
   set trimChars "0123456789ÄÖÜ_\#|^\\\[\]!,:;<>%=«»§\'()/\".?&$*+-\}\{\n\t "
	
   set text [$ew get]
   set newtext [string trimright [ConvertToUppercase $text] $trimChars]
     
   if {$newtext != $text} {
      set ix [$ew index insert]
      $ew delete 0 end
      $ew insert 0 $newtext
      $ew icursor $ix
   }
}


proc InitIndexTextField {w} {
   global font
   
   $w config -state normal -wrap word -font $font(h,m,r,14) \
      -background grey85
   $w delete 1.0 end
   $w tag configure kursiv -font $font(h,m,i,14) -foreground blue
   
   $w insert end "Hinweise zum rückläufigen Stichwortindex"
   $w insert end "\n\nIn diesem Index finden Sie die im DWB aufgenommenen\
 Stichwörter in rückläufig alphabetisierter Form vor, d.h. von rechts\
 nach links, vom Wortende zum Wortanfang gelesen.\
 Hier können Sie nach Wortendungen suchen, indem Sie\
 im Eingabefeld "
   $w insert end "Wortendung eingeben" kursiv
 $w insert end " eine beliebige Wortendung eintragen und\
 die Suche in der rückläufigen Stichwortliste durch Betätigen\
 der Eingabetaste starten. Die gefundenen Stichwörter werden\
 in diesem Fenster aufgelistet und sind mit dem Wörterbuch verknüpft:\
 Durch Mausklick auf eines der Stichwörter wird der zugehörige\
 Wörterbuchartikel im Artikelfenster aufgeschlagen. \
 Die gesuchte Zeichenfolge sollte sich möglichst nicht auf einzelne\
 Buchstaben beschränken, sondern über eine gewisse Länge verfügen, da\
 andernfalls die Anzahl der gefundenen Stichwörter zu groß wird."

   $w config -state disabled       
}

