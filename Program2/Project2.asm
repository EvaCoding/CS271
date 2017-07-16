TITLE Program 2 Fibonacci Numbers     (Project2.asm)

; Author: Alexander Miranda
; Email: miranale@oregonstate.edu
; Class/Section: CS 271-400
; Assignment: Program 2
; Due Date: 07/16/2017
; Description: This program calculates Fibonacci numbers and presents them to the user
; while greeting and saying farewell to the user with their inputted name

INCLUDE Irvine32.inc

; Constant definitions:

; The minimum allowable calculated Fibonacci terms is bounded by this global
LOWER_LIMIT = 1
; The maximum allowable calculated Fibonacci terms is bounded by this global
UPPER_LIMIT = 46
; The number of desired columns of Fibonacci terms until a newline set to 5 for assignment
COLUMN_COUNT = 5
; The number of chars the userName can store
NAME_MAX_LEN = 25

.data

; Constant output strings:

programName			BYTE	"Fibonacci Numbers",0
authorAttr			BYTE	"Programmed by Alexander Miranda",0
userNameMsg			BYTE	"What's your name? ",0
greeting			BYTE	"Hello, ",0
instruct1			BYTE	"Enter the number of Fibonacci terms to be displayed",0
instruct2			BYTE	"Give the number as an integer in the range [",0
instruct3			BYTE	" .. ",0
instruct4			BYTE	"].",0
fibNumMsg			BYTE	"How many Fibonacci terms do you want? ",0
fibNumErr1			BYTE	"Out of range.  Enter a number in [",0
fibNumErr2			BYTE	"]",0
fullStop			BYTE	".",0
whiteSpace			BYTE	9,9,0
certMsg				BYTE	"Results certified by Alexander Miranda.",0
farewell			BYTE	"Goodbye, ",0
repeatMsg			BYTE	"Enter 1 to run again 0 to exit: ",0

; Extra credit prompts

columnsEc			BYTE	"**EC: Program displays the numbers in aligned columns.",0
repeatEc			BYTE	"**EC: User can decide to run the program again",0
errColorEc			BYTE	"**EC: Error output messages are colored red",0	

; Variable definitions:

userName			BYTE	NAME_MAX_LEN + 1 DUP(0) ;variable that stores the name the user inputs for themselves
fibTerms			DWORD	?	;variable that stores the desired number of Fibonacci terms from the user
fibNum				DWORD	?	;variable that holds the current Fibonacci term to be printed
placeholder			DWORD	?	;variable that holds the current Fibonacci term so white
								;space can be outputted to the screen using the edx register
								;without losing the current Fibonacci int

.code
main PROC

introduction:

; Output intro message to the user
	mov			edx, OFFSET programName
	call	WriteString
	call	CrLf
	mov			edx, OFFSET authorAttr
	call	WriteString
	call	CrLf
	call	CrLf

; Output the extra credit prompts
	mov			edx, OFFSET columnsEc
	call	WriteString
	call	CrLf
	mov			edx, OFFSET repeatEc
	call	WriteString
	call	CrLf
	mov			edx, OFFSET errColorEc
	call	WriteString
	call	CrLf
	call	CrLf

; Grab the user's inputted name
	mov			edx, OFFSET userNameMsg
	call	WriteString
	mov			ecx, 32
	mov			edx, OFFSET userName
	call	ReadString

; Greet the user
	mov			edx, OFFSET greeting
	call	WriteString
	mov			edx, OFFSET userName
	call	WriteString
	call	CrLf

; Instruct user on input rules for program

instructUser:
	mov			edx, OFFSET instruct1
	call	WriteString
	call	CrLf
	mov			edx, OFFSET instruct2
	call	WriteString
	mov			eax, LOWER_LIMIT
	call	WriteDec
	mov			edx, OFFSET instruct3
	call	WriteString
	mov			eax, UPPER_LIMIT
	call	WriteDec
	mov			edx, OFFSET instruct4
	call	WriteString
	call	CrLf
	call	CrLf
	jmp			getNumOfFibTermsFromUser

; Error message output to the user on invalid lower or upper bound number
;	sets the text color to lightRed (defined by Irvine32.inc)
;		restores the default text color after outputting the error message

validationError:
	mov			eax, lightRed
	call	SetTextColor
	mov			edx, OFFSET fibNumErr1
	call	WriteString
	mov			eax, LOWER_LIMIT
	call	WriteDec
	mov			edx, OFFSET instruct3
	call	WriteString
	mov			eax, UPPER_LIMIT
	call	WriteDec
	mov			edx, OFFSET fibNumErr2
	call	WriteString
	call	CrLf
	mov			eax, lightGray
	call	SetTextColor

; Get the number of Fibonacci terms to display from the user

getNumOfFibTermsFromUser:
	mov			edx, OFFSET fibNumMsg
	call	WriteString
	call	readInt
	mov			fibTerms, eax

; Validating fibTerms to see that it is within LOWER_LIMIT and UPPER_LIMIT

	; Checking if the inputted number is zero
	jz			validationError
	; Checking if the inputted number is negative
	js			validationError
	cmp			eax, LOWER_LIMIT
	jl			validationError
	cmp			eax, UPPER_LIMIT
	jg			validationError

; Assign beginning of Fibonacci sequence to registers and assign 5 to edx for 5 rows of output
	mov			eax, 0
	mov			ebx, 1
	mov			ecx, fibTerms
	mov			edx, COLUMN_COUNT

outputFibNums:
	mov			fibNum, eax
	add			eax, ebx
	call	WriteDec
	dec			edx
	jnz			rowFormatting

outputNewLine:
	call	CrLf
	mov			edx, COLUMN_COUNT
	jmp			resumeFibOutput

rowFormatting:
	cmp			ecx, 1
	je			outputNewLine
	mov			placeholder, edx
	mov			edx, OFFSET whiteSpace
	call	WriteString
	mov			edx, placeholder

resumeFibOutput:
	mov			ebx, fibNum
	loop	outputFibNums

; Output the certification and farewell message to the user
;	And prompt the user to run the program again or not based on their input

outputFarewell:

	; Outputting the results certified message with author's name included

	call	CrLf
	mov			edx, OFFSET certMsg
	call	WriteString
	call	CrLf
	call	CrLf

	; Prompting user to run the program again

	mov			edx, OFFSET repeatMsg
	call	WriteString
	call	readInt
	cmp			eax, 1
	je		getNumOfFibTermsFromUser

	; Outputting the farewell message to the user

	mov			edx, OFFSET farewell
	call	WriteString
	mov			edx, OFFSET userName
	call	WriteString
	mov			edx, OFFSET fullStop
	call	WriteString
	call	CrLf
	call	CrLf

	exit	; exit to operating system
main ENDP

END main
