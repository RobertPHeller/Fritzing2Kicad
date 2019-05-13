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
#  Last Modified : <190513.0943>
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

snit::type FritzingView {
    option -metafilename -default {} -readonly yes
    option -partsdirectory -default {} -readonly yes
    component svg -public svg
    variable _layers [list]
    method LayerCount {} {return [llength $_layers]}
    method LayerId {i} {return [lindex $_layers $i]}
    method AllLayerIds {} {
        set ids [list]
        for {set i 0} {$i < [$self LayerCount]} {incr i} {
            lappend ids [$self LayerId $i]
        }
        return $ids
    }
    variable _filename
    
    constructor {view args} {
        $self configurelist $args
        set layers [$view getElementsByTagName layers -depth 1]
        if {[llength $layers] != 1} {
            error [format {missing or duplicate layers tag in view (metafile: %s)} $options(-metafilename)]
            exit 95
        }
        set _filename [file join $options(-partsdirectory)                                              [$layers attribute image]]
        if {[catch {open $_filename r} fp]} {
            error [format {Could not open %s (view_file) for reading: %s} $_filename $fp]
            exit 96
        }
        install svg using ParseXML %AUTO% [read $fp]
        close $fp
        foreach c [$layers children] {
            if {[$c cget -tag] eq "layer"} {
                lappend _layers [$c attribute layerId]
            }
        }
    }
    method toString {} {
        return [format {<#%s %d layer%s: %s>} $self \
                [$self LayerCount] [expr {([$self LayerCount] == 1)?"":"s"}] \
                [$self AllLayerIds]]
    }
    
}

snit::type FritzingMetadata {
    component svg -public svg
    variable _module
    variable _views
    variable _properties
    variable _connectors
    variable _buses
    variable _url
    constructor {partfile args} {
        if {[catch {open $partfile r} fp]} {
            error [format {Could not open %s (metadata) for reading: %s} $partfile $fp]
            exit 90
        }
        install svg using ParseXML %AUTO% [read $fp]
        close $fp
        set _module [$svg getElementsByTagName module -depth 1]
        if {[llength $_module] != 1} {
            error [format {missing or duplicate module tag in %s (metadata)} $partfile]
            exit 91
        }
        set _views  [$_module getElementsByTagName views -depth 1]
        if {[llength $_views] != 1} {
            error [format {missing or duplicate views tag in %s (metadata)} $partfile]
            exit 93
        }
        set _properties [$_module getElementsByTagName properties -depth 1]
        if {[llength $_properties] != 1} {
            error [format {missing or duplicate properties tag in %s (metadata)} $partfile]
            exit 94
        }
        set _connectors [$_module getElementsByTagName connectors -depth 1]
        set _buses      [$_module getElementsByTagName buses -depth 1]
        set _url        [$_module getElementsByTagName url -depth 1]
    }
    method Module {} {
        return $_module
    }
    method Views  {} {
        return $_views
    }
    method ModuleId {} {
        return [$_module attribute moduleId]
    }
    method ReferenceFile {} {
        return [$_module attribute referenceFile]
    }
    method FritzingVersion {} {
        return [$_module attribute fritzingVersion]
    }
    method Version {} {
        set ver [$_module getElementsByTagName version -depth 1]
        if {[llength $ver] == 1} {
            return [$ver data]
        } else {return {}}
    }
    method Date {} {
        set date [$_module getElementsByTagName date -depth 1]
        if {[llength $date] == 1} {
            return [$date data]
        } else {return {}}
    }
    method Author {} {
        set authors [$_module getElementsByTagName author -depth 1]
        set results [list]
        foreach a $authors {
            lappend results [$a data]
        }
        return $results
    }
    method Description {} {
        set description [$_module getElementsByTagName description -depth 1]
        if {[llength $description] == 1} {
            return [$description data]
        } else {return {}}
    }
    method Title {} {
        set title [$_module getElementsByTagName title -depth 1]
        if {[llength $title] == 1} {
            return [$title data]
        } else {return {}}
    }
    method Label {} {
        set label [$_module getElementsByTagName label -depth 1]
        if {[llength $label] == 1} {
            return [$label data]
        } else {return {}}
    }
    method Tags {} {
        set taglist [list]
        set tags [$_module getElementsByTagName tags -depth 1]
        foreach tag [$tags getElementsByTagName tag -depth 1] {
            lappend taglist [$tag data]
        }
        return $taglist
    }
    method Properties {} {
        set plist [list]
        foreach p [$_properties getElementsByTagName property -depth 1] {
            lappend plist [$p attribute name]
        }
        return $plist
    }
    method Property {name} {
        foreach p [$_properties getElementsByTagName property -depth 1] {
            if {$name eq [$p attribute name]} {
                return [$p data]
            }
        }
        return {}
    }
    method URL {} {
        if {[llength $_url] == 1} {
            return [$_url data]
        } else {
            return {}
        }
    }
    method Connectors {} {
        if {[llength $_connectors] == 1} {
            set clist [list]
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    lappend clist [$c attribute name]
                }
            }
            return $clist
        } else {
            return {}
        }
    }
    method {Connector Type} {name} {
        if {[llength $_connectors] == 1} {
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    if {[$c attribute name] eq $name} {
                        return [$c attribute type]
                    }
                }
            }
        }
        return {}
    }
    method {Connector Id} {name} {
        if {[llength $_connectors] == 1} {
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    if {[$c attribute name] eq $name} {
                        return [$c attribute id]
                    }
                }
            }
        }
        return {}
    }
    method {Connector Description} {name} {
        if {[llength $_connectors] == 1} {
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    if {[$c attribute name] eq $name} {
                        set description [$c getElementsByTagName description -depth 1]
                        if {[llength $description] == 1} {
                            return [$description data]
                        }
                    }
                }
            }
        }
        return {}
    }
    method {Connector BreadboardView} {name} {
        if {[llength $_connectors] == 1} {
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    if {[$c attribute name] eq $name} {
                        set views [$c getElementsByTagName views -depth 1]
                        if {[llength $views] == 1} {
                            return [$views getElementsByTagName breadboardView]
                        }
                    }
                }
            }
        }
        return {}
    }
    method {Connector SchematicView} {name} {
        if {[llength $_connectors] == 1} {
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    if {[$c attribute name] eq $name} {
                        set views [$c getElementsByTagName views -depth 1]
                        if {[llength $views] == 1} {
                            return [$views getElementsByTagName schematicView]
                        }
                    }
                }
            }
        }
        return {}
    }
    method {Connector PcbView} {name} {
        if {[llength $_connectors] == 1} {
            foreach c [$_connectors children] {
                if {[$c cget -tag] eq "connector"} {
                    if {[$c attribute name] eq $name} {
                        set views [$c getElementsByTagName views -depth 1]
                        if {[llength $views] == 1} {
                            return [$views getElementsByTagName pcbView]
                        }
                    }
                }
            }
        }
        return {}
    }
    method Buses {} {
        if {[llength $_buses] == 1} {
            set blist [list]
            foreach c [$_buses  children] {
                if {[$c cget -tag] eq "bus"} {
                    lappend blist [$c attribute id]
                }
            }
            return $blist
        } else {
            return {}
        }
    }
    method {Bus Nodes} {busid} {
        if {[llength $_buses] == 1} {
            foreach c [$_buses  children] {
                if {[$c cget -tag] eq "bus" && [$c attribute id] eq $busid} {
                    set nlist [list]
                    foreach c1 [$c children] {
                        if {[$c1 cget -tag] eq "nodeMember"} {
                            lappend nlist [$c1 attribte connectorId]
                        }
                    }
                    return $nlist
                }
            }
        } else {
            return {}
        }
    }
        
    method toString {} {
        return [format {<#%s %s (%s)>} $self [$self ModuleId] [$self Title]]
    }
        
}   

snit::type FritzingPart {
    option -partsdirectory -default {} -readonly yes
    
    variable _filename
    component metadata -public metadata
    component breadboardView -public breadboardView    
    component schematicView -public schematicView
    component pcbView -public pcbView
    component iconView -public iconView
    
    
    constructor {fzpfile args} {
        $self configurelist $args
        if {$options(-partsdirectory) eq {}} {
            set options(-partsdirectory) [file dirname $fzpfile]
        }
        install metadata using FritzingMetadata \
              ${self}_metadata $fzpfile
        set views [$metadata Views]
        foreach c [$views children] {
            switch [$c cget -tag] {
                breadboardView {
                    if {[info exists breadboardView] && $breadboardView ne {}} {
                        error [format {Duplicate breadboardView in %s} $fzpfile]
                        exit 94
                    }
                    install breadboardView using FritzingView \
                          ${self}_breadboardView $c \
                          -metafilename $fzpfile \
                          -partsdirectory $options(-partsdirectory)
                }
                schematicView {
                    if {[info exists schematicView] && $schematicView ne {}} {
                        error [format {Duplicate schematicView in %s} $fzpfile]
                        exit 94
                    }
                    install schematicView using FritzingView \
                          ${self}_schematicView $c \
                          -metafilename $fzpfile \
                          -partsdirectory $options(-partsdirectory)
                }
                pcbView {
                    if {[info exists pcbView] && $pcbView ne {}} {
                        error [format {Duplicate pcbView in %s} $fzpfile]
                        exit 94
                    }
                    install pcbView using FritzingView \
                          ${self}_pcbView $c \
                          -metafilename $fzpfile \
                          -partsdirectory $options(-partsdirectory)
                }
                iconView {
                    if {[info exists iconView] && $iconView ne {}} {
                        error [format {Duplicate iconView in %s} $fzpfile]
                        exit 94
                    }
                    install iconView using FritzingView \
                          ${self}_iconView $c \
                          -metafilename $fzpfile \
                          -partsdirectory $options(-partsdirectory)
                }
                default {
                    puts stderr [format {Warning: unknown view tag (%s) ignored in %s} [$c cget -tag] $fzpfile]
                }
            }
        }
    }

    method toString {} {
        return [format {<#%s metadata=%s, breadboardView=%s, schematicView=%s, pcbView=%s, iconView=%s} \
                $self [$metadata toString] [$breadboardView toString] \
                [$schematicView toString] [$pcbView toString] \
                [$iconView toString]]
    }
    
    typeconstructor {
        global argc
        global argv
        global argv0
        
        if {$argv > 0} {
            set filename [lindex $argv 0]
            
            set fpz [$type create [file rootname [file tail $filename]] $filename]
            puts stdout [format {%s loaded: %s} $filename [$fpz toString]]
        }
        exit 0
    }
    
}

        
