# DDCS M350 Expert Controller - Core Truths Quick Reference

**Version**: V1.22 Verified  
**Authority**: [CONFIRMED] Production-tested  
**Last Updated**: January 2026

**Purpose**: Essential firmware quirks - READ FIRST before any macro work

**Complete details**: See full version (571 lines) or `software-technical-spec.md`

---

## The 8 Critical Truths [CONFIRMED]

**Standard FANUC rules DO NOT apply**

| # | Truth | Workaround | Reference |
|---|-------|------------|-----------|
| 1 | **G10 is BROKEN** | Use direct #805+ writes | software-technical-spec.md §3.2 |
| 2 | **G53 requires variables** | No hardcoded constants | software-technical-spec.md §3.3 |
| 3 | **G28 ≠ machine zero** | Goes to back-off positions | software-technical-spec.md §3.3 |
| 4 | **Variable priming required** | Prime #1153+ from #880+ | variable-priming-card.md |
| 5 | **C-style operators only** | Use ==, !=, <, > (NOT EQ) | software-technical-spec.md §3.4 |
| 6 | **WCS stride = 5** | Not 20 (G54=#805, G55=#810) | software-technical-spec.md §3.5 |
| 7 | **IF/GOTO syntax strict** | No brackets, no spaces | conditional-syntax-card.md |
| 8 | **#2070 range limited** | Only writes to #50-#499 | input-dialog-patterns.md |

---

## 1. G10 is BROKEN

### Problem

```gcode
G10 L2 P1 X0 Y0 Z0   ; ❌ Causes unwanted motion
```

### Solution

**Direct parameter writing**:
```gcode
; Set G54 offsets
#805 = #880   ; G54 X offset
#806 = #881   ; G54 Y offset
#807 = #882   ; G54 Z offset
```

**Universal pattern** (any WCS):
```gcode
#wcs = #578                    ; Get active WCS (1-6)
#base = 805 + [#wcs - 1] * 5  ; Calculate base address
#[#base + 0] = #880           ; Set X
#[#base + 1] = #881           ; Set Y
#[#base + 2] = #882           ; Set Z
```

**WCS address table**:

| WCS | Index | X | Y | Z | A | B |
|-----|-------|---|---|---|---|---|
| G54 | 1 | 805 | 806 | 807 | 808 | 809 |
| G55 | 2 | 810 | 811 | 812 | 813 | 814 |
| G56 | 3 | 815 | 816 | 817 | 818 | 819 |
| G57 | 4 | 820 | 821 | 822 | 823 | 824 |
| G58 | 5 | 825 | 826 | 827 | 828 | 829 |
| G59 | 6 | 830 | 831 | 832 | 833 | 834 |

**Formula**: `Base + (WCS_Index - 1) × 5`

---

## 2. G53 Syntax Rules

### ✅ VALID (VERIFIED)

```gcode
; Method 1: Variables only
#x = 500
#y = -500
G53 X#x Y#y   ; ✅ Works

; Method 2: Expressions in brackets
G53 X[#100] Y[#101]   ; ✅ Works

; Method 3: Calculated on separate line
#target = 500 + 100
G53 X#target   ; ✅ Works
```

### ❌ INVALID (BROKEN)

```gcode
; Hardcoded constants — G53 Z5, G53 X0, etc. all fail
G53 X0 Y0 Z0   ; ❌ FAILS
G53 Z5         ; ❌ FAILS

; G0/G1 on same line
G53 G0 X#var   ; ❌ FAILS
G53 G1 X#var F500   ; ❌ FAILS

; Expressions without brackets
G53 X#100+50   ; ❌ FAILS
```

### Rule of thumb

The operand must contain at least one variable. Pure constants are rejected; once a variable is involved, you can add constants to it.

```gcode
G53 Z5             ; ❌ bare constant
G53 Z#z            ; ✅ variable
G53 Z[#10+5]       ; ✅ expression with variable
G53 Z[#10]+5       ; ✅ expression result + constant (factory pattern)
```

Evidence: the controller's own factory code (`firmware-backup-2025-12-31/.../slib-g.nc`) uses variables for every G53 call across ~30+ usages — never bare constants. Confirmed across user macros and factory code.

### Correct Pattern

```gcode
; ALWAYS use this pattern
#x = 0
#y = 0
#z = 0
G53 X#x Y#y Z#z   ; Move to machine zero
```

---

## 3. G28 Reference Point Behavior

### What G28 Actually Does

**G28 does NOT go to machine zero!**

**G28 goes to "back-off" positions**:
- Set by parameters Pr122-Pr126 (#622-#626)
- Ultimate Bee 1010: X=5.0, Y=-5.0, Z=-5.0
- This is **5mm away** from limit switches

### Machine Zero vs G28

| Command | Destination | Ultimate Bee 1010 |
|---------|-------------|-------------------|
| **G53 X0 Y0 Z0** | True machine zero | X=0, Y=0, Z=0 |
| **G28 X0 Y0 Z0** | Back-off positions | X=5.0, Y=-5.0, Z=-5.0 |

### Solution

**Use G53 for machine zero**:
```gcode
; Go to true machine zero
#x = 0
#y = 0
#z = 0
G53 X#x Y#y Z#z
```

**If you need back-off positions**:
```gcode
; Read back-off parameters
#x_backoff = #622
#y_backoff = #623
#z_backoff = #624
G53 X#x_backoff Y#y_backoff Z#z_backoff
```

---

## 4. Variable Priming Bug [CRITICAL]

### The Bug

**Direct assignment from system vars to persistent vars causes freeze**:

```gcode
#1153 = #880   ; ❌ CONTROLLER FREEZE
```

### Why It Happens

Firmware bug when assigning:
- **FROM**: System variables (#880+)
- **TO**: Persistent variables (#1153-#5999)

### Solution: Prime First

```gcode
; Method 1: Prime through local variable
#100 = #880    ; ✅ Prime in local var
#1153 = #100   ; ✅ Now safe

; Method 2: Arithmetic "wash"
#1153 = #880 + 0   ; ✅ Addition prevents freeze

; Method 3: Use intermediate calculation
#1153 = #880 * 1   ; ✅ Multiplication works too
```

### What Needs Priming

**Safe (no priming needed)**:
- Local variables (#1-#999)
- System parameters (#500-#999)
- WCS offsets (#805-#834)

**Requires priming**:
- Persistent storage (#1153-#5999)

**See**: `variable-priming-card.md` for complete patterns

---

## 5. C-Style Operators Only

### ❌ FANUC Style (UNRELIABLE)

```gcode
IF #100 EQ 5 GOTO100   ; ❌ Unreliable
IF #100 NE 0 GOTO200   ; ❌ Unreliable
IF #100 LT 10 GOTO300  ; ❌ Unreliable
IF #100 GT 5 GOTO400   ; ❌ Unreliable
IF #100 LE 10 GOTO500  ; ❌ Unreliable
IF #100 GE 5 GOTO600   ; ❌ Unreliable
```

### ✅ C-Style (REQUIRED)

```gcode
IF #100 == 5 GOTO100   ; ✅ Reliable
IF #100 != 0 GOTO200   ; ✅ Reliable
IF #100 < 10 GOTO300   ; ✅ Reliable
IF #100 > 5 GOTO400    ; ✅ Reliable
IF #100 <= 10 GOTO500  ; ✅ Reliable
IF #100 >= 5 GOTO600   ; ✅ Reliable
```

**Community data**: 99% of production macros use C-style exclusively

---

## 6. WCS Stride = 5 (Not 20)

### Standard FANUC

```
Stride = 20
G54 = Base + 0×20
G55 = Base + 1×20
```

### DDCS M350

```
Stride = 5 (Non-standard!)
G54 = 805 + 0×5 = 805
G55 = 805 + 1×5 = 810
G56 = 805 + 2×5 = 815
```

### Address Calculation

```gcode
; Calculate WCS address
#wcs_index = 2   ; G55
#axis_offset = 0 ; 0=X, 1=Y, 2=Z, 3=A, 4=B

#address = 805 + [#wcs_index - 1] * 5 + #axis_offset
; G55 Y = 805 + (2-1)*5 + 1 = 811
```

---

## 7. Conditional Syntax Rules [CONFIRMED]

> **⚠️ Evidence note (cross-checked against .nc macros, 2026-05-07):** The "no brackets on simple conditions" rule below is **not supported by production macro evidence**. Across all 26 user macros AND the controller's factory firmware (`firmware-backup-2025-12-31/.../slib-g.nc`), **100% of IF statements use brackets** — `IF [#80==1]*[#60==2] GOTO202`, `IF [#71!=0]*[#116<=1] GOTO116`, etc. Zero macros use the bare `IF #var==5 GOTO1` form. The bare form may work (the user reports observing it), but it is not how working code is written. The bracketed form is the safer default.
>
> Also missing from this section but used everywhere in macros: `+` between bracketed conditions = logical **OR**, `*` = logical **AND**. Example: `IF [#a==1]+[#b==1] GOTO5` jumps if either is true.

### IF Statement Brackets

**WRONG - Simple conditions with brackets**:
```gcode
IF [#1922!=2] GOTO990      // ❌ Parser error
IF[#1922!=2]GOTO990        // ❌ Syntax error
IF [#1922 != 2] GOTO 990   // ❌ Multiple errors
```

**CORRECT - No brackets on simple conditions** *(claimed; not seen in any production macro)*:
```gcode
IF #1922!=2 GOTO1          // ✅ Works (per user testing)
IF #1921==1 GOTO2          // ✅ Works (per user testing)
IF #100>50 GOTO9           // ✅ Works (per user testing)
```

**Use brackets for complex expressions** *(this is what every working macro actually does, even for "simple" comparisons)*:
```gcode
IF [#14==5]+[#14==4] GOTO10   // ✅ Compound: + = logical OR
IF [#80==1]*[#60==2] GOTO202  // ✅ Compound: * = logical AND
IF [#100+#200]>50 GOTO2       // ✅ Arithmetic
IF [#var==5] GOTO1            // ✅ Single bracketed condition (matches macro style)
```

### GOTO Spacing

**WRONG - Space before label**:
```gcode
IF #1922!=2 GOTO 990       // ❌ Parser error
GOTO 999                   // ❌ Label not found
```

**CORRECT - No space**:
```gcode
IF #1922!=2 GOTO1          // ✅ Works
GOTO2                      // ✅ Works
GOTO999                    // ✅ Works
```

### Label Number Reliability

> **⚠️ Evidence note (2026-05-07):** The "single digit most reliable" claim is **contradicted by working macros**. Production code routinely uses 2- and 3-digit labels: `GOTO51`, `GOTO107`, `GOTO111`, `GOTO202`, `GOTO401`, `GOTO711` ([macro_DA_without_relay_advanced.nc](example-macros/macro_DA_without_relay_advanced.nc), [macro_Thread_milling.nc](example-macros/macro_Thread_milling.nc)). Multi-digit labels work fine. If parser errors were observed, the cause was likely something else (space before label, or a different syntax issue) rather than the digit count.

**Most reliable (use these)**:
```gcode
N1, N2, N9                 // ✅ Single digit - best
N10, N99                   // ✅ Double digit - good
```

**Less reliable (use caution)**:
```gcode
N100, N990, N999           // ⚠️ Claimed unreliable; macros use these without issue
```

### Program Flow Pattern

**WRONG - Falls through into error handler**:
```gcode
; Main code
#1505=-5000(Success!)
M30                        // ❌ Program ends, but then...

; Error handler
N1
#1505=1(Error!)            // ❌ This executes even after success!
M30
```

**CORRECT - GOTO skips error handlers**:
```gcode
; Main code
#1505=-5000(Success!)
GOTO2                      // ✅ Jump to end label

; Error handler
N1
#1505=1(Error!)

; Program end
N2
M30
```

**Rule**: Success path must GOTO end label to skip error handlers

**See**: `conditional-syntax-card.md` for quick reference

---

## 8. Input Dialog Range Limit [CONFIRMED]

### The #2070 Bug

**#2070 input dialog can ONLY write to #50-#499 range**

**WRONG - Direct write to persistent**:
```gcode
#2070=1175(Enter probe speed...)  // ❌ Silent failure
; User types 400
; #1175 ends up with wrong value (1 or 50 or garbage)
```

**CORRECT - Two-step pattern**:
```gcode
; Step 1: Input to temporary variable
#2070=105(Enter probe speed...)   // ✅ #105 is in safe range
; Step 2: Copy to persistent storage
#1175=#105                        // ✅ Now #1175 has correct value
```

### What Works

**✅ Safe ranges for #2070**:
- #50-#499 (temporary variables)

**❌ Unsafe ranges (silent failures)**:
- #1153-#1193 (persistent storage)
- #2039-#2071 (persistent storage)
- #2500-#2599 (persistent storage)
- #500-#999 (parameter mirrors - don't use for storage anyway)

### Complete Example

```gcode
; Probe configuration macro
; CORRECT version using two-step pattern

; Input to temporary variables
#2070=100(Enter probe radius in mm - default is 2)
#2070=101(Enter max probe distance in mm - default is 50)
#2070=102(Enter fast speed mm/min - default is 400)

; Copy to persistent storage
#1170=#100    // Probe radius
#1171=#101    // Max distance
#1175=#102    // Fast speed

M30
```

**See**: `input-dialog-patterns.md` for all patterns

---

## Quick Command Reference

### Set Work Offset (Replace G10)

```gcode
; Set current position as G54 X0 Y0 Z0
#805 = #880
#806 = #881
#807 = #882
```

### Go to Machine Zero (Replace G28)

```gcode
#x = 0
#y = 0
#z = 0
G53 X#x Y#y Z#z
```

### Safe Persistent Variable Assignment

```gcode
; ALWAYS prime when assigning from #880+
#100 = #880
#1153 = #100
```

### Reliable Comparisons

```gcode
; Use C-style operators
IF #value == 100 GOTO1000
IF #count != 0 GOTO2000
IF #position < 50 GOTO3000
```

---

## Coordinate System Summary (Ultimate Bee 1010)

### Machine Coordinates (G53)

**True machine zero**:
- X=0, Y=0, Z=0 (at limit switches)

**Axis orientations**:
- X: 0 to +1000mm (positive)
- Y: 0 to **-735mm** (NEGATIVE)
- Z: 0 to **-150mm** (NEGATIVE)

### G28 Back-Off Positions

**NOT machine zero!**
- X: +5.0mm (5mm from switch)
- Y: -5.0mm (5mm from switch)
- Z: -5.0mm (5mm from switch)

### Work Coordinates (G54-G59)

**User-defined offsets**:
- Set via direct #805+ writes
- G10 is broken, don't use it
- 6 systems available (G54-G59)

---

## Three Numbering Systems

**Critical understanding**:

| System | Example | Where Used |
|--------|---------|------------|
| ENG File | #0, #129, #880 | .eng backup files |
| UI Display | Pr0, Pr129, Pr500 | Controller screen |
| Macro Address | #500, #629, #880 | **What you write** |

**Common pattern**: Pr[N] → #[N+500]

**Example**: Pr129 (probe thickness) → #629 in code

---

## Related Documentation

**For complete explanations**:
- `software-technical-spec.md` - Complete firmware quirks with examples
- `variable-priming-card.md` - All priming patterns
- `macrob-programming-rules.md` - MacroB syntax reference
- `system-control-variables.md` - Variable address map

**For working examples**:
- `example-macros/` - 25 production-tested macros
- `community-patterns-1-core.md` - Proven patterns
- `user-tested-patterns.md` - Ultimate Bee 1010 patterns

---

## Quick Validation Checklist

**Before running any macro**:

- [ ] No G10 commands (use #805+ instead) — *✅ confirmed: 0 G10 in 26 macros*
- [ ] G53 uses variables only (no hardcoded constants) — *✅ confirmed in user + factory code*
- [ ] G28 not used for machine zero (use G53 instead) — *✅ confirmed: 0 G28 in macros*
- [ ] Persistent vars primed from #880+ (use local var first) — *✅ confirmed in O_Save_*.nc*
- [ ] All comparisons use C-style (==, !=, <, >, <=, >=) — *✅ confirmed: 0 EQ/NE/LT/GT in macros*
- [ ] WCS addresses use stride 5 (not 20) — *✅ confirmed in macro_cam13.nc*
- [ ] ~~IF statements: no brackets on simple conditions~~ — ⚠ **disputed: every working macro brackets every IF; use brackets by default**
- [ ] GOTO statements: no space before label (GOTO1 not GOTO 1) — *✅ confirmed*
- [ ] ~~Labels: single or double digit preferred (N1-N99)~~ — ⚠ **disputed: macros routinely use 3-digit labels (GOTO107, GOTO401, GOTO711)**
- [ ] Success path uses GOTO to skip error handlers — *✅ confirmed pattern*
- [ ] #2070 inputs to #50-#499 only, then copy to persistent — *✅ confirmed*

---

## Document Status

**Type**: Quick reference - critical quirks only  
**Authority**: [CONFIRMED] V1.22 Production-tested  
**Last Updated**: January 2026

**For complete details with all examples and edge cases**, see full 571-line version or `software-technical-spec.md`.
