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
# Tcl-Script for table of contents window
# ---------------------------------------------------------


# ---------------------------------------------------------
# create dynamic table of contents area
# ---------------------------------------------------------

proc MkTOCArea {top} {
   global dwb_vars font

   set tocarea [frame $top.tocarea -background grey -borderwidth 1 \
      -relief sunken]

   set dwb_vars(TOC,active_tab) "tocbook.hierarchy"
   set tocbook [tabset $tocarea.book -side top -relief flat \
      -bd 1 -tiers 3 -tabborderwidth 0 -gap 1 -selectpad 1 \
      -outerpad 0 -highlightthickness 0 -dashes 0 -tearoff 0 \
      -cursor top_left_arrow -samewidth no -activeforeground black \
      -foreground black -selectforeground black]
   set dwb_vars(tocbook) $tocbook

   set w [frame $tocbook.hierarchy]
   $tocbook insert end hierarchy -text "Artikelgliederung" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both -command \
      {SetTOCActiveTab toc.hierarchy}

   set w [frame $tocbook.query]
   $tocbook insert end query -text "Suchen im Wörterbuch" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both -command \
      {SetTOCActiveTab tocbook.query}

   set w [frame $tocbook.bookmark]
   $tocbook insert end bookmark -text "Anmerkungen" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both -command \
      {SetTOCActiveTab tocbook.bookmark}

   set w [frame $tocbook.siglen]
   $tocbook insert end siglen -text "Quellenverzeichnis" \
      -background $dwb_vars(QVZ,TABBACK) \
      -selectbackground $dwb_vars(QVZ,TABSELBACK) \
      -activebackground $dwb_vars(QVZ,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both -command \
      {SetTOCActiveTab tocbook.bookmark}

   set w [frame $tocbook.siglenquery]
   $tocbook insert end siglenquery -text "Suchen im Quellenverzeichnis" \
      -background $dwb_vars(QVZ,TABBACK) \
      -selectbackground $dwb_vars(QVZ,TABSELBACK) \
      -activebackground $dwb_vars(QVZ,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both -command \
      {SetTOCActiveTab tocbook.bookmark}

   set w [frame $tocbook.index]
   $tocbook insert end index -text "Rückläufiger Index" \
      -background $dwb_vars(DWB,TABBACK) \
      -selectbackground $dwb_vars(DWB,TABSELBACK) \
      -activebackground $dwb_vars(DWB,TABACTBACK) \
      -font $font(h,m,r,14) -window $w -fill both -command \
      {SetTOCActiveTab tocbook.bookmark}

   pack $tocarea -expand yes -fill both

   MkHierarchyArea $tocbook.hierarchy
   MkQueryArea $tocbook.query 0
   MkNotesBookMarksDisplay $tocbook.bookmark 0
   MkQVZDisplayArea $tocbook.siglen QVZ
   MkRIDisplayArea $tocbook.index RI
   MkQVZQueryArea $tocbook.siglenquery QVZ
         
   pack $tocbook -side top -expand yes -fill both

   update

   return $tocarea
}

# ---------------------------------------------------------
# create hierarchy area
# ---------------------------------------------------------

proc MkHierarchyArea {top} {
   global dwb_vars font
   
   set hierarchyarea [tixScrolledText $top.hierarchy -scrollbar both]
   set textw [$hierarchyarea subwidget text]
   # used to be -selectforeground white
   # -selectbackground grey80
   $textw config -height 22 -width 44 -padx 10 -pady 5 \
      -wrap none -background "grey97" -relief ridge -bd 1 \
      -spacing1 2 -spacing2 2 -spacing3 2 -highlightthickness 0 \
      -state disabled -cursor top_left_arrow -tabs { 20 40 60 80 100 120 140 160 180 } \
      -exportselection yes -selectforeground black \
      -selectbackground grey97 -selectborderwidth 0 \
      -insertofftime 0 -insertwidth 0
      
   bind $textw <Motion> [eval "list TraceHierarchy $top $textw %x %y"]
   bind $textw <B1-Motion> {}
   bind $textw <ButtonPress-1> [eval "list ReferenceHierarchy $top $textw %x %y"]

   $textw tag configure tc1 -font $font(z,m,i,14)
   $textw tag configure tc2 -font $font(z,m,r,14)
   $textw tag configure l2 -font $font(z,m,r,18)
   $textw tag configure g1 -font $font(z,m,i,14)
   $textw tag configure crtc2 -font $font(z,m,r,12) -foreground blue
   $textw tag configure citc2 -font $font(z,m,r,14) -foreground blue
   $textw tag configure sutc1 -font $font(z,m,i,12) -offset 4p
   $textw tag configure sutc2 -font $font(z,m,r,12) -offset 4p
   $textw tag configure sn1 -font $font(z,m,i,14)
   $textw tag configure sn2 -font $font(z,m,r,14)
   $textw tag configure sngr1 -font $font(g,m,i,14)
   $textw tag configure sngr2 -font $font(g,m,i,14)
   $textw tag configure snhb1 -font $font(a,m,r,14)
   $textw tag configure snhb2 -font $font(a,m,r,14)
   $textw tag configure shb1 -font $font(a,m,r,14)
   $textw tag configure shb2 -font $font(a,m,r,14)

   set dwb_vars(TABLEOFCONS,TREEW) $textw
   set dwb_vars(CURRNODE) ""
 
   pack $hierarchyarea -expand yes -fill both
}

# ---------------------------------------------------------
# Find out which tab in the notebook is currently active
# ---------------------------------------------------------

proc SetTOCActiveTab {widgetname} {
   global dwb_vars

   set dwb_vars(TOC,active_tab) $widgetname
}


# ---------------------------------------------------------
# open procedure for table of contents area
# ---------------------------------------------------------

proc OpenTOCNode {tree node} {

   set hlist [$tree subwidget hlist]

   if {[$hlist info children $node] != {}} {
      foreach kid [$hlist info children $node] {
         $hlist show entry $kid
      }
      return
   }

   regsub -all "/" $node "" label
   set cmd "OpenTOCof$label"

   $cmd $tree $node
}


# ---------------------------------------------------------
# highlight TOC entry
# ---------------------------------------------------------

proc HighlightHierarchyNode {node} {
   global dwb_vars
   set textw $dwb_vars(TABLEOFCONS,TREEW)

   if {$node != $dwb_vars(CURRNODE)} {
      if {$dwb_vars(CURRNODE) != ""} {
      # grey97
         $textw tag configure $dwb_vars(CURRNODE) \
            -background grey97 -relief flat
      }
      set dwb_vars(CURRNODE) $node
      $textw tag configure $dwb_vars(CURRNODE) \
         -background grey80 -bgstipple gray50 \
         -borderwidth 0 -relief flat
      set dwb_vars(CURRNODE) $node
   }
   
   return
}


# ---------------------------------------------------------
# show hierarchy tree
# ---------------------------------------------------------

proc ShowTree {w id node level} {
   global dwb_vars	
	
   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]
   
   if {[lindex $dwb_vars(vis,$id) $node] == 0} {
      return [SkipSubTree $id $node]	
   }

   ShowNode $w $id $node $level
     
   if {$n == 0} {
      return [expr $node+1]
   }
   
   set c $f
   for {set i 0} {$i < $n} {incr i} {
      set c [ShowTree $w $id $c [expr $level+1]]	
   }
   
   return $c
}


proc ShowNode {w id node level} {
   global dwb_vars

   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]
   
   if {$node > 0} {
      set ai [$w index insert]
      for {set i 0} {$i < [expr $level-1]} {incr i} {
      	 $w ins insert "\t"
      }	
      if {$n > 0 && [lindex $dwb_vars(vis,$id) $f] == 0} {
         set idx [$w index insert]
      	 label $w.lbl$dwb_vars(imagenr) -image [tix getimage smallright] -bd 0
         bind $w.lbl$dwb_vars(imagenr) <1> [eval list "OpenNode $w $id $node $level $idx $dwb_vars(imagenr)"]
         $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg "Ebene öffnen"
         $w win cr insert -win $w.lbl$dwb_vars(imagenr) -align baseline
         incr dwb_vars(imagenr)
      }
      if {$n > 0 && [lindex $dwb_vars(vis,$id) $f] == 1} {
         set idx [$w index insert]
      	 label $w.lbl$dwb_vars(imagenr) -image [tix getimage smalldown] -bd 0
         bind $w.lbl$dwb_vars(imagenr) <1> [eval list "CloseNode $w $id $node $level $idx $dwb_vars(imagenr)"]
         $dwb_vars(BHLP) bind $w.lbl$dwb_vars(imagenr) -msg "Ebene schließen"
         $w win cr insert -win $w.lbl$dwb_vars(imagenr) -align baseline
         incr dwb_vars(imagenr) 
      }
      if {$n == 0} {
      	 label $w.lbl$dwb_vars(imagenr) -image [tix getimage none] -bd 0
         $w win cr insert -win $w.lbl$dwb_vars(imagenr) -align baseline
         incr dwb_vars(imagenr) 
      }
      $w ins insert "\t"
      set tocline [lindex $dwb_vars(lab,$id) $node]
      if {$dwb_vars(MENU,subsign)} {
         set tocline [SubsSpecialChars $tocline]
      }
      set tocline [SubsChars $tocline]
      #puts "TOCLINE=$tocline"
      eval $tocline
      set ei [$w index insert]
      $w tag add node$id$node $ai $ei
      $w ins insert "\n"
      $w mark set node$id$node insert-1c
   }
}


