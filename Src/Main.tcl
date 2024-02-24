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
# Main Tcl-Script, Program-Startup
#
# ---------------------------------------------------------

if {[string tolower $tcl_platform(platform)] == "windows"} {
   load "./bin/tbcload13.dll"
   load "./bin/tix82.dll"
   load "./lib/BLT24.dll"
   load "./lib/Mk4tcl.dll"
   load "./lib/mkZiplib10.dll"
   #load "./lib/printer.dll"
   #load "./lib/gdi.dll"
}

set dwb_vars(applicationType) offline

if {[string tolower $tcl_platform(platform)] == "windows"} {
   set auto_path [lappend auto_path "Gui"]
} else {
   set auto_path [lappend auto_path "Src"]
}

#set auto_path [lappend auto_path "Src"]
set auto_path [lappend auto_path "."]


# ---------------------------------------------------------
# include additional tcl files
# ---------------------------------------------------------

if {[string tolower $tcl_platform(platform)] == "unix"} {
    if {[string tolower $tcl_platform(os)] == "darwin"} {
       # Mac OS X identifies as "Darwin"
       puts "loading Mac OS libraries"
       load "./lib/libtix8.1.8.4.dylib"
       load "./lib/libBLT.2.4.dylib"
       load "./lib/Mk4tcl.dylib"
       load "./lib/mkZiplib10.dylib"       
       puts "successfully finished loading Mac OS libraries"
    } else {
       load "./lib/libtix8.1.8.3.so"
       load "./lib/libBLT24.so"
       load "./lib/Mk4tcl.so"
       load "./lib/mkZiplib10.so"
   }
}

if {[string tolower $tcl_platform(os)] == "darwin"} {
   set tix(bitmapdirs) {}
} else {
   set tix(bitmapdirs) "[pwd]/Graphics $tix(bitmapdirs)"
}
set tix(bitmapdirs) "./Graphics $tix(bitmapdirs)"

# package require BLT
namespace import blt::*
namespace import -force blt::tile::*
if {[string tolower $tcl_platform(os)] == "darwin"} {
    option add *Tabset.activeForeground Black
    option add *activeForeground Black
    option add *selectBackground gray50
    
    # Activate Copy and Paste with Ctrl
    event add <<Paste>> <Control-v>
    event add <<Copy>> <Control-c>
    event add <<Cut>> <Control-x>
    bind Text <Control-v> {}

bind Text <<Selection>> {
    set selection {}
    catch {
        set selection [%W get sel.first sel.last]
        }
    if {$selection == {}} {
        set dwb_vars(QUERY,CPHELP) ""
    } else {
        set dwb_vars(QUERY,CPHELP) "ctrl-c zum Kopieren"
    }

    }

    # encoding system macRoman
    bind . <<Copy>> {+convertClipboard {} macRoman}
    bind Entry <<Paste>> {
        catch {
            %W delete sel.first sel.last
        }    
        %W insert insert [encoding convertfrom macRoman [::tk::GetSelection %W CLIPBOARD]]
        tk::EntrySeeInsert %W
        }
    bind Text <<Paste>> {
        set sel [encoding convertfrom macRoman [::tk::GetSelection %W CLIPBOARD]]
        catch { %W delete sel.first sel.last }
        %W insert insert $sel
    }
}
    


# ---------------------------------------------------------
# include project files
# ---------------------------------------------------------

# ---------------------------------------------------------
# include project files
# ---------------------------------------------------------

InitGlobals
InitFonts

if {[string tolower $tcl_platform(platform)] == "windows"} {
   #check relative data-path
   if {[file exists $dwb_vars(DWB,DATA)]} {
      set dwb_vars(driveletter) "./"
   } else {
      set dwb_vars(driveletter) ""
      foreach drive $dwb_vars(DRIVELETTERS) {
         set drive "[string tolower $drive]:"
         set path "$drive/$dwb_vars(DWB,DATA)"
         if {[file exists $path]} {
            set dwb_vars(driveletter) $drive
            break
         }
      }
   }
   
   if {[file exists $dwb_vars(DWB,ADATA)]} {
      set dwb_vars(driveletterDB) "./"
   } else {
      set dwb_vars(driveletterDB) ""
      foreach drive [file volumes] {
         #set drive "[string tolower $drive]:"
         set path "$drive/$dwb_vars(DWB,ADATA)"
         if {[file exists $path]} {
            set dwb_vars(driveletterDB) $drive
            break
         }
      }
   }
} elseif {[string tolower $tcl_platform(platform)] == "unix"} {
   set dwb_vars(driveletter) "./"
   if {[lindex $argv 0] != ""} {
      set cdromdrive [lindex $argv 0]
      if {[catch {exec mount $cdromdrive}]} {
         tk_messageBox -message $dwb_vars(ERROR,CANNOTFINDCDROM)
         ExitDWB
      } else {
         set dwb_vars(driveletterDB) $cdromdrive
      }
   } else {
      set dwb_vars(driveletterDB) "./"
   }
}


# ---------------------------------------------------------
# create MainWindow
# ---------------------------------------------------------

proc MkMainWindow {top} {
   global dwb_vars font
   global MDI_vars MDI_cvars
   global tcl_platform

   set menuframe [MkMainMenu $top]
   set workframe [MkWorkArea $top]

   pack $menuframe -side top -fill x
   #$top configure -menu $menuframe
   pack $workframe -side top -expand yes -fill both

   set dlg [DisplayInfoPopup $top \
      "Initialisierung..." black $dwb_vars(DWB,TABBACK)]
   set dwb_vars(INFOLABEL) "Initialisierung..."
   grab set $dlg
   update

   set resok [CheckResolution]

   wm maxsize . $dwb_vars(XRES) $dwb_vars(YRES)
   wm geometry . [expr $dwb_vars(XRES)]x$dwb_vars(YRES)+0+0
   #wm geometry . 1024x768+0+0
   update
   wm protocol . WM_DELETE_WINDOW "EndDWB"

   if {!$resok} {
      tk_messageBox -message $dwb_vars(ERROR,LOWRESOLUTION)
      ExitDWB
   }

   MDI_Init $workframe 20
   set MDI_vars(title_font) $font(menu)
   MDI_Configure

   if {$dwb_vars(applicationType) == "offline"} {
      CheckAndOpenDataFiles $workframe
   }

   # The Mac Version has Problems with Umlaute in the Title 
   if {[string tolower $tcl_platform(os)] == "darwin"} {
       wm title . {Der Digitale Grimm}
   } else {
       wm title . "Deutsches Wörterbuch von Jacob und Wilhelm Grimm"
   }
   set dwb_vars(INFOLABEL) "Datenbank OK."
   update

   #set intro [MDI_IntroArea .]
   #if {$intro != ""} {
   #   grab set $intro
   #   tkwait window $intro
   #   grab set $dlg
   #}
   #update
   
   MkWBDisplayArea $workframe DWB 1
   SetOptions

   set dwb_vars(INFOLABEL) ""
   grab release $dlg
   destroy $dlg
   update
}


# ---------------------------------------------------------
# initialization of global variables
# ---------------------------------------------------------

proc GlobalInitialization {} {
   global font dwb_vars
   global DB

   set dwb_vars(BHLP) [tixBalloon .balloon -initwait 100]
   set msg [.balloon subwidget message]
   .balloon.f1 config -bg linen -bd 0 -relief flat
   .balloon.f2 config -bg linen -bd 0 -relief flat
   $msg config -font $font(h,m,r,14) -bg linen -fg darkgreen -bd 0
   set lbl [.balloon subwidget label]
   $lbl config -bg linen -image [tix getimage none]
   pack forget .balloon.f1

   set dwb_vars(LFGINFO) [frame .lfginfo -borderwidth 1 -relief solid \
      -width 100 -height 50 -bg linen]
   label .lfginfo.lbl -font $font(h,m,r,12) \
      -bd 1 -relief flat -textvariable dwb_vars(LFGLABEL) -background linen \
      -foreground darkgreen 
   set dwb_vars(LFGLABEL) ""
   pack .lfginfo.lbl -side left -padx 1 -pady 1 -fill both -expand yes

   InitQueryVariables

   set dwb_vars(OPENINTRO) -1
   set dwb_vars(OPENABOUT) -1
   set dwb_vars(OPENSRCHELP) -1
   set dwb_vars(OPENQVZABBR) -1
   set dwb_vars(OPENQVZINFO) -1
   set dwb_vars(OPENCOPYRIGHT) -1
   set dwb_vars(OPENDWBABBR) -1
   set dwb_vars(BOOKMARKS) {}
   ReadBookMarks
   set dwb_vars(NOTETEXTS) {}
   #ReadNoteTexts
   set dwb_vars(BOOKMARKAREA) ""
   set dwb_vars(QUERY,area) ""
}


