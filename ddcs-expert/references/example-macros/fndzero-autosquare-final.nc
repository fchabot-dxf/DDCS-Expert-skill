(AUTO-SQUARING HOMING - AUTO-CALIBRATED + MANUAL TRIM)
(Automatically measures Y1-Y2 switch offset and applies correction)
(Plus manual frame calibration offset for final adjustment)
(Y2 = Reference switch, Y1 = Home switch)

(MANUAL FRAME CALIBRATION - Adjust after test cuts)
#121 = 0.0    (Frame calibration offset in mm)
              (Cut test square, measure diagonals, adjust this value)
              (This corrects for frame not being perfectly square)

(Home Z first - safety)
M98P501X2

(Home X first)
M98P501X0

(AUTO-SQUARE Y-AXIS ROUTINE)
#1503 = 1(Auto-squaring Y-axis - measuring switches...)

(Load Y-axis homing parameters from controller)
#100 = 1                    (Y-axis number)
#103 = #608                 (Y homing speed)
#104 = #613                 (Y homing direction)
#105 = ABS[#623]            (Back-off distance from controller)

(Calculate back-off direction)
#106 = [1*[1-#104]]-#104

(Ensure slaving enabled)
#991 = 1
#655 = 0                    (Disable soft limits)

(STEP 1: Measure Y2 switch position)
#101 = #1054                (Y2 input - triggers first)
#102 = #1056                (Y2 active level)

M98P503X#100                (Home to Y2)
#107 = #881                 (Save Y2 position)
G91 G01 Y[#106*#105] F150   (Back off)

(STEP 2: Measure Y1 switch position)
#101 = #1048                (Y1 input - triggers second)
#102 = #1050                (Y1 active level)

M98P503X#100                (Home to Y1)
#108 = #881                 (Save Y1 position)

(STEP 3: Calculate calibration offset automatically)
#120 = #108 - #107          (Calibration = Y1_position - Y2_position)

#1510 = #120
#1503 = 1(Switch offset measured: %.3f mm)
G04 P1500

(STEP 4: Now do actual squaring with both together)
(Zero at Y1 - the actual home position)
G91 G01 Y[#106*#105] F150   (Back off from Y1)

#101 = #1048                (Y1 input - REAL HOME)
#102 = #1050                (Y1 active level)

M98P503X#100                (Home to Y1 - this is machine zero)
#881 = 0                    (Zero at Y1 - real home position)
G91 G01 Y[#106*#105] F150   (Back off)

(Home to Y2 - measure the difference)
#101 = #1054                (Y2 input - reference switch)
#102 = #1056                (Y2 active level)

M98P503X#100                (Home to Y2)

(STEP 5: Calculate correction with both offsets)
#109 = #881 - #120          (Remove switch offset → pure racking)
#110 = #109 + #121          (Add frame calibration → final correction)

#1510 = #881
#1503 = 1(Raw measurement: %.3f mm)
G04 P1000

#1510 = #109
#1503 = 1(After switch offset: %.3f mm)
G04 P1000

#1510 = #110
#1503 = 1(Final correction: %.3f mm)
G04 P1000

(STEP 6: Apply correction)
#991 = 3                    (Break slave)
G91 G01 Y[0-#110] F50       (Move Y1 back by final correction)
#881 = 0
#883 = 0

(STEP 7: Finish)
#991 = 1                    (Re-enable slaving)
G91 G01 Y[#106*#105] F150   (Back off together)

#1516 = 1
#1518 = 1
#655 = 1

(Home B-axis rotary)
M98P501X4
#1519 = 1

(MSG, AUTO-SQUARING COMPLETE)
M30


