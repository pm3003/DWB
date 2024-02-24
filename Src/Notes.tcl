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

# Tcl-Script for notes
# ---------------------------------------------------------


# ---------------------------------------------------------
# pack wb components into MDI child window
# ---------------------------------------------------------

proc MDI_NotesComponents {lemid xp yp mode} {
   global dwb_vars
   global MDI_vars MDI_cvars

   set n [MDI_CreateChild ANMERKUNG]
   set dwb_vars(NOTESAREA,MDI) $n

   MDIchild_CreateWindow $n 0 0 1
   set indexarea [MkNotesDisplayArea $MDI_cvars($n,client_path) \
      $lemid $mode $n]
   set MDI_cvars($n,hide_cmd) "IconifyNotesWindow $n"
   set MDI_cvars($n,xw) $xp
   set MDI_cvars($n,yw) $yp
   set MDI_cvars($n,width) [winfo reqwidth $MDI_cvars($n,this)]
   set MDI_cvars($n,height) [winfo reqheight $MDI_cvars($n,this)]
   MDIchild_Show $n

   update
}


# ---------------------------------------------------------
# create notes display area
# ---------------------------------------------------------

proc ShowAnnotation {lemid} {
   global dwb_vars font wbi

   set wb [string range $lemid 0 0]
   set part [string range $lemid 1 1]
   set wbidx [lsearch -exact $dwb_vars(wbname) $wb]
   set wbname [lindex $dwb_vars(wbname) [expr $wbidx-1]]
   
   set pos [lsearch $dwb_vars($wbname,loaded) $part]
   set dpidx [lindex $dwb_vars($wbname,loadpos) $pos]

   pack $dwb_vars(NOTES,$wbname) -side bottom -fill both

   set table LEMMA
   set row [performQuery IDX$wbname $table "ID==$lemid"]
   if {[lindex $row 0] != ""} {
      set lemma [mk::get DB$wbname.$table![lindex $row 0] NAME]
   } else {
      return
   }

   set table GRAM
   set row [performQuery IDX$wbname $table "ID==$lemid"]
   if {[lindex $row 0] != ""} {
      set gram "[mk::get DB$wbname.$table![lindex $row 0] TYPE]."
   } else {
      set gram ""
   }

   set notetitle $dwb_vars(NOTES,$wbname).head
   
   $notetitle.lemma config -text "$lemma"
   $notetitle.gram config -text "$gram"

   set notetext $dwb_vars(NTTEXT,$wbname,$dpidx)
   bind $notetext <KeyRelease> [eval "list UpdateNote $notetext $lemid"]
   $notetext config -state normal
   $notetext delete 1.0 end

   set filename "./System/note$lemid.txt"
   if {[file exists $filename]} {
      set fp [open $filename r]
      set text [read $fp]
      close $fp
      $notetext insert end $text
   }

   update
}


# ---------------------------------------------------------
# iconify notes window
# ---------------------------------------------------------

proc IconifyNotesWindow {child} {
   global MDI_cvars MDI_vars
   global dwb_vars

   return

   set father .toolframe.note

   if {[winfo exists $father.iconb$child] == 0} {
      set image [tix getimage pencil]
      set icon [MkFlatButton $father iconb$child ""]
      $icon config -borderwidth 1 -relief groove -image $image \
         -padx 2 -pady 2 -command "MDI_DeiconifyChild $child" \
         -background linen

      $dwb_vars(BHLP) bind $icon -msg $dwb_vars(NOTESAREA,MDI,$child,balloon)

      pack $icon -side left -anchor s -padx 2 -pady 2
   }
}


# ---------------------------------------------------------
# create note
# ---------------------------------------------------------

proc CreateNote {textw lemid} {
   global dwb_vars
   puts "CreateNote textw $textw lemid $lemid"

   set filename "./System/note$lemid.txt"
   set fp [open $filename w]

   puts $fp [[$textw subwidget text] get 1.0 end]
   close $fp

   set dwb_vars(NOTETEXTS) [lappend dwb_vars(NOTETEXTS) $lemid]

   MDIchild_Delete $dwb_vars(NOTESAREA,MDI)
   UpdateBookMarkArea insert note $lemid
}


# ---------------------------------------------------------
# delete note
# ---------------------------------------------------------

proc DeleteNote {idx lemid} {
   global dwb_vars

   set dwb_vars(NOTETEXTS) [lreplace $dwb_vars(NOTETEXTS) $idx \
      $idx]
   UpdateBookMarkArea delete note $lemid
}


# ---------------------------------------------------------
# update note
# ---------------------------------------------------------

proc UpdateNote {textw lemid} {
   global dwb_vars

   set text [$textw get 1.0 end]
   if {$text == ""} {
      set idx [lsearch -exact $dwb_vars(NOTETEXTS) $lemid]
      DeleteNote $idx $lemid
   } else {
      set filename "./System/note$lemid.txt"
      set fp [open $filename w]

      puts $fp [$textw get 1.0 end]
      close $fp

      UpdateBookMarkArea update note $lemid
   }
   #MDIchild_Delete $dwb_vars(NOTESAREA,MDI)
}


# ---------------------------------------------------------
# save notes
# ---------------------------------------------------------

proc SaveNoteTexts {} {
   global dwb_vars

   set filename "./System/notes"
   set fp [open $filename w]
   foreach bookmark $dwb_vars(NOTETEXTS) {
      puts $fp $bookmark
   }
   close $fp
}


# ---------------------------------------------------------
# read notes
# ---------------------------------------------------------

proc ReadNoteTexts {} {
   global dwb_vars

   set filename "./System/notes"
   if {[file exists $filename]} {
      set fp [open $filename r]
      set id [gets $fp]
      while {$id != ""} {
         set dwb_vars(NOTETEXTS) [lappend dwb_vars(NOTETEXTS) $id]

         set id [gets $fp]
      }
      close $fp
   }
}



