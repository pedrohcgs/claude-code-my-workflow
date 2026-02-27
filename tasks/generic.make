OOPR = ../output ../temp ../report ../input $(if $(shell command -v sbatch),run.sbatch)
STATA_OOPR = $(OOPR) profile.do

slurmlogs ../input ../output ../temp ../report:
	mkdir $@

run.sbatch: ../../setup_environment/code/run.sbatch | slurmlogs
	ln -sf $< $@

profile.do: ../../setup_environment/code/profile.do
	ln -sf $< $@

.PRECIOUS: ../../%

../../%:
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)
