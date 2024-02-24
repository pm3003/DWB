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

proc OpenPreface {top mode} {
   global dwb_vars

   if {$mode == "wb"} {
      set tw [$top.tableofcons.content subwidget text]
      set vwt [$top.preface.prefacetext.text subwidget text]
      $tw config -state normal
      $tw delete 1.0 end
      ShowTableofContents $tw    
      ShowVWTitle $vwt
      $tw config -state disabled
   } else {
      set w [$top.preface.prefacetext.text subwidget text]
      set filename "$dwb_vars(PREFDIR)/vor33.tcl"
      set fp [open $filename r]
      set text [read $fp]
      close $fp
      $w config -state normal
      $w delete 1.0 end
      eval $text
      $w config -state disabled
      set dwb_vars(WBAREA,QVZ,ACTIVETAB) preface
   }
}


#-----------------------------------------------------------
# shows preface title
#-----------------------------------------------------------

proc ShowVWTitle {w} {
   global dwb_vars font

   $w tag configure header0 -font $font(z,m,r,30) -justify center
   $w tag configure header1 -font $font(z,m,r,24) -justify center
   $w tag configure header2 -font $font(z,m,r,18) -justify center
   $w tag configure header3 -font $font(z,m,r,14) -justify center
   $w tag configure header4 -font $font(z,m,r,12) -justify center

   $w config -state normal
   $w delete 1.0 end


   set wdth [winfo reqwidth $w]
   $w config -tabs [eval "list $wdth center"]

   set writing [tix getimage dwb5]
   label $w.lbl -image $writing -background grey97

   $w insert end "\n\n\n\t" { header3 }
   $w window create end -window $w.lbl -align center

   #$w insert end "\n\n\nD" { header0 }
   #$w insert end "EUTSCHES " { header0 }
   #$w insert end "W" { header0 }
   #$w insert end "ÖRTERBUCH" { header0 }
   #$w insert end "\n\nVON\n\n" { header2 }
   #$w insert end "J" { header1 }
   #$w insert end "ACOB UND " { header2 }
   #$w insert end "W" { header1 }
   #$w insert end "ILHELM " { header2 }
   #$w insert end "G" { header1 }
   #$w insert end "RIMM\n" { header2 }
   $w insert end "\n\n\n\nVorworte\n" { header1 }
   $w config -state disabled
}


# ---------------------------------------------------------
# create preface display area
# ---------------------------------------------------------


proc MkPrefaceArea {top wbname mode} {
   global dwb_vars font
   global prefarea tableofcons preface contentarea contentw
   global prefacetext footnotes textarea textw 
   global footnotehead footnotetext footnotehead_cancel
   global footnotehead_title footnotearea footnotew

   if {[winfo exists $top.prefarea] == 0} {
      set prefarea [frame $top.prefarea -background grey -borderwidth 1 \
         -relief flat]
      
      set tableofcons [frame $prefarea.tableofcons]
      set preface [frame $prefarea.preface]
   
      set contentarea [tixScrolledText $tableofcons.content]
      set contentw [$contentarea subwidget text]
     
      set prefacetext [frame $preface.prefacetext]
      set footnotes [frame $prefacetext.footnotes]
      if {$wbname == "QVZ"} {
         set dwb_vars($wbname,footnotes) $footnotes
      } else {
         set dwb_vars(footnotes) $footnotes
      } 
      set textarea [tixScrolledText $prefacetext.text -scrollbar y]
      set textw [$textarea subwidget text]
   
      set footnotehead [frame $footnotes.footnotehead \
         -relief raised -bd 1 -bg $dwb_vars($wbname,TABBACK) -bd 1]
      set footnotetext [frame $footnotes.footnotetext]
	
      if {$wbname == "QVZ"} {
         set footnotehead_cancel [label $footnotehead.footnotehead_cancel \
           -image [tix getimage smalldown3] -bg $dwb_vars($wbname,TABBACK)]
      } else {
         set footnotehead_cancel [label $footnotehead.footnotehead_cancel \
           -image [tix getimage smalldown2] -bg $dwb_vars($wbname,TABBACK)]
      }
      $dwb_vars(BHLP) bind $footnotehead_cancel -msg \
        "Fußnotenfenster ausblenden"
	
      set footnotehead_title [label $footnotehead.footnotehead_title \
	-text "Fußnoten" -font $font(h,m,r,14) -bg $dwb_vars($wbname,TABBACK)]
	
      set footnotearea [tixScrolledText $footnotetext.fn -scrollbar y] 
      set footnotew [$footnotearea subwidget text]
      if {$wbname == "QVZ"} {
         set dwb_vars($wbname,footnotew) $footnotew
      } else {
         set dwb_vars(footnotew) $footnotew
      } 
   }

   $contentw config -height 24 -width 30 -padx 10 -pady 5 \
      -wrap none -background grey97 -relief ridge -bd 1 \
      -font $font(z,m,r,14) -cursor top_left_arrow
      
   $textw config -width 60 -padx 10 -pady 5 \
      -wrap word -background grey97 -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -cursor top_left_arrow -tabs { 40 80 120 160 200 } \
      -exportselection yes -selectforeground white \
      -selectbackground grey97 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0 -font $font(z,m,r,14) \
      -cursor top_left_arrow  
   
   $footnotew config -height 5 -width 60 -padx 10 -pady 5 \
      -wrap word -background grey97 -relief ridge -bd 0 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -font $font(z,m,r,14) -cursor top_left_arrow
      
   $footnotew tag configure i -font $font(z,m,i,14)
   
   set dwb_vars(CURRABS) ""    
   set dwb_vars(CURRVOR) ""  
   set dwb_vars(CURRFILE) ""
   
   bind $contentw <Motion> [eval "list TraceTableofContents $top $contentw %x %y"]
   bind $contentw <ButtonPress-1> [eval "list ShowPreface $top $contentw %x %y $textw"]
      
   $textw tag configure text -font $font(z,m,r,14)
   $textw tag configure h1 -font $font(z,m,r,18) -justify center
   $textw tag configure pagenr -font $font(z,m,r,12) -justify center
   $textw tag configure ai -font $font(z,m,r,14)
   $textw tag configure ar -font $font(z,m,r,12)
   $textw tag configure greek -font $font(g,m,i,14)
   $textw tag configure v -font $font(z,m,r,12)
   $textw tag configure s -font $font(z,m,r,12)
   $textw tag configure rtext -font $font(z,m,r,14) -justify right
   $textw tag configure au -font $font(z,m,r,14) -justify center
   $textw tag configure stext -font $font(z,m,r,12)
   $textw tag configure i -font $font(z,m,i,14)
   $textw tag configure ib -font $font(z,b,i,14)
   $textw tag configure gr -font $font(g,m,i,14)
   $textw tag configure fr -font $font(f,m,r,14)
   $textw tag configure sup -font $font(z,m,r,10) -offset 4p
   # ab hier tags der "Hinweise zur Benutzung"
   $textw tag configure h1 -font $font(z,b,r,18)
   $textw tag configure ti -font $font(z,m,i,14)
   $textw tag configure pnr -font $font(z,m,r,12) -justify right -foreground grey 
  
   $contentw tag configure level1 -font $font(z,b,r,14)
   $contentw tag configure level2 -font $font(z,m,r,12) -lmargin1 15  
   
   $footnotew tag configure ai -font $font(z,m,r,14)
   $footnotew tag configure ar -font $font(z,m,r,12)    
   if {$mode == "wb"} {
      pack $contentarea -side left -fill both -expand yes
   }
   
   pack $textarea -fill both -expand yes
   pack $prefacetext -side top -fill both -expand yes
      
   pack $footnotehead_cancel $footnotehead_title -side left  
   pack $footnotehead -fill x
   pack $footnotetext -fill x
     
   pack $footnotearea -side left -fill both -expand yes
   
   if {$mode == "wb"} {
      pack $tableofcons -side left -fill both -expand yes
   }
   pack $preface -side left -fill both -expand yes 
   #bind $textw <ButtonPress-1> [eval "list ShowFootnote $top $textw %x %y $footnotes $footnotew"]
   bind $footnotehead_cancel <ButtonPress-1> [eval "list CloseFootnoteWindow $footnotes"]
   
   return $prefarea
}


#--------------------------------------------------------------------
# trace label in table of contents
#--------------------------------------------------------------------


