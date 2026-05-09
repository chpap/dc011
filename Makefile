# ghdl
GHDL_CMD = ghdl
GHDL_FLAGS  = -fsynopsys --std=08 -frelaxed
FAMILY  = artix7
PART    = xc7a100tcsg324-1
BOARD   = arty
PROJECT = dc011
CHIPDB  = ${ARTIX7_CHIPDB}
TOP_MODULE = dc012.test.vhd
NEXTPNR_XILINX_DIR ?= /opt/openxc7/
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/lib/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/share/nextpnr/prjxray-db
# Ρυθμίσεις Στόχου
PART = xc7a100tcsg324
CHIPFAM = artix7

# Αρχεία Εισόδου
XDC_CONSTRAINTS = constraints/nexys-a7.xdc

# Εργαλεία
YOSYS = yosys
NEXTPNR = nextpnr-xilinx
XRAY_DIR = /path/to/prjxray
DB_DIR = $(XRAY_DIR)/database/$(CHIPFAM)

# Ενδιάμεσα Αρχεία
BUILD_DIR = build
JSON = $(BUILD_DIR)/$(PROJECT).json
FASM = $(BUILD_DIR)/$(PROJECT).fasm
FRAMES = $(BUILD_DIR)/$(PROJECT).frames
BITSTREAM = $(PROJECT).bit

# 1. Σύνθεση (VHDL -> JSON) μέσω GHDL plugin
$(JSON): $(VHDL_SOURCES)
	mkdir -p $(BUILD_DIR)
	$(YOSYS)  -m ghdl -p 'ghdl -read --std=08 -frelaxed  $(GHDL_FLAGS) $^ ; synth_xilinx  -flatten -abc9 -arch xc7 -top $(PROJECT);'
	#$(YOSYS) -m ghdl 'ghdl --std=08 $^ -e $(PROJECT); synth_xilinx -flatten -abc9 -arch xc7 -top $(PROJECT); write_json $@'

#analyze: $(VHDL_SOURCES)
# 2. Place & Route (JSON -> FASM)
$(FASM): $(JSON) $(XDC_CONSTRAINTS)
	$(NEXTPNR) --chipdb $(CHIPDB)$(PART).bin --json $< --xdc $(XDC_CONSTRAINTS) --fasm $@
#--device $(PART)
# 3. Δημιουργία Frames (FASM -> Frames)
$(FRAMES): $(FASM)
	fasm2frames --part $(PART) --db-root $(DB_DIR) $< > $@

# 4. Δημιουργία Bitstream (Frames -> Bit)
$(BITSTREAM): $(FRAMES)
	xc7frames2bit --part_file $(DB_DIR)/$(PART)/part.yaml --part_name $(PART) --frm_file $< --output_file $@

.PHONY: all clean
VHDL_SOURCES = dc011.vhd dc012.vhd dc012.test.vhd

include openXC7.mk

I = dc0112_pkg.vhd  delay.vhd vtiming.vhd htiming.vhd ff.vhd ripple_counter.vhd clk_divider.vhd frac_divider.vhd static_clk_divider.vhd hor_counter.vhd ver_counter.vhd dot_counter.vhd dc011.vhd $(I8080)
LIGHT8080 = light8080/light8080_ucode_pkg.vhdl light8080/light8080.vhdl light8080/mcu80_pkg.vhdl light8080/mcu80_uart.vhdl light8080/mcu80_irq.vhdl light8080/mcu80.vhdl light8080/txt_util.vhdl light8080/light8080_tb_pkg.vhdl light8080/obj_code_pkg.vhdl 
T = dc011.test.vhd
I8080=i8080/types.vhd \
	i8080/regfile.vhd \
	i8080/decode.vhd \
	i8080/cpu8080_top.vhd \
	i8080/control.vhd \
	i8080/ctrlreg.vhd \
	i8080/alu.vhd \
	i8080/cpudiag-tb.vhd \
	i8080/cpudiag-memory-sim.vhd
E = dc011_tb

I2 = $(I) dc012.vhd
T2 = dc012.test.vhd
E2 = dc012_tb

WAVES_DIR = waves

CFLAGS = -I/opt/X11/include

S_TIME = 40ms
S_TIME2 = 4ms
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
	$(GHDL_CMD) -r $(GHDL_FLAGS) $(E2) --vcd=$(WAVES_DIR)/$(E2).vcd --wave=$(WAVES_DIR)/$(E2).ghw --stop-time=$(S_TIME2)

x11:
	$(GHDL_CMD) --vpi-compile gcc -c caux_x11.c $(CFLAGS) -o tb_caux.o
