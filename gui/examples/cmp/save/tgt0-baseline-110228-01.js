<script type="text/javascript"><!--



var cgtop = new Object();
cgtop.BaseModuleName = "top";
cgtop.InstanceName = "top";

cgtop.Parameters = new Object();
cgtop.Parameters.ASSERTION = "ON";
cgtop.Parameters.MODE = "VERIF";
cgtop.Parameters.NUM_MEM_MATS = "1";
cgtop.Parameters.NUM_PROCESSOR = "1";
cgtop.Parameters.QUAD_ID = "0";
cgtop.Parameters.TILE_ID = "0";

cgtop.SubInstances = new Object();

cgtop.SubInstances.DUT = new Object();
cgtop.SubInstances.DUT.BaseModuleName = "tile";

cgtop.SubInstances.DUT.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.ImmutableParameters.CFG_IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.ImmutableParameters.NUM_MEM_MATS = "1";
cgtop.SubInstances.DUT.ImmutableParameters.NUM_PROCESSOR = "1";
cgtop.SubInstances.DUT.ImmutableParameters.QUAD_ID = "0";
cgtop.SubInstances.DUT.ImmutableParameters.TILE_ID = "0";
cgtop.SubInstances.DUT.InstanceName = "DUT";

cgtop.SubInstances.DUT.Parameters = new Object();
cgtop.SubInstances.DUT.Parameters.MAT_0_DATA_SIZE = "64";
cgtop.SubInstances.DUT.Parameters.MAT_0_MAT_TYPE = "SCRATCH";
cgtop.SubInstances.DUT.Parameters.MAT_0_META_SIZE = "32";
cgtop.SubInstances.DUT.Parameters.MAT_0_WORDS = "16";
cgtop.SubInstances.DUT.Parameters.MAT_ADDR = "0";
cgtop.SubInstances.DUT.Parameters.MAT_ADDR_SIZE = "32";
cgtop.SubInstances.DUT.Parameters.MAT_DATA_SIZE = "64";
cgtop.SubInstances.DUT.Parameters.MAT_EN_WIDTH = "8";
cgtop.SubInstances.DUT.Parameters.MAT_META_WIDTH = "32";
cgtop.SubInstances.DUT.Parameters.MAT_OPCODE_WIDTH = "3";
cgtop.SubInstances.DUT.Parameters.MAT_RET_CODE = "32";
cgtop.SubInstances.DUT.Parameters.MAT_TYPE = "SCRATCH";
cgtop.SubInstances.DUT.Parameters.MAT_WORDS = "16";
cgtop.SubInstances.DUT.Parameters.PROC_META_SIZE = "64";
cgtop.SubInstances.DUT.Parameters.PROC_TARG = "0";
cgtop.SubInstances.DUT.Parameters.REQ_PROC = "1";
cgtop.SubInstances.DUT.Parameters.p0_META_SIZE = "64";

cgtop.SubInstances.DUT.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.cfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.cfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.cfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.cfgIn.InstanceName = "cfgIn";
cgtop.SubInstances.DUT.SubInstances.cfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.cfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.cfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.cfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.cfgOut.InstanceName = "cfgOut";
cgtop.SubInstances.DUT.SubInstances.cfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0 = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.BaseModuleName = "addrMap";

cgtop.SubInstances.DUT.SubInstances.dam0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.ImmutableParameters.ADDR_OUT_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.dam0.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.dam0.ImmutableParameters.IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.ImmutableParameters.OP_SIZE = "6";
cgtop.SubInstances.DUT.SubInstances.dam0.ImmutableParameters.TARG_SIZE = "1";
cgtop.SubInstances.DUT.SubInstances.dam0.InstanceName = "dam0";

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0] = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].ops = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].ops[0] = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].remap_bits = "1";

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].segments = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].segments[0] = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].segments[0].addr_interrupts = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].segments[0].lookup_val = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].segments[0].remap_val = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.ADDR_MAP[0].segments[0].targ = "1111";

cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.CFG_OPCODES = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.CFG_OPCODES.bypass = "3";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.CFG_OPCODES.nop = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.CFG_OPCODES.read = "1";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.CFG_OPCODES.write = "2";
cgtop.SubInstances.DUT.SubInstances.dam0.Parameters.INT_SIZE = "3";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_in = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_in.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_in.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_in.InstanceName = "AddrCFG_in";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_in.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_out = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_out.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_out.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_out.InstanceName = "AddrCFG_out";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.AddrCFG_out.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgIn_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgIn_0.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgIn_0.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgIn_0.InstanceName = "cfgIn_0";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgIn_0.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgOut_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgOut_0.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgOut_0.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgOut_0.InstanceName = "cfgOut_0";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.cfgOut_0.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.BaseModuleName = "reg_file";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.REG_LIST = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0] = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].IEO = "O";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].defaultHACK = "15";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].name = "r0";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].width = "5";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.InstanceName = "rf_0";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters.BASE_ADDR = "0";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters.CFG_OPCODES = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters.CFG_OPCODES.bypass = "3";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters.CFG_OPCODES.nop = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters.CFG_OPCODES.read = "1";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.Parameters.CFG_OPCODES.write = "2";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn.InstanceName = "cfgIn";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_WIDTH = "66";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.InstanceName = "cfgIn_floper";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgIn_floper.UniqueModuleName = "flop_unq10";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgOut.InstanceName = "cfgOut";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.cfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.ImmutableParameters.FLOP_DEFAULT = "15";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.ImmutableParameters.FLOP_WIDTH = "5";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.InstanceName = "r0_reg";

cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.SubInstances.r0_reg.UniqueModuleName = "flop_unq16";
cgtop.SubInstances.DUT.SubInstances.dam0.SubInstances.rf_0.UniqueModuleName = "reg_file_unq2";
cgtop.SubInstances.DUT.SubInstances.dam0.UniqueModuleName = "addrMap_unq1";

cgtop.SubInstances.DUT.SubInstances.damCfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.damCfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.damCfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.damCfgIn.InstanceName = "damCfgIn";
cgtop.SubInstances.DUT.SubInstances.damCfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.damCfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.damCfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.damCfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.damCfgOut.InstanceName = "damCfgOut";
cgtop.SubInstances.DUT.SubInstances.damCfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.dr = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.BaseModuleName = "regbank";

cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_WIDTHS[0] = "32";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_WIDTHS[1] = "6";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_WIDTHS[2] = "4";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_WIDTHS[3] = "32";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.INPUT_WIDTHS[4] = "1";

cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.SIGNALS = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.SIGNALS[0] = "address";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.SIGNALS[1] = "op";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.SIGNALS[2] = "en";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.SIGNALS[3] = "data";
cgtop.SubInstances.DUT.SubInstances.dr.ImmutableParameters.SIGNALS[4] = "m1_stall";
cgtop.SubInstances.DUT.SubInstances.dr.InstanceName = "dr";

cgtop.SubInstances.DUT.SubInstances.dr.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.Parameters.FLOP_TYPE = "RFLOP";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.InstanceName = "flop_address_0";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_address_0.UniqueModuleName = "flop_unq3";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3 = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.InstanceName = "flop_data_3";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_data_3.UniqueModuleName = "flop_unq3";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2 = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.ImmutableParameters.FLOP_WIDTH = "4";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.InstanceName = "flop_en_2";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_en_2.UniqueModuleName = "flop_unq8";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4 = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.InstanceName = "flop_m1_stall_4";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_m1_stall_4.UniqueModuleName = "flop_unq1";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1 = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.ImmutableParameters.FLOP_WIDTH = "6";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.InstanceName = "flop_op_1";

cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.dr.SubInstances.flop_op_1.UniqueModuleName = "flop_unq9";
cgtop.SubInstances.DUT.SubInstances.dr.UniqueModuleName = "regbank_unq1";

cgtop.SubInstances.DUT.SubInstances.drh0 = new Object();
cgtop.SubInstances.DUT.SubInstances.drh0.BaseModuleName = "replyHandler";

cgtop.SubInstances.DUT.SubInstances.drh0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.drh0.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.drh0.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.drh0.ImmutableParameters.EN_SIZE = "4";
cgtop.SubInstances.DUT.SubInstances.drh0.ImmutableParameters.META_SIZE = "64";
cgtop.SubInstances.DUT.SubInstances.drh0.ImmutableParameters.OP_SIZE = "6";
cgtop.SubInstances.DUT.SubInstances.drh0.InstanceName = "drh0";
cgtop.SubInstances.DUT.SubInstances.drh0.UniqueModuleName = "replyHandler_unq1";

cgtop.SubInstances.DUT.SubInstances.drs0 = new Object();
cgtop.SubInstances.DUT.SubInstances.drs0.BaseModuleName = "replyStall";

cgtop.SubInstances.DUT.SubInstances.drs0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.drs0.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.drs0.InstanceName = "drs0";
cgtop.SubInstances.DUT.SubInstances.drs0.UniqueModuleName = "replyStall_unq1";

cgtop.SubInstances.DUT.SubInstances.ds_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.ds_0.BaseModuleName = "depStall";

cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters.DATA_OP_SIZE = "6";
cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters.INSTR_OP_SIZE = "2";
cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters.INSTR_SIZE = "64";
cgtop.SubInstances.DUT.SubInstances.ds_0.ImmutableParameters.TARG_SIZE = "1";
cgtop.SubInstances.DUT.SubInstances.ds_0.InstanceName = "ds_0";
cgtop.SubInstances.DUT.SubInstances.ds_0.UniqueModuleName = "depStall_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0 = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.BaseModuleName = "addrMap";

cgtop.SubInstances.DUT.SubInstances.iam0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.ImmutableParameters.ADDR_OUT_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.iam0.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.iam0.ImmutableParameters.IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.ImmutableParameters.OP_SIZE = "2";
cgtop.SubInstances.DUT.SubInstances.iam0.ImmutableParameters.TARG_SIZE = "1";
cgtop.SubInstances.DUT.SubInstances.iam0.InstanceName = "iam0";

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0] = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].ops = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].ops[0] = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].remap_bits = "1";

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].segments = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].segments[0] = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].segments[0].addr_interrupts = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].segments[0].lookup_val = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].segments[0].remap_val = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.ADDR_MAP[0].segments[0].targ = "1111";

cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.CFG_OPCODES = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.CFG_OPCODES.bypass = "3";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.CFG_OPCODES.nop = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.CFG_OPCODES.read = "1";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.CFG_OPCODES.write = "2";
cgtop.SubInstances.DUT.SubInstances.iam0.Parameters.INT_SIZE = "3";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_in = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_in.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_in.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_in.InstanceName = "AddrCFG_in";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_in.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_out = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_out.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_out.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_out.InstanceName = "AddrCFG_out";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.AddrCFG_out.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgIn_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgIn_0.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgIn_0.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgIn_0.InstanceName = "cfgIn_0";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgIn_0.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgOut_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgOut_0.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgOut_0.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgOut_0.InstanceName = "cfgOut_0";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.cfgOut_0.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.BaseModuleName = "reg_file";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.REG_LIST = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0] = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].IEO = "O";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].defaultHACK = "15";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].name = "r0";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.ImmutableParameters.REG_LIST[0].width = "5";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.InstanceName = "rf_0";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters.BASE_ADDR = "0";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters.CFG_OPCODES = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters.CFG_OPCODES.bypass = "3";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters.CFG_OPCODES.nop = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters.CFG_OPCODES.read = "1";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.Parameters.CFG_OPCODES.write = "2";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn.InstanceName = "cfgIn";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_WIDTH = "66";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.InstanceName = "cfgIn_floper";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgIn_floper.UniqueModuleName = "flop_unq10";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgOut.InstanceName = "cfgOut";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.cfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.ImmutableParameters.FLOP_DEFAULT = "15";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.ImmutableParameters.FLOP_WIDTH = "5";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.InstanceName = "r0_reg";

cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.SubInstances.r0_reg.UniqueModuleName = "flop_unq16";
cgtop.SubInstances.DUT.SubInstances.iam0.SubInstances.rf_0.UniqueModuleName = "reg_file_unq2";
cgtop.SubInstances.DUT.SubInstances.iam0.UniqueModuleName = "addrMap_unq2";

cgtop.SubInstances.DUT.SubInstances.iamCfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.iamCfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iamCfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iamCfgIn.InstanceName = "iamCfgIn";
cgtop.SubInstances.DUT.SubInstances.iamCfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.iamCfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.iamCfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iamCfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.iamCfgOut.InstanceName = "iamCfgOut";
cgtop.SubInstances.DUT.SubInstances.iamCfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.ir = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.BaseModuleName = "regbank";

cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_WIDTHS[0] = "32";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_WIDTHS[1] = "2";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_WIDTHS[2] = "2";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_WIDTHS[3] = "64";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.INPUT_WIDTHS[4] = "1";

cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.SIGNALS = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.SIGNALS[0] = "address";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.SIGNALS[1] = "op";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.SIGNALS[2] = "en";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.SIGNALS[3] = "instr";
cgtop.SubInstances.DUT.SubInstances.ir.ImmutableParameters.SIGNALS[4] = "m1_stall";
cgtop.SubInstances.DUT.SubInstances.ir.InstanceName = "ir";

cgtop.SubInstances.DUT.SubInstances.ir.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.Parameters.FLOP_TYPE = "RFLOP";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.InstanceName = "flop_address_0";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_address_0.UniqueModuleName = "flop_unq3";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2 = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.ImmutableParameters.FLOP_WIDTH = "2";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.InstanceName = "flop_en_2";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_en_2.UniqueModuleName = "flop_unq7";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3 = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.ImmutableParameters.FLOP_WIDTH = "64";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.InstanceName = "flop_instr_3";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_instr_3.UniqueModuleName = "flop_unq2";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4 = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.InstanceName = "flop_m1_stall_4";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_m1_stall_4.UniqueModuleName = "flop_unq1";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1 = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.ImmutableParameters.FLOP_WIDTH = "2";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.InstanceName = "flop_op_1";

cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.ir.SubInstances.flop_op_1.UniqueModuleName = "flop_unq7";
cgtop.SubInstances.DUT.SubInstances.ir.UniqueModuleName = "regbank_unq2";

cgtop.SubInstances.DUT.SubInstances.irh0 = new Object();
cgtop.SubInstances.DUT.SubInstances.irh0.BaseModuleName = "replyHandler";

cgtop.SubInstances.DUT.SubInstances.irh0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.irh0.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.irh0.ImmutableParameters.DATA_SIZE = "64";
cgtop.SubInstances.DUT.SubInstances.irh0.ImmutableParameters.EN_SIZE = "2";
cgtop.SubInstances.DUT.SubInstances.irh0.ImmutableParameters.META_SIZE = "64";
cgtop.SubInstances.DUT.SubInstances.irh0.ImmutableParameters.OP_SIZE = "2";
cgtop.SubInstances.DUT.SubInstances.irh0.InstanceName = "irh0";
cgtop.SubInstances.DUT.SubInstances.irh0.UniqueModuleName = "replyHandler_unq2";

cgtop.SubInstances.DUT.SubInstances.irs0 = new Object();
cgtop.SubInstances.DUT.SubInstances.irs0.BaseModuleName = "replyStall";

cgtop.SubInstances.DUT.SubInstances.irs0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.irs0.ImmutableParameters.DATA_SIZE = "64";
cgtop.SubInstances.DUT.SubInstances.irs0.InstanceName = "irs0";
cgtop.SubInstances.DUT.SubInstances.irs0.UniqueModuleName = "replyStall_unq2";

cgtop.SubInstances.DUT.SubInstances.mb0 = new Object();
cgtop.SubInstances.DUT.SubInstances.mb0.BaseModuleName = "memory";

cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.DATA_SIZE = "64";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.EN_SIZE = "8";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.META_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.OP_SIZE = "3";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.REQ_SIZE = "1";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.RET_CODE_SIZE = "32";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.TYPE = "SCRATCH";
cgtop.SubInstances.DUT.SubInstances.mb0.ImmutableParameters.WORDS = "16";
cgtop.SubInstances.DUT.SubInstances.mb0.InstanceName = "mb0";

cgtop.SubInstances.DUT.SubInstances.mb0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.mb0.Parameters.REQ_PROC = "1";
cgtop.SubInstances.DUT.SubInstances.mb0.UniqueModuleName = "memory_unq1";

cgtop.SubInstances.DUT.SubInstances.mr = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.BaseModuleName = "regbank";

