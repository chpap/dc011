# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
from __future__ import annotations

import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_tools.runner import get_runner, Verilog, VHDL

LANGUAGE = os.getenv("TOPLEVEL_LANG", "VHDL").lower().strip()

async def sync_8080(dut):
    """Start 100 and 24 Mhz clocks"""
    # Create a 10us period clock driver on port `clk`
    while True:
      await RisingEdge(dut.clk_f1)
      dut.sync.value=0
      await Timer(150, unit="ns")
      dut.sync.value=1

async def start_clocks(dut):
    """Start 100 and 24 Mhz clocks"""
    # Create a 10us period clock driver on port `clk`

@cocotb.test()
async def i8xxx_simple_test(dut):
    """Test that d propagates to q"""
    #task = cocotb.start_soon(sync_8080(dut))
    clock = Clock(dut.clk_i, 10, unit="ns")
    clock.start(start_high=False)
    clock24 = Clock(dut.clk24_i, 41.6, unit="ns")
    clock24.start(start_high=False)
    dut.n_reset_i.value = "1"
    # Create a 10us period clock driver on port `clk`
    # Start the clock. Start it low to avoid issues on the first RisingEdge

    # Synchronize with the clock. This will register the initial `d` value
    await RisingEdge(dut.clk24_i)
    await Timer(200, unit="ns")
    dut.n_reset_i.value = "0"
    await Timer(1, unit="ms")

    # Check the final input on the next clock
    #await RisingEdge(dut.clk)


def test_simple_dff_runner():
    sim = os.getenv("SIM", "ghdl")

    proj_path = Path(__file__).resolve().parent

    if LANGUAGE == "vhdl":
        #sources = [Verilog(proj_path / "vm80a/vm80a.v"), Verilog(proj_path / "vm80a/i8224.v"), Verilog(proj_path / "vm80a/i8xxx.v"), Verilog(proj_path / "vm80a/i8228.v")]
        sources = [
                proj_path /"dc0112_pkg.vhd",
                proj_path /"delay.vhd",
                proj_path /"vtiming.vhd",
                proj_path /"htiming.vhd",
                proj_path /"ff.vhd",
                proj_path /"ripple_counter.vhd",
                proj_path /"clk_divider.vhd",
                proj_path /"frac_divider.vhd",
                proj_path /"static_clk_divider.vhd",
                proj_path /"hor_counter.vhd",
                proj_path /"ver_counter.vhd",
                proj_path /"dot_counter.vhd",
                proj_path /"dc011.vhd",
                proj_path /"vt100.vhd",
                proj_path /"top_vt100.vhd" ]
    else:
        print("no supported")
        exit(1)
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="top_vt100",
        build_args=[
            VHDL("-fsynopsys"),
            VHDL("--std=08"),
            VHDL("obj_dir/libVi8xxx.a")
            ],
        waves=True,
        always=True,
    )

    #runner.test(hdl_toplevel="i8xxx", test_module="i8xxx_simple_test")
    runner.test(hdl_toplevel="top_vt100", test_module="test_vt100_runner")
