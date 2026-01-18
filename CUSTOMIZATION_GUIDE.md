# Customization Guide - Adapting DDCS Expert Skill to Your Machine

**This skill is configured for an Ultimate Bee 1010 dual-gantry CNC machine.** To use it effectively on your machine, you'll need to customize certain files.

---

## ⚠️ Critical Warning

**DO NOT blindly use the included macros without modification!**

The skill contains machine-specific:
- Travel distances and limits
- Probe positions and thickness values
- Feed rates and speeds
- Homing switch locations and directions
- Input/output assignments
- Motor configurations

**Always review, modify, and test macros on your machine before production use.**

---

## 🔧 Files You MUST Modify

### 1. **hardware-config.md**

**Location**: `references/hardware-config.md`

**What to change:**
- **Section 1**: Machine specifications (model, working area, frame size)
- **Section 2**: Motor & drive configuration (steps/mm, microstepping, driver models)
- **Section 3**: Sensors & I/O - **CRITICAL**: Update all input assignments
  - Limit switch inputs (IN20, IN21, IN23, etc.)
  - Probe inputs (IN02, IN03, IN10, etc.)
  - Your specific sensor types (NPN vs PNP)
  - E-stop and safety inputs
- **Section 4**: Control architecture (your wiring setup)
- **Section 5**: Spindle specifications (VFD model, RPM limits, cooling)
- **Section 9**: Soft limits & travel (your actual machine limits)
- **Section 13**: Probe configuration (your probe types, locations, thicknesses)

**Why it's critical:**
- Wrong I/O assignments = crashes or no response
- Wrong limits = machine damage
- Wrong probe settings = broken tools or workpieces

**How to customize:**
1. Open `hardware-config.md`
2. Go through each section systematically
3. Replace all Ultimate Bee 1010 specs with YOUR machine specs
4. Verify every input assignment matches your wiring
5. Test limit switches and probes manually before running code

---

### 2. **firmware-backup-2025-12-31/** Directory

**Location**: `references/firmware-backup-2025-12-31/`

**What to do:**
- **REPLACE** the entire directory with YOUR controller's firmware backup
- Keep the naming structure: `firmware-backup-YYYY-MM-DD/`
- Include all files from your backup:
  - `slib-g.nc` - Your system G-code library
  - `slib-m.nc` - Your M-code library
  - `key-*.nc` - Your K-button macros
  - `probe.nc`, `fndZ.nc`, etc. - Your system macros
  - All parameter files (`eng`, `setting`, etc.)

**Why it's critical:**
- References in documentation point to YOUR firmware, not someone else's
- Your parameters, homing routines, and probe settings are unique
- Line numbers in slib-g.nc will differ between controllers

**How to backup your firmware:**

1. **On the controller:**
   - Insert USB drive
   - Navigate: `System` → `Backup` → `Execute`
   - Wait for backup to complete
   - Remove USB drive

