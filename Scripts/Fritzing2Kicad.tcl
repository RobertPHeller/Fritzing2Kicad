#*****************************************************************************
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun May 12 21:59:59 2019
#  Last Modified : <190512.2248>
#
#  Description	
#
#  Notes
#
#  History
#	
#*****************************************************************************
#
#    Copyright (C) 2019  Robert Heller D/B/A Deepwoods Software
#			51 Locke Hill Road
#			Wendell, MA 01379-9728
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# 
#
#*****************************************************************************


package require snit
package require ParseXML


snit::type FritzingPart {
    option -partsdirectory -default {} -readonly yes
    
    component metadata
    component breadboardView
    component schematicView
    component pcbView
    component iconView
    
    constructor {fzpfile args} {
        $self configurelist $args
        if {$options(-partsdirectory) eq {}} {
            set options(-partsdirectory) [file dirname $fzpfile]
        }
        if {[catch {open $fzpfile r} fp]} {
            error [format {Could not open %s (metadata) for reading: %s} $fzpfile $fp]
            exit 90
        }
        install metadata using ParseXML %AUTO% [read $fp]
        close $fp
        set module [$metadata getElementsByTagName module -depth 1]
        if {[llength $module] != 1} {
            error [format {missing or duplicate module tag in %s (metadata)} $fzpfile]
            exit 91
        }
        set views  [$module getElementsByTagName views -depth 1]
        if {[llength $views] != 1} {
            error [format {missing or duplicate views tag in %s (metadata)} $fzpfile]
            exit 93
        }
        foreach c [$views children] {
            switch [$c cget -tag] {
                breadboardView {
                    if {[info exists breadboardView] && $breadboardView ne {}} {
                        error [format {Duplicate breadboardView in %s} $fzpfile]
                        exit 94
                    }
                    set layers [$c getElementsByTagName layers -depth 1]
                    if {[llength $layers] != 1} {
                        error [format {missing or duplicate layers tag in breadboardView in %s (metadata)} $fzpfile]
                        exit 95
                    }
                    set breadboardView_file [file join $options(-partsdirectory)                                              [$layers attribute image]]
                    if {[catch {open $breadboardView_file r} fp]} {
                        error [format {Could not open %s (breadboardView) for reading: %s} $breadboardView_file $fp]
                        exit 96
                    }
                    install breadboardView using ParseXML %AUTO% [read $fp]
                    close $fp
                }
                schematicView {
                    if {[info exists schematicView] && $schematicView ne {}} {
                        error [format {Duplicate schematicView in %s} $fzpfile]
                        exit 94
                    }
                    set layers [$c getElementsByTagName layers -depth 1]
                    if {[llength $layers] != 1} {
                        error [format {missing or duplicate layers tag in schematicView in %s (metadata)} $fzpfile]
                        exit 95
                    }
                    set schematicView_file [file join $options(-partsdirectory)                                              [$layers attribute image]]
                    if {[catch {open $schematicView_file r} fp]} {
                        error [format {Could not open %s (schematicView) for reading: %s} $schematicView_file $fp]
                        exit 96
                    }
                    install schematicView using ParseXML %AUTO% [read $fp]
                    close $fp
                }
                pcbView {
                    if {[info exists pcbView] && $pcbView ne {}} {
                        error [format {Duplicate pcbView in %s} $fzpfile]
                        exit 94
                    }
                    set layers [$c getElementsByTagName layers -depth 1]
                    if {[llength $layers] != 1} {
                        error [format {missing or duplicate layers tag in pcbView in %s (metadata)} $fzpfile]
                        exit 95
                    }
                    set pcbView_file [file join $options(-partsdirectory)                                              [$layers attribute image]]
                    if {[catch {open $pcbView_file r} fp]} {
                        error [format {Could not open %s (pcbView) for reading: %s} $pcbView_file $fp]
                        exit 96
                    }
                    install pcbView using ParseXML %AUTO% [read $fp]
                    close $fp
                }
                iconView {
                    if {[info exists iconView] && $iconView ne {}} {
                        error [format {Duplicate iconView in %s} $fzpfile]
                        exit 94
                    }
                    set layers [$c getElementsByTagName layers -depth 1]
                    if {[llength $layers] != 1} {
                        error [format {missing or duplicate layers tag in iconView in %s (metadata)} $fzpfile]
                        exit 95
                    }
                    set iconView_file [file join $options(-partsdirectory)                                              [$layers attribute image]]
                    if {[catch {open $iconView_file r} fp]} {
                        error [format {Could not open %s (iconView) for reading: %s} $iconView_file $fp]
                        exit 96
                    }
                    install iconView using ParseXML %AUTO% [read $fp]
                    close $fp
                }
                default {
                    puts stderr [format {Warning: unknown view tag (%s) ignored in %s} [$c cget -tag] $fzpfile]
                }
            }
        }
    }

    method toString {} {
        return [format {#$s<metadata=%s, breadboardView=%s, schematicView=%s, pcbView=%s, iconView=%s} \
                $metadata $breadboardView $schematicView $pcbView $iconView]
    }
    
    typeconstructor {
        global argc
        global argv
        global argv0
        
        if {$argv > 0} {
            set filename [lindex $argv 0]
            set fpz [$type create %AUTO% $filename]
            puts stdout [format {%s loaded: %s} $filename [$fpz toString]]
        }
        exit 0
    }
    
}

        
