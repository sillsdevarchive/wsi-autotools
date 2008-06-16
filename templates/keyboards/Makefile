
CONFIG=@CONFIG@
KMNCOMPILER=@KMNCOMPILER@

@foreach k,$(KEYBOARDS),$(and $(KMNCOMPILER),$($(k)_KMX),$($(k)_KMN),$(KMXRULES))@

Makefile : $(CONFIG_FILE) $(TEMPLATE_DIR)/keyman.cfg $(TEMPLATE_DIR)/keyboards/Makefile
		$(AUTOSUB)
