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
# Multiple Document Interface
# ---------------------------------------------------------


# ---------------------------------------------------------
# Init MDI Mechanism
# ---------------------------------------------------------

proc MDI_Init {mdiframe max_child {menu ""}} {
   global MDI_vars

   if {![winfo exist $mdiframe]} {
      return 0
   }

   # default configuration
   set MDI_vars(curr_child) -1
   set MDI_vars(max_child) $max_child
   set MDI_vars(menu_path) $menu
   set MDI_vars(child_x) 10
   set MDI_vars(child_y) 10
   set MDI_vars(child_enabled_fg) "white"
   set MDI_vars(child_enabled_bg) "navyblue"
   set MDI_vars(child_disabled_fg) "lightgray"
   set MDI_vars(child_disabled_bg) "gray60"
   set MDI_vars(frame_width) 3
   set MDI_vars(frame_relief) flat
   set MDI_vars(button_width) 12
   set MDI_vars(child_frame_color) "gray"
   set MDI_vars(child_corner_len) 20
   set MDI_vars(title_font) \
      "-adobe-helvetica-bold-r-normal--10-100-75-75-p-60-iso8859-1"

   set MDI_vars(this) $mdiframe
   set MDI_vars(parent) [winfo parent $mdiframe]
   set MDI_vars(idle) 0
   set MDI_vars(MDI_cursor) "arrow"
   set MDI_vars(title_enter_cur) "hand2"
   set MDI_vars(title_press_cur) "fleur"
   set MDI_vars(but_enter_cur) "hand2"
   set MDI_vars(frame_left_enter_cur) "left_side"
   set MDI_vars(frame_right_enter_cur) "right_side"
   set MDI_vars(frame_top_enter_cur) "top_side"
   set MDI_vars(frame_bottom_enter_cur) "bottom_side"
   set MDI_vars(bl_edge_enter_cur) "bottom_left_corner"
   set MDI_vars(br_edge_enter_cur) "bottom_right_corner"
   set MDI_vars(tl_edge_enter_cur) "top_left_corner"
   set MDI_vars(tr_edge_enter_cur) "top_right_corner"
   set MDI_vars(standard_cur) "left_ptr"

   set MDI_vars(width) [winfo w $MDI_vars(this)]
   set MDI_vars(height) [winfo h $MDI_vars(this)]
   set MDI_vars(background) [$MDI_vars(this) cget -bg]

   # if a menu entry is given, create the windows-menupoints
   if {[winfo exist $MDI_vars(menu_path)]} {
      menu $MDI_vars(menu_path).m -tearoff 0
   }

   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      set MDI_vars(order,$i) -1
   }

   return 1
}


# ---------------------------------------------------------
# Exit MDI, call close command for all children
# ---------------------------------------------------------

proc MDI_Exit {} {
   global MDI_cvars MDI_vars

   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      # get children
      if {[info exist MDI_cvars($i,this)]} {
         # at first run the user defined close command
         if {![eval $MDI_cvars($i,close_cmd)]} return else 0
      }
   }

   unset MDI_vars
}


# ---------------------------------------------------------
# create new child in MDI main frame
# ---------------------------------------------------------

proc MDI_CreateChild {name} {
   global MDI_cvars MDI_vars

   set child [MDIchild_New $name]

   if {$child >= $MDI_vars(max_child)} {
      MDIchild_Delete $child
      return -1
   }

   if {[winfo exist $MDI_vars(menu_path)]} {
      # add the child to the window list
      $MDI_vars(window_menu_path).menu add command -label $name \
         -command "
            MDI_ActivateChild $child 1
            MDIchild_Show $child
         "
      set MDI_cvars($child,menu_pos) $MDI_vars(menu_entrys)
      incr MDI_vars(menu_entrys)
   }

   MDI_ActivateChild $child

   return $child
}


# ---------------------------------------------------------
# destroy child in MDI main frame
# ---------------------------------------------------------

proc MDI_DestroyChild {child} {
   global MDI_cvars MDI_vars

   if {![info exist MDI_cvars($child,menu_pos)]} return

   # remove the child from the window list
   # $MDI_vars(window_menu_path).m delete $MDI_cvars($child,menu_pos)
   # decrease the menu pos of all the childs
   # with a menu pos higher then the deleted
   for {set n 0} {$n < $MDI_vars(max_child)} {incr n} {
      # get children
      if {[info exist MDI_cvars($n,menu_pos)]} {
         if {$MDI_cvars($n,menu_pos) > $MDI_cvars($child,menu_pos)} {
            incr MDI_cvars($n,menu_pos) -1
         }
      }
   }

   # incr MDI_vars(menu_entrys) -1

   set retval [MDIchild_Delete $child]

   # to activate the next in order
   MDI_ActivateNextChild

   return $retval
}


