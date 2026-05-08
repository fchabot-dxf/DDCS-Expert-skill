---
name: ddcs-expert
description: Expert guidance for DDCS M350 CNC controller macro programming and G-code development (V1.22 VERIFIED). Use when troubleshooting G-code issues, building macros for DDCS controllers, debugging variable addressing, understanding parameter mappings, working around controller quirks (G53 verified syntax, G10 broken, G28 not configured, variable persistence), developing CNC automation for Ultimate Bee or similar machines using DDCS Expert controllers, or working with manual tool change workflows. Covers variable numbering systems, coordinate system offsets, dual-gantry synchronization, M350-specific workarounds, verified code patterns, and tested macros from real production machines.
---

# DDCS M350/Expert Controller - Macro Programming Skill

**Controller**: DDCS Expert M350 (V1.22 Verified)  
**Machine**: Ultimate Bee 1010 CNC  
**Last Updated**: January 2026  
**Authority**: 90%+ [CONFIRMED] Production Testing

---

## 1. Critical Starting Points

### 1.1. ALWAYS Read These First [REQUIRED]

**For ANY macro task, start here**:

1. **CORE_TRUTH.md** - Firmware quirks and workarounds
   - G10 broken, G28 not machine zero, G53 syntax rules
   - Variable priming bug, C-style operators required
   - [CONFIRMED] patterns only

