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
# create index components
# ---------------------------------------------------------

proc MkWBComponents {top wbname {withtoc 0}} {
   global dwb_vars

   MkWBDisplayArea $top $wbname $withtoc
   update
}


# ---------------------------------------------------------
# create index display area
# ---------------------------------------------------------

proc MkWBDisplayArea {top wbname withtoc} {
   global dwb_vars font wbr

   set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
   incr wbidx
   set wbID [lindex $dwb_vars(wbname) $wbidx]
   set wbarea [frame $top.wbarea -background grey -borderwidth 1 \
      -relief flat]
   set dwb_vars(WBAREA,$wbname) $wbarea

   # create tabset
   set ts [tabset $wbarea.ts -side left -samewidth yes \
      -relief sunken -bd 0 -tiers 2 -tabborderwidth 0 -gap 0 \
      -selectpad 1 -outerpad 0 -highlightthickness 0 \
      -dashes 0 -tearoff 0 -cursor top_left_arrow \
      -activeforeground black -foreground black -selectforeground black]


   for {set i 1} {$i <= $dwb_vars(MAXWBDISPLAY)} {incr i} {
      set w [frame $ts.f$i]
      set dwb_vars(WBAREAFRAME,$wbname) $w

      # --- create index main area
      set main [frame $w.main]

      # --- create paned window
      if {![info exists dwb_vars(PANESIZE,section)]} {
         set dwb_vars(PANESIZE,section) [expr int(2.0*$dwb_vars(XRES)/16)]
      }
      set pane [tixPanedWindow $main.pane -orient horizontal \
         -handlebg $dwb_vars($wbname,TABBACK) -handleactivebg darkgreen]
      $pane add section -min 100 -size $dwb_vars(PANESIZE,section) -max 200
      $pane add lemma

      # --- create lemma display area
      set section [$pane subwidget section]
      set lemma [$pane subwidget lemma]
      if {$withtoc} {
         set seclemma [frame $lemma.f]
         set secpane [tixPanedWindow $seclemma.pane -orient horizontal \
            -handlebg $dwb_vars($wbname,TABBACK) -handleactivebg darkgreen]
         if {![info exists dwb_vars(PANESIZE,lemma)]} {
            set dwb_vars(PANESIZE,lemma) [expr int(7.0*$dwb_vars(XRES)/16)]
         }
         $secpane add lemma -min 240 -size $dwb_vars(PANESIZE,lemma)
         #$secpane add lemma -max 600 -size 400
         if {![info exists dwb_vars(PANESIZE,toc)]} {
            set dwb_vars(PANESIZE,toc) [expr int(7.0*$dwb_vars(XRES)/16)]
         }
         $secpane add toc -min 360 -size $dwb_vars(PANESIZE,toc) \
            -max 600
         set plemma [$secpane subwidget lemma]
         $plemma config -background $dwb_vars(DWB,TABBACK)
         set toc [$secpane subwidget toc]
      } else {
         set plemma $lemma
      }
      
      #$plemma config -relief sunken -bd 1
      set currlemma [frame $plemma.currlem -background $dwb_vars(DWB,TABBACK)]
      label $currlemma.first -textvariable dwb_vars(FLEMMA,$wbname,$i) \
         -background $dwb_vars(DWB,TABBACK) -font $font(h,m,r,14) -pady 2
      label $currlemma.sep -text "  -  " -background $dwb_vars(DWB,TABBACK) \
         -font $font(h,m,i,14) -pady 2
      label $currlemma.last -textvariable dwb_vars(LLEMMA,$wbname,$i) \
         -background $dwb_vars(DWB,TABBACK) -font $font(h,m,r,14) -pady 2
      pack $currlemma.first $currlemma.sep $currlemma.last -side left -fill x
                     
      set header1 [frame $plemma.header1 -background grey97 \
         -borderwidth 0 -relief ridge]

      set header3 [frame $plemma.header3 -background $dwb_vars(DWB,TABBACK) \
         -borderwidth 1 -relief flat -height 2]

      set header2 [frame $plemma.header2 -background grey97 \
         -borderwidth 0 -relief ridge]

      set headerarea [text $header1.text]
      $headerarea config -height 1 -width 30 -padx 2 -pady 2 \
         -wrap none -background "grey97" -relief flat -bd 0 \
         -spacing1 0 -spacing2 0 -spacing3 0 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0 -font $font(z,m,r,14)
      set dwb_vars($wbname,ARTICLEPOS,$i) $headerarea
      $dwb_vars($wbname,ARTICLEPOS,$i) tag configure lemma -font $font(z,b,r,14)
      $dwb_vars($wbname,ARTICLEPOS,$i) tag configure gram -font $font(z,m,i,12)
      $dwb_vars($wbname,ARTICLEPOS,$i) tag configure glpos -font $font(z,m,r,12)
      $dwb_vars($wbname,ARTICLEPOS,$i) tag configure glposgr -font $font(g,m,i,12)
      $dwb_vars($wbname,ARTICLEPOS,$i) tag configure glposhb -font $font(a,m,r,10)
      
      set headerlabel [label $header1.lbl -background grey97 \
         -image [tix getimage smallright] -relief flat \
         -borderwidth 0]

      pack $headerlabel $headerarea -side left -fill y

      $dwb_vars(BHLP) bind $headerlabel -msg \
         "Zum Artikelanfang"

      bind $currlemma <Double-Button-1> [eval "list break"]
      bind $currlemma <Triple-Button-1> [eval "list break"]

      bind $headerlabel <ButtonPress-1> [eval "list RefArticleStart \
         $headerarea $wbname"]

      set pagelabel [label $header1.page -background grey97 \
         -textvariable dwb_vars($wbname,HEADPAGE,$i) \
         -relief flat -borderwidth 1 -font $font(h,m,r,12) -padx 5 \
         -foreground black]

      pack $pagelabel -side right -fill y

      set lemmaarea [tixScrolledText $plemma.lemmaarea -scrollbar y]
      set wbtextw [$lemmaarea subwidget text]
      $wbtextw config -height 22 -width 44 -padx 10 -pady 5 \
         -wrap word -background "grey97" -relief ridge -bd 1 \
         -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0

      set dwb_vars(wbtextw) $wbtextw
      set dwb_vars($wbname,CURRHIGHLIGHT) ""

      bind $wbtextw <Motion> +[eval "list TraceSigle $top $wbtextw \
         $wbname %x %y"]
      #bind $wbtextw <Leave> [eval "list HideSigle $wbtextw $wbname"]
      bind $wbtextw <ButtonPress-1> +[eval "list ReferenceInfo $top \
         $wbname"]
         
      #add focus to window to enable mouse-selection for copy&paste         
      bind $wbtextw <ButtonPress-1> +[eval "list focus %W"]
         
      bind $wbtextw <<Copy>> {
         tk_textCopy %W
      }
      bind $wbtextw <Delete> [eval "list break"]
      bind $wbtextw <BackSpace> [eval "list break"]      
      bind $wbtextw <Control-h> [eval "list break"]
      bind $wbtextw <Any-Key> [eval "list break"]

      #bind $wbtextw <Double-1> [eval "list break"]
      #bind $wbtextw <Triple-1> [eval "list break"]

      MkWBPopupMenu $wbtextw $wbname
      bind $wbtextw <ButtonPress-3> \
         [eval "list ConfigureWBPopupMenu $wbtextw $wbname %x %y"]

      #bind $wbtextw <Button-3> "place $dwb_vars(POPUPMENU,DWB) -x %x -y %y"

      set vsb [$lemmaarea subwidget vsb]
      $vsb config -troughcolor $dwb_vars($wbname,TABBACK)
      $vsb config -command "ScrollWBText $wbtextw $wbname"

      set dwb_vars(WBTEXT,$wbname,$i) [$lemmaarea subwidget text]

      set siglearea [frame $plemma.siglearea -background $dwb_vars(DWB,TABBACK) \
         -relief flat]
      
      set sigleareahead [frame $siglearea.head -background $dwb_vars(DWB,TABBACK) \
         -relief raised -bd 1]
      label $sigleareahead.cancel -image [tix getimage smalldown2] \
         -background $dwb_vars(DWB,TABBACK)
      $dwb_vars(BHLP) bind $sigleareahead.cancel -msg \
         "Siglenfenster ausblenden"
      bind $sigleareahead.cancel <ButtonPress-1> [eval "list CloseSigleWindow \
         $siglearea"]

      label $sigleareahead.title -text "Quellenverzeichnis" -font $font(h,b,r,12) \
         -background $dwb_vars(DWB,TABBACK)
      
      pack $sigleareahead.cancel $sigleareahead.title -side left -padx 5
      pack $sigleareahead -side top -fill x
      
      set sigletextarea [tixScrolledText $siglearea.text -scrollbar y]
      set sgntextw [$sigletextarea subwidget text]
      $sgntextw config -height 7 -width 44 -padx 10 -pady 5 \
         -wrap word -background "grey97" -relief ridge -bd 1 \
         -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0
      pack $sigletextarea -side top -expand yes -fill both
      
      ConfigureSigleWindowsTags $sgntextw
         
      set dwb_vars(SGNTEXT,$wbname,$i) [$sigletextarea subwidget text]
      set dwb_vars(SIGLE,$wbname) $siglearea

      set footnote [frame $plemma.footnote -background $dwb_vars(DWB,TABBACK) \
         -relief flat]
      
      set footnotehead [frame $footnote.head -background $dwb_vars(DWB,TABBACK) \
         -relief raised -bd 1]
      label $footnotehead.cancel -image [tix getimage smalldown2] \
         -background $dwb_vars(DWB,TABBACK)
      $dwb_vars(BHLP) bind $footnotehead.cancel -msg \
         "Fußnotenfenster ausblenden"
      bind $footnotehead.cancel <ButtonPress-1> [eval "list CloseFootnoteWindow \
         $footnote"]

      label $footnotehead.title -text "Fußnoten" -font $font(h,m,r,12) \
         -background $dwb_vars(DWB,TABBACK)
      
      pack $footnotehead.cancel $footnotehead.title -side left -padx 5
      pack $footnotehead -side top -fill x
      
      set footnotearea [tixScrolledText $footnote.text -scrollbar y]
      set fntextw [$footnotearea subwidget text]
      $fntextw config -height 7 -width 44 -padx 10 -pady 5 \
         -wrap word -background "grey97" -relief ridge -bd 1 \
         -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0
      pack $footnotearea -side top -expand yes -fill both
      
      ConfigureFootnoteWindowsTags $fntextw
         
      set dwb_vars(FNTEXT,$wbname,$i) [$footnotearea subwidget text]
      set dwb_vars(FNOTE,$wbname) $footnote
      
      set annotation [frame $plemma.note -background $dwb_vars(DWB,TABBACK) \
         -relief flat]
      
      set notehead [frame $annotation.head -background $dwb_vars(DWB,TABBACK) \
         -relief raised -bd 1]
      label $notehead.cancel -image [tix getimage smalldown2] \
         -background $dwb_vars(DWB,TABBACK)
      $dwb_vars(BHLP) bind $notehead.cancel -msg \
         "Anmerkungsfenster ausblenden"
      bind $notehead.cancel <ButtonPress-1> [eval "list CloseNoteWindow \
         $annotation"]

      label $notehead.title -text "Anmerkung zu" -font $font(h,b,r,12) \
         -background $dwb_vars(DWB,TABBACK)
      label $notehead.lemma -text "" -font $font(h,b,r,12) \
         -background $dwb_vars(DWB,TABBACK)
      label $notehead.gram -text "" -font $font(h,b,r,12) \
         -background $dwb_vars(DWB,TABBACK)
      
      pack $notehead.cancel $notehead.title $notehead.lemma $notehead.gram -side left -padx 5
      pack $notehead -side top -fill x
      
      set notearea [tixScrolledText $annotation.text -scrollbar y]
      set nttextw [$notearea subwidget text]
      $nttextw config -height 4 -width 44 -padx 10 -pady 5 \
         -wrap word -background "grey97" -relief ridge -bd 1 \
         -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
         -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0 -font $font(h,m,r,14)
      pack $notearea -side top -fill both
              
      set dwb_vars(NTTEXT,$wbname,$i) [$notearea subwidget text]
      set dwb_vars(NOTES,$wbname) $annotation

      # --- create index section area
      set currsection [label $section.currsec -textvariable dwb_vars(WBSEC,$wbname,$i) \
         -background $dwb_vars(DWB,TABBACK) -font $font(h,m,r,14) -anchor center -pady 2]
          
      set sectionarea [tixScrolledText $section.sectionarea -scrollbar x]
      set textw [$sectionarea subwidget text]
      $textw config -height 22 -width 15 -padx 0 -pady 5 \
         -wrap none -background "grey97" -relief ridge -bd 1 \
         -spacing1 1 -spacing2 1 -spacing3 1 -highlightthickness 0 \
         -state disabled -cursor hand2 -font $font(z,b,r,12)

      set dwb_vars(wbsubsecs) $textw
      set dwb_vars(WBSUBSECS,$wbname,$i) $textw
      set dwb_vars(WBSUBSECS,$wbname,lemma) ""

      ConfigureSubSecsTags $wbname $i

      bind $textw <Motion> [eval "list TraceArticle $top $textw \
         $wbname %x %y"]
      bind $textw <ButtonPress-1> [eval "list RefArticle $top \
         $textw $wbname %x %y"]
      bind $textw <Double-Button-1> [eval "list break"]
      bind $textw <Triple-Button-1> [eval "list break"]

      set idxcontrol [frame $section.idxctrl -relief sunken -bd 1 \
         -background $dwb_vars($wbname,TABBACK)]

      set line_up [MkFlatButton $idxcontrol lup ""]
      $line_up config -image [tix getimage arrup] \
         -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $line_up -msg \
         "Zeile zurückblättern"
      bind $line_up <ButtonPress-1> [eval "list LemmaListScroll \
         $wbname line up initial"]
      bind $line_up <ButtonRelease-1> {}
      bind $line_up <ButtonRelease-1> [eval "list tkCancelRepeat"]

      set page_up [MkFlatButton $idxcontrol up ""]
      $page_up config -image [tix getimage arr2up] \
         -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $page_up -msg \
         "Seite zurückblättern"
      bind $page_up <ButtonPress-1> [eval "list LemmaListScroll \
         $wbname page up initial"]
      bind $page_up <ButtonRelease-1> {}
      bind $page_up <ButtonRelease-1> [eval "list tkCancelRepeat"]

      #pack $line_up $page_up -side top -fill x -ipady 3

      set page_down [MkFlatButton $idxcontrol down ""]
      $page_down config -image [tix getimage arr2down] \
         -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $page_down -msg \
         "Seite vorblättern"
      bind $page_down <ButtonPress-1> [eval "list LemmaListScroll \
         $wbname page down initial"]
      bind $page_down <ButtonRelease-1> {}
      bind $page_down <ButtonRelease-1> [eval "list tkCancelRepeat"]

      set line_down [MkFlatButton $idxcontrol ldown ""]
      $line_down config -image [tix getimage arrdown] \
         -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $line_down -msg \
         "Zeile vorblättern"
      bind $line_down <ButtonPress-1> [eval "list LemmaListScroll \
         $wbname line down initial"]
      bind $line_down <ButtonRelease-1> {}
      bind $line_down <ButtonRelease-1> [eval "list tkCancelRepeat"]

      pack $page_down $line_down $line_up $page_up -side bottom -fill x -ipady 3

      set sep [frame $idxcontrol.sep -relief raised -bd 1 \
         -background $dwb_vars($wbname,TABBACK)]

      pack $sep -side top -fill both -expand yes

      pack $idxcontrol -side left -fill y    
      pack $currsection -side top -fill x
      
      tixLabelFrame $section.lf -label "Stichwortsuche" \
         -bg $dwb_vars($wbname,TABBACK)
      set f [$section.lf subwidget frame]
      $f config -bg $dwb_vars($wbname,TABBACK)
      [$section.lf subwidget label] config -font $font(h,m,r,12) \
         -bg $dwb_vars($wbname,TABBACK)
      $section.lf.border config -bg $dwb_vars($wbname,TABBACK)
      $section.lf.border.pad config -bg $dwb_vars($wbname,TABBACK)

      entry $f.search -width 20 -font $font(h,b,r,14)
      $dwb_vars(BHLP) bind $f.search -msg \
         "Stichwort auswählen"
      bind $f.search <KeyRelease> "
         ConvertEntities $f.search 1
         ShowFirstMatch $f.search $wbname
      "
      bind $f.search <Return> "
         ShowFirstMatch $f.search $wbname
         RefArticle $top $textw $wbname 0 0
      "

      pack $f.search -side bottom -fill x
      pack $section.lf -side bottom -fill x
      
      pack $sectionarea -side top -fill both -expand yes

      # --- create control area
      set control [frame $plemma.control -bd 1 -relief sunken]

      set page_back [MkFlatButton $control back ""]
      $page_back config -image [tix getimage arrleft] -command \
         "BackOneSection $wbname" -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $page_back -msg \
         "Abschnitt zurückblättern"

#      frame $control.sep -bd 1 -relief raised \
#         -background $dwb_vars($wbname,TABBACK)
      set sep_lbl [label $control.sep -relief raised -bd 1 \
         -background $dwb_vars($wbname,TABBACK) -textvariable dwb_vars(QUERY,CPHELP)]
      frame $control.sep2 -bd 1 -relief raised -width 25 \
         -background $dwb_vars($wbname,TABBACK)

      set page_fore [MkFlatButton $control fore ""]
      $page_fore config -image [tix getimage arrright] -command \
         "ForeOneSection $wbname" -background $dwb_vars($wbname,TABBACK)
      $dwb_vars(BHLP) bind $page_fore -msg \
         "Abschnitt vorblättern"

      set hit_back [MkFlatButton $control hback ""]
      $hit_back config -image [tix getimage arrleft] -command \
         "BackOneHit $wbname" -background $dwb_vars($wbname,TABBACK) \
         -state disabled
      $dwb_vars(BHLP) bind $hit_back -msg \
         "Im Suchergebnis zurückblättern"

      set hit_lbl [label $control.hitlbl -relief raised -bd 1 \
         -background $dwb_vars($wbname,TABBACK) -textvariable dwb_vars(QUERY,HITPOS)]

      set hit_fore [MkFlatButton $control hfore ""]
      $hit_fore config -image [tix getimage arrright] -command \
         "ForeOneHit $wbname" -background $dwb_vars($wbname,TABBACK) \
         -state disabled
      $dwb_vars(BHLP) bind $hit_fore -msg \
         "Im Suchergebnis vorblättern"

      set cmd [format "Configure%sTags" $wbname]
      $cmd $i

      pack $control.sep -side left -fill both -expand yes
      pack $control.hback -side left -fill y -ipadx 3
      pack $control.hitlbl -side left -fill y -ipadx 3
      pack $control.hfore -side left -fill y -ipadx 3
      pack $control.sep2 -side left -fill y
      pack $control.fore -side right -fill y -ipadx 3
      pack $control.back -side right -fill y -ipadx 3

      pack $currlemma -side top 
      pack $header1 $header2 $header3 -side top -fill x
      pack $control -side bottom -fill x
      #pack $footnote -side bottom -fill x
      pack $lemmaarea -side top -fill both -expand yes
      
      set dwb_vars(WBTEXTWDT,$wbname,$i) [winfo reqwidth [$lemmaarea subwidget text]]

      # pack $section -side left -fill both
      if {$withtoc} {
         pack $seclemma -side left -expand yes -fill both
         pack $secpane -side left -expand yes -fill both
      }

      pack $pane -side top -fill both -expand yes
      pack $main -side top -fill both -expand yes       

      # create toc area, if required
      if {$withtoc} {
         MkTOCArea $toc
      }
   }

   set dwb_vars($wbname,loaded) {}
   set dwb_vars($wbname,loadpos) {}
   set dwb_vars(WBSUBSECS,$wbname,$i,curr) 0
   set dwb_vars(HISTORY,$wbname,list) {}
   set dwb_vars(HISTORY,$wbname,pos) -1

   foreach sec $dwb_vars(WBSECTIONS) {
      set filename [format "$dwb_vars(driveletter)/Data/%s/Articles%s.txt" $wbname $sec]
      if {[file exists $filename]} {
         set state normal
      } else {
         set state disabled
      }

      set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
      set wb [lindex $dwb_vars(wbname) [expr $wbidx+1]]
      set dwb_vars(WBSUBSECS,$wbname,$sec,curr) ""
      
      set id [format "%s%s00001" $wb $sec]
      $ts insert end $sec -window $w -fill both \
         -font $font(h,m,r,14) -text $sec -state $state \
         -background $dwb_vars($wbname,TABBACK) \
         -selectbackground $dwb_vars($wbname,TABSELBACK) \
         -activebackground $dwb_vars($wbname,TABACTBACK) -command \
         "GotoArticle $id 0"
   }

   set title [CreateWBTitle $ts $wbname]
   set cmd "SelectIntroduction$wbname"
   $cmd $title

   $ts insert 0 title1 -window $title -fill both \
      -font $font(h,m,i,14) -text "T." \
      -background $dwb_vars(Special,TABBACK) \
      -selectbackground $dwb_vars(Special,TABSELBACK) \
      -activebackground $dwb_vars(Special,TABACTBACK)

   #$ts bind title1 <Enter> [eval list "DisplayInstInfo {Titelseite aufschlagen} %W %x %y"]
   #$ts bind title1 <Leave> [eval list "place forget .lfginfo"]

   set preface [MkPrefaceArea $ts $wbname wb]
   $ts insert 1 preface -window $preface -fill both \
      -font $font(h,m,i,14) -text "V." \
      -background $dwb_vars(Special,TABBACK) \
      -selectbackground $dwb_vars(Special,TABSELBACK) \
      -activebackground $dwb_vars(Special,TABACTBACK) \
      -command "OpenPreface $preface wb"

   #$ts bind preface <Enter> [eval list "DisplayInstInfo {Vorworte aufschlagen} %W %x %y"]
   #$ts bind preface <Leave> [eval list "place forget .lfginfo"]

   pack $ts -fill both -expand yes

   pack $wbarea -side top -fill both -expand yes
   update

   set dwb_vars(WBAREA,$wbname,ACTIVETAB) title1
   $ts invoke 0
}


