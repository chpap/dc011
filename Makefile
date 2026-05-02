# ghdl
GHDL_CMD = ghdl
GHDL_FLAGS  = -fsynopsys --std=08

I = delay.vhd vtiming.vhd htiming.vhd clk_divider.vhd ff.vhd hor_counter.vhd ver_counter.vhd dot_counter.vhd frac_divider.vhd static_clk_divider.vhd clock_divider.vhd dc011.vhd
T = dc011.test.vhd
E = dc011_tb

WAVES_DIR = waves

S_TIME = 10ms

compile:
	@mkdir -p $(WAVES_DIR)
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(I) $(T) 
	$(GHDL_CMD) -e $(GHDL_FLAGS) $(E)
	$(GHDL_CMD) -r $(GHDL_FLAGS) $(E) --vcd=$(WAVES_DIR)/$(E).vcd --wave=$(WAVES_DIR)/$(E).ghw --stop-time=$(S_TIME)

