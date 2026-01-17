# DDCS M350 Expert Controller - Core Truth (V1.22 VERIFIED)

**CRITICAL: Read this FIRST before writing any macro code**

**Last Updated**: January 2026  
**Version**: V1.22 Verified  
**Source**: Production-tested Ultimate Bee 1010 + Community verification

---

## ⚠️ CRITICAL "CORE TRUTHS" - Standard FANUC Rules DO NOT Apply

### 1. G10 is BROKEN - Use Direct Parameter Writing

**Problem**: `G10 L2 P1 X0 Y0 Z0` causes unwanted motion or unpredictable behavior

**WHY**: G10 WCS offset writing is not implemented correctly in M350 firmware

**✅ SOLUTION - Direct Parameter Writing:**
```gcode
; WRONG - Do not use G10
G10 L2 P1 X0 Y0 Z0  ; BROKEN!

; CORRECT - Write directly to WCS offset variables
#805 = #880  ; Set G54 X offset to current machine X
#806 = #881  ; Set G54 Y offset to current machine Y
#807 = #882  ; Set G54 Z offset to current machine Z
```

**For any WCS (G54-G59):**
```gcode
; Universal pattern for active WCS
#100 = #578               ; Get active WCS index (1-6)
#101 = 805 + [#100-1]*5   ; Calculate X offset address
#102 = 806 + [#100-1]*5   ; Calculate Y offset address
#103 = 807 + [#100-1]*5   ; Calculate Z offset address

#[#101] = #880            ; Set X offset
#[#102] = #881            ; Set Y offset
#[#103] = #882            ; Set Z offset
```

---

### 2. G53 Syntax Rules (VERIFIED V1.22)

**CRITICAL**: G53 machine coordinate system moves have STRICT requirements.

#### ✅ VALID Syntax (VERIFIED WORKING)

**Method 1: G53 with Variables Only**
```gcode
#100 = 500    ; Target machine X (positive space)
#101 = -500   ; Target machine Y (NEGATIVE space)
G53 X[#100] Y[#101]  ; MUST use variables, NO G0/G1 on same line
```

**Method 2: G53 with Variable References**
```gcode
G53 X#100 Y#101  ; Direct variable reference also works
```

**Key Rules:**
- ✅ MUST use variables (cannot use hardcoded constants)
- ✅ NO G0 or G1 on the same line as G53
- ✅ Variables only - expressions like `X[#100]` or `X#100`

#### ❌ INVALID Syntax (WILL FAIL)

```gcode
; WRONG - Combining G53 with G0/G1
G53 G0 X500 Y-500       ; WILL FAIL - no G0/G1 allowed
G0 G53 X#100 Y#101      ; WILL FAIL - order doesn't matter

; WRONG - Using hardcoded constants
G53 X500 Y-500          ; UNRELIABLE - may use WCS instead of machine coords
G53 X0 Y0               ; UNRELIABLE - avoid constants

; WRONG - Modal combination attempts
G53 G0                  ; Then later: X500 Y-500  ; WILL FAIL
```

#### 🛡️ FAILSAFE Method (ALWAYS WORKS)

**Incremental Delta Moves** - Use when unsure:
```gcode
; Calculate delta from current position to target
#100 = 500 - #880    ; Delta X (target - current machine X)
#101 = -500 - #881   ; Delta Y (target - current machine Y)

G91                  ; Switch to incremental mode
G0 X[#100] Y[#101]   ; Move by calculated delta
G90                  ; Return to absolute mode
```

**When to use each method:**
- **G53 with variables**: Clean, direct - use for production code
- **Incremental delta**: Guaranteed failsafe - use when debugging or unsure

---

### 3. G28 Reference Point Behavior

**Understanding G28 on M350**: G28 moves to the back-off position from limit switches, NOT machine zero.

