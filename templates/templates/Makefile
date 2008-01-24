# Makefile using less GNUisms

PRODUCT=@PRODUCT@
VERSION=@VERSION@
FONTS=@FONTS@
MAKE_VOLT_PARAMS=@MAKE_VOLT_PARAMS@
MAKE_GDL_PARAMS=@MAKE_GDL_PARAMS@
@FONT_VARS@

RELEASE_DIR=ttf-sil-$(PRODUCT)-$(VERSION)
CONFIG_FILE=@CONFIG_FILE@
AUTOSUB=@AUTOSUB@
RM=@RM@
CP=@CP@

PKG_LIST=@foreach f,$(DOCS),doc/$(f),1@ @foreach f,$(EXTRA_DIST),$(f),nonl@

.PHONY: all exe dist clean dist-clean extra-clean
.SUFFIXES:

all ::

debug : DEBUG=1

debug : all

@and $(or $(EXTRA_RULES),$(EXTRA_TARGETS)),$(ALL_template)@

@osslash $(foreach v,$(FONTS),$(PROGRAM_template))@

exe : $(PRODUCT)-$(VERSION).exe

$(PRODUCT)-$(VERSION).exe : all installer.nsi $(PKG_LIST)
	makensis -O$(PRODUCT)_nsi.log installer.nsi

installer.nsi : templates/templates/installer.nsi Makefile
	$(AUTOSUB)

dist : $(RELEASE_DIR).tar.gz

$(RELEASE_DIR).tar.gz : MANIFEST $(PKG_LIST)
	@TARUP@

MANIFEST : templates/templates/MANIFEST Makefile
	$(AUTOSUB)

dist-clean : clean extra-clean

clean :
	@@-$(RM) $(PRODUCT)_nsi.log gdlerr.txt
	@foreach v,$(FONTS),$(and $(or $($(v)_VTP),$($(v)_GDL)),$(.TAB)$(.AT)-$(RM) $($(v)_VTP) $($(v)_GDL))@

extra-clean :
	-$(RM) installer.nsi Makefile *.zip *.exe

Makefile : $(CONFIG_FILE) templates/system.cfg templates/templates/Makefile
	$(AUTOSUB)
