# DDCS M350 Conditional Syntax - Quick Reference

**Authority**: [CONFIRMED] Production-tested January 2026  
**Controller**: DDCS Expert M350 V1.22  
**Source**: Parser error debugging and working macro verification

**Purpose**: Critical syntax rules for IF/GOTO/label statements discovered through production testing

> **⚠️ Evidence note (cross-checked against .nc macros, 2026-05-07):** Several rules below conflict with what production macros actually do. Specifically: (1) the "NEVER brackets on simple conditions" rule has zero supporting evidence — every working macro brackets every IF condition; (2) "single-digit labels most reliable" is contradicted by macros using `GOTO51`/`GOTO107`/`GOTO711` routinely. The bare/single-digit forms may work (user observed), but the bracketed/multi-digit forms are what the firmware authors and community macro writers consistently use. Annotations added inline below.

---

## IF Statement Syntax

### ✅ CORRECT - Simple Conditions

> **Evidence note:** No production macro uses this bare form. All real-world IFs are bracketed. Treat the bare form as user-tested but unverified by community/factory code.

```gcode
IF #1922!=2 GOTO1              ; No brackets around simple condition (claimed; no macro evidence)
IF #var==5 GOTO2               ; No brackets, no space in GOTO
IF #100<50 GOTO99              ; C-style operators
IF #temp>=0 GOTO1              ; Greater-than-or-equal
```

### ❌ WRONG - Common Errors

```gcode
IF [#1922!=2] GOTO1            ; ❌ Claimed wrong — but this is exactly the form every working macro uses
IF #1922 != 2 GOTO 1           ; ❌ No spaces around operators or before label
IF [#1922!=2]GOTO990           ; ❌ No brackets, label too high
IF #1922 NE 2 GOTO1            ; ❌ Must use != not NE (FANUC-style) — confirmed: 0 EQ/NE in macros
```

### ✅ CORRECT - Complex Expressions

```gcode
IF [#100+#200]>50 GOTO2        ; Brackets for arithmetic
IF [#a*#b]!=0 GOTO1            ; Brackets for multiplication
IF [#x+5]<[#y-3] GOTO3         ; Brackets for both sides
IF [#a==1]+[#b==1] GOTO5       ; Compound OR — `+` between bracketed conditions
IF [#a==1]*[#b==1] GOTO5       ; Compound AND — `*` between bracketed conditions
```

**Rule (revised against evidence)**: Brackets are required for arithmetic and compound logic. They are *also* used by every production macro for "simple" conditions. Use them by default — the bracket-less form is claimed to work but unsupported by any working code.

---

## GOTO Statement Syntax

### ✅ CORRECT

```gcode
GOTO1                          ; No space before label
GOTO2                          ; Single digit label
GOTO99                         ; Double digit label
GOTO999                        ; Three digit (use with caution)
```

### ❌ WRONG

```gcode
GOTO 1                         ; ❌ No space allowed
GO TO1                         ; ❌ GOTO is one word
GOTO1 ; comment                ; ⚠️ Comments OK but may cause issues
```

**Rule**: Format is `GOTOxxx` where xxx is label number - no spaces allowed

---

## Label Numbers

> **⚠️ Evidence note (2026-05-07):** Macros routinely use multi-digit labels without issue: `GOTO51`, `GOTO107`, `GOTO111`, `GOTO202`, `GOTO401`, `GOTO711`. The "single digit most reliable" claim is **not supported** by working macro evidence. If high-label parser errors were observed, the cause was likely something else (space before label, missing matching N-label, etc.). Use whatever label number makes your code clear.

### ✅ MOST RELIABLE (Preferred)

```gcode
N1                             ; Single digit - claimed best, but macros prove multi-digit works
N2
N9
```

### ✅ ACCEPTABLE

```gcode
N10                            ; Double digit - also works
N50
N99
```

### ⚠️ USE CAUTION (claim disputed by evidence)

```gcode
N100                           ; Macros use these without issue
N990                           ; Macros use these without issue
N999                           ; Macros use these without issue
```

**Rule (revised against evidence)**: Any label number works. Use what makes your control flow readable. Original "single digits most reliable" claim is unproven.

**Parser errors observed with high labels**:
```
[N]was not found:L124[GOTO999]
```

---

## Program Flow Pattern

### ✅ CORRECT - Success Jumps to End

```gcode
O1000 (Correct Flow Pattern)

; Main code
G91 G31 Z-50 F200 P3 L0 Q0
IF #1922!=2 GOTO1              ; Error: jump to handler

; Success path
#1505=-5000(Success!)
GOTO2                          ; Jump to end (skip error handlers)

; Error handler
N1
#1505=1(Failed!)

; Program end
N2
M30
```

**Critical**: Success path MUST use GOTO to jump past error handlers to end label

### ❌ WRONG - Fall Through to Error