2. **On your computer:**
   - Copy the `SystemBak_*/` directory from USB
   - Rename parent folder to `firmware-backup-YYYY-MM-DD/` (today's date)
   - Replace the entire `firmware-backup-2025-12-31/` directory in the skill

3. **Update references:**
   - Search for `firmware-backup-2025-12-31` in all .md files
   - Replace with your new directory name
   - Verify line numbers in CORE_TRUTH.md and g31-probe-variables.md
   - Check if O501, O502, O503 are at different line numbers in YOUR slib-g.nc

---

### 3. **user-storage-map.md** (Optional but Recommended)

**Location**: `references/user-storage-map.md`

**What to change:**
- **"Allocated Variables" section**: Document YOUR variable usage
- Update which ranges you're using for what purpose
- Track your persistent storage strategy
- Note any custom variable assignments

**Why it's important:**
- Prevents variable conflicts in your macros
- Helps track what you've allocated where
- Makes debugging easier
- Prevents accidentally overwriting your data

**Example customization:**
```markdown
## My Machine - Allocated Variables

### Tool Change System (#1153-#1156)
- #1153: Safe park X position (machine coords)
- #1154: Safe park Y position (machine coords)  
- #1155: Tool change X position (machine coords)
- #1156: Tool change Y position (machine coords)

### Custom Probing (#1157-#1165)
- #1157: Last probe hit X
- #1158: Last probe hit Y
- #1159: Last probe hit Z
- #1160-#1165: Reserved for probe expansion

### Material Tracking (#2500-#2510)
- #2500: Current material thickness
- #2501: Material hardness code
- #2502-#2510: Reserved for material data
```

---

### 4. **k-button-assignments.md** (If using K-buttons)

**Location**: `references/k-button-assignments.md`

**What to change:**
- Update table with YOUR K-button assignments
- Document what each programmed button does
- Track which buttons are free
- Note any special sequences or workflows

**Why it's useful:**
- Prevents accidentally overwriting important macros
- Helps plan automation workflows
- Makes it easy to see what's available

**Example:**
```markdown
| Button | Status | Macro File | Function | Notes |
|--------|--------|------------|----------|-------|
| K1 | ✅ Assigned | key-1.nc | Quick MDI jump | Hold 2 sec |
| K2 | ✅ Assigned | key-2.nc | Probe routine | Auto Z-zero |
| K3 | ✅ Assigned | key-3.nc | Spindle warmup | 3 min cycle |
| K4 | 🆓 Free | key-4.nc | - | Available |
```

---

## 📝 Files You SHOULD Review

### 5. **CORE_TRUTH.md**

**Location**: `references/CORE_TRUTH.md`

**What to verify:**
- Controller firmware version (V1.22 vs YOUR version)
- Quirks and workarounds apply to your firmware
- Parameter numbers match your controller
- G-code behavior matches what you observe

**Note:** Most M350 quirks are firmware-wide, but test on YOUR machine:
- G10 broken? (Try setting WCS with G10 - does it work?)
- G53 requires variables? (Test hardcoded G53 - does it fail?)
- Variable washing needed? (Test without priming - does it freeze?)

**If your firmware differs significantly**, add notes or create a separate section.

---

### 6. **example-macros/** Directory

**Location**: `references/example-macros/`

**What to modify in each macro:**

**Homing sequences** (`fndzero.nc`, `fndy.nc`, etc.):
- Travel distances to switches
- Switch locations (positive vs negative direction)
- Back-off distances after homing
- Safe clearance heights

**Probe routines**:
- Probe locations (X, Y, Z machine coordinates)
- Probe thickness values (#629 for puck, IN02 for tool setter)
- Approach heights and distances
- Probe speeds (fast approach, slow precision)

**Tool change macros**:
- Tool change position coordinates
- Safe park position coordinates
- Z clearance heights
- Approach paths

**General safety values**:
- Feed rates (match your machine's capabilities)
- Rapid move speeds
- Acceleration limits
- Safe heights above work

**How to adapt:**
1. Open each macro you want to use
2. Find hardcoded coordinates (G0 X__, Y__, Z__)
3. Replace with YOUR machine coordinates
4. Test in air (no tool, safe Z height, soft limits on)
5. Gradually lower Z and reduce speeds until verified

---

### 7. **Fusion360_DDCS_post-processor.cps**

**Location**: `references/Fusion360_DDCS_post-processor.cps`

**What to customize:**

**Machine limits** (lines ~50-80):
```javascript
// Update these to YOUR machine limits
maximumSpindleSpeed = 24000;  // Your max RPM
minimumSpindleSpeed = 6000;   // Your min RPM

// Travel limits
xAxisMinimum = 0;
xAxisMaximum = 756;   // YOUR X travel
yAxisMinimum = -735;  // YOUR Y travel  
yAxisMaximum = 0;
zAxisMinimum = -100;  // YOUR Z travel
zAxisMaximum = 0;
```

**Tool change positions** (search for "homePositionCenter"):
```javascript
// Update to YOUR tool change location
homePositionCenter = {x: 400, y: -350};  // YOUR coordinates
```

**Safe heights** (search for "safeRetractDistance"):
```javascript
safeRetractDistance = 10;  // YOUR safe Z retract
```

**Spindle settings** (search for "spindleRampTime"):
```javascript
spindleRampTime = 2.0;  // YOUR spindle ramp time
```

**Victory dance** (optional, search for "victoryDance"):
- Update coordinates to fit YOUR work area
- Or disable entirely if you don't want it

---

## ✅ Files You Can Use As-Is

These files are **generic DDCS M350 reference** and work universally:

### Programming Reference (No Modification Needed):
- ✅ **macrob-programming-rules.md** - MacroB syntax rules
- ✅ **virtual-buttons-2037.md** - Virtual button codes
- ✅ **g31-probe-variables.md** - G31 variables
- ✅ **ddcs-display-methods.md** - Display functions
- ✅ **system-control-variables.md** - System variables
- ✅ **variable-priming-card.md** - Priming bug workaround
- ✅ **community-patterns.md** - Proven code patterns
- ✅ **advanced-macro-mathematics.md** - Formula library

### Hardware Solutions (Universal):
- ✅ **pnp-to-npn-converter.md** - Circuit designs
- ✅ **gantry-squaring-calibration.md** - Squaring methods
- ✅ **dual-gantry-auto-squaring.md** - Dual-switch reference

### Reference Materials (Universal):
- ✅ **DDCS_Variables_mapping_2025-01-04.xlsx** - Variable map
- ✅ **DDCS_G-M-code_reference.xlsx** - G/M codes
- ✅ **Virtual_button_function_codes_COMPLETE.xlsx** - Button codes
- ✅ **M350_instruction_description-G31.pdf** - G31 specification
- ✅ **Virtual_button_function__2037_.pdf** - Button specification
- ✅ **DDCS_M350_Verified_Skillset_v1.22.pdf** - Verified patterns
- ✅ **eng parameter file** - Parameter definitions

**Note:** Even "universal" files should be verified against YOUR controller. Firmware versions may differ.

---

## 🎯 Quick Customization Workflow

### Step-by-Step Process:

#### 1. **Extract the Skill**
```
ddcs-expert.skill  →  Rename to  →  ddcs-expert.zip  →  Extract
```

#### 2. **Update Hardware Config**
- Open `references/hardware-config.md`
- Replace ALL machine-specific information
- Pay special attention to I/O assignments
- Document YOUR machine completely

#### 3. **Replace Firmware Backup**
- Backup YOUR controller (System → Backup)
- Replace `firmware-backup-2025-12-31/` directory
- Rename to `firmware-backup-YYYY-MM-DD/` (today's date)
- Update directory references in CORE_TRUTH.md and g31-probe-variables.md

#### 4. **Check Firmware Line Numbers**
- Open YOUR `slib-g.nc` file
- Search for `O501` (homing subroutine) - note line number
- Search for `O502` (probe subroutine) - note line number
- Search for `O503` (dual-Y subroutine) - note line number
- Update these line numbers in CORE_TRUTH.md and g31-probe-variables.md

#### 5. **Adapt Example Macros**
- Start with ONE simple macro (like `fndzero.nc`)
- Update coordinates for YOUR machine
- Update feedrates for YOUR machine
- Test in air (no tool, safe height, slow speed)
- Gradually test more macros as you gain confidence

#### 6. **Customize Post-Processor** (If using Fusion 360)
- Open `Fusion360_DDCS_post-processor.cps`
- Update machine limits
- Update tool change positions
- Update safe heights
- Test with simple operations first

#### 7. **Document Your Allocation**
- Update `user-storage-map.md` with YOUR variables
- Update `k-button-assignments.md` with YOUR K-buttons
- Keep notes on what you change

#### 8. **Test Systematically**
- Test limits with jog controls
- Test homing with no tool
- Test probes with safe heights
- Test macros in air first
- Gradually move to real cuts

#### 9. **Re-package** (Optional)
- Compress modified folder back to .zip
- Rename to .skill
- Upload to Claude with YOUR customizations

---

## 🧪 Testing Checklist

Before running ANY macro on your machine:

### Safety Checks:
- [ ] Soft limits enabled and verified
- [ ] E-stop within reach and tested
- [ ] Feed rate override at 10-25%
- [ ] Spindle OFF for initial tests
- [ ] Tool removed or in safe position
- [ ] Work area clear of obstacles

### Verification Tests:
- [ ] Manual jog in all directions works correctly
- [ ] Limit switches trigger properly (test each one)
- [ ] Homing sequence works (test without tool first)
- [ ] Probes trigger correctly (test with multimeter if unsure)
- [ ] Coordinate systems match expectations (G54, G55, etc.)
- [ ] Spindle control works (M3, M4, M5)

### Macro Testing:
- [ ] Read through macro code line by line
- [ ] Verify all coordinates are safe for YOUR machine
- [ ] Check feedrates are appropriate
- [ ] Test with Single Block mode first
- [ ] Run at reduced feed override (10-25%)
- [ ] Watch carefully - ready to hit E-stop

### Progressive Testing:
1. **In air** - No tool, Z well above work
2. **With tool, in air** - Tool installed, still above work
3. **Touch off** - Slowly lower until touching, verify coordinates
4. **Test cut** - Scrap material, shallow depth
5. **Production** - Only after all tests pass

---

## 💡 Tips for Success

### Document Everything:
- Take photos of your machine setup
- Write down your I/O assignments
- Keep notes on what works and what doesn't
- Track your variable allocations
- Document your K-button macros

### Start Simple:
- Begin with basic jog and homing
- Add one feature at a time
- Test thoroughly before moving on
- Don't try to implement everything at once

### Use Version Control:
- Keep backups of working configurations
- Note what changed between versions
- Don't delete old macros - rename them (.old extension)
- Track firmware version updates

### Ask for Help:
- DDCS Expert community forums
- CNC-specific forums and groups
- Share what you learn with others
- Document solutions for future reference

---

## ⚠️ Common Mistakes to Avoid

### 1. **Using someone else's coordinates**
- ❌ Don't assume their tool change position works for you
- ✅ Measure and calculate YOUR coordinates

### 2. **Ignoring I/O assignments**
- ❌ Don't assume IN02 is your probe
- ✅ Verify every input assignment in your controller

### 3. **Skipping air tests**
- ❌ Don't run a new macro with tool loaded
- ✅ Always test in air first

### 4. **Not checking firmware version**
- ❌ Don't assume V1.22 quirks apply to your V1.20
- ✅ Verify behavior on YOUR controller

### 5. **Forgetting about negative space**
- ❌ Don't assume Y+ is toward the back
- ✅ Check YOUR machine's coordinate orientation

### 6. **Blindly trusting macros**
- ❌ Don't run code you don't understand
- ✅ Read every line and verify it makes sense

### 7. **Not backing up**
- ❌ Don't modify without saving the original
- ✅ Always keep backups of working configurations

---

## 📞 Getting Help

If you run into issues:

1. **Double-check this guide** - Did you miss a step?
2. **Review CORE_TRUTH.md** - Is there a known quirk?
3. **Test incrementally** - Isolate the problem
4. **Check your modifications** - Compare to original
5. **Ask the community** - Share specific details about YOUR setup

**When asking for help, provide:**
- Your controller model and firmware version
- Your machine specifications
- The specific macro or operation causing issues
- What you've already tried
- Any error messages or unexpected behavior

---

## ✅ Customization Complete Checklist

- [ ] hardware-config.md updated with MY machine specs
- [ ] firmware-backup directory replaced with MY firmware
- [ ] Line numbers updated in CORE_TRUTH.md for MY slib-g.nc
- [ ] Line numbers updated in g31-probe-variables.md for MY slib-g.nc
- [ ] Example macros adapted for MY coordinates
- [ ] Post-processor customized for MY machine (if using Fusion 360)
- [ ] user-storage-map.md updated with MY variable allocation
- [ ] k-button-assignments.md updated with MY K-button macros
- [ ] All limit switches tested manually
- [ ] All probes tested manually
- [ ] Homing sequence tested in air
- [ ] At least one simple macro tested successfully
- [ ] Documentation updated with MY specific notes

---

**Once you've completed this checklist, you'll have a fully customized DDCS Expert skill for YOUR machine!**

**Remember: Safety first, test incrementally, and keep good documentation!**
