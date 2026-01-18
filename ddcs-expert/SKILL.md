---
name: ddcs-expert
description: Expert guidance for DDCS M350 CNC controller macro programming and G-code development (V1.22 VERIFIED). Use when troubleshooting G-code issues, building macros for DDCS controllers, debugging variable addressing, understanding parameter mappings, working around controller quirks (G53 verified syntax, G10 broken, G28 not configured, variable persistence), developing CNC automation for Ultimate Bee or similar machines using DDCS Expert controllers, or working with manual tool change workflows. Covers variable numbering systems, coordinate system offsets, dual-gantry synchronization, M350-specific workarounds, verified code patterns, and tested macros from real production machines.
---

# DDCS M350/Expert Controller - Macro Programming Skill

## Critical First Step

**ALWAYS read `references/CORE_TRUTH.md` first** - V1.22 VERIFIED document containing essential controller quirks and workarounds. Standard FANUC G-code WILL FAIL on M350 without these workarounds.

**Key verified findings:**
- G53 MUST use variables (no hardcoded constants, no G0/G1 on same line)
- G10 is BROKEN (use direct parameter writing)
- G28 goes to home back-off positions (Pr122-124), NOT machine zero
- Variable priming prevents freeze bug
- Your machine: Y and Z axes travel in NEGATIVE space
- G28 = back-off from switches (X=5.0, Y=-5.0, Z=-5.0)
- G53 X0 Y0 Z0 = true machine zero (different from G28!)

## When to Use This Skill

Use this skill when:
- Writing new MacroB G-code for DDCS M350/Expert controllers
- Debugging existing macros that aren't working as expected
- Converting FANUC macros to DDCS-compatible code
- Understanding variable addressing and parameter mappings
- Creating probe routines, WCS management, or position saving macros
- Developing Fusion 360 post-processors for DDCS controllers
- Troubleshooting controller freezes, unexpected behavior, or broken commands

## The Three Numbering Systems (Critical Understanding)

The DDCS M350 uses **three different numbering schemes** - confusing them will break your code:

1. **ENG File Format**: `#0`, `#129`, `#880` (Parameter numbers from controller)
2. **UI Display**: `Pr0`, `Pr129` (what you see on screen)
3. **Macro Address**: `#500`, `#629`, `#880` (what you write in G-code)

**To find the correct macro address:**
1. Check `references/Variables-ENG_01-04-2025.xlsx` - Column "Macro Var" shows what to use in code
2. Cross-reference with `references/eng` file for parameter behavior
3. Common pattern: UI Parameter Pr[N] often maps to macro variable #[N+500]

Example: UI shows "Pr129" (probe thickness) → Use `#629` in macro code

## Reference File Guide

### Primary References (Read These First)
- `CORE_TRUTH.md` - Controller quirks, broken commands, safe workarounds
- `hardware-config.md` - **Your specific machine setup: Ultimate Bee 1010, dual probes, manual tool changing**
- `variable-priming-card.md` - Critical bug: how to avoid controller freezes
- `ddcs-display-methods.md` - User feedback, dialogs, messages
- `community-patterns.md` - **Proven working code patterns from experienced users**
- `user-tested-patterns.md` - **Tested macros from real production machine (manual tool change workflow)**
- `fusion-post-processor.md` - **Fusion 360 post-processor integration with victory dance & dynamic parking**
- `virtual-buttons-2037.md` - **Virtual button automation - simulate controller button presses**
- `example-macros/` - **Directory of actual working .nc files you can copy and modify**
- `firmware backup 31-12-2025/` - **Complete firmware backup from your actual controller (12-31-2025)**
  - Contains all your current macros (M files, key files, probe routines)
  - `slib-g.nc`: System library with O501 (homing) and O502 (probe) subroutines
  - `slib-m.nc`: M-code system library
  - Use to examine actual controller behavior and macro implementations

