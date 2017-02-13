##############################################################################
################ Makefile Definitions
##############################################################################
# This little trick finds where the makefile exists
DESIGN_HOME := $(dir $(word $(words $(MAKEFILE_LIST)), $(MAKEFILE_LIST)))
$(warning WARNING: CMP home set to $(DESIGN_HOME)) 

-include Makefile.local

# Make sure we have all the relevant definitions
ifndef SMASH
  $(error ERROR: Chip Gen path is not set. Use "setenv SMASH <path_to_chipgen>")
else
  $(warning WARNING: SMASH set to $(SMASH))
endif

############# For Genesis2 ##############
#########################################
# tile is the top of the pre-processed hierarchy
TOP_MODULE := top


# list src folders and include folders
TILE_ENV_PATH := .
TILE_CFGS_PATH := $(TILE_ENV_PATH)/SysCfgs

GENESIS_SRC :=  -srcpath .                              \
		-srcpath $(DESIGN_HOME)

GENESIS_INC :=  -incpath .				\
		-incpath $(DESIGN_HOME)

# vpath directive tells where to search for *.vp and *.vph files
vpath 	%.vp  $(GENESIS_SRC)
vpath 	%.vph $(GENESIS_INC)

GENESIS_PRIMITIVES :=	flop.vp reg_file.vp cfg_ifc.vp regbank.vp

GENESIS_ENV :=		test.vp top.vp ProcShim.vp generic_memory.vp pc.vp \
			mem_mgr.vp transaction.vp

GENESIS_DESIGN := 	tile.vp processor.vp procClkGen.vp			\
			memory.vp						\
			addrMap.vp depStall.vp ms2p_xbar.vp p2ms_xbar.vp	\
			replyHandler.vp lut.vp 					\
			memory.vp replyStall.vp

GENESIS_INPUTS :=	$(GENESIS_PRIMITIVES) $(GENESIS_ENV) $(GENESIS_DESIGN) 

GENESIS_INTERMIDS := $(GENESIS_INPUTS:.vp=.pm)

# debug level
GENESIS_DBG_LEVEL := 0

# List of generated verilog files
GENESIS_VLOG_LIST := genesis_vlog.vf

## Input xml program
ifndef GENESIS_CFG_XML
GENESIS_CFG_XML := $(TILE_CFGS_PATH)/config.xml
else
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
endif

# xml hierarchy file
ifndef GENESIS_HIERARCHY
GENESIS_HIERARCHY := hierarchy_out.xml
else
  $(warning WARNING: GENESIS_HIERARCHY set to $(GENESIS_HIERARCHY))
endif

# For more Genesis parsing options, type 'Genesis2.pl -help'
#        [-parse]                    ---   should we parse input file to generate perl modules?
#        [-sources|srcpath dir]      ---   Where to find source files
#        [-includes|incpath dir]     ---   Where to find included files
#        [-input file1 .. filen]     ---   List of top level files
#                                    ---   The default is STDIN, but some functions
#                                    ---   (such as "for" or "while")
#                                    ---   may not work properly.
#        [-perl_modules modulename]  ---   Additional perl modules to load
GENESIS_PARSE_FLAGS := 	-parse $(GENESIS_SRC) $(GENESIS_INC)			\
			-debug $(GENESIS_DBG_LEVEL)
#			-input $(GENESIS_INPUTS)				\

# For more Genesis parsing options, type 'Genesis2.pl -help'
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
			-debug $(GENESIS_DBG_LEVEL)				\
			-xml $(GENESIS_CFG_XML)


################################################################################
################ Makefile Rules
################################################################################
#default rule: 
# all: simv
all: gen

# Genesis2 rules:
#####################
# Genesis2 Parse:
# This is the rule to activate Genesis2 parser to generate perl module (.pm)
# from the input verilog preprocessed (.vp) files.
# Use "make PARSE=<genesis2_parse_flags>" to add elaboration time flags
%.pm: %.vp
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_PARSE_FLAGS) -input $? $(PARSE)

# Genesis2 Generate:
# This is the rule to activate Genesis2 generator to generate verilog 
# files (_unqN.v) from the perl (.pm) program.
# Use "make GEN=<genesis2_gen_flags>" to add elaboration time flags
$(GENESIS_VLOG_LIST): $(GENESIS_INTERMIDS) $(GENESIS_CFG_XML)
	@echo ""
	@echo Making $@ because of $?
	@echo ==================================================
	Genesis2.pl $(GENESIS_GEN_FLAGS) $(GEN)


# phony rules for partial compilation process
.PHONY: parse gen

parse: $(GENESIS_INTERMIDS)

gen: $(GENESIS_VLOG_LIST) 
	Genesis2.pl -gen -top top -hierarchy $(GENESIS_HIERARCHY) -debug 0 -xml $(GENESIS_CFG_XML)

# Cleanup rules:
#####################
.PHONY: clean cleanall 
clean:
	@echo ""
	@echo Cleanning old files, objects, logs and garbage
	@echo ==================================================
	\rm -rf simv*
	\rm -rf csrc
	\rm -rf *.daidir
	\rm -rf *.log
	\rm -rf vcs.key
	\rm -rf *.pvl
	\rm -rf *.syn
	\rm -rf *.mr
	\rm -rf *.pvk
	\rm -rf *.flc
	\rm -rf ucli.key
	\rm -rf *~
	\rm -rf top.v
	\rm -rf $(GENESIS_INTERMIDS)
	\rm -rf $(GENESIS_INTERMIDS:.pm=_unq*.v)
	\rm -rf depend.list $(GENESIS_VLOG_LIST) hierarchy_out.xml
	\rm -rf genesis_work
	\rm -rf lsp

cleanall: clean
	\rm -rf DVE*
	\rm -rf vcdplus.vpd
