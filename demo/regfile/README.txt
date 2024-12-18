Simple example but with a fake top (i.e., top is not valid verilog and is
ment to be educational only)
   make clean gen TOP_MODULE=top_flop_only SIM_ENGINE=mentor

Or more realistic example: Register File
   make clean run SIM_ENGINE=mentor

* Replace SIM_ENGINE=mentor with SIM_ENGINE=synopsys for using 
  synopsys simulation tools.
