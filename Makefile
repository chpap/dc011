# ghdl
GHDL_CMD = ghdl
GHDL_FLAGS  = -fsynopsys --std=08

I = delay.vhd vtiming.vhd htiming.vhd clk_divider.vhd ff.vhd hor_counter.vhd ver_counter.vhd dot_counter.vhd frac_divider.vhd static_clk_divider.vhd dc011.vhd
T = dc011.test.vhd
E = dc011_tb

I2 = delay.vhd vtiming.vhd htiming.vhd clk_divider.vhd ff.vhd hor_counter.vhd ver_counter.vhd dot_counter.vhd frac_divider.vhd static_clk_divider.vhd dc011.vhd dc012.vhd
T2 = dc012.test.vhd
E2 = dc012_tb

WAVES_DIR = waves

S_TIME = 40ms
all: dc011 dc012

dc011:
	@mkdir -p $(WAVES_DIR)
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(I) $(T) 
	$(GHDL_CMD) -e $(GHDL_FLAGS) $(E)
	$(GHDL_CMD) -r $(GHDL_FLAGS) $(E) --vcd=$(WAVES_DIR)/$(E).vcd --wave=$(WAVES_DIR)/$(E).ghw --stop-time=$(S_TIME)

dc012:
	@mkdir -p $(WAVES_DIR)
	$(GHDL_CMD) -a $(GHDL_FLAGS) $(I2) $(T2) 
	$(GHDL_CMD) -e $(GHDL_FLAGS) $(E2)
	$(GHDL_CMD) -r $(GHDL_FLAGS) $(E2) --vcd=$(WAVES_DIR)/$(E2).vcd --wave=$(WAVES_DIR)/$(E2).ghw --stop-time=$(S_TIME)

