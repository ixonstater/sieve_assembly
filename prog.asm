; Author: Joshua Jarvis

; Purpose: This is a program for checking whether or not a number is prime.  It uses
; the sieve of Eratosthenes to accomplish this task by sieving out all of the prime
; numbers up to a certain limit while checking for the following exit conditions:
; 1) The value of the primary multiplicative operand is not greater than the number being checked.
; 2) The product of the multiplicative operands is not equal to the number being checked.
; 3) The value of the primary mulitiplicative operand does not exceed the square root
;    of the largest number this program can process. (This is to avoid a situation
;    wherein integer "overflow" is reached and the lc3 begins to interpret positive numbers
;    as being negavtive.)

; I created this program as part of my course work for CS 2810 at UVU, it is entirely
; my own work.

; Entry point
.ORIG x3000
    JSR	mainLoop
HALT

; Main subroutine, here the program loops until the letter "q" is entered
mainLoop:
    LEA R0, BASIC_PROG_INFORMATION
    PUTS

    MAINLOOPLOOP LEA R0, CYCLIC_PROMPT
    PUTS
    JSR readInput ; Input value memory location is returned in R1
    LD R3, QUIT_NEG
    LDR	R4,	R1,	X0
    ADD R3, R3, R4
    BRz MAINLOOPEXIT

    JSR validateInput ; If value of register 3 is not 1 then start the loop over
    ADD R3, R3, -1
    BRnp MAINLOOPLOOP
    JSR isPrime
    BRnzp MAINLOOPLOOP

MAINLOOPEXIT HALT

QUIT_NEG .FILL XFF8F

; Prompts for main loop
BASIC_PROG_INFORMATION .STRINGZ	"This program checks whether a number is prime using the sieve of Eratosthenes.  Please enter only non-negative integer numbers less than 32,768. Enter q to exit the program.\r\n"
CYCLIC_PROMPT .STRINGZ "Please enter an integer number less than 32,766 that you would like to check followed by the enter key: \r\n"

; This subroutine reads the users input into five memory spaces before returning.
; Get the input string of characters from the user
; Store address of input memory into R1, store address of tens column into R2
; R6 and R2 contain the two return characters ascii values in the loop
readInput:
    AND R1, R1, X0
    LD R2, ENTER_KEY_NEG
    LD R6, OTHER_ENTER_KEY_NEG
    LEA R3, INPUT_VAL
    ST	R7,	RET_LOC

    READINPUTLOOP
    GETC
    OUT
    ADD R5, R0, R2
    BRz READINPUTEXIT
    ADD R5, R0, R6
    BRz READINPUTEXIT

    ADD R4, R3, R1
    STR	R0, R4, #0

    ADD R1, R1, 1
    ADD R5, R1, -5
    BRz READINPUTEXIT
    BRnzp READINPUTLOOP
    
    READINPUTEXIT 
    LEA R1, INPUT_VAL
    AND R2, R2, 0
    ADD R2, R2, R4
    LD R7, RET_LOC
RET

ENTER_KEY_NEG .FILL XFFF3
OTHER_ENTER_KEY_NEG .FILL XFFF6
RET_LOC .BLKW 1
INPUT_VAL .BLKW 5

; This subroutine validates the input string
; R1 Contains memory location of input digits
; R2 Contains the memory location of the ones column
; R3 Processing register
    ; -Holds the value of the digit being processed
; R3 Returns a boolean indicating valid / invalid

validateInput:
    ST	R7,	RET_LOC
    ST  R2, ONES_COLUMN

    VALIDATEINPUTLOOP
    LDR	R3,	R2,	X0
    LD R4, ASCII
    ADD R3, R3, R4
    BRn ERRORNOTDIGITEXIT
    ADD R4, R3, -10
    BRzp ERRORNOTDIGITEXIT
    STR	R3,	R2,	0
    NOT R4, R2
    ADD R4, R4, 1
    ADD R4, R4, R1
    BRz INPUTVALIDEXIT
    ADD R2, R2, -1
    BRnzp VALIDATEINPUTLOOP

    ERRORNOTDIGITEXIT
    LEA R0, ERROR_NOT_DIGIT
    AND R3, R3, 0
    PUTS
    LD R7, RET_LOC
RET
    INPUTVALIDEXIT
    AND R3, R3, 0
    ADD R3, R3, 1
    LD R7, RET_LOC
    LD R2, ONES_COLUMN
RET

; Prompts / error messages for input validation.
ASCII .FILL -48
ONES_COLUMN .FILL 0
ERROR_NOT_DIGIT .STRINGZ "Non-digit character encountered, digits 0-9 only please.\r\n"