# ---------------------------------------------------------
# iconify child in mainframe frame
# ---------------------------------------------------------

proc MDI_IconifyChild {child title {image ""}} {
   global MDI_cvars MDI_vars

   set father [winfo parent $MDI_cvars($child,this)]

   if {[winfo exists $father.iconb$child] == 0} {
      set icon_frame [frame $father.iconb$child -borderwidth 2 \
         -relief raised]
      if {$image == ""} {
         set image [tix getimage window04a]
      }
      set icon_image [label $icon_frame.lbl -relief raised -bd 0 \
         -image $image -padx 2 -pady 2]
      set icon_button [MkFlatButton $icon_frame btn $title]
      $icon_button config -bd 0

      $icon_button config -font $MDI_vars(title_font) -command \
         "MDI_DeiconifyChild $child"

      pack $icon_image $icon_button -side left -fill both -ipadx 2 \
         -ipady 2
      pack $icon_frame -anchor sw -side bottom -padx 5 -pady 1

      lower $icon_frame
   }
}


# ---------------------------------------------------------
# deiconify child in mainframe frame
# ---------------------------------------------------------

proc MDI_DeiconifyChild {child} {
   global MDI_cvars MDI_vars

   set father [winfo parent $MDI_cvars($child,this)]

   MDIchild_Show $child
   MDI_ActivateChild $child
}


# ---------------------------------------------------------
# activate child in MDI main frame
# ---------------------------------------------------------

proc MDI_ActivateChild {child {from_child 0}} {
   global MDI_cvars MDI_vars

   update idletasks

   if {![info exist MDI_cvars($child,this)]} {
      return
   }
   if {![winfo exist $MDI_cvars($child,this)]} {
      return
   }

   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      if {[info exist MDI_cvars($i,this)]} {
         if {$MDI_cvars($i,maximize)} {
            if {$i != $child && !$MDI_cvars($i,hide)} {
               MDIchild_Maximize $i
            }
         }
      }
   }

   # actual window absolute screen pos
   set MDI_cvars($child,xw) [winfo x $MDI_cvars($child,this)]
   set MDI_cvars($child,yw) [winfo y $MDI_cvars($child,this)]
   # actual window height and width
   set MDI_cvars($child,width) [winfo w $MDI_cvars($child,this)]
   set MDI_cvars($child,height) [winfo h $MDI_cvars($child,this)]

   # deactivate an old one
   if {($child != $MDI_vars(curr_child))} {
      if {[info exist MDI_cvars($MDI_vars(curr_child),this)]} {
         $MDI_cvars($MDI_vars(curr_child),this).titlebar configure \
            -bg $MDI_vars(child_disabled_bg)
         $MDI_cvars($MDI_vars(curr_child),this).titlebar.title \
            configure -fg $MDI_vars(child_disabled_fg) \
            -bg $MDI_vars(child_disabled_bg)
      }

      for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
         if {$MDI_vars(order,$i) == $child} break
      }

      if {$i < $MDI_vars(max_child)} {
         # move all one place back until the position of child
         for {set j $i} {$j > 0} {incr j -1} {
            set MDI_vars(order,$j) $MDI_vars(order,[expr $j-1])
         }
      } else {
         # move all one place back until the last list position
         for {set j [expr $MDI_vars(max_child)-1]} {$j > 0} {incr j \
            -1} {
            set MDI_vars(order,$j) $MDI_vars(order,[expr $j-1])
         }
      }

      # now the position with highest priority is free
      set MDI_vars(order,0) $child
   }

   # to notify a winow, created from outerspace
   # if {$from_child} {
   #    eval $MDI_cvars($child,activate_cmd)
   # }

   raise $MDI_cvars($child,this)
   $MDI_cvars($child,this).titlebar configure \
      -bg $MDI_vars(child_enabled_bg)
   $MDI_cvars($child,this).titlebar.title configure \
      -fg $MDI_vars(child_enabled_fg) -bg $MDI_vars(child_enabled_bg)

   # update the title of the windows entry in the window list
   # $MDI_vars(window_menu_path).m entryconfigure   \
      $MDI_cvars($child,menu_pos)  #       \
      -label $MDI_cvars($child,title)
   update

   set MDI_vars(curr_child) $child
}


