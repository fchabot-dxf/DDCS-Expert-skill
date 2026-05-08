# YunKia V6 (TP06) 3D Touch Probe - Technical Documentation

**Complete technical specifications and integration guide for the YunKia V6 Anti-roll 3D Touch Probe with DDCS M350 controller**

---

## Overview

The YunKia V6 (TP06) is a high-precision 3D touch probe designed for CNC machines. This probe provides sub-0.01mm repeatability for accurate workpiece probing, edge finding, and tool length measurement.

**Model**: V6 Anti-roll 3D Touch Probe (TP06)  
**Output Type**: NPN Normally Open (NO)  
**Primary Use**: Workpiece edge finding, center finding, and surface probing

---

## 1. Core Specifications

### Electrical Specifications
- **Output Type**: NPN Normally Open (NO)
- **Operating Voltage**: DC 5V – 24V (Wide voltage support)
- **Signal Type**: Active low (pulls to ground when triggered)
- **Current Draw**: Low (suitable for direct controller input)

### Mechanical Specifications
- **Shank Diameter**: 6mm (standard router collet compatible)
- **Repeatability**: < 0.01mm (at 50–200 mm/min feed rate)
- **Stylus Material**: Stainless steel shaft
- **Probe Tip**: Tungsten steel ball (wear resistant)

### Physical Safety Limits
⚠️ **CRITICAL - Do Not Exceed These Limits:**
- **XY Over-travel**: ±4mm maximum swing before damage
- **Z-axis Over-travel**: 2mm maximum compression
- **Damage Prevention**: Always use slow approach speeds and soft limits

### Precision Performance
- **Best Repeatability**: 50-200 mm/min probe feed rate
- **Recommended Approach**: Two-stage (fast approach + slow precision)
- **Typical Precision**: 0.005-0.01mm under optimal conditions

---

## 2. Visual Indicators (On-Body LEDs)

The probe has two LED status indicators:

### LED States

| LED Color | State | Meaning | Circuit Status |
|-----------|-------|---------|----------------|
| **Steady Green** | Powered, not triggered | Search mode / Ready to probe | Open circuit (NPN not conducting) |
| **Steady Red** | Triggered / Touching | Contact detected | Closed circuit (NPN pulled to ground) |

### Troubleshooting LED Behavior

**No LEDs lit:**
- ❌ No power to probe
- Check RED wire connection to 24V+
- Check BLACK wire connection to COM-
- Verify voltage present at terminals

**Red LED always on:**
- ❌ Probe stuck in triggered state
- Check for debris blocking stylus movement
- Verify stylus moves freely in all directions
- Check for damaged internal switches

**Flickering LEDs:**
- ⚠️ Electrical noise or intermittent connection
- Check wire shielding grounded properly
- Verify all connections are secure
- Move probe cable away from motor/VFD cables

---

## 3. Wiring Configuration for DDCS M350

### Wire Color Functions

| Wire Color | Function | Connection Point |
|------------|----------|------------------|
| **RED** | VCC (Power +) | Main 24V (+) Hub or DDCS 24V+ terminal |
| **BLACK** | GND (Power -) | DDCS COM- Terminal |
| **YELLOW or WHITE** | IO Signal (NPN Output) | DDCS IN03 Terminal |

### Wiring Diagram

```
YunKia V6 TP06 Probe            DDCS M350 Controller
┌─────────────────┐             ┌────────────────────┐
│                 │             │                    │
│  RED (VCC)      ├─────────────┤ 24V+ (or +24V hub) │
│                 │             │                    │
│  BLACK (GND)    ├─────────────┤ COM- (Ground)      │
│                 │             │                    │
│  YELLOW (Signal)├─────────────┤ IN03               │
│                 │             │                    │
│  Shield Mesh    ├─────────────┤ Chassis Ground     │
│                 │             │                    │
└─────────────────┘             └────────────────────┘
```

### Critical Wiring Notes