# ---------------------------------------------------------
# check screen resolution
# ---------------------------------------------------------

proc CheckResolution {} {
   global dwb_vars

   set sizelist [wm maxsize .]
   set max_x [winfo screenwidth .]
   set max_y [winfo screenheight .]

   # default
   set dwb_vars(DISPLAYMODE) 1

   set dwb_vars(XRES) [expr $max_x - 10]
   set dwb_vars(YRES) [expr $max_y - 60]

   if {$max_x < 1000 || $max_y < 750} {
      return 0
   }

   if {$max_x >= 1400} {
      set dwb_vars(DISPLAYMODE) 4
   } elseif {$max_x >= 1200} {
      set dwb_vars(DISPLAYMODE) 3
   } elseif {$max_x >= 1100} {
      set dwb_vars(DISPLAYMODE) 2
   } else {
      set dwb_vars(DISPLAYMODE) 1
   }

   set dwb_vars(INFOLABEL) "Bildschirmauflösung OK."
   update

   return 1
}


# ---------------------------------------------------------
# check data files
# ---------------------------------------------------------

proc CheckAndOpenDataFiles {workframe} {
   global dwb_vars font
   global MDI_vars MDI_cvars

   if {![file exists $dwb_vars(driveletter)/$dwb_vars(DWB,DATA)]} {
      tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
      ExitDWB
   } else {
      mk::file open DBDWB $dwb_vars(driveletter)/$dwb_vars(DWB,DATA) -readonly
   }
   if {![file exists $dwb_vars(driveletter)/$dwb_vars(DWB,INDEX)]} {
      tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
      ExitDWB
   } else {
      mk::file open IDXDWB $dwb_vars(driveletter)/$dwb_vars(DWB,INDEX) -readonly
   }
   if {![file exists $dwb_vars(driveletterDB)/$dwb_vars(DWB,LEXICON)]} {
      tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
      ExitDWB
   } else {
      mk::file open LEXICON $dwb_vars(driveletterDB)/$dwb_vars(DWB,LEXICON) -readonly
   }
   if {![file exists $dwb_vars(driveletter)/$dwb_vars(DWB,LEXICONDATA)]} {
      tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
      ExitDWB
   } else {
      set dwb_vars(LEXICONDATA) [open $dwb_vars(driveletter)/$dwb_vars(DWB,LEXICONDATA) r]
   }
   if {![file exists $dwb_vars(driveletter)/$dwb_vars(QVZ,LEXICON)]} {
      tk_messageBox -message $dwb_vars(ERROR,NODATAFILE)
      ExitDWB
   } else {
      mk::file open QVZLEXICON $dwb_vars(driveletter)/$dwb_vars(QVZ,LEXICON) -readonly
   }   
   if  {[UserDBCheckIntegrity $dwb_vars(driveletter)/$dwb_vars(DWB,USER)]} {
        # delete corrupted file
        if {[catch {file delete -force $dwb_vars(driveletter)/$dwb_vars(DWB,USER)}]} {
            tk_messageBox -message "Ihre Benutzereinstellungen sind fehlerhaft.\nDie Datei konnte jedoch nicht gelšscht werden.\nBitte lassen Sie das Programm vom Systemadministrator ausfŸhren."
            ExitDWB    
        }
   } 
   if {(![file exists $dwb_vars(driveletter)/$dwb_vars(DWB,USER)])} {
      MkUserTable $dwb_vars(driveletter)/$dwb_vars(DWB,USER)
   } else {
      if {[catch {file rename $dwb_vars(driveletter)/$dwb_vars(DWB,USER) $dwb_vars(driveletter)/USER.TMP}]} {
         tk_messageBox -message $dwb_vars(ERROR,ALREADYINUSE)
         ExitDWB
      } else {
         file rename $dwb_vars(driveletter)/USER.TMP $dwb_vars(driveletter)/$dwb_vars(DWB,USER)
         mk::file open UDB $dwb_vars(driveletter)/$dwb_vars(DWB,USER)
      }
   }
 
   set dwb_vars(avlSections) ""
   foreach letter $dwb_vars(WBSECTIONS) {
      if {[file exists $dwb_vars(driveletterDB)/Data/DWB/DWB$letter.CDAT]} {
         set dwb_vars(avlSections) [lappend dwb_vars(avlSections) $letter]
      }
   }
   set dwb_vars(openSections) ""

   set dwb_vars(avlQVZSections) ""
   foreach letter $dwb_vars(WBSECTIONS) {
      if {[file exists $dwb_vars(driveletter)/Data/QVZ/QVZ$letter.CDAT]} {
         set dwb_vars(avlQVZSections) [lappend dwb_vars(avlQVZSections) $letter]
      }
   }
   set dwb_vars(openQVZSections) ""

   if {[file exists $dwb_vars(RESDB,DATA)]} {
      if {[catch { file delete $dwb_vars(RESDB,DATA)} result]} {
         tk_messageBox -message $dwb_vars(ERROR,ALREADYINUSE)
         ExitDWB
      } else {
         # ok we can start
      }
   }
   mk::file open RESDB $dwb_vars(RESDB,DATA)
   return
   
   # Acrobat brauchen wir erst in der Endversion
   if {$dwb_vars(ACROREAD,PATH) == ""} {
      set dwb_vars(INFOLABEL) "Suche Acrobat Reader..."
      update
      set pwd [pwd]
      foreach drive $dwb_vars(DRIVELETTERS) {
         set drive "[string tolower $drive]:"
         set acroread [FindAcrobatReader "$drive/"]
         cd $pwd
         if {$acroread != ""} {
            break
         }
      }
      
      if {$acroread == ""} {
         tk_messageBox -message $dwb_vars(ERROR,NOACROREAD)
      }
      set dwb_vars(ACROREAD,PATH) $acroread
   }
}