# ---------------------------------------------------------
# create wb title area
# ---------------------------------------------------------

proc CreateWBTitle {top wbname} {
   global dwb_vars font
   
   set f [frame $top.frame]

   set titlearea [tixScrolledText $f.titlearea -scrollbar none -relief sunken -bd 1]
   set textw [$titlearea subwidget text]

   $textw config -height 24 -width 45 -padx 10 -pady 10 -wrap none \
      -background grey97 -relief flat -bd 1 -spacing1 2 \
      -spacing2 2 -spacing3 2 -highlightthickness 0 -state disabled \
      -cursor top_left_arrow -tabs { 20 30 }

   $textw tag configure headerb0 -font $font(z,b,r,24) -justify center
   $textw tag configure headerb1 -font $font(z,b,r,18) -justify center
   $textw tag configure headerb2 -font $font(z,b,r,14) -justify center
   $textw tag configure headerb3 -font $font(z,b,r,12) -justify center
   $textw tag configure headerb4 -font $font(z,b,r,10) -justify center

   $textw tag configure header0 -font $font(z,m,r,30) -justify center
   $textw tag configure header1 -font $font(z,m,r,24) -justify center
   $textw tag configure header2 -font $font(z,m,r,18) -justify center
   $textw tag configure header3 -font $font(z,m,r,14) -justify center
   $textw tag configure header4 -font $font(z,m,r,12) -justify center

   set copylabel [label $f.copy -relief flat -bd 1 -background snow1 \
      -font $font(h,m,r,10) -foreground darkgreen -pady 5]
   $copylabel config -text "Elektronische Fassung der Erstbearbeitung herausgegeben von Hans-Werner Bartz, Thomas Burch, Ruth Christmann, Kurt Gärtner, \
      Vera Hildenbrandt, Thomas Schares, Klaudia Wegge\nam Kompetenzzentrum für elektronische Erschließungs- und Publikationsverfahren in den Geisteswissenschaften an der Universität Trier\nin Verbindung mit der Berlin-Brandenburgischen Akademie der Wissenschaften,\
      gefördert durch die Deutsche Forschungsgemeinschaft"
      
   #pack $copylabel -side bottom -fill x
   pack $titlearea -expand yes -fill both
   pack $f -expand yes -fill both

   return $f
}


# ---------------------------------------------------------
# activate wb window, raise it on top
# ---------------------------------------------------------

proc ActivateWBWindow {wbname} {
   global dwb_vars

   MDI_ActivateChild $dwb_vars(WBAREA,MDI,$wbname)
}


# ---------------------------------------------------------
# create flat button
# ---------------------------------------------------------

proc MkFlatButton {top button text} {
   global font

   #set w [button $top.$button -text $text -activeforeground white \
   #   -activebackground darkolivegreen4 -borderwidth 1 -relief raised \
   #   -highlightthickness 0 -font $font(h,b,r,12) -background grey]
   set w [button $top.$button -text $text -borderwidth 1 -relief raised \
      -highlightthickness 0 -font $font(h,m,r,12) -pady 2 -padx 2]

   return $w
}


# ---------------------------------------------------------
# configure index display
# ---------------------------------------------------------

proc ConfigureSubSecsTags {name pos} {
   global dwb_vars font

   set w $dwb_vars(WBSUBSECS,$name,$pos)

   $w tag configure lemma -font $font(t,b,r,12) -foreground black
   $w tag configure variant -font $font(t,b,r,12) -foreground black
   $w tag configure abbr -font $font(t,b,r,12) -foreground black -lmargin1 20
   $w tag configure sublemma -font $font(t,b,r,12) -foreground black -lmargin1 20
   $w tag configure subvariant -font $font(t,b,r,12) -foreground black -lmargin1 20
   $w tag configure gram -font $font(t,m,i,12) -foreground black
   $w tag configure seq -lmargin1 20 -lmargin2 40
   $w tag configure derived -lmargin1 20 -lmargin2 40
}


# ---------------------------------------------------------
# configure siglearea display
# ---------------------------------------------------------

proc ConfigureSigleWindowsTags {textw} {
   global dwb_vars font

   $textw tag configure s1 -font $font(z,m,i,14) -justify left
   $textw tag configure s2 -font $font(z,m,r,14) -justify left
   $textw tag configure a1 -font $font(z,m,i,14) -justify left
   $textw tag configure a2 -font $font(z,m,r,14) -justify left
   $textw tag configure cia1 -font $font(z,m,i,14) -justify left -foreground blue
   $textw tag configure cia2 -font $font(z,m,r,14) -justify left -foreground blue
   $textw tag configure cra1 -font $font(z,m,i,12) -justify left -foreground blue
   $textw tag configure cra2 -font $font(z,m,r,12) -justify left -foreground blue
   $textw tag configure sus1 -font $font(z,m,i,12) -justify left -offset 4p
   $textw tag configure sus2 -font $font(z,m,r,12) -justify left -offset 4p
   $textw tag configure sua1 -font $font(z,m,i,12) -justify left -offset 4p
   $textw tag configure sua2 -font $font(z,m,r,12) -justify left -offset 4p
}


# ---------------------------------------------------------
# configure footnote display
# ---------------------------------------------------------

proc ConfigureFootnoteWindowsTags {fnw} {
   global font
   
   $fnw tag configure sufn2 -font $font(z,m,r,12) -offset 3p
   $fnw tag configure fn1 -font $font(z,m,i,14)
   $fnw tag configure fn2 -font $font(z,m,r,14)
   $fnw tag configure i -font $font(z,m,i,14)
}


# ---------------------------------------------------------
# configure wb display
# ---------------------------------------------------------

proc ConfigureDWBTags {pos} {
   global dwb_vars font

   set w $dwb_vars(WBTEXT,DWB,$pos)
   $w tag configure art -lmargin1 0 -lmargin2 0
   $w tag configure expart -lmargin1 0 -lmargin2 0
   $w tag configure seq -lmargin1 0 -lmargin2 0
   $w tag configure expseq -lmargin1 0 -lmargin2 0

   $w tag configure ln1 -font $font(z,b,i,12) -lmargin1 20 -offset 3p
   $w tag configure ln2 -font $font(z,b,r,12) -lmargin1 20 -offset 3p
   $w tag configure l1 -font $font(z,m,i,18) -lmargin1 20
   $w tag configure l2 -font $font(z,m,r,18) -lmargin1 20
   $w tag configure sl1 -font $font(z,m,i,14)
   $w tag configure sl2 -font $font(z,m,r,14)
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
   $w tag configure subs1 -font $font(z,m,i,12) -offset -3p
   $w tag configure subs2 -font $font(z,m,r,12) -offset -3p
   $w tag configure sn1 -font $font(z,m,i,14) -lmargin1 10 -lmargin2 0
   $w tag configure sn2 -font $font(z,m,r,14) -lmargin1 10 -lmargin2 0
   $w tag configure sngr1 -font $font(g,m,i,14) -lmargin1 10 -lmargin2 0
   $w tag configure sngr2 -font $font(g,m,i,14) -lmargin1 10 -lmargin2 0
   $w tag configure snhb1 -font $font(a,m,r,14) -lmargin1 10 -lmargin2 0
   $w tag configure snhb2 -font $font(a,m,r,14) -lmargin1 10 -lmargin2 0
   $w tag configure sus1 -font $font(z,m,i,12) -offset 3p
   $w tag configure sus2 -font $font(z,m,r,12) -offset 3p
   $w tag configure sut1 -font $font(z,m,i,12) -offset 3p
   $w tag configure sut2 -font $font(z,m,r,12) -offset 3p
   $w tag configure bir1 -font $font(z,m,i,14)
   $w tag configure bir2 -font $font(z,m,r,14)
   $w tag configure subir2 -font $font(z,m,r,12) -offset 3p
   $w tag configure br -font $font(z,m,r,14)
   $w tag configure brs -font $font(z,m,r,12) -offset 3p
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
   $w tag configure v1 -font $font(z,m,i,12)
   $w tag configure v2 -font $font(z,m,r,12)
   $w tag configure rd -font $font(z,m,i,14)
   $w tag configure da1 -font $font(z,m,i,14)
   $w tag configure da2 -font $font(z,m,r,14)
   $w tag configure xr1 -font $font(z,m,i,14)
   $w tag configure xr2 -font $font(z,m,r,14)
   
   $w tag configure fz1 -font $font(z,m,i,14)
   $w tag configure fz2 -font $font(z,m,r,14)
   $w tag configure sufz1 -font $font(z,m,i,12) -offset 3p
   $w tag configure sufz2 -font $font(z,m,r,12) -offset 3p

   # fuer autorangaben in versen, spaeter korrigieren
   $w tag configure cibir2 -font $font(z,m,r,14)
   $w tag configure crbir2 -font $font(z,m,r,12)

   $w tag configure gr1 -font $font(g,m,i,14)
   $w tag configure gr2 -font $font(g,m,i,14)
   $w tag configure sgr1 -font $font(g,m,i,14)
   $w tag configure sgr2 -font $font(g,m,i,14)

   $w tag configure shb1 -font $font(a,m,r,14)
   $w tag configure shb2 -font $font(a,m,r,14)
   
   $w tag configure cc -font $font(h,m,r,12) -foreground darkgreen

   $w tag configure ee -font $font(h,m,r,12) -foreground darkgreen
   $w tag bind ee <Enter> "$w config -cursor hand2"
   $w tag bind ee <Leave> "$w config -cursor top_left_arrow"
   
   $w tag configure ss -font $font(h,m,r,12) -foreground darkgreen
   $w tag bind ss <Enter> "$w config -cursor hand2"
   $w tag bind ss <Leave> "$w config -cursor top_left_arrow"
   
   $w tag configure lfg -font $font(h,m,r,12) -foreground darkgreen
   $w tag bind lfg <Enter> "$w config -cursor hand2"
   $w tag bind lfg <Leave> "$w config -cursor top_left_arrow; place forget .lfginfo"

   $w tag configure bm -font $font(h,b,r,12) -offset 3p \
      -foreground firebrick -background grey95 -underline true
   $w tag bind bm <Enter> "$w config -cursor hand2"
   $w tag bind bm <Leave> "$w config -cursor top_left_arrow"

   $w tag configure am -font $font(h,b,r,12) -offset 3p \
      -foreground firebrick -underline true
   $w tag bind am <Enter> "$w config -cursor hand2"
   $w tag bind am <Leave> "$w config -cursor top_left_arrow"

   $w tag bind emphasis <Enter> "$w config -cursor hand2"
   $w tag bind emphasis <Leave> "$w config -cursor top_left_arrow"
   $w tag bind emphasis <ButtonPress-1> "ScrollToNextHit $w %x %y"

   #$w tag configure expart -font $font(z,b,r,14) -foreground darkslategrey
}


# ---------------------------------------------------------
# create image for wb hyperlink
# mode 0: external link
#      1: internal link
# ---------------------------------------------------------

proc CrImg {w src tgt mode} {
   global dwb_vars wbr wbi wbm

   if {$tgt != 0} {
      set wbID [string range $tgt 0 0]
   } else {
      set wbID 0
   }
   if {$mode == 0} {
      set image $wbi($wbID)
   } else {
      set image $wbr($wbID)
   }

   label $w.lbl$dwb_vars(imagenr) -image $image -bd 0
   if {$wbID != 0} {
      bind $w.lbl$dwb_vars(imagenr) <1> [eval list "RefWBWB $src $tgt"]
   }
   $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg $wbm($wbID)
   $w win cr end -win $w.lbl$dwb_vars(imagenr) -align baseline -bd 0

   incr dwb_vars(imagenr)
}

# ---------------------------------------------------------
# create image for footnotes
# ---------------------------------------------------------

proc CrFnImg {w id fn fnz} {
   global dwb_vars wbr

   label $w.lbl$dwb_vars(imagenr) -image [tix getimage smallright] -bd 0
   set colmsg "Fußnote $fnz anzeigen"
   $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg $colmsg
   $w win cr insert -win $w.lbl$dwb_vars(imagenr) -align baseline
   bind $w.lbl$dwb_vars(imagenr) <1> [eval list "ShowDWBFootnote $id $fn $fnz"]

   $w ins insert " " fz2

   incr dwb_vars(imagenr)
}


# ---------------------------------------------------------
# create image for annotations
# ---------------------------------------------------------

proc CrAnnImg {w id} {
   global dwb_vars wbr

   label $w.lbl$dwb_vars(imagenr) -image [tix getimage notes_s2] -bd 0
   set colmsg "Anmerkung anzeigen"
   $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg $colmsg
   $w win cr insert-1c -win $w.lbl$dwb_vars(imagenr) -align baseline
   bind $w.lbl$dwb_vars(imagenr) <1> [eval list "ShowAnnotation $id"]

   incr dwb_vars(imagenr)
}


# ---------------------------------------------------------
# create image for column breaks
# ---------------------------------------------------------

