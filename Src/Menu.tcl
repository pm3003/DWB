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

# Tcl-Script for main menu
# ---------------------------------------------------------


# ---------------------------------------------------------
# create menu bar
# ---------------------------------------------------------

proc MkMainMenu {top} {
   global dwb_vars

   set w [frame $top.menuframe -borderwidth 0 -relief flat]
   #      -background grey]
   #set w [menu $top.menu -tearoff 0]

   set filemenu [MkMenuButton $w file "Der Digitale Grimm" 0]
   set quvzmenu [MkMenuButton $w quvz "Quellenverzeichnis" 0]
   set qurymenu [MkMenuButton $w qury Suchen 0]
   set optnmenu [MkMenuButton $w optn Einstellungen 0]
   set extrmenu [MkMenuButton $w extr Extras 0]
   set helpmenu [MkMenuButton $w help Hilfe 0]

   pack $w.file -side left
   pack $w.quvz -side left
   pack $w.qury -side left
   pack $w.optn -side left
   pack $w.extr -side left
   #pack $w.help -side right

   MkMenu $filemenu
   MkMenu $quvzmenu
   MkMenu $qurymenu
   MkMenu $optnmenu
   MkMenu $extrmenu
   #MkMenu $helpmenu

   AddMenuCommand $filemenu "Abkürzungen im Deutschen Wörterbuch" 0 \
      "MDI_DWBAbbrPopup $top"
   AddMenuCommand $filemenu "Das Projektteam" 0 \
      "MDI_AboutArea ."
   AddMenuCommand $filemenu "Über den Digitalen Grimm" 0 \
      "MDI_CopyrightPopup ."
   #AddMenuSeparator $filemenu
   AddMenuCommand $filemenu "Beenden" 0 EndDWB

   AddMenuCommand $quvzmenu "Quellenverzeichnis aufschlagen" 0 \
      "OpenQVZArea $top"
   AddMenuCommand $quvzmenu "Abkürzungen im Quellenverzeichnis" 0 \
      "MDI_QVZAbbrPopup $top"
   AddMenuCommand $quvzmenu "Hinweise zur Benutzung" 0 \
      "MDI_QVZHelpPopup $top"

   AddMenuCommand $qurymenu "Suchen im Wörterbuch" 0 \
      "OpenQueryArea $top"
   AddMenuCommand $qurymenu "Suchen im Quellenverzeichnis" 0 \
      "OpenQVZQueryArea $top"
   #AddMenuSeparator $qurymenu
   AddMenuCommand $qurymenu "Informationen zur Suche" 0 \
      "MDI_SearchHelpPopup $top"

   AddMenuCommand $extrmenu "Rückläufiger Stichwortindex" 0 \
      "OpenRIArea $top"
   AddMenuCommand $extrmenu "Random reading" 0 \
      "MDI_RandomChoose $top"

   if {!$dwb_vars(use_user_conf)} {
      set dwb_vars(MENU,gram) 0
      set dwb_vars(MENU,siglen) 1
      set dwb_vars(MENU,sigrefs) 0
      set dwb_vars(MENU,sense) 0
      set dwb_vars(MENU,belege) 0
      set dwb_vars(MENU,etym) 0
      set dwb_vars(MENU,definition) 0
      set dwb_vars(MENU,intro) 1
      set dwb_vars(MENU,lfg) 1
      set dwb_vars(MENU,col) 1
      set dwb_vars(MENU,subsign) 0
      set dwb_vars(MENU,confexp) 1
   }

   AddMenuCheckButton $optnmenu "Grammatische Angaben markieren" 0 gram 0 \
      "SetOptions gram"
   AddMenuCheckButton $optnmenu "Siglen markieren" 0 siglen 0 \
      "SetOptions siglen"
   AddMenuCheckButton $optnmenu "Lieferungsinformation anzeigen" 0 lfg 0 \
      "ReloadCurrentArticle DWB"
   AddMenuCheckButton $optnmenu "Spaltenwechsel anzeigen" 0 col 0 \
      "ReloadCurrentArticle DWB"
   AddMenuSeparator $optnmenu
   AddMenuCheckButton $optnmenu "Ersatzzeichen anzeigen" 0 subsign 0 \
      "ReloadCurrentArticle DWB"
   AddMenuSeparator $optnmenu
   AddMenuCommand $optnmenu "HTML Exportverzeichnis auswählen" 0 \
    "SelectExportDir"
   AddMenuCheckButton $optnmenu "HTML Export bestätigen" 0 confexp 0 \
    ""   

   return $w
}

# ---------------------------------------------------------
# create menu button
# ---------------------------------------------------------

proc MkMenuButton {menubar menu name uline} {
   global dwb_vars font

   menubutton $menubar.$menu -text $name \
      -font $font(menu) -menu $menubar.$menu.menu -highlightthickness 1
      
      #-highlightthickness 0 -activebackground $dwb_vars(Special,TABBACK) \
      #-menu $menubar.$menu.menu -activeforeground black \
      #-font $font(h,m,r,14) -bd 0 -background grey -relief flat

   return $menubar.$menu.menu
}

