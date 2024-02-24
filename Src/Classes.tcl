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

# =========================================================
# uppercase letters
# =========================================================

set dwb_vars(uppercase) [eval "list A B C D E F G H I J K L M \
                          N O P Q R S T U V W X Y Z \
                          Ä Ë Ö Ü Â Ô Û Ê Î À È Ì Ò \
                          Ù Á É Í Ó Ú Ý Æ \
                          [format "%c" 191] \
                          [format "%c" 140]" \
                        ]

# =========================================================
# lowercase letters
# =========================================================

set dwb_vars(lowercase) [eval "list a b c d e f g h i j k l m \
                          n o p q r s t u v w x y z \
                          ä ë ö ü â ô û ê î à è ì ò \
                          ù á é í ó ú ý æ \
                          [format "%c" 172] \
                          [format "%c" 156]" \
                        ]

# =========================================================
# convert diacritics
# =========================================================

proc ConvertToUppercase {text} {
   global dwb_vars

   set utext ""
   for {set i 0} {$i < [string length $text]} {incr i} {
      set letter [string range $text $i $i]
      set lcpos [lsearch -exact $dwb_vars(lowercase) "$letter"]
      if {$lcpos >= 0} {
         set utext "$utext[lindex $dwb_vars(uppercase) $lcpos]"
      } else {
         set utext "$utext$letter"
      }
   }
   return $utext
}

proc ConvertToLowercase {text} {
   global dwb_vars

   set ltext ""
   for {set i 0} {$i < [string length $text]} {incr i} {
      set letter [string range $text $i $i]
      set ucpos [lsearch -exact $dwb_vars(uppercase) "$letter"]
      if {$ucpos >= 0} {
         set ltext "$ltext[lindex $dwb_vars(lowercase) $ucpos]"
      } else {
         set ltext "$ltext$letter"
      }
   }
   return $ltext
}

# =========================================================
# special characters
# =========================================================

set dwb_vars(upperspecial) [eval "list Ë Â Ô Û Ê Î À È Ì Ò \
                             Ù Á É Í Ó Ú Ý Æ \
                             Ä Ö Ü \
                             [format "%c" 191] \
                             [format "%c" 140]" \
                           ]

set dwb_vars(lowerspecial) [eval "list ë â ô û ê î à è ì ò \
                             ù á é í ó ú ý æ \
                             ä ö ü \
                             [format "%c" 172] \
                             [format "%c" 156]" \
                           ]

set dwb_vars(specialchars) [eval "list Ë Â Ô Û Ê Î À È Ì Ò \
                             Ù Á É Í Ó Ú Ý Æ \
                             [format "%c" 191] \
                             [format "%c" 140] \
                             ë â ô û ê î à è ì ò \
                             ù á é í ó ú ý æ Ä Ö Ü ä ö ü \
                             [format "%c" 172] \
                             [format "%c" 156] \
                             ß - \
                             [format "%c" 160]" \
                           ]

set dwb_vars(normedchars) { E A O U E I A E I O \
                            U A E I O U Y AE \
                            Z \
                            OE \
                            e a o u e i a e i o \
                            u a e i o u y ae AE OE UE ae oe ue \
                            z \
                            oe \
                            sz "" \
                            "" \
                          }

# =========================================================
# normalize word for index
# =========================================================

proc NormalizeWord {text} {
   global dwb_vars

   set ntext ""
   for {set i 0} {$i < [string length $text]} {incr i} {
      set letter [string range $text $i $i]
      set scpos [lsearch -exact $dwb_vars(specialchars) "$letter"]
      if {$scpos >= 0} {
         set ntext "$ntext[lindex $dwb_vars(normedchars) $scpos]"
      } else {
         set ntext "$ntext$letter"
      }
   }
   return $ntext
}

# =========================================================
# insert alternating brackets for special characters
# =========================================================

proc AlternateDiacs {text} {
   global dwb_vars

   set ntext ""
   for {set i 0} {$i < [string length $text]} {incr i} {
      set letter [string range $text $i $i]
      set scpos [lsearch -exact $dwb_vars(upperspecial) "$letter"]
      if {$scpos >= 0} {
         set ntext "$ntext\[$letter[lindex $dwb_vars(lowerspecial) $scpos]\]"
      } else {
         set scpos [lsearch -exact $dwb_vars(lowerspecial) "$letter"]
         if {$scpos >= 0} {
            set ntext "$ntext\[[lindex $dwb_vars(upperspecial) $scpos]$letter\]"
         } else {
            set ntext "$ntext$letter"
         }
      }
   }
   return $ntext
}

# =========================================================
# invert word for index
# =========================================================

proc InvertWord {text} {

   set ntext ""
   for {set i [expr [string length $text] - 1]} {$i >= 0} {incr i -1} {
      set letter [string range $text $i $i]
      set ntext "$ntext$letter"
   }
   return $ntext
}

# =========================================================
# generate temporary filename
# =========================================================

proc getTempFilename {} {
   global dwb_vars

   set n [format "%08d" $dwb_vars(tmpFileNumber)]
   set filename "System/_tmp$n"
   incr dwb_vars(tmpFileNumber)

   return $filename
}

# =========================================================
# generate temporary tablename
# =========================================================

proc getTempTablename {suffix} {
   global dwb_vars

   set n [format "%08d" $dwb_vars(tmpTableNumber)]
   set tablename "_tab$n$suffix"
   incr dwb_vars(tmpTableNumber)

   return $tablename
}

proc SubsChars {text} {
       global tcl_platform
       if {[string tolower $tcl_platform(os)] == "darwin"} {
           # small latin letter ezh
           regsub -all "u10f3" $text "u0292" text
           # e with grave
           regsub -all "u0065\\\\u0300" $text "u00e8" text
           # e with acute
           regsub -all "u0065\\\\u0301" $text "u00e9" text
           # greek e with acute
           regsub -all "u0065\\\\u0315" $text "u2014" text
           # greek e with acute and REVERSED COMMA ABOVE
           regsub -all "u0065\\\\u0314\\\\u0301" $text "u203a" text
           # greek e with reversed comma above 
           regsub -all "u0065\\\\u0314" $text "u0161" text           
           # greek w with tilde and YPOGEGRAMMENI
           regsub -all "u0077\\\\u0345\\\\u0303" $text "u0152" text
           # greek e with comma above and acute
           regsub -all "u0065\\\\u0343\\\\u0301" $text "u203a" text
           # remove combining dot below
           regsub -all "\\\\u0323" $text "" text
           # remove COMBINING RIGHT HALF RING ABOVE
           regsub -all "\\\\u0357" $text "" text           
       }
       return $text
}

proc SubsSpecialChars {text} {
   regsub -all "u10f3" $text "u007a" text
   regsub -all "u0314" $text "u0065" text
   regsub -all "u0313" $text "u0301" text
   regsub -all "u0065\\\\u0343\\\\u0301" $text "u0065" text
   regsub -all "u0065\\\\u0343\\\\u0300" $text "u0065" text
   regsub -all "u0065\\\\u0314\\\\u0300" $text "u0065" text
   regsub -all "u0065\\\\u0314\\\\u0301" $text "u0065" text
   regsub -all "u0065\\\\u0314" $text "u0065" text
   regsub -all "u0065\\\\u0315" $text "u0065" text
   regsub -all "u0065\\\\u0300" $text "u0065" text
   regsub -all "u0065\\\\u0301" $text "u0065" text
   regsub -all "\\\\u0306" $text "" text
   regsub -all "\\\\u0351" $text "" text

   return $text       
}