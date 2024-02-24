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
# No part of this publication may be reprinted or reproduced
# or utilized in any form or by any electronic (online or
# offline), mechnical or other means without permissions in
# writing from the publisher.
# CD-ROM copyright by HWB, TB, RC, KG, VH and TS.
# 
# Trier, November 2002
# =========================================================

#
# Program-Intro
#
# ---------------------------------------------------------


# ---------------------------------------------------------
# pack intro window into MDI child window
# ---------------------------------------------------------

proc MDI_IntroArea {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENINTRO) >= 0} {
      return
   }

   set title "HERZLICH WILLKOMMEN!"
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,close_cmd) "CloseIntroArea $n"
   MDIchild_CreateWindow $n 0 0 0
   set intro [MkIntroArea $MDI_cvars($n,client_path) $n]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"

   set MDI_cvars($n,xw) [expr ([winfo width $top]- [winfo reqwidth \
      $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo height $top]- \
      [winfo reqheight $MDI_cvars($n,this)])/3]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]

   MDIchild_Show $n
   MDI_ActivateChild $n

   set dwb_vars(OPENINTRO) $n
   after 6412 "CloseIntroArea $n"

   return $intro
}


# ---------------------------------------------------------
# create introduction window
# ---------------------------------------------------------

proc MkIntroArea {top n} {
   global font dwb_vars

   set introtop $top

   set introarea [frame $introtop.introarea -bd 0 -relief flat \
      -background $dwb_vars(DWB,TABFORE,disabled)]

   set drawarea [canvas $introarea.draw -height 670 -width 420 \
      -background $dwb_vars(DWB,TABFORE,disabled) -relief flat -bd 1]

   #set writing [tix getimage Engel2]
   #$drawarea create image 400 200 -image $writing -anchor c

   #set writing [tix getimage grimmb]
   set writing [tix getimage logo2001]
   $drawarea create image 0 0 -image $writing -anchor nw

   #$drawarea create text 572 32 -text \
   #   "DEUTSCHES WÖRTERBUCH" \
   #   -font $font(z,m,r,28) -justify center -fill black

   #$drawarea create text 572 63 -text \
   #   "VON JACOB UND WILHELM GRIMM" \
   #   -font $font(z,m,r,18) -justify center -fill black

   #$drawarea create text 572 110 -text "entwickelt im Kompetenzzentrum für\nelektronische Erschließungs- und Publikationsverfahren\nin den Geisteswissenschaften an der Universität Trier\nin Verbindung mit der Berlin-Brandenburgischen Akademie\nder Wissenschaften, Berlin" \
   #   -font $font(z,m,r,14) -justify center -anchor n -fill black

   #$drawarea create text 572 238 -text "bearbeitet von" \
   #   -font $font(z,m,r,12) -justify center -anchor n -fill black

   #$drawarea create text 572 388 -text "Hans-Werner Bartz\nThomas Burch\nRuth Christmann\nKurt Gärtner\nVera Hildenbrandt\nThomas Schares\nKlaudia Wegge" \
   #   -font $font(z,m,r,14) -justify center \
   #   -anchor s -fill black

   #$drawarea create text 183 390 \
   #   -text "Gefördert durch die DFG im Rahmen des Programms\n\'Retrospektive Digitalisierung von Bibliotheksbeständen\'" \
   #   -font $font(z,m,r,12) -justify center -anchor s -fill black

   $drawarea create text 420 665 -text "1. Auflage, Mai 2004" \
      -font $font(z,b,r,12) -justify center -fill black -anchor se

   bind $drawarea <ButtonPress-1> [eval "list CloseIntroArea $n"]
   bind $drawarea <KeyPress> [eval "list CloseIntroArea $n"]

   #button $introarea.ok -text "Zum Wörterbuch" \
   #   -font $font(h,m,r,12) -command "CloseIntroArea $n" \
   #   -bd 0 -background $dwb_vars(DWB,TABFORE,disabled) -relief solid

   #pack $drawarea $introarea.ok -side top -expand yes -fill x
   pack $drawarea -side top -expand yes -fill x
   pack $introarea

   update

   set dwb_vars(INTRO) $introtop

   return $introarea
}


# ---------------------------------------------------------
# close user information window
# ---------------------------------------------------------

