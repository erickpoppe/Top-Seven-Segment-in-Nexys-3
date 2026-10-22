#### Top-Seven-Segment-in-Nexys-3 Spartan 6 FPGA (XC6LX16)

# Adaptive 7-Segment Multiplexed Clock Driver

An optimized, structurally sound 4-digit 7-segment multiplexed display driver written in **VHDL** for the **Digilent Nexys 3** development board. This project implements a real-time, 1-second hexadecimal counter that accurately tracks time intervals by dividing the board's native high-frequency oscillator down to human-perceivable limits.

---

## 🛠️ Project Architecture

```text
📁 Top-Seven-Segment-in-Nexys-3/
├── 📁 rtl/
│   └── top_seven_seg.vhd   # Core VHDL Synthesis Model
└── 📁 constraints/
    └── nexys3.ucf          # Xilinx User Constraints File (Hardware Pins)
```

The design avoids vector direction bugs (MSB/LSB confusion) commonly found when interfacing VHDL array busses with board traces by implementing **Explicit Structural Segment Pin Mapping**.

---

## 🔌 Hardware Specifications

* **Target Device:** Xilinx Spartan-6 (`XC6SLX16-3CSG324C`)
* **Onboard Clock:** 100 MHz Oscillator (Pin `V10`)
* **Reset Infrastructure:** Active-HIGH asynchronous reset bound to Switch 0 (`T10`)
* **Display Configuration:** Common-anode, active-LOW multiplexed 4-digit panel

---

## ⚙️ How it Works under the Hood

1. **Clock Dividing:** A 27-bit prescaler register slices the raw 100MHz clock signal (`100,000,000` cycles) into a rhythmic 1-second trigger pulse that advances our main `time_data` register.
2. **Display Scanning:** A rapid 17-bit refresh loop cycles through each display digit roughly 762 times per second. This triggers individual anodes sequentially, leveraging human **Persistence of Vision (POV)** to make all four numbers appear illuminated simultaneously.
3. **Hex Decoder Matrix:** A combinational lookup logic structure directly interfaces with segments `CA` through `CG` and the Decimal Point (`DP`) using clear-mapped intermediate signals to remove bus ordering bugs.

---

## 🚀 Reproduction & Deployment (Ubuntu Linux)

### 1. Prerequisites
Ensure you have the legacy Xilinx toolchain installed on your Linux system, alongside the Digilent Adept command-line configuration utility:
* **Synthesis Tool:** Xilinx ISE WebPACK 14.7
* **JTAG Utility:** Digilent Adept 2 Utilities (`djtgcfg`)

### 2. Hardware Wiring Configuration
To safely power and program the Nexys 3 board from your computer:
1. Ensure the board power jumper (**JP1**, directly adjacent to the power toggle) is slid over the pins marked **`USB`**. 
2. Hook up **two separate micro-USB cables** from your Ubuntu workstation into the board:
   * **Cable 1:** Plugs into **`USB PROG`** (handles boundary scan JTAG operations).
   * **Cable 2:** Plugs into **`USB UART`** (creates the serial device architecture node).
3. Flip the board's mechanical **`POWER`** switch to **ON**.

### 3. Compilation
Synthesize, map, and place-and-route the design using the Xilinx ISE Project Navigator GUI or your automated command-line Makefile scripts targeting the `XC6SLX16-3CSG324C` profile. This will yield a final compiled binary bitstream file named `top_seven_seg.bit`.

### 4. Flashing to the Spartan-6 Architecture
Open your Ubuntu shell interface and move into your active project build workspace directory:

```bash
# Verify your Ubuntu system can communicate with the hardware programmer hub
djtgcfg enum

# Run a quick diagnostic sweep to ensure the JTAG target scan chain initializes cleanly
djtgcfg init -d Nexys3

# Flash the compiled configuration logic onto the target SRAM partition
djtgcfg prog -d Nexys3 -i 0 -f top_seven_seg.bit
```

---

## 📝 Author & Project Metadata

* **Engineer:** Erick Poppe
* **University/Company:** Digilent Atlys Lab Portfolio
* **Development Date:** October 21, 2024
* **Project Framework:** Adaptive Video Clocking & Dynamic Diagnostics

---

