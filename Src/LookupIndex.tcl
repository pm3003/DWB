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
# find matching entry
# ---------------------------------------------------------

proc findEntry {mode sensecase idxname key {type ""}} {

   if {$sensecase == "nocase" && $type != ":I"} {
      set key [ConvertToUppercase $key]
   }

   set low 0
   set high [expr [mk::view size $idxname] - 1]
   set next [expr {int(ceil(($low+$high)/2.0))}]
   set vkey [mk::get $idxname!$next KEY$type]
   if {$sensecase == "nocase" && $type != ":I"} {
      set vkey [ConvertToUppercase $vkey]]
   }

   while {$key != $vkey && $low < $high} {
      #puts "LOW=$low, HIGH=$high, NEXT=$next, KEY=$key, VKEY=$vkey"
      if {$key < $vkey} {
         set high [expr {$next-1}]
      } else {
         set low [expr {$next+1}]
      }

      set next [expr {int(ceil(($low+$high)/2.0))}]
      if {$next <= $high} {
         set vkey [mk::get $idxname!$next KEY$type]
         if {$sensecase == "nocase" && $type != ":I"} {
            set vkey [ConvertToUppercase $vkey]
         }
      }
   }
   #puts "mode=$mode, LOW=$low, HIGH=$high, NEXT=$next, KEY=$key, VKEY=$vkey"
   if {$mode == "exact"} {
      if {$vkey == $key} {
         return $next
      }
      return -1
   }
   if {$mode == "next"} {
      if {$vkey == $key} {
         return $next
      } elseif {$next < [expr [mk::view size $idxname] - 1]} {
         return [expr {$next+1}]
      } else {
         return -1
      }
   }
   if {$mode == "first"} {
      set low 0
      set high [expr [mk::view size $idxname] - 2]
      if {$high < 0} {
         set high 0
      }
      if {$next <= $high} {
         set high [expr $next+1]
      }
   }
   if {$mode == "last"} {
      set low $next
      set high [expr [mk::view size $idxname] - 1]
   }
   set next [expr {int(ceil(($low+$high)/2.0))}]
   if {$next >= [mk::view size $idxname]} {
      set next [expr [mk::view size $idxname] - 1]
   }
   set vkey [mk::get $idxname!$next KEY$type]
   if {$sensecase == "nocase" && $type != ":I"} {
      set vkey [ConvertToUppercase $vkey]
   }

   while {$low < $high} {
      #puts "2: LOW=$low, HIGH=$high, NEXT=$next, KEY=$key, VKEY=$vkey"
      if {$mode == "first"} {
         if {$vkey < $key} {
            set low [expr {$next+1}]
         } else {
            set high [expr {$next-1}]
         }
      }
      if {$mode == "last"} {
         if {$vkey > $key} {
            set high [expr {$next-1}]
         } else {
            set low [expr {$next+1}]
         }
      }

      if {[expr {int(ceil(($low+$high)/2.0))}] <= $high} {
         set next [expr {int(ceil(($low+$high)/2.0))}]
         set vkey [mk::get $idxname!$next KEY$type]
         if {$sensecase == "nocase" && $type != ":I"} {
            set vkey [ConvertToUppercase $vkey]
         }
      }
   }
   #puts "3: LOW=$low, HIGH=$high, NEXT=$next, KEY=$key, VKEY=$vkey"
   if {$mode == "first"} {
      if {$vkey >= $key} {
         return $next
      } elseif {$next < [expr [mk::view size $idxname] - 1]} {
         return [expr {$next+1}]
      }
   }
   if {$mode == "last"} {
      if {$vkey <= $key} {
         return $next
      } elseif {$next > 1} {
         return [expr {$next-1}]
      }
   }

   return -1
}


# ---------------------------------------------------------
# perform query in index
# ---------------------------------------------------------