proc CloseIntroArea {n} {
   global dwb_vars
   global MDI_cvars MDI_vars

   if {$dwb_vars(OPENINTRO) >= 0} {
      MDI_DestroyChild $n
   }
   set dwb_vars(OPENINTRO) -1
}


# ---------------------------------------------------------
# pack intro window into MDI child window
# ---------------------------------------------------------

proc MDI_AboutArea {top} {
   global dwb_vars
   global MDI_vars MDI_cvars

   if {$dwb_vars(OPENABOUT) >= 0} {
      return
   }

   set title " "
   set n [MDI_CreateChild "$title"]
   set MDI_cvars($n,close_cmd) "CloseAboutArea $n"
   MDIchild_CreateWindow $n 0 0 1
   set intro [MkAboutArea $MDI_cvars($n,client_path) $n]
   set MDI_cvars($n,hide_cmd) "MDI_IconifyChild $n {$title}"

   set MDI_cvars($n,xw) [expr ([winfo width $top]- [winfo reqwidth \
      $MDI_cvars($n,this)])/2]
   set MDI_cvars($n,yw) [expr ([winfo height $top]- \
      [winfo reqheight $MDI_cvars($n,this)])/3]
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]

   MDIchild_Show $n
   MDI_ActivateChild $n

   set dwb_vars(OPENABOUT) $n

   return $intro
}


# ---------------------------------------------------------
# create about window
# ---------------------------------------------------------

