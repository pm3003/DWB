#
# $Id: pkgIndex.tcl,v 1.13 2002/05/01 20:38:17 joe Exp $
# pkgIndex.tcl for Cost
#
# This file is NOT automatically generated.
#

package ifneeded Cost 2.3 \
    [list load [file join $dir cost23[info sharedlibextension]] ] ;
package ifneeded rtflib 1.0	[list source [file join $dir rtflib.tcl]]
package ifneeded htmllib 0.7	[list source [file join $dir htmllib.tcl]]

# package scripts for Cost-specific packages are set up in costinit.tcl