# ---------------------------------------------------------
# create menu panel
# ---------------------------------------------------------

proc MkMenu {menu} {
   global dwb_vars font

   menu $menu -tearoff false -font $font(menu) -activeborderwidth 1
   
   #-borderwidth 0 \
   #   -activebackground $dwb_vars(Special,TABBACK) \
   #    -font $font(h,m,r,14) \
   #   -background grey -activeforeground black -relief flat
}

# ---------------------------------------------------------
# create menu command entry
# ---------------------------------------------------------

proc AddMenuCommand {menu text uline {cmd ""}} {

   if {$cmd != ""} {
      $menu add command -label $text -command $cmd
   } else {
      $menu add command -label $text 
   }
}

# ---------------------------------------------------------
# create menu separator
# ---------------------------------------------------------

proc AddMenuSeparator {menu} {

   $menu add separator
}

# ---------------------------------------------------------
# create cascade menu
# ---------------------------------------------------------

proc AddMenuCascade {menu text uline submenu} {

   $menu add cascade -label $text -underline $uline \
      -menu $menu.$submenu

   return $menu.$submenu
}

# ---------------------------------------------------------
# create menu radio entry
# ---------------------------------------------------------

proc AddMenuRadioButton {menu text textw {active 0}} {
   global dwb_vars

   if {$dwb_vars(altticks)} {
   
      set index [$menu index end]
      if {$index == "none"} {set index "-1"}
      set index [expr {$index + 1}]
      
      set cmd "$command; global dwb_vars; set dwb_vars($variable) $value "
      
      lappend dwb_vars(radioMenus) [list $variable $value $index $menu $text]
                   
      if {$cmd != ""} {
         $menu add command -label "$text" \
            -command $cmd
      }

      if {[trace vinfo dwb_vars($variable)] == ""} {
         trace variable dwb_vars($variable) w "updateRadio"
      }
   } else {
      $menu add radio -label $text -value $textw
   }
}


# ---------------------------------------------------------
# create menu check entry
# ---------------------------------------------------------

proc AddMenuCheckButton {menu text uline textw active {cmd ""}} {
   global dwb_vars

   if {$dwb_vars(altticks)} {
      set atick "$dwb_vars(checkTick) "
      set dtick "   "
      set variable "MENU,$textw"
      set value 1
      if {$dwb_vars(MENU,$textw)} {set tick "$atick"} else {set tick "$dtick"}
         
      set index [$menu index end]
      if {$index == "none"} {set index "-1"}
      set index [expr {$index + 1}]
      
      lappend dwb_vars(radioMenus) [list $variable $value $index $menu $text]
      
      set cmd "global dwb_vars; set dwb_vars(MENU,$textw) \[expr ! \$dwb_vars(MENU,$textw)\] ;\
               if {\$dwb_vars(MENU,$textw)} {set tick \"$atick\"} else {set tick \"$dtick\"};\
               $menu entryconfigure $index -label \"\$\{tick\}$text\"; $cmd "
   
      if {$cmd != ""} {
         $menu add command -label "$tick$text" \
            -command $cmd
      }
      if {[trace vinfo dwb_vars($variable)] == ""} {
         trace variable dwb_vars($variable) w "updateRadio"
      }
   } else {
      if {$cmd != ""} {
         $menu add check -label $text -variable dwb_vars(MENU,$textw) \
            -command $cmd -underline $uline
      } else {
         $menu add check -label $text -variable dwb_vars(MENU,$textw) \
            -underline $uline
      }
   }   
}


# ---------------------------------------------------------
# Update "workaround" radio menu entries
# varname : variable that's connected to the Radios
# key : if variable is an array, this speciefies the array slot
# op : Operation (ignored)
# ---------------------------------------------------------
proc updateRadio {varname key op} {
   global dwb_vars $varname
   if {$key != ""} {
      set varname ${varname}($key)
   }
   set atick "$dwb_vars(radioTick) "
   set dtick "   "
   
   set value [subst $$varname]
   foreach radio $dwb_vars(radioMenus) {
      set rvar [lindex $radio 0]
      set rval [lindex $radio 1]
      set rindex [lindex $radio 2]
      set rmenu [lindex $radio 3]
      set rtext [lindex $radio 4]
      
      # tk_messageBox -message "vergleiche rval $rval rvar $rvar mit value $value key $key"
      if {($rvar == $key) && ($rval == $value)} {
         # show tick
         #tk_messageBox -message "show tick $rindex"
         $rmenu entryconfigure $rindex -label "$atick$rtext"
      } elseif {$rvar == $key} {
         # hide tick  
         #tk_messageBox -message "hide tick $rindex"
         $rmenu entryconfigure $rindex -label "$dtick$rtext"
      }
   }
   update
}