# ---------------------------------------------------------
# activate next child in order in MDI main frame
# ---------------------------------------------------------

proc MDI_ActivateNextChild {} {
   global MDI_cvars MDI_vars

   # first count the existing childs
   set child_no 0
   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      if {[info exist MDI_cvars($i,this)]} {
         if {[winfo exist $MDI_cvars($i,this)]} {
            incr child_no
         }
      }
   }

   # count the child in the order list
   set child_list ""
   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      if {[info exist MDI_cvars($MDI_vars(order,$i),this)]} {
         if {[winfo exist $MDI_cvars($MDI_vars(order,$i),this)]} {
            lappend child_list $MDI_vars(order,$i)
         }
      }
   }

   # shrink the order list
   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      if {$i < [llength $child_list]} {
         set MDI_vars(order,$i) [lindex $child_list $i]
      } else {
         set MDI_vars(order,$i) -1
      }
   }

   if {$child_no != [llength $child_list]} {
      puts stdout "Child list inconsistence"
   }

   set MDI_vars(curr_child) $MDI_vars(order,0)
   MDI_ActivateChild $MDI_vars(order,0) 1
}


# ---------------------------------------------------------
# create new MDI child 
# ---------------------------------------------------------

proc MDIchild_New {name} {
   global MDI_cvars MDI_vars

   for {set i 0} {$i < $MDI_vars(max_child)} {incr i} {
      if {![info exist MDI_cvars($i,this)]} {
         break
      }
   }

   set MDI_cvars($i,close_cmd) "MDIchild_Delete $i"
   set MDI_cvars($i,activate_cmd) "MDI_ActivateChild $i 1"
   set MDI_cvars($i,hide_cmd) ""
   set MDI_cvars($i,client_path) ""
   set MDI_cvars($i,title) $name

   # private
   set MDI_cvars($i,xw) 0
   set MDI_cvars($i,yw) 0
   set MDI_cvars($i,width) 600
   set MDI_cvars($i,height) 400
   set MDI_cvars($i,old_xw) 0
   set MDI_cvars($i,old_yw) 0
   set MDI_cvars($i,old_width) 600
   set MDI_cvars($i,old_height) 400
   set MDI_cvars($i,sm) ""
   set MDI_cvars($i,xp) 0
   set MDI_cvars($i,yp) 0
   set MDI_cvars($i,xpn) 0
   set MDI_cvars($i,ypn) 0
   set MDI_cvars($i,menu_pos) ""
   set MDI_cvars($i,hide) 0
   set MDI_cvars($i,maximize) 0
   set MDI_cvars($i,resizable) 1
   set MDI_cvars($i,this) "$MDI_vars(this).child$i"
   set MDI_cvars($i,close_double) 0

   return $i
}


# ---------------------------------------------------------
# delete MDI child 
# ---------------------------------------------------------

proc MDIchild_Delete {n} {
   global MDI_cvars MDI_vars

   if {![info exist MDI_cvars($n,this)]} {
      return 0
   }

   if {[winfo exist $MDI_cvars($n,this)]} {
      place forget $MDI_cvars($n,this)
      destroy $MDI_cvars($n,this)
   }

   unset MDI_cvars($n,close_cmd)
   unset MDI_cvars($n,activate_cmd)
   unset MDI_cvars($n,title)

   unset MDI_cvars($n,xw)
   unset MDI_cvars($n,yw)
   unset MDI_cvars($n,width)
   unset MDI_cvars($n,height)
   unset MDI_cvars($n,old_xw)
   unset MDI_cvars($n,old_yw)
   unset MDI_cvars($n,old_width)
   unset MDI_cvars($n,old_height)
   unset MDI_cvars($n,sm)
   unset MDI_cvars($n,xp)
   unset MDI_cvars($n,yp)
   unset MDI_cvars($n,xpn)
   unset MDI_cvars($n,ypn)
   unset MDI_cvars($n,menu_pos)
   unset MDI_cvars($n,hide)
   unset MDI_cvars($n,maximize)
   unset MDI_cvars($n,resizable)
   unset MDI_cvars($n,this)
   unset MDI_cvars($n,close_double)

   return 1
}


# ---------------------------------------------------------
# create child's window
# ---------------------------------------------------------

