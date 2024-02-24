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

# Tcl-Script for global variables and defines
# ---------------------------------------------------------

proc InitGlobals {} {
   global dwb_vars wbi wbr wbm
   
   set dwb_vars(htmlexportdir) "./Export"
   set dwb_vars(QUERY,CPHELP) ""
   set dwb_vars(wbServer) "http://gaer27.uni-trier.de"
   set dwb_vars(VersionNumber) "12-04"

   set wbi(G) [tix getimage gdoc]
   set wbi(0) [tix getimage xdoc]

   set wbr(G) [tix getimage 115]
   set wbr(0) [tix getimage 199]

   set wbr(exparticle) [tix getimage smallright]
   set wbr(srkarticle) [tix getimage smallleft]
   set wbr(colbreak)   [tix getimage smalldown]
   set wbr(empty)      [tix getimage none]

   set wbm(G) "Artikel im DWB"
   set wbm(Q) "Verweis im Quellenverzeichnis"
   set wbm(0) "inaktiver Verweis"

   set wbm(exparticle) "Abschnitt ergänzen"
   set wbm(srkarticle) "Abschnitt reduzieren"

   set dwb_vars(NEXTTEXTWID) 1
   set dwb_vars(ACTIVETEXTWID) 0

   set dwb_vars(WBSECTIONS) { A B C D E F G H I J K L M N O P Q R  \
      S T U V W X Y Z  }
   set dwb_vars(WBSECTIONS4SRCH) { A B C D E F }
   set dwb_vars(DRIVELETTERS) { C D E F G H I J K L M N O }
   set dwb_vars(openSections) ""
   set dwb_vars(QVZopenSections) ""

   set dwb_vars(ARTICLEIMAGE,DWB) [tix getimage gdoc]
   set dwb_vars(IMAGES,selected) [tix getimage orsymb]

   set dwb_vars(SECTIONSIZE,DWB)  12
   set dwb_vars(SECTIONSIZE,QVZ)  100

   set dwb_vars(SIGLEAREA) ""
   set dwb_vars(MAXWBDISPLAY) 1
   set dwb_vars(tmpFileNumber) 1
   set dwb_vars(tmpTableNumber) 1
   set dwb_vars(tableNumber) 0
   set dwb_vars(QUERY,HITPOS) ""
   set dwb_vars(QUERY,NOTEXECUTED) "(nicht ausgeführt)"
   set dwb_vars(QUERY,totalhits) $dwb_vars(QUERY,NOTEXECUTED)
   set dwb_vars(ALLOWEDQUERYCHARS) "abcdefghijklmnopqrstuvwxyzäöüßABCDEFGHIJKLMNOPQRSTUVWXYZÄÖÜ0123456789| &!*?\[\]()\"<="
   set dwb_vars(ALLOWEDSECNCHARS) "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-;"
   set dwb_vars(ALLOWEDYEARCHARS) "0123456789-;"
   
   set dwb_vars(wbname) { DWB G QVZ Q }
   set dwb_vars(wbtitle,DWB) "DEUTSCHES WÖRTERBUCH VON JACOB UND WILHELM GRIMM"
   set dwb_vars(wbtitle,QVZ) "QUELLENVERZEICHNIS"
   set dwb_vars(BOOKINFO) { 1 normal 2 normal 3 normal 4 normal 5 normal 6 normal \
      7 normal 8 normal 9 normal 10 normal 11 normal 12 normal 13 normal 14 normal \
      15 normal 16 normal 17 normal 18 normal 19 normal 20 normal 21 normal \
      22 normal 23 normal 24 normal 25 normal 26 normal 27 normal 28 normal \
      29 normal 30 normal 31 normal 32 normal }
   
   set dwb_vars(textTypes) { au2 b1 b2 bir1 bir2 da2 g1 l1 l2 s1 s2 sgr2 sn2 t1 v1 v2 }

   set dwb_vars(tableDesc,LEMMA) "den Stichwörtern"
   set dwb_vars(tableDesc,GRAM) "den grammatischen Angaben"
   set dwb_vars(tableDesc,SIGLE) "den Siglen"
   set dwb_vars(tableDesc,SIGLEREF) "den Stellenangaben"
   set dwb_vars(tableDesc,BELEG) "den Verszitaten"
   set dwb_vars(tableDesc,ETYM) "den etymologischen Abschnitten"
   set dwb_vars(tableDesc,DEF) "den Bedeutungserläuterungen"
   set dwb_vars(tableDesc,REST) "allen übrigen Abschnitten"
   set dwb_vars(tableDesc,ALL) "allen übrigen Abschnitten"

   #content of notes textwindow
   set dwb_vars(NOTESWINDOWTEXT) ""
   
   set dwb_vars(altticks) 1;
   set dwb_vars(checkTick) "*";
   set dwb_vars(radioTick) "*";
   set dwb_vars(ACTIVETEXT) {};


#----------------------------------------------------------------
# Datenpfade
#----------------------------------------------------------------

   set dwb_vars(PREFDIR) "Texte/Vorworte/DWB"

   set dwb_vars(DWB,DATA) "Data/DWB/DWB.DAT"
   set dwb_vars(DWB,INDEX) "Data/DWB/DWB.IDX"
   set dwb_vars(QVZ,DATA) "Data/Quellen/QVZ.DAT"
   set dwb_vars(QVZ,INDEX) "Data/Quellen/QVZ.IDX"
   set dwb_vars(DWB,LEXICON) "Data/DWB/LEXICON.IDX"
   set dwb_vars(QVZ,LEXICON) "Data/QVZ/LEXICON.IDX"
   set dwb_vars(DWB,ADATA) "Data/DWB/DWBA.CDAT"
   set dwb_vars(DWB,LEXICONDATA) "Data/DWB/datafile.tab"

   set dwb_vars(RESDB,DATA) "System/RESULTS[pid].DAT"
   #set dwb_vars(RESDB,DATA) "c:/temp/RESULTS[pid].DAT"

   #table for notes and bookmarks:
   set dwb_vars(DWB,USER) "System/USER.DAT"

   set dwb_vars(ACROREAD,PATH) ""

#----------------------------------------------------------------
# Variablen für Farbeinstellungen
#----------------------------------------------------------------

   set dwb_vars(DWB,TABFORE,normal) black
   set dwb_vars(DWB,TABFORE,disabled) darkolivegreen4
   set dwb_vars(DWB,TABBACK) darkolivegreen3
   set dwb_vars(DWB,TABSELBACK) darkolivegreen2
   set dwb_vars(DWB,TABACTBACK) darkolivegreen1

   set dwb_vars(QVZ,TABFORE,normal) black
   set dwb_vars(QVZ,TABFORE,disabled) gold4
   set dwb_vars(QVZ,TABBACK) gold3
   set dwb_vars(QVZ,TABSELBACK) gold2
   set dwb_vars(QVZ,TABACTBACK) gold1

   set dwb_vars(Special,TABFORE,normal) black
   set dwb_vars(Special,TABFORE,disabled) grey50
   set dwb_vars(Special,TABBACK) grey60
   set dwb_vars(Special,TABSELBACK) grey70
   set dwb_vars(Special,TABACTBACK) grey80

   set dwb_vars(RI,TABFORE,normal) black
   set dwb_vars(RI,TABFORE,disabled) darkolivegreen4
   set dwb_vars(RI,TABBACK) darkolivegreen3
   set dwb_vars(RI,TABSELBACK) darkolivegreen2
   set dwb_vars(RI,TABACTBACK) darkolivegreen1

   set dwb_vars(QUERY,TABFORE,normal) black
   set dwb_vars(QUERY,TABFORE,disabled) grey60
   set dwb_vars(QUERY,TABBACK) grey70
   set dwb_vars(QUERY,TABSELBACK) grey90
   set dwb_vars(QUERY,TABACTBACK) grey80

#----------------------------------------------------------------
# Fehlermeldungen 
#----------------------------------------------------------------

   set dwb_vars(ERROR,NODATAFILE) "Das Programm kann nicht auf die Wörterbuchdaten zugreifen!\nBei Minimalinstallation muß sich die zweite CD-ROM im Laufwerk befinden"
   set dwb_vars(ERROR,LOWRESOLUTION) "Sie können das Programm nur ab einer Bildschirmauflösung\nvon 1024 x 768 Bildpunkten benutzen. Ändern Sie diese Einstellung\nunter Systemsteuerung->Anzeige->Einstellungen und starten Sie neu"
   set dwb_vars(ERROR,ALREADYINUSE) "Das Programm wird auf diesem Rechner bereits einmal ausgeführt."
   set dwb_vars(ERROR,NOACROREAD) "Das Programm kann Acrobat Reader nicht lokalisieren!\nInstallieren Sie das Programm nachträglich."
   set dwb_vars(ERROR,TIMESETBACK) "Die Uhrzeit auf Ihrem Rechner wurde zurückgesetzt!"
   set dwb_vars(ERROR,CANNOTFINDCDROM) "Das Programm kann nicht auf das CD-Laufwerk zugreifen!\nBitte geben Sie den Pfad beim Aufruf an (z.B. ./DWB /mnt/cdrom)"
}