proc TraceTableofContents {top contentw xp yp} {
   global dwb_vars

   set tagnames [$contentw tag names @$xp,$yp]
   foreach tag $tagnames {
      set aTag [string range $tag 0 4]
      set prefTag [string range $tag 0 2]
   
      if {$prefTag == "vor" && $aTag != "vor01"} {
      	 if {$dwb_vars(CURRABS) != ""} {
      	    $contentw tag configure $dwb_vars(CURRABS) \
      	       -background grey97 -relief flat
      	 }
      	
      	 if {$tag != $dwb_vars(CURRVOR)} {
      	    if {$dwb_vars(CURRVOR) != ""} {
      	       $contentw tag configure $dwb_vars(CURRVOR) \
      	          -background grey97 -relief flat
      	    }
      	          	   
      	    set dwb_vars(CURRVOR) $tag
      	    $contentw tag configure $dwb_vars(CURRVOR) \
               -background grey80 -bgstipple gray50 \
               -borderwidth 0 -relief flat
      	    
      	    return
      	 }
    	 if {$tag == $dwb_vars(CURRVOR)} {
      	     return
      	 }
      } else {
      	 if {$prefTag == "abs"} {
  	    if {$dwb_vars(CURRVOR) != ""} {
      	       $contentw tag configure $dwb_vars(CURRVOR) \
      	          -background grey97 -relief flat
      	    }
      	    if {$tag != $dwb_vars(CURRABS)} {
      	       if {$dwb_vars(CURRABS) != ""} {
      	       	  $contentw tag configure $dwb_vars(CURRABS) \
      	      	     -background grey97 -relief flat
      	       }
      	       set dwb_vars(CURRABS) $tag
      	       $contentw tag configure $dwb_vars(CURRABS) \
                  -background grey80 -bgstipple gray50 \
                  -borderwidth 0 -relief flat
      	      # set dwb_vars(CURRABS) $tag
      	       return
      	       }
    	       if {$tag == $dwb_vars(CURRABS)} {
      	          return
      	       }
           }
       }
   }
}


#----------------------------------------------------------------------
# show prefaces
#----------------------------------------------------------------------


proc ShowPreface {top contentw xp yp w} {
   global dwb_vars
   
   $w config -state normal
   if {$dwb_vars(CURRFILE) == "$dwb_vars(PREFDIR)/vor11.tcl"} {
      CloseFootnoteWindow $dwb_vars(footnotes)
   }
   if {$dwb_vars(CURRFILE) == "$dwb_vars(PREFDIR)/vor33.tcl"} {
      CloseFootnoteWindow $dwb_vars(QVZ,footnotes)
   }
        
   set tagnames [$contentw tag names @$xp,$yp]
   foreach tag $tagnames {
      set aTag [string range $tag 0 2]
      set prefTag [string range $tag 0 4]

      if {$prefTag != "level"} {
         if {$aTag == "vor"} {
           set filename "$dwb_vars(PREFDIR)/$prefTag.tcl"
           set dwb_vars(CURRFILE) $filename
           set fp [open $filename r]
      	   set text [read $fp]
      	   close $fp
      	   $w delete 1.0 end
      	   eval $text
         }
         if {$aTag == "abs"} {
            set dwb_vars(CURRABS) $tag
            $w yview $tag
         }
      }
   }
   $w config -state disabled
}


#---------------------------------------------------------------------
# show footnotes
#---------------------------------------------------------------------

proc ShowFootnote {top textw fn vn footnotes w} {
   global dwb_vars

   $w config -state normal
   pack $footnotes -side bottom -fill both
   
   set filename "$dwb_vars(PREFDIR)/$vn$fn.tcl"

   set fp [open $filename r]
   set fntext [read $fp]
   close $fp
   $w delete 1.0 end
   eval $fntext
   $w config -state disabled
}


#-------------------------------------------------------------------
# forget footnote window
#-------------------------------------------------------------------


proc CloseFootnoteWindow {footnotes} {
   pack forget $footnotes
}


#------------------------------------------------------------------
# create dwb-abbreviation display area
#------------------------------------------------------------------