proc performQuery {DB table query {mode "memory"} {limit 0}} {

   set idrxp "(\[a-zA-Z0-9,:\]*)"
   set oprxp "(><|<=|>=|==|<|>)"

   if {[regexp "$idrxp$oprxp$idrxp" $query tmp ctype op key] == 0} {
      return ""
   }

   set column [lindex [split $ctype ":"] 0]
   set keytype "[lindex [split $ctype ":"] 1]"
   if {$keytype != ""} {
      set keytype ":$keytype"
   }

   set idxname [format "%s.%s%sIDX" $DB $table $column]

   if {$op == "><"} {
      set keymax [lindex [split $key ":"] 1]
      set key [lindex [split $key ":"] 0]
      set v [findEntry first case $idxname $key $keytype]
   } elseif {$op == "=="} {
      set v [findEntry first case $idxname $key $keytype]
   } elseif {$op == ">=" || $op == ">"} {
      set v [findEntry first case $idxname $key $keytype]
   } else {
      set v [findEntry last case $idxname $key $keytype]
   }

   if {$v == -1} {
      return ""
   }

   if {$mode == "file"} {
      set tmptable [getTempTablename ""]
      mk::view layout RESDB.$tmptable { DATA }
      mk::view size RESDB.$tmptable 0
   } else {
      set res {}
   }

   set size [mk::view size $idxname]
   set i 0
   while {$v >= 0 && $v < $size} {
      set data [split [eval mk::get $idxname!$v DATA] ","]
      set vkey [eval mk::get $idxname!$v KEY$keytype]

      if {$op == ">" && $vkey > $key} {
         if {$mode == "file"} {
            mk::set RESDB.$tmptable!$i DATA $data
         } else {
            set res [concat $res $data]
         }
         incr i
      } elseif {$op == "<" && $vkey < $key} {
         if {$mode == "file"} {
            mk::set RESDB.$tmptable!$i DATA $data
         } else {
            set res [concat $res $data]
         }
         incr i
      } elseif {$op == ">=" && $vkey >= $key} {
         if {$mode == "file"} {
            mk::set RESDB.$tmptable!$i DATA $data
         } else {
            set res [concat $res $data]
         }
         incr i
      } elseif {$op == "<=" && $vkey <= $key} {
         if {$mode == "file"} {
            mk::set RESDB.$tmptable!$i DATA $data
         } else {
            set res [concat $res $data]
         }
         incr i
      } elseif {$op == "><" && $vkey >= $key && $vkey <= $keymax} {
         if {$mode == "file"} {
            mk::set RESDB.$tmptable!$i DATA $data
         } else {
            set res [concat $res $data]
         }
         incr i
      } elseif {$op == "==" && $vkey == $key} {
         if {$mode == "file"} {
            mk::set RESDB.$tmptable!$i DATA $data
         } else {
            set res [concat $res $data]
         }
         incr i
      }
      if {$op == "==" && $vkey != $key} {
         break
      }
      if {$limit && $i > $limit} {
         break
      }
      if {$op == "==" || $op == ">=" || $op == ">" || $op == "><"} {
         incr v
      } else {
         incr v -1
      }
   }

   if {$mode == "file"} {
      return $tmptable
   }

   return $res
}


# ---------------------------------------------------------
# perform regexp query in index
# ---------------------------------------------------------

proc performLikeQuery {DB table query sensecase {limit 0}} {
   global dwb_vars

   set column [lindex [split $query "="] 0]
   set key [lindex [split $query "="] 1]

   if {$sensecase == "nocase"} {
      set key [ConvertToUppercase $key]
   }
   set mainkey [lindex [split $key ":"] 0]
   set subkey [lindex [split $key ":"] 1]

   set idxname [format "%s.%s%sIDX" $DB $table $column]
   set pkey [lindex [split $mainkey "*?\[\(\)\]"] 0]
   set p [string length $pkey]

   update
   set res {}
   if {$p > 0} {
      set v [findEntry first $sensecase $idxname $pkey]
      if {$v < 0} {
         return $res
      }
      set element [eval mk::get $idxname!$v KEY]
      set mode "normal"
   } else {
      set idxname [format "%s.%s%sINVIDX" $DB $table $column]
      set pkey [lindex [split [InvertWord $mainkey] "*?\[\(\)\]"] 0]
      set p [string length $pkey]
      set v [findEntry first $sensecase $idxname $pkey]
      if {$v < 0} {
         return $res
      }
      set key "[InvertWord $mainkey]"
      set mode "inverted"
   }

   set size [mk::view size $idxname]
   while {$v >= 0 && $v < $size} {
      set element [eval mk::get $idxname!$v KEY]
      if {$sensecase == "nocase"} {
         set element [ConvertToUppercase $element]
      }
      if {[string match $key $element]} {
         set data [split [eval mk::get $idxname!$v DATA] ","]
         if {$mode == "inverted"} {
            foreach d $data {
               set nidxname [format "%s.%s%sIDX" $DB $table $column]
               set ndata [split [eval mk::get $nidxname!$d DATA] ","]
               set res [concat $res $ndata]
            }
         } else {
            set res [concat $res $data]
         }
      }
      if {[string range $element 0 [expr {$p-1}]] > $pkey} {
         break
      }
      if {$limit > 0 && [llength $res] >= $limit} {
         break
      }
      incr v
   }
   return $res
}


# ---------------------------------------------------------
# perform several and-combined queries
# ---------------------------------------------------------

