#!/bin/bash
. /opt/Vivado/2025.2/Vivado/settings64.sh
export PART=xc7a100tcsg324-1
export TOP=top_vt100
export XDC=constraints/nexys-a7.xdc
vivado -mode batch -log vivado.log -source vivado.tcl
