TITLE Designing low-level I/O procedures    (Program5A.asm)

; Name: Alexander Miranda
; Email: miranale@oregonstate.edu
; Class/Section: CS 271-400
; Assignment: Program 5A
; Due Date: 08/13/2017
; Description: A program using macros to complete I/O procedures. The user inputs
;				ten integers which are put into an array which is then outputted
;				along with the sum and the average.

INCLUDE Irvine32.inc

COMMENT @
  Moves the user's input into a place in memory to be converted later 
  receives: reference to the inputted string, strLength the number of chars in the input
  returns: none
  preconditions: none
  registers changed: edx, ecx
@
getString	MACRO reference, strLength	
	push	edx
	push	ecx
	mov		edx, reference
	mov		ecx, strLength
	call 	ReadString
	pop		ecx
	pop		edx
ENDM

COMMENT @
  Displays string stored in an address that is passed as a param
  receives: stringInput which is what the user entered
  preconditions: user had to enter an input
  registers changed: edx
@
displayString	MACRO	stringInput
	push	edx
	mov		edx, OFFSET stringInput
	call	WriteString
	pop		edx
ENDM

; Constant for number of inputs accepted by the user

; Constant used to extend the program to accept a varying amount of inputs easily configured
	NUM_OF_INPUTS = 10

.data

	intro1			BYTE	"PROGRAMMING ASSIGNMENT 5A: Designing low-level I/O procedures",0
	intro2			BYTE	"Written by: Alexander Miranda",0

	instruct1		BYTE	"Please provide 10 unsigned decimal integers.",0
	instruct2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0
	instruct3		BYTE	"After you have finished inputting the raw numbers I will display a list",0
	instruct4		BYTE	"of the integers, their sum, and their average value.",0

	promptNum		BYTE	"Please enter an unsigned number: ", 0

	errMsg			BYTE	"ERROR: You did not enter an unsigned number or your number was too big.",0
	errPrompt		BYTE	"Please try again: ",0

	arrDispMsg		BYTE	"You entered the following numbers:",0
	sumMsg			BYTE	"The sum of these numbers is: ",0
	avgMsg			BYTE	"The average is: ",0

	farewell		BYTE	"Thanks for playing!",0

	; Data variables

	dataArray		DWORD	10 DUP(0)
	sum			DWORD	?
	average			DWORD	?
	buffer			BYTE	255 DUP (0)
	strTemp			BYTE	32 DUP (?)

.code
main PROC

; Print intro to the user and the program instructions

	displayString	intro1
	call	CrLf
	displayString	intro2
	call	CrLf
	call	CrLf
	displayString	instruct1
	call	CrLf
	displayString	instruct2
	call	CrLf
	displayString	instruct3
	call	CrLf
	displayString	instruct4
	call	CrLf
	call	CrLf

; Set loop controls

	mov		ecx, NUM_OF_INPUTS
	mov		edi, OFFSET dataArray

; Prompt the user for numerical input

promptInput:

	displayString	promptNum

; Push address (reference) of buffer onto the stack

	push	OFFSET buffer
	push	SIZEOF buffer
	call	ReadVal

; Iterate to the next slot in the array

	mov		eax, DWORD PTR buffer
	mov		[edi], eax
	add		edi, 4				; Iterating to next slot in dataArray

; Continue loop if more input is needed (less than NUM_OF_INPUT)

	loop	promptInput
	call	CrLf

; Display array contents to the user

; Initialize the loop variables

	mov		ecx, NUM_OF_INPUTS
	mov		esi, OFFSET dataArray
	mov		ebx, 0					; For calculating sum of numbers

; Display message to show user what they entered

	displayString	arrDispMsg
	call			CrLf

; Calculate the sum and output the number to the user

continueSum:
	mov		eax, [esi]
	add		ebx, eax				; Adding number in eax to sum total in ebx

; Push parameters in eax and in strTemp

	push	eax
	push	OFFSET strTemp
	call	WriteVal
	cmp		ecx, 1					; Checking to see if the last number will be printed
	je		noCommaNeeded
	mov		al, ','
	call	WriteChar
	mov		al, ' '
	call	WriteChar

