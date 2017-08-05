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
intro2			BYTE	"This program generates random numbers in the range [",0
intro3			BYTE	"],",13,10,0
;intro4			BYTE	"displays the original list, sorts the list, and calculates the,"13,10,"median value. Finally, it displays the list sorted in descending order.",0

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

	push		OFFSET intro1
	push		OFFSET intro2
	push		OFFSET intro3
	call		introduce

	push		OFFSET errMsg
	push		OFFSET prompt1
	push		OFFSET prompt2
	push		OFFSET numNeeded
	call		grabInput

	push		OFFSET numArray
	push		numNeeded
	call		populateArray

	push		OFFSET unsortedMsg
	push		OFFSET numArray
	push		numNeeded
	call		printArray

	push		OFFSET numArray
	push		numNeeded
	call		sortArray

	push		OFFSET medianMsg
	push		OFFSET numArray
	push		numNeeded
	call		printMedian

	push		OFFSET sortedMsg
	push		OFFSET numArray
	push		numNeeded
	call		printArray

	exit
main ENDP

COMMENT @
Introduce the program to the user.
parameters: intro1, intro2, intro3 on the stack
returns: none
preconditions: none
registers changed: eax, edx
@
introduce	PROC

	push	ebp
	mov			ebp, esp

	mov			edx, [ebp + 16]
	call	WriteString
	call	CrLf

	mov			edx, [ebp + 12]
	call	WriteString
	mov			eax, LOWER_BOUND
	call	WriteDec
	mov			al, ' '
	call	WriteChar
	mov			al, '.'
	call	WriteChar
	call	WriteChar
	mov			al, ' '
	call	WriteChar
	mov			eax, UPPER_BOUND
	call	WriteDec
	mov			edx, [ebp + 8]
	call	WriteString

	call	CrLf
	call	CrLf

	pop			ebp
	ret		12

introduce	ENDP

COMMENT @
Method that grabs the number of random numbers to generate from user input
parameters: errMsg, prompt1, prompt2, numNeeded from the stack
returns: the number inputted by the user
preconditions: none
registers changes: eax, ebx, edx
@
grabInput	PROC

	push	ebp
	mov			ebp, esp
	mov			ebx, [ebp + 8]
	
grabNum:

	mov			edx, [ebp + 16]
	call	WriteString
	mov			eax, MIN_INPUT
	call	WriteDec
	mov			al, ' '
	call	WriteChar
	mov			al, '.'
	call	WriteChar
	call	WriteChar
	mov			al, ' '
	call	WriteChar
	mov			eax, MAX_INPUT
	call	WriteDec
	mov			edx, [ebp + 12]
	call	WriteString
	call	ReadInt

	cmp			eax, MIN_INPUT
	jl			invalidNum
	cmp			eax, MAX_INPUT
	jg			invalidNum
	jmp			validNum

invalidNum:

	mov			edx, [ebp + 16]
	call	WriteString
	call	CrLf
	jmp		grabNum

validNum:

	mov			[ebx], eax
	pop			ebp
	
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

	push	ebp
	mov			ebp, esp
	mov			ecx, [ebp + 8]
	mov			edi, [ebp + 12]
	mov			ebx, LOWER_BOUND
	mov			edx, UPPER_BOUND
	inc			edx
	sub			edx, ebx

generateRandInt:

	mov			eax, edx
	call	RandomRange
	add			eax, LOWER_BOUND
	mov			[edi], eax
	add			edi, 4
	loop	generateRandInt
	pop			ebp
	ret			8

populateArray	ENDP

COMMENT @
Method to display the numbers in the array to the user
parameters: reference to the array, numNeeded both on the system's stack
returns: prints the elements of the array to the user
preconditions: numNeeded is set to a value between LOWER_BOUND and UPPER_BOUND
	and the elements of the random array are populated
registers changed: eax, ebx, ecx, edx, esi
@
printArray	PROC

	push	ebp
	mov			ebp, esp
	mov			ecx, 0
	mov			ebx, 0
	mov			esi, [ebp + 12]
	mov			edx, [ebp + 16]
	call	CrLf
	call	WriteString
	call	CrLf

printRow:

	mov			eax, [esi + ecx * 4]
	call	WriteDec
	inc			ebx
	cmp			ebx, ELEMS_PER_ROW
	je			newRow
	mov			al, 9
	call	WriteChar

mainLoop:
	
	inc			ecx
	cmp			ecx, [ebp + 8]
	jne			printRow
	jmp			return

newRow:

	call	CrLf
	sub			ebx, ELEMS_PER_ROW
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

	push	ebp
	mov			ebp, esp
	mov			ecx, 0
	mov			edi, [ebp + 12]

start:
	mov			eax, ecx
	mov			ebx, ecx

innerLoop:

	inc			ebx
	cmp			ebx, [ebp + 8]
	je			outerLoop
	mov			edx, [edi + ebx * 4]
	cmp			edx, [edi + eax * 4]
	jl			innerLoop
	pushad
	mov			esi, [ebp + 12]
	mov			ecx, 4
	mul			ecx
	add			esi, eax
	push	esi
	mov			eax, ebx
	mul			ecx
	add			edi, eax
	push	edi
	call	swapIndices
	popad
	jmp			innerLoop

outerLoop:

	inc			ecx
	cmp			ecx, [ebp + 8]
	je			return
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
registers changed: eax, ebx, ecx, edx, edi
@
printMedian		PROC

	push	ebp
	mov			ebp, esp
	mov			edi, [ebp + 12]
	mov			edx, [ebp + 16]
	call	WriteString
	mov			eax, [ebp + 8]
	cdq
	mov			ebx, 2
	div			ebx
	cmp			edx, 0
	je			evenLength

oddLength:

	mov			ebx, [edi + eax * 4]
	mov			eax, ebx
	call	WriteDec
	jmp			return

evenLength:

	dec			eax
	mov			ebx, [edi + eax * 4]
	inc			eax
	mov			ecx, [edi + eax * 4]
	mov			eax, ebx
	add			eax, ecx
	mov			ebx, 2
	div			ebx
	call	WriteDec

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
swapIndices		PROC

	push	ebp
	mov			ebp, esp
	mov			esi, [ebp + 12]
	mov			edi, [ebp + 8]
	mov			edx, [edi]
	mov			ecx, [esi]
	mov			[edi], ecx
	mov			[esi], edx
	pop			ebp

	ret		8

swapIndices		ENDP


END main