cgtop.SubInstances.DUT.SubInstances.mr.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.ImmutableParameters.INPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.mr.ImmutableParameters.INPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.ImmutableParameters.INPUT_WIDTHS[0] = "1";

cgtop.SubInstances.DUT.SubInstances.mr.ImmutableParameters.SIGNALS = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.ImmutableParameters.SIGNALS[0] = "req_proc";
cgtop.SubInstances.DUT.SubInstances.mr.InstanceName = "mr";

cgtop.SubInstances.DUT.SubInstances.mr.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.Parameters.FLOP_TYPE = "RFLOP";

cgtop.SubInstances.DUT.SubInstances.mr.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0 = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.ImmutableParameters.FLOP_TYPE = "RFLOP";
cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.InstanceName = "flop_req_proc_0";

cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.mr.SubInstances.flop_req_proc_0.UniqueModuleName = "flop_unq1";
cgtop.SubInstances.DUT.SubInstances.mr.UniqueModuleName = "regbank_unq3";

cgtop.SubInstances.DUT.SubInstances.ms21 = new Object();
cgtop.SubInstances.DUT.SubInstances.ms21.BaseModuleName = "ms2p_xbar";

cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.INPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.INPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.INPUT_WIDTHS[0] = "1";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.INPUT_WIDTHS[1] = "32";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.INPUT_WIDTHS[2] = "64";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.INPUT_WIDTHS[3] = "32";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_WIDTHS[0] = "32";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_WIDTHS[1] = "64";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_WIDTHS[2] = "64";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_WIDTHS[3] = "64";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.OUTPUT_WIDTHS[4] = "6";
cgtop.SubInstances.DUT.SubInstances.ms21.ImmutableParameters.PC_SIZE = "96";
cgtop.SubInstances.DUT.SubInstances.ms21.InstanceName = "ms21";
cgtop.SubInstances.DUT.SubInstances.ms21.UniqueModuleName = "ms2p_xbar_unq1";

cgtop.SubInstances.DUT.SubInstances.p0 = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.BaseModuleName = "processor";

cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.ADDR_BUS_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.CFG_IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_ADDR_SPACE = "0x80000000:0xffffffff";

cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[0] = "NOP";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[1] = "LOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[2] = "STORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[3] = "METALOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[4] = "METASTORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[5] = "SYNCLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[6] = "SYNCSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[7] = "RESETLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[8] = "SETSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[9] = "FUTURELOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[10] = "RAWLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[11] = "RAWSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[12] = "RAWMETALOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[13] = "RAWMETASTORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[14] = "FIFOLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[15] = "FIFOSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[16] = "CACHEGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[17] = "CACHECONDGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[18] = "MATGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[19] = "MATCONDGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[20] = "HARDINTCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[21] = "MEMBAR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[22] = "SM_DHWB";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[23] = "SM_DHWBI";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[24] = "SM_DHI";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[25] = "SM_DII";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[26] = "SM_DIWB";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[27] = "SM_DIWBI";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[28] = "SM_DPFR";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[29] = "SM_DPFW";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[30] = "SM_IHI";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[31] = "SM_III";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[32] = "SM_IPF";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[33] = "SAFE_LOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_LIST[34] = "SPEC_CMD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.DATA_OP_WIDTH = "6";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_ADDR_SPACE = "0x40000000:0x7fffffff";

cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_OP_LIST = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_OP_LIST[0] = "NOP";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_OP_LIST[1] = "LOAD";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_OP_LIST[2] = "STORE";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_OP_LIST[3] = "FETCH";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.INST_OP_WIDTH = "2";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.PROC_ID = "0";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.QUAD_ID = "0";
cgtop.SubInstances.DUT.SubInstances.p0.ImmutableParameters.TILE_ID = "0";
cgtop.SubInstances.DUT.SubInstances.p0.InstanceName = "p0";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.DATA_BUS_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.INSTRUCTION_BUS_WIDTH = "64";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS = new Object();

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[0] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[0].name = "METALOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[0].tiecode = "4";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[1] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[1].name = "METASTORE";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[1].tiecode = "36";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[2] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[2].name = "SYNCLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[2].tiecode = "2";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[3] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[3].name = "SYNCSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[3].tiecode = "34";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[4] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[4].name = "RESETLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[4].tiecode = "3";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[5] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[5].name = "SETSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[5].tiecode = "35";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[6] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[6].name = "FUTURELOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[6].tiecode = "1";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[7] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[7].name = "RAWLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[7].tiecode = "5";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[8] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[8].name = "RAWSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[8].tiecode = "37";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[9] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[9].name = "RAWMETALOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[9].tiecode = "6";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[10] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[10].name = "RAWMETASTORE";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[10].tiecode = "38";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[11] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[11].name = "FIFOLOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[11].tiecode = "7";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[12] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[12].name = "FIFOSTORE";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[12].tiecode = "39";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[13] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[13].name = "CACHEGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[13].tiecode = "40";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[14] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[14].name = "CACHECONDGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[14].tiecode = "41";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[15] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[15].name = "MATGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[15].tiecode = "42";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[16] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[16].name = "MATCONDGANGCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[16].tiecode = "43";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[17] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[17].name = "HARDINTCLEAR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[17].tiecode = "44";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[18] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[18].name = "MEMBAR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[18].tiecode = "19";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[19] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[19].name = "SM_DHWB";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[19].tiecode = "52";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[20] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[20].name = "SM_DHWBI";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[20].tiecode = "53";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[21] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[21].name = "SM_DHI";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[21].tiecode = "54";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[22] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[22].name = "SM_DII";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[22].tiecode = "55";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[23] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[23].name = "SM_DIWB";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[23].tiecode = "56";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[24] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[24].name = "SM_DIWBI";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[24].tiecode = "57";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[25] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[25].name = "SM_DPFR";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[25].tiecode = "58";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[26] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[26].name = "SM_DPFW";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[26].tiecode = "59";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[27] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[27].name = "SM_IHI";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[27].tiecode = "60";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[28] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[28].name = "SM_III";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[28].tiecode = "61";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[29] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[29].name = "SM_IPF";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[29].tiecode = "62";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[30] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[30].name = "SAFE_LOAD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[30].tiecode = "16";

cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[31] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[31].name = "SPEC_CMD";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.SPECIAL_DATA_MEM_OPS[31].tiecode = "46";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.TIE_OPCODE_WIDTH = "6";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.USE_SHIM = "off";
cgtop.SubInstances.DUT.SubInstances.p0.Parameters.USE_XT = "SIM4Xtensa";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.ImmutableParameters.FLOP_WIDTH = "16";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.InstanceName = "BInterrupt_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.BInterrupt_flop.UniqueModuleName = "flop_unq4";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.InstanceName = "DRamAddr_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamAddr_flop.UniqueModuleName = "flop_unq3";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.ImmutableParameters.FLOP_WIDTH = "4";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.InstanceName = "DRamByteEn_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamByteEn_flop.UniqueModuleName = "flop_unq8";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.InstanceName = "DRamData_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamData_flop.UniqueModuleName = "flop_unq3";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.ImmutableParameters.FLOP_WIDTH = "6";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.InstanceName = "DRamOp_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamOp_flop.UniqueModuleName = "flop_unq9";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.InstanceName = "DRamWrData_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.DRamWrData_flop.UniqueModuleName = "flop_unq3";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.ImmutableParameters.FLOP_WIDTH = "27";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.InstanceName = "IRamAddr_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamAddr_flop.UniqueModuleName = "flop_unq5";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.InstanceName = "IRamBusy_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamBusy_flop.UniqueModuleName = "flop_unq1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.ImmutableParameters.FLOP_WIDTH = "64";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.InstanceName = "IRamData_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamData_flop.UniqueModuleName = "flop_unq2";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.ImmutableParameters.FLOP_WIDTH = "2";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.InstanceName = "IRamOp_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamOp_flop.UniqueModuleName = "flop_unq7";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.ImmutableParameters.FLOP_WIDTH = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.InstanceName = "IRamWordEn_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWordEn_flop.UniqueModuleName = "flop_unq6";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.ImmutableParameters.FLOP_WIDTH = "64";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.InstanceName = "IRamWrData_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.IRamWrData_flop.UniqueModuleName = "flop_unq2";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.InstanceName = "Stall_flop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.Stall_flop.UniqueModuleName = "flop_unq1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgIn.InstanceName = "cfgIn";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgOut.InstanceName = "cfgOut";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.cfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.procClkGen = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.procClkGen.BaseModuleName = "procClkGen";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.procClkGen.InstanceName = "procClkGen";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.procClkGen.UniqueModuleName = "procClkGen_unq1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.BaseModuleName = "reg_file";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST = new Object();

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[0] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[0].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[0].comment = "ProcessordebugdatafromWstage";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[0].name = "PDebugData";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[0].width = "32";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[1] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[1].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[1].comment = "DebugstatusduringWstage";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[1].name = "PDebugStatus";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[1].width = "8";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[2] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[2].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[2].comment = "ProcessorPC";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[2].name = "PDebugPC";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[2].width = "32";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[3] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[3].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[3].comment = "ProcessorLSUstatus";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[3].name = "PDebugLS0Stat";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[3].width = "4";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[4] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[4].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[4].comment = "ProcessorLSUaddress";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[4].name = "PDebugLS0Addr";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[4].width = "32";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[5] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[5].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[5].comment = "ProcessorLSUdata";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[5].name = "PDebugLS0Data";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[5].width = "32";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[6] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[6].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[6].comment = "Processorwaitingforinterruptafterwaiti";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[6].name = "PWaitMode";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[6].width = "1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[7] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[7].IEO = "i";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[7].comment = "ProcessorenteredOCDmode";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[7].name = "XOCDMode";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[7].width = "1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[8] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[8].IEO = "o";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[8].comment = "Ifsetprocessorentersdebugstateafterreset";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[8].defaultHACK = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[8].name = "OCDHaltOnReset";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[8].width = "1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[9] = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[9].IEO = "o";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[9].comment = "ProcessorResetsignal";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[9].defaultHACK = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[9].name = "SoftReset";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.ImmutableParameters.REG_LIST[9].width = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.InstanceName = "rf";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters.BASE_ADDR = "0";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters.CFG_OPCODES = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters.CFG_OPCODES.bypass = "3";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters.CFG_OPCODES.nop = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters.CFG_OPCODES.read = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.Parameters.CFG_OPCODES.write = "2";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances = new Object();

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.InstanceName = "OCDHaltOnReset_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.OCDHaltOnReset_reg.UniqueModuleName = "flop_unq14";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.InstanceName = "PDebugData_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugData_reg.UniqueModuleName = "flop_unq11";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.InstanceName = "PDebugLS0Addr_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Addr_reg.UniqueModuleName = "flop_unq11";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.InstanceName = "PDebugLS0Data_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Data_reg.UniqueModuleName = "flop_unq11";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.ImmutableParameters.FLOP_WIDTH = "4";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.InstanceName = "PDebugLS0Stat_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugLS0Stat_reg.UniqueModuleName = "flop_unq13";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.ImmutableParameters.FLOP_WIDTH = "32";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.InstanceName = "PDebugPC_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugPC_reg.UniqueModuleName = "flop_unq11";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.ImmutableParameters.FLOP_WIDTH = "8";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.InstanceName = "PDebugStatus_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PDebugStatus_reg.UniqueModuleName = "flop_unq12";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.InstanceName = "PWaitMode_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.PWaitMode_reg.UniqueModuleName = "flop_unq14";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.ImmutableParameters.FLOP_DEFAULT = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.InstanceName = "SoftReset_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.SoftReset_reg.UniqueModuleName = "flop_unq15";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.ImmutableParameters.FLOP_WIDTH = "1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.InstanceName = "XOCDMode_reg";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.Parameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.Parameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.Parameters.FLOP_TYPE = "REFLOP";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.XOCDMode_reg.UniqueModuleName = "flop_unq14";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn.InstanceName = "cfgIn";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.BaseModuleName = "flop";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_DEFAULT = "0";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_TYPE = "rflop";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.ImmutableParameters.FLOP_WIDTH = "66";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.InstanceName = "cfgIn_floper";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgIn_floper.UniqueModuleName = "flop_unq10";

cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgOut = new Object();
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgOut.InstanceName = "cfgOut";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.SubInstances.cfgOut.UniqueModuleName = "cfg_ifc_unq1";
cgtop.SubInstances.DUT.SubInstances.p0.SubInstances.rf.UniqueModuleName = "reg_file_unq1";
cgtop.SubInstances.DUT.SubInstances.p0.UniqueModuleName = "processor_unq1";

cgtop.SubInstances.DUT.SubInstances.p2ms1 = new Object();
cgtop.SubInstances.DUT.SubInstances.p2ms1.BaseModuleName = "p2ms_xbar";

cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters = new Object();
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[0] = "32";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[1] = "6";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[2] = "4";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[3] = "32";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[4] = "64";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[5] = "2";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[6] = "2";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.INPUT_WIDTHS[7] = "32";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.MAP_IN = "targ_mem_blocks";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.MAP_IN_SIZE = "1";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.MAP_OUT = "req_proc";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.MAP_OUT_SIZE = "1";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.OUTPUT_GROUPS = "1";

cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.OUTPUT_WIDTHS = new Object();
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.OUTPUT_WIDTHS[0] = "64";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.OUTPUT_WIDTHS[1] = "3";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.OUTPUT_WIDTHS[2] = "8";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.OUTPUT_WIDTHS[3] = "32";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.PC_WIDTH = "78";

cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.PORTS = new Object();
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.PORTS[0] = "data";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.PORTS[1] = "instr";

cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.SIGNALS = new Object();
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.SIGNALS[0] = "data";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.SIGNALS[1] = "op";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.SIGNALS[2] = "en";
cgtop.SubInstances.DUT.SubInstances.p2ms1.ImmutableParameters.SIGNALS[3] = "addr";
cgtop.SubInstances.DUT.SubInstances.p2ms1.InstanceName = "p2ms1";
cgtop.SubInstances.DUT.SubInstances.p2ms1.UniqueModuleName = "p2ms_xbar_unq1";
cgtop.SubInstances.DUT.UniqueModuleName = "tile_unq1";

cgtop.SubInstances.dut2tst_cfg_ifc = new Object();
cgtop.SubInstances.dut2tst_cfg_ifc.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.dut2tst_cfg_ifc.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.dut2tst_cfg_ifc.InstanceName = "dut2tst_cfg_ifc";
cgtop.SubInstances.dut2tst_cfg_ifc.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.tb = new Object();
cgtop.SubInstances.tb.BaseModuleName = "test";

cgtop.SubInstances.tb.ImmutableParameters = new Object();
cgtop.SubInstances.tb.ImmutableParameters.CFG_IFC_REF = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.tb.ImmutableParameters.DATA_EN_SIZE = "4";

cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST = new Object();
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[0] = "NOP";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[1] = "LOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[2] = "STORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[3] = "METALOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[4] = "METASTORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[5] = "SYNCLOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[6] = "SYNCSTORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[7] = "RESETLOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[8] = "SETSTORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[9] = "FUTURELOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[10] = "RAWLOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[11] = "RAWSTORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[12] = "RAWMETALOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[13] = "RAWMETASTORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[14] = "FIFOLOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[15] = "FIFOSTORE";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[16] = "CACHEGANGCLEAR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[17] = "CACHECONDGANGCLEAR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[18] = "MATGANGCLEAR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[19] = "MATCONDGANGCLEAR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[20] = "HARDINTCLEAR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[21] = "MEMBAR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[22] = "SM_DHWB";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[23] = "SM_DHWBI";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[24] = "SM_DHI";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[25] = "SM_DII";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[26] = "SM_DIWB";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[27] = "SM_DIWBI";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[28] = "SM_DPFR";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[29] = "SM_DPFW";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[30] = "SM_IHI";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[31] = "SM_III";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[32] = "SM_IPF";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[33] = "SAFE_LOAD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_LIST[34] = "SPEC_CMD";
cgtop.SubInstances.tb.ImmutableParameters.DATA_OP_SIZE = "6";
cgtop.SubInstances.tb.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.tb.ImmutableParameters.INSTR_EN_SIZE = "2";

