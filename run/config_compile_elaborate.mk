####################### COMMON COMPILE OPTIONS ######################
COMMON_COMPILE_OPTS ?=
ifeq ($(VENDOR), CADENCE)
  COMMON_COMPILE_OPTS += -elaborate
  COMMON_COMPILE_OPTS += -64bit
  COMMON_COMPILE_OPTS += -sysv
  COMMON_COMPILE_OPTS += -sv
  COMMON_COMPILE_OPTS += -nocopyright
  COMMON_COMPILE_OPTS += -mccodegen
  COMMON_COMPILE_OPTS += -mcmaxcores 8
  COMMON_COMPILE_OPTS += +define+XCELIUM
  COMMON_COMPILE_OPTS += -uvm
  COMMON_COMPILE_OPTS += -uvmhome CDNS-1.2
  COMMON_COMPILE_OPTS += -linedebug -classlinedebug -uvmlinedebug
  COMMON_COMPILE_OPTS += -errormax 5
  COMMON_COMPILE_OPTS += -access +rwc
  COMMON_COMPILE_OPTS += -warnmax 10000
  COMMON_COMPILE_OPTS += -xmwarn BNDBERR
  COMMON_COMPILE_OPTS += -xmerr DYNBDU
  COMMON_COMPILE_OPTS += -xmerr FLFFNF
  COMMON_COMPILE_OPTS += -status
  COMMON_COMPILE_OPTS += -timescale 1ns/1ns
  COMMON_COMPILE_OPTS += -mcmaxcores 8
  COMMON_COMPILE_OPTS += -nospecify
  ifeq ($(EN_COVERAGE), 1)
    COMMON_COMPILE_OPTS += -coverage toggle:functional
    COMMON_COMPILE_OPTS += -cov_cgsample
  endif
else ifeq ($(VENDOR), SYNOPSYS)
  COMMON_COMPILE_OPTS += -ntb_opts uvm-1.2
  COMMON_COMPILE_OPTS += -debug_access+all
  COMMON_COMPILE_OPTS += -full64 -sverilog -l compile.log -lca -kdb
  COMMON_COMPILE_OPTS += +nospecify +notimingchecks +lint=none
  COMMON_COMPILE_OPTS += -timescale=1ns/1ns
  COMMON_COMPILE_OPTS += -debug_access+f
  COMMON_COMPILE_OPTS += -partcomp=autopart_low -fastpartcomp=j8
  COMMON_COMPILE_OPTS += +libext+.v+.sv
  COMMON_COMPILE_OPTS += -CFLAGS -DVCS
  COMMON_COMPILE_OPTS += +warn=noLCA_FEATURES_ENABLED
else
  $(error Vendor $(VENDOR) is not supported)
endif

INCDIRS += +incdir+$(UVM_HOME)/rtl
INCDIRS += +incdir+$(UVM_HOME)/rtl/apb_csr
INCDIRS += +incdir+$(UVM_HOME)/rtl/axis_rx
INCDIRS += +incdir+$(UVM_HOME)/rtl/axis_tx
INCDIRS += +incdir+$(UVM_HOME)/rtl/mat_op

INCDIRS += +incdir+$(TB_HOME)
INCDIRS += +incdir+$(TB_HOME)/bfms
INCDIRS += +incdir+$(TB_HOME)/if
INCDIRS += +incdir+$(TB_HOME)/agents/apb_vc
INCDIRS += +incdir+$(TB_HOME)/agents/axis_vc
INCDIRS += +incdir+$(TB_HOME)/agents/axis_vc/axis_master
INCDIRS += +incdir+$(TB_HOME)/agents/axis_vc/axis_slave
INCDIRS += +incdir+$(TB_HOME)/agents/clk_vc
INCDIRS += +incdir+$(TB_HOME)/agents/rst_vc
INCDIRS += +incdir+$(TB_HOME)/env
INCDIRS += +incdir+$(TB_HOME)/seqs
INCDIRS += +incdir+$(TB_HOME)/seqs/base_seqs
INCDIRS += +incdir+$(TB_HOME)/seqs/API_seqs
INCDIRS += +incdir+$(TB_HOME)/seqs/work_seqs
INCDIRS += +incdir+$(TB_HOME)/tests