proc CrColImg {w src tgt} {
   global dwb_vars wbr

   if {!$dwb_vars(MENU,col)} {
      return
   }
   
   set colmsg "Band [lindex [split $tgt "@"] 0], Spalte [lindex [split $tgt "@"] 1]"
   set colmsg "  \[[lindex [split $tgt "@"] 0],[lindex [split $tgt "@"] 1]\] "
   $w ins insert $colmsg cc
      
   incr dwb_vars(imagenr)
}

# ---------------------------------------------------------
# create image for article/installation information
# ---------------------------------------------------------

proc CrInstImg {w lemid instid} {
   global dwb_vars wbr
    
   if {!$dwb_vars(MENU,lfg) || [mk::view size DBDWB.LFG] < $instid} {
      return
   }

   #label $w.lbl$dwb_vars(imagenr) -image [tix getimage textinfo] -bd 0
   set infos [mk::get DBDWB.LFG!$instid]
   set band [lindex $infos 5]
   set dtv [lindex $infos 7]
   set jahr [lindex $infos 9]
   set bearb [lindex $infos 19]
   set lfg [lindex $infos 3]
   set msg " \[Lfg. $dtv,[lindex [split $lfg " "] 0]\]"
   $w ins insert $msg "lfg ll$lemid"
   
   set colmsg "Band: $band ($dtv DTV)\nLieferung: $lfg\nErscheinungsjahr: $jahr\nBearbeiter: $bearb"
   $w tag bind ll$lemid <Button-1> \
      [eval list "DisplayInstInfo {$colmsg} %W %x %y"]
}

# ---------------------------------------------------------
# create image for article/installation information
# ---------------------------------------------------------

proc CrExI {w lemid section wordpos {firstpos ""}} {
   CrExpandImg $w $lemid $section $wordpos $firstpos
}

proc CrExpandImg {w lemid section wordpos {firstpos ""}} {
   global dwb_vars wbr
   
   set expmsg " ...\[weiter\]"
   $w mark set expsec${lemid}@$section insert-1c
   $w mark set expwp${lemid}@${section}@${wordpos}@$firstpos insert-1c
   $w ins insert $expmsg "ee exp${lemid}@${section}@$wordpos"
   
   $w tag bind exp${lemid}@${section}@$wordpos <Button-1> \
      [eval list "ExpandSection $lemid $wordpos $section %W %x %y"]
}


proc DisplayInstInfo {msg textw xp yp} {
   global dwb_vars
   
   set dwb_vars(LFGLABEL) $msg
   set x [expr [winfo rootx $textw] + $xp]
   set y [expr [winfo rooty $textw] + $yp]
   place .lfginfo -x $x -y $y
   raise .lfginfo
   update
}


# ---------------------------------------------------------
# select wb section
# mode 0: open section without selecting article
#      1: open section and select article
# ---------------------------------------------------------

proc GotoArticle {lemid mode {lineidx ""}} {
   global dwb_vars wbi wbr wbm font
   global MDI_vars MDI_cvars

   if {[winfo exists .infopopup]} {
      return
   }
   
   place forget $dwb_vars(POPUPMENU,DWB)
   
   set lemma_id [lindex [split $lemid "."] 0]
   set sub_id [lindex [split $lemid "."] 1]
   set subnr [lindex [split $lemid "."] 2]
   if {$lemma_id == ""} {
      set lemma_id $sub_id
   }

   set wb [string range $lemma_id 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set table "LEMMA"
   set row [performQuery IDX$wbname LEMMA "ID==$lemma_id"]
   if {[lindex $row 0] != ""} {
      set parent [eval mk::get DB$wbname.LEMMA![lindex $row 0] PARENTID]
   } else {
      return
   }
   
   set lemma_id $parent

   set ts $dwb_vars(WBAREA,$wbname).ts

   set part [string range $lemma_id 1 1]
   set id [string range $lemma_id 2 end]
   set nr [string trimleft $id "0"]
   set section [expr ($nr-1)/$dwb_vars(SECTIONSIZE,$wbname)+1]

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
         #it is not in the queue

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
         set id [format "%s%s00001" $wb $part]
         $ts tab configure $part -command "GotoArticle $id 0"
      }
   } else {
      set pos [lsearch $dwb_vars($wbname,loaded) $part]
      set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   }

   if {$dwb_vars(WBSUBSECS,$wbname,$part,curr) == 0} {
      # new part, load article list

      #$dwb_vars(WBSUBSECS,$wbname,$dpidx) config -state normal
      #$dwb_vars(WBSUBSECS,$wbname,$dpidx) delete 1.0 end

      set filename [format "$dwb_vars(driveletter)/Data/%s/Articles%s.txt" $wbname $part]
      set fp [open $filename r]
      set cnts [read -nonewline $fp]
      close $fp

      set dwb_vars(LEMMALIST,$wbname,$dpidx) [split $cnts "\n"]
      set dwb_vars(FIRSTLEMMA,$wbname,$dpidx) 0
   }

   set tags [$dwb_vars(WBTEXT,$wbname,$dpidx) tag ranges lem$sub_id]
   if {[llength $tags] == 0} {
   #if {$dwb_vars(WBSUBSECS,$wbname,$part,curr) != $section} 
      # new section, load wb text

      set dwb_vars(CURRNODE) ""
      pack forget $dwb_vars(FNOTE,$wbname)
      
      set dlg [DisplayInfoPopup $dwb_vars(WBTEXT,$wbname,$dpidx) \
         "Schlage neuen Abschnitt auf..." black $dwb_vars(Special,TABBACK)]
      set dwb_vars(INFOLABEL) "Schlage neuen Abschnitt auf..."
      grab set $dlg
      update
      
      set cnt [winfo parent [winfo parent $dwb_vars(WBTEXT,$wbname,$dpidx)]]
      set twc [winfo parent $dwb_vars(WBTEXT,$wbname,$dpidx)]

      destroy $twc       

      set lemmaarea [tixScrolledText $cnt.lemmaarea -scrollbar y]
      set wbtextw [$lemmaarea subwidget text]
      $wbtextw config -height 22 -width 44 -padx 10 -pady 5 \
         -wrap word -background "grey97" -relief ridge -bd 1 \
         -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0
      pack $lemmaarea -fill both -expand yes
      ConfigureDWBTags $dpidx
      SetOptions
      
      bind $wbtextw <ButtonPress-3> \
         [eval "list ConfigureWBPopupMenu $wbtextw $wbname %x %y"]

      #add focus to window to enable mouse-selection for copy&paste         
      bind $wbtextw <ButtonPress-1> +[eval "list focus %W"]
         
      bind $wbtextw <<Copy>> {
         tk_textCopy %W
      }
      bind $wbtextw <Delete> [eval "list break"]
      bind $wbtextw <BackSpace> [eval "list break"]      
      bind $wbtextw <Control-h> [eval "list break"]
      bind $wbtextw <Any-Key> [eval "list break"]

      set vsb [$lemmaarea subwidget vsb]
      $vsb config -troughcolor $dwb_vars($wbname,TABBACK)
      $vsb config -command "ScrollWBText $wbtextw $wbname"

      set dwb_vars(WBTEXT,$wbname,$dpidx) $wbtextw
      
      $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal
      $dwb_vars(WBTEXT,$wbname,$dpidx) delete 1.0 end
      
      set dwb_vars(imagenr) 0

      #delete contents of "Artikelgliederung" textwidget
      set w $dwb_vars(WBTEXT,$wbname,$dpidx)
      set toc $dwb_vars(TABLEOFCONS,TREEW)
      $toc config -state normal
      $toc delete 1.0 end
      $toc config -state disabled

      #delete contents of "Lesezeichen" textwidget
      #set bookm_toc [$dwb_vars(BOOKMARKAREA) subwidget text]
      #$bookm_toc config -state normal
      #$bookm_toc delete 1.0 end
      #$bookm_toc config -state disabled
      
      set first [expr ($section-1)*$dwb_vars(SECTIONSIZE,$wbname)+1]
      set first $nr
      set last [expr $section*$dwb_vars(SECTIONSIZE,$wbname)]
      set last [expr $first+$dwb_vars(SECTIONSIZE,$wbname)]

      set firstID [format "%s%s%05d" $wb $part $first]
      set lastID [format "%s%s%05d" $wb $part $last]

      if {$dwb_vars(applicationType) == "offline"} {
         mk::file open TCLDB $dwb_vars(driveletter)/Data/$wbname/$part.DAT -readonly
         mk::file open TCLIDX $dwb_vars(driveletter)/Data/$wbname/$part.IDX -readonly
      }


      set in 1
      set id $first
      set lemid [format "%s%s%05d" $wb $part $id]
      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery TCLIDX TCLCODE "ID==$lemid"]
      } else {
         set row [performHTTPQuery "$wbname/$part" TCLCODE "ID==$lemid"]
      }
      if {[lindex $row 0] != ""} {
         set codebase [lindex $row 0]
         set stopdisplay 0
         set i 0
         set lemlist ""
         while {$i < $dwb_vars(SECTIONSIZE,$wbname) || !$stopdisplay} {
            set codepos [expr $codebase + $i]
            if {$codepos >= [mk::view size TCLDB.TCLCODE]} {
               break
            }
            if {$i > 0} {
               $w ins insert "\n" lem$lemid
            }
            lappend lemlist $lemid
            
            if {$dwb_vars(applicationType) == "offline"} {
               set tclcode [inflate [mk::get TCLDB.TCLCODE!$codepos CODE:B]]
               set lemid [mk::get TCLDB.TCLCODE!$codepos ID]      
               #regsub -all "ins e" $tclcode "ins insert" tclcode         
            } else {
               set tclcode [HTTPget "$wbname/$part" TCLCODE $codepos CODE:B]
            }
            if {$dwb_vars(MENU,subsign)} {
               set tclcode [SubsSpecialChars $tclcode]
            }
            set tclcode [SubsChars $tclcode]
            regsub -all "\\\\\" \{" $tclcode "\" \{" tclcode
            #puts "TCLCODE=$tclcode"
            if {[catch { eval $tclcode }]} {
               puts "error evaluating tclcode..."
            } else {
               # ok
            }
            update

            #determine if there are any bookmarks/notes set in this article
            #and add them
            #AddMarks $lemid $dwb_vars(WBTEXT,$wbname,$dpidx)    
            #$w mark set insert end-1c          

            if {$dwb_vars(applicationType) == "offline"} {
               set row [performQuery TCLIDX TOCCODE "ID==$lemid"]
            } else {
               set row [performHTTPQuery "$wbname/$part" TOCCODE "ID==$lemid"]
            }

            if {$lemid == $lemma_id} {
               set tags [$dwb_vars(WBTEXT,$wbname,$dpidx) tag ranges \
                  lem$lemma_id]
               if {[llength $tags] > 0} {
                  $dwb_vars(WBTEXT,$wbname,$dpidx) yview [lindex $tags 0]
               }
            }

            if {[lindex $row 0] != ""} {
               if {$dwb_vars(applicationType) == "offline"} {
                  set dwb_vars(nn,$lemid) [mk::get TCLDB.TOCCODE![lindex $row 0] NODES]
                  set dwb_vars(nc,$lemid) [split [mk::get TCLDB.TOCCODE![lindex $row 0] NSONS] ","]
                  set dwb_vars(fc,$lemid) [split [mk::get TCLDB.TOCCODE![lindex $row 0] FIRST] ","]
                  set dwb_vars(vis,$lemid) [split [mk::get TCLDB.TOCCODE![lindex $row 0] VIS] ","]
                  set dwb_vars(lab,$lemid) [mk::get TCLDB.TOCCODE![lindex $row 0] LABELS]
                  #puts "LABELS=$dwb_vars(lab,$lemid)"
                  regsub -all "@@@" $dwb_vars(lab,$lemid) "@" dwb_vars(lab,$lemid)
                  set dwb_vars(lab,$lemid) [split $dwb_vars(lab,$lemid) "@"]
               } else {
                  set toccode [HTTPget "$wbname/$part" TOCCODE [lindex $row 0] CODE]
               }
               $toc config -state normal
               set table "LEMMA"
               if {$dwb_vars(applicationType) == "offline"} {
                  set row [performQuery IDX$wbname $table "ID==$lemid"]
               } else {
                  set row [performHTTPQuery "$wbname/$wbname" $table "ID==$lemid"]
               }
               if {[lindex $row 0] != ""} {
                  if {$dwb_vars(applicationType) == "offline"} {
                     set lemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
                     set parent [mk::get DB$wbname.$table![lindex $row 0] PARENTID]
                  } else {
                     set lemma [HTTPget "$wbname/$wbname" $table [lindex $row 0] NAME]
                  }
               } else {
                  set lemma ""
               }
               
               set table "GRAM"
               if {$dwb_vars(applicationType) == "offline"} {
                  set row [performQuery IDX$wbname $table "ID==$lemid"]
               } else {
                  set row [performHTTPQuery "$wbname/$wbname" $table "ID==$lemid"]
               }
               if {[lindex $row 0] != ""} {
                  if {$dwb_vars(applicationType) == "offline"} {
                     set gram "[mk::get DB$wbname.$table![lindex $row 0] TYPE]."
                  } else {
                     set gram "[HTTPget "$wbname/$wbname" $table [lindex $row 0] TYPE]."
                  }
                  set sep ", "
               } else {
                  set gram ""
                  set sep ""
               }
               set dwb_vars(INFOPOPUP,ADD) "$lemma$sep$gram"
               update
               if {$dwb_vars(nn,$lemid) > 2} {
                  $toc ins insert "$lemma" "l2 node$lemid"
                  $toc ins insert "$sep" "tc2 node$lemid" 
                  $toc ins insert "$gram\n" "g1 node$lemid"
                  ShowTree $toc $lemid 0 0
                  $toc ins insert "\n" l2
               }
               $toc config -state disabled
               
               #insert lemmata into "lesezeichen" textwidget               
               #ListBookmarks
               #$bookm_toc config -state disabled
            }
            set real_lastID $lemid
            incr i
            if {$parent != $lemid} {
               set stopdisplay 0
            } else {
               set stopdisplay 1
            }
         }
      } else {
         set real_lastID ""
      }
      set dwb_vars(image_nr) $in

      if {$dwb_vars(applicationType) == "offline"} {
         mk::file close TCLDB
         mk::file close TCLIDX
      }
      
      for {set i 0} {$i < 50} {incr i} {
         $w ins e "\n"
      }

      foreach id [lsort -unique $lemlist] {
         AddMarks $id $dwb_vars(WBTEXT,$wbname,$dpidx)    
         $w mark set insert end-1c          
      }

      set dwb_vars(WBSEC,$wbname,$dpidx) $part
      
      set table "LEMMA"
      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $table "ID==$firstID"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $table "ID==$firstID"]
      }
      if {[lindex $row 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set firstlemma [eval mk::get DB$wbname.$table![lindex $row 0] NAME]
         } else {
            set firstlemma [HTTPget "$wbname/$wbname" $table [lindex $row 0] NAME]
         }
      } else {
         set firstlemma ""
      }
      set dwb_vars(FLEMMA,$wbname,$dpidx) $firstlemma
      set dwb_vars(FLEMID,$wbname,$dpidx) $firstID
      
      if {[lindex $row 0] > 0} {
         [winfo parent [winfo parent $dwb_vars(WBTEXT,$wbname,$dpidx)]].control.back config -state normal
      } else {
         [winfo parent [winfo parent $dwb_vars(WBTEXT,$wbname,$dpidx)]].control.back config -state disabled
      }

      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $table "ID==$real_lastID"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $table "ID==$real_lastID"]
      }
      if {[lindex $row 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set lastlemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
         } else {
            set lastlemma [HTTPget "$wbname/$wbname" $table [lindex $row 0] NAME]
         }
      } else {
         set lastlemma ""
      }
      set dwb_vars(LLEMMA,$wbname,$dpidx) $lastlemma
      set dwb_vars(LLEMID,$wbname,$dpidx) $real_lastID

      if {$dwb_vars(applicationType) == "offline"} {
         set size [mk::view size DB$wbname.$table]
      } else {
         set size [HTTPview size "$wbname/$wbname" $table]
      }
      if {[lindex $row 0] < [expr $size-2]} {
         [winfo parent [winfo parent $dwb_vars(WBTEXT,$wbname,$dpidx)]].control.fore config -state normal
      } else {
         [winfo parent [winfo parent $dwb_vars(WBTEXT,$wbname,$dpidx)]].control.fore config -state disabled
      }

      $dwb_vars(WBTEXT,$wbname,$dpidx) config -state disabled

      set dwb_vars(WBSUBSECS,$wbname,$part,curr) $section

      grab release $dlg
      destroy $dlg

      update
   }

   set pos [lsearch -regexp $dwb_vars(LEMMALIST,$wbname,$dpidx) \
      "id$lemma_id"]
   ShowLemmaListSection $wbname $dpidx $pos

   if {$lineidx != ""} {
      $dwb_vars(WBTEXT,$wbname,$dpidx) yview $lineidx
   } else {
      set tags [$dwb_vars(WBTEXT,$wbname,$dpidx) tag ranges \
         lem$sub_id]
      if {[llength $tags] > 0} {
         $dwb_vars(WBTEXT,$wbname,$dpidx) yview [lindex $tags 0]
      }
   }

   SetLemmaHeader $dwb_vars(WBTEXT,$wbname,$dpidx) $wbname

   if {$mode != 2} {
      AppendToHistory $wbname
   }

   if {$subnr != ""} {
      if {$sub_id != ""} {
         if {[$dwb_vars(WBTEXT,$wbname,$dpidx) index subl${sub_id}@$subnr] != ""} {
            $dwb_vars(WBTEXT,$wbname,$dpidx) see [$dwb_vars(WBTEXT,$wbname,$dpidx) index subl${sub_id}@$subnr]
         }  
      } else {
         if {[$dwb_vars(WBTEXT,$wbname,$dpidx) index subl${lemma_id}@$subnr] != ""} {
            $dwb_vars(WBTEXT,$wbname,$dpidx) see [$dwb_vars(WBTEXT,$wbname,$dpidx) index subl${lemma_id}@$subnr]
         }
      }
   }
}