proc MDIchild_CreateWindow {n {iconify 1} {maximize 1} {winclose 1}} {
   global MDI_cvars env MDI_vars

   # create the MDI window
   frame $MDI_cvars($n,this) -relief $MDI_vars(frame_relief) -bg \
      [$MDI_vars(this) cget -bg] -bd $MDI_vars(frame_width)

   # frame for title
   frame $MDI_cvars($n,this).titlebar \
      -background $MDI_vars(child_disabled_bg)
   pack $MDI_cvars($n,this).titlebar -fill x -side top

   # the frame for client data
   set MDI_cvars($n,client_path) $MDI_cvars($n,this).client
   frame $MDI_cvars($n,client_path) -relief flat \
      -bg $MDI_vars(background)
   pack $MDI_cvars($n,client_path) -fill both -side top -expand 1

   label $MDI_cvars($n,this).titlebar.title \
      -textvariable MDI_cvars($n,title) -anchor w -padx 20 \
      -font $MDI_vars(title_font) -bg $MDI_vars(child_disabled_bg) \
      -fg $MDI_vars(child_disabled_fg)

   button $MDI_cvars($n,this).titlebar.close -command \
      "$MDI_cvars($n,close_cmd)" -width $MDI_vars(button_width) \
      -height $MDI_vars(button_width) -relief raised -borderwidth 1 \
      -highlightthickness 0 -background grey -image [tix getimage \
      close] -anchor c -padx 2 -pady 0

   if {!$winclose} {
      $MDI_cvars($n,this).titlebar.close config -state disabled
   }

   button $MDI_cvars($n,this).titlebar.min -command \
      "MDIchild_Hide $n" -width $MDI_vars(button_width) \
      -height $MDI_vars(button_width) -relief raised -borderwidth 1 \
      -highlightthickness 0 -background grey -image [tix getimage \
      minsize] -anchor c

   if {!$iconify} {
      $MDI_cvars($n,this).titlebar.min config -state disabled
   }

   button $MDI_cvars($n,this).titlebar.max -command \
      "MDIchild_Maximize $n" -width $MDI_vars(button_width) \
      -height $MDI_vars(button_width) -relief raised -borderwidth 1 \
      -highlightthickness 0 -background grey -image [tix getimage \
      maxsize] -anchor c

   if {!$maximize} {
      $MDI_cvars($n,this).titlebar.max config -state disabled
      set MDI_cvars($n,resizable) 0
   }

   if {$winclose} {
      pack $MDI_cvars($n,this).titlebar.close -side right -padx 3 -pady 2
   }
   pack $MDI_cvars($n,this).titlebar.title -fill x -expand 1 \
      -side left -padx 5 -pady 2
   if {$maximize} {
      pack $MDI_cvars($n,this).titlebar.max -side right -padx 1 -pady 2
   }
   if {$iconify} {
      pack $MDI_cvars($n,this).titlebar.min -side right -padx 1 -pady 2
   }

   # bindings

   # bind $MDI_cvars($n,client_path) <Enter> "MDIchild_EnterFrame $n %X %Y"
   bind $MDI_cvars($n,client_path) <Leave> "MDIchild_LeaveFrame $n"

   # now the bindings, especially for moving !!
   bind $MDI_cvars($n,this) <1> "
      set MDI_cvars($n,xp) %X
      set MDI_cvars($n,yp) %Y
      MDI_ActivateChild $n 1
   "
   bind $MDI_cvars($n,this) <B1-Motion> "MDIchild_ResizeFrame $n %X \
      %Y"
   bind $MDI_cvars($n,this) <ButtonRelease-1> \
      "MDIchild_RepackFrame $n"
   bind $MDI_cvars($n,this) <Motion> "MDIchild_EnterFrame $n %X %Y"
   bind $MDI_cvars($n,this) <Enter> "MDIchild_EnterFrame $n %X %Y"

   bind $MDI_cvars($n,this).titlebar.title <Enter> \
      "$MDI_cvars($n,this).titlebar configure \
      -cursor $MDI_vars(title_enter_cur)"
   bind $MDI_cvars($n,this).titlebar.title <1> "
      set MDI_cvars($n,xp) %X
      set MDI_cvars($n,yp) %Y
      MDI_ActivateChild $n 1
   "
   if {$maximize} {
      bind $MDI_cvars($n,this).titlebar.title <Double-1> \
         "MDIchild_Maximize $n"
   }
   bind $MDI_cvars($n,this).titlebar.title <3> \
      "lower $MDI_cvars($n,this)"
   bind $MDI_cvars($n,this).titlebar.title <B1-Motion> \
      "MDIchild_Move $n %X %Y"
   bind $MDI_cvars($n,this).titlebar.title <ButtonRelease-1> \
      "MDIchild_Place $n %X %Y"

   bind $MDI_cvars($n,this).titlebar.min <Enter> \
      "$MDI_cvars($n,this).titlebar.max configure \
      -cursor $MDI_vars(but_enter_cur)"
   bind $MDI_cvars($n,this).titlebar.max <Enter> \
      "$MDI_cvars($n,this).titlebar.min configure \
      -cursor $MDI_vars(but_enter_cur)"
   bind $MDI_cvars($n,this).titlebar.close <Enter> "
      $MDI_cvars($n,this).titlebar.close configure \
         -cursor $MDI_vars(but_enter_cur)
   "
   # bind $MDI_cvars($n,this).titlebar.close <Leave> "break"
   # bind $MDI_cvars($n,this).titlebar.close <ButtonPress-1>  #   \
      "MDIchild_Close $n 2"

   # make the window visible with MDIchild_Show from the calling   \
      class, 
   # after you have set his client data
   # e.g. his child frames
   set MDI_cvars($n,xw) $MDI_vars(child_x)
   set MDI_cvars($n,yw) $MDI_vars(child_y)
}