**NPN Probe Cannot Drive Relay:**
- ❌ Do NOT connect this probe through a mechanical relay
- ❌ Do NOT use relay-based input boards
- ✅ Connect DIRECTLY to DDCS controller NPN input (IN03)

**Shield Grounding (Essential):**
- Connect cable shield mesh to machine chassis ground
- Prevents "ghost triggers" from electrical noise
- Critical in electrically noisy environments (VFD spindle)

**Power Source Options:**
1. **DDCS 24V+ terminal** (if available and sufficient current)
2. **Dedicated 24V power supply** shared with other sensors
3. **5V option** (works but 24V preferred for noise immunity)

---

## 4. DDCS M350 Software Configuration

### Parameter #043 (IN03 Configuration)

**Location**: Standard Parameters → #043 (IN03)

**Values:**
- **Value 0**: Active Low (Triggered when signal pulled to ground)
- **Value 1**: Active High (Triggered when circuit is open/broken)

**For YunKia V6 NPN Normally Open Probe:**
```
Parameter #043 = 0 (Active Low)
```

**Why Value 0:**
- Probe is "Normally Open" when not touching
- When triggered, NPN transistor conducts → pulls YELLOW wire to ground
- DDCS detects ground signal as "probe triggered"
- Active Low configuration matches this behavior

### Verification Test

**Step 1: Power On Test**
1. Power on controller with probe connected
2. Probe LED should show **Steady Green**
3. DDCS display should show IN03 = OFF (or 0)

**Step 2: Manual Trigger Test**
1. Gently push stylus in any direction
2. Probe LED should change to **Steady Red**
3. DDCS display should show IN03 = ON (or 1)
4. Release stylus
5. LED returns to **Steady Green**
6. DDCS display returns to IN03 = OFF

**If behavior is reversed (IN03 ON when not touching):**
- Change Parameter #043 to Value 1 (Active High)
- This would indicate wiring issue or non-standard probe

---

## 5. Integration with Hardware Configuration

### Input Assignment (hardware-config.md)

**In your hardware-config.md, Section 3 (Sensors & I/O):**

```markdown
**IN03**: YunKia V6 TP06 3D Touch Probe
- Type: NPN Normally Open
- Voltage: 24V
- Function: Workpiece edge finding, center finding, surface probing
- Shank: 6mm (router collet compatible)
- Repeatability: <0.01mm @ 50-200mm/min
- Parameter #043: 0 (Active Low)
- Wiring: RED=24V+, BLACK=COM-, YELLOW=IN03, Shield=Chassis GND
```

### Probe Storage Location

**Machine Coordinates (Update for YOUR machine):**
- **Storage Position**: [X_coord] [Y_coord] [Z_safe_height]
- **Approach Path**: Define safe Z clearance and XY path
- **Tool Change Integration**: Probe stored alongside tools or separate rack

---

## 6. G31 Probe Command Integration

### Basic G31 Probe Syntax

```gcode
G31 Z-10 F100     ; Probe down 10mm at 100mm/min
```

**After successful probe:**
- Controller stops at contact point
- #5063 = Probed Z position (machine coordinates)
- #5073 = Probed Z position (work coordinates)

**If probe does not trigger within travel distance:**
- ❌ Alarm: "G31 Probe Failed"
- Machine stops
- Check probe wiring and configuration

### Two-Stage Probing (Recommended)

**Fast Approach + Precision Touch:**

```gcode
; Stage 1: Fast approach (safe distance)
G31 Z-8 F200      ; Probe down 8mm at 200mm/min (fast)
G0 Z[#5063 + 2]   ; Retract 2mm above contact point

; Stage 2: Slow precision probe
G31 Z-3 F50       ; Probe down 3mm at 50mm/min (slow, precise)

; Result stored in #5063 (machine Z) and #5073 (work Z)
```

**Why two-stage probing:**
- First stage covers most distance quickly
- Second stage achieves <0.01mm repeatability
- Reduces total cycle time while maintaining precision

### Probe Variables

