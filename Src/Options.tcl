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

# Tcl-Script for option functions
# ---------------------------------------------------------


# ---------------------------------------------------------
# create status area 
# ---------------------------------------------------------

proc SetOptions {{option ""}} {
   global dwb_vars

   for {set w 0} {$w < [llength $dwb_vars(wbname)]} {incr w 2} {
      set wbname [lindex $dwb_vars(wbname) $w]
      if {$wbname == "QVZ" } {
         continue
      }
      for {set i 1} {$i <= $dwb_vars(MAXWBDISPLAY)} {incr i} {
         if {$option == "siglen" || $option == ""} {
            if {$dwb_vars(MENU,siglen)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure au1 -foreground blue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure au2 -foreground blue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure crau2 -foreground blue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure ciau2 -foreground blue
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure crs2 -foreground blue
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure cis2 -foreground blue
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure b1 -foreground blue
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure b2 -foreground blue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure aau -foreground blue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure sec -foreground blue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure asec -foreground blue
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure au1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure au2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure crau2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure ciau2 -foreground black
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure crs2 -foreground black
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure cis2 -foreground black
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure b1 -foreground black
               #$dwb_vars(WBTEXT,$wbname,$i) tag configure b2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure aau -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure sec -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure asec -foreground black
            }
         }
         if {$option == "gram" || $option == ""} {
            if {$dwb_vars(MENU,gram)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure g1 -foreground red
               $dwb_vars(WBTEXT,$wbname,$i) tag configure g2 -foreground red
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure g1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure g2 -foreground black
            }
         }
         if {$option == "sense" || $option == ""} {
            if {$dwb_vars(MENU,sense)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure s1 -foreground darkgreen
               $dwb_vars(WBTEXT,$wbname,$i) tag configure s2 -foreground darkgreen
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure s1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure s2 -foreground black
            }
         }
         if {$option == "belege" || $option == ""} {
            if {$dwb_vars(MENU,belege)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure q1 -foreground maroon
               $dwb_vars(WBTEXT,$wbname,$i) tag configure q2 -foreground maroon
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure q1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure q2 -foreground black
            }
         }
         if {$option == "etym" || $option == ""} {
            if {$dwb_vars(MENU,etym)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure e1 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure e2 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure la1 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure la2 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure gr1 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure gr2 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure laa1 -foreground orange
               $dwb_vars(WBTEXT,$wbname,$i) tag configure laa2 -foreground orange
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure e1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure e2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure la1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure la2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure gr1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure gr2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure laa1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure laa2 -foreground black
            }
         }
         if {$option == "definition" || $option == ""} {
            if {$dwb_vars(MENU,definition)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure d1 -foreground purple
               $dwb_vars(WBTEXT,$wbname,$i) tag configure d2 -foreground purple
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure d1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure d2 -foreground black
            }
         }
         if {$option == "sigrefs" || $option == ""} {
            if {$dwb_vars(MENU,sigrefs)} {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure bir1 -foreground dodgerblue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure bir2 -foreground dodgerblue
               $dwb_vars(WBTEXT,$wbname,$i) tag configure subir2 -foreground dodgerblue
            } else {
               $dwb_vars(WBTEXT,$wbname,$i) tag configure bir1 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure bir2 -foreground black
               $dwb_vars(WBTEXT,$wbname,$i) tag configure subir2 -foreground black
            }
         }
      }
   }
}


proc ToggleIntro {} {
   global dwb_vars
   
   set dwb_vars(MENU,intro) [expr 1-$dwb_vars(MENU,intro)]
}