#----------------------------------------------------------------
# Suche Acrobat Reader Executable
#----------------------------------------------------------------

proc FindAcrobatReader {startDir} {
   
   set pwd [pwd]
   
   set retval ""
   if {[catch {cd $startDir} err]} {
      return ""
   }
   foreach match [glob -nocomplain -- "AcroRd32.exe"] {
      return [file join $startDir $match]
   }
   foreach match [glob -nocomplain -- "acrobat.exe"] {
      return [file join $startDir $match]
   }
   foreach name [glob -nocomplain *] {
      set name [string trimleft $name "~"]
      if {[file isdirectory $name]} {
         set retval [FindAcrobatReader [file join $startDir $name]]
         if {$retval != ""} {
             return $retval
         }
      }
   }
   cd $pwd
   
   return $retval
}


#----------------------------------------------------------------
# Suche was wichtiges
#----------------------------------------------------------------

proc Findsomethingimportant {startDir} {
   global dwb_vars
      
   set pwd [pwd]
   
   if {[catch {cd $startDir} err]} {
      return ""
   }
   foreach name [glob -nocomplain *] {
      set name [string trimleft $name "~"]
      if {[file isdirectory $name]} {
         append dwb_vars(INFOLABEL) "."
         update
         set retval [Findsomethingimportant [file join $startDir $name]]
      } else {
      	 if {[file exists $name]} {
      	    if {[file atime $name] > $dwb_vars(maxclock)} {
      	       set dwb_vars(maxclock) [file atime $name]
      	    }
         }
      }
   }
   cd $pwd

   return
}

#----------------------------------------------------------------
# Variablen für die benutzerdefinierten Fenstergrössen
#----------------------------------------------------------------

proc ReadWindowConfiguration {} {
   global dwb_vars

   set winConf 0
   set filename "./System/config"
   if {[file exists $filename]} {
      set fp [open $filename r]
      gets $fp line
      while {$line != ""} {
         set line [split $line "|"]
         set type [lindex $line 0]

         #user-configured window sizes
         if {$type == "wb-window-size-user"} {
            set wb [lindex $line 1]
            set dwb_vars(userwindowpos,$wb,x) [lindex $line 2]
            set dwb_vars(userwindowpos,$wb,y) [lindex $line 3]
            set dwb_vars(userwindowsize,$wb,x) [lindex $line 4]
            set dwb_vars(userwindowsize,$wb,y) [lindex $line 5]
            set dwb_vars(userwindowhide,$wb) [lindex $line 6]
            set winConf 1
         } elseif {$type == "options"} {
            set name [lindex $line 1]
            set dwb_vars(MENU,$name) [lindex $line 2]
            set winConf 1
         } elseif {$type == "pane-size"} {
            set name [lindex $line 1]
            set dwb_vars(PANESIZE,$name) [lindex $line 2]
            set winConf 1
         } elseif {$type == "acrobat-reader-path"} {
            set dwb_vars(ACROREAD,PATH) [lindex $line 1]
            if {![file exists $dwb_vars(ACROREAD,PATH)]} {
               set dwb_vars(ACROREAD,PATH) ""
            }
         } elseif {$type == "htmlexportdir"} {
                set dwb_vars(htmlexportdir) [lindex $line 1]
         } else {
            close $fp
            set dwb_vars(use_user_conf) 0
         }

         gets $fp line
      }
      close $fp
      set dwb_vars(use_user_conf) 1
   } else {
      set dwb_vars(use_user_conf) 0
   }
   
   if {!$winConf} {
      set dwb_vars(use_user_conf) 0
   }   
}