### Lookup References (Use As Needed)
- `Variables-ENG_01-04-2025.xlsx` - Complete variable mapping (eng# → Pr# → macro address)
- `G-M-code_full_list.xlsx` - Supported G/M codes reference
- `eng` - Raw parameter file from controller (behavior, limits, flags)
- `M350_instruction_description-G31.pdf` - Official probe command specification
- `Virtual_button_function__2037_.pdf` - Official virtual button control specification

## Critical Variables Reference

### Machine Coordinates (Read-Only, Execution Mode)
```gcode
#880  ; Current X machine position
#881  ; Current Y machine position  
#882  ; Current Z machine position
#883  ; Current A machine position (dual gantry)
#884  ; Current B machine position
```

### Work Coordinate System Offsets (Non-Standard!)

**DDCS uses stride of 5, not standard FANUC addresses:**

| WCS | Index (#578) | X | Y | Z | A | B |
|-----|--------------|---|---|---|---|---|
| G54 | 1 | #805 | #806 | #807 | #808 | #809 |
| G55 | 2 | #810 | #811 | #812 | #813 | #814 |
| G56 | 3 | #815 | #816 | #817 | #818 | #819 |
| G57 | 4 | #820 | #821 | #822 | #823 | #824 |
| G58 | 5 | #825 | #826 | #827 | #828 | #829 |
| G59 | 6 | #830 | #831 | #832 | #833 | #834 |

**Active WCS Index**: `#578` (1=G54, 2=G55, etc.)

### Common Parameters (UI Pr# → Macro Variable)
```gcode
#500   ; Pr0   - Start Speed (mm/min)
#561   ; Pr61  - Default Feed 
#570   ; Pr70  - Z Lift Distance
#582   ; Pr82  - Max Spindle RPM
#591   ; Pr91  - Z Lift Enable (0=No, 1=Yes)
#622   ; Pr122 - X Back Home position
#629   ; Pr129 - Probe Thickness (mm)
#630   ; Pr130 - Fixed Sensor Enable
#632   ; Pr132 - Probe Speed
#635   ; Pr135 - Fixed Probe X position
#636   ; Pr136 - Fixed Probe Y position
```

### Probe Results (After G31)
```gcode
#1922  ; Probe hit flag (0=miss, 1=hit)
#1925  ; Probe trigger X (machine coord)
#1926  ; Probe trigger Y (machine coord)
#1927  ; Probe trigger Z (machine coord)
#1928  ; Probe trigger A (machine coord)
```

### User Persistent Storage (Gap Addresses)
**Safe for custom data that survives reboot:**
```gcode
#1153-#1154  ; Safe park position (X, Y)
#1155-#1156  ; Tool change position (X, Y)
#1157-#1169  ; Available for custom use
#1170-#1175  ; Reserved for probe config
#1176-#1193  ; Available for custom use
```

### Display Variables
```gcode
#1503  ; Status bar display (message offset +3000)
#1505  ; Dialog message control
#1510  ; Display variable 1 (for format codes)
#1511  ; Display variable 2
#1512  ; Display variable 3
#1513  ; Display variable 4
#2037  ; Virtual button control (simulate button presses)
#2070  ; User input dialog (2024+ firmware)
```

**Status bar display (#1503):**
```gcode
#1510 = 80
#1511 = 70
#1503 = 1(X=%.0f%%   Y=%.0f%%)  ; Shows in status bar
                                 ; Use %% for literal % sign
                                 ; Message number = 3001 (1+3000)
```

## Virtual Button Control (#2037)

**Official M350 feature** - Programmatically simulate button presses for automation.

**Format**: `#2037 = 65536 + (KeyValue - 1000)`

**Common buttons:**
```gcode
#2037 = 65863  ; Reset button (KeyValue 1327)
#2037 = 65864  ; Start button (KeyValue 1328)
#2037 = 65865  ; Pause button (KeyValue 1329)
#2037 = 65900  ; Feed rate 100% (KeyValue 1364)
#2037 = 65908  ; M3 Spindle CW (KeyValue 1372)
```

**Use cases:**
- Automatic screen navigation
- Reset controller state
- Set feedrate/spindle overrides
- Program start/pause control
- Semi-automated workflows

**Example - Auto-reset after operation:**
```gcode
#1505 = -5000(Operation complete!)
G04 P2.0       ; Wait for operator to read
#2037 = 65863  ; Press Reset button
```

**CRITICAL**: Always add G04 delay (minimum 0.5 sec) after #2037 assignment.

See `references/virtual-buttons-2037.md` for complete button table and `Virtual_button_function__2037_.pdf` for official specification.

## Variable Persistence Rules

| Range | Persistent? | Read Mode | Write Mode | Use For |
|-------|-------------|-----------|------------|---------|
| #0-#49 | ❌ No | prefetch | prefetch | Subroutine locals |
| #50-#499 | ❌ No | prefetch | prefetch | Temporary calcs |
| #500-#1499 | ✅ Yes | prefetch* | execution | User params (Pr0-Pr999) |
| #1500-#2499 | ❌ No | execution | execution** | System reserved - avoid |
| #2500-#2999 | ✅ Yes | prefetch | execution | User params (Pr1000-Pr1499) |

\* #850-#889 reads are execution mode  
\** #1552-#1575 writes are prefetch mode

**Key takeaway**: Only #500-#1499 and #2500-#2999 survive reboot. Use #1153-#1193 gap for custom persistent data.

## G31 Probe Command - Extended Syntax

The DDCS M350 supports extended G31 parameters beyond standard FANUC (official M350 documentation):

```gcode
G31 X Y Z A B C P L K Q F
```

**Parameters (Official M350 Specification):**
- `X, Y, Z, A, B, C`: Axis movement target position (scan distance/direction)
- `F`: Moving speed (feedrate)
- `P`: Input port number (sensor port)
- `L`: Effective level (0=Normally Open, 1=Normally Closed)
- `K`: Scanning method (scanning behavior mode)
- `Q`: Stop mode after signal is valid (0=slow down, 1=stop immediately)

**Probe Result Variables** (official macro addresses after G31 execution):
- `#1920`: X-axis hit flag (0=miss, 1=hit) - *community documented*
- `#1921`: Y-axis hit flag (0=miss, 1=hit) - *community documented*
- `#1922`: Z-axis hit flag (0=miss, 1=hit) - *community documented*
- `#1925`: X MACH Pos (machine coordinate when scan signal valid)
- `#1926`: Y MACH Pos (machine coordinate when scan signal valid)
- `#1927`: Z MACH Pos (machine coordinate when scan signal valid)
- `#1928`: 4th axis (A) MACH Pos (machine coordinate when scan signal valid)
- `#1929`: 5th axis (B) MACH Pos (machine coordinate when scan signal valid)

**CRITICAL**: Parameter #76 must be set to "OPEN" for G31 to work.

**Example - Two-pass probe (fast then slow for precision):**
```gcode
#30 = #1078        ; Probe input port from parameter
#31 = #1080        ; Probe active level

; Fast probe
G91 G31 Z-50 F200 P#30 L#31 Q1
IF #1922 == 0 GOTO 999         ; Miss - abort

; Retract and slow probe
#20 = #1927                    ; Store fast result (MACH Pos)
G53 Z[#20 + 1]                 ; Retract 1mm
G91 G31 Z-2 F20 P#30 L#31 Q1   ; Slow precise probe
IF #1922 == 0 GOTO 999
#20 = #1927                    ; Precise trigger position (MACH Pos)

; Success path
GOTO 1000

N999
#1505 = -5000(Probe failed!)
N1000
M30
```

**Official documentation**: See `references/M350_instruction_description-G31.pdf` for complete specification.

## Built-in Probe Routines (O502 Subroutine)

The controller has **built-in probe modes** accessed via interface buttons or `M98P502`:

| Mode (Pr1502) | Changes WCS Z? | Changes Tool Offset? | Use Case |
|---------------|----------------|---------------------|----------|
| 0 - Floating Probe | ✅ YES | ❌ NO | Find workpiece surface |
| 1 - Fixed (First) | ✅ YES | ✅ YES | Establish work surface vs probe |
| 2 - Fixed (Tool Change) | ❌ NO | ✅ YES | Measure tool lengths only |

**Tool Offset Storage**: `#[1430 + (Tool_Number - 1)]` (T1=#1430, T2=#1431, etc.)

**Key Difference:**
- **Floating probe** → Moves your work zero to workpiece
- **Fixed probe (Mode 2)** → Keeps work zero, updates tool length only

**Homing vs Probing:**
- **fndZ.nc, fndzero.nc** → Homing routines (find limit switches), call O501
- **probe.nc** → Probe routine (measure tools/workpieces), calls O502

See `references/g31-probe-variables.md` for detailed probe mode behavior.

See `references/community-patterns.md` for complete hole-center and surface-finding routines.

## Broken Commands - DO NOT USE

### ❌ G10 - Coordinate System Offset Setting
**Problem**: Causes unwanted motion instead of just setting offsets  
**Solution**: Direct parameter writing

```gcode
; ❌ WRONG - causes motion!
G10 L2 P2 X0 Y0

; ✅ CORRECT - direct write
#810 = #880  ; Set G55 X = current machine X
#811 = #881  ; Set G55 Y = current machine Y
```

### ❌ G53 with Hardcoded Constants
**Problem**: May use active WCS instead of machine coordinates  
**Solution**: Use incremental moves or G53 with variables

```gcode
; ❌ WRONG - unreliable!
G53 G0 X500 Y500

; ✅ CORRECT - incremental delta
#100 = 500 - #880  ; Delta X
#101 = 500 - #881  ; Delta Y
G91
G0 X[#100] Y[#101]
G90

; ✅ ALSO WORKS - G53 with variables
#100 = 500
#101 = 500
G53 G0 X[#100] Y[#101]  ; Test on your firmware first!
```

### ❌ G28 - Return to Reference Point
**Problem**: Not configured by default, moves to undefined positions  
**Solution**: Use saved positions or incremental moves

## The Variable Priming Bug

**CRITICAL**: Controller freezes when assigning system variables to uninitialized user variables.

```gcode
; ❌ WRONG - freezes controller!
#100 = #880

; ✅ CORRECT - prime first
#100 = 0     ; Prime with constant
#100 = #880  ; Now safe to assign system variable
```

**Always add priming block at start of macros:**
```gcode
(--- PRIMING BLOCK ---)
#100 = 0   ; temp_x
#101 = 0   ; temp_y
#102 = 0   ; temp_z
#103 = 0   ; calculation
#1153 = 0  ; persistent storage
(--- END PRIMING ---)
```

**Community observation**: Many proven macros DON'T prime local variables (#0-#499) when directly assigning from system variables. The freeze appears most critical when writing to persistent storage (#1153+). Be conservative: prime when in doubt, but don't be surprised if you see working code without priming for local variables.

See `references/variable-priming-card.md` for details.

## Standard Macro Template

```gcode
%
(Title: <Macro Name>)
(Description: <Function>)

(--- PRIMING BLOCK ---)
#100 = 0
#101 = 0
#102 = 0
#103 = 0
(Add more as needed)

(--- STATE SAVE ---)
#100 = #4003  ; Save G90/G91 mode

(--- MAIN LOGIC ---)
M5            ; Stop spindle
G90           ; Absolute mode

; [INSERT YOUR LOGIC HERE]

(--- STATE RESTORE ---)
G#100         ; Restore G90/G91
M30           ; Program end
%
```

## Common Macro Patterns

### Set Current WCS Zero (Universal)
Works for whichever WCS is active (G54-G59):

```gcode
(Zero X and Y on currently active WCS)
#100 = 0
#100 = #578        ; Get active WCS index (1-6)
#100 = #100 - 1    ; Normalize to 0-5
#100 = #100 * 5    ; Calculate stride

; Set X offset
#[805 + #100] = #880  ; Indirect addressing

; Set Y offset
#[806 + #100] = #881

#1505 = -5000(Current WCS X/Y Zeroed!)
```

### Dual-Gantry Y/A Sync (For G55)
When setting G55 zero, sync A-axis for proper display:

```gcode
#810 = #880  ; G55 X offset
#811 = #881  ; G55 Y offset
#812 = #882  ; G55 Z offset
#813 = #881  ; G55 A = Y (cosmetic sync for dual gantry)
```

### Save Current Position to Persistent Storage

```gcode
(Save current position as safe park location)
#1153 = 0      ; Prime
#1154 = 0      ; Prime
#1153 = #880   ; Save machine X
#1154 = #881   ; Save machine Y
#1505 = -5000(Park position saved!)
```

### Return to Saved Position

```gcode
(Return to saved park position)
#100 = 0
#101 = 0
#100 = #1153 - #880  ; Calculate X delta
#101 = #1154 - #881  ; Calculate Y delta
G91
G0 X[#100] Y[#101]
G90
```

### Floating Probe Z-Zero (Auto-compensate for puck thickness)

```gcode
(Auto Z-Zero using probe puck)
(Uses Pr129 = #629 for puck thickness)

(1. Prime variables)
#100 = 0  ; Fast speed
#101 = 0  ; Slow speed
#102 = 0  ; Max depth
#103 = 0  ; Puck thickness
#104 = 0  ; WCS index
#105 = 0  ; WCS Z offset address
#106 = 0  ; Calculated offset

(2. Setup)
#100 = 200       ; Fast probe feedrate
#101 = 20        ; Slow probe feedrate
#102 = 20        ; Max probe distance
#103 = #629      ; Load puck thickness from parameter

(3. Fast probe)
G91
G31 Z-[#102] F[#100]
IF #1922 == 0 GOTO 999  ; Error if no hit

(4. Retract and slow probe)
G0 Z2
G31 Z-5 F[#101]
IF #1922 == 0 GOTO 999

(5. Calculate and set WCS Z offset)
#104 = #578                    ; Get active WCS (1-6)
#105 = 807 + [#104-1]*5        ; Calculate Z offset address
#106 = #1927 - #103            ; Z position - thickness
#[#105] = #106                 ; Write to WCS Z offset

G0 Z10                         ; Retract safely
#1505 = -5000(Z Zero Set!)
GOTO 1000

N999 #1505 = -5000(Probe Failed!)
N1000 G90
M30
```

### User Confirmation Dialog

```gcode
#1505 = 1(Ready to start? ENTER=Yes ESC=No)
IF #1505 == 0 GOTO 999  ; User pressed ESC
; Continue with operation...
N999 M30
```

### Display Current Position

```gcode
#1510 = 0
#1511 = 0
#1512 = 0
#1510 = #880  ; X position
#1511 = #881  ; Y position
#1512 = #882  ; Z position
#1505 = -5000(Position X=[%.3f] Y=[%.3f] Z=[%.3f])
```

### User Input for Variable

```gcode
(Ask user to enter probe ball diameter)
#2070 = 500(Enter probe diameter:)
; User's input now in #500

#1510 = 0
#1510 = #500
#1505 = -5000(Using diameter: [%.3f])
```

## Display and Feedback

**Basic message** (no user interaction):
```gcode
#1505 = -5000(Operation complete!)
```

**Confirmation dialog**:
```gcode
#1505 = 1(Continue? ESC=Cancel ENTER=OK)
IF #1505 == 0 GOTO abort
```

**Display variable values**:
```gcode
#1510 = 0           ; Prime first
#1510 = #880        ; Load value
#1505 = 1(X Position: [%.3f])  ; Use [%.3f] with square brackets!
```

**Format codes**:
- `[%.0f]` = no decimals
- `[%.1f]` = 1 decimal
- `[%.2f]` = 2 decimals
- `[%.3f]` = 3 decimals

**G4P-1 Interactive Pause** (undocumented but proven):
```gcode
; Operator manually positions Z to table surface
G4P-1
G1
;Move Z to table
;and press START
#1577 = #882    ; Capture position after operator presses START

; Continue with captured value
#807 = #882 - #probe_length
```

**How it works**: `G4P-1` pauses execution and displays following comments as on-screen instructions. Operator performs manual action (jog axes, visual check, position tool), then presses START. Next line executes immediately and can capture the current position.

See `references/ddcs-display-methods.md` for complete guide and `references/community-patterns.md` for advanced interactive patterns.

## Fusion 360 Post-Processor Integration

### Dynamic WCS-Aware Parking (Production-Tested)

The DDCS M350's non-standard WCS addressing requires special handling in Fusion 360 post-processors. See `references/fusion-post-processor.md` for complete implementation.

**Core formula** for machine coordinate → work coordinate conversion:

```javascript
// In post-processor onClose() function:
writeBlock(
  "X[#1153 - #[800 + #578 * 5]]",  // Safe park X
  "Y[#1154 - #[801 + #578 * 5]]"   // Safe park Y
);
```

**How it works:**
- `#1153` = Stored machine X position (from SAVE macro)
- `#578` = Active WCS index (1=G54, 2=G55, etc.)
- `800` = Base X offset address
- `5` = Stride between WCS offset addresses
- `#[800 + #578 * 5]` = Indirect addressing reads active WCS X offset
- Result: Machine position converted to work coordinate in active WCS

### End-of-Job Parking to Saved Position

Production-tested pattern with multiple parking options:

```javascript
var endPos = getProperty("homePositionEnd");

if (endPos == "safePark") {
  // Safe Park using #1153-#1154
  writeBlock(
    gMotionModal.format(0), 
    "X[#1153 - #[800 + #578 * 5]]", 
    "Y[#1154 - #[801 + #578 * 5]]"
  );
  
} else if (endPos == "tool") {
  // Tool Change using #1155-#1156
  writeBlock(
    gMotionModal.format(0), 
    "X[#1155 - #[800 + #578 * 5]]", 
    "Y[#1156 - #[801 + #578 * 5]]"
  );
}
```

### Safe Z Retract Before Parking

```javascript
// Move to Machine Z-10 (or your safe height) while respecting WCS
writeBlock(
  gMotionModal.format(0), 
  "Z[-10 - #[802 + #578 * 5]]"
);
```

**Important**: Adjust Z value for your machine's coordinate system direction.

### Victory Dance Pattern (Optional)

Celebratory 3D spiral movement after job completion - proven morale booster in production environment:

```javascript
if (getProperty("victoryDance")) {
  // Two-phase spiral: out & up, then in & up
  // See fusion-post-processor.md for complete implementation
  
  // Optional operator confirmation:
  if (getProperty("askForDance")) {
    writeBlock(mFormat.format(0));  // M0 pause
  }
  
  // Dance code here...
  
  gMotionModal.reset();  // CRITICAL: Reset state after dance
}
```

See `references/fusion-post-processor.md` for:
- Complete tested post-processor code
- Victory dance implementation
- WCS offset address calculations
- Multiple park position options
- Troubleshooting guide
- Template for custom positions

## Troubleshooting Guide

### Controller Freezes When Running Macro
1. Check for unprimed variables - add priming block
2. Look for `#880`, `#881`, `#882` assignments without priming
3. Verify you're not using G10 or hardcoded G53
4. Check for `%` symbol in dialog messages (causes freeze)

### WCS Zero Not Setting Correctly
1. Verify you're using correct WCS offset addresses (stride of 5)
2. Check that you're reading machine coordinates (#880-#883)
3. Ensure you're not using G10 command
4. For dual-gantry, remember to sync A-axis: `#813 = #881`

### G53 Moves to Wrong Position
1. Don't use hardcoded constants with G53
2. Use incremental delta method instead
3. If using G53 with variables, test on your firmware first

### Probe Doesn't Trigger or Gives Wrong Result
1. Check probe speed parameter #632 (Pr132)
2. Verify probe thickness parameter #629 (Pr129)
3. Confirm fixed sensor settings if using fixed probe
4. Check #1922 flag after G31 (0=miss, 1=hit)
5. Use #1927 for precision Z trigger position

### Variables Not Persisting After Reboot
1. Only #500-#1499 and #2500-#2999 are persistent
2. Use #1153-#1193 gap addresses for custom persistent data
3. Variables #0-#499 always reset to 0

### Format Codes Not Working in Messages
1. Use square brackets: `[%.3f]` not `%.3f`
2. Prime display variables: `#1510 = 0` before `#1510 = #880`
3. Some firmware versions work WITHOUT priming - test both

## Best Practices

1. **Always read CORE_TRUTH.md first** when starting a new macro
2. **Prime all user variables** at the start of every macro
3. **Avoid G10, G28, hardcoded G53** - use documented workarounds
4. **Test on scrap material** - controller quirks can surprise you
5. **Use incremental moves** for machine coordinate positioning
6. **Save state** (G90/G91) at start, restore at end
7. **Check probe results** (#1922) before trusting position data
8. **Comment your code** - but keep comments outside conditionals
9. **Use persistent storage** (#1153-#1193) for data that must survive reboot
10. **Dual-gantry users**: Always sync A-axis offsets with Y-axis

## File Encoding Requirements

- ✅ UTF-8 encoding without BOM
- ✅ Windows line endings (CRLF) preferred
- ✅ Unix line endings (LF) also work

## Quick Workflow

1. **Identify the task** - probe? WCS zero? position save?
2. **Check CORE_TRUTH.md** - any broken commands involved?
3. **Look up variables** in Variables-ENG_01-04-2025.xlsx
4. **Copy template** - start with standard macro structure
5. **Add priming block** - initialize all variables
6. **Implement logic** - using proven patterns above
7. **Test on scrap** - verify behavior before production use

## Additional Resources

For detailed information on specific topics:
- **User Storage Map**: See `references/user-storage-map.md` - **Complete allocation guide for 174 persistent variables**
- **K-Button Assignments**: See `references/k-button-assignments.md` - **Track K1-K7 button macros (all currently free)**
- **Gantry Squaring Calibration**: See `references/gantry-squaring-calibration.md` - **Simple single-switch calibration with test cuts**
- **PNP to NPN Converter**: See `references/pnp-to-npn-converter.md` - **Signal inverter for PNP probe compatibility**
- **MacroB Programming Rules**: See `references/macrob-programming-rules.md` - **Essential M350 syntax rules and best practices**
- **Advanced Macro Mathematics**: See `references/advanced-macro-mathematics.md` - **Formula library by Nikolay Zvyagintsev**
- **V1.22 Verified Skillset**: See `references/DDCS_Expert___M350_Master_Skillset__Verified_V1_22_.pdf` - Complete verified patterns and reference values
- **Current Fusion 360 Post**: See `references/DDCSE_Post-processor.cps` - Your working post-processor file (ready to use)
- **Example macro files**: See `references/example-macros/` - 22 working .nc files including auto-squaring and thread milling
- **Hardware configuration**: See `references/hardware-config.md` - Your Ultimate Bee 1010 setup details
- **Virtual button automation**: See `references/virtual-buttons-2037.md` - Complete guide to #2037 programmable buttons
- **Fusion 360 integration**: See `references/fusion-post-processor.md` - Complete post-processor guide with victory dance
- **User-tested patterns**: See `references/user-tested-patterns.md` - Real macros from production dual-gantry machine
- **Proven code patterns**: See `references/community-patterns.md` - Working macros from experienced users
- **Official G31 specification**: See `references/M350_instruction_description-G31.pdf` - Official M350 probe command documentation
- **Official #2037 specification**: See `references/Virtual_button_function__2037_.pdf` - Official virtual button control documentation
- **Variable priming bug**: See `references/variable-priming-card.md`
- **Display and dialogs**: See `references/ddcs-display-methods.md` - Includes #2042 beep sound control
- **Complete variable map**: See `references/Variables-ENG_01-04-2025.xlsx`
- **G/M code reference**: See `references/G-M-code_full_list.xlsx`
- **Parameter details**: See `references/eng` file
- **Controller quirks**: See `references/CORE_TRUTH.md` - V1.22 VERIFIED

**Recommended reading order for complex tasks:**
1. CORE_TRUTH.md - Essential quirks and broken commands
2. hardware-config.md - Your specific machine configuration
3. example-macros/ - Browse working .nc files for similar tasks
4. user-tested-patterns.md - See tested solutions for your exact use case
5. fusion-post-processor.md - If working with Fusion 360
6. community-patterns.md - Additional proven approaches
7. Variables-ENG_01-04-2025.xlsx - Look up specific addresses
8. Your reference files as needed for details

**System Specifics**: This skill is tailored for an Ultimate Bee 1010 dual-gantry machine (700×700×100mm) with DDCS M350 controller, 2.2kW water-cooled spindle, floating + fixed probes, manual tool changing, and T-track workholding.

Remember: This controller has quirks. When standard FANUC code doesn't work, there's usually a DDCS-specific workaround documented in the references.
