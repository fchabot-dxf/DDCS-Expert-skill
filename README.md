# DDCS Expert Skill

**Comprehensive documentation and macro library for DDCS Expert (M350) CNC controller**

![Version](https://img.shields.io/badge/version-1.0-blue)
![Controller](https://img.shields.io/badge/DDCS-Expert%20M350-orange)
![Firmware](https://img.shields.io/badge/firmware-V1.22-green)

---

## Overview

This skill provides complete documentation, proven macros, and reference materials for operating CNC machines with the DDCS Expert (M350) controller. Built from production experience on an Ultimate Bee 1010 dual-gantry CNC machine.

**Skill file updated periodically - download the latest `.skill` file from this repository**

---

## What's Included

### 📚 Documentation (18 Files)

**Core Reference:**
- **CORE_TRUTH.md** - V1.22 verified controller quirks and workarounds
- **hardware-config.md** - Complete machine configuration reference
- **macrob-programming-rules.md** - Essential M350 macro syntax rules
- **user-storage-map.md** - 174 persistent variable allocation guide
- **variable-priming-card.md** - Critical variable washing bug workaround

**Specialized Guides:**
- **pnp-to-npn-converter.md** - Signal inverter for PNP probe compatibility
- **gantry-squaring-calibration.md** - Single-switch calibration method
- **k-button-assignments.md** - K1-K7 programmable button map
- **fusion-post-processor.md** - Complete Fusion 360 workflow

**Variable & Control Reference:**
- **community-discovered-variables.md** - Community-found variable behaviors
- **system-control-variables.md** - System variable reference
- **g31-probe-variables.md** - G31 probe command documentation
- **ddcs-display-methods.md** - Dialog boxes and display functions
- **virtual-buttons-2037.md** - Complete #2037 virtual button guide

**Community Knowledge:**
- **community-patterns.md** - Proven macro patterns from experienced users
- **user-tested-patterns.md** - Production-tested macros
- **advanced-macro-mathematics.md** - Formula library by Nikolay Zvyagintsev
- **dual-gantry-auto-squaring.md** - Reference: dual-switch method (not used)

### 🔧 Example Macros (22 Files)

**Production Macros:**
- Complete homing sequences (Z→X→Y→B)
- Tool change position management
- WCS offset auto-detection
- Spindle warmup routines
- Variable inspection tools
- Persistence testing utilities

**Community Examples:**
- Thread milling (internal & external)
- Arc movement patterns
- Probe operations
- Safe movement templates

### 📖 Reference Materials

- **Variables-ENG_01-04-2025.xlsx** - Complete variable map (1339 rows)
- **G-M-code_full_list.xlsx** - G/M code reference
- **DDCSE_Post-processor.cps** - Current Fusion 360 post-processor
- **Official PDFs** - G31 specification, Virtual buttons, Parameter descriptions
- **eng parameter file** - Controller parameter definitions

---

## Quick Start

### Installation

1. **Download** the latest `ddcs-expert.skill` file from this repository
2. **Upload** to Claude.ai or Claude desktop app
3. **Access** - The skill will be available in your Claude interface

### Using the Skill

The skill file is a knowledge base that Claude can reference when helping with:
- Writing macros for DDCS M350 controllers
- Troubleshooting controller quirks
- Understanding variable behavior
- Planning tool change workflows
- Configuring dual-gantry machines
- Setting up probes and sensors

**Example prompts:**
```
"Write a macro to home all axes on DDCS M350"
"How do I work around the G53 bug?"
"What variables are persistent across reboots?"
"Help me set up a PNP probe on an NPN controller"
"Create a K-button macro to jump to MDI page"
```

---

## Key Features

### ✅ Production-Tested

All macros and documentation verified on:
- **Machine**: Ultimate Bee 1010 (1000×1000mm)
- **Controller**: DDCS Expert M350 (V1.22 firmware)
- **Configuration**: Dual-gantry Y-axis, rotary B-axis, manual tool changes

### ✅ Controller Quirks Documented

**Critical workarounds included:**
- G10 WCS writing broken → Use direct parameter writing
- G53 requires Z-axis movement first → Safe movement patterns
- G28 not configured → Alternative homing methods
- Variable washing required → Priming patterns documented
- #2500-2599 persistence confirmed → Complete storage map

### ✅ Complete Hardware Documentation

- Input assignments (IN01-IN23 mapped)
- Wiring architecture (hybrid DB37 + direct-wired)
- Sensor types (NPN/PNP compatibility)
- Motor configuration (dual-gantry slave setup)
- Probe specifications (tool setter, puck, 3D probe)

### ✅ Workflow Solutions

- **Manual tool changes**: Separate toolpath strategy documented
- **Gantry squaring**: Single-switch calibration method
- **PNP probe fix**: Complete signal inverter guide
- **K-button automation**: Navigation and utility macros
- **Fusion 360 integration**: Working post-processor included

---

## Documentation Highlights

### CORE_TRUTH.md - The Essential Guide

**Critical "Core Truths" about M350 firmware:**
- G10 WCS writing is broken
- G53 machine coordinates require Z-first movement
- G28 reference points not configured by default
- Variable washing required before assignment
- Dialog message formatting quirks

**175+ verified patterns and workarounds**

### hardware-config.md - Complete Machine Manifest

**15 comprehensive sections:**
1. Machine specifications
2. Motor & drive configuration
3. Sensors & IO (complete input map)
4. Control architecture
5. Spindle & VFD
6. Machine construction
7. Accessories & tooling
8. Rotary axis (K-80)
9. Soft limits & travel
10. Parameter quick reference
11. Dual-gantry synchronization
12. Tool change workflow
13. Probe configuration
14. Key machine characteristics
15. Troubleshooting

### user-storage-map.md - 174 Persistent Variables

**Complete allocation guide:**
- System-reserved ranges
- User-available ranges
- Persistence verified ranges
- Usage recommendations
- Collision avoidance strategies

### pnp-to-npn-converter.md - PNP Probe Solution

**Three complete circuit designs:**
1. NPN transistor (recommended - $0.50)
2. Relay-based (simple - $3-5)
3. Opto-isolator (best isolation - $1-2)

**Includes**: Parts lists, wiring diagrams, testing procedures, troubleshooting

---

## Machine Configuration (Reference)

This skill was developed on the following configuration:

**CNC Machine:**
- Ultimate Bee 1010 (1000×1000mm working area)
- Dual-gantry Y-axis (Y1 master, A/Y2 slave)
- Y-axis negative space (0 to -735mm)
- C-Beam 40×80mm frame construction

**Controller:**
- DDCS Expert (M350) V1.22 firmware
- Magic Cube breakout (v4.1 legacy system)
- Hybrid wiring (DB37 + direct-wired sensors)

**Axes:**
- X: 756mm travel, SFS1210 ballscrew, 500 pulse/mm
- Y: 735mm travel (dual motor), SFS1210 ballscrew, 500 pulse/mm  
- Z: Verified travel, SFU1204 ballscrew, 1250 pulse/mm
- B: Rotary K-80, 6:1 ratio, DM556 driver, 3200 microsteps

**Spindle:**
- 2.2kW water-cooled (ER20 collets, 0-24,000 RPM)
- Huanyang VFD control

**Sensors:**
- IN01: Rotary B-axis homing (NPN proximity)
- IN02: Tool setter (passive)
- IN03: 3D touch probe (PNP - requires converter)
- IN10: Z-probe puck (passive)
- IN20: X-axis home (mechanical switch)
- IN21: Z-axis home (mechanical switch)
- IN23: Y-axis home (mechanical switch)

---

## Community Contributions

This skill incorporates knowledge from:
- Nikolay Zvyagintsev (advanced mathematics formulas)
- DDCS Expert community (proven patterns)
- Official DDCS documentation (verified against V1.22)
- Production testing (Ultimate Bee 1010)

---

## Version Information

**Current Skill Version**: Check filename for date  
**Controller Firmware**: V1.22 (verified)  
**Last Major Update**: January 2026  
**Total Size**: ~843KB (compressed .skill file)  
**File Count**: 46 files (18 markdown + 22 macros + 6 reference files)

---

## File Format

The `.skill` file is a **zip archive** containing:
- Markdown documentation files
- Example macro .nc files  
- Reference materials (XLSX, PDF, CPS)
- Organized in `/references/` structure

**To extract**: Rename `.skill` → `.zip` and extract with any zip utility

---

## Usage Notes

### ⚠️ Important Disclaimers

- **Machine-specific**: Documentation reflects Ultimate Bee 1010 configuration
- **Firmware-specific**: Verified on V1.22 - other versions may differ
- **Not official**: Community-developed, not endorsed by DDCS manufacturer
- **Use at own risk**: Test all macros safely before production use
- **Backup settings**: Always backup controller parameters before changes

### ✅ Best Practices

- Read CORE_TRUTH.md first
- Check hardware-config.md for your machine differences
- Test macros in air (no tool, safe Z height) before production
- Keep soft limits enabled during testing
- Use feed rate override for initial testing
- Document any modifications you make

---

## Support & Updates

**Repository**: fchabot-dxf/DDCS-Expert-skill  
**Updates**: Skill file replaced periodically with latest version  
**README**: This file is static - skill documentation evolves

**For DDCS Expert controller support:**
- Official DDCS documentation
- DDCS Expert user forums
- CNC community resources

**This is a documentation project, not a support channel**

---

## File Organization

```
ddcs-expert/
├── SKILL.md (main index/navigation)
├── references/
│   ├── CORE_TRUTH.md (essential reading)
│   ├── hardware-config.md (machine manifest)
│   ├── macrob-programming-rules.md
│   ├── user-storage-map.md
│   ├── pnp-to-npn-converter.md
│   ├── gantry-squaring-calibration.md
│   ├── k-button-assignments.md
│   ├── ... (14 more .md files)
│   ├── example-macros/
│   │   ├── fndzero.nc
│   │   ├── SPINDLE_WARMUP.nc
│   │   ├── ... (20 more .nc files)
│   ├── Variables-ENG_01-04-2025.xlsx
│   ├── G-M-code_full_list.xlsx
│   ├── DDCSE_Post-processor.cps
│   └── ... (3 PDFs + eng file)
```

---

## License

**Documentation**: Shared for educational and reference purposes  
**Macros**: Use and modify freely, test thoroughly before production use  
**Community Knowledge**: Credit to original contributors where noted  

**No warranty expressed or implied. Use at your own risk.**

---

## Changelog

**Skill updates are periodic - check filename date for version**

Major milestones:
- **Jan 2026**: Complete documentation rewrite with V1.22 verification
- **Jan 2026**: PNP-to-NPN converter guide added
- **Jan 2026**: K-button assignment map added
- **Jan 2026**: Dual-gantry single-switch calibration documented
- **Jan 2026**: 174 persistent variables verified
- **Jan 2026**: Hardware manifest completed
- **Jan 2026**: CORE_TRUTH updated to V1.22

---

## Quick Links (Within Skill)

**Start here:**
- `SKILL.md` - Main navigation and index
- `CORE_TRUTH.md` - Essential controller quirks

**Most useful:**
- `hardware-config.md` - Complete reference
- `user-storage-map.md` - Variable allocation
- `macrob-programming-rules.md` - Syntax rules
- `example-macros/` - Working code examples

**Problem solvers:**
- `pnp-to-npn-converter.md` - PNP probe fix
- `variable-priming-card.md` - Variable washing bug
- `gantry-squaring-calibration.md` - Squaring method

---

**Download the latest `.skill` file and import into Claude for comprehensive DDCS Expert M350 knowledge!**

**Repository**: https://github.com/fchabot-dxf/DDCS-Expert-skill