See `references/g31-probe-variables.md` for complete G31 variable reference:
- `#5061-#5069`: Machine coordinate results
- `#5071-#5079`: Work coordinate results  
- Input status and probe mode configuration

---

## 7. Best Practices for Accuracy

### Environmental Factors

**Cleanliness (Critical):**
- ✅ Clean workpiece surface (no oil, coolant, chips)
- ✅ Clean tungsten ball tip before each use
- ✅ Inspect stylus for debris after every few probes
- ❌ Oil or coolant causes inconsistent contact
- ❌ Chips can prevent full stylus deflection

**Feed Rate for Precision:**
- **Fast approach**: 150-300 mm/min (initial contact search)
- **Final precision**: 50-100 mm/min (best repeatability)
- **Maximum recommended**: 200 mm/min for precision work
- **Higher speeds**: Reduce repeatability and may damage probe

**Electrical Noise Prevention:**
- ✅ Shield cable grounded to machine chassis
- ✅ Route probe cable away from motor/VFD power cables
- ✅ Use shielded twisted pair cable for long runs
- ✅ Verify all ground connections are solid
- ❌ Never run probe cable in same conduit as spindle/motor cables

### Probe Technique

**Approach Direction:**
- Probe perpendicular to surface when possible
- Avoid extreme angles (reduces repeatability)
- Account for stylus ball diameter in calculations

**Multiple Probes for Verification:**
```gcode
; Probe same point 3 times, verify consistency
G31 Z-10 F100
#100 = #5063      ; Store first result
G0 Z5             ; Retract

G31 Z-10 F100
#101 = #5063      ; Store second result
G0 Z5

G31 Z-10 F100
#102 = #5063      ; Store third result

; Check consistency
IF [ABS[#100 - #101] > 0.02] THEN #1505 = 5001(Probe Error - Check Results!)
```

### Material Considerations

**Conductive Materials (Best):**
- ✅ Aluminum, steel, brass, copper
- ✅ Reliable electrical contact
- ✅ Consistent triggering

