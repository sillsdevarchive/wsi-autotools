
CONFIG=@CONFIG@
KMNCOMPILER=@KMNCOMPILER@

@foreach k,$(KEYBOARDS),$(and $(KMNCOMPILER),$($(k)_KMX),$($(k)_KMN),$(KMXRULES))@
@foreach k,$(KEYBOARDS),$(and $($(k)_KMN),$(KMNSVGRULES))@
@foreach k,$(KEYBOARDS),$(and $($(k)_PDF),$(KMNPDFRULES))@

@KMNTESTS@

Makefile : @CONFIG_FILE@ @TEMPLATE_DIR@/keyman.cfg @TEMPLATE_DIR@/keyboards/Makefile
	@AUTOSUB@
