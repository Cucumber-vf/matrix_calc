.PHONY: help info compile run all

TB_HOME             := ${UVM_HOME}/tb

UVM_TEST            ?= mat_test
NAME_TOP_MODULE     := tb_top
MAIN_SOURCE_FILE    := ${TB_HOME}/tb_sources.sv
RUN_OPTS            ?= 
COMPILE_OPTS        ?= 
export VENDOR := CADENCE
ifeq (${VENDOR}, CADENCE)
  COMPILE_OPTS +=-nowarn DSEM2009
  COMPILE_OPTS +=-nowarn DSEMEL
  COMPILE_OPTS +=-nowarn TSNSPK
  COMPILE_OPTS +=-nowarn DFAUTO
  COMPILE_OPTS +=-nowarn SAWSTP
  COMPILE_OPTS +=-nowarn CUVIHR
  COMPILE_OPTS +=-nowarn SPDUSD
else
  $(error $(BS_ERR_PREFIX) Vendor ${VENDOR} is not supported)
endif
$(info "LALA")
include ${UVM_HOME}/run/union_config.mk