proc MkDWBAbbr {top n} {
   global font dwb_vars
   global dwbabbr wbabbrhead wbabbrtext wbabbrcancel wbabbrarea wbabbrw
   
   if {[winfo exists $top.dwbabbr] == 0} {
      set dwbabbr [frame $top.dwbabbr -relief raised -bd 1]

      set wbabbrhead [frame $dwbabbr.abbrhead]
      set wbabbrtext [frame $dwbabbr.abbrtext]
      set wbabbrcancel [frame $dwbabbr.abbrcancel -background $dwb_vars(DWB,TABBACK)]

      set wbabbrarea [tixScrolledText $dwbabbr.abbr -scrollbar y]
      set wbabbrw [$wbabbrarea subwidget text]
      
      label $wbabbrhead.head -text "Abkürzungen im Bearbeitertext des DWB" \
         -bd 1 -relief flat -anchor c -background $dwb_vars(DWB,TABBACK) \
         -font $font(h,m,r,14)
      
      button $wbabbrcancel.cancel -text "Schließen" \
         -font $font(h,m,r,14) -command "CloseDWBAbbrWindow $n"

      ShowDWBAbbr $wbabbrw      
   }
   
   $wbabbrw config -wrap word -width 45 -height 15 \
      -cursor top_left_arrow -tabs { 40 80 120 160 200 } \
      -font $font(z,m,r,14) -padx 10 -pady 5 \
      -wrap word -background "grey97" -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -state disabled
   $wbabbrw tag configure pnr -font $font(z,m,r,14) \
      -justify right -foreground grey 
   
   pack $wbabbrhead $wbabbrtext -fill both
   pack $wbabbrhead.head -fill both
   pack $wbabbrarea -fill both -expand yes
   pack $wbabbrcancel -fill both
   pack $wbabbrcancel.cancel

   set xpos [winfo rootx $dwb_vars(wbtextw)]
   set ypos [winfo rooty $dwb_vars(wbtextw)]
   set width [winfo width $dwb_vars(wbtextw)]
   set newx [expr ($xpos + $width)]
   pack $dwbabbr -fill both -expand yes
   update
}


#-------------------------------------------------------------------
# forget dwb abbreviations window
#-------------------------------------------------------------------

proc CloseDWBAbbrWindow {n} {
   global dwb_vars
   
   MDI_DestroyChild $n
   set dwb_vars(OPENDWBABBR) -1
}


#------------------------------------------------------------------
# create qvz help and abbreviation display area
#------------------------------------------------------------------

proc MkQVZHelp {top n} {
   global font dwb_vars
   
   set qvzhlplabel "Hinweise zur Benutzung des Quellenverzeichnisses"
   
   if {[winfo exists $top.qvzhlp] == 0} {
      set qvzhlp [frame $top.qvzhlp -relief raised -bd 1]

      set qvzhlphead [frame $qvzhlp.hlphead]
      set qvzhlptext [frame $qvzhlp.hlptext]
      set qvzhlpcancel [frame $qvzhlp.hlpcancel -background $dwb_vars(QVZ,TABBACK)]

      set qvzhlparea [tixScrolledText $qvzhlp.hlp -scrollbar y]
      set qvzhlpw [$qvzhlparea subwidget text]
            
      label $qvzhlphead.head -text "" \
         -bd 1 -relief flat -anchor c -background $dwb_vars(QVZ,TABBACK) \
         -font $font(h,m,r,14) -text $qvzhlplabel
      
      button $qvzhlpcancel.cancel -text "Schließen" \
         -font $font(h,m,r,14) -command "CloseQVZHelpWindow $n"      
   }
   
   ShowUserinfos $qvzhlpw
  
   $qvzhlpw config -wrap word -width 45 -height 15 \
      -cursor top_left_arrow -tabs { 40 80 120 160 200 } \
      -font $font(z,m,r,14) -padx 10 -pady 5 \
      -background "grey97" -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -state disabled
   $qvzhlpw tag configure pnr -font $font(z,m,r,14) \
      -justify right -foreground grey 
   $qvzhlpw tag configure ai -font $font(z,m,r,14)
   $qvzhlpw tag configure ar -font $font(z,m,r,12)
   $qvzhlpw tag configure ti -font $font(z,m,i,14)
   
   pack $qvzhlphead.head -fill both
   pack $qvzhlphead $qvzhlptext -fill both
   pack $qvzhlparea -fill both -expand yes
   pack $qvzhlpcancel.cancel
   pack $qvzhlpcancel -fill both

   pack $qvzhlp -fill both -expand yes
   update
   
   return $qvzhlp
}

