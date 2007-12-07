# Makefile using less GNUisms

PRODUCT=@PRODUCT@
VERSION=@VERSION@
TTF_VERSION=@TTF_VERSION@
FONTS=@FONTS@
MAKE_VOLT_PARAMS=@MAKE_VOLT_PARAMS@
MAKE_GDL_PARAMS=@MAKE_GDL_PARAMS@
padauk_TARGET = Padauk.ttf
padaukbold_TARGET = PadaukBold.ttf
@include templates/system.cfg@
@FONT_VARS@

RELEASE_DIR=ttf-sil-$(PRODUCT)-$(VERSION)
CONFIG_FILE=@CONFIG_FILE@

RM=@RM@
CP=@CP@

.PHONY: all exe dist dist-src clean dist-clean extra-clean
.SUFFIXES:

all :: @osslash font-source/myanmar5.html@

@osslash font-source/myanmar5.html : font-source/myanmar5.gdl@
	perl bin/make_doc font-source/myanmar5.gdl > font-source/myanmar5.html

@osslash $(foreach v,$(FONTS),$(PROGRAM_template))@

exe : $(PRODUCT)-$(VERSION).exe

$(PRODUCT)-$(VERSION).exe : installer.nsi $(RELEASE_DIR).zip
	makensis -O$(PRODUCT)_nsi.log installer.nsi

installer.nsi : templates/installer.nsi
	$(AUTO_SUB)

dist : $(RELEASE_DIR).zip

$(RELEASE_DIR).zip : MANIFEST all
	-$(RM) $@@
	7za a -tzip $@@ @@MANIFEST

dist-src : $(RELEASE_DIR)-src.zip

$(RELEASE_DIR)-src.zip : MANIFEST-SRC all
	-$(RM) $@@
	7za a -tzip $@@ @@MANIFEST-SRC

dist-clean : clean extra-clean

clean :
	-$(RM) $(PRODUCT)_nsi.log gdlerr.txt
	-$(RM) @foreach v,$(FONTS),$($(v)_VTP) $($(v)_GDL),nonl@

extra-clean :
	-$(RM) installer.nsi Makefile *.zip *.exe

Makefile : $(CONFIG_FILE) templates/system.cfg templates/Makefile
	$(AUTO_SUB)