# ---------------------------------------------------------
# load wb section via wb link
# ---------------------------------------------------------

proc RefWB {wbname src_lem tgt_section tgt_partno tgt_lem} {
   global dwb_vars

   GotoArticle $tgt_lem 1
}


# ---------------------------------------------------------
# trace article in list
# ---------------------------------------------------------

proc TraceArticle {top textw wbname xp yp} {
   global dwb_vars

   set tagnames [$textw tag names @$xp,$yp]
   foreach tag $tagnames {
      if {[string range $tag 0 1] == "id" && $tag != \
         $dwb_vars(WBSUBSECS,$wbname,lemma)} {
         if {$dwb_vars(WBSUBSECS,$wbname,lemma) != ""} {
            $textw tag configure \
               $dwb_vars(WBSUBSECS,$wbname,lemma) -background grey97 \
                  -borderwidth 0 -relief flat
         }
         $textw tag configure $tag -background grey80 \
            -borderwidth 0 -relief solid -bgstipple gray50
         set dwb_vars(WBSUBSECS,$wbname,lemma) $tag
      }
   }
}


# ---------------------------------------------------------
# reference article in current section
# ---------------------------------------------------------

proc RefArticleStart {header wbname} {
   global dwb_vars

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set w $dwb_vars(WBTEXT,$wbname,$dpidx)

   set tagnames [$w tag names @0,0]
   foreach tag $tagnames {
      if {[string range $tag 0 2] == "lem" && [string range $tag 3 \
         3] != "m"} {

         set lemid [string range $tag 3 end]

         set tags [$dwb_vars(WBTEXT,$wbname,$dpidx) tag ranges lem$lemid]
         if {[llength $tags] > 0} {
            $w yview [lindex $tags 0]
         }
      }
   }
   SetLemmaHeader $dwb_vars(WBTEXT,$wbname,$dpidx) $wbname
}


# ---------------------------------------------------------
# reference article in current section
# ---------------------------------------------------------

proc RefArticle {top textw wbname xp yp} {
   global dwb_vars

   set tagnames [$textw tag names @$xp,$yp]
   foreach tag $tagnames {

      if {[string range $tag 0 1] == "id"} {
         set lemma_id [lindex [split [string range $tag 2 end] "."] 1]
         set sub_id [lindex [split [string range $tag 2 end] "."] 0]
         set subnr [lindex [split [string range $tag 2 end] "."] 2]

         if {$subnr != ""} {
            GotoArticle "$lemma_id.$sub_id.$subnr" 1
         } else {
            GotoArticle "$lemma_id.$sub_id" 1
         }
      }
   }
}


# ---------------------------------------------------------
# load wb section via link from other wb
# ---------------------------------------------------------

proc RefWBWB {src_lem tgt_lem} {
   global dwb_vars

   GotoArticle $tgt_lem 1
}


# ---------------------------------------------------------
# destroy wb window within main frame
# ---------------------------------------------------------

proc DestroyWBWindow {top} {
   global dwb_vars

   # do nothing!
}


# ---------------------------------------------------------
# append current position to history 
# ---------------------------------------------------------

proc AppendToHistory {wb} {
   global dwb_vars

   set pos [lsearch $dwb_vars($wb,loaded) \
      $dwb_vars(WBAREA,$wb,ACTIVETAB)]

   if {$pos < 0} {
      return
   }

   set dpidx [lindex $dwb_vars($wb,loadpos) $pos]

   set id ""
   set tagnames [$dwb_vars(WBTEXT,$wb,$dpidx) tag names @0,0]
   foreach tag $tagnames {
      if {[string range $tag 0 2] == "lem" && [string range $tag 3 \
         3] != "m"} {
         set id [string range $tag 3 end]
         break
      }
   }
   if {$id == ""} {
      return
   }

   set line [$dwb_vars(WBTEXT,$wb,$dpidx) index @0,0]
   set idline "$id:$line"

   if {$dwb_vars(HISTORY,$wb,pos) < 0 ||
       [lindex $dwb_vars(HISTORY,$wb,list) $dwb_vars(HISTORY,$wb,pos)] != \
       $idline} {
      incr dwb_vars(HISTORY,$wb,pos)
      if {$dwb_vars(HISTORY,$wb,pos) < [llength $dwb_vars(HISTORY,$wb,list)]} {
         set dwb_vars(HISTORY,$wb,list) \
            [lreplace $dwb_vars(HISTORY,$wb,list) \
            $dwb_vars(HISTORY,$wb,pos) end]
      }
      lappend dwb_vars(HISTORY,$wb,list) "$id:$line"
   }
}


proc ReloadCurrentArticle {wbname} {
   global dwb_vars
   
   set target [lindex $dwb_vars(HISTORY,$wbname,list) \
      $dwb_vars(HISTORY,$wbname,pos)]

   #puts "TARGET=$target"
   if {$target != ""} {
      set id [lindex [split $target ":"] 0]
      set line [lindex [split $target ":"] 1]

      GotoArticle $id 2 $line      
   }     
}

# ---------------------------------------------------------
# go back in history
# ---------------------------------------------------------

proc BackInHistory {wbname} {
    MoveInHistory $wbname -1
}


# ---------------------------------------------------------
# go fore in history
# ---------------------------------------------------------

proc ForeInHistory {wbname} {
    MoveInHistory $wbname 1
}

proc MoveInHistory {wbname {step 1}} {
    global dwb_vars

   place forget $dwb_vars(POPUPMENU,DWB)   

   set next [expr $dwb_vars(HISTORY,$wbname,pos) + ( $step )]
   set target [lindex $dwb_vars(HISTORY,$wbname,list) \
      $next]

   set id [lindex [split $target ":"] 0]
   set line [lindex [split $target ":"] 1]

   if {[catch {GotoArticle $id 2 $line}] == 0} {
    set dwb_vars(HISTORY,$wbname,pos) $next
   }
}


# ---------------------------------------------------------
# scroll wb and update lemma information
# ---------------------------------------------------------

proc ScrollIndex {mainarea c p {x ""}} {

   set indexw [$mainarea.lemmaarea subwidget text]

   if {$x != ""} {
      eval $indexw yview $c $p $x
   } else {
      eval $indexw yview $c $p
   }
}


# ---------------------------------------------------------
# find first matching article
# ---------------------------------------------------------

proc ShowFirstMatch {w wbname} {
   global dwb_vars

   set text [$w get]
   if {$text == ""} {
      return
   }

   set tablename "[string toupper $wbname]LEMMA"
   set gramtable "[string toupper $wbname]GRAM"

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set normlemma [ConvertToLowercase $text]
   regsub -all " " $normlemma "" normlemma
   regsub -all "\\-" $normlemma "" normlemma
   set normlemma [NormalizeWord $normlemma]
   regsub -all "\'" $normlemma "\\\'" normlemma
   regsub -all "\\*" $normlemma "" normlemma

   if {$normlemma == ""} {
      return
   }

   $dwb_vars(WBSUBSECS,$wbname,$dpidx) config -state normal
   $dwb_vars(WBSUBSECS,$wbname,$dpidx) delete 1.0 end

   if {$dwb_vars(applicationType) == "offline"} {
      set row [performLikeQuery IDX$wbname LEMMA "NORMNAME=$normlemma*" nocase 60]
   } else {
      set row [performHTTPLikeQuery "$wbname/$wbname" LEMMA "NORMNAME=$normlemma*" nocase 60]
   }

   set i 0
   while {$i < [llength $row] && $i < 60} {
      if {$dwb_vars(applicationType) == "offline"} {
         set name [eval mk::get DB$wbname.LEMMA![lindex $row $i] NAME]
         set id [eval mk::get DB$wbname.LEMMA![lindex $row $i] ID]
         set type [eval mk::get DB$wbname.LEMMA![lindex $row $i] TYPE]
         set parent [eval mk::get DB$wbname.LEMMA![lindex $row $i] PARENTID]
         set subnr [eval mk::get DB$wbname.LEMMA![lindex $row $i] SUBNR]
      } else {
         set name [HTTPget "$wbname/$wbname" LEMMA [lindex $row $i] NAME]
         set id [HTTPget "$wbname/$wbname" LEMMA [lindex $row $i] ID]
         set type [HTTPget "$wbname/$wbname" LEMMA [lindex $row $i] TYPE]
         set parent [HTTPget "$wbname/$wbname" LEMMA [lindex $row $i] PARENTID]
         set subnr [HTTPget "$wbname/$wbname" LEMMA [lindex $row $i] SUBNR]
      }
      if {$subnr != ""} {
         set idtag "id$id.$parent.$subnr"
      } else {
         set idtag "id$id.$parent"
      }

      if {$dwb_vars(applicationType) == "offline"} {
         set subrow [performQuery IDX$wbname GRAM "ID==$id"]
      } else {
         set subrow [performHTTPQuery "$wbname/$wbname" GRAM "ID==$id"]
      }
      if {[lindex $subrow 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set gram [eval mk::get DB$wbname.GRAM![lindex $subrow 0] TYPE]
         } else {
            set gram [HTTPget "$wbname/$wbname" GRAM [lindex $subrow 0] TYPE]
         }
         if {!$type} {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "  $name" \
               "lemma $idtag"
         } else {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "  $name" \
               "sublemma $idtag"
         }
         $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end \
            ", $gram.\n" "gram $idtag"
      } else {
         if {!$type} {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "  $name\n" \
               "lemma $idtag"
         } else {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "  $name\n" \
               "sublemma $idtag"
         }
      }

      incr i
   }

   $dwb_vars(WBSUBSECS,$wbname,$dpidx) config -state disabled
}




# ---------------------------------------------------------
# goto next section in wb
# ---------------------------------------------------------

proc ForeOneSection {wbname} {
   global dwb_vars

   set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
   set wb [lindex $dwb_vars(wbname) [expr $wbidx+1]]

   set nsecs [llength $dwb_vars(WBSECTIONS)]

   set section $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set sectionnr [lsearch $dwb_vars(WBSECTIONS) $section]
   set partno $dwb_vars(WBSUBSECS,$wbname,$section,curr)
   
   set lnr [string trimleft [string range $dwb_vars(LLEMID,$wbname,1) 2 end] "0"]

   set tablename "LEMMA"

   set id [format "%s%s%05d" $wb $section [expr $lnr+1]]

   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery IDX$wbname $tablename "ID==$id"]
   } else {
      set row [performHTTPQuery "$wbname/$wbname" $tablename "ID==$id"]
   }

   if {[lindex $row 0] != ""} {
      GotoArticle $id 1
      return
   }

   while {[lindex $row 0] == ""} {
      set sectionnr [expr ($sectionnr+1)%$nsecs]
      set section [lindex $dwb_vars(WBSECTIONS) $sectionnr]

      set id [format "%s%s00001" $wb $section]

      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $tablename "ID==$id"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $tablename "ID==$id"]
      }
   }

   GotoArticle $id 1
}


# ---------------------------------------------------------
# goto previous section in wb
# ---------------------------------------------------------

proc BackOneSection {wbname} {
   global dwb_vars

   set wbidx [lsearch -exact $dwb_vars(wbname) $wbname]
   set wb [lindex $dwb_vars(wbname) [expr $wbidx+1]]

   set nsecs [llength $dwb_vars(WBSECTIONS)]

   set section $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set sectionnr [lsearch $dwb_vars(WBSECTIONS) $section]
   set partno $dwb_vars(WBSUBSECS,$wbname,$section,curr)
   incr partno -1

   set lnr [string trimleft [string range $dwb_vars(FLEMID,$wbname,1) 2 end] "0"]

   set tablename "LEMMA"

   set maxid [format "%s%s%05d" $wb $section \
      [expr $lnr-$dwb_vars(SECTIONSIZE,$wbname)]]

   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery IDX$wbname $tablename "ID==$maxid"]
   } else {
      set row [performHTTPQuery "$wbname/$wbname" $tablename "ID==$maxid"]
   }

   if {[lindex $row 0] != ""} {
      if {$dwb_vars(applicationType) == "offline"} {
         GotoArticle [eval mk::get DB$wbname.$tablename![lindex $row 0] ID] 1
      } else {
         GotoArticle [HTTPget "$wbname/$wbname" $tablename [lindex $row 0] ID] 1
      }
      return
   }

   set minid [format "%s%s00001" $wb $section]
   if {$dwb_vars(applicationType) == "offline"} {
      set rowidx [lindex [performQuery IDX$wbname $tablename "ID==$minid"] 0]
   } else {
      set rowidx [lindex [performHTTPQuery "$wbname/$wbname" $tablename "ID==$minid"] 0]
   }

   if {$rowidx > 0} {
      incr rowidx -1
      GotoArticle [eval mk::get DB$wbname.$tablename!$rowidx ID] 1
   }
}


# ---------------------------------------------------------
# scroll text and update article information in header
# ---------------------------------------------------------

proc ScrollWBText {w wbname c p {x ""}} {
   global dwb_vars

   if {$x != ""} {
      eval $w yview $c $p $x
   } else {
      eval $w yview $c $p
   }
   if {$dwb_vars(applicationType) == "offline"} {
      SetLemmaHeader $w $wbname
   }
}


# ---------------------------------------------------------
# extract lemma header from database
# ---------------------------------------------------------

proc SetLemmaHeader {w wbname} {
   global dwb_vars

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set tagnames [$w tag names @0,0]
   foreach tag $tagnames {
      if {[string range $tag 0 2] == "lem" && [string range $tag 3 \
         3] != "m"} {

         set lemid [string range $tag 3 end]

         set table "LEMMA"
         if {$dwb_vars(applicationType) == "offline"} {
            set row [performQuery IDX$wbname $table "ID==$lemid"]
         } else {
            set row [performHTTPQuery "$wbname/$wbname" $table "ID==$lemid"]
         }
         if {[lindex $row 0] != ""} {
            if {$dwb_vars(applicationType) == "offline"} {
               set lemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
               set position [mk::get DB$wbname.$table![lindex $row 0] POSITION]
            } else {
               set lemma [HTTPget "$wbname/$wbname" $table [lindex $row 0] NAME]
               set position [HTTPget "$wbname/$wbname" $table [lindex $row 0] POSITION]
            }
         } else {
            set lemma ""
            set position ""
         }

         set table "GRAM"
         if {$dwb_vars(applicationType) == "offline"} {
            set row [performQuery IDX$wbname $table "ID==$lemid"]
         } else {
            set row [performHTTPQuery "$wbname/$wbname" $table "ID==$lemid"]
         }
         if {[lindex $row 0] != ""} {
            if {$dwb_vars(applicationType) == "offline"} {
               set gram "[mk::get DB$wbname.$table![lindex $row 0] TYPE]."
            } else {
               set gram "[HTTPget "$wbname/$wbname" $table [lindex $row 0] TYPE]."
            }
            set sep ", "
         } else {
            set gram ""
            set sep ""
         }

         set glpos ""
         set m [$w mark prev @0,0]
         while {$m != "" && [string range $m 0 8] != "hp$lemid"} {
            set m [$w mark prev $m]
         }
         if {$m != ""} {
            set glpos [string range $m 9 end]
            regsub -all "@" $glpos " " glpos
         }

         set bpos ""
         set m [$w mark prev "@0,0"]
         while {$m != "" && [string range $m 0 3] != "bpos"} {
            set m [$w mark prev $m]
         }
         if {$m != ""} {
            set bpos [string range $m 4 end]
         } else {
            set bpos $position
         }

         $dwb_vars($wbname,ARTICLEPOS,$dpidx) config -state normal         
         $dwb_vars($wbname,ARTICLEPOS,$dpidx) delete 1.0 end        
         $dwb_vars($wbname,ARTICLEPOS,$dpidx) insert end "$lemma$sep" lemma
         $dwb_vars($wbname,ARTICLEPOS,$dpidx) insert end "$gram" gram
         foreach gp [split $glpos " "] {
            set gptext [lindex [split $gp "_"] 0]
            set gptype [lindex [split $gp "_"] 1]
            set gptype "glpos$gptype"
            $dwb_vars($wbname,ARTICLEPOS,$dpidx) insert end " $gptext" $gptype
         }
         $dwb_vars($wbname,ARTICLEPOS,$dpidx) config -state disabled      

         if {$bpos == ""} {
            set dwb_vars($wbname,HEADPAGE,$dpidx) $bpos
         } else {
            DisplayLemmaPosition $wbname $dpidx $bpos
         }

         set m [$w mark prev @0,0]
         while {$m != "" && [string range $m 0 10] != "node$lemid"} {
            set m [$w mark prev $m]
         }
         if {$m != ""} {
            HighlightHierarchyNode $m
         }
      }
   }
}


# ---------------------------------------------------------
# trace sigle in wbtext
# ---------------------------------------------------------

