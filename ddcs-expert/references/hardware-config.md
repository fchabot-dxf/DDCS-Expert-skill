# Ultimate Bee 1010 CNC - Complete Hardware Manifest

**Machine Model**: Bulkman 3D Ultimate Bee 1000x1000mm  
**Controller**: DDCS Expert (M350)  
**Date**: January 06, 2026

---

## **Machine History - Controller Upgrade**

**Original Configuration (v4.1):**
- DDCS v4.1 controller
- Magic Cube cabinet with DB37 breakout board
- All sensors/motors through DB37 cable system
- Standard 3-axis or 4-axis configuration

**Upgrade to Expert (M350):**
- Replaced DDCS v4.1 with **DDCS Expert (M350)** controller
- **Kept**: Magic Cube cabinet, DB37 cable, original limit switches
- **Added**: 
  - Rotary B-axis (direct-wired, bypassing DB37)
  - Rotary homing sensor (NPN proximity, direct-wired)
  - Z-probe puck for tool setting (direct-wired)
  - 3D touch probe for digitizing (direct-wired)
  - 5-port Wago hub at controller for 24V distribution

**Result**: **Hybrid wiring architecture** - legacy DB37 system + direct-wired additions

---

## ⚠️ **CRITICAL: NO AUTOMATIC TOOL CHANGER - MANUAL WORKFLOW**

**This machine uses MANUAL TOOL CHANGES ONLY and will NEVER have:**
- ❌ Tool carousel
- ❌ ATC (Automatic Tool Changer)
- ❌ Tool changer equipment of any kind
- ❌ Automatic tool magazine

**ACTUAL WORKFLOW: SEPARATE TOOLPATHS (NO M0)**

**This machine uses SEPARATE G-CODE FILES for each tool:**
- ✅ **One complete toolpath per file** (e.g., "Project_Tool1_6mmEM.nc", "Project_Tool2_VBit.nc")
- ✅ Operator manually changes tools **between files**, not during execution
- ✅ Each file runs start-to-finish without M0 pauses
- ✅ Tool length measured with Z-probe **before starting each file**
- ✅ Multiple operations with same tool = run in **same file** (no tool change needed)

**Example Multi-Tool Project:**
```
Project_Roughing_6mmEM.nc          ; Tool 1 - all roughing operations
Project_Finishing_3mmEM.nc         ; Tool 2 - all finishing operations  
Project_Pockets_6mmEM.nc           ; Tool 1 again - separate pockets (runs separately)
Project_Engraving_VBit.nc          ; Tool 3 - engraving operations
```

**Do NOT generate code that:**
- ❌ Assumes automatic tool changing
- ❌ Uses M6 expecting automatic tool change
- ❌ Combines multiple tools in one file with M0 pauses (user separates these)
- ❌ Expects tool library/carousel functionality
- ❌ References tool pockets or tool numbers beyond manual tracking

**Typical Single-File Workflow:**
1. Load tool manually in spindle
2. Measure tool length with Z-probe (before loading file)
3. Load and run complete G-code file (one tool, all operations with that tool)
4. File completes (M30)
5. **If another tool needed**: Operator changes tool, measures length, loads next file

**Multi-Operation Same Tool:**
- If multiple operations use the same tool, user may run them as **separate files** or **combined**
- User preference: separate files for flexibility in operation order
- No M0 tool change pauses within files

---

## **1. Mechanical Drive System (Verified Pitch)**

### **X-Axis (Gantry) & Y-Axis (Base)**
- **Ball Screw**: **SFS1210** (12mm Diameter)
- **Pitch**: **10mm** (High Speed)
- **Pulse Setting**: **500.000** (Derived from 5000 microsteps)

### **Z-Axis (Vertical Lift)**
- **Ball Screw**: **SFU1204** (12mm Diameter)
- **Pitch**: **4mm** (High Torque)
- **Pulse Setting**: **1250.000** (Derived from 5000 microsteps)

---

## **2. Motors & Motion Electronics (Hybrid Wiring)**

### **Linear Axis Motors (X, Y, Y2, Z)**
- **Model**: **PFDE 57HSE 3.0N** (Verified from Label)
- **Specs**: 3.0 N.m Torque / 3.5A Phase / 1.8° Step
- **Driver Setting**: 5000 Microsteps
- **Wiring Map (Label)**:
  - **Power**: A+ (Red), A- (Green), B+ (Yellow), B- (Blue)
  - **Encoder**: EB+ (Yellow), EB- (Green), EA+ (Black), EA- (Blue), VCC (Red), GND (White)

### **Rotary Axis Motor (5th / B-Axis) - Direct Wired**
- **Type**: NEMA 23 Standard Stepper
- **Driver**: DM556 (located in Magic Cube cabinet)
- **Setting**: 3200 Microsteps (DDCS = 53.333)
- **Wiring Path**: **Direct Wire (4-Core Cable) → DDCS Expert Green Plugs (B-PUL/B-DIR)**
- **Installation**: Added with Expert upgrade (bypasses DB37 system)
- **Note**: Motor power goes to DM556 driver in cabinet, but **control signals** (pulse/direction) go **directly to Expert controller**, not through Magic Cube breakout board

