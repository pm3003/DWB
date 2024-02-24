#
# $Id: Numerals.tcl,v 1.4 1999/07/02 21:57:02 jenglish Exp $
#
# Created 23 Jan 1995; updated 9 May 1995
#
# Procedures for formatting numbers:
#
#	arabic n
#		format 'n' as an arabic numberal (basically a no-op)
#	lcroman n
#	ucroman n 
#		lower- and upper-case Roman numeral
#	lcalpha n
#	ucalpha n
#		lower- and upper-case alphabetic (a, b, c, ... z).
#	englishNumber n
#		format 'n' as an English word
#
#  Bugs:
#	lcalpha and ucalpha barf if n > 26.
#	Need other styles:
#		a, ..., z, aa, bb, cc, ... zz
#		a, ..., z, ab, ac, ad, ... az, ba (?)
#
#  	All routines assume the input is in fact a number.
#

package provide Cost-Numerals 1.1

proc arabic {n} { return [string trim $n] }

# romanNumeral: internal routine
proc romanNumeral {x} {
    set result ""
    if {$x < 0} {
	set x [expr - $x] 
	set result "negative "
    }
    if {$x == 0} {
	error "No roman numeral for zero"
    }
    foreach elem {
	{ 1000	m  }    { 900	cm }    
	{ 500	d  }    { 400	cd }    
	{ 100	c  }    { 90 	xc }    
	{ 50 	l  }    { 40    xl }
	{ 10 	x  }    { 9 	ix }    
	{ 5 	v  }    { 4 	iv }    
	{ 1 	i  }
    } {
	set digit [lindex $elem 0]
	set roman [lindex $elem 1]
	while {$x >= $digit} {
	    append result $roman
	    incr x -$digit
	}
    }
    return $result
}

proc ucroman {x} {
    string toupper [romanNumeral $x]
}

proc lcroman {x} {
     romanNumeral $x
}


global _numeral_alphabet;
set _numeral_alphabet {a b c d e f g h i j k l m n o p q r s t u v w x y z}

proc lcalpha {n} {
    global _numeral_alphabet
    if {$n > 26} { error "Number out of range $n > 26" }
    return [lindex  ${_numeral_alphabet} [expr $n - 1]]
}

proc ucalpha {n} {
    global _numeral_alphabet
    if {$n > 26} { error "Number out of range $n > 26" }
    return [string toupper [lindex  ${_numeral_alphabet} [expr $n - 1]]]
}

# 
# Snarfed off of comp.lang.tcl 30 Jun 1999
# From: Richard.Suchenwirth@kst.siemens.de
# Message-ID: <3779F6B4.6DF5@kst.siemens.de>
#
# English spelling for integer numbers
# 
proc englishNumber {n {optional 0}} {
    if {[catch {set n [expr $n]}]}  {return $n}
    if {$optional && $n==0} {return ""}
    array set dic {
        0 zero 1 one 2 two 3 three 4 four 5 five 6 six 7 seven 
        8 eight 9 nine 10 ten 11 eleven 12 twelve
    }
    if {[info exists dic($n)]} {return $dic($n)}
    foreach {value word} {1000000 million 1000 thousand 100 hundred} {
        if {$n>=$value} {
	    set hi [expr $n / $value]
	    set lo [expr $n % $value]
            return "[englishNumber $hi] $word [englishNumber $lo 1]"
        }
    } ;#--------------- composing between 13 and 99...
    if {$n>=20} {
        set res $dic([expr $n/10])ty
        if  {$n%10} {append res -$dic([expr $n%10])}
    } else {
        set res $dic([expr $n-10])teen
    } ;#----------- fix over-regular compositions
    regsub "twoty"  $res "twenty" res
    regsub "threet" $res "thirt"  res
    regsub "fourt"  $res "fort"   res
    regsub "fivet"  $res "fift"   res
    regsub "eightt" $res "eight"  res
    return $res
}

#*EOF*
