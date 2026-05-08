# DDCS M350 Input Dialog Patterns - #2070 Safe Usage

**Authority**: [CONFIRMED] Production-tested January 2026  
**Controller**: DDCS Expert M350 V1.22  
**Source**: Probe configuration macro debugging and firmware analysis

**Purpose**: Critical #2070 variable range limitation and safe usage patterns

---

## The Critical Bug

### Problem

**#2070 input dialog CANNOT write directly to persistent variables**

Persistent ranges affected:
- ❌ #1153-#1193 (user persistent storage)
- ❌ #2039-#2071 (user persistent storage)
- ❌ #2500-#2599 (user persistent storage)

**Symptom**: Dialog appears, user enters value, but write **fails silently** or writes to wrong location

---

## What Happens

### ❌ WRONG - Direct Write to Persistent

```gcode
; Trying to write directly to persistent #1175
#2070=1175(Enter fast probe speed in mm/min - default is 400)

; User types: 400
; Expected: #1175 = 400
; Reality: #1175 = 1 (or 50, or garbage value)
```

**Result**: 
- No error message
- Value ends up wrong (often 1, 50, or some default)
- Macro behavior fails later (e.g., probe crawls at 1 mm/min instead of 400)

**Root cause**: #2070 can ONLY write to #50-#499 (temporary variable range)

---

## The Fix - Two-Step Pattern

### ✅ CORRECT - Input to Temp, Copy to Persistent

```gcode
; Step 1: Input to TEMPORARY variable (#50-#499)
#2070=105(Enter fast probe speed in mm/min - default is 400)

; Step 2: Copy to PERSISTENT storage
#1175=#105

; Now #1175 correctly contains the user's input
```

**Why this works**:
- #105 is in #50-#499 range (safe for #2070)
- #2070 successfully writes to #105
- Manual assignment transfers value to persistent #1175
- No data loss, no silent failures

---

## Variable Range Rules

### ✅ #2070 CAN Write To (Safe)

```gcode
#50-#499                       ; Temporary variables - ALWAYS use these
```

### ❌ #2070 CANNOT Write To (Unsafe)

```gcode
#0-#49                         ; Too low - may work but not recommended
#500-#999                      ; Parameter mirrors - dangerous!
#1153-#1193                    ; Persistent user storage - silent failure
#2039-#2071                    ; Persistent user storage - silent failure  
#2500-#2599                    ; Persistent user storage - silent failure
```

**Rule**: Always use #50-#499 as #2070 target, then copy to final destination

---

## Complete Working Example

### Probe Configuration Setup (CORRECT)

```gcode
O9000 (Probe Configuration Setup)
(Sets all probe persistent variables #1170-#1176)
(DDCS M350 V1.22 - Fixed for #2070 range limits)

;=== PROBE GEOMETRY ===
#2070=100(Enter probe radius in mm - default is 2)
#1170=#100                     ; Copy to persistent

;=== PROBE SAFETY & LIMITS ===
#2070=101(Enter max probe distance in mm - default is 50)
#1171=#101                     ; Copy to persistent

#2070=102(Enter start offset in mm - default is 5)
#1172=#102                     ; Copy to persistent

;=== PROBE Z HEIGHTS ===
#2070=103(Enter safe Z height above surface in mm - default is 10)
#1173=#103                     ; Copy to persistent

#2070=104(Enter probe depth BELOW surface in mm - default is 5)
#1174=-#104                    ; Copy to persistent (store as negative)

;=== PROBE SPEEDS ===
#2070=105(Enter fast probe speed in mm/min - default is 400)
#1175=#105                     ; Copy to persistent

#2070=106(Enter slow probe speed in mm/min - default is 20)
#1176=#106                     ; Copy to persistent

#1505=-5000(Probe configuration saved!)
M30
```

**Key points**:
- All inputs go to #100-#106 (temporary, #2070-safe range)
- Each input immediately copied to persistent #1170-#1176
- User must TYPE values - pressing Enter alone doesn't use "default" text in prompt
- No silent failures

