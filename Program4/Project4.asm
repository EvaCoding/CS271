TITLE Program 4 Template     (Project4.asm)

; Author: Alexander Miranda
; Email: miranale@oregonstate.edu
; Class/Section: CS 271-400
; Assignment: Program 4
; Due Date: 08/06/2017
; Description: A program that takes a request integer and displays that many random numbers to the
;		user ten numbers per line. That list of random integers are then sorted in descending order
;		(largest first). The median value is calculated and rounded to the nearest integer to
;		then be displayed to the user. The sorted list is then outputted to the user showing
;		ten numbers per line.

INCLUDE Irvine32.inc

; (insert constant definitions here)

; Lower bound of user inputted request integer
MIN_INPUT = 10
; Upper bound of user inputted request integer
MAX_INPUT = 200
; Minimum value of generated random integers
LOWER_BOUND = 100
; Maximum value of generated random integers
UPPER_BOUND = 999
; Number of array elements to print per row
ELEMS_PER_ROW = 10

.data

; (insert variable definitions here)

; Output string constants

intro1			BYTE	"Sorting Random Integers       Programmed by Alexander Miranda",0
intro2			BYTE	"This program generates random numbers in the range [100 .. 999],",0
intro3			BYTE	"displays the original list, sorts the list, and calculates the,",0
intro4			BYTE	"median value. Finally, it displays the list sorted in descending order.",0

errMsg			BYTE	"Invalid input",0
medMsg			BYTE	"The median is ",0
sortMsg			BYTE	"The sorted list: ",0
prompt1			BYTE	"How many numbers should be generated? [",0
prompt2			BYTE	"]: ",0
unsortedMsg		BYTE	"The unsorted random numbers: ",0
medianMsg		BYTE	"The median is ",0
sortedMsg		BYTE	"The sorted list: ",0

; Data storage variables

; Variable for the user inputted number of random numbers desired to be generated
numNeeded		DWORD	?
; The array that contains the random numbers that are generated
numArray		DWORD	MAX_INPUT		DUP(?)


.code
main PROC
	call		Randomize

	push		OFFSET intro1			; pushing references of intro prompts to the stack prior to introduce PROC call
	push		OFFSET intro2
	push		OFFSET intro3
	push		OFFSET intro4
	call		introduce

	push		OFFSET errMsg			; pushing references of errMsg, prompt1, prompt2, and user inputted number
	push		OFFSET prompt1			; (numNeeded) to the system stack prior to grabInput PROC call
	push		OFFSET prompt2
	push		OFFSET numNeeded
	call		grabInput

	push		OFFSET numArray			; pushing the reference to the numArray and the value of numNeeded
	push		numNeeded				; onto the system stack prior to the populateArray PROC call
	call		populateArray

	push		OFFSET unsortedMsg		; pushing references to the unsortedMsg, the numArray and
	push		OFFSET numArray			; the value of numNeeded to the system stack prior
	push		numNeeded				; to the printArray PROC call
	call		printArray

	push		OFFSET numArray			; pushing the reference to numArray and the value of numNeeded
	push		numNeeded				; to the system stack prior to the call of PROC sortArray
	call		sortArray

	push		OFFSET medianMsg		; pushing the references of medianMsg and numArray to the system
	push		OFFSET numArray			; stack as well as the value of numNeeded prior to the 
	push		numNeeded				; printMedian PROC call
	call		printMedian

	push		OFFSET sortedMsg		; pushing references of sortedMsg and numArray along with the
	push		OFFSET numArray			; value of numNeeded to the system stack prior to the
	push		numNeeded				; printArray PROC call
	call		printArray

	exit
main ENDP

COMMENT @
Introduce the program to the user.
parameters: intro1, intro2, intro3, intro4 on the stack
returns: none
preconditions: none
registers changed: edx
@
introduce	PROC

	pushad							; pushing 32-bit registers onto the stack
	mov			ebp, esp

	mov			edx, [ebp + 48]		; assigning edx the ref to intro1
	call	WriteString				; outputting intro1
	call	CrLf

	mov			edx, [ebp + 44]		; assigning edx the ref to intro2
	call	WriteString				; outputting intro2
	call	CrLf
	mov			edx, [ebp + 40]		; assigning edx the ref to intro3
	call	WriteString				; outputting intro3
	call	CrLf
	mov			edx, [ebp + 36]		; assiging edx the ref to intro4
	call	WriteString				; outputting intro4

	call	CrLf
	call	CrLf

	popad							; popping 32-bit registers off the stack
	ret		16

