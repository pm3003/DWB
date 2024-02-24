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
# Script for HTML Viewer
#
# ---------------------------------------------------------


# ---------------------------------------------------------
# pack HTML viewer into MDI child window
# ---------------------------------------------------------

proc MDI_HTMLViewer {top wbname starturl} {
   global dwb_vars
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild " "]
   MDIchild_CreateWindow $n 1 0 1
   set htmlarea [MkHTMLViewer $MDI_cvars($n,client_path) $wbname $starturl]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {HTML Viewer}"

   set MDI_cvars($n,xw) [expr ([winfo reqwidth .workarea]- \
      [winfo reqwidth $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo reqheight .workarea]- \
      [winfo reqheight $MDI_cvars($n,this)])/2]

   MDIchild_Show $n
   return $htmlarea
}

# ---------------------------------------------------------
# create HTML viewer area
# ---------------------------------------------------------

proc MkHTMLViewer {top wbname starturl} {
   global dwb_vars font

   set body [frame $top.body -bd 0]

   set f1 [frame $body.f1 -bd 0]

   set html [html $f1.html -padx 5 -pady 5 -width 400 -height 400 \
      -yscrollcommand "$f1.vs set" -bd 1 -relief sunken \
      -xscrollcommand "$body.f2.hs set" -imagecommand \
      "LoadImage $f1.html" -background grey97 -unvisitedcolor blue \
      -visitedcolor maroon -hyperlinkcommand \
      "FollowHperlink $f1.html" -base "." \
      -fontcommand "SelectFont"]

   # $html token handler body "br.bodymarkup"
   # $html base [pwd]
   
   bind $html.x <1> [eval "list FollowHyperlink $html %x %y"]
   bind $html.x <Motion> [eval "list TraceHyperlink $html %x %y"]

   pack $html -side left -fill both -expand yes

   set dwb_vars($html,urllist) {}
   set dwb_vars($html,imagelist) {}
   set dwb_vars($html,index) -1

   scrollbar $f1.vs -command "$html yview" -orient vertical -width 15
   pack $f1.vs -side right -fill y

   set f2 [frame $body.f2 -bd 0]

   frame $f2.spacer -width [winfo reqwidth $f1.vs]
   pack $f2.spacer -side right -fill y
   scrollbar $f2.hs -command "$html xview" -orient horizontal -width 15
   pack $f2.hs -side left -fill x -expand yes

   set f3 [frame $body.f3 -bd 1 -relief sunken -background $dwb_vars($wbname,TABBACK)]

   set back [MkFlatButton $f3 back ""]
   $back config -image [tix getimage arrleft] -command \
      "PreviousPage $html" -background $dwb_vars($wbname,TABBACK)
   $dwb_vars(BHLP) bind $back -msg "Zurückblättern"

   set home [MkFlatButton $f3 home ""]
   $home config -image [tix getimage arrleftend] -command "HomePage $html" -background $dwb_vars($wbname,TABBACK)
   $dwb_vars(BHLP) bind $home -msg "Zur Startseite"

   set fore [MkFlatButton $f3 fore ""]
   $fore config -image [tix getimage arrright] -command \
      "NextPage $html" -background $dwb_vars($wbname,TABBACK)
   $dwb_vars(BHLP) bind $fore -msg "Vorblättern"

   set sep [frame $f3.sep -bd 1 -relief raised -background $dwb_vars($wbname,TABBACK)]

   pack $f3.back $f3.fore $f3.home -side left -fill y
   pack $f3.sep -side left -expand yes -fill both

   pack $f3 -side top -fill x
   pack $f2 -side bottom -fill x
   pack $f1 -side top -fill both -expand yes

   pack $body -fill both -expand yes

   update

   LoadPage $html $starturl

   return $body
}


# ---------------------------------------------------------
# activate hyper link, load next page
# ---------------------------------------------------------

proc FollowHyperlink {html x y} {
   global dwb_vars

   set url [$html href $x $y]
   
   if {$url != ""} {
      LoadPage $html $url
   }
   $html config -cursor arrow
}


# ---------------------------------------------------------
# trace hyper link
# ---------------------------------------------------------

proc TraceHyperlink {html x y} {
   global dwb_vars

   set url [$html href $x $y]
   
   if {$url != ""} {
      $html config -cursor hand2
   } else {
      $html config -cursor arrow
   }
}

# ---------------------------------------------------------
# goto previous page
# ---------------------------------------------------------

proc PreviousPage {html} {
   global dwb_vars

   incr dwb_vars($html,index) -1
   set url [lindex $dwb_vars($html,urllist) \
      $dwb_vars($html,index)]
   incr dwb_vars($html,index) -1
   LoadPage $html $url
}


# ---------------------------------------------------------
# goto start page
# ---------------------------------------------------------

proc HomePage {html} {
   global dwb_vars

   set url [lindex $dwb_vars($html,urllist) 0]
   set dwb_vars($html,index) -1
   LoadPage $html $url
}


# ---------------------------------------------------------
# load page from url
# ---------------------------------------------------------

proc LoadPage {html url} {
   global dwb_vars

   set mainurl [lindex [split $url ","] 0]
   set securl [lindex [split $url ","] 1]

   if {$mainurl != ""} {
      set fp [open $mainurl r]
      set text [read $fp]
      close $fp

      $html clear
      $html parse $text
   }

   update
   if {$securl != ""} {
      $html yview $securl
   }
   update

   set dwb_vars($html,urllist) [lrange $dwb_vars($html,urllist) \
      0 $dwb_vars($html,index)]
   incr dwb_vars($html,index)
   lappend dwb_vars($html,urllist) $url

   if {$dwb_vars($html,index) == [expr \
      [llength $dwb_vars($html,urllist)] - 1]} {
      [winfo parent [winfo parent $html]].f3.fore config \
         -state disabled
   } else {
      [winfo parent [winfo parent $html]].f3.back config -state normal
   }

   if {$dwb_vars($html,index) == 0} {
      [winfo parent [winfo parent $html]].f3.back config \
         -state disabled
      [winfo parent [winfo parent $html]].f3.home config \
         -state disabled
   } else {
      [winfo parent [winfo parent $html]].f3.back config -state normal
      [winfo parent [winfo parent $html]].f3.home config -state normal
   }
}


# ---------------------------------------------------------
# load image into page
# ---------------------------------------------------------

proc LoadImage {html url args} {
   global dwb_vars

   set cnt [llength $dwb_vars($html,imagelist)]
   set img $html.img.$cnt
   image create photo $img -file $url
   lappend dwb_vars($html,imagelist) $img

   return $img
}


# ---------------------------------------------------------
# set font
# ---------------------------------------------------------

proc SelectFont {size {args ""}} {
   global font

   if {$size < 2} {
      set pxlsize 10
   } elseif {$size < 3} {
      set pxlsize 12
   } elseif {$size < 4} {
      set pxlsize 14
   } else {
      set pxlsize 18
   }
   if {[lsearch $args "italic"] >= 0} {
      set weight b
   } else {
      set weight m
   }
   if {[lsearch $args "bold"] >= 0} {
      set slant i
   } else {
      set slant r
   }
   
   return $font(z,$weight,$slant,$pxlsize)
}
