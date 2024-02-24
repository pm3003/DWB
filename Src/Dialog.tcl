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
# create info popup message
# ---------------------------------------------------------

proc DisplayInfoPopup {top labeltext {fg ""} {bg ""} {mode 0}} {
   global dwb_vars font

   set dparea [frame .infopopup -borderwidth 1 -relief raised -bg grey]

   label $dparea.text -text $labeltext -font $font(h,b,r,14) \
      -bd 0 -relief solid -textvariable dwb_vars(INFOLABEL)

   if {$mode} {
      frame $dparea.add	
   }

   if {$bg != ""} {
      $dparea config -bg $bg
      $dparea.text config -bg $bg
   }

   if {$fg != ""} {
      $dparea.text config -fg $fg
   }

   if {$mode} {
      pack $dparea.text $dparea.add -side top -ipadx 3 -ipady 1 \
         -fill both
   } else {
      pack $dparea.text -side left -ipadx 3 -ipady 1 \
         -fill both
   }
         
   set x [expr ([winfo reqwidth .]-[winfo reqwidth $dparea])/3]
   incr x [winfo x $top]
   set y [expr ([winfo reqheight .]-[winfo reqheight $dparea])/3]
   incr y [winfo y $top]

   place $dparea -x $x -y $y
   update

   #grab set $dparea

   return $dparea
}


proc WarningDialog {title text button1 button2 command1} {

   set w .warn
   toplevel $w
   wm title $w $title

   # make modal
   grab set $w

   # Create the label on the top of the dialog box
   #
   frame $w.top -border 1 -relief raised
   label $w.top.label -pady 20 -anchor c -text $text
   label $w.top.bitmap -image [tix getimage warn]

   # Create the button box and add two buttons in it.

   tixButtonBox $w.box -orientation horizontal
   $w.box add ok -text $button1 -underline 0 -command "
         $command1
         destroy $w
         update
      " -width 5

   $w.box add cancel -text $button2 -underline 0 -command "
         destroy $w
         update
      " -width 5

   pack $w.box -side bottom -fill x
   pack $w.top.bitmap -side left -padx 2m -pady 2m
   pack $w.top.label -side left -ipadx 15m
   pack $w.top -side top -fill both -expand yes

   wm withdraw $w
   update

   set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 - \
      [winfo vrootx [winfo parent $w]]]
   set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 - \
      [winfo vrooty [winfo parent $w]]]
   wm geom $w +$x+$y

   wm deiconify $w
   wm resizable $w 0 0
   # wm protocol $w WM_DELETE_WINDOW "DestroyNotebookWindow $w"

   # make modal
   grab set $w

   focus [$w.box subwidget cancel]
}


proc ErrorDialog {title text button command1} {

   set dparea [frame .errorpopup -borderwidth 1 -relief raised -bg grey]
   #set w .warn
   #toplevel $w
   #wm title $w $title

   set w $dparea
   # make modal
   grab set $w

   # Create the label on the top of the dialog box
   #
   frame $w.top -border 1 -relief raised
   label $w.top.label -pady 20 -anchor c -text $text
   label $w.top.bitmap -image [tix getimage error]

   # Create the button box and add two buttons in it.

   tixButtonBox $w.box -orientation horizontal
   $w.box add ok -text $button -underline 0 -command "
         destroy $w
         $command1
         update
      " -width 5

   pack $w.box -side bottom -fill x
   pack $w.top.bitmap -side left -padx 2m -pady 2m
   pack $w.top.label -side left -ipadx 15m
   pack $w.top -side top -fill both -expand yes

   #wm withdraw $w
   update

   set x [expr [winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 - \
      [winfo vrootx [winfo parent $w]]]
   set y [expr [winfo screenheight $w]/2 - [winfo reqheight $w]/2 - \
      [winfo vrooty [winfo parent $w]]]

   place $dparea -x $x -y $y
   update

   #grab set $dparea

   tkwait window $w
   return $dparea
   #wm geom $w +$x+$y

   #wm deiconify $w
   #wm resizable $w 0 0

   # make modal
   #grab set $w

   #focus [$w.box subwidget ok]
}


# ---------------------------------------------------------
# create info popup message
# ---------------------------------------------------------

proc DisplayInfoPopupCmd {top header imagename labeltext btntext cmd {fg ""} {bg \
   ""}} {
   global dwb_vars font
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild $header]
   MDIchild_CreateWindow $n 0 0 0

   set dparea [frame $MDI_cvars($n,client_path).dparea \
      -borderwidth 1 -relief raised]

   label $dparea.img -image [tix getimage $imagename]
   label $dparea.text -text $labeltext -font $font(h,b,r,14)

   if {$bg != ""} {
      $dparea config -bg $bg
      $dparea.img config -bg $bg
      $dparea.text config -bg $bg
   }

   if {$fg != ""} {
      $dparea.img config -fg $fg
      $dparea.text config -fg $fg
   }

   button $dparea.btn -text $btntext -command $cmd

   pack $dparea.img -side left -ipadx 3 -ipady 3 -padx 5
   pack $dparea.text -side left -ipadx 3 -ipady 3 -expand yes \
      -fill both
   pack $dparea.btn -side right

   pack $dparea -ipadx 3 -ipady 3
   update

   set MDI_cvars($n,xw) [expr ([winfo width .workarea]-[winfo \
      reqwidth $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo height .workarea]-[winfo \
      reqheight $MDI_cvars($n,this)])/3]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]

   MDIchild_Show $n

   update
   grab set $MDI_cvars($n,this)

   return $n
}


# ---------------------------------------------------------
# create info popup message
# ---------------------------------------------------------

proc DisplaySearchInfo {top header imagename labeltext {fg ""} {bg \
   ""}} {
   global dwb_vars font
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild $header]
   MDIchild_CreateWindow $n 0 0 0

   set dparea [frame $MDI_cvars($n,client_path).dparea \
      -borderwidth 1 -relief raised]

   frame $dparea.head
   label $dparea.head.img -image [tix getimage $imagename]
   label $dparea.head.text -text $labeltext -font $font(h,b,r,14)

   if {$bg != ""} {
      $dparea config -bg $bg
      $dparea.head.img config -bg $bg
      $dparea.head.text config -bg $bg
   }

   if {$fg != ""} {
      $dparea.head.img config -fg $fg
      $dparea.head.text config -fg $fg
   }

   frame $dparea.body
   tixScrolledText $dparea.body.iarea
   [$dparea.body.iarea subwidget text] config -font $font(h,m,r,14) \
      -width 60 -height 20

   pack $dparea.head.img -side left -ipadx 3 -ipady 3 -fill x
   pack $dparea.head.text -side left -ipadx 3 -ipady 3 -expand yes \
      -fill both
      
   pack $dparea.body.iarea -side bottom -expand yes -fill both
   set dwb_vars(SearchInfoArea) [$dparea.body.iarea subwidget text]
   
   pack $dparea.head -side top -fill x
   pack $dparea.body -side bottom -fill both -expand yes
   
   pack $dparea -ipadx 3 -ipady 3
   update

   set MDI_cvars($n,xw) [expr ([winfo width .workarea]-[winfo \
      reqwidth $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo height .workarea]-[winfo \
      reqheight $MDI_cvars($n,this)])/3]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]

   MDIchild_Show $n

   update
   grab set $MDI_cvars($n,this)

   return $n
}

