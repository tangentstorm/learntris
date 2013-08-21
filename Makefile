# directory paths, relative to this directory:

XPL       = ~/x/code
# TODO: set up submodules
# XPL       = lib/xpl/code
# LNPAS     = lib/linenoise

GEN	  = gen
FPC       = fpc -gl -B -Sgic -Fu$(XPL) -Fu$(LNPAS) -Fi$(XPL) -FE$(GEN)
PYTHON    = python

#------------------------------------------------------

targets:
	@echo 'available targets:'
	@echo '--------------------------'
	@echo 'make term  -> make and run ./gen/termtris'
	@echo 'make test  -> run testris.py'
	@echo

term: init
	@$(FPC) termtris.pas
	gen/termtris

init    :
	@mkdir -p $(GEN)
	@rm -f $(GEN)/library $(GEN)/retroImage
	@git submodule init
	@git submodule update

test:
	$(PYTHON) testris.py
