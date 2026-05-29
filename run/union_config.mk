UVM_HOME				?= 

ifeq ($(UVM_HOME),)
  $(error You must set UVM_HOME to PATH to project repo directory.)
endif

UVM_TEST				?=
SEED					?= random
GUI						?= 0
VENDOR					?= CADENCE

COMMON_COMPILE_OPTS		?= 
COMMON_RUN_OPTS			?= 


USER_COMPILE_OPTS			= -top $(NAME_TOP_MODULE) $(MAIN_SOURCE_FILE) $(COMPILE_OPTS)
USER_RUN_OPTS				= $(RUN_OPTS)

export VENDOR
include $(UVM_HOME)/run/config_compile_elaborate.mk
include $(UVM_HOME)/run/config_run.mk

ifeq ($(VENDOR), CADENCE)
	BUILD_FUNC := xrun $(COMMON_COMPILE_OPTS) $(INCDIRS)
	SIM_FUNC := xrun $(COMMON_RUN_OPTS)
endif

export COMMON_SCRIPT_HOME=/fs/artifacts/verif/libraries/prj-config-au/scripts
export BUILD_DIR                 ?= $(shell pwd)
help:
	@echo
	@echo info - print environment variables
	@echo Attributes: none
	@echo Usage: make info
	@echo
	@echo build - build the design
	@echo Attributes:
	@echo   GUI             - 1 - simulation with VERDI, 0 - simulation in terminal (by default)
	@echo   COMPILE_OPTS 
	@echo Usage: make build GUI=<1,0> COMPILE_OPTS=<...>
	@echo
	@echo run - run the simulation
	@echo Attributes:
	@echo   UVM_TEST - uvm test name, ymp_reset_demo_base_test by default
	@echo   SEED     - random or specific value, random by default
	@echo   GUI      - 1 - simulation with GUI, 0 - simulation in terminal (by default)
	@echo   RUN_OPTS - list of user-defined options for ./simv
	@echo Usage: make run UVM_TEST=<test name> GUI=<1,0> SEED=1 RUN_OPTS=<...>
	@echo
	@echo all - compile the design and run the simulation
	@echo Attributes: all for compile and run targets
	@echo Usage: make all UVM_TEST=<test name> GUI=<1,0> SEED=1 COMPILE_OPTS=<...> RUN_OPTS=<...>
	@echo

info:
	@echo
	@echo ---------------- Environment variables -----------------
	@echo "GIT_HOME        = $(GIT_HOME)"
	@echo "UVM_HOME        = $(UVM_HOME)"
	@echo "TB_HOME         = $(TB_HOME)"
	@echo "UVM_TEST        = $(UVM_TEST)"
	@echo "INCDIRS         = $(INCDIRS)"
	@echo "BUILD_FUNC      = $(BUILD_FUNC) $(USER_COMPILE_OPTS)"
	@echo --------------------------------------------------------
	@echo

clean:
	rm -rf * .*

build:
	$(BUILD_FUNC) $(USER_COMPILE_OPTS)

run:
	$(SIM_FUNC) $(USER_RUN_OPTS)


all: build run