#------------------------------------------------------------------
# create qvz help and abbreviation display area
#------------------------------------------------------------------

proc MkQVZAbbr {top n} {
   global font dwb_vars
   
   set qvzhlplabel "Abkürzungen im Quellenverzeichnis"
   
   if {[winfo exists $top.qvzabbr] == 0} {
      set qvzhlp [frame $top.qvzabbr -relief raised -bd 1]

      set qvzhlphead [frame $qvzhlp.hlphead]
      set qvzhlptext [frame $qvzhlp.hlptext]
      set qvzhlpcancel [frame $qvzhlp.hlpcancel -background $dwb_vars(QVZ,TABBACK)]

      set qvzhlparea [tixScrolledText $qvzhlp.hlp -scrollbar y]
      set qvzhlpw [$qvzhlparea subwidget text]
            
      label $qvzhlphead.head -text "" \
         -bd 1 -relief flat -anchor c -background $dwb_vars(QVZ,TABBACK) \
         -font $font(h,m,r,14) -text $qvzhlplabel
      
      button $qvzhlpcancel.cancel -text "Schließen" \
         -font $font(h,m,r,14) -command "MDI_DestroyChild $n; set dwb_vars(OPENQVZABBR) -1"
   }
   
   ShowAbbrQVZ $qvzhlpw
  
   $qvzhlpw config -wrap word -width 45 -height 15 \
      -cursor top_left_arrow -tabs { 40 80 120 160 200 } \
      -font $font(z,m,r,14) -padx 10 -pady 5 \
      -background "grey97" -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -state disabled
   $qvzhlpw tag configure pnr -font $font(z,m,r,14) \
      -justify right -foreground grey 
   $qvzhlpw tag configure ai -font $font(z,m,r,14)
   $qvzhlpw tag configure ar -font $font(z,m,r,12)
   $qvzhlpw tag configure ti -font $font(z,m,i,14)
   
   pack $qvzhlphead $qvzhlptext -fill both
   pack $qvzhlphead.head -fill both
   pack $qvzhlparea -fill both
   pack $qvzhlpcancel -fill both
   pack $qvzhlpcancel.cancel

   pack $qvzhlp -expand yes -fill both
   update
   
   return $qvzhlp
}


#-------------------------------------------------------------
# forget qvz help window
#-------------------------------------------------------------

proc CloseQVZHelpWindow {n} {
   global dwb_vars
   
   MDIchild_Delete $n
   set dwb_vars(OPENQVZINFO) -1
}


