# Advanced MacroB Mathematics - Formula Library

**Author**: Nikolay Zvyagintsev (Николай Звягинцев)  
**Source**: Russian DDCS M350 community  
**Purpose**: Efficient mathematical operations without IF statements

This document provides pre-built mathematical formulas for common MacroB programming tasks. These formulas are optimized for the M350 controller and often more efficient than using multiple IF/GOTO statements.

---

## Sign Determination Functions

### Convert Sign (±) to 1 or -1

**Analog of sgn(x) function:**

```gcode
; If X is negative → -1
; If X is positive → 1
; If X = 0 → ERROR (division by zero)

#result = ABS[X] / X
```

**Inverted (negate):**
```gcode
#result = 0 - ABS[X] / X
```

**Safe versions (handle X=0):**
```gcode
; For integers only - If X=0, result is 1
#result = ABS[X+0.1] / [X+0.1]

; For integers only - If X=0, result is -1
#result = ABS[X-0.1] / [X-0.1]
```

**Example - Apply sign of one variable to magnitude of another:**
```gcode
#1 = 16   ; Distance (always positive)
#2 = 30   ; Direction and distance (positive or negative)

; Apply sign of #2 to magnitude of #1
#1 = #1 * [ABS[#2] / #2]
; If #2=30, result: 16
; If #2=-30, result: -16
```

---

### Convert Sign (±) to 1 or 0

**If negative → 0, if positive → 1:**
```gcode
#result = [ABS[X] + X] / 2 / X
; X=0 → ERROR
```

**Safe versions:**
```gcode
; If X=0 → result is 1
#result = [ABS[X+0.1] + X + 0.1] / 2 / [X+0.1]

; If X=0 → result is 0
#result = [ABS[X-0.1] + X - 0.1] / 2 / [X-0.1]
```

**Inverted (negative → 1, positive → 0):**
```gcode
#result = 0 - [ABS[X] - X] / 2 / X
; X=0 → ERROR

; If X=0 → result is 1
#result = 0 - [ABS[X-0.1] - X + 0.1] / 2 / [X-0.1]

; If X=0 → result is 0
#result = 0 - [ABS[X+0.1] - X - 0.1] / 2 / [X+0.1]
```

---

## Equality Checking

### Check if Two Values Are Equal

**Returns 1 if X=Y, otherwise 0:**

**Method 1 - Trigonometric (limited range):**
```gcode
#result = FIX[COS[X-Y]]
; CAUTION: cos(102-3) gives negative, use ABS version:
#result = FIX[ABS[COS[X-Y]]]
```

**Method 2 - Sine based:**
```gcode
#result = 1 - FUP[ABS[SIN[X-Y]]]
```

**Method 3 - Arithmetic:**
```gcode
#result = 1 - FUP[ABS[0.1 * [X-Y]]]
```

**Method 4 - Most reliable:**
```gcode
#result = [[1 - ABS[X-Y]] + ABS[1 - ABS[X-Y]]] / 2
```

**Inverted (returns 0 if X=Y, otherwise 1):**
```gcode
; Trigonometric
#result = 1 - FIX[ABS[COS[X-Y]]]

; Sine based
#result = FUP[ABS[SIN[X-Y]]]

; Arithmetic
#result = FUP[ABS[0.1 * [X-Y]]]

; Most reliable
#result = 1 - [[[1 - ABS[X-Y]] + ABS[1 - ABS[X-Y]]] / 2]
```

---

### Special Case - Binary Format (0-1)

**When X and Y are binary (0 or 1):**

```gcode
; Returns 1 if X=Y, otherwise 0
#result = ABS[X + Y - 1]
```

**Use case:** Comparing port state with configured trigger level

---

## Axis Number Translation

### Convert Axis Number to Coordinate Offset

**Standard method:**
```gcode
#8 = 1    ; Axis number (1=X, 2=Y, 3=Z)
#9 = 15   ; Distance and direction

#3 = 0    ; X offset
#4 = 0    ; Y offset
#5 = 0    ; Z offset

#[2+#8] = #9    ; Assign distance to selected axis

G91 G0 X#3 Y#4 Z#5
; If #8=1 → moves X15
; If #8=2 → moves Y15
; If #8=3 → moves Z15
```

---

## Binary Logic Operations

### AND Operation (Binary Format)

**If X=1 AND Y=1 → result is 1, else 0:**
```gcode
#result = FIX[[X + Y] / 2]
```

---

### Conditional Value Selection

**Using binary condition (0-1 format):**

```gcode
; X, Y are integers
; Z is binary (0 or 1)

; If X=Y → result = Z
; If X≠Y → result = NOT Z
#result = ABS[1 - FIX[COS[X-Y]] - Z]

; If X=Y → result = NOT Z
; If X≠Y → result = Z
#result = ABS[FIX[COS[X-Y]] - Z]
```

---

## Min/Max Calculations

### Minimum Value

**Returns minimum of X and Y:**