proc TraceSigle {top textw wbname xp yp} {
   global dwb_vars

   set tagnames [$textw tag names @$xp,$yp]
   foreach tag $tagnames {
      set prefTag [string range $tag 0 2]
      if {($prefTag == "sgn" || $prefTag == "ref") \
          && $tag != $dwb_vars($wbname,CURRHIGHLIGHT)} {
         if {$dwb_vars($wbname,CURRHIGHLIGHT) != ""} {
            $textw tag configure $dwb_vars($wbname,CURRHIGHLIGHT) \
               -background grey97 -relief flat
         }
         if {$prefTag == "sgn"} {
            $textw tag configure $tag \
            -background $dwb_vars(DWB,TABBACK) \
            -borderwidth 1 -relief raised
         } 
         set dwb_vars($wbname,CURRHIGHLIGHT) $tag
         return
      }
      if {$tag == $dwb_vars($wbname,CURRHIGHLIGHT)} {
         return
      }
   }
   HideSigle $textw $wbname
}


# ---------------------------------------------------------
# hide sigle information
# ---------------------------------------------------------

proc HideSigle {w wbname} {
   global dwb_vars

   if {$dwb_vars($wbname,CURRHIGHLIGHT) != ""} {
      $w tag configure $dwb_vars($wbname,CURRHIGHLIGHT) \
         -background grey97 -relief flat
   }

   set dwb_vars($wbname,CURRHIGHLIGHT) ""
}


# ---------------------------------------------------------
# reference sigle
# ---------------------------------------------------------

proc RefSigle {w wbname src tgt} {
   global dwb_vars wbr wbi

   set sgnw $dwb_vars(SIGLE,$wbname)
   pack $sgnw -side bottom -fill both

   return
   
   if {$w == $dwb_vars(WBTEXT,QVZ,1)} {
      GotoQVZArticle $tgt 1
      return
   }

   set part [string range [string toupper $tgt] 1 1]

   if {$dwb_vars(applicationType) == "offline"} {
      set filename "$dwb_vars(driveletter)Data/Quellen/$part"
      if {![file exists "$filename.DAT"]} {
         tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
         ExitDWB
      } else {
         mk::file open TCLDB $filename.DAT -readonly
      }
      if {![file exists "$filename.IDX"]} {
         tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
         ExitDWB
      } else {
         mk::file open TCLIDX $filename.IDX -readonly
      }
   }

   $w config -state normal
   $w delete 1.0 end

   # $w ins e "Quellenverzeichnisse zu den mittelhochdeutschen Wörterbüchern\n" dbh1
   # $w ins e "\n" 

   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery TCLIDX TCLCODE "ID==$tgt"]
   } else {
      set row [performHTTPQuery "Quellen/$part" TCLCODE "ID==$tgt"]
   }
   if {[lindex $row 0] != ""} {
      if {$dwb_vars(applicationType) == "offline"} {
         set tclcode [mk::get TCLDB.TCLCODE![lindex $row 0] CODE]
      } else {
         set tclcode [HTTPget "Quellen/$part" TCLCODE [lindex $row 0] CODE]
      }
      eval $tclcode
   }

   ShowQVZClassification $w $tgt

   $w config -state disabled

   if {$dwb_vars(applicationType) == "offline"} {
      mk::file close TCLDB
      mk::file close TCLIDX
   }

   set dwb_vars($wbname,CURRHIGHLIGHT) $tgt
}


# ---------------------------------------------------------
# show reference info
# ---------------------------------------------------------

proc ReferenceInfo {top wbname} {
   global dwb_vars

   if {$dwb_vars($wbname,CURRHIGHLIGHT) == ""} {
      return
   }

   set sgnw $dwb_vars(SIGLE,$wbname)
   pack $sgnw -side bottom -fill both

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   set textw $dwb_vars(SGNTEXT,$wbname,$dpidx)

   set prefTag [string range $dwb_vars($wbname,CURRHIGHLIGHT) 0 2]
   set sigid [string range $dwb_vars($wbname,CURRHIGHLIGHT) 3 end]
   $textw config -state normal
   $textw delete 1.0 end
   
   label $textw.lbl -image [tix getimage smallright] -bd 0
   set colmsg "Eintrag im Quellenverzeichnis nachschlagen"
   $dwb_vars(BHLP) bind $textw.lbl -msg $colmsg
   $textw win cr insert -win $textw.lbl -align baseline
   $textw ins insert " " s2
   set sigid [InfoSigle $top $textw $wbname $sigid]
   bind $textw.lbl <1> [eval list "GotoQVZArticle $sigid 0"]
   $textw config -state disabled
}

# ---------------------------------------------------------
# show sigle info
# ---------------------------------------------------------

proc InfoSigle {top textw wbname sigid} {
   global dwb_vars wbr wbi
   global MDI_vars MDI_cvars

   if {$sigid == "0"} {
      return
   }

   set part [string range [string toupper $sigid] 1 1]

   if {$dwb_vars(applicationType) == "offline"} {
      set filename "$dwb_vars(driveletter)Data/QVZ/$part"
      if {![file exists "$filename.DAT"]} {
         tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
         ExitDWB
      } else {
         mk::file open TCLDB $filename.DAT -readonly
      }
      if {![file exists "$filename.IDX"]} {
         tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
         ExitDWB
      } else {
         mk::file open TCLIDX $filename.IDX -readonly
      }
   }


   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery TCLIDX TCLCODE "ID==$sigid"]
   } else {
      set row [performHTTPQuery "Quellen/$part" TCLCODE "ID==$sigid"]
   }
   if {[lindex $row 0] != ""} {
      if {$dwb_vars(applicationType) == "offline"} {
         set parent [mk::get TCLDB.TCLCODE![lindex $row 0] PARENT]
         set tclcode [mk::get TCLDB.TCLCODE![lindex $row 0] CODE]
      } else {
         set parent [HTTPget "Quellen/$part" TCLCODE [lindex $row 0] PARENT]
         set tclcode [HTTPget "Quellen/$part" TCLCODE [lindex $row 0] CODE]
      }
   }

   if {$dwb_vars(applicationType) == "offline"} {
      mk::file close TCLDB
      mk::file close TCLIDX
   }

   if {$parent != $sigid} {
      set sigid [InfoSigle $top $textw $wbname $parent]      
   }

   set w $textw
   eval $tclcode
   $textw ins e "\n"
   
   return $parent
}


# ---------------------------------------------------------
# display database info for sigle
# ---------------------------------------------------------

proc ShowQVZClassification {textw sigid} {
   global dwb_vars

   $textw ins e "\n\n"
   $textw ins e "Klassifikation in der Datenbank\n" { dbh1 }
   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery IDXQVZ SIGLEN "ID==$sigid"]
   } else {
      set row [performHTTPQuery "Quellen/QVZ" SIGLEN "ID==$sigid"]
   }
   if {[lindex $row 0] != ""} {
      if {$dwb_vars(applicationType) == "offline"} {
         set textname [mk::get DBQVZ.SIGLEN![lindex $row 0] TEXTNAME]
         set stime [mk::get DBQVZ.SIGLEN![lindex $row 0] STIME:I]
         set etime [mk::get DBQVZ.SIGLEN![lindex $row 0] ETIME:I]
      } else {
         set textname [HTTPget "Quellen/QVZ" SIGLEN [lindex $row 0] TEXTNAME]
         set stime [HTTPget "Quellen/QVZ" SIGLEN [lindex $row 0] STIME:I]
         set etime [HTTPget "Quellen/QVZ" SIGLEN [lindex $row 0] ETIME:I]
      }
      regsub -all "_" $textname " " textname
      $textw ins e "\tName:  " { dbh2 }
      $textw ins e "\t$textname\n" { dbt2 }
   }
   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery IDXQVZ TYPES "ID==$sigid"]
   } else {
      set row [performHTTPQuery "Quellen/QVZ" TYPES "ID==$sigid"]
   }
   if {[llength $row] > 0} {
      set label "\tTextsorte:  "
   }
   foreach hit $row {
      if {$dwb_vars(applicationType) == "offline"} {
         set cls1 [mk::get DBQVZ.TYPES!$hit CLASS1:I]
         set cls2 [mk::get DBQVZ.TYPES!$hit CLASS2:I]
      } else {
         set cls1 [HTTPget "Quellen/QVZ" TYPES $hit CLASS1:I]
         set cls2 [HTTPget "Quellen/QVZ" TYPES $hit CLASS2:I]
      }
      set p1 [lsearch $dwb_vars(QUERY,SOURCE,part1) "CLASS1:I==$cls1"]
      if {$p1 >= 0} {
         set cn1 [lindex $dwb_vars(QUERY,SOURCE,part1) [expr $p1-1]]
      } else {
         set p1 [lsearch $dwb_vars(QUERY,SOURCE,part2) "CLASS1:I==$cls1"]
         if {$p1 >= 0} {
            set cn1 [lindex $dwb_vars(QUERY,SOURCE,part2) [expr $p1-1]]
         } else {
            set cn1 "unklassifiziert"
         }
      }
      set p1 [lsearch $dwb_vars(QUERY,SOURCE,part1) "CLASS2:I==$cls2"]
      set sep ""
      if {$p1 >= 0} {
         set cn2 [lindex $dwb_vars(QUERY,SOURCE,part1) [expr $p1-1]]
         set sep " => "
      } else {
         set p1 [lsearch $dwb_vars(QUERY,SOURCE,part2) "CLASS2:I==$cls2"]
         if {$p1 >= 0} {
            set cn2 [lindex $dwb_vars(QUERY,SOURCE,part2) [expr $p1-1]]
            set sep " => "
         } else {
            set cn2 ""
         }
      }
      regsub -all "\n" $cn1 " " cn1
      regsub -all "\n" $cn2 " " cn2
      $textw ins e $label { dbh2 }
      $textw ins e "\t$cn1$sep$cn2\n" { dbt2 }
      set label "\t  "
   }
   if {$dwb_vars(applicationType) == "offline"} {
      set row [performQuery IDXQVZ REGIONS "ID==$sigid"]
   } else {
      set row [performHTTPQuery "Quellen/QVZ" REGIONS "ID==$sigid"]
   }
   if {[llength $row] > 0} {
      set label "\tRegion:  "
   }
   foreach hit $row {
      if {$dwb_vars(applicationType) == "offline"} {
         set cls1 [mk::get DBQVZ.REGIONS!$hit CLASS1:I]
         set cls2 [mk::get DBQVZ.REGIONS!$hit CLASS2:I]
         set cls3 [mk::get DBQVZ.REGIONS!$hit CLASS3:I]
      } else {
         set cls1 [HTTPget "Quellen/QVZ" REGIONS $hit CLASS1:I]
         set cls2 [HTTPget "Quellen/QVZ" REGIONS $hit CLASS2:I]
         set cls3 [HTTPget "Quellen/QVZ" REGIONS $hit CLASS3:I]
      }
      set p1 [lsearch $dwb_vars(QUERY,DIALECT) "CLASS1:I==$cls1"]
      if {$p1 >= 0} {
         set cn1 [lindex $dwb_vars(QUERY,DIALECT) [expr $p1-1]]
      }
      set p1 [lsearch $dwb_vars(QUERY,DIALECT) "CLASS2:I==$cls2"]
      if {$p1 >= 0} {
         set cn2 [lindex $dwb_vars(QUERY,DIALECT) [expr $p1-1]]
         set sep1 " => "
      } else {
         set cn2 ""
         set sep1 ""
      }
      set p1 [lsearch $dwb_vars(QUERY,DIALECT) "CLASS3:I==$cls3"]
      if {$p1 >= 0} {
         set cn3 [lindex $dwb_vars(QUERY,DIALECT) [expr $p1-1]]
         set sep2 " => "
      } else {
         set cn3 ""
         set sep2 ""
      }
      $textw ins e $label { dbh2 }
      $textw ins e "\t$cn1$sep1$cn2$sep2$cn3\n" { dbt2 }
      set label "\t  "
   }
   $textw ins e "\tEntstehungszeit:  " { dbh2 }
   if {$stime != 0 && $etime != 0} {
      if {$etime == 9999} {
         $textw ins e "\tnach $stime\n" { dbt2 }
      } elseif {$stime == 1} {
         $textw ins e "\tvor $etime\n" { dbt2 }
      } elseif {$stime == $etime} {
         $textw ins e "\t$stime\n" { dbt2 }
      } else {
         $textw ins e "\t$stime - $etime\n" { dbt2 }
      }
   } else {
      $textw ins e "\tunklassifiziert\n" { dbt2 }
   }
   $textw ins e "\n"
}

# ---------------------------------------------------------
# pack sigle info components into MDI child window
# ---------------------------------------------------------

proc MDI_SigleInfoWindow {top wbname xp yp} {
   global dwb_vars
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild "QUELLENVERZEICHNISSE"]
   if {$n < 0} {
      InfoDialog "Info" "Kein weiteres Fenster möglich!" "Ok" info
      return 0
   }

   MDIchild_CreateWindow $n 1 1 1
   set siglearea [MkInfoSigleArea $MDI_cvars($n,client_path) \
      $wbname $n]
   set MDI_cvars($n,hide_cmd) "IconifyInfoSigleWindow $n"
   set MDI_cvars($n,xw) [expr $xp+200]
   set MDI_cvars($n,yw) [expr $yp-10]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]

   MDIchild_Show $n
   raise $MDI_cvars($n,this)

   set dwb_vars(SIGLEINFO,MDI) $n

   return 1
}


# ---------------------------------------------------------
# make wbtext popup menu
# ---------------------------------------------------------

proc MkWBPopupMenu {top wbname} {
   global dwb_vars font

   set popupmenu [frame .popup -relief raised -bd 1 \
      -background lightgrey]
   set dwb_vars(POPUPMENU,$wbname) $popupmenu
   #bind $popupmenu <Leave> "place forget $dwb_vars(POPUPMENU,DWB)"
   bind . <1> "place forget $dwb_vars(POPUPMENU,DWB); bind $top <1> \[eval bind $top <1>\]"
   set headerarea [text $popupmenu.head]
   $headerarea config -height 1 -width 20 -padx 10 -pady 5 \
      -wrap none -background "grey90" -relief flat -bd 0 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 30 } \
      -exportselection yes -selectforeground white \
      -selectbackground grey80 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(z,b,r,14)
   set dwb_vars($wbname,POPUPHEAD) $headerarea
   $dwb_vars($wbname,POPUPHEAD) tag configure lemma -font $font(z,b,r,14)
   $dwb_vars($wbname,POPUPHEAD) tag configure gram -font $font(z,b,i,14)

   #bind $popupmenu.head <Button1-Motion> "place $dwb_vars(POPUPMENU,DWB) -x %x -y %y"
   
   frame $popupmenu.lab1 -relief raised -bd 1 \
      -background $dwb_vars($wbname,TABBACK) -height 3
      
   frame $popupmenu.fback -relief flat -bd 0 
   set back [MkFlatButton $popupmenu.fback back "Zurückblättern"] 
   $back config -command "BackInHistory $wbname" -font $font(h,m,r,14) \
      -background grey
   pack $popupmenu.fback.back -side left -fill both -expand yes

   frame $popupmenu.ffore -relief flat -bd 0 
   set fore [MkFlatButton $popupmenu.ffore fore "Vorblättern"] 
   $fore config -command "ForeInHistory $wbname" -font $font(h,m,r,14) \
      -background grey
   pack $popupmenu.ffore.fore -side left -fill both -expand yes

   #frame $popupmenu.lab2 -relief raised -bd 1 \
   #   -background $dwb_vars($wbname,TABBACK) -height 3
      
   #frame $popupmenu.fprnt -relief flat -bd 0
   #set prnt [MkFlatButton $popupmenu.fprnt prnt "Artikel drucken..."] 
   #$prnt config -command "" -font $font(h,m,r,14)
   #pack $popupmenu.fprnt.prnt -side left -fill both -expand yes

   frame $popupmenu.fexpa -relief flat -bd 0
   set expa [MkFlatButton $popupmenu.fexpa expa "Alle Abschnitte expandieren"] 
   $expa config -command "" -font $font(h,m,r,14) -state disabled \
      -background grey
   bind $expa <Enter> ""
   bind $expa <Leave> ""
   pack $popupmenu.fexpa.expa -side left -fill both -expand yes

   #frame $popupmenu.lab3 -relief raised -bd 1 \
   #   -background $dwb_vars($wbname,TABBACK) -height 3
   
      frame $popupmenu.fehtm -relief raised -bd 0 
   set ehtm [MkFlatButton $popupmenu.fehtm ehtm "Artikel als HTML exportieren"] 
   $ehtm config -command "" -font $font(h,m,r,14) -background grey
   pack $popupmenu.fehtm.ehtm -side left -fill both -expand yes
   
   frame $popupmenu.fsbmk -relief raised -bd 0 
   set sbmk [MkFlatButton $popupmenu.fsbmk sbmk "Lesezeichen anlegen"] 
   $sbmk config -command "" -font $font(h,m,r,14) -background grey
   pack $popupmenu.fsbmk.sbmk -side left -fill both -expand yes

   frame $popupmenu.fcnot -relief raised -bd 0 
   set cnote [MkFlatButton $popupmenu.fcnot cnote "Anmerkung schreiben"] 
   $cnote config -command "" -font $font(h,m,r,14) -background grey
   pack $popupmenu.fcnot.cnote -side left -fill both -expand yes

   pack $popupmenu.head $popupmenu.lab1 $popupmenu.fback $popupmenu.ffore \
      $popupmenu.fexpa $popupmenu.fehtm $popupmenu.fsbmk $popupmenu.fcnot \
      -side top -fill x
}


# ---------------------------------------------------------
# configure wbtext popup menu
# ---------------------------------------------------------