proc SkipSubTree {id node} {
   global dwb_vars
   
   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]

   if {$n == 0} {
      return [expr $node+1]
   }
   
   set c $f
   for {set i 0} {$i < $n} {incr i} {
      set c [SkipSubTree $id $c]	
   }
   
   return $c
}


# ---------------------------------------------------------
# open hierarchy node
# ---------------------------------------------------------

proc OpenNode {w id node level idx img} {
   global dwb_vars
   
   $w config -state normal
   $w.lbl$img config -image [tix getimage smalldown]
   bind $w.lbl$img <1> [eval list "CloseNode $w $id $node $level $idx $img"]
   $dwb_vars(BHLP) bind $w.lbl$img -msg "Ebene schließen"

   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]

   $w mark set insert "[$w index node$id$node]+1 char"

   set c $f
   for {set i 0} {$i < $n} {incr i} {
      set dwb_vars(vis,$id) [lreplace $dwb_vars(vis,$id) $c $c 1]

      ShowNode $w $id $c [expr $level+1]
      set c [OpenSubTree $w $id $c [expr $level+1]]	
   }
   $w config -state disabled
}

proc OpenSubTree {w id node level} {
   global dwb_vars
   
   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]

   if {$n == 0} {
      return [expr $node+1]
   }
   if {[lindex $dwb_vars(vis,$id) $f] == 0} {
      return [SkipSubTree $id $node]
   }	

   $w mark set insert "[$w index node$id$node]+1 char"
   
   set c $f
   for {set i 0} {$i < $n} {incr i} {
      ShowNode $w $id $c [expr $level+1]
      set c [OpenSubTree $w $id $c [expr $level+1]]
   }
   
   return $c
}


