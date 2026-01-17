# DDCS M350 Display & Feedback Methods

## Overview

The DDCS M350 has several operator feedback options, though they differ from industrial FANUC controllers. The primary display methods use:
- **#1505** - Dialog/popup messages at bottom of screen
- **#1503** - Status bar display (persistent on-screen display)

-----

## Method 1: Status Bar Display (#1503)

**Discovered by Michel Faust** - Display persistent text in the status bar with variable values.

**Status bar characteristics:**
- Always visible on screen (not a popup)
- Displays alongside system status information
- Message number = offset + 3000 (e.g., message 1 displays as "3001")
- Uses same format codes as #1505
- Can display up to 4 variables simultaneously (#1510-#1513)
- **Maximum 68 characters** per message
- Green text display at bottom of controller screen

**Basic syntax:**
```gcode
#1510 = 80     ; Value 1
#1511 = 70     ; Value 2  
#1512 = 60     ; Value 3

#1503 = 1(X=%.0f%%   Y=%.0f%%   Z=%.0f%%)
```

**Result**: Status bar shows "X=80%   Y=70%   Z=70%" with message number "3001"

### Format Codes in Status Bar

Same as #1505 dialog messages:
- `%.0f` - Integer (no decimals)
- `%.1f` - 1 decimal place
- `%.2f` - 2 decimal places
- `%.3f` - 3 decimal places

### Percent Sign Handling (CRITICAL)

**To display a literal "%" sign, use "%%":**

```gcode
#1503 = 1(Progress: %.0f%%)    ; Shows "Progress: 85%"
#1503 = 1(X=%.0f% Y=%.0f%)     ; WRONG - system may misinterpret
#1503 = 1(X=%.0f%% Y=%.0f%%)   ; CORRECT - double %% for literal %
```

**Why**: Single `%` can be misinterpreted by the system as a format code prefix.

### Message Number Offset

**#1503 uses offset 3000:**
```gcode
#1503 = 1(...)     ; Displays as message "3001" (1 + 3000)
#1503 = 5(...)     ; Displays as message "3005" (5 + 3000)
#1503 = 100(...)   ; Displays as message "3100" (100 + 3000)
```

### Practical Examples

**Example 1: Spindle load percentage**
```gcode
#1510 = #879       ; Current spindle load
#1503 = 1(Spindle Load: %.0f%%)
```

**Example 2: XYZ coordinates**
```gcode
#1510 = #880       ; Machine X
#1511 = #881       ; Machine Y
#1512 = #882       ; Machine Z
#1503 = 1(X=%.3f   Y=%.3f   Z=%.3f)
```

**Example 3: Progress indicator**
```gcode
#100 = 0
#100 = 42          ; Current operation number
#101 = 100         ; Total operations
#1510 = #100
#1511 = #101
#1503 = 2(Progress: %.0f/%.0f operations)
```

**Example 4: Mixed text and values**
```gcode
#1510 = 12000      ; Spindle RPM
#1511 = 850        ; Feedrate
#1503 = 1(S%.0f RPM   F%.0f mm/min)
```

### #1503 vs #1505 Comparison

| Feature | #1503 (Status Bar) | #1505 (Dialog) |
|---------|-------------------|----------------|
| Location | Status bar (persistent) | Bottom popup |
| Duration | Until cleared/updated | Until dismissed |
| Interaction | Display only | Can wait for user input |
| Use case | Ongoing status | Confirmations, alerts |
| Message offset | +3000 | None |

### Clearing Status Bar

**To clear the status bar display:**
```gcode
#1503 = 0(  )      ; Clear with empty message
```

Or update with new message:
```gcode
#1503 = 1(New status message)
```

---

## Method 2: Dialog Messages (#1505)

Display popup messages at the bottom of the screen.

**Basic Message (no user input):**

```gcode
#1505 = -5000(Operation complete!)
```

**Confirmation Dialog (with user choice):**

```gcode
#1505 = 1(Continue? ESC=Cancel ENTER=OK)
IF #1505 == 0 GOTO abort
```

**Binary Choice Dialog (ENTER vs ESC):**

```gcode
#1505 = 3(Move Right[Enter] or Left[Esc]?)
IF #1505 = 0 GOTO 1   ; ESC pressed
G01 X10 F200          ; ENTER pressed
GOTO 2
N1
G01 X-10 F200         ; ESC pressed
N2
```

|#1505 Value|Behavior                             |
|-----------|-------------------------------------|
|`-5000`    |Display message only (no buttons)    |
|`1`        |Prompt with OK/Cancel, returns 0 or 1|
|`2`        |Prompt with Confirm/Exit buttons     |
|`3`        |Binary choice (ENTER or ESC), returns 0 (ESC) or 1 (ENTER)|

**Display Variable Values (#1510-#1513):**

```gcode
#1510 = 0           ; Prime first!
#1510 = #880        ; Load X machine position
#1505 = 1(X Position: [%.3f])
```

**CRITICAL SYNTAX NOTE:** Format codes use **square brackets** `[%.3f]` not just `%.3f`

Format codes:

- `[%.0f]` = no decimals
- `[%.1f]` = 1 decimal
- `[%.2f]` = 2 decimals
- `[%.3f]` = 3 decimals

**Multiple Values:**

```gcode
#1510 = 0
#1511 = 0
#1512 = 0
#1510 = #880        ; X
#1511 = #881        ; Y
#1512 = #882        ; Z
#1505 = 2(Position: X=[%.3f] Y=[%.3f] Z=[%.3f])
```

**Working example from Current_error.nc:**

```gcode
#1510=#2111
#1511=#2112
#1512=#2113
#1513=#2114
#1505=-5000(Axis1[%.3f]mm Axis2[%.3f]mm Axis3[%.3f]mm Axis4[%.3f]mm)
```

> ⚠️ **Warning:** Format codes can be fragile on some firmware versions. However, the community macros demonstrate they work reliably when:
> 
> 1. Variables are NOT primed (directly assigned system variables)
> 1. Square bracket syntax `[%.3f]` is used consistently
> 1. Example from Current_error.nc shows stable 4-value display without priming

**Priming paradox discovered:** Format codes may work MORE reliably WITHOUT the priming step that’s required for normal variable writes. Test both approaches on your firmware.

-----

## Method 2: User Input (#2070)

Prompt operator to enter a value (2024+ firmware).

```gcode
#2070 = 500(Enter probe diameter: )
; User types value, stored in #500
```

The number after `=` specifies which variable receives the input.

**Example from READ_VAR.nc - Dynamic variable inspector:**

```gcode
#2070 = 100(Enter variable # to read:)
#1510 = #100           ; The variable number entered
#1511 = #[#100]        ; Indirect addressing - read the value
#1505 = -5000(#[%.0f] = [%.3f])
```

**Indirect addressing:** `#[#100]` reads the contents of variable #100, then uses that value as an address. If user enters “880”, it reads `#[#880]` (machine X position).

-----

## Method 3: M0 Program Stop

Halts execution until operator presses START.

```gcode
G0 Z10               ; Retract
M0                   ; STOP - "PAUSE" appears on screen
; Operator reviews, presses START to continue
```

**Behavior:** Controller shows “PAUSE” status, Z lifts if configured (#70, #90).

-----

## Method 3A: G4 P-1 Interactive Pause (Community Discovery)

**Undocumented feature:** `G4 P-1` creates an interactive pause with on-screen instructions.

```gcode
G4P-1
G1
;Move Z to table
;and press START
#1577=#882  ; Capture position after START pressed
```

**How it works:**

- `G4P-1` pauses execution
- Comments immediately following appear on screen as instructions
- Operator performs manual action (jog axes, position tool, etc.)
- Press START to continue
- Next line executes and can capture position

**Practical use:** Manual positioning steps within automated macros (touch-off, alignment, visual inspection).

**Discovery source:** `Table_leveling.nc` community macro

-----

## Method 4: Buzzer Feedback

Audible confirmation (requires #241 = Yes).

```gcode
M30    ; End program - 3 beeps
M0     ; Pause - single beep
```

**Limitation:** No programmable beep command—only triggered by M0/M30.

-----

## Method 5: Output Port Signals

Control external indicators (lights, buzzers) via M-codes.

```gcode
M68                  ; OUT10 ON
G4 P0.5              ; Dwell 0.5 sec
M69                  ; OUT10 OFF
```

**Output M-Codes:**

|Output|ON |OFF|
|------|---|---|
|OUT01 |M50|M51|
|OUT02 |M52|M53|
|OUT10 |M68|M69|
|OUT21 |M90|M91|

-----

## Method 6: Write to Coordinate Display

Make values visible by writing to work coordinate offsets.

```gcode
; Store measurement in G59 for operator to view
#830 = #102          ; Write to G59 X offset
; Operator can view in Coord Set menu
```

-----

## Method 7: Persistent Variables for Later Review

Store values in persistent range for post-job inspection.

```gcode
#1153 = 0            ; Prime first!
#1153 = #882         ; Save Z probe result
; Operator can check #1153 in Param page later
```

-----

## What’s NOT Available

|Feature            |Status             |
|-------------------|-------------------|
|MSG[] (FANUC style)|❌ Use #1505 instead|
|#3000 alarms       |❌ Not supported    |
|#3006 messages     |❌ Not supported    |
|DPRNT[]            |❌ Not supported    |
|Console output     |❌ Not supported    |

-----

## Practical Patterns

**Success Confirmation:**

```gcode
#1505 = -5000(Probe complete - offset saved!)
```

**User Decision Point:**

```gcode
#1505 = 1(Ready to cut? ENTER=Go ESC=Abort)
IF #1505 == 0 GOTO 999
; Continue with cut...
N999 M30
```

**Display Measured Value:**

```gcode
#1510 = 0
#1510 = #1922        ; Probe Z result
#1505 = -5000(Probed Z: [%.3f])
```

**Multi-step Progress Display (from PERSISTENCE_READ.nc):**

```gcode
#1505 = 1(Checking persistence...)

; Test range #56-#499
#1510 = #56
#1511 = #250
#1512 = #499
#1505 = -5000(#56-499: [%.2f]  [%.2f]  [%.2f])

; Test range #1153-#1193
#1510 = #1153
#1511 = #1175
#1512 = #1193
#1505 = -5000(#1153-93: [%.2f]  [%.2f]  [%.2f])

; Continue testing other ranges...
#1505 = -5000(TEST COMPLETE - 0.00 means NOT persistent)
```

**Pattern:** Sequential display updates show progress through multi-step operations without requiring user interaction between steps.

**External Light Flash for Success:**

```gcode
M68                  ; Light ON
G4 P0.5
M69                  ; Light OFF
M68
G4 P0.5
M69                  ; Double-flash = success
```

-----

## Important Notes

1. **Format code syntax:** Use square brackets `[%.3f]` not bare `%.3f`
1. **Priming paradox:** Format displays may work WITHOUT priming (see Current_error.nc)
1. **Indirect addressing works:** `#[#var]` pattern proven in READ_VAR.nc
1. **G4P-1 interactive pause** enables manual steps within macros
1. **#1505 = -5000** displays message only (no response needed)
1. **#1505 = 1 or 2** waits for operator response
1. Comments inside dialog strings work: `#1505 = 1(message)`
1. **Sequential displays** update operator on multi-step progress

**Firmware variance:** These patterns are from working community macros (2022-2024 firmware). Test on your specific firmware version.

-----

## Summary

Your main display tools are:

- **#1505** for popup messages and confirmations
- **#2070** for user input (newer firmware) with indirect addressing
- **M0** for program pauses
- **G4P-1** for interactive manual steps (undocumented but proven)
- **Output ports** for external lights/buzzers
- **Persistent variables** for post-job data review

**Key discovery:** Format codes `[%.3f]` work reliably when syntax is correct, even with multiple values displayed simultaneously.

## Reference Macros

Working examples demonstrating these patterns:

- **Current_error.nc** - Multi-value display without priming
- **READ_VAR.nc** - User input + indirect addressing + formatted output
- **PERSISTENCE_READ.nc** - Sequential progress displays
- **Table_leveling.nc** - G4P-1 interactive pause
- **macro_cam10.nc, macro-cam12.nc** - Simple success/error messages
---

## Method 3: Audio Feedback (#2042)

**Beep/buzzer sound control** - Audio feedback for operator alerts and confirmations.

**Duration**: Value in **milliseconds**

**Basic syntax:**
```gcode
#2042 = 500    ; Beep for 500 milliseconds (0.5 seconds)
```

**Example - Confirmation beep:**
```gcode
#1153 = #880     ; Save position
#1154 = #881
#2042 = 500      ; Beep for 0.5 seconds to confirm
#1505 = -5000(Position saved!)
```

**Example - Pre-alert beep:**
```gcode
#2042 = 1000     ; Long beep (1 second warning)
#1505 = 1(Tool change required - Press ENTER when ready)
```

**Example - Multi-step feedback:**
```gcode
#2042 = 100      ; Short beep (0.1 seconds)
#1503 = 1(Step 1 complete)
G04 P1000

#2042 = 100      ; Short beep (0.1 seconds)
#1503 = 1(Step 2 complete)
G04 P1000

#2042 = 800      ; Long beep (0.8 seconds)
#1503 = 1(All steps complete!)
```

### Duration Guidelines

**Value = milliseconds of beep duration**

```gcode
#2042 = 100      ; Quick tap (0.1 sec) - routine confirmation
#2042 = 300      ; Short beep (0.3 sec) - step complete
#2042 = 500      ; Medium beep (0.5 sec) - save/load operation
#2042 = 1000     ; Long beep (1.0 sec) - important event
#2042 = 1500     ; Very long (1.5 sec) - warning/error
#2042 = 0        ; Silent (no beep)
```

**Recommended durations:**
- **50-150ms**: Quick acknowledgment taps
- **300-500ms**: Standard confirmations
- **800-1200ms**: Important events
- **1500-2000ms**: Warnings and errors
- **>2000ms**: Avoid (annoying to operator)

### Use Cases

**Operation confirmation:**
```gcode
; Save park position with short beep
#1153 = #880
#1154 = #881
#2042 = 300      ; Quick confirmation (0.3 seconds)
#1505 = -5000(Park position saved)
```

**Error alerts:**
```gcode
; Probe contact failure with long warning beep
IF #probe_failed EQ 1 GOTO error
; ... normal operation ...
GOTO done

N error
#2042 = 1500     ; Long alert beep (1.5 seconds)
#1505 = 1(ERROR: Probe contact failed!)
M30

N done
```

**Multi-step progress:**
```gcode
#2042 = 200      ; Quick beep (0.2 sec)
#1503 = 1(Homing X...)
M98 P1001

#2042 = 200      ; Quick beep (0.2 sec)
#1503 = 1(Homing Y...)
M98 P1002

#2042 = 500      ; Success beep (0.5 sec)
#1503 = 1(Homing complete!)
```

**Attention grabber:**
```gcode
; Before critical operation - series of beeps
#2042 = 300
G04 P0.5
#2042 = 300
G04 P0.5
#2042 = 800      ; Final longer beep
#1505 = 1(WARNING: Spindle about to start!)
G04 P2000
M03 S12000
```

**Countdown warning:**
```gcode
; 3-2-1 countdown with beeps
#1505 = -5000(Starting in 3...)
#2042 = 200
G04 P1000

#1505 = -5000(Starting in 2...)
#2042 = 200
G04 P1000

#1505 = -5000(Starting in 1...)
#2042 = 200
G04 P1000

#2042 = 500      ; Start beep
#1503 = 1(Operation started!)
```