introduce	ENDP

COMMENT @
Method that grabs the number of random numbers to generate from user input
parameters: errMsg, prompt1, prompt2, numNeeded from the stack
returns: the number inputted by the user
preconditions: none
registers changes: eax, ebx, edx
@
grabInput	PROC

	push	ebp					; initializing stack frame
	mov			ebp, esp
	mov			ebx, [ebp + 8]	; assign ebx the reference to numNeeded
	
grabNum:

	mov			edx, [ebp + 16]	; assigning edx the reference to prompt1
	call	WriteString
	mov			eax, MIN_INPUT	; outputting the min acceptable user input for numNeeded
	call	WriteDec
	mov			al, ' '
	call	WriteChar
	mov			al, '.'
	call	WriteChar
	call	WriteChar
	mov			al, ' '
	call	WriteChar
	mov			eax, MAX_INPUT	; outputting the max acceptable user input for numNeeded
	call	WriteDec
	mov			edx, [ebp + 12]	; assigning edx the reference to prompt2
	call	WriteString
	call	ReadInt				; taking the user's input into the eax register

	; Validation block to ensure the user's input is in the desired range
	cmp			eax, MIN_INPUT
	jl			invalidNum
	cmp			eax, MAX_INPUT
	jg			invalidNum
	jmp			validNum

invalidNum:

	mov			edx, [ebp + 20]	; assigning edx the reference to errMsg
	call	WriteString
	call	CrLf
	jmp		grabNum				; asking the user for input again

validNum:

	mov			[ebx], eax		; assigning the value of eax to be the value at the ebx register
	pop			ebp				; which references numNeeded currently
	
	ret			16

grabInput	ENDP

COMMENT @
This method creates the random numbers and enters them into an array
of a size the user designates
parameters: reference to the array and the value of numNeeded
returns: an array of size the user specifies that contains random numbers
preconditions: numNeeded is in the range specified by LOWER_BOUND and UPPER_BOUND
registers changed: eax, ebx, ecx, edx, edi
@
populateArray		PROC

	push	ebp						; initialize the stack frame
	mov			ebp, esp
	mov			ecx, [ebp + 8]		; assigning value of numNeeded to ecx (for the loop)
	mov			edi, [ebp + 12]		; assigning address of numArray to edi
	mov			ebx, LOWER_BOUND	; assigning value of LOWER_BOUND to ebx
	mov			edx, UPPER_BOUND	; assigning value of UPPER_BOUND to edx
	inc			edx
	sub			edx, ebx			; calculation to assign edx to be equal to UPPER_BOUND - LOWER_BOUND + 1

generateRandInt:

	mov			eax, edx			; assign random number to eax
	call	RandomRange				; generate a pseudo-random number
	add			eax, LOWER_BOUND	; bump up the random number in eax so it is within the range of LOWER_BOUND and UPPER_BOUND
	mov			[edi], eax			; enter the random number into numArray
	add			edi, 4				; move to next index in the numArray
	loop	generateRandInt
	pop			ebp
	ret			8

populateArray	ENDP

COMMENT @
Method to display the numbers in the array to the user
parameters: reference to the array, numNeeded both on the system's stack, reference to title
returns: prints the elements of the array to the user
preconditions: numNeeded is set to a value between LOWER_BOUND and UPPER_BOUND
	and the elements of the random array are populated
registers changed: eax, ebx, ecx, edx, esi
@
printArray	PROC

	push	ebp
	mov			ebp, esp
	mov			ecx, 0				; initializing to track element count
	mov			ebx, 0				; initializing to track white space count
	mov			esi, [ebp + 12]		; assigning the reference to numArray to esi
	mov			edx, [ebp + 16]		; assigning the reference to unsortedMsg which serves as the
	call	CrLf						; title
	call	WriteString
	call	CrLf

printRow:

	mov			eax, [esi + ecx * 4]	; assigning the value referenced on the stack (in numArray) to eax
	call	WriteDec					; outputting element of array to user
	inc			ebx						; increasing element count by one
	cmp			ebx, ELEMS_PER_ROW		; comparing elements displayed in current row to the total num of elements
	je			newRow						; per row, if equal will jump to newRow
	mov			al, 9					; will output a tab char otherwise
	call	WriteChar