# ---------------------------------------------------------
# close hierarchy node
# ---------------------------------------------------------

proc CloseNode {w id node level idx img} {
   global dwb_vars
   
   $w config -state normal
   $w.lbl$img config -image [tix getimage smallright]
   bind $w.lbl$img <1> [eval list "OpenNode $w $id $node $level $idx $img"]
   $dwb_vars(BHLP) bind $w.lbl$img -msg "Ebene öffnen"

   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]

   $w mark set insert "[$w index node$id$node]+1 char"
   set line [lindex [split [$w index insert] "."] 0]

   set c $f
   for {set i 0} {$i < $n} {incr i} {
      set dwb_vars(vis,$id) [lreplace $dwb_vars(vis,$id) $c $c 0]
      $w delete $line.0 "$line.end+1 char"
      set c [DismissSubTree $w $id $c]
   }
   $w config -state disabled
}

proc DismissSubTree {w id node} {
   global dwb_vars
   
   set n [lindex $dwb_vars(nc,$id) $node]
   set f [lindex $dwb_vars(fc,$id) $node]

   if {$n == 0 || [lindex $dwb_vars(vis,$id) $f] == 0} {
      return [expr $node+1]
   }

   $w mark set insert "[$w index node$id$node]+1 char"
   set line [lindex [split [$w index insert] "."] 0]
   
   set c $f
   for {set i 0} {$i < $n} {incr i} {
      $w delete $line.0 "$line.end+1 char"
      set c [DismissSubTree $w $id $c]
   }
   
   return $c
}

# ---------------------------------------------------------
# trace hierarchy in wbtext
# ---------------------------------------------------------

proc TraceHierarchy {top textw xp yp} {
   global dwb_vars

   set tagnames [$textw tag names @$xp,$yp]
   foreach tag $tagnames {
      set prefTag [string range $tag 0 3]
      if {($prefTag == "node") \
          && $tag != $dwb_vars(CURRNODE)} {
         if {$dwb_vars(CURRNODE) != ""} {
            #tk_messageBox -message "normal view"
            $textw tag configure $dwb_vars(CURRNODE) \
               -background grey97 -relief flat
         }
         set dwb_vars(CURRNODE) $tag
         $textw tag configure $dwb_vars(CURRNODE) \
            -borderwidth 0 -relief solid -bgstipple gray50 -background grey80
         set dwb_vars(CURRNODE) $tag
         return
      }
      if {$tag == $dwb_vars(CURRNODE)} {
         return
      }
   }
   HideHierarchyNode $textw
}


# ---------------------------------------------------------
# low light hierarchy node
# ---------------------------------------------------------

proc HideHierarchyNode {w} {
   global dwb_vars


   if {$dwb_vars(CURRNODE) != ""} {
      $w tag configure $dwb_vars(CURRNODE) -background grey97 -relief flat
   }

   # set dwb_vars($wbname,CURRHIGHLIGHT) ""
}


# ---------------------------------------------------------
# show reference hierarchy node
# ---------------------------------------------------------

proc ReferenceHierarchy {top textw xp yp} {
   global dwb_vars

   if {$dwb_vars(CURRNODE) == ""} {
      return
   }

   set wbname DWB 
   set part $dwb_vars(WBAREA,$wbname,ACTIVETAB)
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   set mark $dwb_vars(CURRNODE)

   if {[catch {eval $dwb_vars(WBTEXT,$wbname,$dpidx) yview $mark+2c}]} {
   }

   if {$dwb_vars(applicationType) == "offline"} {
      SetLemmaHeader $dwb_vars(WBTEXT,$wbname,$dpidx) $wbname
   }
}
