# Makefile using less GNUisms

PRODUCT=@PRODUCT@
VERSION=@VERSION@
FONTS=@FONTS@
MAKE_VOLT_PARAMS=@MAKE_VOLT_PARAMS@
MAKE_GDL_PARAMS=@MAKE_GDL_PARAMS@
@FONT_VARS@

RELEASE_DIR=ttf-sil-$(PRODUCT)-$(VERSION)
CONFIG_FILE=@.CONFIG@
AUTOSUB=@AUTOSUB@
TEMPLATE_DIR?=@TEMPLATE_DIR@
RM=@RM@
CP=@CP@
MKDIR=@MKDIR@
MAKENSIS=@or $(MAKENSIS),makensis@

PKG_LIST=@foreach f,$(DOCS),doc/$(f),1@ @foreach f,$(EXTRA_DIST),$(f),nonl@

.PHONY: all exe dist clean dist-clean extra-clean
.SUFFIXES:

all ::

debug : DEBUG=1

debug : all

temp :
	@@- mkdir $@@

@osslash $(foreach v,$(FONTS),$(PROGRAM_template))@

@and $(or $(EXTRA_RULES),$(EXTRA_TARGETS),$(TEST_FILES)),$(ALL_template)@

@and $(LICENSE_IN_FONT),$(LICENSE_template)@

@if $(MASTER_SFD),$(MASTER_template)@

all :: @and $(which defoma-hints),debian-src/$(TARNAME).defoma-hints@

exe : $(PRODUCT)-$(VERSION).exe

$(PRODUCT)-$(VERSION).exe : all installer.nsi $(PKG_LIST)
	$(MAKENSIS) -O$(PRODUCT)_nsi.log installer.nsi

installer.nsi : $(TEMPLATE_DIR)/templates/installer.nsi Makefile
	$(AUTOSUB)

dist : @TARNAME@-@VERSION@.tar.gz

@TARNAME@-@VERSION@.tar.gz : MANIFEST $(PKG_LIST)
	perl $(TEMPLATE_DIR)/bin/tarman -cvzf $@ -T MANIFEST -l templates=$(TEMPLATE_DIR)

MANIFEST : $(TEMPLATE_DIR)/templates/MANIFEST Makefile
	$(AUTOSUB)

@and $(DEBARCH),$(DEBIAN_template)@

@and $(which defoma-hints),$(DEFOMA_template)@

dist-clean : clean extra-clean

clean :
	@@-$(RM) $(PRODUCT)-$(VERSION).exe $(PRODUCT)_nsi.log @TARNAME@-$(VERSION).tar.gz gdlerr.txt
	@@-$(RM) @foreach v,$(CLEAN_FILES),$(v),nonl@

extra-clean :
	-$(RM) @sub \Q$(.TEMPLATE_DIR)/\E,,$(.TEMPLATES)@

Makefile : $(CONFIG_FILE) $(TEMPLATE_DIR)/system.cfg $(TEMPLATE_DIR)/templates/Makefile
	$(AUTOSUB)