# ---------------------------------------------------------
# move child's window
# ---------------------------------------------------------

proc MDIchild_Move {n xpn ypn} {
   global MDI_cvars MDI_vars

   if {$n != $MDI_vars(curr_child)} return
   if {$MDI_cvars($n,maximize)} return

   if {$MDI_vars(idle)} return

   set MDI_cvars(idle) 1
   set xn [expr $MDI_cvars($n,xw)+$xpn-$MDI_cvars($n,xp)]
   set yn [expr $MDI_cvars($n,yw)+$ypn-$MDI_cvars($n,yp)]

   if {$xn < 0} {
      set xn 0
   }
   if {$xn > [expr $MDI_vars(width) - [winfo width \
      $MDI_cvars($n,this)]]} {
      set xn [expr $MDI_vars(width) - [winfo width \
         $MDI_cvars($n,this)]]
   }
   if {$yn < 0} {
      set yn 0
   }
   if {$yn > [expr $MDI_vars(height) - [winfo height \
      $MDI_cvars($n,this).titlebar]]} {
      set yn [expr $MDI_vars(height) - [winfo height \
         $MDI_cvars($n,this).titlebar]]
   }

   place $MDI_cvars($n,this) -x $xn -y $yn

   update idletasks
   set MDI_vars(idle) 0
}


# ---------------------------------------------------------
# fix child's position
# ---------------------------------------------------------

proc MDIchild_Place {n xpn ypn} {
   global MDI_cvars MDI_vars

   set MDI_cvars($n,xw) [expr $MDI_cvars($n,xw) + $xpn - $MDI_cvars($n,xp)]
   set MDI_cvars($n,yw) [expr $MDI_cvars($n,yw) + $ypn - $MDI_cvars($n,yp)]
}

# ---------------------------------------------------------
# leave child's window title frame
# ---------------------------------------------------------

proc MDIchild_LeaveFrame {n} {
   global MDI_cvars MDI_vars

   if {[$MDI_cvars($n,client_path) cget -cursor] != \
      $MDI_vars(standard_cur)} {
      set MDI_cvars($n,sm) ""
      $MDI_cvars($n,this) configure -cursor $MDI_vars(standard_cur)
   }
   # tkCancelRepeat
}


# ---------------------------------------------------------
# enter child's window title frame
# ---------------------------------------------------------

proc MDIchild_EnterFrame {n xp yp} {
   global MDI_cvars MDI_vars
   global tkPriv

   if {$MDI_cvars($n,maximize)} return
   if {!$MDI_cvars($n,resizable)} return

   # set tkPriv(afterId) [after 400 MDI_ActivateChild $n]

   # actual pointer pos in window
   set px [expr $xp - [winfo rootx $MDI_cvars($n,this)]]
   set py [expr $yp - [winfo rooty $MDI_cvars($n,this)]]

   # set px [expr $xp - $MDI_cvars($n,xw)]
   # set py [expr $yp - $MDI_cvars($n,yw)]

   # difference between corner len and width, height as a threshold
   set xdif [expr $MDI_cvars($n,width) - $MDI_vars(child_corner_len)]
   set ydif [expr $MDI_cvars($n,height) - $MDI_vars(child_corner_len)]

   set fw [expr 2*$MDI_vars(frame_width)]

   if {$px <= $fw} {
      # left side
      if {$py < $MDI_vars(child_corner_len)} {
         # upper corner
         if {$MDI_cvars($n,sm) != "nw"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(tl_edge_enter_cur)
            set MDI_cvars($n,sm) "nw"
         }
      } \
      elseif {$py > $ydif} {
         # lower corner
         if {$MDI_cvars($n,sm) != "sw"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(bl_edge_enter_cur)
            set MDI_cvars($n,sm) "sw"
         }
      } else {
         # left side between corners
         if {$MDI_cvars($n,sm) != "ww"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(frame_left_enter_cur)
            set MDI_cvars($n,sm) "ww"
         }
      }
   } \
   elseif {$py <= $fw} {
      # top side
      if {$px < $MDI_vars(child_corner_len)} {
         # left corner
         if {$MDI_cvars($n,sm) != "nw"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(tl_edge_enter_cur)
            set MDI_cvars($n,sm) "nw"
         }
      } \
      elseif {$px > $xdif} {
         # right corner
         if {$MDI_cvars($n,sm) != "ne"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(tr_edge_enter_cur)
            set MDI_cvars($n,sm) "ne"
         }
      } else {
         # top side betweeen corners
         if {$MDI_cvars($n,sm) != "nn"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(frame_top_enter_cur)
            set MDI_cvars($n,sm) "nn"
         }
      }
   } \
   elseif {$px >= [expr $MDI_cvars($n,width) - $fw]} {
      # right side
      if {$py < $MDI_vars(child_corner_len)} {
         #  upper corner
         if {$MDI_cvars($n,sm) != "ne"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(tr_edge_enter_cur)
            set MDI_cvars($n,sm) "ne"
         }
      } \
      elseif {$py > $ydif} {
         # lower corner
         if {$MDI_cvars($n,sm) != "se"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(br_edge_enter_cur)
            set MDI_cvars($n,sm) "se"
         }
      } else {
         # right side betweeen corners
         if {$MDI_cvars($n,sm) != "ee"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(frame_right_enter_cur)
            set MDI_cvars($n,sm) "ee"
         }
      }
   } \
   elseif {$py >= [expr $MDI_cvars($n,height) - $fw]} {
      # bottom side
      if {$px < $MDI_vars(child_corner_len)} {
         #  left corner
         if {$MDI_cvars($n,sm) != "sw"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(bl_edge_enter_cur)
            set MDI_cvars($n,sm) "sw"
         }
      } \
      elseif {$px > $xdif} {
         # right corner
         if {$MDI_cvars($n,sm) != "se"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(br_edge_enter_cur)
            set MDI_cvars($n,sm) "se"
         }
      } else {
         # bottom side betweeen corners
         if {$MDI_cvars($n,sm) != "ss"} {
            $MDI_cvars($n,this) configure \
               -cursor $MDI_vars(frame_bottom_enter_cur)
            set MDI_cvars($n,sm) "ss"
         }
      }
   }
}


# ---------------------------------------------------------
# resize child's window
# ---------------------------------------------------------

