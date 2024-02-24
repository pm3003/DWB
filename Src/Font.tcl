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

# Tcl-Script for fonts
# ---------------------------------------------------------

proc InitFonts {} {
   global font
   
global tcl_platform
if {[string tolower $tcl_platform(os)] == "darwin"} {
    set timesfont "times"
    set arialfont helvetica
    set szmod 3
} else {
    set timesfont "times new roman"
    set arialfont arial
    set szmod 0
}
   
   set font(z,b,i,10) [font create -family $timesfont -size [expr $szmod + 9] -weight bold -slant italic]
   set font(z,b,i,12) [font create -family $timesfont -size [expr $szmod + 11] -weight bold -slant italic]
   set font(z,b,i,14) [font create -family $timesfont -size [expr $szmod + 13] -weight bold -slant italic]
   set font(z,b,i,18) [font create -family $timesfont -size [expr $szmod + 15] -weight bold -slant italic]
   set font(z,b,i,24) [font create -family $timesfont -size [expr $szmod + 20] -weight bold -slant italic]
   set font(z,b,i,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight bold -slant italic]

   set font(z,b,r,10) [font create -family $timesfont -size [expr $szmod + 9] -weight bold -slant roman]
   set font(z,b,r,12) [font create -family $timesfont -size [expr $szmod + 11] -weight bold -slant roman]
   set font(z,b,r,14) [font create -family $timesfont -size [expr $szmod + 13] -weight bold -slant roman]
   set font(z,b,r,18) [font create -family $timesfont -size [expr $szmod + 15] -weight bold -slant roman]
   set font(z,b,r,24) [font create -family $timesfont -size [expr $szmod + 20] -weight bold -slant roman]
   set font(z,b,r,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight bold -slant roman]

   set font(z,m,i,10) [font create -family $timesfont -size [expr $szmod + 9] -weight normal -slant italic]
   set font(z,m,i,12) [font create -family $timesfont -size [expr $szmod + 11] -weight normal -slant italic]
   set font(z,m,i,14) [font create -family $timesfont -size [expr $szmod + 13] -weight normal -slant italic]
   set font(z,m,i,18) [font create -family $timesfont -size [expr $szmod + 15] -weight normal -slant italic]
   set font(z,m,i,24) [font create -family $timesfont -size [expr $szmod + 20] -weight normal -slant italic]
   set font(z,m,i,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight normal -slant italic]

   set font(z,m,r,10) [font create -family $timesfont -size [expr $szmod + 9] -weight normal -slant roman]
   set font(z,m,r,12) [font create -family $timesfont -size [expr $szmod + 11] -weight normal -slant roman]
   set font(z,m,r,14) [font create -family $timesfont -size [expr $szmod + 13] -weight normal -slant roman]
   set font(z,m,r,18) [font create -family $timesfont -size [expr $szmod + 15] -weight normal -slant roman]
   set font(z,m,r,24) [font create -family $timesfont -size [expr $szmod + 20] -weight normal -slant roman]
   set font(z,m,r,28) [font create -family $timesfont -size [expr $szmod + 24] -weight normal -slant roman]
   set font(z,m,r,30) [font create -family $timesfont -size [expr $szmod + 30] -weight normal -slant roman]
   set font(z,m,r,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight normal -slant roman]

   set font(t,b,i,10) [font create -family $timesfont -size [expr $szmod + 9] -weight bold -slant italic]
   set font(t,b,i,12) [font create -family $timesfont -size [expr $szmod + 11] -weight bold -slant italic]
   set font(t,b,i,14) [font create -family $timesfont -size [expr $szmod + 13] -weight bold -slant italic]
   set font(t,b,i,18) [font create -family $timesfont -size [expr $szmod + 15] -weight bold -slant italic]
   set font(t,b,i,24) [font create -family $timesfont -size [expr $szmod + 20] -weight bold -slant italic]
   set font(t,b,i,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight bold -slant italic]

   set font(t,b,r,10) [font create -family $timesfont -size [expr $szmod + 9] -weight bold -slant roman]
   set font(t,b,r,12) [font create -family $timesfont -size [expr $szmod + 11] -weight bold -slant roman]
   set font(t,b,r,14) [font create -family $timesfont -size [expr $szmod + 13] -weight bold -slant roman]
   set font(t,b,r,18) [font create -family $timesfont -size [expr $szmod + 15] -weight bold -slant roman]
   set font(t,b,r,24) [font create -family $timesfont -size [expr $szmod + 20] -weight bold -slant roman]
   set font(t,b,r,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight bold -slant roman]

   set font(t,m,i,10) [font create -family $timesfont -size [expr $szmod + 9] -weight normal -slant italic]
   set font(t,m,i,12) [font create -family $timesfont -size [expr $szmod + 11] -weight normal -slant italic]
   set font(t,m,i,14) [font create -family $timesfont -size [expr $szmod + 13] -weight normal -slant italic]
   set font(t,m,i,18) [font create -family $timesfont -size [expr $szmod + 15] -weight normal -slant italic]
   set font(t,m,i,24) [font create -family $timesfont -size [expr $szmod + 20] -weight normal -slant italic]
   set font(t,m,i,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight normal -slant italic]

   set font(t,m,r,10) [font create -family $timesfont -size [expr $szmod + 9] -weight normal -slant roman]
   set font(t,m,r,12) [font create -family $timesfont -size [expr $szmod + 11] -weight normal -slant roman]
   set font(t,m,r,14) [font create -family $timesfont -size [expr $szmod + 13] -weight normal -slant roman]
   set font(t,m,r,18) [font create -family $timesfont -size [expr $szmod + 15] -weight normal -slant roman]
   set font(t,m,r,24) [font create -family $timesfont -size [expr $szmod + 20] -weight normal -slant roman]
   set font(t,m,r,8)  [font create -family $timesfont -size [expr $szmod + 8] -weight normal -slant roman]

   set font(g,b,i,10) [font create -family greek -size [expr $szmod + 9] -weight bold -slant italic]
   set font(g,b,i,12) [font create -family greek -size [expr $szmod + 12] -weight bold -slant italic]
   set font(g,b,i,14) [font create -family greek -size [expr $szmod + 13] -weight bold -slant italic]
   set font(g,b,i,18) [font create -family greek -size [expr $szmod + 16] -weight bold -slant italic]
   set font(g,b,i,24) [font create -family greek -size [expr $szmod + 20] -weight bold -slant italic]
   set font(g,b,i,8)  [font create -family greek -size [expr $szmod + 8] -weight bold -slant italic]

   set font(g,b,r,10) [font create -family greek -size [expr $szmod + 9] -weight bold -slant roman]
   set font(g,b,r,12) [font create -family greek -size [expr $szmod + 12] -weight bold -slant roman]
   set font(g,b,r,14) [font create -family greek -size [expr $szmod + 13] -weight bold -slant roman]
   set font(g,b,r,18) [font create -family greek -size [expr $szmod + 16] -weight bold -slant roman]
   set font(g,b,r,24) [font create -family greek -size [expr $szmod + 20] -weight bold -slant roman]
   set font(g,b,r,8)  [font create -family greek -size [expr $szmod + 8] -weight bold -slant roman]

   set font(g,m,i,10) [font create -family greek -size [expr $szmod + 9] -weight normal -slant italic]
   set font(g,m,i,12) [font create -family greek -size [expr $szmod + 12] -weight normal -slant italic]
   set font(g,m,i,14) [font create -family greek -size [expr $szmod + 13] -weight normal -slant italic]
   set font(g,m,i,18) [font create -family greek -size [expr $szmod + 16] -weight normal -slant italic]
   set font(g,m,i,24) [font create -family greek -size [expr $szmod + 20] -weight normal -slant italic]
   set font(g,m,i,36) [font create -family greek -size [expr $szmod + 36] -weight normal -slant italic]
   set font(g,m,i,8)  [font create -family greek -size [expr $szmod + 8] -weight normal -slant italic]

   set font(g,m,r,10) [font create -family greek -size [expr $szmod + 9] -weight normal -slant roman]
   set font(g,m,r,12) [font create -family greek -size [expr $szmod + 12] -weight normal -slant roman]
   set font(g,m,r,14) [font create -family greek -size [expr $szmod + 13] -weight normal -slant roman]
   set font(g,m,r,18) [font create -family greek -size [expr $szmod + 16] -weight normal -slant roman]
   set font(g,m,r,24) [font create -family greek -size [expr $szmod + 20] -weight normal -slant roman]
   set font(g,m,r,36) [font create -family greek -size [expr $szmod + 36] -weight normal -slant roman]
   set font(g,m,r,8)  [font create -family greek -size [expr $szmod + 8] -weight normal -slant roman]

   set font(a,b,i,10) [font create -family "sil ezra" -size [expr $szmod + 9] -weight bold -slant italic]
   set font(a,b,i,12) [font create -family "sil ezra" -size [expr $szmod + 12] -weight bold -slant italic]
   set font(a,b,i,14) [font create -family "sil ezra" -size [expr $szmod + 13] -weight bold -slant italic]
   set font(a,b,i,18) [font create -family "sil ezra" -size [expr $szmod + 16] -weight bold -slant italic]
   set font(a,b,i,24) [font create -family "sil ezra" -size [expr $szmod + 20] -weight bold -slant italic]
   set font(a,b,i,8)  [font create -family "sil ezra" -size [expr $szmod + 8] -weight bold -slant italic]

   set font(a,b,r,10) [font create -family "sil ezra" -size [expr $szmod + 9] -weight bold -slant roman]
   set font(a,b,r,12) [font create -family "sil ezra" -size [expr $szmod + 12] -weight bold -slant roman]
   set font(a,b,r,14) [font create -family "sil ezra" -size [expr $szmod + 13] -weight bold -slant roman]
   set font(a,b,r,18) [font create -family "sil ezra" -size [expr $szmod + 16] -weight bold -slant roman]
   set font(a,b,r,24) [font create -family "sil ezra" -size [expr $szmod + 20] -weight bold -slant roman]
   set font(a,b,r,8)  [font create -family "sil ezra" -size [expr $szmod + 8] -weight bold -slant roman]

   set font(a,m,i,10) [font create -family "sil ezra" -size [expr $szmod + 9] -weight normal -slant italic]
   set font(a,m,i,12) [font create -family "sil ezra" -size [expr $szmod + 12] -weight normal -slant italic]
   set font(a,m,i,14) [font create -family "sil ezra" -size [expr $szmod + 13] -weight normal -slant italic]
   set font(a,m,i,18) [font create -family "sil ezra" -size [expr $szmod + 16] -weight normal -slant italic]
   set font(a,m,i,24) [font create -family "sil ezra" -size [expr $szmod + 20] -weight normal -slant italic]
   set font(a,m,i,8)  [font create -family "sil ezra" -size [expr $szmod + 8] -weight normal -slant italic]

   set font(a,m,r,10) [font create -family "sil ezra" -size [expr $szmod + 9] -weight normal -slant roman]
   set font(a,m,r,12) [font create -family "sil ezra" -size [expr $szmod + 12] -weight normal -slant roman]
   set font(a,m,r,14) [font create -family "sil ezra" -size [expr $szmod + 13] -weight normal -slant roman]
   set font(a,m,r,18) [font create -family "sil ezra" -size [expr $szmod + 16] -weight normal -slant roman]
   set font(a,m,r,24) [font create -family "sil ezra" -size [expr $szmod + 20] -weight normal -slant roman]
   set font(a,m,r,8)  [font create -family "sil ezra" -size [expr $szmod + 8] -weight normal -slant roman]

   set font(h,b,i,10) [font create -family $arialfont -size [expr $szmod + 7] -weight bold -slant italic]
   set font(h,b,i,12) [font create -family $arialfont -size [expr $szmod + 9] -weight bold -slant italic]
   set font(h,b,i,14) [font create -family $arialfont -size [expr $szmod + 10] -weight bold -slant italic]
   set font(h,b,i,18) [font create -family $arialfont -size [expr $szmod + 14] -weight bold -slant italic]
   set font(h,b,i,24) [font create -family $arialfont -size [expr $szmod + 18] -weight bold -slant italic]
   set font(h,b,i,8)  [font create -family $arialfont -size [expr $szmod + 6] -weight bold -slant italic]

   set font(h,b,r,10) [font create -family $arialfont -size [expr $szmod + 7] -weight bold -slant roman]
   set font(h,b,r,12) [font create -family $arialfont -size [expr $szmod + 9] -weight bold -slant roman]
   set font(h,b,r,14) [font create -family $arialfont -size [expr $szmod + 10] -weight bold -slant roman]
   set font(h,b,r,18) [font create -family $arialfont -size [expr $szmod + 14] -weight bold -slant roman]
   set font(h,b,r,24) [font create -family $arialfont -size [expr $szmod + 18] -weight bold -slant roman]
   set font(h,b,r,8)  [font create -family $arialfont -size [expr $szmod + 6] -weight bold -slant roman]

   set font(h,m,i,10) [font create -family $arialfont -size [expr $szmod + 7] -weight normal -slant italic]
   set font(h,m,i,12) [font create -family $arialfont -size [expr $szmod + 9] -weight normal -slant italic]
   set font(h,m,i,14) [font create -family $arialfont -size [expr $szmod + 10] -weight normal -slant italic]
   set font(h,m,i,18) [font create -family $arialfont -size [expr $szmod + 14] -weight normal -slant italic]
   set font(h,m,i,24) [font create -family $arialfont -size [expr $szmod + 18] -weight normal -slant italic]
   set font(h,m,i,8)  [font create -family $arialfont -size [expr $szmod + 6] -weight normal -slant italic]

   set font(h,m,r,10) [font create -family $arialfont -size [expr $szmod + 7] -weight normal -slant roman]
   set font(h,m,r,12) [font create -family $arialfont -size [expr $szmod + 9] -weight normal -slant roman]
   set font(h,m,r,14) [font create -family $arialfont -size [expr $szmod + 10] -weight normal -slant roman]
   set font(h,m,r,18) [font create -family $arialfont -size [expr $szmod + 14] -weight normal -slant roman]
   set font(h,m,r,24) [font create -family $arialfont -size [expr $szmod + 18] -weight normal -slant roman]
   set font(h,m,r,8)  [font create -family $arialfont -size [expr $szmod + 6] -weight normal -slant roman]

   set font(f,m,r,10) [font create -family $arialfont -size [expr $szmod + 7] -weight normal -slant roman]
   set font(f,m,r,12) [font create -family $arialfont -size [expr $szmod + 8] -weight normal -slant roman]
   set font(f,m,r,14) [font create -family $arialfont -size [expr $szmod + 10] -weight normal -slant roman]
   set font(f,m,r,18) [font create -family $arialfont -size [expr $szmod + 14] -weight normal -slant roman]
   set font(f,m,r,24) [font create -family $arialfont -size [expr $szmod + 18] -weight normal -slant roman]
   set font(f,m,r,8)  [font create -family $arialfont -size [expr $szmod + 6] -weight normal -slant roman]

   set font(menu) [font create -family $arialfont -size [expr $szmod + 9] -weight normal -slant roman]
}