noCommaNeeded:

	add		esi, 4					; Move address to the next number
	loop	continueSum
	call	CrLf

; Output the sum to the user

	mov			eax, ebx
	mov			sum, eax
	displayString	sumMsg

; Push sum and strTemp paramaters onto the stack

	push	sum
	push	OFFSET strTemp
	call	WriteVal
	call	CrLf
	
; Calculating the average of all the numbers inputted

; Empty edx and set ebx to NUM_OF_INPUTS

	mov		ebx, NUM_OF_INPUTS
	mov		edx, 0

; Divide the sum by NUM_OF_INPUTS

	div		ebx

; Determine if average needs to be rounded up

	mov		ecx, eax
	mov		eax, edx
	mov		edx, 2
	mul		edx
	cmp		eax, ebx
	mov		eax, ecx
	mov		average, eax
	jb		noNeedToRound
	inc		eax
	mov		average, eax

noNeedToRound:
	displayString	avgMsg

; Push parameters average and strTemp | Call WriteVal

	push	average
	push	OFFSET strTemp
	call	WriteVal
	call	CrLf
	call	CrLf
	
; Display goodbye message

	displayString	farewell
	call	CrLf

	exit		; exit to operating system
main ENDP

COMMENT @
  Invokes getString macro to get the user's string of digits. Converts
  the digits string to numbers and validates input.
  receives: address of buffer (OFFSET), and size of buffer (SIZEOF)
  returns: The integer version of the inputted number
  preconditions: 
  registers changed: 
@
readVal PROC

	push	ebp
	mov		ebp, esp

	pushad

begin:

	mov		edx, [ebp + 12]	; reference to the buffer variable
	mov		ecx, [ebp + 8]	; size of buffer pushed to ecx register so it is tracked

; Read the input from the user

	getString	edx, ecx

; Initialize the registers
	mov		esi, edx
	mov		eax, 0
	mov		ecx, 0
	mov		ebx, 10

; Loading the string incrementally

continueRead:
	lodsb					; loads from memory at esi
	cmp		ax, 0			; check to see if the string has terminated
	je		finish

; Check the range if char is a digit in ASCII

	cmp		ax, 48				; ASCII code 48 relates to the zero (0) digit
	jb		invalidInput
	cmp		ax, 57				; ASCII code 57 relates to the nine (9) digit
	ja		invalidInput

; Adjust for value of digit

	sub		ax, 48
	xchg	eax, ecx
	mul		ebx				; multiply by 10 for correct digit place
	jc		invalidInput
	jnc		validInput

invalidInput:

	displayString	errMsg
	call	CrLf
	displayString	errPrompt
	jmp				begin

validInput:

	add		eax, ecx
	xchg	eax, ecx		; Swap references in the two registers
	jmp		continueRead	; Continue parsing
	
finish:

	xchg	ecx, eax
	mov		DWORD PTR buffer, eax	; Save int in passed variable
	popad
	pop ebp

	ret 8

readVal ENDP

COMMENT @
  Method that outputs the number to the user after converting the number to ASCII characters
  receives: number needing to be converted and string reference to write the output to the user
  returns: none
  preconditions: none
  registers changed: ebp, eax, edi, ebx, edx, esp
@
writeVal PROC

	push	ebp
	mov		ebp, esp
	pushad		; save the registers by pushing them onto the stack

; Initialize the loop to read the inputted number

	mov		eax, [ebp + 12]	; move integer value in stack to eax register
	mov		edi, [ebp + 8]	; move reference to edi to store the output string
	mov		ebx, 10
	push	0

convertNum:

	mov		edx, 0
	div		ebx
	add		edx, 48
	push	edx

; Check if at end

	cmp		eax, 0
	jne		convertNum

; Pop numbers off the stack

removeNum:

	pop		[edi]
	mov		eax, [edi]
	inc		edi
	cmp		eax, 0				; check if the end
	jne		removeNum

; Output as string using the macro displayString

	mov				edx, [ebp + 8]
	displayString	OFFSET strTemp

	popad
	pop ebp

	ret 8

writeVal ENDP

END main