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

; Error messaging

rngErrMsg			BYTE	"Out of range.	Try again.",0

; Certification and farewell message

certMsg				BYTE	"Results certified by Alexander Miranda.  Goodbye.",0

; (insert variable definitions here)

compTerms			DWORD	?	;variable that stores the user inputted desired number of composite terms

.code
main PROC

introduction:

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

; Prompting the user for the number of terms they want to see and storing that number

getNumOfCompTerms:

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
	call	readInt
	mov			compTerms, eax

validateInput:

	; Checking if the inputted number is zero
	jz			validationError
	; Checking if the inputted number is negative
	js			validationError
	cmp			eax, LOWER_BOUND
	jl			validationError
	cmp			eax, UPPER_BOUND
	jg			validationError
	jmp			calculateTerms

validationError:

	; Changed text color to lightRed (defined in Irvine32.inc) for error message output
	mov			eax, lightRed
	call	SetTextColor
	mov			edx, OFFSET rngErrMsg
	call	WriteString
	; Reverting the text color back to the terminal's default after error prompt display
	mov			eax, lightGray
	call	SetTextColor
	jmp			getNumOfCompTerms

calculateTerms:

	

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