---

## **3. Sensors, Inputs & IO - Hybrid Wiring Architecture**

**IMPORTANT: Two-Stage Upgrade Wiring (CONFIRMED CONFIGURATION)**

This machine was upgraded from **DDCS v4.1 to Expert (M350)** controller, resulting in a **hybrid wiring system**:

---

### **Complete Input Assignments (Verified)**

**Limit Switches (Via DB37 System):**
- **IN20**: X-axis home switch (via DB37 → Magic Cube)
- **IN21**: Z-axis home switch (via DB37 → Magic Cube)
- **IN23**: Y-axis home switch (via DB37 → Magic Cube) - Left side, Y1 motor

**Direct-Wired Sensors (Bypass DB37):**
- **IN01**: Rotary B-axis proximity sensor - NPN type, ✅ Working
- **IN02**: Tool setter - Tool length measurement, ✅ Working
- **IN03**: 3D touch probe - PNP type, ⚠️ Requires PNP→NPN converter
- **IN10**: Z-probe puck - Surface/WCS probe, ✅ Working

**Summary:**
| Input | Device | Type | Path | Status |
|-------|--------|------|------|--------|
| IN01 | Rotary homing | NPN proximity | Direct | ✅ Working |
| IN02 | Tool setter | Touch plate | Direct | ✅ Working |
| IN03 | 3D probe | PNP (needs converter) | Direct | ⚠️ Not working |
| IN10 | Z-probe puck | Touch plate | Direct | ✅ Working |
| IN20 | X-home | Mechanical switch | DB37 | ✅ Working |
| IN21 | Z-home | Mechanical switch | DB37 | ✅ Working |
| IN23 | Y-home | Mechanical switch | DB37 | ✅ Working |

---

### **Legacy DB37 System (from v4.1, kept during upgrade)**

**Complete sensor bus with power and signals:**

```
DDCS Expert Controller
├─ COM+ (screw terminal) ────┐
├─ COM- (screw terminal) ────┤
└─ Signal inputs ─────────────┤
                              ↓
        Second Breakout Board (screw-to-DB37 adapter)
                              ↓
                DB37 Cable (37-pin, carries everything)
                ├─ Pin ~25: COM+ (24V from controller)
                ├─ Pin ~26: COM- (GND from controller)  
                └─ Pins 1-24: Sensor signals
                              ↓
                    Magic Cube Breakout Board
                    (Receives COM+/COM-, distributes to sensors)
                              ↓
                ┌─────────────┴─────────────┐
                ↓                           ↓
        Limit Switches              Other v4.1 Sensors
        (share common COM)          (share common COM)
```

**Key points:**
- ✅ **Controller provides COM+/COM-** through screw terminals
- ✅ **Second breakout board** converts screw terminals → DB37 connector
- ✅ **DB37 cable** carries power (COM+/COM-) AND signals in one cable
- ✅ **Magic Cube** receives COM, distributes to all sensors locally
- ✅ **Confirmed by testing** - disconnecting controller COM breaks limit switches

**Sensors on this path:**
- X-axis limit switch
- Y-axis limit switch (master gantry)
- Y2-axis limit switch (slave gantry, mapped to A-axis)
- Z-axis limit switch
- Any other v4.1-era sensors

**Why kept during upgrade:**
- ✅ Working system, no need to rewire
- ✅ Clean single-cable solution
- ✅ DB37 standard provides power distribution through cable
- ✅ Magic Cube handles local sensor power distribution

---

### **Direct-Wired Additions (new with Expert upgrade)**

**Bypass DB37 system entirely, connect directly to controller:**

```
DDCS Expert Controller Inputs ────┐
                                   ↓
Wago Hub (24V from PSU) ───→ Sensor Power
                                   ↓
                    ┌──────────────┴──────────────┬──────────────┐
                    ↓              ↓              ↓              ↓
            Rotary Homing    Tool Setter    Z-Probe Puck   3D Touch Probe
            (IN01)           (IN02)         (IN10)         (IN03 - NOT WORKING)
                    
                    ↓
        Rotary B-Axis Motor (Green Plugs: B-PUL/B-DIR)
```

**Key points:**
- ✅ **Independent from DB37 system** - no Magic Cube involved
- ✅ **Power from Wago hub** (24V PSU at controller front panel)
- ✅ **Signals direct to controller** - shorter path, simpler wiring
- ✅ **Controller COM+/COM- available** but Wago hub used for power distribution

**Sensors on this path:**
- **Rotary B-axis homing sensor** (NPN proximity, IN01) - Working
- **Tool setter** (tool length measurement, IN02) - Working
- **Z-probe puck** (surface/WCS probe, IN10) - Working
- **3D touch probe** (3-axis digitizer, IN03) - ⚠️ **LED ON but NOT TRIGGERING**
- **Rotary B-axis motor** (pulse/direction signals to green plugs)