proc ShowTableofContents {w} {
$w insert end "Vorwort zu Band 1 (= I)\n" {vor01 abs1 level1}
$w insert end "  1. Wörterbuch ist die alphabetische verzeichnung der ...\n" {abs2 vor01 level2}
$w insert end "  2. Was ist eines wörterbuchs zweck?\n" {abs3 vor01 level2}
$w insert end "  3. Bisher sind begrif und bedeutung eines wörterbuchs ...\n" {abs4 vor01 level2}
$w insert end "  4. Wir haben gesehen, welche einschränkung dem raume nach ...\n" {abs5 vor01 level2}
$w insert end "  5. Welche vorgänger haben wir und was ist von ihnen schon geleistet worden?\n" {abs6 vor01 level2}
$w insert end "  6. Fremde wörter\n" {abs7 vor01 level2}
$w insert end "  7. Eigennamen\n" {abs8 vor01 level2}
$w insert end "  8. Sprache der hirten, jäger, vogelsteller, fischer\n" {abs9 vor01 level2}
$w insert end "  9. Anstöszige wörter\n" {abs10 vor01 level2}
$w insert end "10. Umfang der quellen\n" {abs11 vor01 level2}
$w insert end "11. Belege\n" {abs12 vor01 level2}
$w insert end "12. Terminologie\n" {abs13 vor01 level2}
$w insert end "13. Definitionen\n" {abs14 vor01 level2}
$w insert end "14. Bildungstriebe\n" {abs15 vor01 level2}
$w insert end "15. Partikeln\n" {abs16 vor01 level2}
$w insert end "16. Worterklärung\n" {abs17 vor01 level2}
$w insert end "17. Wortforschung\n" {abs18 vor01 level2}
$w insert end "18. Sitten und bräuche\n" {abs19 vor01 level2}
$w insert end "19. Schreibung und druck\n" {abs20 vor01 level2}
$w insert end "20. Rechtschreibung\n" {abs21 vor01 level2}
$w insert end "21. Betonung\n" {abs22 vor01 level2}
$w insert end "22. Vertheilung\n" {abs23 vor01 level2}
$w insert end "23. Beistand\n" {abs24 vor01 level2}
$w insert end "24. Schlusz\n" {abs25 vor01 level2}
$w insert end "Vorwort zu Band 2 (= II)\n" {vor02 level1}
$w insert end "Vorwort zu Band 5 (= IV,I,2)\n" {vor05 level1}
$w insert end "Vorwort zu Band 7 (= IV,I,4)\n" {vor07 level1}
$w insert end "Vorwort zu Band 8 (= IV,I,5)\n" {vor08 level1}
$w insert end "Vorwort zu Band 9 (= IV,I,6)\n" {vor09 level1}
$w insert end "Vorwort zu Band 10 (= IV,II)\n" {vor10 level1}
$w insert end "Vorwort zu Band 11 (= V)\n" {vor11 level1}
$w insert end "Vorwort zu Band 13 (= VII)\n" {vor13 level1}
$w insert end "Vorwort zu Band 14 (= VIII)\n" {vor14 level1}
$w insert end "Vorwort zu Band 15 (= IX)\n" {vor15 level1}
$w insert end "Vorwort zu Band 18 (= X,II,2)\n" {vor18 level1}
$w insert end "Vorwort zu Band 19 (= X,III)\n" {vor19 level1}
$w insert end "Vorwort zu Band 20 (= X,IV)\n" {vor20 level1}
$w insert end "Vorwort zu Band 21 (= XI,I,1)\n" {vor21 level1}
$w insert end "Vorwort zu Band 22 (= XI,I,2)\n" {vor22 level1}
$w insert end "Vorwort zu Band 23 (= XI,II)\n" {vor23 level1}
$w insert end "Vorwort zu Band 24 (= XI,III)\n" {vor24 level1}
$w insert end "Vorwort zu Band 25 (= XII,I)\n" {vor25 level1}
$w insert end "Vorwort zu Band 26 (= XII,II)\n" {vor26 level1}
$w insert end "Vorwort zu Band 27 (= XIII)\n" {vor27 level1}
$w insert end "Vorwort zu Band 28 (= XIV,I,1)\n" {vor28 level1}
$w insert end "Vorwort zu Band 29 (= XIV,I,2)\n" {vor29 level1}
$w insert end "Vorwort zu Band 30 (= XIV,II)\n" {vor30 level1}
$w insert end "Vorwort zu Band 31 (= XV)\n" {vor31 level1}
$w insert end "Vorwort zu Band 32 (= XVI)\n" {vor32 level1}
}


# ---------------------------------------------------------
# pack intro window into MDI child window
# ---------------------------------------------------------

proc MDI_DWBAbbrPopup {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENDWBABBR) >= 0} {
      return
   }
   
   set title "Abkürzungen"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,close_cmd) "CloseDWBAbbrWindow $n"
   MDIchild_CreateWindow $n 0 0 1
   set w [MkDWBAbbr $MDI_cvars($n,client_path) $n]

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
   
   set dwb_vars(OPENDWBABBR) $n
   
   return $w
}


# ---------------------------------------------------------
# pack intro window into MDI child window
# ---------------------------------------------------------

proc MDI_QVZHelpPopup {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENQVZINFO) >= 0} {
      return
   }
   
   set title "Hinweise"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,close_cmd) "CloseQVZHelpWindow $n"
   MDIchild_CreateWindow $n 0 0 1
   set w [MkQVZHelp $MDI_cvars($n,client_path) $n]

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
   
   set dwb_vars(OPENQVZINFO) $n
   
   return $w
}


# ---------------------------------------------------------
# pack intro window into MDI child window
# ---------------------------------------------------------

proc MDI_QVZAbbrPopup {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENQVZABBR) >= 0} {
      return
   }
   set title "Abkürzungen"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,close_cmd) "MDIchild_Delete $n; set dwb_vars(OPENQVZABBR) -1"
   MDIchild_CreateWindow $n 0 0 1
   set w [MkQVZAbbr $MDI_cvars($n,client_path) $n]

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
   
   set dwb_vars(OPENQVZABBR) $n
   
   return $w
}


