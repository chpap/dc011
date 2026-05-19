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

async def sync_8080(dut):
    """Start 100 and 24 Mhz clocks"""
    # Create a 10us period clock driver on port `clk`
    while True:
      await RisingEdge(dut.clk_f1)
      dut.sync.value=0
      await Timer(150, unit="ns")
      dut.sync.value=1

@cocotb.test()
async def i8xxx_simple_test(dut):
    """Start 100 and 24 Mhz clocks"""
    #task = cocotb.start_soon(sync_8080(dut))
    # Create a 10us period clock driver on port `clk`
    clock = Clock(dut.clk_i, 10, unit="ns")
    clock.start(start_high=False)
    clock24 = Clock(dut.clk24_i, 41.6, unit="ns")
    clock24.start(start_high=False)
    dut.n_reset_i.value = "0"
    dut.hold_i.value = "0"
    dut.int_i.value = "0"
    dut.ready_i.value = "1"
    dut.d_i.value = "00000000"
    # Start the clock. Start it low to avoid issues on the first RisingEdge
    await RisingEdge(dut.clk24_i)
    await Timer(200, unit="ns")
    dut.n_reset_i.value = "1"
    await Timer(5000, unit="ns")
    dut.n_reset_i.value = "0"
    await Timer(1000, unit="ns")
    dut.n_reset_i.value = "1"

    await Timer(2, unit="ms")
    # Check the final input on the next clock
    #await RisingEdge(dut.clk)


def test_simple_dff_runner():
    sim = os.getenv("SIM", "icarus")

    proj_path = Path(__file__).resolve().parent

    if LANGUAGE == "verilog":
        sources = [Verilog(proj_path / "vm80a/vm80a.v"), Verilog(proj_path / "vm80a/i8224.v"), Verilog(proj_path / "vm80a/i8xxx.v"), Verilog(proj_path / "vm80a/i8228.v")]
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