```gcode
; Long version
#min = X - [[[X - Y] + ABS[X - Y]] / 2]

; Simplified version (recommended)
#min = [X + Y - ABS[X - Y]] / 2
```

**Example:**
```gcode
#1 = 10
#2 = 25
#3 = [#1 + #2 - ABS[#1 - #2]] / 2
; #3 = 10 (minimum)
```

---

### Maximum Value

**Returns maximum of X and Y:**

```gcode
; Long version
#max = X - [[[Y - X] + ABS[Y - X]] / 2]

; Simplified version (recommended)
#max = [X + Y + ABS[X - Y]] / 2
```

**Example:**
```gcode
#1 = 10
#2 = 25
#3 = [#1 + #2 + ABS[#1 - #2]] / 2
; #3 = 25 (maximum)
```

---

## Format Conversions

### Binary (0-1) to Signed (-1 to 1)

```gcode
; If X=0 → result is -1
; If X=1 → result is 1
#result = X * 2 - 1

; Inverted
; If X=0 → result is 1
; If X=1 → result is -1
#result = 1 - X * 2
```

---

### Signed (-1 to 1) to Binary (0-1)

```gcode
; If X=1 → result is 0
; If X=-1 → result is 1
#result = [1 - X] / 2

; Inverted
; If X=1 → result is 1
; If X=-1 → result is 0
#result = [1 + X] / 2
```

---

### Positive Number to Binary (0-1)

**Convert 0 or positive number to binary:**

```gcode
; If X=0 → result is 0
; If X>0 → result is 1
#result = FUP[X / [X + 0.1]]
```

**Inverted:**
```gcode
; If X=0 → result is 1
; If X>0 → result is 0
#result = 1 - FUP[X / [X + 0.1]]
```

---

## Value Inversions

### Simple Inversions

```gcode
; Invert sign (+ to -, - to +)
#result = -X

; Invert -1 and 1
#result = 0 - X

; Invert 1 and 0
#result = 1 - X

; Invert 1 and 2
#result = 3 - X

; Invert 2 and 3
#result = 5 - X

; Invert 4 and 5
#result = 9 - X
```

**Pattern**: For values N and N+1, use `(N + N+1) - X`

---

## Even/Odd Detection

### Return 1 or 0

**Works for positive and negative numbers:**

```gcode
; If X is odd → 1, if even → 0
#result = ABS[X - FIX[X/2] * 2]

; If X is odd → 0, if even → 1
#result = 1 - ABS[X - FIX[X/2] * 2]
```

**Example:**
```gcode
#1 = -4
#2 = ABS[#1 - FIX[#1/2] * 2]
; #2 = 0 (even)

#1 = 7
#2 = ABS[#1 - FIX[#1/2] * 2]
; #2 = 1 (odd)
```

---

### Return 1 or -1

```gcode
; If X is odd → 1, if even → -1
#result = ABS[X - FIX[X/2] * 2] * 2 - 1

; If X is odd → -1, if even → 1
#result = 1 - ABS[X - FIX[X/2] * 2] * 2
```

---

## Loop Optimization

### Variable Economy in Loops

**Example - Probe contact checking:**

```gcode
#1080 ; Floating Probe signal effective level (0 or 1)
#[1519+#1078] ; Port state variable (0 if closed)

#489 = 0
WHILE #489 < 70 DO 41
    ; Check contact equality and accumulate
    #489 = #489 + ABS[#[1519+#1078] + #1080 - 1] + 10
END41

; If reliable contact detected (≥70), proceed to retract
IF #489 - 70 >= #486 GOTO 308
```

**Uses equality formula:**
```gcode
ABS[#1 + #2 - 1]
; Returns 1 if #1 = #2, else 0
```

**Alternative - using trigonometric:**
```gcode
FIX[COS[#1 - #2]]
```

---

### Contact Verification

**Accumulated contact variable:**

```gcode
#24 ; Accumulated contact check variable

; Verify contact matches expected value
IF ROUND[#24/10 + 0.1] == #[1047 + #1*3] GOTO 1
#1505 = -5000(Bad contact detected)
N1
```

---

## Geometric Calculations

### Distance Between Two Points

**2D distance formula:**

```gcode
; Points: (x1, y1) and (x2, y2)
#length = SQRT[[x2 - x1] * [x2 - x1] + [y2 - y1] * [y2 - y1]]
```

**Example:**
```gcode
#1 = 10   ; x1
#2 = 20   ; y1
#3 = 40   ; x2
#4 = 60   ; y2

#5 = SQRT[[#3 - #1] * [#3 - #1] + [#4 - #2] * [#4 - #2]]
; #5 = 50 (distance)
```

---

### Move by Distance and Angle

**Polar to Cartesian conversion:**

```gcode
#1 ; Distance
#2 ; Angle in degrees

G91 G0 X[#1 * COS[#2]] Y[#1 * SIN[#2]]
```

**Note:** Use `SIN` not `COS[90-#2]` for Y - it's more direct.

