#NEXTPNR_XILINX_DIR ?= /snap/openxc7/current/opt/nextpnr-xilinx
NEXTPNR_XILINX_DIR ?= /opt/openxc7/lib
NEXTPNR_XILINX_PYTHON_DIR ?= ${NEXTPNR_XILINX_DIR}/python
PRJXRAY_DB_DIR ?= ${NEXTPNR_XILINX_DIR}/external/prjxray-db

DBPART = $(shell echo ${PART} | sed -e 's/-[0-9]//g')
SPEEDGRADE = $(shell echo ${PART} | sed -e 's/.*\-\([0-9]\)/\1/g')

CHIPDB ?= ../chipdb/
ifeq ($(CHIPDB),)
CHIPDB = ../chipdb/
endif

PYPY3 ?= pypy3

TOP ?= ${PROJECT}
TOP_MODULE ?= ${TOP}
TOP_VERILOG ?= ${TOP}.v

PNR_DEBUG ?= # --verbose --debug

BOARD ?= UNKNOWN
JTAG_LINK ?= --board ${BOARD}

XD ?= ${PROJECT}.xdc

#.PHONY: all
#all: ${PROJECT}.bit

.PHONY: burn
burn: ${PROJECT}.bit
	openFPGALoader ${JTAG_LINK} --write-flash --bitstream $<

.PHONY: program
program: ${PROJECT}.bit
	openFPGALoader ${JTAG_LINK} --bitstream $<

#${PROJECT}.json: ${TOP_VERILOG} ${ADDITIONAL_SOURCES}
#	yosys -p "synth_xilinx -flatten -abc9 ${SYNTH_OPTS} -arch xc7 -top ${TOP_MODULE}; write_json ${PROJECT}.json" $< ${ADDITIONAL_SOURCES}

# The chip database only needs to be generated once
# that is why we don't clean it with make clean
${CHIPDB}/${DBPART}.bin:
	${PYPY3} ${NEXTPNR_XILINX_PYTHON_DIR}/bbaexport.py --device ${PART} --bba ${DBPART}.bba
	bbasm -l ${DBPART}.bba ${CHIPDB}/${DBPART}.bin
	rm -f ${DBPART}.bba

$(BUILD_DIR)/${PROJECT}.fasm: $(JSON) ${CHIPDB}/${DBPART}.bin ${XDC}
	nextpnr-xilinx --chipdb ${CHIPDB}/${DBPART}.bin --xdc ${XDC} --json ${BUILD_DIR}/${PROJECT}.json --fasm $@ ${PNR_ARGS} ${PNR_DEBUG}
	
$(FRAMES): $(FASM)
	fasm2frames --part ${PART} --db-root ${PRJXRAY_DB_DIR}/${FAMILY} $< > $@

$(BITSTREAM): $(FRAMES)
	xc7frames2bit --part_file ${PRJXRAY_DB_DIR}/${FAMILY}/${PART}/part.yaml --part_name ${PART} --frm_file $< --output_file $@


#.PHONY: clean
clean::
	@rm -f *.bit
	@rm -f *.o
	@rm -f *.frames
	@rm -f *.fasm
	@rm -f 
	@rm -f $(JSON)
	@rm -rf obj_dir
	@rm -rf .gvi
.PHONY: pnrclean
pnrclean:
	@rm -f $(FASM) $(FRAMES) $(BITSTREAM) 
	rm *.fasm *.frames *.bit