proc performAndQuery {DB table query {mode "memory"}} {

   set res {all}

   foreach q $query {
      set res [JoinListsSimple $res [performQuery $DB $table $q $mode]]
   }

   return $res
}


# ---------------------------------------------------------
# perform regexp query in index
# ---------------------------------------------------------

proc performWordQuery {DB query sensecase normsearch class {limit 0}} {
   global dwb_vars
   
   set column [lindex [split $query "="] 0]
   set key [lindex [split $query "="] 1]
   set keyword $key

   set idxname $DB.${column}IDX
   if {[mk::view size $idxname] == 0} {
      return ""
   }

   set s1 [string first "*" $key]
   set s2 [string first "?" $key]
   set minidx $s1
   if {$s2 >= 0 && ($s2 < $minidx || $minidx < 0)} {
      set minidx $s2
   }
   if {$minidx != 0} {
      set key "@$key"
   } else {
      #set key "[string range $key [expr $minidx+1] end]@[string range $key 0 $minidx]"
      set key "\#[InvertWord $key]"
   }

   set keytail ""
   if {!$sensecase} {
      set key "[ConvertToLowercase $key]"
      #set keytail "_"
   }
   if {$normsearch} {
      set key "[NormalizeWord $key]"
      #set keytail "_"
   }
   set key "$key$keytail"
   set pkey [lindex [split $key "*?\[\(\)\]"] 0]
   set plg [string length $pkey]

   set res {}
   set v -1
   if {$plg > 0} {
      set low 0
      set high [expr [mk::view size $idxname] - 1]
      set next [expr {int(floor(($low+$high)/2.0))}]
      set vkey [mk::get $idxname!$next KEY]

      while {$pkey != $vkey && $low < $high} {
         if {$key < $vkey} {
            set high [expr {$next-1}]
         } else {
            set low [expr {$next+1}]
         }
         if {$low < 0 || $high < 0} {
            return ""
         }

         set next [expr {int(floor(($low+$high)/2.0))}]
         if {$next <= $high} {
            set vkey [mk::get $idxname!$next KEY]
         }
         if {!$dwb_vars(execQuery)} {
            return ""
         }
      }

      set v $next
      #set v [findEntry first $sensecase $idxname $pkey]
      if {$v < 0} {
         return $res
      }
      set element [eval mk::get $idxname!$v KEY]
      set mode "normal"
   }

   set nmatches 0
   set vmatches 0
   set tmatches 0
   set limit 10000
   set size [mk::view size $idxname]
   while {$v >= 0 && $v < $size} {
      set tagid [eval mk::get $idxname!$v TAGID:I]
      set element [eval mk::get $idxname!$v KEY]
      if {[expr {$tagid&$class}] != 0} {
         set matches [eval mk::get $idxname!$v N:I]
         if {[string match $key $element]} {
            incr vmatches
            set xp [string first "@" $element]
            if {$xp > 0} {
               set fp [string range $element 0 [expr $xp-1]]
               set sp [string range $element $xp end]
               set element "$sp$fp"
            }
            lappend res "$element+$matches+$v"
            incr nmatches
            incr tmatches $matches
            if {$vmatches > 1 && $tmatches > $limit} {
               set choice [tk_messageBox -type yesno -default yes -icon question \
                  -message "Die Suche nach \"[string range $key 1 end]\" lieferte bereits $tmatches mögliche Treffer.\nSoll die Suche fortgesetzt werden?"]
               if {$choice == "no"} {   
                  return $res
               }
               incr limit 10000
            }
         } else {
            if {([string range $element 0 [expr {$plg-1}]] > $pkey) || \
                ($minidx < 0 && $element > $pkey)} {
               break
            }
         }
         if {$limit > 0 && [llength $res] >= $limit} {
            break
         }
      }         
      incr v
      if {!$dwb_vars(execQuery)} {
         return ""
      }
   }
   return $res
}


proc binSearch {DB table column key {type ""}} {

   set low 0
   set high [expr [mk::view size $DB.$table] - 1]
   if {$high < 0} {
      return -1
   }
   set next [expr {int(ceil(($low+$high)/2.0))}]
   set vkey [mk::get $DB.$table!$next $column$type]

   while {$key != $vkey && $low < $high} {
      if {$key < $vkey} {
         set high [expr {$next-1}]
      } else {
         set low [expr {$next+1}]
      }

      set next [expr {int(ceil(($low+$high)/2.0))}]
      if {$next <= $high} {
         set vkey [mk::get $DB.$table!$next $column$type]
      }
   }
   if {$vkey == $key} {
      return $next
   }

   return -1
}