proc MDIchild_ResizeFrame {n xpn ypn} {
   global MDI_cvars MDI_vars

   # if {$n != $MDI_vars(act_child)} return
   if {$MDI_cvars($n,maximize)} return
   if {!$MDI_cvars($n,resizable)} return

   if {$MDI_vars(idle)} return

   set MDI_vars(idle) 1

   # only resize an empty frame
   if {![string match $MDI_cvars($n,client_path) [pack slaves \
      $MDI_cvars($n,this)]]} {
      pack forget $MDI_cvars($n,client_path)
   }
   if {[$MDI_cvars($n,this) cget -bg] != $MDI_vars(background)} {
      $MDI_cvars($n,this) configure -bg $MDI_vars(background)
   }

   if {[string match "*e*" $MDI_cvars($n,sm)]} {
      set nw [expr $MDI_cvars($n,width) + $xpn-$MDI_cvars($n,xp)]
   } \
   elseif {[string match "*w*" $MDI_cvars($n,sm)]} {
      set nw [expr $MDI_cvars($n,width) - ($xpn-$MDI_cvars($n,xp))]
      set nx [expr $MDI_cvars($n,xw) + ($xpn-$MDI_cvars($n,xp))]
   }

   if {[string match "*s*" $MDI_cvars($n,sm)]} {
      set nh [expr $MDI_cvars($n,height) + $ypn-$MDI_cvars($n,yp)]
   } \
   elseif {[string match "*n*" $MDI_cvars($n,sm)]} {
      set nh [expr $MDI_cvars($n,height) - ($ypn-$MDI_cvars($n,yp))]
      set ny [expr $MDI_cvars($n,yw) + ($ypn-$MDI_cvars($n,yp))]
   }

   switch $MDI_cvars($n,sm) {
   "ee" {
         set MDI_cvars($n,width) $nw
         set MDI_cvars($n,xp) $xpn
      }
   "ss" {
         set MDI_cvars($n,height) $nh
         set MDI_cvars($n,yp) $ypn
      }
   "se" {
         set MDI_cvars($n,width) $nw
         set MDI_cvars($n,xp) $xpn
         set MDI_cvars($n,height) $nh
         set MDI_cvars($n,yp) $ypn
      }
   "ww" {
         set MDI_cvars($n,width) $nw
         set MDI_cvars($n,xp) $xpn
         set MDI_cvars($n,xw) $nx
      }
   "nn" {
         set MDI_cvars($n,height) $nh
         set MDI_cvars($n,yp) $ypn
         set MDI_cvars($n,yw) $ny
      }
   "nw" {
         set MDI_cvars($n,width) $nw
         set MDI_cvars($n,xp) $xpn
         set MDI_cvars($n,xw) $nx
         set MDI_cvars($n,height) $nh
         set MDI_cvars($n,yp) $ypn
         set MDI_cvars($n,yw) $ny
      }
   "ne" {
         set MDI_cvars($n,height) $nh
         set MDI_cvars($n,yp) $ypn
         set MDI_cvars($n,yw) $ny
         set MDI_cvars($n,width) $nw
         set MDI_cvars($n,xp) $xpn
      }
   "sw" {
         set MDI_cvars($n,height) $nh
         set MDI_cvars($n,yp) $ypn
         set MDI_cvars($n,width) $nw
         set MDI_cvars($n,xp) $xpn
         set MDI_cvars($n,xw) $nx
      }
   }
   place $MDI_cvars($n,this) -width $MDI_cvars($n,width) \
      -height $MDI_cvars($n,height) -x $MDI_cvars($n,xw) \
      -y $MDI_cvars($n,yw)

   update
   set MDI_vars(idle) 0
}


proc MDIchild_RepackFrame {me} {
   global MDI_cvars MDI_vars

   if {![string match $MDI_cvars($me,client_path) [pack slaves \
      $MDI_cvars($me,this)]]} {
      pack $MDI_cvars($me,client_path) -fill both -side bottom \
         -expand 1
   }
   if {[$MDI_cvars($me,this) cget -bg] != \
      $MDI_vars(child_frame_color)} {
      $MDI_cvars($me,this) configure -bg $MDI_vars(child_frame_color)
   }
}


# ---------------------------------------------------------
# display child's window
# ---------------------------------------------------------

proc MDIchild_Show {n} {
   global MDI_cvars MDI_vars

   if {$MDI_cvars($n,maximize)} {
      if {$MDI_cvars($n,hide)} {
         pack $MDI_cvars($n,this) -fill both -expand true
      }
   } else {
      set w [winfo width $MDI_cvars($n,this).titlebar.title]
      set h [winfo height $MDI_cvars($n,this).titlebar.title]
      set x [winfo x $MDI_cvars($n,this).titlebar.title]
      set y [winfo y $MDI_cvars($n,this).titlebar.title]

      set x [expr $x + $MDI_cvars($n,xw)]
      set y [expr $y + $MDI_cvars($n,yw)]

      set x [expr $x + $MDI_cvars($n,xw)]
      set y [expr $y + $MDI_cvars($n,yw)]
      set x $MDI_cvars($n,xw)
      set y $MDI_cvars($n,yw)
      set w $MDI_cvars($n,width)
      set h $MDI_cvars($n,height)

      if {($x > [winfo width $MDI_vars(this)]) ||([expr $x + $w] < \
         0)} {
         set MDI_cvars($n,xw) $MDI_vars(child_x)
      }

      if {($y > [winfo height $MDI_vars(this)]) ||([expr $y + $h] < \
         0)} {
         set MDI_cvars($n,yw) $MDI_vars(child_y)
      }

      place $MDI_cvars($n,this) -x $MDI_cvars($n,xw) \
         -y $MDI_cvars($n,yw) -width $MDI_cvars($n,width) \
         -height $MDI_cvars($n,height)
   }
   set MDI_cvars($n,hide) 0

   # if {[$MDI_cvars($n,this) cget -bg] !=  #    \
      $MDI_vars(child_frame_color)} {
   #    after 20 "$MDI_cvars($n,this) configure    #       \
      -bg $MDI_vars(child_frame_color)"
   # }
}


