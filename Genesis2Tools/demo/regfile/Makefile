################################################################################
################ Makefile Definitions
################################################################################
# This little trick finds where the makefile lives
DESIGN_HOME := $(dir $(lastword $(MAKEFILE_LIST)))
$(warning WARNING: Design home set to $(DESIGN_HOME)) 

# this line enables a local Makefile to override values of the main makefile
-include Makefile.local


########### Generic Env Defs ############
#########################################
ifndef SIM_ENGINE
SIM_ENGINE := synopsys
  $(warning WARNING: SIM_ENGINE not specified. Using default SIM_ENGINE=synopsys) 
  $(warning WARNING: Rerun with SIM_ENGINE=synopsys or SIM_ENGINE=mentor)
endif


############# For Genesis2 ##############
#########################################
# tile is the top of the pre-processed hierarchy
TOP_MODULE := top


# list src folders and include folders
GENESIS_SRC := 	-srcpath ./			\
		-srcpath $(DESIGN_HOME)/genesis-source

GENESIS_INC := 	-incpath ./			\
		-incpath $(DESIGN_HOME)/genesis-source

# vpath directive tells where to search for *.vp and *.vph files
vpath 	%.vp  $(GENESIS_SRC)
vpath 	%.vph $(GENESIS_INC)

GENESIS_PRIMITIVES :=	

GENESIS_ENV :=		$(TOP_MODULE).vp

GENESIS_DESIGN := 	cfg_ifc.vp  flop.vp  reg_file.vp  top_flop_only.vp

GENESIS_INPUTS :=	$(GENESIS_PRIMITIVES) $(GENESIS_ENV) $(GENESIS_DESIGN) 

# debug level
GENESIS_DBG_LEVEL := 0

# List of generated verilog files
GENESIS_VLOG_LIST := genesis_vlog.vf

# Input xml program
ifndef GENESIS_CFG_XML
  GENESIS_CFG_XML := 	config.xml
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
else
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
endif

# xml hierarchy file
ifndef GENESIS_HIERARCHY
GENESIS_HIERARCHY := hierarchy_out.xml
else
  $(warning WARNING: GENESIS_HIERARCHY set to $(GENESIS_HIERARCHY))
endif

# For more Genesis parsing options, type 'Genesis2 -help'
#        [-parse]                    ---   should we parse input file to generate perl modules?
#        [-sources|srcpath dir]      ---   Where to find source files
#        [-includes|incpath dir]     ---   Where to find included files
#        [-input file1 .. filen]     ---   List of top level files
#                                    ---   The default is STDIN, but some functions
#                                    ---   (such as "for" or "while")
#                                    ---   may not work properly.
#        [-perl_modules modulename]  ---   Additional perl modules to load
GENESIS_PARSE_FLAGS := 	-parse $(GENESIS_SRC) $(GENESIS_INC)

# For more Genesis parsing options, type 'Genesis2 -help'
#        [-generate]                 ---   should we generate a verilog hierarchy?
#        [-top topmodule]            ---   Name of top module to start generation from
#        [-depend filename]          ---   Should Genesis2 generate a dependency file list? (list of input files)
#        [-product filename]         ---   Should Genesis2 generate a product file list? (list of output files)
#        [-hierarchy filename]       ---   Should Genesis2 generate a hierarchy representation tree?
#        [-xml filename]             ---   Input XML representation of definitions
GENESIS_GEN_FLAGS :=	-gen -top $(TOP_MODULE)					\
			-depend depend.list					\
			-product $(GENESIS_VLOG_LIST)				\
			-hierarchy $(GENESIS_HIERARCHY)                		\
			-xml $(GENESIS_CFG_XML)					




############### For Verilog ################
############################################

##### FLAGS FOR SYNOPSYS COMPILATION ####
ifeq ($(SIM_ENGINE), synopsys) 
COMPILER := vcs

EXECUTABLE := ./simv

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=  	$(VERILOG_ENV)	$(VERILOG_DESIGN)					

VERILOG_LIBS := 	


# "-sverilog" enables system verilog
# "+lint=PCWM" enables linting error messages
# "+libext+.v" specifies that library files (imported by the "-y" directive) ends with ".v"
# "-notice" used to get details when ports are coerced to inout
# "-full64" for 64 bit compilation and simulation
# "+v2k" for verilog 2001 constructs such as generate
# "-timescale=1ns/1ns" sets the time unit and time precision for the entire design
# "+noportcoerce" compile-time option to shut off the port coercion for the entire design
# "-top topModuleName" specifies the top module
# "-f verilogFiles.list" specifies a file that contains list of verilog files to compile
VERILOG_COMPILE_FLAGS := 	-sverilog 					\
				+cli 						\
				+lint=PCWM					\
				+libext+.v					\
				-notice						\
				-full64						\
				+v2k						\
				-debug_pp					\
				-timescale=1ns/1ns				\
				+noportcoerce         				\
				-ld gcc -debug_pp				\
				-top $(TOP_MODULE)				\
				-f $(GENESIS_VLOG_LIST) 			\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "+vpdbufsize+100" limit the internal buffer to 100MB (forces flushing to disk)