mainLoop:
	
	inc			ecx						; incrementing the value in ecx
	cmp			ecx, [ebp + 8]			; compare the number of elements printed to the count requested (numNeeded)
	jne			printRow				; if the count does not match jump to print another row of numbers
	jmp			return					; otherwise jump to return because all elements of the array have been
											; outputted
newRow:

	call	CrLf
	sub			ebx, ELEMS_PER_ROW		; resetting ebx to 0
	jmp			mainLoop

return:

	call	CrLf
	call	CrLf
	pop			ebp
	ret			12

printArray	ENDP

COMMENT @
Method to sort the array in descending order. The algorithm used is selection sort.
parameters: reference to the array, numNeeded on the system's stack
returns: an array sorted in descending order
preconditions: numNeeded is set to a value between LOWER_BOUND and UPPER_BOUND,
	and the array references an array populated with random numbers
registers changed: eax, ebx, ecx, edx, edi
@
sortArray	PROC

	push	ebp							; initialize stack frame
	mov			ebp, esp
	mov			ecx, 0					; initialize loop counter
	mov			edi, [ebp + 12]			; assigning reference to array to edi

start:
	mov			eax, ecx
	mov			ebx, ecx

innerLoop:

	inc			ebx
	cmp			ebx, [ebp + 8]			; comparing number of elements sorted to numNeeded
	je			outerLoop				; if equal breaks out to the outer loop
	mov			edx, [edi + ebx * 4]	; comparing a pair of elements whereas it is arr[j] to arr[i]
	cmp			edx, [edi + eax * 4]	
	jl			innerLoop				; if arr[i] is less jump back to the inner loop
	pushad								; push register values onto stack to save them
	mov			esi, [ebp + 12]
	mov			ecx, 4
	mul			ecx
	add			esi, eax
	push	esi
	mov			eax, ebx
	mul			ecx
	add			edi, eax
	push	edi
	call	swapElements				; if arr[i] is greater swap it with arr[j]
	popad								; reinitialize the register values prior to pushad
	jmp			innerLoop

outerLoop:

	inc			ecx
	cmp			ecx, [ebp + 8]
	je			return					; returns if all elements have been sorted
	jmp			start

return:

	pop			ebp
	ret		8

sortArray	ENDP

COMMENT @
Method that prints and displays the median of the array to the user
parameters: reference to the array, numNeeded value, and medianMsg on the system's stack
returns: displays the median to the user
preconditions: numNeeded is populated as well as the sorted array
registers changed: eax, ebx, ecx, edx, edi, al
@
printMedian		PROC

	push	ebp
	mov			ebp, esp
	mov			edi, [ebp + 12]
	mov			edx, [ebp + 16]
	call	WriteString
	mov			eax, [ebp + 8]		; assigning value of numNeeded to eax
	cdq
	mov			ebx, 2
	div			ebx					; dividing numNeeded by 2
	cmp			edx, 0				; if edx equals 0 numNeeded was even
	je			evenLength			; jump to evenLength if edx == 0

oddLength:

	mov			ebx, [edi + eax * 4]	; when numNeeded is odd print the middle element
	mov			eax, ebx					; in numArray
	call	WriteDec
	mov			al, '.'
	call	WriteChar
	jmp			return

evenLength:
										; if number of array elements are even the middle two will be summed 					
	dec			eax						; and the sum will be divided by in half (by 2)
	mov			ebx, [edi + eax * 4]	; then displayed to the user
	inc			eax
	mov			ecx, [edi + eax * 4]
	mov			eax, ebx
	add			eax, ecx
	mov			ebx, 2
	div			ebx
	call	WriteDec
	mov			al, '.'
	call	WriteChar

return:

	call	CrLf
	pop			ebp

	ret		12

printMedian		ENDP

COMMENT @
Method that swaps two array elements
parameters: reference of first element, reference of second element on the system's stack
returns: the values of the swapped elements
preconditions: an array of at least two elements in length
registers changed: edx, edi, esi, ecx
@
swapElements		PROC

	push	ebp						; initialize stack frame
	mov			ebp, esp
	mov			esi, [ebp + 12]		; assigning address of first element to esi
	mov			edi, [ebp + 8]		; assigning address of second element to edi
	mov			edx, [edi]			; storing address of edi in edx
	mov			ecx, [esi]			; storing address of esi in ecx
	mov			[edi], ecx			; assigning address in ecx to edi (swapping first to second element address)
	mov			[esi], edx			; assigning address in edx to esi (swapping second element to first element address)
	pop			ebp					; restore the stack

	ret		8

swapElements		ENDP


END main