**Why added this way:**
- ✅ DB37 system already at capacity with v4.1 sensors
- ✅ Simpler to add new features directly vs. modifying DB37
- ✅ Wago hub provides local 24V distribution at front panel
- ✅ Future expansion easier (just add to Wago hub + controller inputs)

---

### **Wiring Architecture Summary**

**Confirmed Power Flow:**

```
PSU in Magic Cube Cabinet
├─ 24V → DDCS Expert COM+ screw terminal
│         ↓
│   Second Breakout Board
│         ↓
│   DB37 Cable (Pin ~25: COM+)
│         ↓
│   Magic Cube (distributes to DB37 sensors)
│
├─ 24V → Wago Hub at front panel
│         ↓
│   Direct-wired sensors (rotary, probes)
│
└─ GND → Both paths (common ground reference)
```

**Why this hybrid system exists:**
- ✅ Minimal rewiring during v4.1 → Expert upgrade
- ✅ DB37 system kept for existing limit switches (working perfectly)
- ✅ New features added directly (simpler than modifying DB37)
- ✅ Easy troubleshooting (legacy vs new systems separate)
- ✅ Future-proof (can add more direct sensors without DB37 constraints)

**Verified by testing:** Disconnecting controller COM+/COM- disables DB37 limit switches, confirming controller provides power through DB37 cable to Magic Cube distribution system.

---

### **Limit Switches (Linear Axes) - Via DB37 System**
- **Type**: Mechanical Micro-Switches (2-Wire Passive)
- **Axes and Inputs**:
  - **X-axis**: Input #20 (IN20)
  - **Y-axis**: Input #23 (IN23) - Left side, Y1 motor
  - **Z-axis**: Input #21 (IN21)
- **Power**: COM- (GND) from controller via DB37
- **Signals**: Through DB37 → Magic Cube → Controller inputs
- **Installation**: Original v4.1 system, kept during upgrade

---