---

## Usage Pattern Template

### For Single Persistent Variable

```gcode
; Template for any #2070 → persistent variable operation

; Step 1: Choose temp var in #50-#499 range
#temp_var_number = 100         ; Or 50, 75, 200, etc. (avoid already-used)

; Step 2: Input to temp
#2070=#temp_var_number(Enter your value here...)

; Step 3: Copy to persistent destination
#your_persistent_var = #temp_var_number

; Step 4: Optionally confirm
#1510 = #your_persistent_var
#1505 = -5000(Value saved: [%.1f])
```

### For Multiple Related Variables

```gcode
; Collect multiple configuration parameters

; Use sequential temp vars for clarity
#2070=100(Enter parameter 1...)
#2070=101(Enter parameter 2...)
#2070=102(Enter parameter 3...)

; Copy all to persistent storage
#1180=#100                     ; Persistent param 1
#1181=#101                     ; Persistent param 2
#1182=#102                     ; Persistent param 3

; Validate if needed
IF #1180<=0 GOTO1
IF #1181<=0 GOTO1
IF #1182<=0 GOTO1

; Success
#1505=-5000(Configuration saved!)
GOTO2

; Error
N1
#1505=1(ERROR: Invalid values entered!)

N2
M30
```

---

## Diagnostic Macro

### Check for Corrupted Persistent Values

```gcode
O9999 (Diagnostic - Check Probe Config)

; Check fast probe speed
#1510=#1175
#1505=-5000(Fast probe speed: [%.1f] mm/min)
G04 P2000

; Check slow probe speed
#1510=#1176
#1505=-5000(Slow probe speed: [%.1f] mm/min)
G04 P2000

; Check probe radius
#1510=#1170
#1505=-5000(Probe radius: [%.1f] mm)

M30
```

**Expected results**:
- Fast speed: ~400 mm/min
- Slow speed: ~20 mm/min
- Probe radius: ~2 mm

**If corrupted**:
- Values show 1, 50, or other wrong values
- Re-run configuration with corrected two-step pattern

---

## Why This Bug Wasn't Obvious

1. **Documentation mentions #50-#499 but doesn't emphasize it's a HARD LIMIT**
   - Found in ddcs-display-methods-2-advanced.md: "Storage range: Values entered are stored in #50-#499"
   - Reads like a note, not a critical restriction

2. **No error message**
   - Controller doesn't reject the command
   - Dialog appears and accepts input normally
   - Write just fails silently

3. **Values end up "somewhere"**
   - Not undefined or zero
   - Shows wrong value (1, 50, or defaults)
   - Looks like successful write at first glance

4. **Prompt text is misleading**
   - Text says "default is 400"
   - Makes you think pressing Enter will use 400
   - Actually, you MUST type values - Enter alone gives garbage

---

## Related Issue: Parameter Mirrors

### #500-#999 Are Parameter Mirrors

**Formula**: `#[500+N] = Pr[N]`

**Examples**:
```gcode
#500 = Pr0                     ; Motor Start Speed
#561 = Pr61                    ; Default operation speed
#629 = Pr129                   ; Probe thickness
```

**Don't use #500-#999 for ANY purpose**:
- They map to system parameters
- Changes require controller reboot
- Not suitable for temporary storage
- Conflicts with parameter system

**See**: `user-storage-map.md` for complete variable range documentation

---

## Summary Table

| Issue | Problem | Solution |
|-------|---------|----------|
| **#2070 → Persistent** | Cannot write to #1153+, #2039+, #2500+ | Use temp (#50-#499) then copy |
| **#500-#999** | Parameter mirrors (Pr0-Pr499) | Never use for storage |
| **"Default" text** | Doesn't auto-fill on Enter | Always type values manually |
| **Silent failure** | No error when write fails | Always use two-step pattern |

---

## Best Practices

### 1. Always Use Two-Step Pattern

