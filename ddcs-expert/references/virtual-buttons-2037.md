# Virtual Button Control via #2037

Official M350 documentation for programmatic control of controller interface buttons and actions through macro variable #2037.

## Overview

**Purpose**: Allows G-code macros to simulate button presses on the controller interface, enabling automated workflows and operator interaction patterns.

**Macro Variable**: `#2037` - Virtual button/key press control

**Official Documentation**: `Virtual_button_function__2037_.pdf`

## How #2037 Works

**Format**: 
```
#2037 = (Press Status × 2^16) + (Key Value - 1000)
```

**Bit structure**:
- **Bit 0-15**: Key value (Table value - 1000)
- **Bit 16**: Press status (0=Release, 1=Press)

**Calculation formula**:
```
#2037 = (1 × 65536) + (Table_Key_Value - 1000)
```

Where:
- `1` = Press (use 0 for release, though rarely needed)
- `65536` = 2^16
- `Table_Key_Value` = The key number from official table below
- `1000` = Offset to subtract from table value

## Official Key Value Table

### Operation Interface Navigation

| Key Value | Function | Usage |
|-----------|----------|-------|
| 1373 | Monitor | Switch to Monitor screen |
| 1374 | Program | Switch to Program screen |
| 1375 | Param | Switch to Parameter screen |
| 1376 | IO | Switch to I/O screen |
| 1377 | System Log | Switch to System Log screen |
| 1378 | System Info | Switch to System Info screen |
| 1323 | Probe | Switch to Probe screen |
| 1321 | Go Work Zero | Navigate to Work Zero screen |
| 1322 | Go Home | Navigate to Home screen |
| 1320 | Clear | Clear/Reset screen action |
| 1387 | Coord Set | Switch to Coordinate Set screen |
| 1389 | Local Disk | Switch to Local Disk browser |
| 1390 | U Disk | Switch to USB Disk browser |
| 1363 | Break | Break/Stop operation |
| 1326 | Manual | Switch to Manual mode |
| 1348 | MDI | Switch to MDI mode |

### Functional Actions

| Key Value | Function | Usage |
|-----------|----------|-------|
| 1008 | Backspace | Delete character |
| 1013 | Enter | Confirm/Execute |
| 1016 | Left | Navigate left |
| 1017 | Up | Navigate up |
| 1018 | Right | Navigate right |
| 1019 | Down | Navigate down |
| 1025 | SHIFT | Shift modifier |
| 1027 | Esc | Escape/Cancel |
| 1331 | Spindle ON/OFF | Toggle spindle |
| 1327 | Reset | Controller reset |
| 1328 | Start | Start program/motion |
| 1329 | Pause | Pause program/motion |

### Manual Jogging

| Key Value | Function | Usage |
|-----------|----------|-------|
| 1350 | X+ | Jog X positive |
| 1351 | X- | Jog X negative |
| 1352 | Y+ | Jog Y positive |
| 1353 | Y- | Jog Y negative |
| 1354 | Z+ | Jog Z positive |
| 1355 | Z- | Jog Z negative |
| 1356 | 4th+ | Jog A axis positive |
| 1357 | 4th- | Jog A axis negative |
| 1358 | 5th+ | Jog B axis positive |
| 1359 | 5th- | Jog B axis negative |
| 1362 | MPG RUN | MPG mode run |
| 1360 | CONT-STEP-MPG | Toggle continuous/step/MPG |

### Speed Controls

| Key Value | Function | Usage |
|-----------|----------|-------|
| 1364 | Feed rate 100% | Reset feedrate to 100% |
| 1365 | Feed rate +10% | Increase feedrate by 10% |
| 1366 | Feed rate -10% | Decrease feedrate by 10% |
| 1367 | Spindle rate 100% | Reset spindle override to 100% |
| 1368 | Spindle rate +10% | Increase spindle by 10% |
| 1369 | Spindle rate -10% | Decrease spindle by 10% |

### Spindle Direction

| Key Value | Function | Usage |
|-----------|----------|-------|
| 1370 | M5 | Spindle stop |
| 1371 | M4 | Spindle CCW |
| 1372 | M3 | Spindle CW |

### Additional Controls

| Key Value | Function | Usage |
|-----------|----------|-------|
| 1388 | Fast | Fast mode toggle |
| 1392 | Start 1 | Custom start button 1 |
| 1393 | Start 2 | Custom start button 2 |
| 1394 | Start 3 | Custom start button 3 |

### ASCII Character Input