proc MDI_CopyrightPopup {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENCOPYRIGHT) >= 0} {
      return
   }
   set title "Der Digitale Grimm"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"
   set MDI_cvars($n,close_cmd) "MDIchild_Delete $n; set dwb_vars(OPENCOPYRIGHT) -1"
   MDIchild_CreateWindow $n 0 0 1
   set w [MkCopyright $MDI_cvars($n,client_path) $n]

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
   
   set dwb_vars(OPENCOPYRIGHT) $n
   
   return $w
}


proc MkCopyright {top n} {
   global font dwb_vars
   
   if {[winfo exists $top.copyright] == 0} {
      set copyright [frame $top.copyright -relief raised -bd 1]

      set crtext [frame $copyright.text]
      set crcancel [frame $copyright.cancel -background $dwb_vars(DWB,TABBACK)]

      set crarea [tixScrolledText $crtext.text -scrollbar y]
      set w [$crarea subwidget text]
            
      button $crcancel.cancel -text "Schließen" \
         -font $font(h,m,r,14) -command "CloseCopyrightWindow $n"      
   }
    
   $w config -wrap word -width 60 -height 15 \
      -cursor top_left_arrow -tabs { 40 80 120 160 200 } \
      -font $font(h,m,r,14) -padx 10 -pady 5 \
      -background "grey97" -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -state disabled
      
   $w tag configure sup -offset 3p -font $font(h,m,r,14)
   $w tag configure bold -font $font(h,b,r,14)
   
   pack $crtext -fill both
   pack $crarea -fill both -expand yes
   pack $crcancel.cancel
   pack $crcancel -fill both

   pack $copyright -fill both -expand yes
   update
   
   $w config -state normal
   $w insert end "Der Digitale Grimm"
   $w insert end "®" sup
   $w insert end " Version $dwb_vars(VersionNumber)\n\n"
   $w insert end "Alle Rechte vorbehalten. Copyright © 2004 by Zweitausendeins, Postfach D-60381 Frankfurt am Main\n"
   $w insert end "www.Zweitausendeins.de\n\n"
   $w insert end "Nutzungsrechte." bold
   $w insert end " Mit dem Kauf des Digitalen Grimm wird das Recht erworben,"
   $w insert end " die gelieferte Software auf einem beliebigen Rechner zu nutzen,"
   $w insert end " der für diese Zwecke geeignet ist. Der Kunde erwirbt das"
   $w insert end " nicht ausschließliche und nicht übertragbare Recht nur an der"
   $w insert end " im beigefügten Handbuch beschriebenen Nutzung. Alle darüber"
   $w insert end " hinausgehenden Nutzungsrechte bleiben bei den Inhabern der"
   $w insert end " Schutz- und Urheberrechte.\n\n"
   
   $w insert end "Haftung." bold
   $w insert end " Für durch den Einsatz der gelieferten Software an"
   $w insert end " anderer Software und Datenträgern sowie der"
   $w insert end " Datenverarbeitungsanlage des Kunden entstandene Schäden wird"
   $w insert end " nur gehaftet, wenn schadensursächliche Mängel von einem"
   $w insert end " gesetzlichen Vertreter oder Erfüllungsgehilfen von"
   $w insert end " Zweitausendeins vorsätzlich oder grob fahrlässig verursacht"
   $w insert end " worden sind. - Die Programme sind nach dem Stand der Technik"
   $w insert end " sorgfältig entwickelt worden. Da Fehler sich jedoch nie"
   $w insert end " gänzlich vermeiden lassen, kann für das fehlerfreie Arbeiten"
   $w insert end " sowie die Einsetzbarkeit auf unterschiedlichen Rechnertypen,"
   $w insert end " Gerätekonfigurationen und Plattformen keine Gewähr übernommen werden."
   $w insert end "\n\n\n\n\n"
   $w config -state disabled
   
   return $copyright
}


proc CloseCopyrightWindow {n} {
   global dwb_vars
   
   MDI_DestroyChild $n
   set dwb_vars(OPENCOPYRIGHT) -1
}

