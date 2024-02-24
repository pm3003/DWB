################################################################
# A2PS.TCL
# "Port" of A2PS version 4.2 in Tcl
################################################################
## A2PS Copyright (c) 1992, 1993, Miguel Santana, santana@imag.fr
##
## Permission is granted to copy and distribute this file, for noncommercial
## use, provided (a) this copyright notice is preserved, (b) no attempt
## is made to restrict redistribution of this file, and (c) this file is
## not distributed as part of any collection whose redistribution is
## restricted by a compilation copyright.
##
## Tcl Port original author: Michael I. Schwartz, mschwart@nyx.net
## $Revision: 1.3 $
## $Date: 2000/07/02 23:40:56 $
## $Log: a2ps.tcl $
## Revision 1.3  2000/07/02 23:40:56  Michael_Schwartz
## Check for cancellation
##
## Revision 1.2  1999/09/09 04:56:58  Michael_Schwartz
## *** empty log message ***
##
# Revision 1.1  1998/12/14  00:08:33  Michael_Schwartz
# Initial revision
#
################################################################

################################################################
## Sample usage in a script (not using auto indexing):
##   package require printer
##   package require gdi
##   source a2ps.tcl
##   A2PS::a2ps textvariable
##
## Flags supported to A2PS::a2ps
##   -n   number lines
##   -b   Provide a border around the file
##   -h   Provide a header with file name and page numbers
################################################################

################################################################
## Written to use namespaces
################################################################
namespace eval A2PS {
  variable param
  variable option
  variable counter

  # The debug_puts proc is used for getting visibility into intermediate calculations
  # where needed.
  # With the 3 lines commented out, it does nothing.
  # It is intended for use in the console of a Tk application under windows (or 
  # under tclsh), or the puts will need to be redefined as well.

proc debug_puts { string } {
  #  puts $string
  #  update
  #  after 100
  }

  ################
  ## Init sets up default parameters.
  ## The parameters, options, and counters are derived from a2ps, and may not
  ## all be used in the current implementation
  ################
proc init { hdc array } {
    variable param
    variable option
    variable counter
    upvar #0 $array ary

    # Parameters in milli-inches....
    set param(width)               [ expr $ary(pw) - $ary(rm) ]  ;# 8500 for letter, 8270 for A4
    set param(height)              [ expr $ary(pl) - $ary(bm) ]  ;# 11000 for letter, 11640 for A4
    set param(margin)              $ary(lm)
    set param(lm)		   $ary(lm)
    set param(rm)		   $param(width)
    set param(tm)		   -$ary(tm)
    set param(bm)		   -$param(height)
    set param(dir_sep)             /
    set param(portrait_header)     [expr $ary(lm)]
    set param(landscape_header)    [ expr 1.8 * $ary(lm) ]
    set param(pixels_inch)        72
    set param(max_lines)         160
    set param(hdc)                 $hdc
    set param(x0)                  $ary(lm) 
    set param(y0)                  -$ary(tm)
    set param(sheetnumberx)        $ary(rm)
    set param(sheetnumbery)        $ary(bm)
    set param(text)                ""
    set param(filename)		   ""

    set option(line_numbering)     0
    set option(folding)            1
    set option(file_page_number_restart) 0
    set option(interpret_chars)    1
    set option(only_printable)     1
    set option(landscape)          0
    set option(twinfiles)          1
    set option(header)             0
    set option(border)             0
    set option(printdate)          0
    set option(filename_footer)    1
    set option(font_weight)        normal
    set option(font_name)          Times
    set option(font_size)          10.0
    set option(isolatin1)          1    ;# Assume everything is printable...
    set option(header_font_weight) bold
    set option(header_font_name)   Helvetica
    set option(header_font_size)   14.0
    set option(footer_font_weight) normal
    set option(footer_font_name)   Helvetica
    set option(footer_font_size)   8.0

    set counter(column)            0
    set counter(line)              0
    set counter(line_number)       1
    set counter(pages)             0
    set counter(sheets)            0
    set counter(old_pages)         0
    set counter(old_sheets)        0
    set counter(linesperpage)     66
    set counter(lines_requested)   0
    set counter(new_linesrequest)  0
    set counter(columnsperline)   80
    set counter(chars)             0
    set counter(copies_number)     1
    set counter(tab_column_width)  8
    set counter(num_files)         0
    set counter(x)                 $param(x0)
    set counter(y)                 $param(y0)
  }