proc ConfigureWBPopupMenu {top wbname xp yp} {
   global dwb_vars font
   set duration 6412
   # puts "ConfigureWBPopupMenu top $top wbname $wbname xp $xp yp $yp"

   set x $xp
   set y $yp
   set mx [expr $xp + [winfo rootx $top]]
   set my [expr $yp + [winfo rooty $top]]
   
   if {[expr $my+[winfo reqheight $dwb_vars(POPUPMENU,DWB)]] > $dwb_vars(YRES)} {
      set my [expr $dwb_vars(YRES)-[winfo reqheight $dwb_vars(POPUPMENU,DWB)]-50]
   }

   set menu $dwb_vars(POPUPMENU,DWB)
   place $dwb_vars(POPUPMENU,DWB) -x $mx -y $my
   #after $duration place forget $dwb_vars(POPUPMENU,DWB)
  
   # Display History Back and Forward Buttons if apropriate  
   if {$dwb_vars(HISTORY,$wbname,pos) > 0} {
      $menu.fback.back configure -state normal
      bind $menu.fback.back <1> "BackInHistory $wbname"
      bind $menu.fback.back <Enter> "$menu.fback.back config -background $dwb_vars($wbname,TABBACK)"
      bind $menu.fback.back <Leave> "$menu.fback.back config -background grey"
   } else {
      $menu.fback.back configure -state disabled
      bind $menu.fback.back <Enter> ""
      bind $menu.fback.back <Leave> ""
   }
   if {$dwb_vars(HISTORY,$wbname,pos) == [expr [llength $dwb_vars(HISTORY,$wbname,list)] - 1]} {
      $menu.ffore.fore configure -state disabled
      bind $menu.ffore.fore <Enter> ""
      bind $menu.ffore.fore <Leave> ""
   } else {
      $menu.ffore.fore configure -state normal
      bind $menu.ffore.fore <1> "ForeInHistory $wbname"
      bind $menu.ffore.fore <Enter> "$menu.ffore.fore config -background $dwb_vars($wbname,TABBACK)"
      bind $menu.ffore.fore <Leave> "$menu.ffore.fore config -background grey"
   }

   set tagnames [$top tag names @$x,$y]
   if {[lsearch $tagnames "art"] < 0 && [lsearch $tagnames "seq"] < 0 &&
       [lsearch $tagnames "expart"] < 0} {
      $menu.fexpa.expa configure -state disabled
      $menu.fcnot.cnote configure -state disabled
      $menu.fsbmk.sbmk configure -state disabled
      return
   }
   if {[lsearch $tagnames "ee"] >= 0 || [lsearch $tagnames "cc"] >= 0 || \
       [lsearch $tagnames "lfg"] >= 0} {
      $menu.fcnot.cnote configure -state disabled
      $menu.fsbmk.sbmk configure -state disabled
      return
   }
   foreach tag $tagnames {
      if {[string range $tag 0 2] == "lem" && [string range $tag 3 \
         3] != "m"} {

         set lemid [string range $tag 3 end]

         if {$dwb_vars(applicationType) == "offline"} {
            set tablename "LEMMA"
            set row [performQuery IDX$wbname $tablename "ID==$lemid"]
            if {[lindex $row 0] != ""} {
               set position [eval mk::get DB$wbname.$tablename![lindex $row 0] POSITION]
               set lemma [eval mk::get DB$wbname.$tablename![lindex $row 0] NAME]
               set grow [performQuery IDX$wbname GRAM "ID==$lemid"]
               if {[lindex $grow 0] != ""} {
                  set gram "[mk::get DB$wbname.GRAM![lindex $grow 0] TYPE]."
                  set sep ", "
               } else {
                  set gram ""
                  set sep ""
               }
               $dwb_vars($wbname,POPUPHEAD) config -state normal
               $dwb_vars($wbname,POPUPHEAD) delete 1.0 end
               $dwb_vars($wbname,POPUPHEAD) ins e $lemma lemma
               $dwb_vars($wbname,POPUPHEAD) ins e $sep$gram gram
               $dwb_vars($wbname,POPUPHEAD) config -state disabled
            }
         }

         #$menu.fprnt.prnt configure -state disabled -command \
         #   "place forget $dwb_vars(POPUPMENU,DWB);PrintArticleDialog $lemid"
         #bind $menu.fprnt.prnt <Enter> "$menu.fprnt.prnt config -background $dwb_vars($wbname,TABBACK)"
         #bind $menu.fprnt.prnt <Leave> "$menu.fprnt.prnt config -background grey"
#ExportHtml
         $menu.fexpa.expa configure -state normal
         bind $menu.fexpa.expa <1> "place forget $dwb_vars(POPUPMENU,DWB);ExpandAllSections $lemid"
         bind $menu.fexpa.expa <Enter> "$menu.fexpa.expa config -background $dwb_vars($wbname,TABBACK)"
         bind $menu.fexpa.expa <Leave> "$menu.fexpa.expa config -background grey"
      
         # export as html
         $menu.fehtm.ehtm configure -state normal
         bind $menu.fehtm.ehtm <1> "place forget $dwb_vars(POPUPMENU,DWB);ExportHtml $lemid"
         bind $menu.fehtm.ehtm <Enter> "$menu.fehtm.ehtm config -background $dwb_vars($wbname,TABBACK)"
         bind $menu.fehtm.ehtm <Leave> "$menu.fehtm.ehtm config -background grey"

         #create note
         $menu.fcnot.cnote configure -state normal
         bind $menu.fcnot.cnote <1> "place forget $dwb_vars(POPUPMENU,DWB);InsertMark $top $wbname 1 $xp $yp $lemid"
         bind $menu.fcnot.cnote <Enter> "$menu.fcnot.cnote config -background $dwb_vars($wbname,TABBACK)"
         bind $menu.fcnot.cnote <Leave> "$menu.fcnot.cnote config -background grey"

         #create bookmark
         $menu.fsbmk.sbmk configure -state normal 
         bind $menu.fsbmk.sbmk <1> "place forget $dwb_vars(POPUPMENU,DWB);InsertMark $top $wbname 0 $xp $yp $lemid"   
         bind $menu.fsbmk.sbmk <Enter> "$menu.fsbmk.sbmk config -background $dwb_vars($wbname,TABBACK)"
         bind $menu.fsbmk.sbmk <Leave> "$menu.fsbmk.sbmk config -background grey"
   
         place $dwb_vars(POPUPMENU,DWB) -x $mx -y $my
         break
      }
   }  
}


# ---------------------------------------------------------
# create bookmark
# ---------------------------------------------------------

proc CreateBookMark {w article xp yp} {
   global dwb_vars
   # puts "CreateBookMark  w $w article $article xp $xp yp $yp"

   set idx [$w search -backward " " @$xp,$yp]
   $w config -state normal
   
   label $w.lbl$dwb_vars(imagenr) -image [tix getimage smallright2] -bd 0
   $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg "Anmerkung schreiben"
   $w ins "$idx" " "
   $w win cr "$idx+1 chars" -win $w.lbl$dwb_vars(imagenr) -align baseline
   set idx2 [$w search " " "$idx+40 chars"]
   set text [$w get $idx $idx2]
   incr dwb_vars(imagenr)
   $w config -state disabled

   if {![info exists dwb_vars(BOOKMARKS,$article)]} {
      set dwb_vars(BOOKMARKS,$article) {}
      lappend dwb_vars(ALLBOOKMARKS) $article 
   }
   lappend dwb_vars(BOOKMARKS,$article) "$text"
   
   UpdateBookMarkArea insert book $article "$text"
}


# ---------------------------------------------------------
# delete bookmark
# ---------------------------------------------------------

proc DeleteBookMark {bookmark_idx article} {
   global dwb_vars

   set dwb_vars(BOOKMARKS) [lreplace $dwb_vars(BOOKMARKS) \
      $bookmark_idx $bookmark_idx]
   UpdateBookMarkArea delete book $article
}


# ---------------------------------------------------------
# notes components display area
# ---------------------------------------------------------

proc MkNotesBookMarksDisplay {top id} {
   global dwb_vars font
   global MDI_vars MDI_cvars

   set noteframe [frame $top.notes -background grey -borderwidth 1 \
      -relief flat]

   set notearea [tixScrolledText $noteframe.notes -scrollbar both]
   set notetextw [$notearea subwidget text]
   $notetextw config -height 15 -width 44 -padx 10 -pady 5 \
      -wrap none -background "grey97" -relief raised -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 right 35 left 45 left } \
      -exportselection yes -selectforeground white \
      -selectbackground grey80 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(z,m,r,12)
      
   $notetextw tag configure lemma -font $font(z,m,r,18)
   $notetextw tag configure gram -font $font(z,m,i,14)
   $notetextw tag configure context -font $font(z,m,r,14)
   $notetextw tag configure bm -font $font(h,b,r,12) -offset 3p \
      -foreground firebrick -underline true

   pack $notearea -side top -expand yes -fill both
   pack $noteframe -side top -expand yes -fill both
   update

   set dwb_vars(BOOKMARKAREA) $notearea
   ListBookmarks
}


# ---------------------------------------------------------
# update bookmark area
# ---------------------------------------------------------

proc UpdateBookMarkArea {cmd type lemid context} {
   global dwb_vars font
   global wbi

   set textw [$dwb_vars(BOOKMARKAREA) subwidget text]
   $textw config -state normal

   if {$cmd == "insert"} {
      set wb [string range $lemid 0 0]
      set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
      set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

      set ltable "LEMMA"
      set gtable "GRAM"

      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $ltable "ID==$lemid"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $ltable "ID==$lemid"]
      }
      if {[lindex $row 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set lemma [mk::get DB$wbname.$ltable![lindex $row 0] NAME]
         } else {
            set lemma [HTTPget "$wbname/$wbname" $ltable [lindex $row 0] NAME]
         }
      } else {
         return
      }

      if {$dwb_vars(applicationType) == "offline"} {
         set row [performQuery IDX$wbname $gtable "ID==$lemid"]
      } else {
         set row [performHTTPQuery "$wbname/$wbname" $gtable "ID==$lemid"]
      }
      if {[lindex $row 0] != ""} {
         if {$dwb_vars(applicationType) == "offline"} {
            set gram "[mk::get DB$wbname.$gtable![lindex $row 0] TYPE]."
         } else {
            set gram [HTTPget "$wbname/$wbname" $gtable [lindex $row 0] TYPE].
         }
      } else {
         set gram ""
      }

      label $textw.lbl$dwb_vars(imagenr) -image [tix getimage smallright2]
      $textw win cr end -win $textw.lbl$dwb_vars(imagenr) -align baseline
      incr dwb_vars(imagenr)

      $textw ins end "\t$lemma" LEMMA
      if {$gram != ""} {
      	 $textw ins end ", $gram" GRAM
      }
      $textw ins end "\n"
      if {$context != ""} {
      	 $textw ins end "\t... $context ...\n" TEXT
      }     
   }
   if {$cmd == "delete"} {
      $hlist delete entry $type$lemid
   }
   if {$cmd == "update"} {
      if {$type == "note"} {
         set filename "./System/note$lemid.txt"
         if {[file exists $filename]} {
            set fp [open $filename r]
            set text [string trimright [read $fp] "\n"]
            close $fp
            if {[string length $text] > 30} {
               set text "[string range $text 0 24]..."
            }

            $hlist item configure $type$lemid 3 -text $text
         }
      }
   }
   
   $textw config -state disabled
}


# ---------------------------------------------------------
# save bookmarks
# ---------------------------------------------------------

proc SaveBookMarks {} {
   global dwb_vars

   set filename "./System/bookmarks"
   set fp [open $filename w]
   foreach bookmark $dwb_vars(ALLBOOKMARKS) {
      puts -nonewline $fp $bookmark
      puts -nonewline $fp "@"
      puts -nonewline $fp [llength $dwb_vars(BOOKMARKS,$bookmark)]
      foreach element $dwb_vars(BOOKMARKS,$bookmark) {
         puts -nonewline $fp "@"
         puts -nonewline $fp $element
      }      
   }
   if {[llength $dwb_vars(ALLBOOKMARKS)] > 0} {
      puts $fp ""
   }
   close $fp
}


# ---------------------------------------------------------
# save bookmarks
# ---------------------------------------------------------

proc ReadBookMarks {} {
   global dwb_vars

   set dwb_vars(ALLBOOKMARKS) {}
   set filename "./System/bookmarks"
   if {[file exists $filename]} {
      set fp [open $filename r]
      set cnts [read $fp]
      close $fp
      
      set elements [split $cnts "@"]
      set i 0
      while {$i < [llength $elements]} {
      	 set article [lindex $elements $i]
      	 incr i
      	 set nmarks [lindex $elements $i]
      	 incr i
      	 set dwb_vars(BOOKMARKS,$article) {}
      	 lappend dwb_vars(ALLBOOKMARKS) $article
      	 for {set j 0} {$j < $nmarks} {incr j} {
      	    lappend dwb_vars(BOOKMARKS,$article) [lindex $elements $i]
      	    incr i
      	 }
      }
   }
}


# ---------------------------------------------------------
# activate bookmark
# ---------------------------------------------------------

proc ActivateBookMark {entry} {
   global dwb_vars

   set type [string range $entry 0 3]
   set id [string range $entry 4 end]

   set wb [string range $id 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   GotoArticle $id 1
   if {$type == "note"} {
      MDI_NotesComponents $id 300 300 edit
   }
}


# ---------------------------------------------------------
# LemmaListPageDown
# ---------------------------------------------------------

proc LemmaListScroll {wbname unit dir repeat} {
   global tkPriv
   global dwb_vars

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]

   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   if {$dir == "down"} {
      if {$unit == "page"} {
         set lc [expr $dwb_vars(FIRSTLEMMA,$wbname,$dpidx) + 22]
      }
      if {$unit == "line"} {
         set lc [expr $dwb_vars(FIRSTLEMMA,$wbname,$dpidx) + 1]
      }
      # set dwb_vars(FIRSTLEMMA,$wbname,$dpidx) $lc
   }

   if {$dir == "up"} {
      if {$unit == "page"} {
         set lc [expr $dwb_vars(FIRSTLEMMA,$wbname,$dpidx) - 22]
      }
      if {$unit == "line"} {
         set lc [expr $dwb_vars(FIRSTLEMMA,$wbname,$dpidx) - 1]
      }
   }

   ShowLemmaListSection $wbname $dpidx $lc

   if {$repeat == "again"} {
      set tkPriv(afterId) [after 100 LemmaListScroll $wbname $unit \
         $dir again]
   } \
   elseif {$repeat == "initial"} {
      set tkPriv(afterId) [after 300 LemmaListScroll $wbname $unit \
         $dir again]
   }
}


# ---------------------------------------------------------
# show part of lemma list
# ---------------------------------------------------------

proc ShowLemmaListSection {wbname dpidx lc} {
   global dwb_vars

   if {$lc < 0} {
      set lc 0
   }

   set last [expr $lc + 60]
   if {$lc > [expr [llength $dwb_vars(LEMMALIST,$wbname,$dpidx)] \
      - 1]} {
      return
   }

   set dwb_vars(FIRSTLEMMA,$wbname,$dpidx) $lc

   $dwb_vars(WBSUBSECS,$wbname,$dpidx) config -state normal
   $dwb_vars(WBSUBSECS,$wbname,$dpidx) delete 1.0 end

   set linesep ""
   set lineprefix "  "
   while {$lc < $last && $lc < \
      [llength $dwb_vars(LEMMALIST,$wbname,$dpidx)]} {
      set line [lindex $dwb_vars(LEMMALIST,$wbname,$dpidx) $lc]
      if {$line == ""} {
         incr lc
         continue
      }
      set l [split [string trimright $line "|"] "|"]
      set i 0
      while {$i < [llength $l]} {
         set text [lindex $l $i]
         set taglist [lindex $l [expr $i+1]]
         if {[lsearch $taglist "abbr"] >= 0 || [lsearch $taglist "sublemma"] >= 0 || [lsearch $taglist "subvariant"] >= 0} {
            set text [ConvertToLowercase $text]
         }
         if {[lsearch $taglist "variant"] >= 0 || [lsearch $taglist "subvariant"] >= 0} {
            set linesep ", "
         }
         if {[lsearch $taglist "gram"] >= 0} {
            set linesep ""
         }
         set tags ""
         foreach tag $taglist {
            set tag [lindex [split $tag "."] 0]
            set tags [lappend tags $tag]
         }
         if {$linesep == ", "} {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "$linesep" $taglist
         } else {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "$linesep"
         }
         if {[lsearch $taglist "gram"] >= 0} {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "$lineprefix$text" "$taglist"
         } else {
            $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "$lineprefix$text" "$taglist"
         }
         set lineprefix ""

         incr i 2
      }
      $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "  \n" $taglist
      set linesep ""
      set lineprefix "  "
      incr lc
   }
   $dwb_vars(WBSUBSECS,$wbname,$dpidx) insert end "\n"
   $dwb_vars(WBSUBSECS,$wbname,$dpidx) config -state disabled
}


# ---------------------------------------------------------
# export article as rtf file
# ---------------------------------------------------------

proc ExportArticleToRTF {lemid filename} {
   global dwb_vars

   set wb [string range $lemid 0 0]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set tags [$dwb_vars(WBTEXT,$wbname,$dpidx) tag ranges lem$lemid]
   if {[llength $tags] > 0} {
      set first [lindex $tags 0]
      set last [lindex $tags end]
      ExportToRTF $dwb_vars(WBTEXT,$wbname,$dpidx) $first $last \
         $filename
   }
}


# ---------------------------------------------------------
# create file select box
# the parameter contains the widget's label
# ---------------------------------------------------------

