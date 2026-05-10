# This file is public domain, it can be freely copied without restrictions.
# SPDX-License-Identifier: CC0-1.0
from __future__ import annotations

import os
import random
from pathlib import Path

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer
from cocotb_tools.runner import get_runner, Verilog

LANGUAGE = os.getenv("TOPLEVEL_LANG", "verilog").lower().strip()

async def start_clocks(dut):
    """Start 100 and 24 Mhz clocks"""
    # Create a 10us period clock driver on port `clk`

@cocotb.test()
async def i8xxx_simple_test(dut):
    """Test that d propagates to q"""
    # task = cocotb.start_soon(start_clocks(dut))
    clock = Clock(dut.clk_i, 10, unit="ns")
    clock.start(start_high=False)
    clock24 = Clock(dut.clk24_i, 41.6, unit="ns")
    clock24.start(start_high=False)
    dut.reset.value = "1"
    # Create a 10us period clock driver on port `clk`
    # Start the clock. Start it low to avoid issues on the first RisingEdge

    # Synchronize with the clock. This will register the initial `d` value
    await RisingEdge(dut.clk24_i)
    dut.reset.value = "0"
    await Timer(1, unit="ms")

    # Check the final input on the next clock
    #await RisingEdge(dut.clk)


def test_simple_dff_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent

    if LANGUAGE == "verilog":
        sources = [Verilog(proj_path / "vm80a/vm80a.v"), Verilog(proj_path / "vm80a/i8224.v"), Verilog(proj_path / "vm80a/i8xxx.v")]
    else:
        print("no supported")
        exit(1)
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="i8xxx",
        waves=True,
        always=True,
    )

    #runner.test(hdl_toplevel="i8xxx", test_module="i8xxx_simple_test")
    runner.test(hdl_toplevel="i8xxx", test_module="test_i8xxx_runner")
