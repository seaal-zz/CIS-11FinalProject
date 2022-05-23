; Final Project
; Program to calculate the minimum, maximum, and average test scores of 5 inputted test scores.
; Ethan Ortega, Tyler Cox, Monteserrat Castellanos, 12 May 2022, CIS-11

.orig x3000

        AND R5, R5, #0
        ADD R5, R5, #5
	LD R6, BASE		; load base of stack
LOOP    JSR INPUT
        ADD R5, R5, #-1
        BRp LOOP

        JSR FINDMAX
        JSR FINDMIN
        JSR AVG		; get average score	
	STI R4, AVERAGE	; store average score

        LDI R4, MAX
        JSR DIV2
        ;10s place in R5, ones place in R4
        LEA R0, MAXTEXT
        JSR OUTPUT

        LDI R4, MIN
        JSR DIV2
        LEA R0, MINTEXT
        JSR OUTPUT

        LDI R4, AVERAGE
        JSR DIV2
        LEA R0, AVETEXT
        JSR OUTPUT







        HALT
INPUT   ST R7, SAVEREG7
	AND R0, R0, #0
        AND R1, R1, #0
        AND R4, R4, #0
        AND R2, R2, #0
        AND R3, R3, #0
        LEA R0, PROMPT
        PUTS
        GETC
        ADD R2, R0, x0          ;Copy  input into Register 2
        ;offset digit in 10s place
        ADD R2, R2, #-16        ;offset at 16
        ADD R2, R2, #-16        ;offset at 32
        ADD R2, R2, #-16        ;offset at 48
        OUT                     ;ouput to user
        ; ADD R4, R2, #-1         ;R4 = OFFSET 1 from R2, THIS IS DONE FOR INPUT VALIDATION 0-1 for 10s place
        ; BRp ERROR               ;GO TO ERROR IF INPUT IS LARGER THAN 1
        ; AND R4, R4, x0          ;Clearing R4 to use Again
        GETC                    ;reading 1s place
        ADD R3, R0, x0          ;Copy into register 3
        ;offset digit in 1s place
        ADD R3, R3, #-16        ;offset at 16
        ADD R3, R3, #-16        ;offset at 32
        ADD R3, R3, #-16        ;offset at 48
        OUT                     ;ouput to user
        ; ADD R4, R3, #-9         ;R4 = OFFSET 9 from R3, THIS IS DONE FOR INPUT VALIDATION 0-9 for 1s place
        ; BRp ERROR               ;GO TO ERROR IF INPUT IS LARGER THAN 9
        AND R0, R0, #0
        LEA R0, LF
        PUTS
        
        LD R4, TEN              ;used to multiply by 10
        JSR BY10
        AND R4, R4, #0          ;Clearing R4 to use Again
        ADD R4, R1, R3
	JSR PUSH		; store inputted value into stack
        LD R7, SAVEREG7
        RET
        
BY10    ADD R1, R1, R2          ;Multiplying by 10
        ADD R4, R4, #-1
        BRP BY10
        ADD R1, R1, x0
        RET

; push subroutine (R4 = input, R6 = stack location)
PUSH	STR R4, R6, X0	; store R4 into address held in R6
	ADD R6, R6, X-1	; move up stack
	RET		; return

; pop subroutine (R4 = output, R6 = stack location)
POP	ADD R6, R6, X1	; move down stack
	LDR R4, R6, X0	; load R4 with value at address held in R6
	RET		; return

; data -----------------------------------------------
; (i) = input, (c) = caluclated during execution, no () = constant


FINDMAX	        ST R7, SAVEREG7
                LD R6, TBASE
                ADD R6, R6, #1
                LDR R0, R6, #0
                STI R0, MAX		;Store top of stack as max to be compared
		AND R3, R3, #0	;init R3
		ADD R3, R3, #5	;Start counter
		
LOOP2		JSR POP
		LDI R1, MAX	;LD current Max into R1
		NOT R2, R4		;1s comp
		ADD R2, R2, #1	;2s comp
		ADD R5, R2, R1	; subtract
		BRn NEW		;check if value is less than or greater than current max

                ADD R3, R3 #-1  	;decrement
		BRP LOOP2
                LD R7, SAVEREG7
                RET

NEW		STI R4, MAX		;if value is greater than current max, make that value new 
		ADD R3, R3 #-1  	;decrement
		BRP LOOP2		;loop back up
                LD R7, SAVEREG7
                RET

		
FINDMIN         ST R7, SAVEREG7
                LD R6, TBASE
                ADD R6, R6, #1
                LDR R0, R6, #0
                STI R0, MIN		;Store top of stack as max to be compared
		AND R3, R3, #0	;init R3
		ADD R3, R3, #4	;Start counter
		
LOOP3		JSR POP
		LDI R1, MIN	;LD current Min into R1
		NOT R2, R4		;1s comp
		ADD R2, R2, #1	;2s comp
		ADD R5, R2, R1	; subtract
		BRp NEW2	;check if value is less than or greater than current max

                ADD R3, R3 #-1  	;decrement
		BRP LOOP3
                LD R7, SAVEREG7
                RET

NEW2		STI R4, MIN		;if value is greater than current max, make that value new 
		ADD R3, R3 #-1  	;decrement
		BRP LOOP3		;loop back up
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

;Converting to characters---------------
DIV2   
        ;check if number is 3 digits

        ;R4 = number to be divided
        AND R5, R5, #0
        AND R6, R6, #0
        AND R0, R0, #0  ;clear register for divisor
        ADD R0, R0, #10  ;divisor = 10
        ADD R6, R0, #0  ;Y into R6
        NOT R0, R0
        ADD R0, R0, #1  ;divisor = -10
        ; ADD R0, R3, R4  ;Subtract X by Y
        ; ; BRn QUIT2
LOOP4   ADD R5, R5, #1
        ADD R4, R4, R0
        BRp LOOP4       ;if positive, go back to loop
        BRz QUIT3       ;if 0, got to quit3
        ADD R4, R4, R6  ;if neg, add result + Y
        ADD R5, R5, #-1 ;if neg, add the counter + 1
        BR QUIT3
QUIT3   RET
;---------------------------------------

OUTPUT          ST R7, SAVEREG7
                PUTS
                AND R0, R0, #0
                ADD R5, R5, #15        ;offset at 16
                ADD R5, R5, #15        ;offset at 32
                ADD R5, R5, #15        ;offset at 48
                ADD R5, R5, #3
                ADD R0, R5, R0
                OUT

                AND R0, R0, #0
                ADD R4, R4, #15       ;offset at 16
                ADD R4, R4, #15        ;offset at 32
                ADD R4, R4, #15        ;offset at 48
                ADD R4, R4, #3
                ADD R0, R4, R0
                OUT

                LEA R0, LF
                PUTS
                LD R7, SAVEREG7
                RET



TEN .FILL x000A

PROMPT          .STRINGZ "ENTER TEST SCORE: "
MAXTEXT         .STRINGZ "The highest score is: "
MINTEXT         .STRINGZ "The lowest score is: "
AVETEXT         .STRINGZ "The average score is: "
LF              .STRINGZ "\n"

MAX             .FILL x3100          ;Saves Max Value
MIN             .FILL x3101          ;Saves Min Value

BASE		.FILL X4000	; base of test score stack
TBASE		.FILL X3FFB	; top of stack
; NBASE		.FILL XC000	; negative base (unused, was going to be used for stack validation)

SAVEREG7        .FILL X3200     ; (c) saves register 7 (for subroutines within subroutines)
AVERAGE		.FILL X3201	; (c) average test score

.END