### **Rotary Homing Sensor (B-Axis) - Direct Wired**
- **Type**: NPN Inductive Proximity Sensor (Blue Tip, LJ12A3 type)
- **Input**: **IN01** (Input #01)
- **Mounting**: Custom 3D Printed Bracket (Yellow) on rotary housing
- **Target**: Metal tab on chuck
  - **⚠️ CAUTION**: J-B Weld is detectable; keep clear of sensor face
- **Power**: Brown (+24V) and Blue (GND) to Wago Hub
- **Signal**: Black wire to Input #01
- **Installation**: Added with Expert upgrade

---

### **Tool Setter - Direct Wired**
- **Type**: Tool length measurement probe
- **Input**: **IN02** (Input #02)
- **Function**: Tool length measurement for manual tool changes
- **Wiring**: Direct to Input #02 and GND
- **Usage**: Measures tool length before running each toolpath
- **Installation**: Added with Expert upgrade

---

### **Z-Probe Puck (Surface/WCS Probe) - Direct Wired**
- **Type**: Generic Puck Style Touch Plate (Non-branded)
- **Input**: **IN10** (Input #10)
- **Function**: Workpiece surface detection, WCS Z-zero setting
- **Wiring**: Direct to Input #10 and GND
- **Usage**: Setting Z-zero on workpiece surface
- **Installation**: Added with Expert upgrade

---

### **3D Touch Probe (Digitizer) - Direct Wired - ⚠️ PNP TYPE (INCOMPATIBLE)**
- **Type**: 3-Axis Active Probe (Stylus)
- **Input**: **IN03** (Input #03)
- **Function**: Edge finding, Center finding, Surface mapping
- **Wiring**:
  - Red (VCC): +24V from Wago Hub
  - Black (GND): GND from Wago Hub
  - Yellow (IO): Signal to Input #03
- **Installation**: Added with Expert upgrade
- **Status**: ⚠️ **PNP OUTPUT TYPE - REQUIRES SIGNAL CONVERTER**

**PROBLEM IDENTIFIED:**
- Probe has **PNP output** (sourcing)
- DDCS Expert expects **NPN input** (sinking)
- Signal polarity is **inverted** - won't work without converter
- LED RED = powered correctly ✅
- Not triggering = signal type mismatch ❌

**SOLUTION:**
**Signal inverter required** - see `pnp-to-npn-converter.md` for complete guide

**Three options:**
1. **NPN Transistor** (Recommended)
   - Parts: 2N2222 transistor, 1kΩ + 10kΩ resistors
   - Cost: ~$0.50
   - Size: Tiny, fits in small box
   - Build time: 30 minutes

2. **Small Relay**
   - 24V DC SPDT relay
   - Cost: $3-5
   - Larger but very simple

3. **Opto-isolator**
   - PC817 or similar
   - Best electrical isolation
   - Cost: $1-2

**Once converter installed:**
- Probe will work correctly on IN03
- Signal properly inverted to NPN
- May need to adjust IN03 active level setting (0 or 1)

**Alternative solution:**
- Replace probe with NPN version (if available)
- Would work directly without converter

**Verified Specifications** (from factory test report 2025/12/22):
- **Power**: DC 5-24V (machine uses 24V)
- **Repeatability**: <0.01mm (X, Y, Z axes) when working properly
- **Test Performance**: 100/100 triggers (X&Y), 50/50 triggers (Z) at factory

**CRITICAL Operating Requirements (once working):**
1. **⚠️ Spindle MUST be OFF during probing** - running spindle interferes with probe accuracy
2. **Feed rate**: Keep probe moving at **50mm/min or less** for high accuracy
3. **Environment**: Keep away from wet conditions for longer service life
4. **ER Collet accuracy**: Use AAA grade or better (<0.005mm concentricity) for best chuck accuracy

**Troubleshooting Current Issue (Not Triggering):**

**LED Status:**
- ✅ RED LED on = Power connected correctly
- ❌ Not triggering when touched = Signal issue

**HOW TO CHANGE INPUT POLARITY (Active Level):**

The DDCS Expert uses variable pairs for each input configuration:
- **#104X** = Input port number (which physical input: 1, 2, 3, etc.)
- **#105X** = Active level (0 or 1, determines trigger polarity)

**For IN03 (your 3D probe):**
```gcode
; Check current settings:
; You need to find which #104X variable is set to 3

; Common pattern - look for:
#1043 = 3     ; Input port assignment (if this is set to 3, it's IN03)
#1053 = ?     ; Active level for this input (0 or 1)

; To change polarity, toggle the active level:
#1053 = 0     ; Try this if currently 1
; OR
#1053 = 1     ; Try this if currently 0
```

**Step-by-Step to Find and Change:**

**Method 1: Controller Menu (Easiest)**
1. Go to controller **Settings/Parameters** menu
2. Look for **Input Configuration** or **IO Configuration**
3. Find **IN03** in the list
4. Look for **Active Level** or **Trigger Level** setting
5. Toggle between **0 and 1** (or **NO/NC**, **High/Low**)
6. Save and test

**Method 2: Via Macro (If you know the variable)**
```gcode
; Example - adjust to your actual variable numbers:
; Find which #104X = 3 (IN03), then toggle its #105X

(Test current setting)
#2070 = 1053    ; Example: if #1053 is the active level
#1505 = 1(Current value: %.0f - Press ENTER)

(Toggle it)
IF #1053 EQ 0 GOTO set_one
#1053 = 0       ; Was 1, set to 0
GOTO done
N set_one
#1053 = 1       ; Was 0, set to 1
N done

#1505 = 1(Polarity changed - test probe now)
M30
```

**Method 3: Controller IO Screen Test**
1. Go to **IO Diagnostic** screen on controller
2. Watch **IN03** indicator
3. Touch probe - does indicator change on screen?
   - YES but macro doesn't work = Variable/parameter issue
   - NO = Physical wiring or active level wrong

**Possible Causes:**

1. **Input Configuration Wrong:**
   - Check input #03 active level in controller parameters
   - Try toggling between NO/NC (normally open/normally closed)
   - Probe might be outputting opposite signal polarity expected

2. **Signal Wire Issue:**
   - Yellow wire connected to IN03? Verify connection
   - Check for loose connection at controller input terminal
   - Test continuity from probe yellow wire to IN03 terminal

3. **Ground Reference:**
   - Black wire to same GND as power supply?
   - Probe needs common ground with controller
   - Try connecting black to controller COM- terminal

4. **Input Not Enabled:**
   - Check if IN03 is enabled in controller IO configuration
   - Some inputs may need to be activated in parameters

5. **Probe Output Type Mismatch:**
   - **CONFIRMED**: DDCS Expert accepts **NPN logic** (your rotary sensor IN01 is NPN and working)
   - Your 3D touch probe should also be NPN-compatible
   - **NPN behavior** (sinking):
     - Not triggered: Signal HIGH (pulled up)
     - Triggered: Signal pulled to GND (0V)
   - If probe is PNP (sourcing) instead, signal is inverted:
     - Not triggered: Signal at GND
     - Triggered: Signal at +V
   - Check 3D probe specifications - should be NPN type
   - If PNP, may need signal inversion circuit or won't work properly

6. **Voltage Issue:**
   - Probe getting full 24V? Measure with multimeter
   - Check Wago hub connections
   - Voltage drop in wiring?

**Testing Steps:**

1. **Verify power:**
   ```
   - LED RED = Good
   - Measure voltage: Red to Black should be ~24V
   ```

2. **Test signal output:**
   ```
   - Measure Yellow wire to Black (GND):
     - Not triggered: Should be 0V or 24V (depends on type)
     - Triggered: Should switch to opposite voltage
   - If no voltage change = probe defective
   ```

3. **Test controller input:**
   ```
   - Go to IO screen on controller
   - Watch IN03 status while touching probe
   - If changes on screen but not in macro = parameter issue
   - If no change = wiring or input config issue
   ```

4. **Try different input:**
   ```
   - Temporarily move to known-working input (like IN02)
   - If works = IN03 configuration problem
   - If still doesn't work = probe or wiring issue
   ```

**Recommended G31 Probe Settings (once working):**
```gcode
G31 Z-50 F50   ; Probe down max 50mm at 50mm/min feedrate
```

---

**Verified Specifications** (from factory test report 2025/12/22):
- **Power**: DC 5-24V (machine uses 24V)
- **Repeatability**: <0.01mm (X, Y, Z axes)
- **Test Performance**: 100/100 triggers (X&Y), 50/50 triggers (Z)
- **Status**: Factory tested and passed

**CRITICAL Operating Requirements:**
1. **⚠️ Spindle MUST be OFF during probing** - running spindle interferes with probe accuracy
2. **Feed rate**: Keep probe moving at **50mm/min or less** for high accuracy
3. **Environment**: Keep away from wet conditions for longer service life
4. **ER Collet accuracy**: Use AAA grade or better (<0.005mm concentricity) for best chuck accuracy

**Recommended G31 Probe Settings:**
```gcode
G31 Z-50 F50   ; Probe down max 50mm at 50mm/min feedrate
```

**Pre-probe checklist:**
- ✅ Spindle stopped (M5)
- ✅ Feedrate ≤50mm/min
- ✅ Probe tip clear of obstructions
- ✅ Work coordinate system established

---

## **Wiring Architecture Summary**

**Why this hybrid system?**
- Original v4.1 installation used Magic Cube + DB37 for all signals
- Upgrading to Expert kept existing Magic Cube infrastructure (working, no need to replace)
- New sensors/features added directly to Expert controller for simplicity
- Result: Clean separation between legacy (DB37) and new (direct) wiring

**Advantages:**
- ✅ Minimal rewiring during upgrade (kept working v4.1 infrastructure)
- ✅ Easy troubleshooting (legacy vs new systems separate)
- ✅ Future-proof (can add more direct-wired sensors without DB37 limitations)
- ✅ Wago hub at controller provides local power distribution for new sensors

---

## **4. Physical Control Architecture (Verified Split System)**

### **A. User Interface (Front of Table)**
- **Housing**: Custom Plywood Console
- **Device**: **DDCS Expert (M350)** Controller Panel
- **Internal Mods**: **5-Port Wago Hub** installed here for 24V distribution to local probes/sensors

### **B. Control Cabinet (Under Table)**
- **Housing**: Metal "Magic Cube" Industrial Enclosure
- **Contents**:
  - **Stepper Drivers**: 4x HBS57 (Closed Loop) + 1x DM556 (Rotary)
  - **Power**: 24V Logic PSU + 36V/48V Motion PSU
  - **VFD**: 110V Inverter (Huanyang/Nowfore)
  - **Relays**: Coolant/Mist switching
  - **Breakout Board**: Adapts the DB37 harness

---

## **5. Spindle Specifications (Verified)**

- **Model**: **2.2kW Water Cooled**
- **Diameter**: 80mm
- **Collet System**: **ER20** (Supports tool shanks up to 13mm / 1/2")
- **Speed Range**: 0 - 24,000 RPM
- **Connector**: GX16-4 Pin (1=U, 2=V, 3=W, 4=GND)
- **Power Source**: 3-Phase AC (220V/110V equiv) supplied by VFD

---

## **6. Construction Hardware**

- **Frame**: C-Beam 40x80mm & V-Slot 20x40mm
- **Plates**: 10mm+ Anodized 6061-T5 Aluminum
- **Couplers**:
  - Zero-Backlash Double Diaphragm (X/Y)
  - Standard Jaw (Z)
- **Drag Chains**: Bridge Type (Openable)

---

## **7. Accessories & External Equipment**

### **Dust Collection (Two-Stage System)**
- **Stage 1 (Separator)**: **Dust Deputy Cyclone** mounted on a **5-Gallon Bucket**
- **Stage 2 (Vacuum)**: **Fein Turbo I** (Wet/Dry Dust Extractor)
- **Control**: **Manual Operation** (Independent wall plug)

### **Spindle Cooling (Water Pump)**
- **Type**: Submersible AC Pump (110V)
- **Control Logic**: **M8 Command** (Flood Coolant Output)
- **Hardware**: Connected to Controller Output #08

---

## **8. Rotary Axis Mechanical Specifications**

- **Model**: **K-80 (80mm Kit)**
- **Chuck**:
  - **Type**: **80mm 4-Jaw Chuck** (Self Centering)
  - **Diameter**: 80mm
- **Dimensions**:
  - **Center Height**: **65mm**
  - **Overall Size**: 205mm (L) x 168mm (W) x 117mm (H)
- **Transmission**:
  - **Ratio**: **6:1** (Synchronous Belt)
  - **Motor**: NEMA 23 (57mm) 2-Phase Stepper
- **Tailstock**:
  - **Center Height**: **65mm**
  - **Stroke**: **35mm**

---

## **9. Configuration & Calibration Data (Soft Limits)**

### **X-Axis**
- **Travel Range**: 0mm to **+756mm**
- **Soft Limit Min**: -2.000
- **Soft Limit Max**: 754.000

### **Y-Axis (NEGATIVE SPACE - CRITICAL!)**
- **Travel Range**: 0mm to **-735mm**
- **Soft Limit Max**: 2.000 (Home)
- **Soft Limit Min**: -733.000 (Front)
- **⚠️ WARNING**: Y-axis travels in NEGATIVE space - uncommon configuration!

### **Z-Axis**
- **Travel Range**: Verified
- **Soft Limit Max**: 1.000 (Home)

---

## **10. Coordinate System Behavior**

### **Machine Zero (G53 Coordinates)**
- **X0**: Home switch position (back right)
- **Y0**: Home switch position (back of table)
- **Z0**: Home switch position (top of travel)

### **G28 Back-Off Positions (NOT Machine Zero!)**
- **X**: 5.0mm from home switch (Pr122 = 5.0)
- **Y**: -5.0mm from home switch (Pr123 = -5.0)
- **Z**: -5.0mm from home switch (Pr124 = -5.0)

**IMPORTANT**: G28 moves to back-off positions, NOT to true machine zero (G53 X0 Y0 Z0)!

---

## **11. Dual Gantry Y-Axis Synchronization**

### **Physical Configuration**

**Motor Placement:**
- **X-axis motor**: Mounted on **LEFT side** of gantry
- **Y1 motor** (controller Y output): Drives **LEFT side** of gantry
- **Y2 motor** (controller A output): Drives **RIGHT side** of gantry (slave)

**Limit Switch Configuration:**
- **Y1 switch** (Input #1048): **LEFT side** - Primary home switch
- **Y2 switch** (Input #1054): **RIGHT side** - May or may not be installed
  - **Note**: Not required for basic operation
  - Machine uses **single-switch homing** with manual calibration

### **Gantry Squaring Strategy: Manual Calibration**

**Approach**: Use single Y1 home switch + iterative test cuts

**How it works:**
1. Both motors home to Y1 switch (left side)
2. Zero at Y1 position
3. Break slave (#991 = 3) - motors independent
4. Move **ONLY Y1 motor** by calibration offset (#121)
5. Re-enable slave (#991 = 1) - gantry now squared!

**Calibration offset (#121):**
- Set by user based on test cut diagonal measurements
- Positive = Y1 moves back (toward home)
- Negative = Y1 moves forward (away from home)
- Typical range: ±1mm to ±6mm
- See `gantry-squaring-calibration.md` for complete guide

### **Calibration Process Summary**

**Step 1: Initial Test**
```gcode
#121 = 0.0    ; Start with no correction
```
Cut test square, measure diagonals

**Step 2: Calculate Correction**
```
Diagonal_error = |Diagonal1 - Diagonal2|
Error_ratio = Diagonal_error / Rectangle_length
Correction = Error_ratio × Gantry_width
```

**Step 3: Apply and Verify**
```gcode
#121 = 4.5    ; Example: 4.5mm correction
```
Re-home, cut new test square, adjust if needed

**Result**: Diagonals equal within 0.5mm

### **Key Parameters**

- **#991**: A-axis slave configuration
  - `#991 = 1`: A follows Y (slaved) - normal operation
  - `#991 = 3`: A independent - during squaring correction

- **#121**: Manual gantry squaring offset (persistent)
  - Stores calibration value between power cycles
  - Adjust based on test cut diagonal measurements
  - Fine-tune in 0.5mm increments

### **Critical Operating Notes**

- **Master**: Y-axis motor (left side, Y1)
- **Slave**: A-axis motor (right side, Y2) - electronically slaved via #991
- **Homing**: Both axes move together (slaved) to Y1 switch
- **After Power Cycle**: Re-home applies saved #121 calibration automatically
- **Squaring Correction**: Only Y1 (left) moves during correction, Y2 (right) stays at zero

### **Physical Layout Diagram**

```
                    FRONT OF MACHINE
                    (toward operator)
                           ↓

    (Y2 motor)             |             Y1 switch
    RIGHT side            |||            (Input #1048)
    No switch         ==GANTRY==         LEFT side
    (slave motor)         |||            HOME position
                          |||
                    [X motor on left]
                          |||
                           ↑
                    BACK OF MACHINE
                    (Y-home position)

Homing sequence:
1. Both motors move together (slaved, #991=1)
2. Y1 switch (left) triggers → both stop
3. Zero at Y1 position
4. Break slave (#991=3)
5. Move Y1 only by #121 offset
6. Re-enable slave (#991=1) → gantry squared!

Y-axis travel: 0mm (back) to -735mm (front)
```

### **Advantages of Single-Switch Calibration**

✅ **Simple**: One switch, iterative calibration  
✅ **Reliable**: Manual calibration persists between power cycles  
✅ **Accurate**: Test cuts verify actual table squareness  
✅ **Adjustable**: Easy to fine-tune for different conditions  
✅ **No complex math**: Direct measurement-based correction  

### **When to Re-Calibrate**

- After mechanical work on gantry
- If test cuts show diagonal drift
- After belt/coupling adjustments
- Seasonally (temperature affects frame)
- When switching between materials (optional fine-tuning)

---

## **12. Tool Change Strategy (Separate Toolpaths)**

**WORKFLOW: Separate G-code files per tool/operation**

### **File Organization Strategy**

**User preference: ONE TOOL PER FILE**
```
Project_Roughing_6mmEndmill.nc      ; All roughing with 6mm EM
Project_Adaptive_6mmEndmill.nc      ; Adaptive clearing with 6mm EM  
Project_Finishing_3mmEndmill.nc     ; All finishing with 3mm EM
Project_Chamfer_Chamfermill.nc      ; Chamfering operations
Project_Engraving_60degVbit.nc      ; V-carve engraving
```

**Key points:**
- Each file is complete and independent
- No M0 pauses for tool changes within files
- Operator changes tools **between files**, not during execution
- Same tool used in multiple files = operator re-runs that tool when needed

### **Single-File Execution Flow**

**Before loading file:**
1. Install correct tool in spindle manually
2. Run tool length measurement macro (Z-probe)
3. Verify tool offset updated

**During file execution:**
1. File runs start to finish (no M0 tool changes)
2. All operations with that tool complete
3. File ends with M30

**After file completes:**
1. If same tool needed again = load another file, run
2. If different tool needed = change tool, measure length, load next file

### **Example: Multi-Tool Project**

**Project: Decorative Box (3 tools)**

**File 1:** `Box_Pockets_6mm.nc`
```gcode
; Tool: 6mm End Mill
; Operations: All pocket milling
; ...operations...
M30
```

**File 2:** `Box_Contour_6mm.nc`  
```gcode
; Tool: 6mm End Mill (same tool, separate file for flexibility)
; Operations: Outside contour
; ...operations...
M30
```

**File 3:** `Box_Details_3mm.nc`
```gcode
; Tool: 3mm End Mill (TOOL CHANGE between file 2 and 3)
; Operations: Fine detail work
; ...operations...
M30
```

**File 4:** `Box_Engraving_Vbit.nc`
```gcode
; Tool: 60° V-bit (TOOL CHANGE between file 3 and 4)
; Operations: Text engraving
; ...operations...
M30
```

**Operator workflow:**
1. Load 6mm EM → measure → run `Box_Pockets_6mm.nc` → complete
2. Same tool → run `Box_Contour_6mm.nc` → complete
3. **Change to 3mm EM** → measure → run `Box_Details_3mm.nc` → complete
4. **Change to V-bit** → measure → run `Box_Engraving_Vbit.nc` → complete

### **Why This Approach?**

**Advantages:**
- ✅ Maximum flexibility in operation order
- ✅ Can skip operations if needed
- ✅ Re-run individual operations easily
- ✅ No complex M0 tool change logic in code
- ✅ Each file is simple and focused
- ✅ Easy to troubleshoot individual operations

**When same tool appears in multiple files:**
- User decision: run back-to-back or run separately
- No requirement to combine same-tool operations
- Separate files allow independent execution

### **Stored Positions** (Persistent Variables)

These are used for parking/setup, NOT for M0 tool changes mid-file:
- **#1153, #1154**: Safe park position (X, Y)
- **#1155, #1156**: Accessible position for manual tool changes (between files)
- **#1157**: Tool change safe Z height (if used)

### **Tool Length Measurement**

**Z-Probe puck used BEFORE each file (not during):**
- Operator runs tool measurement macro
- Tool offset updated in controller
- Then loads and runs G-code file

**See user-tested-patterns.md for tool measurement macros**

---

## **13. Probe Configuration Summary**

| Probe Type | Input | Function | Usage | Status |
|------------|-------|----------|-------|--------|
| Tool Setter | IN02 | Tool length measurement | Before each toolpath | ✅ Working |
| Z-Probe Puck | IN10 | Surface/WCS Z-zero | Workpiece setup | ✅ Working |
| 3D Touch Probe | IN03 | Edge/center finding, digitizing | Complex geometry | ⚠️ NOT TRIGGERING |

**3D Touch Probe Status:**
- LED: RED (powered correctly)
- Issue: Not triggering when touched
- See Section 3 for troubleshooting steps

**Probe Usage Strategy:**
- **Tool Setter (IN02)**: Measure tool length before each toolpath file
- **Z-Probe Puck (IN10)**: Set workpiece Z-zero, establish WCS offsets
- **3D Touch Probe (IN03)**: Once working - edge finding, center finding, surface mapping

**Probe Mode Configuration (Pr1502):**
- **Mode 0**: Floating probe (Z-Probe Puck on IN10) - Changes WCS Z only
- **Mode 2**: Fixed probe tool change (Tool Setter on IN02) - Changes tool offset only
- **Mode 1**: Fixed probe first use (Tool Setter on IN02) - Changes both WCS Z and tool offset

**Parameter Assignments:**
- **Pr1075** (#1075): Fixed probe input = **2** (Tool Setter)
- **Pr1078** (#1078): Floating probe input = **10** (Z-Probe Puck)
- See `g31-probe-variables.md` for complete probe configuration details

**Firmware Reference:**
- Built-in probe routines: `firmware-backup-2025-12-31/.../slib-g.nc` line 306 (O502)
- Homing routines: `firmware-backup-2025-12-31/.../slib-g.nc` line 157 (O501)

---

## **14. Key Machine Characteristics**

### **Unique Features**
- Large working area (1000mm x 1000mm)
- Dual-gantry design for rigidity
- **Y-axis negative space orientation** (uncommon!)
- Dual probe system (tool setter + 3D probe)
- Closed-loop steppers on linear axes
- Split control architecture (panel + cabinet)

### **Critical Behaviors to Remember**
1. **Y-axis NEGATIVE SPACE** - moves from 0 to -735mm
2. **G28 ≠ Machine Zero** - uses back-off positions (Pr122-124)
3. **Dual gantry** - requires Y/A synchronization after power cycle
4. **SEPARATE TOOLPATHS** - one tool per file, no M0 tool changes within files
5. **Z-probe measurement** - done BEFORE loading each file, not during execution

---

## **15. Related Documentation**

- **Controller Quirks**: See CORE_TRUTH.md for M350-specific issues
- **Manual Tool Change Macros**: See user-tested-patterns.md for complete code
- **Probe Operations**: See g31-probe-variables.md for probe configuration
- **Fusion 360 Integration**: See fusion-post-processor.md for post-processor setup
- **MacroB Syntax**: See macrob-programming-rules.md for M350 programming rules

---

**Document Source**: Complete hardware manifest provided January 06, 2026  
**Machine Owner**: Frédéric  
**Location**: Montreal, Quebec, CA  
**Last Updated**: January 2026

---

## **16. DDCS Expert Input Logic - NPN Confirmed**

### **Controller Input Type**

**CONFIRMED**: DDCS Expert controller uses **NPN-compatible inputs** (active-low, sinking)

**Evidence:**
- Rotary proximity sensor (IN01) is **NPN type** and **WORKING**
- Standard industrial CNC controllers typically use NPN logic
- Compatible with "sinking" type sensors

### **NPN Sensor Behavior (What Works)**

**Physical wiring:**
```
Sensor:
├─ Brown: +24V (power)
├─ Blue: GND (ground)
└─ Black: Signal output (to controller input)
```

**Signal behavior:**
```
Not triggered:
- Black wire: HIGH (pulled up by controller internal resistor)
- Voltage: ~24V or ~5V (depends on pull-up)
- Controller sees: OPEN/OFF

Triggered:
- Black wire: Pulled to GND inside sensor
- Voltage: ~0V
- Controller sees: CLOSED/ON
```

**This is "active-low" or "sinking" logic - sensor pulls signal LOW when triggered.**

### **PNP Sensors (May NOT Work)**

**PNP is opposite:**
```
Not triggered:
- Signal at GND (0V)
- Controller sees: CLOSED/ON (WRONG!)

Triggered:  
- Signal pulled to +V (24V)
- Controller sees: OPEN/OFF (WRONG!)
```

**PNP sensors require signal inversion or different controller input configuration.**

### **Sensor Selection Guidelines**

**For DDCS Expert compatibility:**
- ✅ Use **NPN sensors** (also called "sinking" or "active-low")
- ✅ 3-wire NPN proximity sensors work perfectly
- ✅ Touch probes should be NPN output type
- ❌ Avoid PNP sensors unless you add signal inversion circuit

**Common sensor types that work:**
- NPN inductive proximity (like your rotary sensor)
- NPN touch probes
- Mechanical switches (passive - always compatible)
- Opto-isolated inputs (check compatibility)

### **Your Working Sensors (Confirmed NPN Compatible)**

| Sensor | Input | Type | Status |
|--------|-------|------|--------|
| Rotary proximity | IN01 | NPN inductive | ✅ Working |
| Tool setter | IN02 | Touch plate (passive) | ✅ Working |
| Z-probe puck | IN10 | Touch plate (passive) | ✅ Working |
| 3D touch probe | IN03 | Should be NPN | ⚠️ Check if NPN type |

**If 3D probe is PNP type:** That would explain why it's not triggering correctly - signal polarity is inverted from what controller expects.

---