```gcode
✅ DO THIS:
#2070=100(Prompt...)
#persistent=#100

❌ NOT THIS:
#2070=1175(Prompt...)
```

### 2. Use Sequential Temp Variables for Related Inputs

```gcode
✅ CLEAR:
#2070=100(Width...)
#2070=101(Height...)
#2070=102(Depth...)

❌ CONFUSING:
#2070=73(Width...)
#2070=247(Height...)
#2070=88(Depth...)
```

### 3. Validate Inputs Immediately After Collection

```gcode
✅ SAFE:
#2070=100(Enter speed...)
#speed=#100
IF #speed<=0 GOTO error
IF #speed>1000 GOTO error

❌ UNSAFE:
#2070=100(Enter speed...)
#speed=#100
; ... use directly without validation
```

### 4. Confirm Critical Values

```gcode
✅ USER-FRIENDLY:
#2070=100(Enter probe radius in mm...)
#1170=#100

#1510=#1170
#1505=-5000(Probe radius set to: [%.2f] mm)

❌ SILENT:
#2070=100(Enter probe radius in mm...)
#1170=#100
; No confirmation
```

---

## Example: Before/After Fix

### ❌ BEFORE (Buggy Version)

```gcode
O9000 (Probe Config - BROKEN)

;=== PROBE SPEEDS ===
#2070=1175(Enter fast probe speed in mm/min - default is 400)
#2070=1176(Enter slow probe speed in mm/min - default is 20)

M30
```

**Problem**:
- User runs, types 400 and 20
- Later, fence_finder macro runs at 1 mm/min
- Checking #1175 shows value is 1, not 400
- Silent failure - no error shown

### ✅ AFTER (Fixed Version)

```gcode
O9000 (Probe Config - FIXED)

;=== PROBE SPEEDS ===
; Step 1: Input to temporary variables
#2070=105(Enter fast probe speed in mm/min - default is 400)
#2070=106(Enter slow probe speed in mm/min - default is 20)

; Step 2: Copy to persistent storage
#1175=#105
#1176=#106

; Step 3: Confirm (optional but recommended)
#1510=#1175
#1511=#1176
#1505=-5000(Speeds saved: Fast=[%.0f] Slow=[%.0f] mm/min)

M30
```

**Result**:
- User runs, types 400 and 20
- Values correctly stored in #1175 and #1176
- fence_finder macro runs at correct 400 mm/min
- Confirmation message shows correct values

---

## Testing Your Macros

### Quick Test for #2070 Issues

1. **Check your macro for direct persistent writes**:
   ```gcode
   # Search for patterns like:
   #2070=1xxx(...)             ; ❌ Direct to #1153-#1193
   #2070=2xxx(...)             ; ❌ Direct to #2039-#2071
   #2070=25xx(...)             ; ❌ Direct to #2500-#2599
   ```

2. **Run diagnostic macro after configuration**:
   ```gcode
   O9999 (Check Values)
   #1510=#your_persistent_var
   #1505=-5000(Value: [%.1f])
   M30
   ```

3. **Compare expected vs actual**:
   - If you entered 400, you should see 400
   - If you see 1, 50, or wrong value → two-step pattern needed

---

## Related Documentation

**For more details**:
- `ddcs-display-methods-2-advanced.md` - Complete #2070 documentation
- `user-storage-map.md` - Persistent variable ranges
- `CORE_TRUTH.md` - Section 8 (#2070 limitation)
- `software-technical-spec.md` - Variable addressing system

**Working examples**:
- `example-macros/READ_VAR.nc` - Uses #2070 correctly with temp vars

---

## Document Status

**Type**: Critical bug documentation and workaround  
**Authority**: [CONFIRMED] Production-tested  
**Testing**: Probe configuration macro failure and fix verification  
**Date**: January 2026  
**Controller**: DDCS Expert M350 V1.22

**Bottom line**: #2070 is only safe with #50-#499. For persistent storage, always use two-step pattern.
