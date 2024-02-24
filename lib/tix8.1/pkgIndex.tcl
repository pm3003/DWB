# Tcl package index file, version 1.0
#
# $Id: pkgIndex.tcl.in,v 1.1 2000/11/03 00:20:31 idiscovery Exp $
#

package ifneeded Tix 8.1.8.3 [list load "[file join [file dirname $dir] libtix8.1.8.3.so]" Tix]
package ifneeded Tixsam 8.1.8.3 [list load "[file join [file dirname $dir] libtixsam8.1.8.3.so]" Tixsam]
