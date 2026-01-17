# Example Macros - Working .nc Files

This directory contains actual working macro files (.nc) tested on DDCS M350 systems. These are real production code examples that can be referenced when building new macros.

## Your Tested Macros (Fréderic's Ultimate Bee 1010)

### Position Saving

**SAVE_safe_park_position.nc**
- Saves current position to #1153-#1154 (safe park)
- Simple, proven pattern with priming
- Used by Fusion post-processor for end-of-job parking

**SAVE_tool_change_position.nc**
- Saves current position to #1155-#1156 (tool change)
- Optimized for manual tool access
- Alternative parking location

**SAVE_NATIVE_SYSTEM_FIXED_SENSOR_POSITION.nc**
- Saves current position to Pr135/Pr136 (#635-#636)
- Updates controller's built-in fixed probe parameters
- Uses buffer variables for safety

**SAVE_WCS_XY_AUTO.nc**
- Dynamically detects active WCS (G54-G59)
- Sets XY zero for currently active coordinate system
- Uses indirect addressing: `#[#103] = #101`
- Production-tested with all WCS

### Homing & Synchronization

**fndzero.nc**
- Complete homing sequence: Z→X→Y
- Syncs A-axis (Y2) after Y homing
- Sets A-axis homed flag (#1518)
- Production startup routine

**fndy.nc**
- Y-axis only rehoming
- Syncs A-axis without full homing sequence
- Quick re-sync after step loss

**sysstart.nc**
- Uses M115 built-in homing
- Alternative to manual M98P501 calls
- Includes A-axis sync after completion

### Spindle Control

**SPINDLE_WARMUP.nc**
- Progressive warmup: 6000→12000 RPM
- 30 seconds at each speed
- User confirmation dialog
- Prevents cold-start bearing damage

### Probing (Community Examples)

**macro_cam10.nc**
- Surface finding with 3D touch probe
- Two-pass approach (fast + slow)
- Accounts for probe length offset
- Sets WCS Z zero automatically

**macro_cam11.nc**
- Hole center finding routine
- Four-direction probe (left, right, back, front)
- Optional double Y-scan for round features
- Calculates center, sets WCS XY zero

### Debugging & Testing

**READ_VAR.nc**
- Interactive variable inspector
- Uses #2070 for user input
- Displays variable address and value
- Indirect addressing: `#[#100]`

**PERSISTENCE_WRITE.nc**
- Tests which variable ranges survive reboot
- Writes unique values to 8 different ranges
- Run before power cycle

**PERSISTENCE_READ.nc**
- Reads values after power cycle
- Sequential display of all tested ranges
- Shows 0.00 for non-persistent ranges
- Comprehensive persistence verification

### Utility Macros

**Average_error.nc**
- Calculates arithmetic mean homing error
- Loops through axes 1-4
- Displays errors with format codes
- Identifies sensor problems

**Test_DA_with_relay.nc**
- Interactive dual-axis sensor testing
- Tests master, slave, and relay operation
- User input for port numbers
- Flashing relay test pattern

### Advanced Examples (Community)

**Table_leveling.nc**
- Surface milling with snake pattern
- G4P-1 interactive pause for setup
- Saves/restores soft limit state
- Complex coordinate calculation
- Progress display via #879+axis

**macro_through_a_pause.nc**
- Loop-based position memory
- G4P-1 for manual positioning
- Stores unlimited positions
- Playback with G53 machine coords

**macro_through_the_stop.nc**
- Alternative position memory method
- Uses M0 stops instead of G4P-1
- ESC/ENTER decision points
- Iterative position teaching

**Double_Y_double_zero_switch.nc**
- Advanced dual-gantry homing
- Tests both Y-axis sensors separately
- Chinese comments (from community)
- Complex sensor port logic

**Manual.nc**
- Documentation file (not executable)
- Describes other community macros
- Testing procedures
- Feature explanations

## Usage Patterns

### When to Reference These Macros

**Building position saving macro:**
→ Reference `SAVE_safe_park_position.nc` for pattern

**Creating probe routine:**
→ Reference `macro_cam10.nc` or `macro_cam11.nc`

**Need variable inspection:**
→ Copy pattern from `READ_VAR.nc`

**Dual-gantry sync issue:**
→ Check `fndzero.nc` and `fndy.nc` for correct pattern

**Testing persistence:**
→ Use `PERSISTENCE_WRITE.nc` and `PERSISTENCE_READ.nc`

**Interactive workflow:**
→ Reference `macro_through_a_pause.nc` for G4P-1 usage

**Spindle warmup:**
→ Copy `SPINDLE_WARMUP.nc` structure

## Key Patterns Found in These Macros

### 1. Variable Priming
```gcode
#1153 = 1      ; Prime with 1 (not 0 - also works!)
#1154 = 1
#1153 = #880   ; Safe to assign system variable
```

### 2. Active WCS Detection
```gcode
#100 = #578                    ; Get active WCS (1-6)
#103 = 805 + [#100 - 1] * 5    ; Calculate offset address
#[#103] = #880                 ; Indirect write
```

### 3. Dual-Gantry Sync
```gcode
M98P501X1      ; Home Y
#883 = #881    ; Sync A to Y
#1518 = 1      ; Mark A as homed
```

### 4. Two-Pass Probe
```gcode
G31 Z-50 F200           ; Fast
IF #1922 == 0 GOTO 999
#20 = #1927             ; Store trigger
G53 Z[#20 + 1]          ; Retract
G31 Z-2 F20             ; Slow precise
```

### 5. G4P-1 Interactive Pause
```gcode
G4P-1
G1
;Move to position
;and press START
#1577 = #882   ; Capture position after START
```

### 6. User Input
```gcode
#2070 = 100(Enter variable #:)
#1510 = #100           ; The number entered
#1511 = #[#100]        ; Indirect read
#1505 = -5000(#[%.0f] = [%.3f])
```

### 7. Format Code Display
```gcode
#1510 = #880
#1511 = #881
#1512 = #882
#1505 = -5000(X=[%.3f] Y=[%.3f] Z=[%.3f])
```

### 8. Loop-Based Position Storage
```gcode
WHILE #100 < #200 DO1
    #100 = #100 + 1
    G53 X#[2200 + #100] Y#[2300 + #100]
END1
```

## File Organization

**Your macros** (Fréderic's tested on Ultimate Bee 1010):
- All SAVE_*.nc files
- fndzero.nc, fndy.nc, sysstart.nc
- SPINDLE_WARMUP.nc
- READ_VAR.nc
- PERSISTENCE_*.nc

**Community macros** (proven on other M350 systems):
- macro_cam*.nc (probe routines)
- Table_leveling.nc (surface milling)
- macro_through_*.nc (position memory)
- Average_error.nc (diagnostics)
- Test_DA_*.nc (sensor testing)
- Double_Y_*.nc (dual-gantry advanced)

## Integration with Skill

These macros are referenced throughout the skill documentation:

- **user-tested-patterns.md** - Documents your macros with explanations
- **community-patterns.md** - Documents community macros with patterns
- **SKILL.md** - Provides quick reference examples
- **fusion-post-processor.md** - Uses SAVE position patterns

## Testing Status

✅ **Production-tested**: All SAVE_*.nc, fndzero.nc, fndy.nc, SPINDLE_WARMUP.nc
✅ **Community-proven**: macro_cam*.nc, Table_leveling.nc
✅ **Diagnostic tools**: READ_VAR.nc, PERSISTENCE_*.nc, Average_error.nc
✅ **Advanced examples**: macro_through_*.nc, Double_Y_*.nc

## Important Notes

1. **Encoding**: All files use UTF-8 without BOM
2. **Line endings**: Mix of CRLF and LF (both work on M350)
3. **Comments**: Some use `//`, some use `;`, both work
4. **Language**: Some community macros have Chinese comments
5. **Tested**: Your macros tested on ballscrew/LGR Ultimate Bee 1010
6. **Community**: Other macros tested on various M350 systems

## How to Use

**Copy pattern directly:**
```gcode
; Copy the entire SAVE_safe_park_position.nc pattern
; Modify variable numbers if needed
```

**Extract technique:**
```gcode
; Take the G4P-1 pattern from Table_leveling.nc
; Apply to your own macro
```

**Learn from structure:**
```gcode
; Study SPINDLE_WARMUP.nc for user confirmation
; Study macro_cam11.nc for complex probe logic
```

**Debug reference:**
```gcode
; Compare your macro to working examples
; Check variable usage, priming, sync patterns
```

These are real, working files - not theoretical examples. They represent battle-tested solutions to common DDCS M350 programming challenges.

## Advanced Community Macro

21. **macro_Thread_milling.nc** - Cylindrical thread milling macro (by Nikolay Zvyagintsev)
    - Internal and external threads
    - Configurable thread parameters
    - Progressive depth cutting
    - Chamfering options
    - Finishing passes
    - Through-cutting support
    - Safety checks and simulation
    - Production-tested advanced example

## Latest Addition - Auto-Squaring

22. **fndzero-autosquare-final.nc** - Dual-gantry auto-squaring homing macro
    - Automatically corrects gantry racking using two Y-axis limit switches
    - Two-stage correction: auto-measured switch offset + manual frame calibration
    - Y1 (left) = Home position, Y2 (right) = Reference
    - Self-calibrating switch offset measurement
    - Manual frame calibration offset (#121) for fine-tuning
    - Production-tested on Ultimate Bee 1010
    - See `dual-gantry-auto-squaring.md` for complete documentation
