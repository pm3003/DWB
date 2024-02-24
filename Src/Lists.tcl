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

#
# Tcl-Script for list operations
# ---------------------------------------------------------


# ---------------------------------------------------------
# merge two sorted tables
# ---------------------------------------------------------

proc MergeResTables {tab1 tab2} {
   global dwb_vars

   
   set table1 result@$tab1
   set table2 result@$tab2

   set n1 [mk::view size RESDB.$table1]
   set n2 [mk::view size RESDB.$table2]
   
   if {$n1 <= $n2} {
      set mintable $table1
      set min $n1
      set maxtable $table2
      set max $n2
   } else {
      set mintable $table2
      set min $n2
      set maxtable $table1
      set max $n1
   }

   set res $dwb_vars(tableNumber)
   incr dwb_vars(tableNumber)
   set restable result@$res
   mk::view layout RESDB.$restable {DATA IDS}
   mk::view size RESDB.$restable 0
   mk::file commit RESDB
   set r 0

   for {set i 0} {$i < $max} {incr i} {
      set vals [mk::get RESDB.$maxtable!$i]
      mk::set RESDB.$restable!$r DATA [lindex $vals 1] IDS [lindex $vals 3]
      incr r
   }
   
   set i 0
   while {$i < $min} {
      set id1 [mk::get RESDB.$mintable!$i IDS]
      set data1 [mk::get RESDB.$mintable!$i DATA]
      set j [binSearch RESDB $maxtable IDS $id1]

      if {$j >= 0} {
         set data2 [mk::get RESDB.$restable!$j DATA]
      	 mk::set RESDB.$restable!$j DATA $data1+$data2
      } else {
      	 mk::set RESDB.$restable!$r DATA $data1 IDS $id1
         incr r
      }
      incr i
   }
   
   return $res
}

# ---------------------------------------------------------
# join two sorted tables
# ---------------------------------------------------------

