; Final Project
; Program to calculate the minimum, maximum, and average test scores of 5 inputted test scores.
; Ethan Ortega, Tyler Cox, Monteserrat Castellanos, 12 May 2022, CIS-11

.orig x3000

; first, get the 5 test scores
        AND R5, R5, #0	; clear R5
        ADD R5, R5, #5	; counter to keep track of how many test scores have been entered
	LD R6, BASE	; load base of stack
LOOP    JSR INPUT	; input a test score
        ADD R5, R5, #-1	; decrement counter
        BRp LOOP	; loop until 5 test scores are submitted

; second, calculate the average, minimum, and maximum test scores
	JSR FINDMAX	; find maximum score
        JSR FINDMIN	; find minimum score
	JSR AVG		; get average score	
	STI R4, AVERAGE	; store average score
	
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
	; print a new line
        	AND R0, R0, #0 		; clear R0
        	LEA R0, LF		; load new line
        	PUTS			; print new line
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
	; finalize & exit
		ADD R4, R4, R0		; add ones place
		JSR PUSH		; store inputted value into stack
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
	AND R4, R4, X0	; clear R4 (for counting quotient)
DIV	
	; divide sum by 5	
	ADD R5, R5, X-5	; subtract sum by 5
	BRn DIVDONE	; if R5 is negative, quotient has been found
	ADD R4, R4, X1	; increment R4 (will equal quotient)
	BR DIV		; loop
DIVDONE	
	; return
	LD R7, SAVEREG7	; load return address
	RET		; return


; data --------------------------------------------------------------
; (i) = input, (c) = caluclated during execution, no () = constant


HUNDRED		.FILL X64	; #100

PROMPT 		.STRINGZ "ENTER TEST SCORE: "
LF      	.STRINGZ "\n"

BASE		.FILL X4000	; base of test score stack
TBASE		.FILL X3FFB	; top of stack + 1

MAX        	.FILL x3200     ; (c) saves Max Value
MIN        	.FILL x3201     ; (c) saves Min Value
AVERAGE		.FILL X3202	; (c) average test score

SAVEREG5	.FILL X3203	; (c) saves register 5 (to preserve counter data)
SAVEREG7        .FILL X3204     ; (c) saves register 7 (for subroutines within subroutines)

.END