| Key Value | Character | Usage |
|-----------|-----------|-------|
| 1033 | ! | ASCII character |
| 1034 | " | ASCII character |
| 1035 | # | ASCII character |
| 1048 | 0 | Number input |
| 1049 | 1 | Number input |
| 1050 | 2 | Number input |
| 1051 | 3 | Number input |
| 1052 | 4 | Number input |
| 1053 | 5 | Number input |
| 1054 | 6 | Number input |
| 1055 | 7 | Number input |
| 1056 | 8 | Number input |
| 1057 | 9 | Number input |
| 1065 | A | Letter input |
| 1066 | B | Letter input |
| 1067 | C | Letter input |
| 1068 | D | Letter input |
| 1069 | E | Letter input |
| ... | ... | Continue through alphabet |

**Note**: Full ASCII table available in official documentation.

## Common Use Cases

### 1. Simulate Reset Button

**Official example from documentation:**

```gcode
; Simulate pressing the Reset button
#2037 = 1 * 2^16 + (1327 - 1000)
#2037 = 65536 + 327
#2037 = 65863
```

**Simplified calculation:**
```gcode
; Press Reset button
#2037 = 65536 + 327  ; 1327 (Reset) - 1000 = 327
```

### 2. Automatic Screen Navigation

```gcode
; Navigate to Probe screen automatically
#2037 = 65536 + (1323 - 1000)  ; Press Probe button
#2037 = 65536 + 323
#2037 = 65859
```

### 3. Start Program from Macro

```gcode
; Automatically press START button
#2037 = 65536 + (1328 - 1000)
#2037 = 65536 + 328
#2037 = 65864
```

### 4. Feedrate Override Control

```gcode
; Set feedrate to 100%
#2037 = 65536 + (1364 - 1000)
#2037 = 65536 + 364
#2037 = 65900

; Increase feedrate by 10%
#2037 = 65536 + (1365 - 1000)
#2037 = 65536 + 365
#2037 = 65901
```

### 5. Switch to Manual Mode

```gcode
; Switch to Manual operation screen
#2037 = 65536 + (1326 - 1000)
#2037 = 65536 + 326
#2037 = 65862
```

## Practical Automation Patterns

### Auto-Reset After Operation

```gcode
(Complete operation and reset controller)
; ... operation code ...

#1505 = -5000(Operation complete - Resetting controller)
G04 P2.0          ; Wait 2 seconds for operator to read
#2037 = 65863     ; Simulate Reset button (1327-1000+65536)
```

### Screen Navigation Sequence

```gcode
(Navigate through screens for setup)
#1505 = -5000(Setting up screens...)

; Go to Coordinate Set screen
#2037 = 65536 + 387  ; 1387 - 1000
G04 P0.5

; Go to Probe screen
#2037 = 65536 + 323  ; 1323 - 1000
G04 P0.5

#1505 = -5000(Screens configured!)
```

### Spindle Control Sequence

```gcode
(Test spindle in all directions)
#1505 = -5000(Testing spindle...)

; Start CW
#2037 = 65536 + 372  ; M3 (1372-1000)
G04 P3.0             ; Run 3 seconds

; Stop
#2037 = 65536 + 370  ; M5 (1370-1000)
G04 P2.0

; Start CCW
#2037 = 65536 + 371  ; M4 (1371-1000)
G04 P3.0

; Stop
#2037 = 65536 + 370  ; M5

#1505 = -5000(Spindle test complete!)
```

### Feedrate Calibration

```gcode
(Set known feedrate override state)
; Always start from 100%
#2037 = 65536 + 364  ; Feed rate 100% (1364-1000)
G04 P0.5

#1505 = -5000(Feedrate reset to 100%)
```

## Advanced Patterns

### Emergency Stop Macro

```gcode
(Emergency stop - accessible via custom button)
M5                   ; Stop spindle
#2037 = 65863        ; Press Reset (1327-1000+65536)
#1505 = 1(EMERGENCY STOP - Press ENTER to acknowledge)
M30
```

### Operator-Assisted Probing Workflow

```gcode
(Semi-automated probing with screen navigation)
; Navigate to Probe screen
#2037 = 65536 + 323  ; Probe screen (1323-1000)
G04 P1.0

#1505 = 1(Attach probe - Press ENTER when ready)
IF #1505 == 0 GOTO 999

; ... probe routine ...

; Navigate back to Program screen
#2037 = 65536 + 374  ; Program screen (1374-1000)
#1505 = -5000(Probing complete!)

N999
M30
```

### Multi-Step Setup Automation

