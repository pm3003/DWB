# =========================================================
#     DEUTSCHES W�RTERBUCH VON JACOB UND WILHELM GRIMM
#                        
#   ENTWICKELT IM FACH GERMANISTIK DER UNIVERSIT�T TRIER
#                IN ZUSAMMENARBEIT MIT DEM
#  KOMPETENZZENTRUM F�R ELEKTRONISCHE ERSCHLIESSUNGS- UND
#    PUBLIKATIONSVERFAHREN IN DEN GEISTESWISSENSCHAFTEN
# ---------------------------------------------------------
#                     BEARBEITET VON
#     HANS-WERNER BARTZ, THOMAS BURCH, RUTH CHRISTMANN,
#      KURT G�RTNER, VERA HILDENBRANDT, THOMAS SCHARES
#
#        COPYRIGHT (C) 1998, 1999, 2000, 2001, 2002
# BY KOMPETENZZENTRUM F�R ELEKTRONISCHE ERSCHLIESSUNGS- UND
#    PUBLIKATIONSVERFAHREN IN DEN GEISTESWISSENSCHAFTEN
#                 AN DER UNIVERSIT�T TRIER
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


proc performHTTPQuery {dbname table query} {
   global dwb_vars

   set result {}
   set url "$dwb_vars(wbServer)/cgi-bin/queryMhdWB.tcl?$dbname+$table+$query"
   set token [::http::geturl $url]
   upvar #0 $token state 
   if {$state(status) == "ok"} {
      set result $state(body)
   }

   return $result
}

proc performHTTPLikeQuery {dbname table query sensecase limit} {
   global dwb_vars

   set result {}
   set url "$dwb_vars(wbServer)/cgi-bin/likequeryMhdWB.tcl?$dbname+$table+$query+$sensecase+$limit"
   set token [::http::geturl $url]
   upvar #0 $token state 
   if {$state(status) == "ok"} {
      set result $state(body)
   }

   return $result
}

proc HTTPget {dbname table index column} {
   global dwb_vars

   set result ""
   set url "$dwb_vars(wbServer)/cgi-bin/getMhdWB.tcl?$dbname+$table+$index+$column"
   set token [::http::geturl $url]
   upvar #0 $token state 
   if {$state(status) == "ok"} {
      set result $state(body)
   }

   return $result
}

proc HTTPview {cmd dbname table} {
   global dwb_vars

   set result ""
   set url "$dwb_vars(wbServer)/cgi-bin/viewMhdWB.tcl?$cmd+$dbname+$table"
   set token [::http::geturl $url]
   upvar #0 $token state 
   if {$state(status) == "ok"} {
      set result $state(body)
   }

   return $result
}

