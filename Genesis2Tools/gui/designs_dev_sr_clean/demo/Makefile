# Input xml program
ifndef GENESIS_CFG_XML
GENESIS_CFG_XML := $(TILE_CFGS_PATH)/config.xml
else
  $(warning WARNING: GENESIS_CFG_XML set to $(GENESIS_CFG_XML))
endif

ifndef GENESIS_HIERARCHY
GENESIS_HIERARCHY := hierarchy_out.xml
else
  $(warning WARNING: GENESIS_HIERARCHY set to $(GENESIS_HIERARCHY))
endif


gen:
	Genesis2.pl -gen -top top -hierarchy $(GENESIS_HIERARCHY) -debug 0 -xml $(GENESIS_CFG_XML)


top.js:
	build_js.csh

clean:
	(mv *.js       old 2> /dev/null) || echo -n ""
	(mv *.pm       old 2> /dev/null) || echo -n ""
	(mv *.v        old 2> /dev/null) || echo -n ""
	(mv *.xml      old 2> /dev/null) || echo -n ""
	(mv *~         old 2> /dev/null) || echo -n ""
	(mv SysCfgs/*  old 2> /dev/null) || echo -n ""