cgtop.SubInstances.tb.ImmutableParameters.INSTR_OP_LIST = new Object();
cgtop.SubInstances.tb.ImmutableParameters.INSTR_OP_LIST[0] = "NOP";
cgtop.SubInstances.tb.ImmutableParameters.INSTR_OP_LIST[1] = "LOAD";
cgtop.SubInstances.tb.ImmutableParameters.INSTR_OP_LIST[2] = "STORE";
cgtop.SubInstances.tb.ImmutableParameters.INSTR_OP_LIST[3] = "FETCH";
cgtop.SubInstances.tb.ImmutableParameters.INSTR_OP_SIZE = "2";
cgtop.SubInstances.tb.ImmutableParameters.INSTR_SIZE = "64";
cgtop.SubInstances.tb.ImmutableParameters.MAT_ADDR_SIZE = "32";
cgtop.SubInstances.tb.ImmutableParameters.MAT_EN_SIZE = "8";
cgtop.SubInstances.tb.ImmutableParameters.MAT_RET_CODE = "32";
cgtop.SubInstances.tb.ImmutableParameters.META_SIZE = "64";
cgtop.SubInstances.tb.ImmutableParameters.NUM_PROCESSOR = "1";
cgtop.SubInstances.tb.ImmutableParameters.QUAD_ID = "0";
cgtop.SubInstances.tb.ImmutableParameters.TILE_ID = "0";
cgtop.SubInstances.tb.InstanceName = "tb";

cgtop.SubInstances.tb.Parameters = new Object();
cgtop.SubInstances.tb.Parameters.MAX_CYCLES = "100000";

cgtop.SubInstances.tb.SubInstances = new Object();

cgtop.SubInstances.tb.SubInstances.cfgIn = new Object();
cgtop.SubInstances.tb.SubInstances.cfgIn.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.tb.SubInstances.cfgIn.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.tb.SubInstances.cfgIn.InstanceName = "cfgIn";
cgtop.SubInstances.tb.SubInstances.cfgIn.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.tb.SubInstances.cfgOut = new Object();
cgtop.SubInstances.tb.SubInstances.cfgOut.BaseModuleName = "cfg_ifc";
cgtop.SubInstances.tb.SubInstances.cfgOut.CloneOf = "INSTANCE_PATH:top.tst2dut_cfg_ifc";
cgtop.SubInstances.tb.SubInstances.cfgOut.InstanceName = "cfgOut";
cgtop.SubInstances.tb.SubInstances.cfgOut.UniqueModuleName = "cfg_ifc_unq1";

cgtop.SubInstances.tb.SubInstances.dtrans = new Object();
cgtop.SubInstances.tb.SubInstances.dtrans.BaseModuleName = "transaction";
cgtop.SubInstances.tb.SubInstances.dtrans.CloneOf = "INSTANCE_PATH:top.tb.pc.dtrans";
cgtop.SubInstances.tb.SubInstances.dtrans.InstanceName = "dtrans";
cgtop.SubInstances.tb.SubInstances.dtrans.UniqueModuleName = "transaction_unq1";

cgtop.SubInstances.tb.SubInstances.dtrans_out = new Object();
cgtop.SubInstances.tb.SubInstances.dtrans_out.BaseModuleName = "transaction";
cgtop.SubInstances.tb.SubInstances.dtrans_out.CloneOf = "INSTANCE_PATH:top.tb.pc.dtrans_out";
cgtop.SubInstances.tb.SubInstances.dtrans_out.InstanceName = "dtrans_out";
cgtop.SubInstances.tb.SubInstances.dtrans_out.UniqueModuleName = "transaction_unq2";

cgtop.SubInstances.tb.SubInstances.itrans = new Object();
cgtop.SubInstances.tb.SubInstances.itrans.BaseModuleName = "transaction";
cgtop.SubInstances.tb.SubInstances.itrans.CloneOf = "INSTANCE_PATH:top.tb.pc.itrans";
cgtop.SubInstances.tb.SubInstances.itrans.InstanceName = "itrans";
cgtop.SubInstances.tb.SubInstances.itrans.UniqueModuleName = "transaction_unq3";

cgtop.SubInstances.tb.SubInstances.itrans_out = new Object();
cgtop.SubInstances.tb.SubInstances.itrans_out.BaseModuleName = "transaction";
cgtop.SubInstances.tb.SubInstances.itrans_out.CloneOf = "INSTANCE_PATH:top.tb.pc.itrans_out";
cgtop.SubInstances.tb.SubInstances.itrans_out.InstanceName = "itrans_out";
cgtop.SubInstances.tb.SubInstances.itrans_out.UniqueModuleName = "transaction_unq2";

cgtop.SubInstances.tb.SubInstances.mem_mgr = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.BaseModuleName = "mem_mgr";

cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.ADDR_SIZE = "32";

cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[0] = "NOP";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[1] = "LOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[2] = "STORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[3] = "METALOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[4] = "METASTORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[5] = "SYNCLOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[6] = "SYNCSTORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[7] = "RESETLOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[8] = "SETSTORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[9] = "FUTURELOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[10] = "RAWLOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[11] = "RAWSTORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[12] = "RAWMETALOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[13] = "RAWMETASTORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[14] = "FIFOLOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[15] = "FIFOSTORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[16] = "CACHEGANGCLEAR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[17] = "CACHECONDGANGCLEAR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[18] = "MATGANGCLEAR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[19] = "MATCONDGANGCLEAR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[20] = "HARDINTCLEAR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[21] = "MEMBAR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[22] = "SM_DHWB";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[23] = "SM_DHWBI";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[24] = "SM_DHI";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[25] = "SM_DII";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[26] = "SM_DIWB";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[27] = "SM_DIWBI";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[28] = "SM_DPFR";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[29] = "SM_DPFW";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[30] = "SM_IHI";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[31] = "SM_III";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[32] = "SM_IPF";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[33] = "SAFE_LOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_OP_LIST[34] = "SPEC_CMD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.EN_SIZE = "8";

cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.INSTR_OP_LIST = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.INSTR_OP_LIST[0] = "NOP";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.INSTR_OP_LIST[1] = "LOAD";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.INSTR_OP_LIST[2] = "STORE";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.INSTR_OP_LIST[3] = "FETCH";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.INSTR_SIZE = "64";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.META_SIZE = "64";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.NUM_PROCESSOR = "1";
cgtop.SubInstances.tb.SubInstances.mem_mgr.ImmutableParameters.OP_SIZE = "6";
cgtop.SubInstances.tb.SubInstances.mem_mgr.InstanceName = "mem_mgr";

cgtop.SubInstances.tb.SubInstances.mem_mgr.Parameters = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.Parameters.INITIAL_TYPE = "zero";

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances = new Object();

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.BaseModuleName = "generic_memory";

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.ImmutableParameters.INITIAL_TYPE = "zero";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.ImmutableParameters.INSTR_SIZE = "64";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.ImmutableParameters.META_SIZE = "64";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.InstanceName = "mem";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mem.UniqueModuleName = "generic_memory_unq1";

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_in = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_in.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_in.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_in.ImmutableParameters.PAYLOAD = "110";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_in.InstanceName = "mtrans_in";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_in.UniqueModuleName = "transaction_unq4";

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_out = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_out.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_out.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_out.ImmutableParameters.PAYLOAD = "128";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_out.InstanceName = "mtrans_out";
cgtop.SubInstances.tb.SubInstances.mem_mgr.SubInstances.mtrans_out.UniqueModuleName = "transaction_unq2";
cgtop.SubInstances.tb.SubInstances.mem_mgr.UniqueModuleName = "mem_mgr_unq1";

cgtop.SubInstances.tb.SubInstances.pc = new Object();
cgtop.SubInstances.tb.SubInstances.pc.BaseModuleName = "pc";

cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.ADDR_SIZE = "32";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.DATA_EN_SIZE = "4";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.DATA_OP_SIZE = "6";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.DATA_SIZE = "32";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.INSTR_EN_SIZE = "2";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.INSTR_OP_SIZE = "2";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.INSTR_SIZE = "64";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.MAT_EN_SIZE = "8";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.META_SIZE = "64";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.NUM_PROCESSOR = "1";
cgtop.SubInstances.tb.SubInstances.pc.ImmutableParameters.RET_SIZE = "32";
cgtop.SubInstances.tb.SubInstances.pc.InstanceName = "pc";

cgtop.SubInstances.tb.SubInstances.pc.Parameters = new Object();

cgtop.SubInstances.tb.SubInstances.pc.Parameters.OP_LIST = new Object();
cgtop.SubInstances.tb.SubInstances.pc.Parameters.OP_LIST.NOP = "2";
cgtop.SubInstances.tb.SubInstances.pc.Parameters.OP_LIST.RD = "0";
cgtop.SubInstances.tb.SubInstances.pc.Parameters.OP_LIST.WR = "1";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances = new Object();

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans.ImmutableParameters.PAYLOAD = "74";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans.InstanceName = "dtrans";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans.UniqueModuleName = "transaction_unq1";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans_out = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans_out.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans_out.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans_out.ImmutableParameters.PAYLOAD = "128";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans_out.InstanceName = "dtrans_out";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.dtrans_out.UniqueModuleName = "transaction_unq2";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans.ImmutableParameters.PAYLOAD = "100";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans.InstanceName = "itrans";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans.UniqueModuleName = "transaction_unq3";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans_out = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans_out.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans_out.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans_out.ImmutableParameters.PAYLOAD = "128";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans_out.InstanceName = "itrans_out";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.itrans_out.UniqueModuleName = "transaction_unq2";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_in = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_in.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_in.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_in.ImmutableParameters.PAYLOAD = "110";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_in.InstanceName = "mtrans_in";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_in.UniqueModuleName = "transaction_unq4";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_out = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_out.BaseModuleName = "transaction";

cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_out.ImmutableParameters = new Object();
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_out.ImmutableParameters.PAYLOAD = "128";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_out.InstanceName = "mtrans_out";
cgtop.SubInstances.tb.SubInstances.pc.SubInstances.mtrans_out.UniqueModuleName = "transaction_unq2";
cgtop.SubInstances.tb.SubInstances.pc.UniqueModuleName = "pc_unq1";
cgtop.SubInstances.tb.UniqueModuleName = "test_unq1";

cgtop.SubInstances.tst2dut_cfg_ifc = new Object();
cgtop.SubInstances.tst2dut_cfg_ifc.BaseModuleName = "cfg_ifc";

cgtop.SubInstances.tst2dut_cfg_ifc.ImmutableParameters = new Object();
cgtop.SubInstances.tst2dut_cfg_ifc.ImmutableParameters.CFG_ADDR_WIDTH = "32";
cgtop.SubInstances.tst2dut_cfg_ifc.ImmutableParameters.CFG_BUS_WIDTH = "32";
cgtop.SubInstances.tst2dut_cfg_ifc.ImmutableParameters.CFG_OPCODE_WIDTH = "2";
cgtop.SubInstances.tst2dut_cfg_ifc.InstanceName = "tst2dut_cfg_ifc";
cgtop.SubInstances.tst2dut_cfg_ifc.UniqueModuleName = "cfg_ifc_unq1";
cgtop.UniqueModuleName = "top";
//--></script>