**Non-Conductive Materials (May Not Work):**
- ❌ Plastics (unless conductive or coated)
- ❌ Wood (dry wood is insulator)
- ❌ Composites (carbon fiber may work, fiberglass won't)

**Workarounds for Non-Conductive:**
- Use mechanical touch probe instead
- Place conductive shim on surface
- Ground the material if semi-conductive

---

## 8. Maintenance and Care

### Regular Maintenance

**Daily (if used frequently):**
- Wipe tungsten ball with clean cloth
- Inspect stylus for free movement in all directions
- Visual check for damaged wires or connectors

**Weekly:**
- Test trigger repeatability (manual push test)
- Verify LED indicators functioning
- Check wire connections for tightness

**Monthly:**
- Full electrical verification (IN03 parameter test)
- Measure repeatability with test block
- Inspect cable for wear or damage

### Storage

**When Not in Use:**
- Store in protective case or designated holder
- Avoid placing heavy objects on probe
- Keep away from chips, coolant, and debris
- Protect cable from being crushed or pinched

**Tool Changer Integration:**
- If using manual tool changes, create dedicated holder
- Ensure probe cannot roll off or fall
- Mark storage location clearly

### Damage Prevention

**Physical Protection:**
- ⚠️ Never exceed ±4mm XY over-travel
- ⚠️ Never exceed 2mm Z over-travel
- ⚠️ Always use slow approach speeds
- ⚠️ Never force stylus if stuck

**Electrical Protection:**
- Don't reverse polarity on power wires
- Don't apply voltage >24V
- Don't short signal wire to power
- Use properly rated power supply

### Signs of Damage

**Replace probe if:**
- ❌ Stylus does not return to center
- ❌ Excessive play in stylus movement
- ❌ LED indicators not functioning
- ❌ Intermittent triggering or false triggers
- ❌ Repeatability >0.05mm consistently
- ❌ Physical cracks or visible damage

---

## 9. Troubleshooting Guide

### Probe Not Triggering

**Symptoms:** Probe LED goes red, but DDCS IN03 stays OFF

**Possible Causes:**
1. Parameter #043 set incorrectly
   - **Fix:** Set to Value 0 (Active Low)
2. Signal wire (YELLOW) not connected to IN03
   - **Fix:** Verify connection at DDCS terminal
3. Ground wire (BLACK) not connected properly
   - **Fix:** Check COM- terminal connection
4. Input damaged or disabled
   - **Fix:** Test IN03 with another sensor

### False Triggering

**Symptoms:** DDCS IN03 triggers without probe contact

**Possible Causes:**
1. Electrical noise from VFD or motors
   - **Fix:** Ground shield properly, reroute cable
2. Loose wire connections
   - **Fix:** Tighten all terminals, check for broken wires
3. Damaged probe internal electronics
   - **Fix:** Test with multimeter, replace if faulty
4. Wrong parameter setting
   - **Fix:** Verify Parameter #043 = 0

### Inconsistent Repeatability

**Symptoms:** Probe results vary by >0.02mm

**Possible Causes:**
1. Feed rate too high (>200 mm/min)
   - **Fix:** Reduce to 50-100 mm/min for final probe
2. Dirty probe tip or workpiece
   - **Fix:** Clean both surfaces thoroughly
3. Vibration or machine rigidity issues
   - **Fix:** Check machine for loose components
4. Electrical noise affecting trigger point
   - **Fix:** Improve shielding and grounding

### Probe LED Not Lighting

**Symptoms:** No LED illumination at all

**Possible Causes:**
1. No power to probe
   - **Fix:** Check 24V supply, verify voltage at terminals
2. Power wires reversed
   - **Fix:** Verify RED=24V+, BLACK=COM-
3. Internal LED failure
   - **Fix:** If probe still functions, LED may be burned out (still usable)

---

## 10. Example G-code Macros

### Simple Auto-Zero Test Macro

```gcode
; YunKia V6 Auto-Zero Test Macro
; Tests probe functionality and sets work Z-zero

O1000 (Auto-Zero Test)

; Safety checks
IF [#1014 == 0] THEN #1505 = 5001(ERROR: No spindle in position!)
IF [#5023 < -50] THEN #1505 = 5002(ERROR: Z too low - move up first!)

; Parameters
#100 = 100        ; Probe feed rate (mm/min)
#101 = -20        ; Max probe distance (mm)
#102 = 5          ; Retract height after probe (mm)

; Clear WCS Z offset first
G10 L2 P0 Z0      ; Reset current WCS Z to zero (machine coords)

; Fast approach
G91               ; Incremental mode
G31 Z#101 F200    ; Probe down 20mm at 200mm/min
G0 Z2             ; Retract 2mm

; Slow precision probe
G31 Z-5 F#100     ; Probe 5mm at slow speed
G90               ; Absolute mode

; Set work Z-zero at current position
G92 Z0            ; Set current position as Z=0 in work coordinates

; Retract to safe height
G91
G0 Z#102          ; Retract 5mm above surface
G90

#1505 = 5000(Z-Zero Set Successfully!)
M30
```

### Advanced Edge Finder (X-Edge)

```gcode
; YunKia V6 X-Edge Finder
; Finds X edge and sets work X-zero

O1001 (Find X Edge)

; Safety checks and parameters
#100 = 100        ; Probe feed rate
#101 = 10         ; Max probe travel
#102 = 3          ; Probe ball radius (1.5mm radius = 3mm diameter)

; Approach from left side
G91               ; Incremental mode
G31 X#101 F200    ; Fast approach
G0 X-2            ; Back off 2mm
G31 X5 F#100      ; Slow precision probe
G90               ; Absolute mode

; Calculate edge position (compensate for ball radius)
#103 = #5061 - #102  ; Subtract ball radius from probed position

; Set work X-zero at calculated edge
G10 L2 P0 X#103

#1505 = 5000(X-Edge Found and Zeroed!)
G0 X-10           ; Move away from edge
M30
```

### Center Finder (Rectangular Boss)

```gcode
; YunKia V6 Center Finder for Rectangular Features
; Probes all 4 sides and calculates center

O1002 (Find Center)

; User parameters
#100 = 100        ; Probe feed rate
#101 = 20         ; Max probe travel
#102 = 3          ; Probe ball diameter (compensate)

; Probe -X side (left)
G91
G31 X-#101 F#100
#110 = #5061 + #102  ; Store edge + radius
G0 X5
G90

; Probe +X side (right)
G91
G31 X#101 F#100
#111 = #5061 - #102  ; Store edge - radius
G0 X-5
G90

; Probe -Y side (front)
G91
G31 Y-#101 F#100
#112 = #5062 + #102  ; Store edge + radius
G0 Y5
G90

; Probe +Y side (back)
G91
G31 Y#101 F#100
#113 = #5062 - #102  ; Store edge - radius
G0 Y-5
G90

; Calculate center
#120 = [#110 + #111] / 2  ; X center
#121 = [#112 + #113] / 2  ; Y center

; Set work coordinates to center
G10 L2 P0 X#120 Y#121

#1505 = 5000(Center Found!)
G0 X0 Y0          ; Move to new center
M30
```

---

## 11. Integration Checklist

Before using the probe in production:

### Physical Installation
- [ ] Probe shank properly secured in 6mm collet
- [ ] Stylus moves freely in all directions (±4mm XY, 2mm Z)
- [ ] LED indicators visible during operation
- [ ] Cable routed away from spindle/motors
- [ ] Cable has service loop (not tight/stretched)

### Electrical Connection
- [ ] RED wire connected to 24V+
- [ ] BLACK wire connected to COM-
- [ ] YELLOW wire connected to IN03
- [ ] Shield mesh connected to chassis ground
- [ ] All terminals tightened securely
- [ ] No wire strands sticking out of terminals

### Controller Configuration
- [ ] Parameter #043 set to 0 (Active Low)
- [ ] IN03 shows OFF when probe not touching
- [ ] IN03 shows ON when stylus manually pushed
- [ ] Green LED steady when not touching
- [ ] Red LED steady when touching

### Functional Testing
- [ ] Manual trigger test passes (LED + IN03 response)
- [ ] Simple G31 test macro executes successfully
- [ ] Repeatability test shows <0.02mm variation
- [ ] No false triggers during normal operation
- [ ] Probe retracts and returns to center after trigger

### Documentation Updated
- [ ] hardware-config.md updated with IN03 assignment
- [ ] Probe storage location documented
- [ ] Example macros tested and saved
- [ ] Maintenance schedule established

---

## 12. Related Documentation

**Within this skill:**
- `hardware-config.md` - Complete I/O assignments including IN03
- `g31-probe-variables.md` - G31 command and variable reference
- `CORE_TRUTH.md` - Controller quirks affecting probe operation
- `pnp-to-npn-converter.md` - PNP probe conversion (not needed for this probe)
- `supplies-and-parts-list.md` - Wiring components and connectors

**Official References:**
- `M350_instruction_description-G31.pdf` - G31 command specification
- DDCS M350 controller manual - Input configuration

---

## Conclusion

The YunKia V6 TP06 3D Touch Probe provides professional-grade probing capability for the DDCS M350 controller when properly configured. With <0.01mm repeatability and robust NPN output, it's suitable for precision edge finding, center location, and surface mapping.

**Key Success Factors:**
1. ✅ Correct electrical configuration (Parameter #043 = 0)
2. ✅ Proper shielding and grounding
3. ✅ Slow probe speeds (50-100 mm/min for precision)
4. ✅ Clean surfaces and regular maintenance
5. ✅ Two-stage probing technique

**Remember:** This is a precision instrument. Treat it carefully, maintain it regularly, and always test your macros safely before production use.

---

**For questions or troubleshooting, refer to the troubleshooting section above or consult the DDCS Expert community.**