```gcode
O1000 (Wrong - No Jump)

; Main code
G91 G31 Z-50 F200 P3 L0 Q0
IF #1922!=2 GOTO1

; Success path
#1505=-5000(Success!)
; ❌ Program "falls through" into error handler!

; Error handler
N1                             ; Executes even after success
#1505=1(Failed!)

M30
```

**Problem**: After success, execution continues into N1 error handler

---

## Complete Working Example

**From macro_cam10.nc (verified working)**:

```gcode
O1000 (Front-Left Corner Finder)

; Configuration
#30=3                          ; Probe input (IN03)
#31=0                          ; Skip distance

; Probe X-axis
G91 G31 X50 F200 P#30 L#31 Q0
IF #1921==1 GOTO1              ; ✅ No brackets, no space
#100=#1925                     ; Save X position

; Probe Y-axis  
G91 G31 Y50 F200 P#30 L#31 Q0
IF #1921==1 GOTO1              ; ✅ Consistent pattern
#101=#1926                     ; Save Y position

; Success
#1505=-5000(Corner found!)
GOTO2                          ; ✅ Jump to end

; Error handler
N1                             ; ✅ Single digit label
#1505=1(Probe failed!)

; Program end
N2                             ; ✅ Single digit label
M30
```

**Verified syntax**:
- IF conditions: `IF #var==value GOTOlabel` (no brackets, no spaces)
- GOTO statements: `GOTOx` (no space)
- Labels: `N1`, `N2` (single digits)
- Flow: success uses GOTO2 to skip N1 error handler

---

## Operator Reference

### ✅ CORRECT - C-Style Operators

```gcode
IF #var==5 GOTO1               ; Equal to
IF #var!=5 GOTO1               ; Not equal to
IF #var<5 GOTO1                ; Less than
IF #var>5 GOTO1                ; Greater than
IF #var<=5 GOTO1               ; Less than or equal
IF #var>=5 GOTO1               ; Greater than or equal
```

### ❌ WRONG - FANUC-Style Operators

```gcode
IF #var EQ 5 GOTO1             ; ❌ Use == not EQ
IF #var NE 5 GOTO1             ; ❌ Use != not NE
IF #var LT 5 GOTO1             ; ❌ Use < not LT
IF #var GT 5 GOTO1             ; ❌ Use > not GT
IF #var LE 5 GOTO1             ; ❌ Use <= not LE
IF #var GE 5 GOTO1             ; ❌ Use >= not GE
```

**See**: `software-technical-spec.md` §3.4 for complete operator documentation

---

## Testing Checklist

**Before running any macro with conditionals**:

```
Syntax Check:
[ ] IF statements: No brackets on simple conditions
[ ] IF statements: Format is `IF #var!=value GOTOlabel`
[ ] GOTO statements: No space (GOTOx not GOTO x)
[ ] Labels: Single or double digit (N1-N99)
[ ] Success path: Uses GOTO to jump to end
[ ] End structure: success+GOTO → errors → end label → M30
[ ] Operators: C-style (== != < >) not FANUC (EQ NE LT GT)
[ ] No spaces around operators in IF statements
```

---

## Common Parser Errors

### Error: "syntax error!:L34[#temp=#34]"

**Cause**: Brackets around simple IF condition

**Fix**:
```gcode
; Wrong
IF [#1922!=2] GOTO990

; Correct
IF #1922!=2 GOTO1
```

### Error: "[N]was not found:L69[IF #1920==1 GOTO 991]"

**Cause**: Space before label number OR label number too high

**Fix**:
```gcode
; Wrong
IF #1920==1 GOTO 991

; Correct
IF #1920==1 GOTO1
```

### Error: "[N]was not found:L124[GOTO999]"

**Cause**: Three-digit label number less reliable

**Fix**:
```gcode
; Less reliable
GOTO999

; More reliable
GOTO2
```

---

## Summary Rules

1. **IF brackets**: Don't use on simple conditions (`#var!=value`)
2. **GOTO spacing**: No space before label (`GOTO1` not `GOTO 1`)
3. **Label numbers**: Single digits preferred (N1-N9 most reliable)
4. **Program flow**: Success must GOTO end to skip error handlers
5. **Operators**: C-style only (== != < > not EQ NE LT GT)

**Pattern verified**: macro_cam10.nc, macro_cam11.nc, macro_cam12.nc, macro_cam13.nc

---

## Related Documentation

**For more details**:
- `CORE_TRUTH.md` - Section 7 (Control Flow)
- `software-technical-spec.md` - §3.4 (Operators), §3.6 (Conditional Quirks)
- `macrob-programming-rules.md` - Complete syntax reference
- `example-macros/macro_cam10.nc` - Working example

---

## Document Status

**Type**: Quick reference card  
**Authority**: [CONFIRMED] Production-tested  
**Testing**: Multiple iterations with parser and runtime verification  
**Date**: January 2026  
**Controller**: DDCS Expert M350 V1.22