; This is a wrapper for the subroutines that check whether the input number is prime or not.
isPrime:
    ST	R7,	RETLOCISPRIME
    JSR convertToNumber
    JSR sieveNumber
    LD R7, RETLOCISPRIME
RET
RETLOCISPRIME .FILL 0

; This subroutine uses the multiply and power subroutines to convert the input number to a single
; hexidecimal number which is returned in R1.
convertToNumber:
    ST	R7,	RETLOCCONVERT
    ST R2, CURRENTDIGIT
    ST R1, FINALDIGIT

    CONVERSIONLOOP
    LD R2, POWEROFTEN
    AND R1, R1, 0
    ADD R1, R1, 10
    JSR power

    ADD R1, R3, 0
    LD	R2,	CURRENTDIGIT
    LDR	R2,	R2,	0
    JSR multiply

    LD R1, CONVERTEDNUMBER
    ADD R1, R1, R3
    ST R1, CONVERTEDNUMBER

    LD R2, CURRENTDIGIT
    NOT R2, R2
    ADD R2, R2, 1
    LD R1, FINALDIGIT
    ADD R1, R2, R1
    BRz CONVERSIONEXIT
    LD R2, CURRENTDIGIT
    ADD R2, R2, -1
    ST R2, CURRENTDIGIT
    LD R2, POWEROFTEN
    ADD R2, R2, 1
    ST R2, POWEROFTEN
    BRnzp CONVERSIONLOOP

    CONVERSIONEXIT
    LD R7, RETLOCCONVERT
    LD R1, CONVERTEDNUMBER
    AND R2, R2, 0
    ST R2, POWEROFTEN
    ST R2, CONVERTEDNUMBER
RET

POWEROFTEN .FILL 0
CURRENTDIGIT .FILL 0
FINALDIGIT .FILL 0
CONVERTEDNUMBER .FILL 0
RETLOCCONVERT .FILL 0

; This subroutine multiplies two numbers passed to it.
; R1 contains the first operand
; R2 contains the second operand
; Result is returned in R3
multiply:
    ST	R7,	RETLOCMULTIPLY
    AND R3, R3, 0

    ADD R2, R2, 0
    BRz MULTIPLYEXITZERO
    ADD R1, R1, 0
    BRz MULTIPLYEXITZERO

    MULTIPLYLOOP
    ADD R3, R3, R2
    ADD R1, R1, -1
    BRnz MULTIPLYEXIT
    BRnp MULTIPLYLOOP
    MULTIPLYEXIT
    LD R7, RETLOCMULTIPLY
RET

    MULTIPLYEXITZERO
    LD R7, RETLOCMULTIPLY
    AND R3, R3, 0
RET

RETLOCMULTIPLY .FILL 0

; This subroutine applies the multiplication subroutine in a loop to return a power.
; R1 contains the base
; R2 contains the power
; Result is returned in R3
power:
    ST	R7,	RETLOCPOWER
    ST R1, BASE
    ST R2, EXP
    AND R3, R3, 0

    ADD R2, R2, 0
    BRz POWEREXITZERO

    POWERLOOP
    LD R2, RESULT
    JSR multiply
    ST R3, RESULT
    LD R2, EXP
    LD R1, BASE
    ADD R2, R2, -1
    BRz POWEREXIT
    ST R2, EXP
    BRnp POWERLOOP

    POWEREXITZERO
    LD R7, RETLOCPOWER
    AND R3, R3, 0
    ADD R3, R3, 1
RET
    POWEREXIT
    LD R7, RETLOCPOWER
    AND R1, R1, 0
    ADD R1, R1, 1
    ST R1, RESULT
RET

BASE .FILL 0
EXP .FILL 0
RESULT .FILL 1
RETLOCPOWER .FILL 0

; R1 contains converted number
; This subroutine is yet another wrapper to avoid values getting to far away from each other
; and causing runtime errors (because of addressability issues)
sieveNumber:
    ST R7, RETLOCSIEVENUM
    ST R1, NUMTOSEARCH
    JSR allocSieve
    LD R1, NUMTOSEARCH
    JSR sieveLoops
    LD R7, RETLOCSIEVENUM
RET
NUMTOSEARCH .FILL 0
RETLOCSIEVENUM .FILL 0

