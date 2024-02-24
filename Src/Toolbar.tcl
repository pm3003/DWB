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

# Tcl-Script for main toolbar
# ---------------------------------------------------------


# ---------------------------------------------------------
# create toolbar 
# ---------------------------------------------------------

proc MkToolBar {top} {
   global dwb_vars

   set w [frame $top.toolframe -bd 1 -relief sunken -height 36 \
      -background slategrey]

   set wb_fr [frame $w.wb -background slategrey]
   set wb_sep [frame $w.wbsep -background grey -width 2 -height 30 \
      -bd 1 -relief sunken]
   set book_fr [frame $w.book -background slategrey]
   set book_sep [frame $w.booksep -background grey -width 2 -height 30 \
      -bd 1 -relief sunken]
   set note_fr [frame $w.note -background slategrey]
   set exit_fr [frame $w.exit -background slategrey]
   set help_fr [frame $w.help -background slategrey]

   set image [tix getimage door_open]
   set icon [MkFlatButton $exit_fr exit ""]
   $icon config -borderwidth 1 -relief raised -image $image \
      -padx 1 -pady 1 -background linen
   pack $icon -side left -anchor s -padx 2 -pady 2

   foreach {wb wbshort} $dwb_vars(wbname) {
      set image [tix getimage iconlogo$wbshort]
      set icon [MkFlatButton $wb_fr wb$wbshort ""]
      $icon config -borderwidth 1 -relief raised -image $image \
         -padx 1 -pady 1 -background linen
      pack $icon -side left -anchor s -padx 2 -pady 2
      $dwb_vars(BHLP) bind $icon -msg "$dwb_vars(wbtitle,$wb)"
   }

   set image [tix getimage book11b]
   set icon [MkFlatButton $book_fr mark ""]
   $icon config -borderwidth 1 -relief raised -image $image \
      -padx 1 -pady 1 -background linen
   pack $icon -side left -anchor s -padx 2 -pady 2

   set image [tix getimage binoculars]
   set icon [MkFlatButton $book_fr search ""]
   $icon config -borderwidth 1 -relief raised -image $image \
      -padx 1 -pady 1 -background linen
   pack $icon -side left -anchor s -padx 2 -pady 2

   set image [tix getimage iconqvz]
   set icon [MkFlatButton $book_fr qvz ""]
   $icon config -borderwidth 1 -relief raised -image $image \
      -padx 1 -pady 1 -background linen
   pack $icon -side left -anchor s -padx 2 -pady 2

   set image [tix getimage help]
   set icon [MkFlatButton $help_fr help ""]
   $icon config -borderwidth 1 -relief raised -image $image \
      -padx 1 -pady 1 -background linen
   pack $icon -side left -anchor s -padx 2 -pady 2

   set image [tix getimage i3a]
   set icon [MkFlatButton $help_fr info ""]
   $icon config -borderwidth 1 -relief raised -image $image \
      -padx 1 -pady 1 -background linen
   pack $icon -side left -anchor s -padx 2 -pady 2

   pack $wb_fr -side left -padx 2
   pack $wb_sep -side left -padx 2
   pack $book_fr -side left -padx 2
   pack $note_fr -side left -padx 2
   pack $exit_fr -side right -padx 2
   pack $book_sep -side right -padx 2
   pack $help_fr -side right -padx 2

   return $w
}


# ---------------------------------------------------------
# configure toolbar after generation of components
# ---------------------------------------------------------

proc ConfigureToolbar {top} {
   global dwb_vars

   $top.exit.exit config -command EndDWB
   $dwb_vars(BHLP) bind $top.exit.exit -msg "Programmende"

   $top.wb.wbQ config -command "$dwb_vars(tocbook) select 3"

   $top.book.mark config -command "MDI_NotesBookMarksDisplay $top"
   $dwb_vars(BHLP) bind $top.book.mark -msg \
      "Lesezeichen anlegen"

   $top.book.search config -command "$dwb_vars(tocbook) select 1"
   $dwb_vars(BHLP) bind $top.book.search -msg "Suchen in \
      der Datenbank"

   $top.book.qvz config -command "ReferenceInfo $top DWB"
   $dwb_vars(BHLP) bind $top.book.qvz -msg "Quellensigle"

   # $top.help.help config -command "ShowUserHelp"
   $dwb_vars(BHLP) bind $top.help.help -msg "Benutzerhilfe"

   $top.help.info config -command "MDI_AboutArea ."
   $dwb_vars(BHLP) bind $top.help.info -msg \
      "Informationen über die CD-ROM"
}