  ################################################################
  ## page_args
  ## Description:
  ##   This is a helper proc used to parse common arguments for
  ##   text processing in the other commands.
  ##   "Reasonable" defaults are providedif not present
  ## Args:
  ##   Name of an array in which to store the various pieces 
  ##   needed for text processing
  ################################################################
proc page_args { array } {
    upvar #0 $array ary
  
    # First we check whether we have a valid hDC
    # (perhaps we can later make this also an optional argument, defaulting to 
    #  the default printer)
    set attr [ printer attr ]
    foreach attrpair $attr {
      set key [lindex $attrpair 0]
      set val [lindex $attrpair 1]
      switch -exact $key {
        "hDC"       { set ary(hDC) $val }
        "copies"    { if { $val >= 0 } { set ary(copies) $val } }
        "page dimensions" {
                            set wid [lindex $val 0]
                            set hgt [lindex $val 1]
                            if { $wid > 0 } { set ary(pw) $wid }
                            if { $hgt > 0 } { set ary(pl) $hgt }
                          }
        "page margins"    {
                            if { [scan [lindex $val 0] %d tmp] > 0 } {
  			    set ary(lm) [ lindex $val 0 ]
  			    set ary(tm) [ lindex $val 1 ]
  			    set ary(rm) [ lindex $val 2 ]
  			    set ary(bm) [ lindex $val 3 ]
  			  }
                          }
        "resolution"      {
                            if { [scan [lindex $val 0] %d tmp] > 0 } {
  			    set ary(resx) [ lindex $val 0 ]
  			    set ary(resy) [ lindex $val 1 ]
  			  } else {
  			    set ary(resx) 200	;# Set some defaults for this...
  			    set ary(resy) 200
  			  }
                          }
                       
      }
    }
  
    if { ( [ info exist ary(hDC) ] == 0 ) || ($ary(hDC) == 0x0) } {
      error "Can't get printer attributes"
    }
  
    # Now, set "reasonable" defaults if some values were unavailable
    if { [ info exist ary(resx) ] == 0 } { set ary(resx) 200 }
    if { [ info exist ary(resy) ] == 0 } { set ary(resy) 200 }
    if { [ info exist ary(tm) ] == 0 } { set ary(tm) 1000 }
    if { [ info exist ary(bm) ] == 0 } { set ary(bm) 1000 }
    if { [ info exist ary(lm) ] == 0 } { set ary(lm) 1000 }
    if { [ info exist ary(rm) ] == 0 } { set ary(rm) 1000 }
    if { [ info exist ary(pw) ] == 0 } { set ary(pw) 8500 }
    if { [ info exist ary(pl) ] == 0 } { set ary(pl) 11000 }
    if { [ info exist ary(copies) ] == 0 } { set ary(copies) 1 }
  }

  ################
  ## set_global_options parses the command line flags that are supported
  ## by the proc.
  ## A2PS uses a two-tiered option setting scheme, where some arguments
  ## can "re"appear between filenames. These latter are called
  ## "positional" parameters and have their own proc
  ## The return value tells the calling routine (a2ps) how many 
  ## more of the remaining arguments to eat.
  ################
proc set_global_options { command args } {
    variable option
    variable counter
    variable param
    set retval 0

    switch -exact -- $command {
      "-n" { 
             set option(line_numbering) 1 
	     incr counter(line_number)
           }
      "-h" {
	     set option(header) 1
           }
      "-b" {
             set option(border) 1
           }
    }
    return $retval
  }