# "+vpdports" Record information about ports (signal/in/out)
# "+vpdfileswitchsize+1000" limits the wave file to 1G (then switch to next file)
VERILOG_SIMULATION_FLAGS := 	$(VERILOG_SIMULATION_FLAGS) 			\
				-l $(EXECUTABLE).log					\
				+vpdbufsize+100					\
				+vpdfileswitchsize+100
endif 
##### END OF FLAGS FOR SYNOPSYS COMPILATION ####


##### FLAGS FOR MENTOR COMPILATION ####
ifeq ($(SIM_ENGINE), mentor) 
COMPILER := vlog

EXECUTABLE := vsim

VERILOG_ENV :=		 

VERILOG_DESIGN :=	

VERILOG_FILES :=  	$(VERILOG_ENV)	$(VERILOG_DESIGN)					

VERILOG_LIBS := 	

# "-source" Displays the associated line of source code before each error 
#	message that is generated during compilation.
# "-sv" Enables SystemVerilog features and keywords.
# "-f fileName" Specifies a file with more command line arguments.
VERILOG_COMPILE_FLAGS := 	-source -sv					\
				-f $(GENESIS_VLOG_LIST) 			\
				$(VERILOG_FILES) $(VERILOG_LIBS)

# "-c" Specifies that the simulator is to be run in command-line mode.
# "-capacity" Enables the fine-grain analysis display of memory capacity
VERILOG_SIMULATION_FLAGS := 	-c						\
				$(TOP_MODULE)					\
				-capacity					\
				-do "run -all; quit"

endif 
##### END OF FLAGS FOR SYNOPSYS COMPILATION ####

################################################################################
################ Makefile Rules
################################################################################
#default rule: 
all: $(EXECUTABLE)

# Genesis2 rules:
#####################
# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the genesis (.vp) program.
# Use "make GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST): $(GENESIS_INPUTS) $(GENESIS_CFG_XML)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2 $(GENESIS_GEN_FLAGS) $(GEN) $(GENESIS_PARSE_FLAGS) $(PARSE) -input $(GENESIS_INPUTS) -debug $(GENESIS_DBG_LEVEL)

# phony rules for verilog generation process
.PHONY: gen genesis_clean
gen: $(GENESIS_VLOG_LIST)

genesis_clean:
	@echo ""
	@echo Cleanning previous runs of Genesis
	@echo ===================================
	if test -f "genesis_clean.cmd"; then 	\
		source genesis_clean.cmd;	\
	fi
	\rm -f genesis_vlog.vf

# VCS rules:
#####################
# compile rules:
# use "make COMP=+define+<compile_time_flag[=value]>" to add compile time flags
.PHONY: comp
comp: $(EXECUTABLE)

$(EXECUTABLE):	$(VERILOG_FILES) $(GENESIS_VLOG_LIST) 
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	@(if [ "$(SIM_ENGINE)" = "mentor" ]; then 	\
	    vlib work;					\
	  fi )
	$(COMPILER)  $(VERILOG_COMPILE_FLAGS) $(COMP) 


# Simulation rules:
#####################
# use "make run RUN=+<runtime_flag[=value]>" to add runtime flags
.PHONY: run run_wave
run_wave: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE) with wave
	@echo ==================================================
	$(EXECUTABLE) +wave $(VERILOG_SIMULATION_FLAGS) $(RUN)

run: $(EXECUTABLE)
	@echo ""
	@echo Now Running $(EXECUTABLE)
	@echo ==================================================
	$(EXECUTABLE) $(VERILOG_SIMULATION_FLAGS) $(RUN)



# Cleanup rules:
#####################
.PHONY: clean cleanall 
clean: genesis_clean
	@echo ""
	@echo Cleanning old files, objects, logs and garbage
	@echo ==================================================
	\rm -rf $(EXECUTABLE) 
	\rm -rf csrc
	\rm -rf *.daidir
	\rm -rf *.log
	\rm -rf *.pvl
	\rm -rf *.syn
	\rm -rf *.mr
	\rm -rf *.pvk
	\rm -rf *.flc
	\rm -rf ucli.key
	\rm -rf *~
ifdef SIM_ENGINE
	\rm -rf $(EXECUTABLE).*
endif
ifeq ($(SIM_ENGINE), mentor) 
	\rm -rf work
	\rm -rf transcript
endif

cleanall: clean
	\rm -rf DVE*
	\rm -rf vcdplus.vpd
