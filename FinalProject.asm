; 

.orig x3000

        AND R5, R5, #0
        ADD R5, R5, #5
LOOP    JSR INPUT
        ADD R5, R5, #-1
        BRp LOOP
        HALT

INPUT   AND R0, R0, #0
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
        AND R4, R4, x0          ;Clearing R4 to use Again
        LEA R0, LF
        PUTS
        
        LD R4, TEN              ;used to multiply by 10
        ST R7, SAVEREG7
        JSR BY10 
        LD R7, SAVEREG7
        ADD R4, R1, R2
        RET
        
BY10    ADD R1, R1, R2          ;Multiplying by 10
        ADD R4, R4, #-1
        BRP BY10
        ADD R1, R1, x0
        RET

; push subroutine (R4 = input, R6 = stack location)
PUSH	STR R4, R6, X0	; store R4 into address held in R6
	ADD R6, R6, X-1	; move up stack

; pop subroutine (R4 = output, R6 = stack location)
POP	ADD R6, R6, X1	; move down stack
	LDR R4, R6, X0	; load R4 with value at address held in R6

; data
; (i) = input, (c) = caluclated during execution, no () = constant

TEN     .FILL x000A

PROMPT .STRINGZ "ENTER TEST SCORE: "
LF      .STRINGZ "\n"

BASE	.FILL X4000	; base of test score stack

SAVEREG7        .FILL X3200     ; saves register 7 (for subroutines within subroutines)
.END
