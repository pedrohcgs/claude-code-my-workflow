SHELL=bash

all: ../output/nipa_supplement_tables.txt ../output/nipa_supplement_inventory.txt

include ../../generic.make
include ../../shell_functions.make

../output/nipa_supplement_tables.txt ../output/nipa_supplement_inventory.txt: main.do fetch_nipa_supplements.py | $(STATA_OOPR)
	$(STATA) main.do