  ################
  ## Used to set arguments that may change between one file and another.
  ################
proc set_positional_argument { command args } {
    # Not implemented yet.
  }

  ################
  ## skip_page terminates printing on the current page and moves to the 
  ## next page
  ################
proc skip_page { } {
    variable param
    variable counter
    printer page end
    incr counter(pages)
    printer page start
  }

  ################
  ## fold_line ends the current line.
  ## If at the end of the page, it will end the current page as well.
  ################
proc fold_line { } {
    variable counter
    variable param
    variable option

    incr counter(line)

    if { $counter(line) > $param(linesperpage) } {
      endpage
      skip_page
      set counter(line) 0
    }
  }
  
  ################
  ## mygetc fetches the next character from the file.
  ## This routine will likely need work for internationalization.
  ################
proc mygetc { } {
    variable text

    if { $text(index) >= $text(len) } {
      debug_puts "**End of file"
      return ""
    } else {
      set retval [string index $text(text) $text(index)]
      incr text(index)
      return $retval
    }
  }

  ################
  ## cut_line eats all remaining characters in the current line
  ## up to the end of file, newline, or page feed.
  ################
proc cut_line { } {
    variable text

    set ch Z

    while { ( $ch != "")  && ( $ch != {\n} ) && ( $ch != {\f} } {
      set ch [mygetc]
    }

    return $ch
  }  

  ################
  ## print_page puts the current page number on the page before moving to the next page
  ################
proc printpage { } {
    variable param
    variable counter
    variable option

    gdi text $param(hdc) $param(sheetnumberx) $param(sheetnumbery) -font "$option(font_name) $option(font_size) $option(font_weight)" -text "Page $counter(sheets)" -anchor e
    debug_puts "**Printed page $counter(sheets)"
    incr counter(sheets)
    set  counter(line) 0

    # Similarly with date and filename footer
  }
 
  ################
  ## startpage performs all the special processing for starting a new page:
  ## The header, border boxes, etc.
  ## It also initializes the counters for generating the body text
  ################ 
proc startpage { } {
    variable counter
    variable option
    variable param

    if { $option(border) } {
      set xl [ expr $param(lm) - 250 ]
      set xr [ expr $param(rm) + 250 ]
      set yt $param(tm)
      set yb [ expr $param(bm) - 250 ]

      gdi rectangle $param(hdc) $xl $yt $xr $yb -outline black
      debug_puts "Drawing rectangle from ($xl,$yt) to ($xr,$yb)"
    }
    if { $option(header) } {
      set xcenter [ expr ( $param(lm) + $param(rm) ) / 2 ]
      set ycenter [ expr  $param(tm) + 350 ]
      gdi text $param(hdc) $xcenter $ycenter -anchor n -font [ list $option(header_font_name) $option(header_font_size) $option(header_font_weight) ] -text $param(filename)
      gdi text $param(hdc) $param(rm) $ycenter -anchor ne -font [ list $option(header_font_name) $option(header_font_size) $option(header_font_weight) ] -text "Page $counter(pages)"
      debug_puts "Drawing text '$param(filename)' at $xcenter,$ycenter"
    }

    set counter(x) $param(x0)
    set counter(y) $param(y0)
  }

  ################
  ## cleanup is called once at the end of each file.
  ## It prints the last page and closes off the job in the print queue.
  ################
proc cleanup { } {
    variable param
    printpage
    printer job end
  }

  ################
  ## endpage is probably obsolete
  ################
proc endpage { } {
    printpage
  }

  ################
  ## print_file_prologue in the original a2ps put out the dictionary settings
  ## for the postscript output for each file
  ## Thus, in Tcl it sets up the print job counters and parameters as well.
  ################
proc print_file_prologue { name { title "" } } {
    variable option
    variable counter
    variable param

    if { $counter(pages) > 0 } {
      cleanup
    }
    if { $title == "" } {
      set title $name
    }
    
    set counter(line) 0
    setlinesperpage

    # If there is a header, move y0 a bit...
    if $option(header) {
      incr param(y0) -333
    }
  }

  ################
  ## print_prologue in the original a2ps put out the dictionary settings
  ## for the postscript output for the whole job.
  ## Thus, in Tcl it sets up the print job counters and parameters as well.
  ################
proc print_prologue { name } {
    variable param
    variable chars
    variable option
    variable ary

    printer job start -name $name
     foreach pair [ printer attr ] {
      if { [lindex $pair 0] == "hDC" } {
        set param(hdc) [ lindex $pair 1]
        break
      }
     }
    # Set the mapping mode and initialize the character width table for the selected font
    gdi map $param(hdc) -mode MM_HIENGLISH
    gdi characters $param(hdc) -font [ list $option(font_name) $option(font_size) $option(font_weight) ] -array ::A2PS::charwidths
    set param(charwidths) ::A2PS::charwidths

    set param(fh) [ expr $option(font_size) * 1000.0 / 72.0 ]
    set param(fw) $::A2PS::charwidths(m)

  }

  ################
  ## setlinesperpage is used in the original to figure out how many text
  ## lines fit on a page in the selected font.
  ## That may not be needed in the current implementation
  ################
proc setlinesperpage { } {
    variable option
    variable param
    
  }

  ################
  ## init_file_counters are reset for each file printed, and reflect such
  ## counters as line numbering and the text array
  ################
proc init_file_counters { } {
    variable counter
    variable param
    variable option

    set counter(column) 0
    set counter(line) 0
    set counter(line_number) 1
    if  $option(line_numbering) {
      set param(text) [ format "%5d " $counter(line_number) ]
    } else {
      set param(text) ""
    }
  }

  ################
  ## This function actually outputs the text line and prepares for the next one.
  ################
proc next_line { } {
    variable counter
    variable option
    variable param
    variable start_page

    if { $counter(line) == 0 } {
      startpage
    }

    if { [ string length $param(text) ] > 0 } {
      set param(fh) [gdi text $param(hdc) $param(x0) $counter(y) -text $param(text) -anchor w -font [ list $option(font_name) $option(font_size) $option(font_weight) ] ]
    }
    set counter(x) $param(x0)
    set counter(y) [ expr $counter(y) + $param(fh) ]
    incr counter(line_number)
    incr counter(line)
    if $option(line_numbering) {
      set param(text) [ format "%5d " $counter(line_number) ]
      incr counter(x) [ expr 6 * $param(fw) ]
    } else {
      set param(text) ""
    }
    # debug_puts "**New line"
  }

  ################
  ## This function actually outputs the wrapped text line and prepares for the
  ## next line, which is a continuation line.
  ################
proc continuation_line { } {
    variable counter
    variable option
    variable param

    if { [ string length $param(text) ] > 0 } {
      set param(fh) [ gdi text $param(hdc) $param(x0) $counter(y) -text $param(text) -anchor w -font [ list $option(font_name) $option(font_size) $option(font_weight) ] ]
    }
    set counter(x) $param(x0)
    set counter(y) [ expr $counter(y) + $param(fh) ]
    incr counter(line)
    set param(text) "\t"
    # debug_puts "**New line"
  }

  # Convenience routine to place a character at the current location
  # Changed strategy from a2ps: add characters to a variable until
  # the end of line is reached (based on character widths).
  # next_line will output the entire line at once.
proc putchar { ch } {
    variable param
    variable counter
    variable option
    variable $param(charwidths)

    upvar #0 $param(charwidths) charwidths
    set param(text) "$param(text)$ch"
    # gdi text $param(hdc) $counter(x) $counter(y) -text $ch -anchor w -font [ list $option(font_name) $option(font_size) $option(font_weight) ]
    # debug_puts "$ch: char"
    set counter(x) [ expr $counter(x) + $charwidths($ch) ]
    return $counter(x)
  }

  ################
  ## Main routine for printing a single file
  ################  
proc print_file { name { header "" } } {
    variable option
    variable text
    variable counter
    variable param
    variable start_page

    set text(text) $name
    set param(filename) {CAG}
    set text(index) 0
    set text(len) [ string length $text(text) ]
    # debug_puts "Read $text(len) characters"
    

    print_file_prologue $name $header
    set start_page 0
    init_file_counters
    set first_page 1
    set start_line 1

    skip_page
    set c [mygetc]

    while { "$c" != "" } {
      if { ( $c == "\f" ) && $option(interpret_chars) } {
        if { $start_line == 0 } {
          next_line
        }
        if { $start_page } {
          skip_page
          startpage
        }
        end_page
        set start_page 1
        set counter(line) 0
        set counter(column) 0
        set c [ mygetc ]
        if { $c == "" } {
          break
        }
      }

      if $start_line {
        if $start_page {
          skip_page
          set start_page 0
        }
      }

      switch -exact -- $c {
        "\n"  {
                next_line
                set counter(column) 0
                set start_line 1
                if { $counter(y) <=  -$param(height)  } {
                  endpage
                  set start_page 1
                  set counter(line) 0
                  set counter(y) $param(y0)
                } 
              }
        "\t"  {
                set curlen [ string length $param(text) ]
                if { $option(line_numbering) } {
                  incr curlen -6
                  set spaces [ expr $counter(tab_column_width) - ( $curlen % $counter(tab_column_width) ) ]
                } else {
                  set spaces [ expr $counter(tab_column_width) - ( $curlen % $counter(tab_column_width) ) ]
                }
                if { $spaces == 0 } { set spaces 8 }
                for { set i 0 } { $i < $spaces } { incr i } {
		  set wid [ putchar " " ]
		  if { $wid > $param(width) } {
		    continuation_line
                    if { $option(folding) == 0 } {
		      set c [cut_line]
		    }
                  }
                }
              }
        ""    {
                break
              }
        default {
                  set nchars 1  ;# ignores control chars for now
                  incr counter(column) $nchars
                  set wid [putchar $c]
                  if { $wid >= $param(width) } {
                    continuation_line
                    if { $option(folding) == 0  } {
                      set c [cut_line]
                    }
                  } 
                  incr counter(chars)
                }
      }
      set c [mygetc]
    }

    if { $start_line == 0 } {
      next_line
    }
    if { $start_page == 0 } {
      endpage
    }
  }

  ################################################################
  ## Main routine of the package.
  ## Arranges to start the print job, initialize all the variables,
  ## parse the command, and call print_file appropriately for
  ## each file.
  ################################################################
proc a2ps { args } {
    variable option 
    variable param 
    variable counter
    
#    set hdc [printer dialog select -flags 4]
#    if { [lindex $hdc 1] == 0 } {
#      # Print has been canceled
#      return
#    }
#    set hdc [ lindex $hdc 0]
    set hdc [lindex [lindex [printer attr -get hDC] 0] 1]
    page_args A2PS::ary
    init $hdc A2PS::ary

    set len [ llength $args ]
    for { set narg 0 } { $narg < $len } { incr narg } {
       set command [ lindex $args $narg ]
       if { [string index $command 0] == "-" } {
         set retval [ set_global_options $command [lrange $args [expr $narg + 1 ] end] ]
	 incr narg $retval
       } else {
         break
       }
    }
    # Remaining arguments are files.
    print_prologue "Tcl A2PS emulator"
    for { } { $narg < $len } { incr narg } {
      set command [ lindex $args $narg ]
      if { [string index $command 0] == "-" } {
        set_positional_option $command [lrange $args [expr $narg + 1 ] end]
      }
      print_file [lindex $args $narg]
    }
    cleanup
  }
}

package provide a2ps 0.1
package require printer
package require gdi
