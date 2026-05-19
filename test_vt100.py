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

async def start_clocks(dut):
    """Start 100 and 24 Mhz clocks"""
    # Create a 10us period clock driver on port `clk`
    clock24 = Clock(dut.clk_24_88, 41.6, unit="ns")
    clock24.start(start_high=False)

@cocotb.test()
async def vt100_simple_test(dut):
    """VT100 Test"""
    #task = cocotb.start_soon(sync_8080(dut))
    #task = cocotb.start_soon(start_clocks(dut))
    clock = Clock(dut.clk100, 10, unit="ns")
    clock.start(start_high=False)
    clock24_8 = Clock(dut.clk_24_88, 41.6, unit="ns")
    clock24_8.start(start_high=False)
    clock24 = Clock(dut.clk_24_07, 41.6, unit="ns")
    clock24.start(start_high=False)
    dut.n_reset_i.value = "0"
    dut.clk_locked.value = "1"
    # Create a 10us period clock driver on port `clk`
    # Start the clock. Start it low to avoid issues on the first RisingEdge

    # Synchronize with the clock. This will register the initial `d` value
    #await RisingEdge(dut.clk24_i)
    await Timer(20, unit="ns")
    dut.n_reset_i.value = "1"
    await Timer(2000, unit="ns")
    dut.n_reset_i.value = "0"
    await Timer(2000, unit="ns")
    dut.n_reset_i.value = "1"
    await Timer(1000, unit="ns")
    dut.n_reset_i.value = "0"
    await Timer(3000, unit="ns")
    dut.n_reset_i.value = "1"
    await Timer(200000, unit="ns")
    await Timer(500000, unit="ns")
    #for _ in range(10):
    #  await Timer(2000, unit="ns")
    #   await RisingEdge(dut.clk_24_07)
    #   #await Timer(200, unit="ns")
    #dut.n_reset_i.value = "1"
    #await Timer(200, unit="ns")
    #await Timer(1, unit="ms")

    # Check the final input on the next clock
    #await RisingEdge(dut.clk)