proc ExportRTFFileDialog {text lemid} {

   set dialog [tix filedialog tixExFileSelectDialog]
   $dialog config -title $text
   $dialog config -command "TestRTFFilename $lemid"
   $dialog subwidget fsbox config -pattern {*.rtf}
   $dialog subwidget fsbox config -filetypes {
                {{*.rtf}        {RTF Dateien}}
                {{*}    {Alle Dateien}}
   }

   $dialog subwidget fsbox filter

   set fsbox [$dialog subwidget fsbox]
   $fsbox subwidget types pick 0

   $dialog popup

   focus $dialog
}


# ---------------------------------------------------------
# test, whether file exists
# ---------------------------------------------------------

proc TestRTFFilename {lemid filename} {
   global dwb_vars

   if {[file exist $filename]} {
      WarningDialog "Warnung" "Eine Datei mit diesem Namen \
         existiert bereits.\nSoll sie überschrieben werden?" "Ja" \
         "Nein" "ExportArticleToRTF $lemid $filename"
   } else {
      ExportArticleToRTF $lemid $filename
   }
}


# ---------------------------------------------------------
# convert entities to real letters
# ---------------------------------------------------------

proc ConvertEntities {ew mode} {

   set text [$ew get]
   set oldtext $text

   regsub -all "\#\\.\\^A" $text "Æ" text
   regsub -all "\#\\.\\^a" $text "æ" text
   regsub -all "\#\\.\\^o" $text "[format "%c" 161]" text
   regsub -all "\#\\.\\^O" $text "[format "%c" 160]" text
   regsub -all "\#\\.Ä" $text "Æ" text
   regsub -all "\#\\.ä" $text "æ" text
   regsub -all "\#\\.ö" $text "[format "%c" 161]" text
   regsub -all "\#\\.Ö" $text "[format "%c" 160]" text

   regsub -all "\\^a" $text "ä" text
   regsub -all "%:e" $text "ë" text
   regsub -all "\\^o" $text "ö" text
   regsub -all "\\^s" $text "ß" text
   regsub -all "\\^u" $text "ü" text
   regsub -all "\#\\.z" $text "[format "%c" 172]" text
   regsub -all "\#\\.Z" $text "[format "%c" 191]" text

   regsub -all "%\/a" $text "á" text
   regsub -all "%\/e" $text "é" text
   regsub -all "%\/i" $text "í" text
   regsub -all "%\/o" $text "ó" text
   regsub -all "%\/u" $text "ú" text
   regsub -all "%\/y" $text "ý" text

   regsub -all "%\/A" $text "Á" text
   regsub -all "%\/E" $text "É" text
   regsub -all "%\/I" $text "Í" text
   regsub -all "%\/O" $text "Ó" text
   regsub -all "%\/U" $text "Ú" text
   regsub -all "%\/Y" $text "Ý" text

   regsub -all "%<a" $text "â" text
   regsub -all "%<e" $text "ê" text
   regsub -all "%<i" $text "î" text
   regsub -all "%<o" $text "ô" text
   regsub -all "%<u" $text "û" text

   regsub -all "%<A" $text "Â" text
   regsub -all "%<E" $text "Ê" text
   regsub -all "%<I" $text "Î" text
   regsub -all "%<O" $text "Ô" text
   regsub -all "%<U" $text "Û" text

   regsub -all "%>i" $text "i" text

   regsub -all "%\\\\a" $text "à" text
   regsub -all "%\\\\e" $text "è" text
   regsub -all "%\\\\i" $text "ì" text
   regsub -all "%\\\\o" $text "ò" text
   regsub -all "%\\\\u" $text "ù" text

   regsub -all "%\\\\A" $text "À" text
   regsub -all "%\\\\E" $text "È" text
   regsub -all "%\\\\I" $text "Ì" text
   regsub -all "%\\\\O" $text "Ò" text
   regsub -all "%\\\\U" $text "Ù" text

   regsub -all "%-e" $text "e" text
   regsub -all "%-i" $text "i" text
   regsub -all "%-n" $text "n" text
   regsub -all "%.m" $text "m" text

   regsub -all "\\\$=" $text "" text
   regsub -all "\\\$:" $text " " text
   
   if {$mode} {
      set text [ConvertToUppercase $text]
   }
   
   if {$text != $oldtext} {
      $ew delete 0 end
      $ew insert end $text
   }
}

# ---------------------------------------------------------
# space word
# ---------------------------------------------------------

proc SpaceWord {word} {

   set spcword ""
   set sep ""
   for {set i 0} {$i < [string length $word]} {incr i} {
      set spcword "$spcword$sep[string index $word $i]"
      set sep [format "%c" 160]
   }

   return $spcword
}


# ---------------------------------------------------------
# save user configurations
# ---------------------------------------------------------

proc SaveUserConf {} {
   global dwb_vars MDI_cvars

   set filename "./System/config"
   set fp [open $filename w]

   if {$dwb_vars(ACROREAD,PATH) != ""} {
      puts $fp "acrobat-reader-path|$dwb_vars(ACROREAD,PATH)"
   }
   
   set p1 $dwb_vars(WBAREAFRAME,DWB).main.pane
   puts $fp "pane-size|section|[winfo width [$p1 subwidget section]]"
   set p2 [$p1 subwidget lemma].f.pane
   puts $fp "pane-size|lemma|[winfo width [$p2 subwidget lemma]]"
   puts $fp "pane-size|toc|[winfo width [$p2 subwidget toc]]"
   puts $fp "htmlexportdir|$dwb_vars(htmlexportdir)"
   
   foreach {wbname wbID} $dwb_vars(wbname) { 
      if {[info exists dwb_vars(WBAREA,MDI,$wbname)]} {
         set width $MDI_cvars($dwb_vars(WBAREA,MDI,$wbname),width)
         set height $MDI_cvars($dwb_vars(WBAREA,MDI,$wbname),height)
         set xp $MDI_cvars($dwb_vars(WBAREA,MDI,$wbname),xw)
         set yp $MDI_cvars($dwb_vars(WBAREA,MDI,$wbname),yw)
         set hide $MDI_cvars($dwb_vars(WBAREA,MDI,$wbname),hide)

         puts $fp "wb-window-size-user|$wbname|$xp|$yp|$width|$height|$hide"
      }
   }

   if {[info exists dwb_vars(MENU,gram)]} {
      puts $fp "options|gram|$dwb_vars(MENU,gram)"
      puts $fp "options|siglen|$dwb_vars(MENU,siglen)"
      puts $fp "options|sigrefs|$dwb_vars(MENU,sigrefs)"
      puts $fp "options|sense|$dwb_vars(MENU,sense)"
      puts $fp "options|belege|$dwb_vars(MENU,belege)"
      puts $fp "options|etym|$dwb_vars(MENU,etym)"
      puts $fp "options|definition|$dwb_vars(MENU,definition)"
      puts $fp "options|lfg|$dwb_vars(MENU,lfg)"
      puts $fp "options|col|$dwb_vars(MENU,col)"
      puts $fp "options|intro|$dwb_vars(MENU,intro)"
      puts $fp "options|subsign|$dwb_vars(MENU,subsign)"
      puts $fp "options|confexp|$dwb_vars(MENU,confexp)"
   }
   close $fp
}


# ---------------------------------------------------------
# show original position
# ---------------------------------------------------------

proc DisplayLemmaPosition {wbname dpidx position} {
   global dwb_vars

   if {$wbname == "DWB"} {
      set book [lindex [split $position "."] 0]

      set column [lindex [split $position "."] 1]
      set column [string trimleft $column "0"]

      set line [lindex [split $position "."] 2]
      set line [string trimleft $line "0"]

      set pos "Bd. $book, Sp. $column, $line"
      set dwb_vars($wbname,HEADPAGE,$dpidx) $pos
   } else {
     set dwb_vars($wbname,HEADPAGE,$dpidx) ""
   }
}

 
# ---------------------------------------------------------
# expand article section
# ---------------------------------------------------------

