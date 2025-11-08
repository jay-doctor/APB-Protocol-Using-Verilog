# APB Protocol Implementation and Testbench

## Overview
This project implements a complete Advanced Peripheral Bus (APB) protocol system designed according to the AMBA APB specification. The system includes an APB master controller, two APB slave devices with internal memory, and a top-level integration module. A comprehensive testbench verifies the functionality through various test cases including read/write operations, address decoding, error handling, and system reset behavior.

The design is written in Verilog and demonstrates practical implementation of bus protocol concepts with proper finite state machine control, slave selection, and error handling mechanisms.

## Project Structure

### Core Modules
- **APB Master** (`APB_master.v`) - Bus controller with FSM-based transaction management
- **APB Slave** (`APB_slave.v`) - Peripheral device with 256-byte memory and error handling
- **APB Top** (`APB_top.v`) - System integration connecting master and slaves
- **Testbench** (`APB_tb.v`) - Comprehensive verification environment

## Module Specifications

### APB Master Controller
**File:** `APB_master.v`

The master module implements a 3-state finite state machine:
- **IDLE**: Wait for transaction initiation
- **SETUP**: Configure address and control signals
- **ENABLE**: Activate transfer with penable signal

**Key Features:**
- Supports both read and write operations
- Automatic slave selection based on address decoding (bit 8)
- Handles slave ready (pready) and error (pslverr) responses
- Captures read data on successful transaction completion

**Interface Signals:**
- **Control Inputs**: `presetn`, `pclk`, `transfer`, `read`, `write`
- **Address/Data Inputs**: `apb_write_paddr[8:0]`, `apb_write_data[7:0]`, `apb_read_paddr[8:0]`
- **Slave Response**: `pready`, `pslverr`, `prdata[7:0]`
- **APB Bus Outputs**: `psel1`, `psel2`, `penable`, `pwrite`, `paddr[8:0]`, `pwdata[7:0]`
- **Data Output**: `apb_read_data_out[7:0]`

### APB Slave Device
**File:** `APB_slave.v`

Each slave contains a 256-byte memory array and implements the APB slave interface protocol.

**Key Features:**
- 256-byte addressable memory space
- Error generation for out-of-range addresses (paddr > 8'd255)
- Synchronous operation with ready signal generation
- Support for both read and write operations

**Interface Signals:**
- **APB Inputs**: `pclk`, `presetn`, `psel`, `penable`, `pwrite`, `paddr[7:0]`, `pwdata[7:0]`
- **APB Outputs**: `prdata[7:0]`, `pready`, `pslverr`

### Top-Level Integration
**File:** `APB_top.v`

Integrates one master and two slaves with proper signal routing and slave selection logic.

**Address Mapping:**
- **Slave 1**: Address range 0x000-0x0FF (paddr[8] = 0)
- **Slave 2**: Address range 0x100-0x1FF (paddr[8] = 1)

## Testbench Verification
**File:** `APB_tb.v`

The testbench implements a comprehensive verification suite with the following test cases:

### Test Cases
1. **Basic Write Operation** - Write data to valid address
2. **Basic Read Operation** - Read data from previously written location
3. **Slave Selection** - Verify address decoding selects correct slave
4. **Multiple Operations** - Sequential read/write operations
5. **Error Handling** - Write to invalid address triggers pslverr
6. **Reset Behavior** - System recovery after reset assertion

### Test Methodology
- Clock generation with 10ns period (100MHz)
- Systematic task-based testing approach
- Reset sequence verification
- Error condition testing
- Multi-slave address space validation
APB_master.v  
APB_top.v
APB_tb.v