**Example:**
```gcode
#1 = 100   ; Move 100mm
#2 = 45    ; At 45 degrees

G91 G0 X[#1 * COS[#2]] Y[#1 * SIN[#2]]
; Moves X70.71 Y70.71 (approximately)
```

---

### Calculate Angle (ATAN) Without Zeroing Axes

**Find angle from center to point:**

```gcode
#11 = 125   ; Point X position
#12 = -63   ; Point Y position
#21 = 90    ; Center X position
#22 = -120  ; Center Y position

#angle = ATAN[#12 - #22, #11 - #21]
```

**Using current work coordinates:**
```gcode
; #790 = current X WCS
; #791 = current Y WCS

#angle = ATAN[#791 - #22, #790 - #21]
```

---

### Convert ATAN from ±180° to 0-360°

**ATAN returns -180 to +180, convert to 0-360:**

**Method 1 - Using IF:**
```gcode
#36 = ATAN[#791, #790]
IF #36 >= 0 GOTO 1
#36 = #36 + 360
N1
```

**Method 2 - Single line (no IF):**
```gcode
#36 = ATAN[#791, #790] + 360 * [0 - [ABS[ATAN[#791, #790]] - ATAN[#791, #790]] / 2 / ATAN[#791, #790]]
```

**Warning:** If angle = 0, division by zero error occurs (extremely rare).

---

## Practical Examples

### Example 1: Directional Retract

**Apply retract distance in direction of measurement:**

```gcode
#1 = 5     ; Retract distance (always positive)
#2 = -30   ; Probe distance and direction

; Apply sign of probe direction to retract
#1 = #1 * [ABS[#2] / #2]
; Result: #1 = -5 (retract opposite to probe)
```

---

### Example 2: Safe Movement Selection

**Choose minimum safe distance:**

```gcode
#1 = 10    ; Calculated clearance
#2 = 5     ; Minimum safe clearance

; Use the smaller value for safety
#3 = [#1 + #2 - ABS[#1 - #2]] / 2
; Result: #3 = 5 (minimum)
```

---

### Example 3: Axis Selection Without IF

**Move specific axis by number:**

```gcode
#8 = 2     ; Axis: 1=X, 2=Y, 3=Z
#9 = 25    ; Distance

#3 = 0
#4 = 0
#5 = 0
#[2 + #8] = #9

G91 G0 X#3 Y#4 Z#5
; Moves Y25 (because #8=2)
```

---

### Example 4: Even/Odd Step Pattern

**Alternate direction on each pass:**

```gcode
#pass = 1
WHILE #pass <= 10 DO 1
    ; Calculate direction: odd=1, even=-1
    #dir = ABS[#pass - FIX[#pass/2] * 2] * 2 - 1
    
    G91 G0 X[10 * #dir]  ; Alternate +10, -10, +10...
    
    #pass = #pass + 1
END1
```

---

## Performance Notes

**Why use these formulas instead of IF statements?**

1. **Faster execution** - No conditional branching
2. **Shorter code** - Single line vs multiple lines
3. **Easier debugging** - Predictable execution path
4. **Variable economy** - No label numbers needed
5. **More elegant** - Mathematical vs procedural approach

**When to use IF instead:**

- Code clarity is more important than efficiency
- Complex multi-condition logic
- When the formula would be harder to understand than IF/GOTO

---

## Formula Quick Reference

```gcode
;=== SIGN FUNCTIONS ===
ABS[X]/X                    ; X→1, -X→-1
[ABS[X]+X]/2/X              ; X→1, -X→0

;=== EQUALITY ===
FIX[ABS[COS[X-Y]]]          ; X=Y→1, else→0
ABS[X+Y-1]                  ; Binary: X=Y→1, else→0

;=== MIN/MAX ===
[X+Y-ABS[X-Y]]/2            ; Minimum
[X+Y+ABS[X-Y]]/2            ; Maximum

;=== FORMAT CONVERSIONS ===
X*2-1                       ; 0-1 to -1-1
[1-X]/2                     ; -1-1 to 0-1
FUP[X/[X+0.1]]              ; Positive to binary

;=== INVERSIONS ===
1-X                         ; Invert 0-1
0-X                         ; Invert -1-1

;=== EVEN/ODD ===
ABS[X-FIX[X/2]*2]           ; Odd→1, Even→0

;=== GEOMETRY ===
SQRT[[X2-X1]*[X2-X1]+[Y2-Y1]*[Y2-Y1]]  ; Distance
X[R*COS[A]] Y[R*SIN[A]]                ; Polar to Cartesian
ATAN[Y2-Y1,X2-X1]                      ; Angle
```

---

## Credits

**Original formulas**: Николай Звягинцев (Nikolay Zvyagintsev)  
**Source**: Russian DDCS M350 community  
**Language**: Translated from Russian

These formulas represent years of community knowledge and optimization for DDCS M350 controllers.

---

**Remember**: Test all formulas in simulation before production use!