proc ExpandSection {lemma_id wordpos section lblwin x y {fopen 1}} {
   global dwb_vars wbr wbi wbm font

   #puts "ExpandSection $lemma_id $wordpos $section $lblwin $x $y"
   set xp [expr [winfo x $lblwin] + $x]
   set yp [expr [winfo y $lblwin] + $y]

   set wb [string range $lemma_id 0 0]
   set part [string range $lemma_id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal

   set w $dwb_vars(WBTEXT,$wbname,$dpidx)
   set ranges [$w tag ranges lem$lemma_id]

   set partID [format "%s%03d" $lemma_id $section]
   
   if {$fopen == 1} {
      mk::file open TCLDB $dwb_vars(driveletter)/Data/$wbname/$part.DAT -readonly
      mk::file open TCLIDX $dwb_vars(driveletter)/Data/$wbname/$part.IDX -readonly
   }

   set row [performQuery TCLIDX TCLSUBCODE "ID==$partID"]
   if {[lindex $row 0] != ""} {
      set tr [$w tag range exp${lemma_id}@${section}@$wordpos]
      if {$tr != ""} {
         set tclcode [inflate [mk::get TCLDB.TCLSUBCODE![lindex $row 0] CODE:B]]
         if {$dwb_vars(MENU,subsign)} {
            set tclcode [SubsSpecialChars $tclcode]
         }
         set tclcode [SubsChars $tclcode]
    
         $w mark set insert expsec$lemma_id@$section

         $w delete insert insert+13c
         #$w mark set insert [lindex $tr 0]
         #$w delete [lindex $tr 0]-1c [lindex $tr 1]
      
         # $w mark set insert @$xp,$yp
         #set spos [$w index insert-8c]
         #puts "[$w get insert-8c insert]"
         #$w delete insert-8c insert+2c
         set apos [$w index insert]
         puts "SUBCODE=$tclcode"
         if {[catch { eval $tclcode }]} {
            puts "error evaluating tclcode..."
         } else {
            # ok
         }
         #eval $tclcode
         set epos [$w index insert]
      
         $w tag add expsec${lemma_id}@$section $apos $epos

         for {set nxi 0} {$nxi < [mk::view size UDB.NOTES]} {incr nxi} {         
            set vals [mk::get UDB.NOTES!$nxi ID NR TYPE POS EXPMARK TEXT CONTEXT]
            set id [lindex $vals 0]
            set nr [lindex $vals 1]
            set type [lindex $vals 2]
            set relpos [lindex $vals 3]
            set notetext [lindex $vals 5]         
            set context [lindex $vals 6]         

            set pos1 [lindex [$w tag ranges lem$lemma_id] 0]
            set pos2 [lindex [$w tag ranges lem$lemma_id] 1]
            foreach {l1 c1} [split $relpos "."] {}
            foreach {l2 c2} [split $pos1 "."] {}
            set pos "[expr $l1+$l2].[expr $c1+$c2]"
            set pos [$w search $context $pos1 $pos2]
            if {$pos < 0} {
               continue
            }
            
            if {$id == $lemma_id && [$w compare $apos <= $pos] &&
                [$w compare $pos <= $epos]} {
         
            $w ins $pos " " "nz bmk$nxi"
            set nc [expr $nxi +1 ]
            if {$type == 0} {
               $w insert $pos "$nc" "nz bm bmk$nxi"
            } else {
               $w insert $pos "$nc" "nz am bmk$nxi"
            }
            $w tag bind bmk$nxi <Button-1> \
               [eval list "MDI_PopupNotes . $nxi"]
         
            if {[string length $notetext] > 25} {
               set colmsg "[string range $notetext 0 20]..."
            } else {
               if {$notetext != ""} {
                  set colmsg $notetext
               } else {
                  set colmsg "- keine -"
               }
            }
            $w tag bind bmk$nxi <Enter> \
               [eval list "DisplayInstInfo {$colmsg} %W %x %y"]
            $w tag bind bmk$nxi <Leave> \
               "place forget .lfginfo" 
            $w ins $pos " " "nz bmk$nxi"
            }
         }
              
         set msg " \[Abschnitt reduzieren\]"
         $w ins insert $msg "ss srk${lemma_id}@$section"

         $w tag bind srk${lemma_id}@${section} <Button-1> \
            [eval list "ShrinkSection $lemma_id $wordpos $section $apos $epos"]
      
         #label $w.lbl$lemma_id$section -image $wbr(srkarticle) -bd 0
         #$dwb_vars(BHLP) bind $w.lbl$lemma_id$section -msg $wbm(srkarticle)
         #bind $w.lbl$lemma_id$section <1> [eval list "ShrinkSection $lemma_id $wordpos $section $spos $epos"]
         #$w window create insert -window $w.lbl$lemma_id$section -align baseline
         #$w mark unset expe$lemma_id@$section@$wordpos
      }
   }
   set ranges [$w tag ranges lem$lemma_id]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state disabled

   if {$fopen == 1} {
      mk::file close TCLDB
      mk::file close TCLIDX
   }
}

# ---------------------------------------------------------
# shrink expanded article section
# ---------------------------------------------------------

proc ShrinkSection {lemma_id wordpos section spos epos} {
   global dwb_vars wbr wbi wbm

   set wb [string range $lemma_id 0 0]
   set part [string range $lemma_id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal
   set w $dwb_vars(WBTEXT,$wbname,$dpidx)

   set alt [$w tag ranges expsec${lemma_id}@$section]
   set bmtags [$w tag ranges nz]
   foreach {bms bme} $bmtags {
      if {[$w compare $spos+1c <= $bms] &&
          [$w compare $bme <= $epos+23c]} {
         #$w delete $bms $bme
      }     
   }
   set spos [lindex $alt 0]
   set epos [lindex $alt end]

   $w delete $spos+1c $epos+23c
   $w mark set insert $spos+1c
   #puts "$w delete [$w index $spos+1c] [$w index $epos+1c]"

   set expmsg " ...\[weiter\]"
   $w mark set expsec${lemma_id}@$section insert-1c
   $w mark set expwp${lemma_id}@${section}@$wordpos insert-1c
   $w ins insert $expmsg "ee exp${lemma_id}@${section}@$wordpos"
   
   $w tag bind exp${lemma_id}@${section}@$wordpos <Button-1> \
      [eval list "ExpandSection $lemma_id $wordpos $section %W %x %y"]

   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state disabled
}


# ---------------------------------------------------------
# control visible levels in table of contens widget
# ---------------------------------------------------------

proc ReduceLevelDisplay {hlist maxlevel} {

   set topentry [lindex [$hlist info children] 0]
   if {$topentry != ""} {
      set next [$hlist info next $topentry]
      while {$next != ""} {
         set level [llength [split $next "."]]
         if {$level > $maxlevel} {
            $hlist hide entry $next
         }
         set next [$hlist info next $next]
      }
   }
}

# ---------------------------------------------------------
# expand article section from mark m
# ---------------------------------------------------------

proc ExpandParagraph {lemma_id section {fopen 0}} {
   global dwb_vars font

   #puts "ExpandParagraph $lemma_id $section"
   set wb [string range $lemma_id 0 0]
   set part [string range $lemma_id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal

   set w $dwb_vars(WBTEXT,$wbname,$dpidx)

   if {$fopen} {
      mk::file open TCLDB $dwb_vars(driveletter)/Data/$wbname/$part.DAT -readonly
      mk::file open TCLIDX $dwb_vars(driveletter)/Data/$wbname/$part.IDX -readonly
   }
   
   set partID [format "%s%03d" $lemma_id $section]
   set row [performQuery TCLIDX TCLSUBCODE "ID==$partID"]
   if {[lindex $row 0] != ""} {
      set tclcode [inflate [mk::get TCLDB.TCLSUBCODE![lindex $row 0] CODE:B]]
      if {$dwb_vars(MENU,subsign)} {
         set tclcode [SubsSpecialChars $tclcode]
      }
      set tclcode [SubsChars $tclcode]
      $w mark set insert expsec$lemma_id@$section

      $w delete insert insert+13c
      #$w delete [lindex $tr 0]-1c [lindex $tr 1]
      
      set apos [$w index insert]
      if {[catch { eval $tclcode }]} {
         puts "error evaluating tclcode..."
      } else {
         # ok
      }
      #eval $tclcode
      set epos [$w index insert]
     
      $w tag add expsec${lemma_id}@$section $apos $epos

      set msg " \[Abschnitt reduzieren\]"
      $w ins insert $msg "ss srk${lemma_id}@$section"

      $w tag bind srk${lemma_id}@${section} <Button-1> \
         [eval list "ShrinkSection $lemma_id 0 $section $apos $epos"]
   }
   #$dwb_vars(WBTEXT,$wbname,$dpidx) config -state disabled

   if {$fopen} {
      mk::file close TCLDB
      mk::file close TCLIDX
   }
}


# ---------------------------------------------------------
# expand article section from mark m
# ---------------------------------------------------------

proc ExpandSubsection {w lemma_id m} {
   global dwb_vars wbr wbi wbm font

   set wb [string range $lemma_id 0 0]
   set part [string range $lemma_id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal

   set w $dwb_vars(WBTEXT,$wbname,$dpidx)

   set wordpos [string trimleft [lindex [split $m "E"] 0] "0"]
   if {$wordpos == ""} {
      set wordpos 0
   }
   set section [lindex [split $m "E"] 1]

   set partID [format "%s%03d" $lemma_id $section]

   mk::file open TCLDB $dwb_vars(driveletter)/Data/$wbname/$part.DAT -readonly
   mk::file open TCLIDX $dwb_vars(driveletter)/Data/$wbname/$part.IDX -readonly

   set row [performQuery TCLIDX TCLSUBCODE "ID==$partID"]
   if {[lindex $row 0] != ""} {
      set tclcode [inflate [mk::get TCLDB.TCLSUBCODE![lindex $row 0] CODE:B]]
      if {$dwb_vars(MENU,subsign)} {
         set tclcode [SubsSpecialChars $tclcode]
      }
      set tclcode [SubsChars $tclcode]
      $w mark set insert expe$lemma_id@$section@$wordpos
      set spos [$w index insert-8c]
      $w delete insert-8c insert+2c
      if {[catch { eval $tclcode }]} {
         puts "error evaluating tclcode..."
      } else {
         # ok
      }
      #eval $tclcode
      set epos [$w index insert]

      label $w.lbl$lemma_id$section -image $wbr(srkarticle) -bd 0
      $dwb_vars(BHLP) bind $w.lbl$lemma_id$section -msg $wbm(srkarticle)
      bind $w.lbl$lemma_id$section <1> [eval list "ShrinkSection $lemma_id $wordpos $section $spos $epos"]
      $w window create insert -window $w.lbl$lemma_id$section -align baseline
      $w mark unset expe$lemma_id@$section@$wordpos
   }
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state disabled

   mk::file close TCLDB
   mk::file close TCLIDX
}

# ---------------------------------------------------------
# show footnote text
# ---------------------------------------------------------

proc ShowDWBFootnote {id fn fnz} {
   global dwb_vars

   set wb [string range $id 0 0]
   set part [string range $id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set fnw $dwb_vars(FNOTE,$wbname)
   pack $fnw -side bottom -fill both

   set w $dwb_vars(FNTEXT,$wbname,$dpidx)

   set fnID [format "%sF%02d" $id $fn]

   mk::file open TCLDB $dwb_vars(driveletter)/Data/$wbname/$part.DAT -readonly
   mk::file open TCLIDX $dwb_vars(driveletter)/Data/$wbname/$part.IDX -readonly

   set row [performQuery TCLIDX TCLSUBCODE "ID==$fnID"]
   $dwb_vars(FNTEXT,$wbname,$dpidx) config -state normal
   $dwb_vars(FNTEXT,$wbname,$dpidx) delete 1.0 end 
   if {[lindex $row 0] != ""} {
      set tclcode [inflate [mk::get TCLDB.TCLSUBCODE![lindex $row 0] CODE:B]]
      if {$dwb_vars(MENU,subsign)} {
         set tclcode [SubsSpecialChars $tclcode]
      }
      set tclcode [SubsChars $tclcode]
      if {[catch { eval $tclcode }]} {
         puts "error evaluating tclcode..."
      } else {
         # ok
      }
      #eval $tclcode
   }
   $dwb_vars(FNTEXT,$wbname,$dpidx) config -state disabled

   mk::file close TCLDB
   mk::file close TCLIDX
}


# ---------------------------------------------------------
# forget footnote window
# ---------------------------------------------------------

proc CloseFootnoteWindow {fnw} {

   pack forget $fnw
}

# ---------------------------------------------------------
# forget note window
# ---------------------------------------------------------

proc CloseNoteWindow {fnw} {

   pack forget $fnw
}

# ---------------------------------------------------------
# forget sigle window
# ---------------------------------------------------------

proc CloseSigleWindow {w} {

   pack forget $w
}


# ---------------------------------------------------------
# expand all article sections
# ---------------------------------------------------------

proc ExpandAllSections {lemma_id} {
   global dwb_vars font

   place forget $dwb_vars(POPUPMENU,DWB)   
   
   set wb [string range $lemma_id 0 0]
   set part [string range $lemma_id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal

   set w $dwb_vars(WBTEXT,$wbname,$dpidx)
   set alltags [$w tag names]
   
   set nsections 0
   foreach m [$w mark names] {
      if {[string range $m 0 11] == "expwp$lemma_id"} {
         incr nsections
      }
   }
   if {!$nsections} {
      return
   }
   
   set dlg [DisplayInfoPopup .workarea \
      "Abschnitte werden ergänzt..." black $dwb_vars(Special,TABBACK) 1]
   grab set $dlg
      
   set cancel [MkFlatButton $dlg.add cancel "Abbrechen"]
   $cancel config -command "CancelExpansion" -font $font(h,m,r,14) -state normal
   pack $cancel -fill both -expand yes
   update
      
   set dwb_vars(execExpansion) 1
   
   set expsecs ""
   foreach m [$w mark names] {
      if {[string range $m 0 11] == "expwp$lemma_id"} { 
         set section [lindex [split [string range $m 13 end] "@"] 0]
         if {[lsearch $alltags srk${lemma_id}@$section] < 0} {
            lappend expsecs $section
         }
      }
   }
   
   set i 0
   foreach sec [lsort -integer $expsecs] {
      ExpandParagraph $lemma_id $sec 1
        
         #set wpos [lindex [split [string range $m 13 end] "@"] 1]
         #update
         #ExpandSection $lemma_id $wpos $section $w 0 0
         if {!$dwb_vars(execExpansion)} {
            break
         }
         incr i
         set p [format "%.2f" [expr 100.0*$i/$nsections]]
         set dwb_vars(INFOLABEL) "Abschnitte werden ergänzt... ($p%)"
         update
      	
   }
   
   grab release $dlg
   destroy $dlg                                                              
}


proc CancelExpansion {} {
   global dwb_vars
   
   set dwb_vars(execExpansion) 0	
}


proc MDI_RandomChoose {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   set title "Random Reading"
   set n [MDI_CreateChild "$title"]
   MDIchild_CreateWindow $n 0 0 1
   set w [RandomChooseArticle $MDI_cvars($n,client_path) $n]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"

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
   
   return $w
}


proc RandomChooseArticle {top id} {
   global dwb_vars font
 
   set n [mk::view size DBDWB.LEMMA]
   set z [expr int(rand()*$n)]
   
   set zid [mk::get DBDWB.LEMMA!$z ID]
   
   if {![winfo exists $top.randompopup]} {
      set dparea [frame $top.randompopup -borderwidth 1 -relief raised \
         -background $dwb_vars(DWB,TABBACK)]

      label $dparea.text -text "Zufällig ausgewähltes Stichwort" \
         -font $font(h,m,r,14) -anchor c \
         -background $dwb_vars(DWB,TABBACK)
      
      set headerarea [text $dparea.head]
      $headerarea config -height 2 -width 30 -padx 10 -pady 5 \
         -wrap none -background "grey90" -relief flat -bd 0 \
         -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
         -state disabled -cursor top_left_arrow -tabs { 20 30 } \
         -exportselection yes -selectforeground white \
         -selectbackground grey80 -selectborderwidth 0 \
         -insertofftime 0 -insertwidth 0 -font $font(z,m,r,14)
      $headerarea tag configure lemma -font $font(z,m,r,18)
      $headerarea tag configure gram -font $font(z,m,i,14)
      $headerarea tag configure ref -font $font(z,m,i,14)
   
      set f [frame $dparea.control -background $dwb_vars(DWB,TABBACK)]
      set ok [MkFlatButton $f ok "Artikel aufschlagen"]
      $ok config -command "GotoArticle $zid 0" -font $font(h,m,r,12)
      set again [MkFlatButton $f again "Neue Auswahl"]
      $again config -command "RandomChooseArticle $top $id" -font $font(h,m,r,12)
      set cancel [MkFlatButton $f cancel "Schließen"]
      $cancel config -command "MDI_DestroyChild $id" \
         -font $font(h,m,r,12)
      pack $ok $again $cancel -side left
      
      pack $dparea.text -ipadx 1 -ipady 1 -fill x
      pack $headerarea -side top -ipadx 1 -ipady 1 \
         -fill both -expand yes
      pack $dparea.control -side top -ipadx 1 -ipady 1
   } else {
      set dparea $top.randompopup
      set headerarea $dparea.head
      $dparea.control.ok config -command "GotoArticle $zid 0"
   }
        
   set row [performQuery IDXDWB LEMMA "ID==$zid"]
   if {[lindex $row 0] != ""} {
      set position [eval mk::get DBDWB.LEMMA![lindex $row 0] POSITION]
      set lemma [eval mk::get DBDWB.LEMMA![lindex $row 0] NAME]
      set grow [performQuery IDXDWB GRAM "ID==$zid"]
      if {[lindex $grow 0] != ""} {
         set gram "[mk::get DBDWB.GRAM![lindex $grow 0] TYPE]."
         set sep ", "
      } else {
         set gram ""
         set sep ""
      }
      set band [lindex [split $position "."] 0]
      set spalte [string trimleft [lindex [split $position "."] 1] "0"]
      set zeile [lindex [split $position "."] 2]

      $headerarea config -state normal
      $headerarea delete 1.0 end
      $headerarea ins e $lemma lemma
      $headerarea ins e $sep$gram gram
      $headerarea ins e "\n" lemma
      $headerarea ins e "(Band $band, Spalte $spalte, Zeile $zeile)" ref
   }
                
   set x [expr ([winfo reqwidth $top]-[winfo reqwidth $dparea])/2]
   incr x [winfo x $top]
   set y [expr ([winfo reqheight $top]-[winfo reqheight $dparea])/2]
   incr y [winfo y $top]

   pack $dparea -fill both -expand yes
   #place $dparea -x $x -y $y
   update
}


proc CheckPopupMenu {w x y} {
	
   puts "W=$w, X=$x, Y=$y"	
}

# export currently visible article to html file
proc ExportHtml {lemma_id} {
   set tag_html(ln1) {font-family:'Hiragino Mincho Pro','Times New Roman','Times New Roman',Times,serif;font-style:italic;font-size:12pt;font-weigh:bold;text-indent:20pt;margin-left:0;vertical-align:super;}
   set tag_html(ln2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-style:normal;font-size:12pt;font-weigh:bold;text-indent:20pt;vertical-align:super;}
   set tag_html(l1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-style:italic;font-size:18ptpt;font-weigh:normal;text-indent:20pt;}
   set tag_html(l2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:18pt; text-indent:20pt;}
   set tag_html(sl1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(sl2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(g1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(g2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(cit2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(crt2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;}
   set tag_html(cis2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(crs2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;}
   set tag_html(ciau2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;color:blue;}
   set tag_html(crau2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;color:blue;}
   set tag_html(ia1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(ia2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(au1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:12pt;}
   set tag_html(au2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;}
   set tag_html(s1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(s2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(subs1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:12pt;vertical-align:sub;}
   set tag_html(subs2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;vertical-align:sub;}
   set tag_html(sn1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(sn2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(sngr1) {font-family:Greek;font-weight:normal;font-style:italic;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(sngr2) {font-family:Greek;font-weight:normal;font-style:italic;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(snhb1) {font-family:'Sil Ezra';font-weight:normal;font-style:normal;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(snhb2) {font-family:'Sil Ezra';font-weight:normal;font-style:normal;font-size:14pt;text-indent:10pt;margin-left:0;}
   set tag_html(sus1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:12pt;vertical-align:super;}
   set tag_html(sus2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;vertical-align:super;}
   set tag_html(sut1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:12pt;vertical-align:super;}
   set tag_html(sut2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;vertical-align:super;}
   set tag_html(bir1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(bir2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(subir2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;vertical-align:super;}
   set tag_html(br) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(brs) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;vertical-align:super;}
   set tag_html(e1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(e2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(laa) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(la1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(la2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(q1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(q2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(rl) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(rla {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(d1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(d2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(t1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(t2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(b1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(b2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(p1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(p2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(v1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:12pt;}
   set tag_html(v2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;}
   set tag_html(rd) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(da1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(da2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(xr1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(xr2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(fz1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(fz2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(sufz1) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:italic;font-size:12pt;vertical-align:super;}
   set tag_html(sufz2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;vertical-align:super;}
   set tag_html(cibir2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(crbir2) {font-family:'Hiragino Mincho Pro','Times New Roman',Times,serif;font-weight:normal;font-style:normal;font-size:12pt;}
   set tag_html(gr1) {font-family:Greek;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(gr2) {font-family:Greek;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(sgr1) {font-family:Greek;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(sgr2) {font-family:Greek;font-weight:normal;font-style:italic;font-size:14pt;}
   set tag_html(shb1) {font-family:'Sil Ezra';font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(shb2) {font-family:'Sil Ezra';font-weight:normal;font-style:normal;font-size:14pt;}
   set tag_html(cc) {font-family:Arial,Helvetica,Verdana,sans-serif;font-style:normal;font-size:12pt;font-weigh:normal;color:green;}
   set tag_html(ee) {font-family:Arial,Helvetica,Verdana,sans-serif;font-style:normal;font-size:12pt;font-weigh:normal;color:green;}
   set tag_html(ss) {font-family:Arial,Helvetica,Verdana,sans-serif;font-style:normal;font-size:12pt;font-weigh:normal;color:green;}
   set tag_html(lfg) {font-family:Arial,Helvetica,Verdana,sans-serif;font-style:normal;font-size:12pt;font-weigh:normal;color:green;}
   set tag_html(bm) {font-family:Arial,Helvetica,Verdana,sans-serif;font-style:normal;font-size:12pt;font-weigh:bold;color:red;text-decoration:underline;}
   set tag_html(am) {font-family:Arial,Helvetica,Verdana,sans-serif;font-style:normal;font-size:12pt;font-weigh:bold;color:red;text-decoration:underline;background-color:DDDDDD;}

    ExpandAllSections $lemma_id
    
   global dwb_vars font tcl_platform

   #puts "ExpandParagraph $lemma_id $section"
   set wb [string range $lemma_id 0 0]
   set part [string range $lemma_id 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]

   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]
   $dwb_vars(WBTEXT,$wbname,$dpidx) config -state normal

   set w $dwb_vars(WBTEXT,$wbname,$dpidx)
   
   # generate filename
   set table "LEMMA"
   set dir $dwb_vars(htmlexportdir)
   set dir [file join [pwd] $dir]
    set row [performQuery IDX$wbname $table "ID==$lemma_id"]
    if {[lindex $row 0] != ""} {
           set lemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
           set position [mk::get DB$wbname.$table![lindex $row 0] POSITION]
    } else {
        set lemma "unbekannt"
        set position "00"
    }
    regsub -all {\.} $position "_" position
    set file "${lemma}_${position}.html"
    set filename "$dir/$file"

   
   # find ranges to dump
   set lemma_ranges [$w tag ranges lem$lemma_id]
   set lemma_ranges_length [llength $lemma_ranges]
   set tdump {}
   #tk_messageBox -message $lemma_ranges
   for {set i 0} {$i < $lemma_ranges_length} {incr i 2} {
        set start [lindex $lemma_ranges $i ]
        set end   [lindex $lemma_ranges [expr $i + 1] ]
        append tdump " " [$w dump -tag -text $start $end]
   }
   
   # convert DUMP to HTML
   set tdump_length [llength $tdump]
   set html {<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"><html><head><meta HTTP-EQUIV="content-type" CONTENT="text/html; charset=ISO-8859-1"><title>}
   append html "$lemma $position"
   append html {</title></head><body><p>}
   for {set i 0} {$i < $tdump_length} {incr i 3} {
        set type [lindex $tdump $i]
        set content [lindex $tdump [expr $i+1]]
        #tk_messageBox -message "type: $type content: $content"
        switch -exact $type {
            "text" {
                set res ""
                regsub -all {&} $content {\&amp;} content
                regsub -all {"} $content {\&quot;} content
                regsub -all {<} $content {\&lt;} content
                regsub -all {>} $content {\&gt;} content                                                
                regsub -all {\n} $content {<br>} content
                regsub -all {  } $content {\&nbsp;\&nbsp;} content                                
                foreach j [split $content ""] {
                    scan $j %c c
                    if {$c<128} {append res $j} else {append res "&#x[format %4.4X $c];"}
                }
                append html $res
            }
            "tagon" {
                if {[info exists tag_html($content)]} {
                    append html "<span style=\"$tag_html($content)\" >"   
                 } else {
                 }
            }
            "tagoff" {
                if {[info exists tag_html($content)]} {
                    append html "</span>"
                }
            }
            "default" {
            }
        }
   }
   append html "</p></body> </html>"
   
   
   
   if {[catch {set fid [open $filename w+ ]}] == 0} {
       
       puts $fid $html
       #puts $fid $tdump
       close $fid
       
       if { $dwb_vars(MENU,confexp) != 0 } {
        set confirmmsg "Das Stichwort \"$lemma\" wurde erfolgreich exportiert.\n\nExportverzeichnis: \"$dir\"\n\nDateiname: \"$file\"\n"
        if {[string tolower $tcl_platform(os)] == "darwin"} {
            append confirmmsg "\n\nBitte beachten Sie, daß dieser Dialog die englischen Verzeichnisnamen anzeigt. z.B. \"Applications\" statt \"Programme\""
        }
        tk_messageBox -icon info -message $confirmmsg 
       }
   } else {
        tk_messageBox -icon error -title {Fehler} -message "Keine Schreibberechtigung!\nBitte wählen Sie ein anderes HTML Exportverzeichnis."
   }
}


# select the directory where html files are saved
proc SelectExportDir {} {
 global dwb_vars tcl_platform
 set start 1
 set exportdir {}
 while { ($start == "1") || ([file writable $exportdir] == 0 && $exportdir != {}) } {
     if {$start != 1} {
         tk_messageBox -icon error -message "Keine Schreibberechtigung!\nBitte wählen Sie ein anderes HTML Exportverzeichnis."
     }
    if {[string tolower $tcl_platform(os)] == "darwin"} {
        tk_messageBox -message "Bitte beachten Sie, daß dieser Dialog die englischen Verzeichnisnamen anzeigt. z.B. \"Applications\" statt \"Programme\""
    }
     set exportdir [tk_chooseDirectory -initialdir $dwb_vars(htmlexportdir) -mustexist 1 -title {Exportverzeichnis}]
     set start 0
 }
 if {$exportdir != {}} {
    set dwb_vars(htmlexportdir) $exportdir
 }
}