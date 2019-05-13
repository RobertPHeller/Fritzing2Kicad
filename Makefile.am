##-*- makefile -*-############################################################
#
#  System        : 
#  Module        : 
#  Object Name   : $RCSfile$
#  Revision      : $Revision$
#  Date          : $Date$
#  Author        : $Author$
#  Created By    : Robert Heller
#  Created       : Sun May 12 20:48:45 2019
#  Last Modified : <190512.2055>
#
#  Description	
#
#  Notes
#
#  History
#	
#  $Log$
#
##############################################################################
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
##############################################################################




ACLOCAL_AMFLAGS = -I m4

SUBDIRS = BuildScripts BuildData Scripts ExtraDoc
EXTRA_DIST = README.md Doxyfile.in bootstrap

clean-local:
	-rm -rf man html latex Fritzing2Kicad.pdf

Fritzing2KicadModules = 

Fritzing2KicadLib = $(wildcard $(srcdir)/Scripts/*.tcl)

bin_SCRIPTS = Fritzing2Kicad$(EXEEXT)
man_MANS = man1/Fritzing2Kicad.1
pkgdatadir = $(datadir)/$(PACKAGE)/Doc
pkgdata_DATA = Fritzing2Kicad.pdf

install-data-hook: $(top_builddir)/html/index.html
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	   if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	    f=`echo $$p | sed -e 's|^.*/||'`; \
	    echo " $(INSTALL_DATA) '$$d$$p' '$(DESTDIR)$(pkgdatadir)/html/$$f'"; \
	    $(INSTALL_DATA) "$$d$$p" "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done

uninstall-hook:  
	$(INSTALL) -d $(DESTDIR)$(pkgdatadir)/html
	for p in html/*; do \
	   if test -f "$$p"; then d=; else d="$(srcdir)/"; fi; \
	    f=`echo $$p | sed -e 's|^.*/||'`; \
	    echo " rm -f '$(DESTDIR)$(pkgdatadir)/html/$$f'"; \
	    rm -f "$(DESTDIR)$(pkgdatadir)/html/$$f"; \
	done

TCLKIT = $(top_builddir)/BuildData/tclkit${BEXEEXT}
BUILT_SOURCES = $(TCLKIT)

Fritzing2Kicad$(EXEEXT) : Scripts/Fritzing2Kicad.tcl \
	$(Fritzing2KicadLib) $(top_builddir)/html/index.html \
	ExtraDoc/Version.tcl
	-rm -rf Fritzing2Kicad.vfs
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit qwrap $(srcdir)/Scripts/Fritzing2Kicad.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit unwrap Fritzing2Kicad.kit
	-rm -rf Fritzing2Kicad.kit
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Fritzing2Kicad \
		lib $(SNITLIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitDir.kit Fritzing2Kicad \
		lib $(URILIB)
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit -srcdir $(srcdir)/Scripts Fritzing2Kicad \
		lib/Common $(Fritzing2KicadLib) ExtraDoc/Version.tcl
	$(TCLKIT) $(top_srcdir)/BuildScripts/MakePkgIndex.kit Fritzing2Kicad \
		Common
	$(UNZIP) -qq -d Fritzing2Kicad.vfs/lib \
		$(top_srcdir)/BuildData/Tclxml3.1-GenericPureTcl.zip
	$(TCLKIT) $(top_srcdir)/BuildScripts/AddKitFile.kit Fritzing2Kicad \
		Help $(top_builddir)/html/*
	$(TCLKIT) $(top_srcdir)/BuildScripts/sdx.kit wrap Fritzing2Kicad${EXEEXT} -runtime $(top_srcdir)/BuildData/$(TCLKITRUN)
	-rm -rf Fritzing2Kicad.vfs Fritzing2Kicad.kit
endif


$(top_builddir)/html/index.html \
	man1/Fritzing2Kicad.1 \
	Fritzing2Kicad.pdf : Doxyfile Scripts/Fritzing2Kicad.tcl \
		$(Fritzing2KicadModules) $(wildcard ExtraDoc/*.h) \
		ExtraDoc/Version.tcl BuildScripts/tcldoxyfilter.sh
	-rm -rf man1 html latex
	$(DOXYGEN)
	$(MAKE) -C latex
	mv latex/refman.pdf ./Fritzing2Kicad.pdf


Doxyfile: Doxyfile.in
	

$(top_builddir)/BuildData/tclkit${BEXEEXT}: FORCE
	$(MAKE) -C $(top_builddir)/BuildData tclkit${BEXEEXT}

ExtraDoc/Version.tcl: FORCE
	$(MAKE) -C $(top_builddir)/ExtraDoc Version.tcl

FORCE:

