; Final Project
; Program to calculate the minimum, maximum, and average test scores of 5 inputted test scores.
; Ethan Ortega, Tyler Cox, Monteserrat Castellanos, 12 May 2022, CIS-11

.orig x3000
AND R0, R0, X0		; non-consequential statement to start program on (every time I re-ran the program,
			; it would always skip the first statement for some reason)
JSR MPROMPT		; print main prompt

; first, get the 5 test scores
        AND R5, R5, #0	; clear R5
        ADD R5, R5, #5	; counter to keep track of how many test scores have been entered
	LD R6, BASE	; load base of stack
LOOP    JSR INPUT	; input a test score
        ADD R5, R5, #-1	; decrement counter
        BRp LOOP	; loop until 5 test scores are submitted
	PUTS		; print new line

; second, calculate the average, minimum, and maximum test scores
	JSR FINDMAX	; find maximum score
        JSR FINDMIN	; find minimum score
	JSR AVG		; get average score	
	STI R4, AVERAGE	; store average score

; third, print the results

	LDI R5, MAX	
        LEA R0, TEXT	
        JSR OUTPUT

	LDI R5, MIN
        LEA R0, TEXT
	ADD R0, R0, #11	; get min text
	ADD R0, R0, #12
        JSR OUTPUT

	LDI R5, AVERAGE	
        LEA R0, TEXT
	ADD R0, R0, #12	; get average text
	ADD R0, R0, #12
	ADD R0, R0, #12
	ADD R0, R0, #10
        JSR OUTPUT
	
	HALT		; end program execution


; subroutines --------------------------------------------------------


; subroutine to input test score
INPUT   ST R7, SAVEREG7		; save return address (since it will be overridden)
	STI R5, SAVEREG5	; save counter
	AND R0, R0, #0		; clear registers 0-4
        AND R1, R1, #0
        AND R4, R4, #0
        AND R2, R2, #0
        AND R3, R3, #0
	; print the prompt
        	LEA R0, PROMPT		; get prompt
        	PUTS			; print prompt
	; get first digit
        	GETC			; get number inputted
        	ADD R2, R0, x0  	; copy input into register 2
        ; offset first inputted digit
        	ADD R2, R2, #-16        ; offset at 16
        	ADD R2, R2, #-16        ; offset at 32
        	ADD R2, R2, #-16        ; offset at 48
        	OUT                     ; output number to user
        	; ADD R4, R2, #-1         ;R4 = OFFSET 1 from R2, THIS IS DONE FOR INPUT VALIDATION 0-1 for 10s place
        	; BRp ERROR               ;GO TO ERROR IF INPUT IS LARGER THAN 1
        	; AND R4, R4, x0          ;Clearing R4 to use Again
        ; get second digit
		GETC                    ; get second number inputted
        	ADD R3, R0, x0          ; copy input into register 3
        ; offset second inputted digit
       		ADD R3, R3, #-16        ; offset at 16
        	ADD R3, R3, #-16        ; offset at 32
        	ADD R3, R3, #-16        ; offset at 48
        	OUT                     ; output to user
        	; ADD R4, R3, #-9         ;R4 = OFFSET 9 from R3, THIS IS DONE FOR INPUT VALIDATION 0-9 for 1s place
        	; BRp ERROR               ;GO TO ERROR IF INPUT IS LARGER THAN 9
	; get third digit
		GETC			; get third number inputted
		ADD R4, R0, X0		; copy input into register 4
	; offset third inputted digit
       		ADD R4, R4, #-16        ; offset at 16
        	ADD R4, R4, #-16        ; offset at 32
        	ADD R4, R4, #-16        ; offset at 48
		OUT			; output to user
        ; calculate hundreds place digit
		LD R5, HUNDRED		; R5 = #100
		JSR MULT		; R1 = hundreds place digit
		ADD R0, R1, X0		; place R1 into R0
	; calculate tens place digit
		AND R5, R5, X0		; clear R5
		ADD R5, R5, XA		; R5 = #10
		ADD R2, R3, X0		; place R3 into R2
		JSR MULT		; R1 = tens place digit
		ADD R0, R0, R1		; add tens place to hundreds place
	; finalize
		ADD R4, R4, R0		; add ones place
		JSR PUSH		; store inputted value into stack
	; print a new line & exit
        	AND R0, R0, #0 		; clear R0
        	LEA R0, LF		; load new line
        	PUTS			; print new line
        	LD R7, SAVEREG7		; load return address
		LDI R5, SAVEREG5	; restore counter
        	RET			; return

; multiplication subroutine (R1 will = product, R2 = x, R5 = y)
MULT	
; check if x = 0 (in this program, y will never equal 0 so don't check for it)
	AND R1, R1, X0	; clear R1
	ADD R2, R2, X0	; check x
	BRnz PRODUCT	; product equals 0/invalid

; add x to R1 y times
MLOOP	ADD R5, R5, X-1	; decrement y
	BRn PRODUCT	; break if y < 0
	ADD R1, R2, R1	; R0 = R0 + x
	BR MLOOP	; loop
PRODUCT	RET		; return

; push subroutine (R4 = input, R6 = stack location)
PUSH	STR R4, R6, X0	; store R4 into address held in R6
	ADD R6, R6, X-1	; move up stack
	RET		; return

; pop subroutine (R4 will = output, R6 = stack location)
POP	ADD R6, R6, X1	; move down stack
	LDR R4, R6, X0	; load R4 with value at address held in R6
	RET		; return

; maximum score subroutine (uses all registers)
FINDMAX		ST R7, SAVEREG7	; save register 7 (since it will be overridden)
                LD R6, TBASE	; load top of stack + 1
                ADD R6, R6, #1	; go down the stack by one
                LDR R0, R6, #0	; save top value in stack
                STI R0, MAX	; Store top of stack as max to be compared
		AND R3, R3, #0	; init R3
		ADD R3, R3, #5	; Start counter
		
LOOP2		JSR POP
		LDI R1, MAX	; LD current Max into R1
		NOT R2, R4	; 1s comp
		ADD R2, R2, #1	; 2s comp
		ADD R5, R2, R1	; subtract
		BRn NEW		; check if value is less than or greater than current max

                ADD R3, R3 #-1  ; decrement
		BRP LOOP2
                LD R7, SAVEREG7
                RET

NEW		STI R4, MAX	; if value is greater than current max, make that value new 
		ADD R3, R3 #-1  ; decrement
		BRP LOOP2	; loop back up
                LD R7, SAVEREG7
                RET

; minimum score subroutine (uses all registers)	
FINDMIN         ST R7, SAVEREG7	; save register 7 (since it will be overridden)
                LD R6, TBASE	; load top of stack + 1
                ADD R6, R6, #1	; go down the stack by one
                LDR R0, R6, #0	; save top value in stack
                STI R0, MIN	; Store top of stack as max to be compared
		AND R3, R3, #0	; init R3
		ADD R3, R3, #4	; Start counter
		
LOOP3		JSR POP
		LDI R1, MIN	; LD current Min into R1
		NOT R2, R4	; 1s comp
		ADD R2, R2, #1	; 2s comp
		ADD R5, R2, R1	; subtract
		BRp NEW2	; check if value is less than or greater than current max

                ADD R3, R3 #-1  ; decrement
		BRP LOOP3
                LD R7, SAVEREG7
                RET

NEW2		STI R4, MIN	; if value is greater than current max, make that value new 
		ADD R3, R3 #-1  ; decrement
		BRP LOOP3	; loop back up
                LD R7, SAVEREG7
                RET

; print subroutine (R0 = current test score being printed (string), R5 = test score being analyzed, uses all registers)
OUTPUT  
; initialize    
	ST R7, SAVEREG7	; save R7
	AND R1, R1, X0	; clear R1 for storing digits
	LD R6, ASCII	; load ASCII offset into R6
	AND R3, R3, X0
        PUTS		; print info that states what is being displayed

; calculate digits
	; find hundreds place
	LD R2, HUNDRED	; R2 = #100
	JSR DIV		; R4 = R5 / 100, R5 = R5 % 100
	ADD R1, R4, X0	; place hundreds digit in R1
	; find tens & ones place
	AND R2, R2, X0	; clear R2
	ADD R2, R2, XA	; R2 = #10
	JSR DIV		; R4 = R5 / 10, R5 = R5 % 10
	; R1 = hundreds place, R4 = tens place, R5 = ones place

; print digits
	; print hundreds place
	ADD R1, R1, X0	; load R1 to check
	BRnz SKIP1	; do not print if hundreds place is 0
	ADD R0, R1, R6	; move R1 to R0 w/ ASCII offset
	OUT		; print hundreds place
	BR SKIP1A	; DO NOT check tens place if hundreds place != 0
	; print tens place
SKIP1	ADD R4, R4, X0	; load R4 to check
	BRnz SKIP2	; do not print if hundreds & tens place is 0
SKIP1A	ADD R0, R4, R6	; move R4 to R0 w/ ASCII offset
	OUT		; print tens place
	; print ones place
SKIP2	ADD R0, R5, R6	; move R5 to R0 w/ ASCII offset
	OUT		; print ones place

; calculate letter grade
	LEA R0, LGRADE	; load letter grade array
	; check hundreds place first
	ADD R1, R1, X0	; load R1
	BRp GRADEA	; "A" if hundreds place is >= 1
	; check tens place next
	ADD R1, R4, X-9	; R1 = tens digit - 9
	BRz GRADEA	; "A" if tens place = 9
	ADD R1, R4, X-8	; R1 = tens digit - 8
	BRz GRADEB	; "B" if tens place = 8
	ADD R1, R4, X-7	; R1 = || - 7
	BRz GRADEC	; "C" if || = 7
	ADD R1, R4, X-6	; R1 = || - 6
	BRz GRADED	; "D" if || = 6
	BR GRADEF	; "F" if || < 6

GRADEA	PUTS		; print " A"
	BR GCALCD	; grade calculation done
GRADEB	ADD R0, R0, X3	; go to next array element
	PUTS		; print " B"
	BR GCALCD
GRADEC	ADD R0, R0, X6
	PUTS		; print " C"
	BR GCALCD
GRADED	ADD R0, R0, X9
	PUTS		; print " D"
	BR GCALCD
GRADEF	ADD R0, R0, #12
	PUTS		; print " F"

GCALCD  LEA R0, LF	
        PUTS	
        LD R7, SAVEREG7	
        RET

; average subroutine (R4 will = average, uses R3-7)
AVG	; initialize
	ST R7, SAVEREG7	; save return address (since it will be overridden)
	LD R6, TBASE	; load top of stack
	AND R5, R5, X0	; clear R5
	AND R3, R3, X0	; clear R3
	ADD R3, R3, X5	; counter to help check entire stack
AVGLOOP	
	; get sum of all test scores in stack
	JSR POP		; get first/next number from stack
	ADD R5, R5, R4	; R5 = R5 + next number obtained from stack
	ADD R3, R3, X-1	; decrement counter
	BRp AVGLOOP	; keep adding until every number in stack has been added	
	AND R2, R2, X0	; clear R2
	ADD R2, R2, X5	; R2 = 5 (to divide sum by 5)
	JSR DIV		; R4 = sum / 5
	; return
	LD R7, SAVEREG7	; load return address
	RET		; return

; division subroutine (R5 = dividend, R2 = divisor, R5 will = remainder, R4 will = quotient, uses R2, & R4-5)
DIV	; initialize
	AND R4, R4, X0	; clear R4 (quotient)
	NOT R2, R2	; negate R2
	ADD R2, R2, X1
DIVLOOP	; subtract R2 from R5 until R5 is negative or 0
	ADD R5, R5, R2	; R5 = R5 - R2
	BRn DLDONE	; break if R5 < 0
	ADD R4, R4, X1	; increment quotient
	ADD R5, R5, X0	; load R5
	BRz DIVDONE	; return if R5 = 0 (perfect division)
	BR DIVLOOP	; loop
DLDONE	; fix remainder
	NOT R2, R2
	ADD R2, R2, X1	; negate R2 again
	ADD R5, R5, R2	; correct remainder
DIVDONE	RET		; return

; print main prompt subroutine (prompt is too far away for code to reach & is too large to put closer, I assume anyway)
MPROMPT	ST R7, SAVEREG7		; save return address (since it will be overridden)
	LEA R0, MAINPROMPT	; load main prompt 1
	PUTS			; print
	LEA R0, MAINPROMPT2	; load main prompt 2
	PUTS			; print
	LD R7, SAVEREG7		; load return address
	RET			; return


; data --------------------------------------------------------------
; (i) = input, (c) = caluclated during execution, no () = constant


HUNDRED		.FILL X64	; #100
ASCII		.FILL X30	; ASCII offset

BASE		.FILL X4000	; base of test score stack
TBASE		.FILL X3FFB	; top of stack + 1

MAX        	.FILL x3200     ; (c) saves Max Value
MIN        	.FILL x3201     ; (c) saves Min Value
AVERAGE		.FILL X3202	; (c) average test score

SAVEREG5	.FILL X3203	; (c) saves register 5 (to preserve counter data)
SAVEREG7        .FILL X3204     ; (c) saves register 7 (for subroutines within subroutines)

TEXTOFFSET	.FILL #23	; how large each end result text box is
LF      	.STRINGZ "\n"
PROMPT 		.STRINGZ "ENTER TEST SCORE: "	
TEXT		.STRINGZ "The highest score is: "
	        .STRINGZ "The lowest score is:  "
		.STRINGZ "The average score is: "

LGRADE		.STRINGZ " A"
		.STRINGZ " B"
		.STRINGZ " C"
		.STRINGZ " D"
		.STRINGZ " F"

MAINPROMPT	.STRINGZ "This program will find the minimum, maximum, and average\nof 5 inputted test scores. Please enter the scores in the\n"
MAINPROMPT2	.STRINGZ "format of \"000\", ranging from 0-100. If the score does\nnot have a hundreds or hundreds & tens place, please fill\nin those spaces with a 0.\n\n"

.END