# ---------------------------------------------------------
# maximize child's window
# ---------------------------------------------------------

proc MDIchild_Maximize {n} {
   global MDI_cvars MDI_vars

   # currently not supported
   # return

   if {! $MDI_cvars($n,maximize)} {
      set MDI_cvars($n,maximize) 1
      update
      # actual window absolute screen pos
      set MDI_cvars($n,old_xw) [winfo x $MDI_cvars($n,this)]
      set MDI_cvars($n,old_yw) [winfo y $MDI_cvars($n,this)]
      # actual window height and width
      set MDI_cvars($n,old_width) [winfo w $MDI_cvars($n,this)]
      set MDI_cvars($n,old_height) [winfo h $MDI_cvars($n,this)]

      $MDI_cvars($n,this).titlebar.max configure -image \
         [tix getimage resize]
      bind $MDI_cvars($n,this).titlebar.title <3> "break"

      pack $MDI_cvars($n,this) -fill both -expand true
   } else {
      set MDI_cvars($n,maximize) 0
      pack forget $MDI_cvars($n,this)

      $MDI_cvars($n,this).titlebar.max configure -image \
         [tix getimage maxsize]
      bind $MDI_cvars($n,this).titlebar.title <3> \
         "lower $MDI_cvars($n,this)"

      place $MDI_cvars($n,this) -x $MDI_cvars($n,old_xw) \
         -y $MDI_cvars($n,old_yw) -width $MDI_cvars($n,old_width) \
         -height $MDI_cvars($n,old_height)
      update
      # actual window absolute screen pos
      set MDI_cvars($n,xw) [winfo x $MDI_cvars($n,this)]
      set MDI_cvars($n,yw) [winfo y $MDI_cvars($n,this)]
      # actual window height and width
      set MDI_cvars($n,width) [winfo w $MDI_cvars($n,this)]
      set MDI_cvars($n,height) [winfo h $MDI_cvars($n,this)]
   }
}


# ---------------------------------------------------------
# hide child's window
# ---------------------------------------------------------

proc MDIchild_Hide {n} {
   global MDI_cvars MDI_vars

   # actual window absolute screen pos
   # set MDI_cvars($n,xw) [winfo x $MDI_cvars($n,this)]
   # set MDI_cvars($n,yw) [winfo y $MDI_cvars($n,this)]
   # actual window height and width
   # set MDI_cvars($n,width) [winfo w $MDI_cvars($n,this)]
   # set MDI_cvars($n,height) [winfo h $MDI_cvars($n,this)]

   set MDI_cvars($n,hide) 1

   if {$MDI_cvars($n,hide_cmd) != ""} {
      eval $MDI_cvars($n,hide_cmd)
      place forget $MDI_cvars($n,this)
   }
}


# ---------------------------------------------------------
# close child's window
# ---------------------------------------------------------

proc MDIchild_Close {n mode} {
   global MDI_cvars MDI_vars

   $MDI_cvars($n,this).titlebar.close configure -relief sunken

   switch $mode {
   "1p" {
         after 200 {set i1 1}
         tkwait variable i1
         if {$MDI_cvars($n,close_double)} {
            eval $MDI_cvars($n,close_cmd)
         } else {
            $MDI_cvars($n,this).titlebar.menu unpost
            set x [winfo x $MDI_cvars($n,this).titlebar.close]
            set y [winfo y $MDI_cvars($n,this).titlebar.close]
            set y [expr $y + [winfo height \
               $MDI_cvars($n,this).titlebar.close]]
            $MDI_cvars($n,this).titlebar.menu post $x $y
            grab $MDI_cvars($n,this).titlebar.menu
         }
         set MDI_cvars($n,close_double) 0
      }
   "2" {
         set MDI_cvars($n,close_double) 1
      }
   }
   if {![info exist MDI_cvars($n,this)]} return
   if {![winfo exist $MDI_cvars($n,this).titlebar.close]} return
   $MDI_cvars($n,this).titlebar.close configure -relief raised
}