**How G28 works on DDCS M350:**
- G28 moves axes to their **home switch back-off positions**
- Back-off distances set in Parameters Pr122-124 (variables #622-#624)
- This is NOT the same as machine coordinate zero
- This is the safe position after homing completes

**Your Ultimate Bee 1010 G28 positions:**
```gcode
G28 X0 Y0 Z0  ; Moves to back-off positions:
              ; X = 5.0mm (from limit switch)
              ; Y = -5.0mm (from limit switch)
              ; Z = -5.0mm (from limit switch)
```

**Where these values come from:**
```gcode
#622  ; Pr122 = X Back Home = 5.0mm
#623  ; Pr123 = Y Back Home = -5.0mm  
#624  ; Pr124 = Z Back Home = -5.0mm
```

**Important distinctions:**
- **G28** = Move to home back-off position (Pr122-124)
- **G53 X0 Y0 Z0** = Move to machine coordinate zero (true machine origin)
- **G54 X0 Y0 Z0** = Move to WCS zero (work coordinate zero)

**When to use G28:**
```gcode
; Safe parking after job (near home switches)
G28 X0 Y0 Z0  ; Go to home back-off position

; This is DIFFERENT from saved positions
G53 X#1153 Y#1154  ; Go to saved machine coordinate
```

**G28 syntax on M350:**
```gcode
; Standard G28 usage
G91 G28 X0 Y0 Z0  ; Incremental mode, move to home back-off
G90               ; Return to absolute mode

; Or direct G28 (works on M350)
G28 X0 Y0 Z0      ; Move to home back-off positions
```

**Why this matters:**
- G28 is useful for safe parking near home switches
- But it's NOT the same as your custom park positions (#1153-#1154)
- And it's NOT machine zero (G53 X0 Y0 Z0)
- It's the comfortable back-off distance from switches set in Pr122-124

---

### 4. Variable Priming Bug (CRITICAL)

**Problem**: Assigning system variables to uninitialized user variables causes controller freeze

**SYMPTOM**: Controller hangs when executing lines like `#100 = #880` if #100 hasn't been initialized

**✅ SOLUTION - Always Prime Variables:**
```gcode
; WRONG - Uninitialized variable
#100 = #880  ; May cause freeze!

; CORRECT - Prime first, then assign
#100 = 0     ; Initialize with any constant
#100 = #880  ; Now safe to assign system variable
```

**Priming value doesn't matter** (can be 0, 1, or any number):
```gcode
#100 = 1     ; This works too
#100 = #880  ; Safe
```

**Community observation**: Freeze mainly happens with persistent storage (#1153+). Local variables (#0-#499) may work without priming in practice, but always prime for safety.

---

### 5. Display Formatting Rules

**Problem**: Format codes need square brackets in #1505 messages

**✅ CORRECT - Square Brackets:**
```gcode
#1510 = #880
#1511 = #881
#1505 = -5000(Position: X=[%.3f] Y=[%.3f])  ; Square brackets required
```

**❌ WRONG - Regular Parentheses:**
```gcode
#1505 = -5000(Position: X=(%.3f) Y=(%.3f))  ; Won't format
```

**Available format codes:**
- `[%.0f]` - Integer (no decimals)
- `[%.1f]` - 1 decimal place
- `[%.2f]` - 2 decimal places
- `[%.3f]` - 3 decimal places (precision work)

---

### 6. Parameter Mapping Rule

**Critical Rule**: "Pr" numbers in UI usually map to `#Pr+500`

```
Pr1 (UI) = #501 (macro variable)
Pr129 (UI) = #629 (macro variable)
Pr500 (UI) = #1000 (macro variable)
```

**EXCEPTION**: System variables like machine coordinates don't follow this rule:
- Machine X = #880 (not Pr380)
- Machine Y = #881 (not Pr381)

**Always verify** in `Variables-ENG_01-04-2025.xlsx` - the Pr+500 rule is a guideline, not absolute.

---

## Machine Coordinate System (VERIFIED)

### Machine Coordinate Spaces

**Your Ultimate Bee 1010 Configuration:**

| Axis | Direction | Range | Notes |
|------|-----------|-------|-------|
| X | POSITIVE | 0 to +Max (~750mm) | Normal positive space |
| Y | NEGATIVE | 0 to -Max (~-750mm) | **Travels in negative direction** |
| Z | NEGATIVE | 0 to -Max (~-100mm) | **Table drops = negative Z** |
| A | NEGATIVE | Follows Y | Dual-gantry slave axis |

**Read machine coordinates:**
```gcode
#880  ; Current X machine position (0 to +max)
#881  ; Current Y machine position (0 to -max, NEGATIVE)
#882  ; Current Z machine position (0 to -max, NEGATIVE)
#883  ; Current A machine position (synced with Y)
```

**Critical understanding:**
- X increases as gantry moves right
- Y increases (becomes less negative) as gantry moves forward
- Z increases (becomes less negative) as table rises

---

## Work Coordinate Offset Map (Stride = 5)

**VERIFIED**: WCS offsets use stride of 5 between coordinate systems

| WCS | Index (#578) | X Offset | Y Offset | Z Offset | A Offset |
|-----|--------------|----------|----------|----------|----------|
| G54 | 1 | #805 | #806 | #807 | #808 |
| G55 | 2 | #810 | #811 | #812 | #813 |
| G56 | 3 | #815 | #816 | #817 | #818 |
| G57 | 4 | #820 | #821 | #822 | #823 |
| G58 | 5 | #825 | #826 | #827 | #828 |
| G59 | 6 | #830 | #831 | #832 | #833 |

**To set WCS zero**, write machine coordinate to offset variable:
```gcode
#805 = #880  ; Set G54 X zero at current machine position
```

**Calculate offset for active WCS:**
```gcode
#100 = #578               ; Get active WCS (1-6)
#101 = 805 + [#100-1]*5   ; Calculate X offset address
#[#101] = #880            ; Set X zero for active WCS
```

**Important**: Write the MACHINE coordinate value, not zero!
- WCS offset = Current machine position
- Work coordinate will display as 0.000 after setting

---

## Your Machine-Specific Reference Values

### G54 Fence System (Your Ultimate Bee 1010)

**These are YOUR verified machine reference values** - use to restore G54 if accidentally lost:

| Reference | Axis | Machine Coordinate | Purpose |
|-----------|------|-------------------|---------|
| G54 Fence | X | 42.650 | Reference X zero position |
| G54 Fence | Y | -661.186 | Reference Y zero position |
| Spoilboard | Z | -87.336 | Z zero surface height |

**Restore G54 macro:**
```gcode
(RESTORE G54 FENCE DEFAULTS - Ultimate Bee 1010 Specific)
#805 = 0
#806 = 0  
#807 = 0

#805 = 42.650     ; Restore X fence
#806 = -661.186   ; Restore Y fence  
#807 = -87.336    ; Restore Z spoilboard

#1505 = -5000(G54 Fence Restored!)
M30
```

**When to use**: If you accidentally overwrite G54 and lose your fence reference.

### Back-Off from Home Positions

**Your machine's verified back-off distances** (Pr122-124):

```gcode
#622  ; X Back Home = 5.0mm (POSITIVE space)
#623  ; Y Back Home = -5.0mm (NEGATIVE space)
#624  ; Z Back Home = -5.0mm (NEGATIVE space)
```

These are the distances the axes back off from limit switches after homing.

---

## Common System Parameters (Read/Write)

**VERIFIED**: Macro Variable = UI Parameter + 500

| Parameter (UI) | Macro Variable | Description | Your Machine Value |
|----------------|----------------|-------------|-------------------|
| Pr 0 | #500 | Start Speed | Min speed before accel |
| Pr 61 | #561 | Default Feed | Used if F missing |
| Pr 70 | #570 | Z Lift Distance | Retract on Pause/Stop |
| Pr 82 | #582 | Max Spindle RPM | 24,000 RPM limit |
| Pr 91 | #591 | Z Lift Enable | 0=No, 1=Lift on Pause |
| Pr 122 | #622 | X Back Home | 5.0mm (positive) |
| Pr 123 | #623 | Y Back Home | -5.0mm (negative) |
| Pr 124 | #624 | Z Back Home | -5.0mm (negative) |
| Pr 129 | #629 | Probe Thickness | Touch plate thickness (mm) |
| Pr 130 | #630 | Fixed Sensor Enable | 0=Disable, 1=Enable |
| Pr 132 | #632 | Probe Speed | Initial G31 feedrate |
| Pr 135 | #635 | Fixed Probe X | Machine X for sensor |
| Pr 136 | #636 | Fixed Probe Y | Machine Y for sensor |
| Pr 269 | #769 | Debug Message | Set to 1 for #1503 text |
| - | #578 | WCS Index | Active WCS (1=G54, 2=G55...) |

---

## User Storage Map (VERIFIED PERSISTENT)

**Your allocated persistent storage** - do not overwrite, use Available slots:

| Function | Variables | Status | Macro |
|----------|-----------|--------|-------|
| Safe Park Position | #1153 (X), #1154 (Y) | ✅ IN USE | SAVE_safe_park_position.nc |
| Tool Change Position | #1155 (X), #1156 (Y) | ✅ IN USE | SAVE_tool_change_position.nc |
| Available | #1157 - #1169 | 🟢 FREE | Available for expansion |
| Probe Config | #1170 - #1175 | 🟡 RESERVED | Reserved for probe settings |
| Available | #1176 - #1193 | 🟢 FREE | Available for use |
| G-code Temp Variables | #2038 | 🟡 SYSTEM | "Self-define G code Temporary variables" |
| Available (Medium) | #2039 - #2071 | 🟢 FREE | 33 variables, persistent |
| Function Keys K1-K8 | #2072 - #2079 | 🟡 SYSTEM | Function key indicator addresses |
| Available (LARGE) | #2500 - #2599 | 🟢 FREE | 100 variables, **VERIFIED PERSISTENT** (XLSX confirmed 'B' status) |

**Note on #2500-#2599**: Earlier versions of Variables-ENG_01-04-2025.xlsx incorrectly marked this as "does not work". **Updated file (01-04-2025) confirms status 'B' (persisted after reboot)**. User testing and official documentation now aligned.

### Persistence Rules (VERIFIED)

**NON-PERSISTENT (Resets on reboot):**
- `#0 - #499` - User variables, temporary storage only

**PERSISTENT (Survives reboot):**
- `#1153 - #1193` - Gap in system variables, verified safe (41 variables)
- `#2039 - #2071` - Persistent range, verified working (33 variables)
- `#2500 - #2599` - Large persistent block, **user-verified working** (100 variables)

**Total available persistent storage: 174 variables!**

**DO NOT use #0-#499 for storage** - will reset to 0.000 on power cycle!

---

## The Three Numbering Systems

The DDCS M350 uses THREE different numbering schemes:

### 1. ENG File Format (Parameter Numbers)
- Format: `#0`, `#1`, `#129`, `#880`
- This is the **Parameter Number (Pr#)**
- Found in eng file from controller
- **NOT the macro address!**

### 2. Controller UI Display
- Format: `Pr0`, `Pr1`, `Pr129`
- Same as eng file number
- What you see in parameter interface

### 3. Macro/G-Code Address (What You Actually Write)
- Format: `#500`, `#629`, `#880`
- Memory address in variable space
- **This goes in your .nc files**

### The Critical Mapping

```
eng file "#129" → Pr129 (UI) → #629 (macro) via Variables-ENG_01-04-2025.xlsx
```

**NEVER assume** eng "#number" = macro "#number"

Always use **BOTH** reference files:
1. `Variables-ENG_01-04-2025.xlsx` - Find macro address
2. `eng` - Understand parameter behavior

---

## Standard Macro Template (V1.22)

```gcode
%
(Title: <Macro Name>)
(Description: <Function>)

(--- PRIMING BLOCK ---)
#100 = 0
#101 = 0
#102 = 0
#1153 = 0  ; If using persistent storage

(--- STATE SAVE ---)
#100 = #4003  ; Save G90/G91 state

(--- MAIN LOGIC ---)
M5    ; Stop spindle for safety
G90   ; Absolute mode

; [INSERT LOGIC HERE]

(--- STATE RESTORE ---)
G#100  ; Restore G90/G91 state

M30
%
```

---

---

## Parameter Access & Passwords

### Default Access Passwords

**Use with EXTREME caution** - changing parameters can damage your machine!

| Access Level | Password | Capabilities |
|-------------|----------|--------------|
| Operator | 666666 | Basic parameter viewing and simple adjustments |
| Admin | 777777 | Advanced parameter modifications |
| Super Admin | 888888 | **ALL parameters** - can damage machine! |

**⚠️ CRITICAL**: Always backup parameters to USB before making ANY changes!

### Critical Parameter for Macros

**Pr76 (#0076) - Macro Enable**
```
Menu → Parameters → Pr76
Set to: OPEN
```

**Without this setting, NO macros will execute!** This is the first thing to check if macros aren't running.

### Simulation Parameter

**Pr245 (#0245) - Simulation Mode**
```
Set to: "line"
```

Enables line-by-line simulation for testing macros before running on machine.

**Other modes:**
- `3D` - 3D graphical simulation
- `Statue` - Static view
- May affect whether simulation runs

---

## Investigation Process for ANY Variable

**STEP 1**: Check `Variables-ENG_01-04-2025.xlsx`
- Find the macro address
- Check if it's a parameter (has Pr# column)
- Check if it's read-only (R/O marking)

**STEP 2**: Check `eng` file
- Find parameter behavior
- Menu location (`-m` flag)
- Read/write permissions (`-p` flag)
- Min/max ranges

**STEP 3**: Cross-reference
- XLSX = WHAT the macro address is
- eng = HOW the parameter behaves

**STEP 4**: Test safely
- Prime variable first
- Test on scrap material
- Verify result with READ_VAR.nc

---

## Critical Reminders

1. ✅ **G10 is BROKEN** - Use direct parameter writing
2. ✅ **G53 requires variables** - No constants, no G0/G1 on same line
3. ✅ **G28 goes to back-off positions** - Uses Pr122-124 (#622-#624), not machine zero
4. ✅ **Always prime variables** - Prevents freeze bug
5. ✅ **Format codes need square brackets** - `[%.3f]` not `(%.3f)`
6. ✅ **Pr + 500 = macro address** - Usually (verify in XLSX)
7. ✅ **Y and Z are NEGATIVE space** - Your machine coordinate system
8. ✅ **#0-#499 NOT persistent** - Use #1153-#1193, #2039-#2071, or #2500-#2599 for storage
9. ✅ **#2500-#2599 VERIFIED PERSISTENT** - Confirmed in Variables-ENG_01-04-2025.xlsx (01-04-2025) status 'B'
10. ✅ **WCS stride = 5** - Not 1, calculate with `805 + [index-1]*5`
11. ✅ **Standard FANUC rules DON'T apply** - M350 is different!

**Available persistent storage:**
- `#1153-#1193` (41 variables) - Verified safe gap
- `#2039-#2071` (33 variables) - Verified working range
- `#2500-#2599` (100 variables) - User-verified working (XLSX marking incorrect)
- **Total: 174 persistent variables available**

**Important position distinctions:**
- `G28 X0 Y0 Z0` → Home back-off positions (X=5.0, Y=-5.0, Z=-5.0 from switches)
- `G53 X0 Y0 Z0` → True machine coordinate zero
- `G53 X#1153 Y#1154` → Your saved custom park positions
- `G54 X0 Y0 Z0` → WCS zero (work coordinate system)

---

**Remember**: When standard FANUC code doesn't work, there's usually a DDCS-specific workaround in this document. Read before coding, test on scrap, verify results!