```gcode
(Automated setup sequence)
#1505 = 1(Run setup sequence?)
IF #1505 == 0 GOTO 999

; Step 1: Reset to known state
#2037 = 65863        ; Reset button
G04 P1.0

; Step 2: Navigate to Coord Set
#2037 = 65536 + 387  ; Coord Set (1387-1000)
G04 P1.0

; Step 3: Set feedrate to 100%
#2037 = 65536 + 364  ; Feed 100%
G04 P0.5

; Step 4: Set spindle override to 100%
#2037 = 65536 + 367  ; Spindle 100%
G04 P0.5

#1505 = -5000(Setup complete!)

N999
M30
```

## Important Considerations

### 1. Timing Requirements

**Always add delays** after #2037 assignments:
```gcode
#2037 = 65863        ; Press button
G04 P0.5             ; Wait 0.5 seconds
```

Without delays, the controller may not register the button press or subsequent actions may execute before screen changes complete.

### 2. Screen Context Dependency

Some button actions depend on which screen is currently active. Navigate to the correct screen first:

```gcode
; Won't work if not on Program screen:
#2037 = 65864        ; Start button

; Correct approach:
#2037 = 65536 + 374  ; Navigate to Program
G04 P1.0             ; Wait for screen change
#2037 = 65864        ; Now Start works
```

### 3. Release vs Press

**Bit 16 = 1**: Press button  
**Bit 16 = 0**: Release button

Most use cases only need Press (bit 16 = 1). Release is rarely needed.

```gcode
; Press
#2037 = 1 * 65536 + 327  ; Press Reset

; Release (rarely needed)
#2037 = 0 * 65536 + 327  ; Release Reset
#2037 = 327              ; Same as above (0 × 65536 = 0)
```

### 4. ASCII Input Use Cases

ASCII character input (1033-1069+) is primarily for:
- MDI command entry automation
- File name input automation
- Parameter value entry automation

Example:
```gcode
; Type "G0 X10" in MDI
; G = 1071, 0 = 1048, space = 1032, X = 1088, 1 = 1049, 0 = 1048

#2037 = 65536 + 71   ; G
G04 P0.1
#2037 = 65536 + 48   ; 0
G04 P0.1
#2037 = 65536 + 32   ; space
G04 P0.1
; ... continue for remaining characters
```

**Note**: This is complex and error-prone. Better to use direct G-code in macros.

## Helper Calculations

**Quick reference formulas:**

```gcode
; Formula: #2037 = 65536 + (KeyValue - 1000)

; Common buttons:
#2037 = 65863  ; Reset (1327)
#2037 = 65864  ; Start (1328)
#2037 = 65865  ; Pause (1329)
#2037 = 65867  ; Spindle ON/OFF (1331)
#2037 = 65900  ; Feed 100% (1364)
#2037 = 65903  ; Spindle 100% (1367)
#2037 = 65906  ; M5 Stop (1370)
#2037 = 65907  ; M4 CCW (1371)
#2037 = 65908  ; M3 CW (1372)
```

## Troubleshooting

### Button Press Doesn't Work

**Symptoms**: #2037 assignment has no effect

**Checks:**
1. Verify calculation: (KeyValue - 1000) + 65536
2. Add G04 delay after assignment (minimum 0.5 seconds)
3. Confirm correct screen is active
4. Verify key value from official table
5. Check that controller isn't in error state

### Screen Doesn't Change

**Symptoms**: Navigation button doesn't switch screens

**Solutions:**
```gcode
; Add longer delay
#2037 = 65536 + 374  ; Program screen
G04 P1.0             ; Increase to 1 second

; Ensure no blocking dialog
#1027 = 65563        ; Press ESC first to clear dialogs
G04 P0.5
#2037 = 65536 + 374  ; Now navigate
```

### Unexpected Behavior

**Cause**: Multiple rapid button presses

**Solution**: Always add delays between #2037 assignments:
```gcode
#2037 = 65863  ; Reset
G04 P1.0       ; Wait
#2037 = 65864  ; Start
G04 P1.0       ; Wait
```

## Best Practices

1. **Always use delays**: G04 P0.5 minimum after each #2037 assignment
2. **Document key values**: Add comments with original key value
3. **Test in isolation**: Verify each button press works before chaining
4. **Handle errors**: Add IF checks after critical screen changes
5. **Provide feedback**: Use #1505 to inform operator what's happening
6. **Keep it simple**: Avoid complex ASCII input sequences

## Summary

The #2037 virtual button system enables powerful automation:
- ✅ Screen navigation
- ✅ Program control (Start/Stop/Reset)
- ✅ Feedrate/spindle overrides
- ✅ Mode switching (Manual/MDI)
- ✅ Operator-assisted workflows

**Official documentation**: `Virtual_button_function__2037_.pdf`

**Formula to remember**: `#2037 = 65536 + (KeyValue - 1000)`

This feature transforms static macros into interactive, screen-aware automation routines.