proc JoinResTables {tab1 tab2 {dist ""} {seq unordered}} {
   #global dwb_vars kwic_list
   global dwb_vars

   if {$dist != ""} {
      set dist [expr abs($dist + 0)]
   }

   set table1 result@$tab1
   set table2 result@$tab2

   set n1 [mk::view size RESDB.$table1]
   set n2 [mk::view size RESDB.$table2]

   if {$n1 <= $n2 || $seq == "ordered"} {
      set mintable $table1
      set min $n1
      set maxtable $table2
      set max $n2
   } else {
      set mintable $table2
      set min $n2
      set maxtable $table1
      set max $n1
   }

   set res $dwb_vars(tableNumber)
   incr dwb_vars(tableNumber)
   set restable result@$res
   mk::view layout RESDB.$restable {DATA IDS}
   mk::view size RESDB.$restable 0
   set r 0
   
   set i 0
   set prevletter ""
   while {$i < $min} {
      set id1 [mk::get RESDB.$mintable!$i IDS]
      set data1 [mk::get RESDB.$mintable!$i DATA]
      set j [binSearch RESDB $maxtable IDS $id1]
      
      #puts "MIN=$min, I=$i, ID1=$id1, J=$j"
      
      if {$j >= 0} {
         set data2 [mk::get RESDB.$maxtable!$j DATA]
      	 if {$dist == ""} {
      	    #puts "mk::set RESDB.$restable!$r DATA $data1+$data2 IDS $id1"
      	    mk::set RESDB.$restable!$r DATA $data1+$data2 IDS $id1
            incr r
      	 } else {
            #****
            set match 0
            set ldata ""  
            foreach dx [split $data1 "+"] {
               foreach d1 [split $dx "-"] {
                  set letter1 [string range $d1 0 0]
                  #puts "L1=$letter1, PL=$prevletter"
                  if {$letter1 != $prevletter} {
                     if {$prevletter != ""} {
                        #tk_messageBox -message "CLOSE $prevletter"
                        mk::file close DB$prevletter
                     }
                     #tk_messageBox -message "OPEN $letter1"
                     mk::file open DB$letter1 $dwb_vars(driveletterDB)/Data/DWB/DWB$letter1.CDAT -readonly
                  }
                  set ip1 [string range $d1 1 end]
                  foreach dy [split $data2 "+"] {
                     foreach d2 [split $dy "-"] {
                        set letter2 [string range $d2 0 0]
                        if {$letter2 != $letter1} {
                           #tk_messageBox -message "OPEN2 $letter2"
                           mk::file open DB$letter2 $dwb_vars(driveletterDB)/Data/DWB/DWB$letter2.CDAT -readonly
                        }
                        set ip2 [string range $d2 1 end]
            
                        set cridx1 [expr $ip1/1000]
                        set iridx1 [expr $ip1%1000]
                        if {![info exists kwic_list(pos,$letter1,$cridx1)]} {
                           set kwic_list(pos,$letter1,$cridx1) [inflate [mk::get DB$letter1.TEXT!$cridx1 POS:B]]
                        }
                        set pos1 [lindex $kwic_list(pos,$letter1,$cridx1) $iridx1]

                        set cridx2 [expr $ip2/1000]
                        set iridx2 [expr $ip2%1000]
                        if {![info exists kwic_list(pos,$letter2,$cridx2)]} {
                           set kwic_list(pos,$letter2,$cridx2) [inflate [mk::get DB$letter2.TEXT!$cridx2 POS:B]]
                        }
                        set pos2 [lindex $kwic_list(pos,$letter2,$cridx2) $iridx2]
             
                        if {($seq == "unordered" && [expr {abs($pos1-$pos2)}] <= $dist && [expr {abs($pos1-$pos2)}] > 0) || 
                            ($seq == "ordered" && [expr {$pos2-$pos1}] <= $dist && [expr $pos2-$pos1] > 0)} {
                           #puts "LDATA=|$ldata|, DATA1=$data1 ($pos1), DATA2=$data2 ($pos2)"
                           lappend ldata "$dx-$dy"
                           set match 1
                        }
                        if {$letter2 != $letter1} {
                           #tk_messageBox -message "CLOSE2 $letter2"
                           mk::file close DB$letter2
                        }
                     }
                  }
                  set prevletter $letter1
               }
            }
            if {$match} {
               set data [join $ldata "+"]
      	       puts "mk::set RESDB.$restable!$r DATA $data IDS $id1"
      	       mk::set RESDB.$restable!$r DATA $data IDS $id1
               incr r
            } 
      	 }
      }
      incr i
   }
   if {$prevletter != ""} {
      #tk_messageBox -message "CLOSE $prevletter"
      mk::file close DB$prevletter
   }
   mk::file commit RESDB
   #puts "RETURNING: $res"
   
   return $res
}


# ---------------------------------------------------------
# subtract two sorted tables
# ---------------------------------------------------------

proc SubResTables {tab1 tab2} {
   global dwb_vars resList

   set table1 result@$tab1
   set table2 result@$tab2

   set n1 [mk::view size RESDB.$table1]
   set n2 [mk::view size RESDB.$table2]

   set res $dwb_vars(tableNumber)
   incr dwb_vars(tableNumber)
   set restable result@$res
   mk::view layout RESDB.$restable {DATA IDS}
   mk::view size RESDB.$restable 0
   set r 0
   
   set i 0
   while {$i < $n1} {
      set id1 [mk::get RESDB.$table1!$i IDS]
      set j [binSearch RESDB $table2 IDS $id1]

      if {$j < 0} {
         set data1 [mk::get RESDB.$table1!$i DATA]
      	 mk::set RESDB.$restable!$r DATA $data1 IDS $id1
         incr r
      }
      incr i
   }

   return $res
}


# ---------------------------------------------------------
# move element at position pos to the end of the list
# ---------------------------------------------------------

proc MoveToEnd {l1 elpos el} {

   set l2 [lreplace $l1 $elpos $elpos]
   set l2 [lappend l2 $el]

   return $l2
}
