####################### COMMON RUN OPTIONS ######################
COMMON_RUN_OPTS ?=
############################ SYNOPSYS ############################
ifeq ($(VENDOR), SYNOPSYS)
  ifeq ($(SEED), random)
    COMMON_RUN_OPTS += +ntb_random_seed_automatic
  else
    COMMON_RUN_OPTS += +ntb_random_seed=$(SEED)
  endif
  ifeq ($(EN_COVERAGE), 1)
    COMMON_RUN_OPTS += -cm tgl+assert+fsm+line
    COMMON_RUN_OPTS += +en_cov
    ifneq ($(COV_TEST_NAME),)
      COMMON_RUN_OPTS += -cm_name $(COV_TEST_NAME)
    else
      COMMON_RUN_OPTS += -cm_name $(UVM_TEST)
    endif
    
    ifeq ($(USE_CUSTOM_VDB_DIR), 1)
      ifneq ($(CUSTOM_VDB_DIR),)
        COMMON_RUN_OPTS += -cm_dir $(CUSTOM_VDB_DIR)/run_simv
      else
        COMMON_RUN_OPTS += -cm_dir $(shell pwd)/run_simv
      endif
    endif
  else
    ifneq ($(SNAPSHOT_PATH),)
      COMMON_RUN_OPTS += -cm_dir $(shell pwd)/run_simv
    endif
  endif
  ifeq ($(GUI), 1)
    COMMON_RUN_OPTS += -gui
    COMMON_RUN_OPTS += -lca
  endif
############################ CADENCE ############################
else ifeq ($(VENDOR), CADENCE)
  COMMON_RUN_OPTS += -64bit
  COMMON_RUN_OPTS += -R
  COMMON_RUN_OPTS += +UVM_NO_RELNOTES
  COMMON_RUN_OPTS += -seed $(SEED)
  COMMON_RUN_OPTS += -nowarn DLWNEW
  COMMON_RUN_OPTS += -logfile xmsim.log
  ifeq ($(GUI), 1)
    COMMON_RUN_OPTS += -gui
  endif
  ifeq ($(EN_COVERAGE), 1)
    COMMON_RUN_OPTS += -covoverwrite # overwriting coverage output files
    COMMON_RUN_OPTS += +en_cov # plusarg
    ifneq ($(COV_TEST_NAME),)
      COMMON_RUN_OPTS += -covtest $(COV_TEST_NAME) # renaming to a directory for coverage
    else
      COMMON_RUN_OPTS += -covtest $(UVM_TEST) # renaming to a directory for coverage
    endif
  endif

else
  $(error Vendor $(VENDOR) is not supported)
endif

COMMON_RUN_OPTS += +UVM_TESTNAME=$(UVM_TEST)
