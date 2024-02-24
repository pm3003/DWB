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
# Tcl-Script for wb titles
# ---------------------------------------------------------

proc SelectIntroductionDWB {top} {
   global dwb_vars font

   set textw [$top.titlearea subwidget text]
   $textw config -state normal -background "#c8dcc6"

   set wdth [winfo reqwidth $textw]
   $textw config -tabs [eval "list $wdth center"]

   set writing [tix getimage logo2001b]
   label $textw.lbl -image $writing -background grey97 -borderwidth 0

   #$textw insert end "\n\n\n\t" { header3 }
   #$textw insert end "\nD" { header0 }
   #$textw insert end "EUTSCHES " { header0 }
   #$textw insert end "W" { header0 }
   #$textw insert end "ÖRTERBUCH" { header0 }
   #$textw insert end "\n\nVON\n\n" { header2 }
   #$textw insert end "J" { header1 }
   #$textw insert end "ACOB  UND  " { header2 }
   #$textw insert end "W" { header1 }
   #$textw insert end "ILHELM  " { header2 }
   #$textw insert end "G" { header1 }
   #$textw insert end "RIMM\n" { header2 }
   $textw insert end "\n\t" { header3 }
   $textw window create end -window $textw.lbl -align center
   #$textw insert end "\n\nLEIPZIG\n" { header1 }
   #$textw insert end "VERLAG  " { header1 }
   #$textw insert end "VON" { header2 }
   #$textw insert end "  S. HIRZEL\n" { header1 }
   #$textw insert end "1854 - 1960\n" { header1 }
   $textw config -state disabled
}


proc SelectIntroductionQVZ {top} {
   global dwb_vars font
 
   set textw [$top.titlearea subwidget text]
   $textw config -state normal
 
   set wdth [winfo reqwidth $textw]
   $textw config -tabs [eval "list $wdth center"]

   #set writing [tix getimage dwb3]
   set writing [image create photo -file Graphics/dwb5.gif]
   label $textw.lbl -image $writing -background grey97

   $textw insert end "\n\n\n\t" { header4 }
   $textw window create end -window $textw.lbl -align center

   $textw insert end "\n\n\nHerausgegeben von der Deutschen Akademie" { header4 }
   $textw insert end "\nder Wissenschaften zu Berlin" { header4 }
   $textw insert end "\nin Zusammenarbeit mit der Akademie" { header4 }
   $textw insert end "\nder Wissenschaften zu Göttingen\n\n" { header4 }
   $textw insert end "Quellenverzeichnis" { header2 }
   $textw insert end "\n\nBearbeitet in der Arbeitsstelle Berlin von" { header4 }
   $textw insert end "\nA. Huber, H. Petermann, G. Richter, H. Schmidt," { header4 }
   $textw insert end "\nR. Schmidt, U. Schröter und in der Arbeitsstelle" { header4 }
   $textw insert end "\nGöttingen von U. Horn" { header4 }
   #$textw insert end "G" { header2 }
   #$textw insert end "RIMM\n" { header3 }
   #$textw insert end "\n\n" { header3 }
   #$textw insert end "QUELLENVERZEICHNIS\n\n" { header2 }
   #$textw insert end "\nLEIPZIG\n" { header3 }
   #$textw insert end "VERLAG  " { header3 }
   #$textw insert end "VON" { header3 }
   #$textw insert end "  S. HIRZEL\n" { header3 }
   #$textw insert end "1970\n" { header3 }
 
   $textw config -state disabled
}                                                                                       

