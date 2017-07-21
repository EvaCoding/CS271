TITLE Program 3 Composite Numbers     (Project3.asm)

; Author: Alexander Miranda
; Email: miranale@oregonstate.edu
; Class/Section: CS 271-400
; Assignment: Program 3
; Due Date: 07/30/2017
; Description: This program calculates composite numbers with a user entered upper bound. The upper
;	bound determines to how many terms of composite numbers will be displayed to the console.
;	The results are displayed to have 10 numbers per line with at least 3 spaces between terms.

INCLUDE Irvine32.inc

; (insert constant definitions here)

; This constant specifies the lower bound for how many composite terms can be displayed
LOWER_BOUND = 1
; This constant specifies the upper bound for how many composite terms can be displayed
UPPER_BOUND = 400
; This constant sets how many composite numbers are displayed per row
SPACE_COUNT = 10

.data

; Constant output strings:

; Introduction and initial instructions
programHead			BYTE	"Composite Numbers		Programmed by Alexander Miranda",0
instruct1			BYTE	"Enter the number of composite numbers you would like to see.",0
instruct2			BYTE	"I'll accept orders for up to ",0
instruct3			BYTE	" composites.",0

; User prompt for input

termPrompt1			BYTE	"Enter the number of composites to display [",0
termPrompt2			BYTE	" .. ",0
termPrompt3			BYTE	"]: ",0

; Formatting variables

spaceChar			BYTE	9,0	; variable to hold the whitespace char
	
; Error messaging

rngErrMsg			BYTE	"Out of range.	Try again.",0

; Certification and farewell message

certMsg				BYTE	"Results certified by Alexander Miranda.  Goodbye.",0

; (insert variable definitions here)

userInput			DWORD	?	; variable that stores the user inputted desired number of composite terms
userInputTmp		DWORD	?	; additional storage variable for user inputted number, helping with spacing
compTerm			DWORD	?	; placeholder for composite number to be displayed in loop
countPH				DWORD	?	; loop counter placeholder variable
spaceCount			DWORD	?	; variable that holds the space count, initialized with SPACE_COUNT	

.code
main PROC

	call introduction
	call getNumOfCompTerms
	call outputComposites
	call sayGoodBye

	exit	; exit to operating system
main ENDP

introduction	PROC

; Introduction for the user
	mov			edx, OFFSET programHead
	call	WriteString
	call	CrLf
	call	CrLf

; Instructing the user for input with range specifications
	mov			edx, OFFSET instruct1
	call	WriteString
	call	CrLf
	mov			edx, OFFSET instruct2
	call	WriteString
	mov			eax, UPPER_BOUND
	call	WriteDec
	mov			edx, OFFSET instruct3
	call	WriteString
	call	CrLf

	ret
introduction ENDP

; Prompting the user for the number of terms they want to see and storing that number

getNumOfCompTerms	PROC

grabNum:

	mov			edx, OFFSET termPrompt1
	call	WriteString
	mov			eax, LOWER_BOUND
	call	WriteDec
	mov			edx, OFFSET termPrompt2
	call	WriteString
	mov			eax, UPPER_BOUND
	call	WriteDec
	mov			edx, OFFSET termPrompt3
	call	WriteString
	call	ReadInt
	mov			userInput, eax
	call	validateInput
	cmp			ebx, 1
	je			validNum
	call	validationError
	jmp		grabNum

validNum:
	ret

getNumOfCompTerms ENDP

validateInput	PROC

	; Checking if the inputted number is zero
	jz			validationError
	; Checking if the inputted number is negative
	js			validationError
	cmp			eax, LOWER_BOUND
	jl			invalid
	cmp			eax, UPPER_BOUND
	jg			invalid
	jmp			valid

invalid:
	mov			ebx, 0
	jmp			return

valid:
	mov			ebx, 1

return:
	ret

validateInput	ENDP

validationError		PROC

	; Changed text color to lightRed (defined in Irvine32.inc) for error message output
	mov			eax, lightRed
	call	SetTextColor
	mov			edx, OFFSET rngErrMsg
	call	WriteString
	; Reverting the text color back to the terminal's default after error prompt display
	mov			eax, lightGray
	call	SetTextColor
	ret
validationError	ENDP

isComp		PROC

	mov			ebx, compTerm
	cmp			ebx, 3			; Checking if number are less than or equal to 3
	jle			primeNum
	mov			ecx, 3

testDivide:
	
	mov			eax, ebx
	xor			edx, edx
	div			ecx
	cmp			edx, 0
	je			noRemainder
	inc			ecx
	cmp			ecx, compTerm
	je			primeNum
	jmp			testDivide

noRemainder:

	mov			eax, 0
	jmp			return

primeNum:

	mov			eax, 1

return:

	ret

isComp	ENDP

outputComposites	PROC
	
	mov			compTerm, 0
	mov			eax, userInput
	dec			eax
	mov			userInputTmp, eax

	; Initializing spaceCount with SPACE_COUNT
	mov			eax, SPACE_COUNT
	mov			spaceCount, eax

calcComp:
	
	inc			compTerm
	call	isComp
	cmp			eax, 0
	je			foundComp
	jmp			calcComp

foundComp:

	mov			eax, compTerm
	call	WriteDec
	dec			spaceCount
	jmp		formatting

newRow:

	call	CrLf
	mov			eax, SPACE_COUNT
	mov			spaceCount, eax
	jmp			resume

formatting:

	mov			eax, countPH
	cmp			eax, userInputTmp
	je			newRow
	mov			edx, OFFSET spaceChar
	call	WriteString

resume:

	inc			countPH
	mov			eax, countPH
	cmp			eax, userInput
	je			return
	jmp			calcComp

return:

	call	CrLf

	ret

outputComposites	ENDP

sayGoodbye	PROC
	mov			edx, OFFSET certMsg
	call	WriteString
	call	CrLf
	call	CrLf

	ret

sayGoodbye ENDP
	
END main