2. **example-macros/** - 25 production-tested macros
   - Find similar example to your goal
   - Copy working code as template
   - Better than documentation (proven to work)

3. **Quick reference specs** (Agent-optimized):
   - `hardware-integration-spec.md` - I/O, power, troubleshooting trees
   - `software-technical-spec.md` - Core truths, execution model, firmware quirks

**See**: Section 4 for complete reference guide

---

## 2. The Eight Core Truths [CONFIRMED]

**Standard FANUC G-code WILL FAIL without these workarounds**:

| # | Truth | Workaround | Reference |
|---|-------|------------|-----------|
| 1 | **G10 is BROKEN** | Use direct #805+ writes | software-technical-spec.md §3.2 |
| 2 | **G28 ≠ machine zero** | Use G53 G0 with coordinates | CORE_TRUTH.md §3 |
| 3 | **G53 requires variables** | No hardcoded constants | CORE_TRUTH.md §2 |
| 4 | **Variable priming required** | Prime #1153+ from #880+ | variable-priming-card.md |
| 5 | **C-style operators only** | Use ==, !=, <, > (NOT EQ, NE) | software-technical-spec.md §3.4 |
| 6 | **WCS stride = 5** | Not 20 (G54=#805, G55=#810) | software-technical-spec.md §3.5 |
| 7 | **IF/GOTO syntax strict** | No brackets, no spaces | conditional-syntax-card.md |
| 8 | **#2070 range limited** | Only writes to #50-#499 | input-dialog-patterns.md |

**Machine-Specific (Ultimate Bee 1010)**:
- Y-axis: 0 to **-735mm** (NEGATIVE space)
- Z-axis: 0 to **-150mm** (NEGATIVE space)
- G28 back-off: X=5.0, Y=-5.0, Z=-5.0 (NOT machine zero!)

---

## 3. Quick Decision Tree

**"What should I read for X?"**

```
Task: Write new macro
├─ example-macros/ (find similar)
├─ software-technical-spec.md §4 (3-phase execution model)
└─ macrob-programming-rules.md (syntax)

Task: Probe not triggering
├─ hardware-integration-spec.md §8 (troubleshooting tree)
├─ g31-probe-variables.md (G31 command)
└─ macro_cam*.nc (working examples)

Task: Controller freeze
├─ variable-priming-card.md (priming bug)
├─ software-technical-spec.md §3.1 (priming requirement)
└─ example-macros/ (check priming patterns)

Task: Dual-gantry setup
├─ dual-gantry-advanced-1-overview.md (config)
├─ dual-gantry-advanced-3-usage.md (troubleshooting)
└─ macro_DA_without_relay_advanced.nc (example)

Task: WCS offset management
├─ software-technical-spec.md §3.2 (avoid G10)
└─ user-tested-patterns.md (working examples)

Task: I/O troubleshooting
├─ hardware-integration-spec.md §10 (quick ref)
└─ hardware-config.md (complete specs)
```

---

## 4. Reference File Guide

### 4.1. Start Here (Agent-Optimized Quick References)

| File | Lines | Purpose |
|------|-------|---------|
| **hardware-integration-spec.md** | 475 | I/O mapping, troubleshooting trees, power distribution |
| **software-technical-spec.md** | 896 | Core truths, 3-phase model, firmware quirks |
| **CORE_TRUTH.md** | 524 | Complete firmware workarounds reference |

**Authority**: All [CONFIRMED] - production-verified patterns only

---

### 4.2. Language & Syntax

**MacroB Programming**:
- `macrob-programming-rules.md` - Complete syntax reference
- `advanced-macro-mathematics.md` - Complex calculations
- `variable-priming-card.md` - Priming bug patterns
- `conditional-syntax-card.md` - IF/GOTO/Label syntax (NEW)

**User Input & Display**:
- `input-dialog-patterns.md` - Safe #2070 usage patterns (NEW)
- `ddcs-display-methods.md` - Complete display methods (2-part series)

**Variable Reference**:
- `system-control-variables.md` - Variable addresses
- `community-discovered-variables.md` - Undocumented vars
- `user-storage-map.md` - Persistent storage

---

### 4.3. Hardware & I/O

**Machine Configuration**:
- `hardware-config.md` (864 lines) - Complete Ultimate Bee 1010 manifest
- `yunkia-v6-probe.md` (622 lines) - YunKia V6 probe specs
- `supplies-and-parts-list.md` - BOM

**Sensors & Probing**:
- `g31-probe-variables.md` - G31 command reference
- `pnp-to-npn-converter.md` - Signal conversion

---

### 4.4. Working Patterns (Split Series - All Under 650 Lines)

**Community Patterns** (6-part series):
- `community-patterns.md` - Index
- `community-patterns-1-core.md` (606) - **START HERE** for patterns
- Parts 2-5: Boolean/dynamic, multi-tool, advanced syntax

**Dual-Gantry** (3-part series):
- `dual-gantry-advanced.md` - Index
- `dual-gantry-advanced-1-overview.md` (400) - **START HERE** for dual-gantry
- Parts 2-3: Algorithm, troubleshooting

**Display Methods** (2-part series):
- `ddcs-display-methods.md` - Index
- `ddcs-display-methods-1-core.md` (417) - **START HERE** for dialogs
- Part 2: Advanced methods

**Why split?** Better navigation, all parts under 650 lines. Start with Part 1, follow links.

---

### 4.5. Your Machine (User-Specific)

- `user-tested-patterns.md` - Verified on Ultimate Bee 1010
- `fusion-post-processor.md` - Fusion 360 post-processor
- `squaring-macro-WIP-log.md` - Development log

**Calibration**:
- `gantry-squaring-calibration.md` - Manual procedures
- `dual-gantry-auto-squaring.md` - Basic overview

---

### 4.6. Controller Interface

**Virtual Controls**:
- `virtual-buttons-2037.md` (589 lines) - #2037 button simulation
- `k-button-assignments.md` (626 lines) - K-button programming

---

### 4.7. Example Macros (25 Files)

**Directory**: `references/example-macros/`

**Categories**:
- **Homing**: fndzero.nc, fndy.nc, Double_Y_*.nc
- **Probing**: macro_cam10-13.nc (4 methods)
- **Tool Management**: O_Save_*.nc, PERSISTENCE_*.nc
- **Utilities**: SPINDLE_WARMUP.nc, READ_VAR.nc
- **Advanced**: macro_Adaptive_Pocket.nc, macro_DA_without_relay_advanced.nc (348 lines)

**See**: `example-macros/README.md` for complete catalog

---

### 4.8. Data Lookup (Spreadsheets)

1. **DDCS_Variables_mapping_2025-01-04.xlsx**
   - ENG# → Pr# → Macro Address mapping

2. **Virtual_button_function_codes_COMPLETE.xlsx**
   - 201 #2037 KeyValue codes

3. **DDCS_G-M-code_reference.xlsx**
   - Supported G/M codes

---

## 5. The Three Numbering Systems [CRITICAL]

**DDCS M350 uses three different numbering schemes - confusing them breaks code**:

| System | Example | Used Where | Notes |
|--------|---------|------------|-------|
| **ENG File** | #0, #129, #880 | .eng backup files | Parameter storage |
| **UI Display** | Pr0, Pr129 | Controller screen | What you see |
| **Macro Address** | #500, #629, #880 | G-code macros | **What you write** |

**Process**: Check `DDCS_Variables_mapping_2025-01-04.xlsx` → "Macro Var" column = correct address

**Common pattern**: Pr[N] → #[N+500]  
**Example**: Pr129 (probe thickness) → #629 in code

**Important ranges**:
- #1-#999: Local (no priming needed)
- #805-#834: WCS offsets (no priming needed)
- #880-#884: Machine positions (read-only)
- #1153-#5999: User persistent (**REQUIRES PRIMING**)

**See**: `system-control-variables.md` for complete map

---

## 6. Authority Levels [Data Reliability]

| Tag | Confidence | Source | Use For |
|-----|------------|--------|---------|
| **[CONFIRMED]** | 100% | Production testing + firmware analysis | Critical operations |
| **[OBSERVED]** | 90% | Consistent on Ultimate Bee 1010 | Standard operations |
| **[HYPOTHESIS]** | 50% | Theory under verification | Experimental only |

**Agent Instruction**: Prefer [CONFIRMED]. Flag [HYPOTHESIS] for user validation.

---

## 7. Best Practices (Quick Reference)

### 7.1. Three-Phase Execution Model

**Every macro follows this pattern**:

```gcode
O1000 (Macro Name)

; ═══ PHASE 1: Safety & Priming ═══
#100 = 0          ; Initialize
#100 = #880       ; Prime system vars
IF #880 == 0 THEN #1505=1(Not homed!)

; ═══ PHASE 2: Execution ═══
#target = #100 + 50
G53 G0 X#target   ; Use G53 (not G28)
IF #target > 500 THEN GOTO100  ; C-style

; ═══ PHASE 3: Validation & Restore ═══
IF #1922 != 1 THEN #1505=1(Failed!)
#2100 = 0         ; Prime persistent
#2100 = #result   ; Safe assignment
G90               ; Restore modal
M30
```

**See**: `software-technical-spec.md` §4 for complete explanation

---

### 7.2. Critical Rules (Quick Checklist)

> **⚠️ Evidence note (2026-05-07):** Two items below conflict with macro evidence — see annotations.

```
❌ NEVER:
- #1153 = #880                (freeze bug — confirmed by priming patterns in macros)
- G10 L2 P1 X0 Y0 Z0          (broken — 0 uses in 26 macros)
- G28 Z0                      (not machine zero — 0 uses in macros)
- IF #100 EQ 5 GOTO100        (unreliable — confirmed: 0 EQ/NE in macros)
- G53 G0 X0                   (needs variable — confirmed)
- IF [#var!=2] GOTO1          ⚠ DISPUTED: every working macro uses brackets like this
- GOTO 1                      (no space before label)
- #2070=1175(...)             (can't write to persistent directly)

✅ ALWAYS:
- #100 = #880, #1153 = #100   (prime first — confirmed)
- #805 = #880                 (direct WCS write — confirmed)
- G53 G0 Z0                   (true machine zero)
- IF #100 == 5 GOTO100        (C-style — confirmed)
- #var = 0, G53 G0 X#var      (use variable — confirmed)
- IF #var!=2 GOTO1            ⚠ CLAIMED but no macro uses bare form. Brackets are the production default.
- GOTO1                       (no space — but multi-digit labels are fine; "single digit label" hint disproved)
- #2070=105(...), #1175=#105  (two-step for persistent)
```

**Compound conditions (missing from original checklist, used everywhere in macros):**
```
- IF [#a==1]+[#b==1] GOTO5   `+` between brackets = logical OR
- IF [#a==1]*[#b==1] GOTO5   `*` between brackets = logical AND
```

---

## 8. Getting Started Workflow

**For any new macro project**:

```
Step 1: Read CORE_TRUTH.md
   ↓
Step 2: Find similar example in example-macros/
   ↓
Step 3: Check software-technical-spec.md for execution model
   ↓
Step 4: Check hardware-integration-spec.md if using I/O
   ↓
Step 5: Copy example as template
   ↓
Step 6: Follow three-phase structure
   ↓
Step 7: Prime persistent variables
   ↓
Step 8: Use C-style operators only
   ↓
Step 9: Test on machine
   ↓
Step 10: Document in user-tested-patterns.md
```

---

## 9. Skill Statistics

**Documentation**: 27 guides (16 split into focused parts)  
**Example Macros**: 25 production-tested .nc files  
**Total Lines**: ~15,000 lines  
**Largest File**: 864 lines (hardware-config.md)  
**All Split Parts**: Under 650 lines  
**Authority**: 90%+ [CONFIRMED] on core content

**Complete Coverage**:
- ✅ Firmware V1.22 reference
- ✅ Ultimate Bee 1010 hardware
- ✅ All MacroB patterns
- ✅ Dual-gantry auto-squaring
- ✅ Probe routines (4 methods)
- ✅ WCS workarounds
- ✅ I/O troubleshooting
- ✅ Variable priming
- ✅ Virtual buttons
- ✅ Fusion post-processor

---

## 10. File Organization Summary

**Quick References** (Start here):
- hardware-integration-spec.md (475 lines) - [CONFIRMED]
- software-technical-spec.md (896 lines) - [CONFIRMED]
- CORE_TRUTH.md (524 lines) - [CONFIRMED]

**Quick Reference Cards** (New - Syntax Safety):
- conditional-syntax-card.md (198 lines) - IF/GOTO/Label syntax
- input-dialog-patterns.md (268 lines) - Safe #2070 usage

**Split Series** (Organized by topic):
- Community Patterns: 6 parts, indexed
- Dual-Gantry: 3 parts, indexed
- Display Methods: 2 parts, indexed

**Everything Else** (Use as needed):
- Language reference (syntax, variables, priming)
- Hardware specs (machine config, probes, I/O)
- User-specific (your patterns, calibration, post-processor)
- Example macros (25 working .nc files)
- Lookup tables (spreadsheets for addresses/codes)

**Navigation**: All split series have index files with quick access links. Start with Part 1, follow links.

---

## 11. Quick Command Reference

**Correct patterns**:
```gcode
; WCS offset management (G10 broken)
#805 = #880   ; G54 X offset (direct write)

; Machine zero (G28 not machine zero)
G53 G0 Z0     ; True machine zero

; G53 syntax (requires variable)
#z = 0
G53 G0 Z#z    ; Correct

; Variable priming (prevents freeze)
#100 = #880
#1153 = #100  ; Safe assignment

; Operators (C-style only)
IF #100 == 5 GOTO100   ; Correct
IF #100 != 0 GOTO200   ; Correct
```

**See**: `software-technical-spec.md` for complete patterns

---

## 12. Need Help?

**Can't find what you need?**

1. Check Section 3 (Quick Decision Tree)
2. Start with quick references (Section 4.1)
3. Browse example-macros/ directory
4. Search CORE_TRUTH.md for quirks
5. Check split series indexes for organized topics

**Remember**: Example macros are better than docs. Find similar example first, then consult references.

---

## 13. Skill Updates

**For Claude**: When the user requests skill updates or changes, automatically package and present the skill using:
```bash
cd /mnt/skills/user && tar -czf /mnt/user-data/outputs/ddcs-expert.skill ddcs-expert/
```
Then use `present_files` on the `.skill` file to provide the "Copy to your skills" button.

**For Users**: After Claude makes changes, you'll see a "Copy to your skills" button to update your skill library with one click.

---

**Skill Version**: 2.1 (Agent-Optimized + Updated Jan 2026)  
**Last Updated**: January 21, 2026  
**Firmware**: V1.22 Verified  
**Status**: ✅ Production-Ready
