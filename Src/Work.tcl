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
# create workarea
# ---------------------------------------------------------

proc MkWorkArea {top} {

   # set w [frame $top.workarea -bd 2 -relief sunken  #    \
      -background brown]

   set w [canvas $top.workarea -background darkslategrey]

   set bgimg [tix getimage hsa]
   set bgimg_w [image width $bgimg]
   set bgimg_h [image height $bgimg]

   for {set i 0} {$i < 9} {incr i} {
      for {set j 0} {$j < 6} {incr j} {
         $w create image [expr $bgimg_w*$i] [expr $bgimg_h*$j] \
            -image $bgimg -anchor nw
      }
   }


   return $w
}