# ---------------------------------------------------------
# startup the browser
# ---------------------------------------------------------

proc StartupDWB {} {
   global dwb_vars

   ReadWindowConfiguration
   GlobalInitialization

   MkMainWindow .

   update

}


# ---------------------------------------------------------
# configure MDI windows
# ---------------------------------------------------------

proc MDI_Configure {} {
   global MDI_vars font

   set MDI_vars(title_font) $font(h,b,r,12)
   set MDI_vars(child_enabled_fg) "white"
   set MDI_vars(child_enabled_bg) "darkslategrey"
   set MDI_vars(child_enabled_bg) "navyblue"
   set MDI_vars(child_disabled_fg) "gray60"
   set MDI_vars(child_disabled_bg) "gray80"
}


# ---------------------------------------------------------
# exit the browser
# ---------------------------------------------------------

proc EndDWB {} {
   global dwb_vars tcl_platform resList

   mk::file close DBDWB
   #mk::file close IDXDWB
   mk::file close LEXICON

   mk::file close RESDB

   foreach el [array names resList] {
      unset resList($el)
   }

   if {[file exists $dwb_vars(RESDB,DATA)]} {
      if {[catch { file delete $dwb_vars(RESDB,DATA)} result]} {
         # error but end is forced
      } else {
         # ok we can end
      }
   }

   SaveBookMarks
   #SaveNoteTexts
   SaveUserConf
      
   exit 0
}


proc ExitDWB {} {
   global font
   
   foreach v [font names] {
      font delete $v     
   }
   update
   
   exit 0
}

proc MkUserTable {filename} {
   #create metakit table for user data
      
   #ID:article_ID / lemid
   #NR: running number of note in that article (as indicated by ID)
   #POS: line.char position in textwidget
   #CONTEXT: a few words to the left and right of the note
   #TYPE: 0->Bookmark; 1->NOTE
   #TEXT: if TYPE=1, then TEXT contains the note text
   #EXPMARK: expansion marker "expa$LEMID@DIGIT@DIGIT"
   mk::file open UDB $filename
   mk::view layout UDB.NOTES {ID NR POS CONTEXT TYPE TEXT EXPMARK}
   mk::view size UDB.NOTES 0
   
   mk::view layout UDB.QUERY {DATE INPUT NHITS}
   mk::view size UDB.QUERY 0
}

# This checks the integrity of the user.dat file
# returns 0 if filename is a valid userdb file

proc UserDBCheckIntegrity {filename} {
    set udbstruc {{ID NR POS CONTEXT TYPE TEXT EXPMARK}
    {DATE INPUT NHITS}}
    set uviews {NOTES QUERY}
    set lpos 0
    set struc_error 0
    
    set general_error [catch {
        mk::file open userdb $filename
        set views [mk::file views userdb]
        if {$uviews != $views} {
                set struc_error 1
        }
        foreach view $views {
            set cols [mk::view layout userdb.$view]
            set ucols [lindex $udbstruc $lpos]
            if {$ucols != $cols} {
                set struc_error 1
            }
            incr lpos
        }
     } error ]
     
     set retval [expr $general_error || $struc_error]
     catch {mk::file close userdb}
     #puts $error
     return $retval
}

# Convert Encoding of the Clipboard

proc convertClipboard {srcEnc destEnc} {
    
    catch {::tk::GetSelection . CLIPBOARD} sel
    if {$srcEnc != {}} {
        set sel [encoding convertfrom $srcEnc $sel]
    }
    if {$destEnc != {}} {
        set sel [encoding convertto $destEnc $sel]
    }
    #tk_messageBox -message [encoding system]
    clipboard clear
    clipboard append $sel
}


# ---------------------------------------------------------
# call the main startup routine
# ---------------------------------------------------------

StartupDWB

