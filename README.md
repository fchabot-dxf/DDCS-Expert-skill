# DDCS Expert Skill

**Comprehensive documentation and macro library for DDCS Expert (M350) CNC controller**

![Version](https://img.shields.io/badge/DDCS-Expert%20M350-orange)
![Firmware](https://img.shields.io/badge/firmware-V1.22%20verified-green)

---

## Overview

This skill provides complete documentation, proven macros, and reference materials for operating CNC machines with the DDCS Expert (M350) controller. Built from production experience on an Ultimate Bee 1010 dual-gantry CNC machine.

**Download the latest `.skill` file from this repository and import into Claude AI or other AI agent, for guided customization, Claude AI will modify the MD files with your provided specific informations**

---

## What's Included

### 📚 Documentation

**Core Reference:**
- **CORE_TRUTH.md** - Essential controller quirks and workarounds
- **hardware-config.md** - Complete machine configuration reference
- **macrob-programming-rules.md** - M350 macro syntax rules
- **user-storage-map.md** - Persistent variable allocation guide
- **variable-priming-card.md** - Critical variable washing bug workaround

**Specialized Guides:**
- **virtual-buttons-2037.md** - Complete #2037 virtual button automation guide
- **g31-probe-variables.md** - G31 probe command documentation
- **fusion-post-processor.md** - Complete Fusion 360 workflow
- **pnp-to-npn-converter.md** - Signal inverter for PNP probe compatibility
- **gantry-squaring-calibration.md** - Single-switch calibration method
- **k-button-assignments.md** - K1-K7 programmable button tracking
- **ddcs-display-methods.md** - Dialog boxes and display functions
- **system-control-variables.md** - System variable reference
- **community-patterns.md** - Proven macro patterns from experienced users
- **user-tested-patterns.md** - Production-tested macros
- **advanced-macro-mathematics.md** - Formula library
- **community-discovered-variables.md** - Community-found variable behaviors
- **dual-gantry-auto-squaring.md** - Reference: dual-switch method

### 🔧 Example Macros

**Production-Ready:**
- Complete homing sequences
- Tool change position management
- WCS offset auto-detection
- Spindle warmup routines
- Variable inspection tools
- Persistence testing utilities

**Community Examples:**
- Thread milling patterns
- Arc movement templates
- Probe operations
- Safe movement examples

### 📖 Reference Materials

**Excel/Spreadsheet References:**
- **DDCS_Variables_mapping_2025-01-04.xlsx** - Complete variable mapping (eng# → Pr# → macro address)
- **DDCS_G-M-code_reference.xlsx** - Supported G/M codes
- **Virtual_button_function_codes_COMPLETE.xlsx** - All 201 virtual button KeyValue codes (extended functions)

**Code & Configuration:**
- **Fusion360_DDCS_post-processor.cps** - Working Fusion 360 post-processor
- **firmware-backup-2025-12-31/** - Complete controller firmware backup with slib-g.nc, slib-m.nc, and all system macros

**Official Documentation:**
- **M350_instruction_description-G31.pdf** - G31 probe command specification
- **Virtual_button_function__2037_.pdf** - Virtual button control specification
- **DDCS_M350_Verified_Skillset_v1.22.pdf** - Complete verified patterns
- **eng parameter file** - Controller parameter definitions

---

## Quick Start

### Installation

1. **Download** the latest `ddcs-expert.skill` file from this repository
2. **Import** to Claude:
   - **claude.ai**: Click the paperclip icon → Upload the .skill file
   - **Claude desktop app**: Drag and drop the .skill file into the chat
3. **Use** - Claude will now have access to all DDCS Expert documentation

### Using the Skill

The skill provides Claude with comprehensive knowledge for:
- Writing macros for DDCS M350 controllers
- Troubleshooting controller quirks
- Understanding variable behavior
- Planning tool change workflows
- Configuring dual-gantry machines
- Setting up probes and sensors
- Fusion 360 post-processor development

**Example prompts:**
```
"Write a macro to home all axes on DDCS M350"
"How do I work around the G53 bug?"
"What variables are persistent across reboots?"
"Help me set up a PNP probe on an NPN controller"
"Create a K-button macro to jump to MDI page"
"Explain the virtual button system and give me examples"
```

---

## Key Features

### ✅ Production-Tested

All macros and documentation verified on real hardware:
- **Machine**: Ultimate Bee 1010 (1000×1000mm dual-gantry)
- **Controller**: DDCS Expert M350 (V1.22 firmware)
- **Configuration**: Manual tool changes, dual probes, rotary axis

### ✅ Controller Quirks Documented

**Critical workarounds for M350 firmware bugs:**
- **G10 broken** → Direct parameter writing method
- **G53 requires variables** → No hardcoded constants
- **G28 not configured** → Alternative homing methods
- **Variable washing required** → Priming patterns documented
- **Dialog formatting issues** → Safe message patterns
- **#2500-2599 persistence** → Verified and documented

### ✅ Complete Hardware Integration

- Input assignments (all 23+ inputs mapped)
- Wiring architecture (hybrid DB37 + direct-wired)
- Sensor compatibility (NPN/PNP solutions)
- Motor configuration (dual-gantry slave setup)
- Probe specifications (multiple probe types)
- VFD spindle control

### ✅ Advanced Automation

- **Virtual buttons (#2037)**: 201 KeyValue codes including K-button triggers, axis commands, file operations
- **K-button macros**: Programmable automation routines
- **Fusion 360 integration**: Complete post-processor with dynamic parking
- **Manual tool change workflow**: Optimized separate-toolpath strategy
- **Gantry squaring**: Single-switch calibration method

### ✅ Firmware Backup Included

Complete controller firmware backup from production machine:
- **slib-g.nc** - System library with O501 (homing), O502 (probe), O503 (dual-Y) subroutines
- **slib-m.nc** - M-code system library
- All K-button macros, probe routines, homing sequences
- Reference for understanding controller behavior

---

## Documentation Highlights

### CORE_TRUTH.md - The Essential Guide

**Critical "Core Truths" about M350 firmware:**
- G10 WCS writing is broken
- G53 machine coordinates require variables only
- G28 reference points use back-off positions (Pr122-124)
- Variable washing prevents freeze bugs
- Dialog message formatting quirks (% symbol causes hangs)
- Verified workarounds for all known issues

### Virtual Buttons - Complete Automation

**Extended virtual button capabilities (#2037):**
- Screen navigation and mode switching
- Feedrate and spindle override control
- **Axis homing commands** (1512-1517) - Home individual or all axes
- **Go to work zero** (1518-1523) - Move to WCS zero programmatically
- **K-button triggers** (2536-2551) - Chain K-button macros together!
- **File operations** (1531-1533) - Copy/paste files, USB transfers
- Complete 201-code reference table

### user-storage-map.md - Persistent Variables

**Complete allocation guide for user data storage:**
- System-reserved ranges identified
- User-available persistent ranges mapped
- Verified persistent ranges tested
- Usage recommendations
- Collision avoidance strategies
- **174 total persistent variables available**

### pnp-to-npn-converter.md - PNP Probe Solution

**Three complete circuit designs:**
1. **NPN transistor** - Recommended ($0.50, simple)
2. **Relay-based** - Easiest ($3-5, foolproof)
3. **Opto-isolator** - Best isolation ($1-2, professional)

Includes parts lists, wiring diagrams, testing procedures, troubleshooting guides.

---

## Machine Configuration (Reference)

This skill was developed on the following configuration:

**CNC Machine:**
- Ultimate Bee 1010 (1000×1000mm working area)
- Dual-gantry Y-axis (Y1 master, A/Y2 slave)
- Y-axis negative space orientation
- Manual tool change workflow (separate toolpaths)

**Controller:**
- DDCS Expert (M350) V1.22 firmware
- Hybrid wiring architecture (DB37 legacy + direct-wired sensors)

**Axes:**
- Linear axes: SFS1210/SFU1204 ballscrews, closed-loop steppers
- Rotary B-axis: K-80 chuck, 6:1 ratio, DM556 driver

**Spindle:**
- 2.2kW water-cooled (ER20 collets, 0-24,000 RPM)
- Huanyang VFD control

**Probes:**
- Tool setter (passive, IN02)
- Z-probe puck (passive, IN10)
- 3D touch probe (PNP with converter, IN03)

---

## File Organization

```
ddcs-expert/
├── SKILL.md                              # Main index (for Claude)
└── references/
    ├── CORE_TRUTH.md                     # Essential controller quirks
    ├── hardware-config.md                # Complete machine manifest
    ├── virtual-buttons-2037.md           # #2037 automation guide
    ├── [15 more documentation files]
    │
    ├── example-macros/
    │   ├── fndzero.nc                    # Complete homing
    │   ├── SPINDLE_WARMUP.nc
    │   └── [20 more macro files]
    │
    ├── firmware-backup-2025-12-31/       # Actual controller firmware
    │   └── SystemBak_.../nand1-1/
    │       ├── slib-g.nc                 # System G-code library
    │       ├── slib-m.nc                 # M-code library
    │       └── [120+ system files]
    │
    ├── DDCS_Variables_mapping_2025-01-04.xlsx
    ├── DDCS_G-M-code_reference.xlsx
    ├── Virtual_button_function_codes_COMPLETE.xlsx
    ├── Fusion360_DDCS_post-processor.cps
    └── [Official PDFs and parameter files]
```

---

## Usage Notes

### ⚠️ Important Disclaimers

- **Machine-specific**: Documentation reflects Ultimate Bee 1010 configuration
- **Firmware-specific**: Verified on V1.22 - other versions may have differences
- **Not official**: Community-developed, not endorsed by DDCS manufacturer
- **Use at own risk**: Test all macros safely before production use
- **Backup settings**: Always backup controller parameters before changes

### ✅ Best Practices

1. **Read CORE_TRUTH.md first** - Essential controller quirks
2. **Check hardware-config.md** - Understand your machine differences
3. **Test in air** - No tool, safe Z height, soft limits enabled
4. **Use feed override** - Start at 10-25% for initial testing
5. **Document modifications** - Keep notes on what you change
6. **Verify persistence** - Test variable storage before relying on it

---

## Contributing

This is a living documentation project. If you:
- Find bugs or errors in macros
- Discover new controller quirks
- Develop useful macros or patterns
- Have hardware configuration insights

Feel free to open an issue or submit a pull request!

---

## Community Acknowledgments

This skill incorporates knowledge from:
- **Nikolay Zvyagintsev** - Advanced mathematics formulas
- **DDCS Expert community** - Proven patterns and solutions
- **Official DDCS documentation** - Verified against V1.22 firmware
- **Production testing** - Ultimate Bee 1010 real-world validation

---

## Support & Resources

**This Repository**: Documentation and skill downloads  
**DDCS Official**: Manufacturer documentation and firmware updates  
**CNC Communities**: Forums and user groups for general CNC support

**This is a documentation project, not a support channel**

---

## File Format

The `.skill` file is a **zip archive** containing all documentation and reference materials in an organized structure.

**To extract** (optional): Rename `.skill` → `.zip` and extract with any zip utility  
**To use**: Simply upload to Claude - no extraction needed

---

## License

**Documentation**: Shared for educational and reference purposes  
**Macros**: Use and modify freely, test thoroughly before production use  
**Community Knowledge**: Credit to original contributors where noted  

**No warranty expressed or implied. Use at your own risk.**

---

## Quick Reference Links

**Essential Reading:**
- CORE_TRUTH.md - Controller quirks and workarounds
- SKILL.md - Main navigation and index

**Problem Solvers:**
- pnp-to-npn-converter.md - PNP probe compatibility fix
- variable-priming-card.md - Variable washing bug workaround
- virtual-buttons-2037.md - Complete automation guide

**Reference Materials:**
- user-storage-map.md - Persistent variable allocation
- hardware-config.md - Complete machine documentation
- firmware-backup-2025-12-31/ - Actual controller firmware

---

**Download the latest `.skill` file and import into Claude for comprehensive DDCS Expert M350 knowledge!**

**Repository**: https://github.com/fchabot-dxf/DDCS-Expert-skill