; This subroutine will allocate space for the sieve to operate, from a starting marker out to 32800 spaces.
; It is called each time the program runs.
allocSieve:
    ST R7, RETLOCALLOCSIEVE
    LEA R1, SIEVESTART

    LD R3, SIEVEMAX
    ADD R3, R3, R1
    NOT R3, R3
    ADD R3, R3, 1

    AND R2, R2, 0
    
    ALLOCSIEVELOOP
    STR	R2,	R1,	0
    ADD R4, R1, R3
    BRz ALLOCSIEVEEXIT
    ADD R1, R1, 1
    BRnp ALLOCSIEVELOOP

    ALLOCSIEVEEXIT
    LD R7, RETLOCALLOCSIEVE
RET
RETLOCALLOCSIEVE .FILL 0

; This is the big subroutine in this program.  It actually contains the logic to fill the sieve with the
; correct data to represent all primes up to a limit.  This is where the stopping conditions mentioned in
; the header are actuall implemented.  It does not return any information, rather it outputs information
; as it is discovered on each successive run.  It contains a doubly nested loop that runs through each
; successive number marking its multiplicative factors starting with 2 until one of the stopping conditions
; is reached.  Initialization was important in this subroutine and making sure that each variable was
; properly initialized took quite some time.

sieveLoops:
    ST R7, RETLOCSIEVELOOPS
    NOT R1, R1
    ADD R1, R1, 1
    ST R1, PRIMENUM
    AND R1, R1, 0
    ST R1, INNERLOOPCOUNT
    ADD R1, R1, -1
    ST R1, OUTERLOOPCOUNT
    
    SIEVEOUTERLOOP

    LD R3, OUTERLOOPCOUNT ; Increment outer loop count
    ADD R3, R3, 1
    ST R3, OUTERLOOPCOUNT
    ADD R3, R3, 2 ; Check to see if the outer loop count is bigger than the prime we are checking
    LD R2, PRIMENUM
    ADD R2, R2, R3
    BRp EXITNUMISPRIME
    LD R3, OUTERLOOPCOUNT
    ADD R3, R3, 2
    LD R2, MAXLOOPCOUNT
    ADD R3, R3, R2
    BRzp EXITNUMISPRIME

    LEA R1, SIEVESTART
    LD R3, OUTERLOOPCOUNT
    ADD R1, R1, R3 ; Get memory location of the next checked bit in the outer loop count
    LDR R2, R1, 0 ; Load checked bit of outer loop count into r2
    ADD R2, R2, 0
    BRnp SIEVEOUTERLOOP ; Check to see if value of checked bit at outer loop count is 1 or 0
    LD R1, OUTERLOOPCOUNT
    ST R1, INNERLOOPCOUNT
        
        SIEVEINNERLOOP
        LD R1, OUTERLOOPCOUNT ; Load the outer loop factor
        ADD R1, R1, 2
        LD R2, INNERLOOPCOUNT ; Load the inner loop factor
        ADD R2, R2, 2
        JSR multiply ; Multiply the two factors
        LD R4, PRIMENUM
        ADD R2, R3, R4
        BRz EXITNUMISCOMPOSITE ; Add the result to the number being checked, if the sum is zero the number is composite
        BRp SIEVEOUTERLOOP ; If positive jump to outer loop
        ADD R3, R3, -2 ; Turn number back to memory offset
        LEA R4, SIEVESTART ; Read in sieve start marker
        ADD R3, R3, R4 ; Add number location and sieve beginning marker to get final memory location
        AND R4, R4, 0
        ADD R4, R4, 1
        STR R4, R3, 0 ; Store a one in the number just checked
        LD R1, INNERLOOPCOUNT
        ADD R1, R1, 1 ; Increment inner loop count
        ST R1, INNERLOOPCOUNT
        
        BRnzp SIEVEINNERLOOP
        

    EXITNUMISPRIME
    LEA R0, NUMISPRIME
    PUTS
    LD R7, RETLOCSIEVELOOPS
RET
    EXITNUMISCOMPOSITE
    LEA R0, NUMISCOMPOSITE
    PUTS
    LD R7, RETLOCSIEVELOOPS
RET
RETLOCSIEVELOOPS .FILL 0
NUMISPRIME .STRINGZ "\r\nThat was a prime number. \r\n"
NUMISCOMPOSITE .STRINGZ "\r\nThat was a composite number. \r\n"

MAXLOOPCOUNT .FILL -181
OUTERLOOPCOUNT .FILL -1 ; Starting count for the outer loop of the sieve.
INNERLOOPCOUNT .FILL 0 ; Starting count for the inner loop of the sieve.
SIEVEMAX .FILL 32800 ; Maximum needed memory spaces for a complete sieving.
PRIMENUM .FILL 0 ; Prime number to check for.
SIEVESTART .FILL 0 ; Marker for the start of the sieve's allocated memory.
.END