proc MkAboutArea {top n} {
   global font dwb_vars

   set introtop $top

   set introarea [frame $introtop.introarea -bd 5 -relief flat \
      -background $dwb_vars(DWB,TABFORE,disabled)]

   set drawarea [canvas $introarea.draw -height 400 -width 800 \
      -background linen -relief sunken -bd 1]

   #set writing [tix getimage hs3]
   #$drawarea create image 5 0 -image $writing -anchor nw

   #set writing [tix getimage hsb]
   #$drawarea create image 316 0 -image $writing -anchor nw

   #set head [tix getimage mhdwb2]
   #$drawarea create image 400 40 -image $head -anchor c

   $drawarea create text 400 32 -text \
      "Deutsches Wörterbuch von Jacob und Wilhelm Grimm (Erstbearbeitung) auf CD-ROM" \
      -font $font(z,m,r,18) -justify center -fill black

   $drawarea create text 400 50 -text \
      "Der Digitale Grimm wird herausgegeben von\nHans-Werner Bartz, Thomas Burch, Ruth Christmann, Kurt Gärtner,\nVera Hildenbrandt, Thomas Schares, Klaudia Wegge\nam Kompetenzzentrum für elektronische Erschließungs-\nund Publikationsverfahren in den Geisteswissenschaften\nan der Universität Trier\nin Verbindung mit der Berlin-Brandenburgischen Akademie der Wissenschaften" \
      -font $font(z,m,r,12) -justify center -anchor n -fill black
        
   $drawarea create text 400 180 -text \
     "Gefördert durch die Deutsche Forschungsgemeinschaft" \
     -font $font(z,m,r,12) -justify center -anchor n -fill black 

   $drawarea create text 400 220 -text \
     "Am Digitalen Grimm haben außerdem  mitgearbeitet\nClaudia Bick, Johanna Theresia Biehl, Niels Bohnert, Gabriele Diehr, Johannes Endres, Beate Falterbaum, Verena Hoffmann,\nPatrick Heck, Ruth Kersting, Ane Kleine, Stephanie Kuhn, Johannes Leicht, Patrick Mai, Janine Marske, Oliver Mees,\nJenny Port, Thomas Raps, Hagen Reinstein, Patricia Seyler, Ramona Treinen, Tanja Wagner, Yan Wu" \
     -font $font(z,m,r,12) -justify center -anchor n -fill black 
     
   $drawarea create text 400 300 -text \
     "Das Arbeitsteam des Kompetenzzentrums bedankt sich bei\nRudolf Behrendt, Johannes Fournier, Andrea Rapp, Jingning Tao, Michael Trauth, Martin Weinmann" \
     -font $font(z,m,r,12) -justify center -anchor n -fill black 
     
   #set tcltk [tix getimage tcllogo]
   #$drawarea create image 60 120 -image $tcltk -anchor n

   #set tix [tix getimage tixlogo]
   #$drawarea create image 60 199 -image $tix -anchor n

   #set blt [tix getimage bltlogo]
   #$drawarea create image 60 277 -image $blt -anchor n

   #set equi4 [tix getimage mk4logo]
   #$drawarea create image 60 345 -image $equi4 -anchor n

   #$drawarea create text 130 157 -text "Tcl/Tk 8.3\nvon John Ousterhout" \
   #   -font $font(z,m,r,12) -justify left -anchor sw

   #$drawarea create text 130 157 -text "www.scriptics.com" \
   #   -font $font(z,m,r,12) -justify left -anchor nw -fill blue

   #$drawarea create text 130 231 -text "Tix 4.1.0\nvon Gregg Squires" \
   #   -font $font(z,m,r,12) -justify left -anchor sw

   #$drawarea create text 130 231 -text "tix.mne.com" \
   #   -font $font(z,m,r,12) -justify left -anchor nw -fill blue

   #$drawarea create text 130 305 -text "BLT 2.4\nvon Bell Labs" \
   #   -font $font(z,m,r,12) -justify left -anchor sw

   #$drawarea create text 130 305 -text "www.tcltk.com" \
   #   -font $font(z,m,r,12) -justify left -anchor nw -fill blue

   #$drawarea create text 130 373 -text "MetaKit 1.8.6\nvon Jean-Claude Wippler" \
   #   -font $font(z,m,r,12) -justify left -anchor sw

   #$drawarea create text 130 373 -text "www.equi4.com" \
   #   -font $font(z,m,r,12) -justify left -anchor nw -fill blue

   #$drawarea create text 600 85 -text "An dieser CD-ROM haben mitgearbeitet" \
   #   -font $font(z,m,r,14) -justify center -anchor c -fill black

   #$drawarea create text 600 100 -text "Hans-Werner Bartz, Claudia Bick, Johanna Theresia Biehl\n\
   #   Niels Bohnert, Thomas Burch, Ruth Christmann\n\
   #   Gabriele Diehr, Johannes Endres, Beate Falterbaum\n\
   #   Kurt Gärtner, Vera Hildenbrandt, Verena Hoffmann\n\
   #   Ruth Kersting, Ane Kleine, Stephanie Kuhn\n\
   #   Johannes Leicht, Patrick Mai, Janine Marske\n\
   #   Oliver Mees, Jenny Port, Thomas Raps\n\
   #   Thomas Schares, Patricia Seyler, Ramona Treinen\n\
   #   Tanja Wagner, Klaudia Wegge, Yan Wu" \
   #   -font $font(z,m,r,12) -justify center -anchor n -fill black

   #$drawarea create text 600 270 -text "Außerdem möchten wir uns bedanken bei" \
   #   -font $font(z,m,r,14) -justify center -anchor c -fill black

   # $drawarea create text 600 285 -text "Johannes Fournier, Andrea Rapp, Jingning Tao" \
   #   -font $font(z,m,r,12) -justify center -anchor n -fill black

    $drawarea create text 400 350 -text "Kontaktadresse\nwww.Zweitausendeins.de/dwb" \
      -font $font(z,m,r,12) -justify center -anchor n -fill black

   # $drawarea create text 600 335 -text "FB II, Germanistik, Uni Trier, 54286 Trier\nwww.dwb.uni-trier.de\ne-mail: grimmwb@uni-trier.de" \
   #   -font $font(z,m,r,12) -justify center -anchor n -fill black

   bind $drawarea <ButtonPress-1> [eval "list CloseAboutArea $n"]
   bind $drawarea <KeyPress> [eval "list CloseAboutArea $n"]

   pack $drawarea -side top -expand yes -fill x
   pack $introarea

   update

   set dwb_vars(ABOUT) $introtop

   return $introarea
}


# ---------------------------------------------------------
# close about window
# ---------------------------------------------------------

proc CloseAboutArea {n} {
   global dwb_vars
   global MDI_cvars MDI_vars

   if {$dwb_vars(OPENABOUT) >= 0} {
      MDIchild_Delete $n
   }
   set dwb_vars(OPENABOUT) -1
}