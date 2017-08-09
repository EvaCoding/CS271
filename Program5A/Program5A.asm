TITLE Designing low-level I/O procedures     (Program5A.asm)

; Author: Alexander Miranda
; Email: miranale@oregonstate.edu
; Class/Section: CS 271-400
; Assignment: Program 5A
; Due Date: 08/13/2017
; Description: A program using macros to complete I/O procedures. The user inputs
;				ten integers which are put into an array which is then outputted
;				along with the sum and the average.

INCLUDE Irvine32.inc

displayString	MACRO	stringInputPtr

	push	edx
	mov			edx, OFFSET stringInputPtr
	call	WriteString
	pop			edx

ENDM

getString	MACRO	stringInputPtr, stringLength

	push	ecx
	push	edx
	mov			edx, stringInputPtr
	mov			ecx, stringLength
	call	ReadString
	pop			ecx
	pop			edx

ENDM

readVal	   MACRO	userEntered, intNum

	LOCAL		begin
	LOCAL		moreNums
	LOCAL		finish

	pushad

	mov			edx, OFFSET promptNum
	call	WriteString

begin:

	mov			eax, 0
	mov			edx, NUM_OF_INPUTS
	mov			ebx, 0

	getString	userEntered, stringLength
	mov			ecx, strLength
	dec			ecx
	mov			esi, OFFSET userEntered

	cld
	lodsb

	sub			al, 48
	cmp			al, 9
	ja			invalidInput

moreNums:
	
	lodsb
	sub			al, 48
	cmp			al, 9
	ja			invalidInput
	cmp			al, 0
	jb			invalidInput

	push		eax
	mov			eax, ebx
	mov			edx, 10
	mul			edx

	mov			ebx, eax
	pop			eax

	add			ebx, eax
	dec			ecx

	jne			moreNums
	je			finish

invalidInput:

	mov			edx, OFFSET errMsg
	call	WriteString
	jmp			begin

finish:

	mov			intNum, ebx
	popad

ENDM

writeVal	MACRO	intNum, stringIn

	LOCAL	grabInts
	LOCAL	change
	LOCAL	grabNums
	LOCAL	finish
	LOCAL	zeroHit

	pushad

	cld

	lea			edi, stringIn
	mov			ecx, (SIZEOF stringIn)
	mov			al, 0
	rep			stosb

	mov			eax, intNum
	mov			ebx, 10
	mov			ecx, 0

getInts:

	cmp			eax, 0
	je			change
	cdq
	div			ebx
	inc			ecx
	jmp			getInts

change:

	cmp			ecx, 0
	je			zeroHit
	mov			eax, intNum
	mov			ebx, 10
	mov			edi, OFFSET stringIn
	add			edi, ecx
	dec			edi
	std

grabNums:

	cdq
	div			ebx
	push	eax
	mov			eax, edx
	add			eax, 48
	stosb
	pop		eax
	cmp		eax, 0
	je		finish
	jmp		grabNums

zeroHit:

	mov			edi, OFFSET stringIn
	mov			eax, 48
	stosb

finish:

	displayString	stringIn

	popad

ENDM

; Program constants

NUM_OF_INPUTS = 10

.data

; Constant output strings

intro1			BYTE	"PROGRAMMING ASSIGNMENT 5A: Designing low-level I/O procedures",0
intro2			BYTE	"Written by: Alexander Miranda",0

instruct1		BYTE	"Please provide 10 unsigned decimal integers.",0
instruct2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0
instruct3		BYTE	"After you have finished inputting the raw numbers I will display a list",0
instruct4		BYTE	"of the integers, their sum, and their average value.",0

promptNum		BYTE	"Please enter an unsigned number: ",0

errMsg			BYTE	"ERROR: You did not enter an unsigned number or your number was too big.",0

arrDispMsg		BYTE	"You entered the following numbers:",0
sumMsg			BYTE	"The sum of these numbers is: ",0
avgMsg			BYTE	"The average is: ",0

farewell		BYTE	"Thanks for playing!",0

; Data variables

numArray		DWORD	10	DUP (?)
userInt			DWORD	?
userEntered		BYTE	30		DUP (?)
sum				DWORD	?
average			DWORD	?

.code
main PROC

	push	OFFSET intro1
	push	OFFSET intro2
	call	intro

	push	OFFSET instruct1
	push	OFFSET instruct2
	push	OFFSET instruct3
	push	OFFSET instruct4
	call	instructUser

	push	OFFSET numArray
	push	OFFSET userInt
	push	OFFSET userEntered
	call	grabInput

	push	OFFSET arrDispMsg
	push	OFFSET numArray
	call	outputArray

	push	OFFSET sum
	push	OFFSET userEntered
	push	OFFSET sumMsg
	push	OFFSET numArray
	call	calculateSum

	push	OFFSET sum
	push	OFFSET average
	push	OFFSET avgMsg
	push	OFFSET numArray
	call	calculateAverage

	push	OFFSET farewell
	call	endMessage

	exit	; exit to operating system
main ENDP

intro	PROC

	push	ebp
	mov			ebp, esp
	push	edx
	mov			edx, [ebp + 12]
	call	WriteString
	call	CrLf
	mov			edx, [ebp + 8]

	call	WriteString
	call	CrLf
	call	CrLf

	pop			edx
	pop			ebp

	ret 8

intro	ENDP

instructUser	PROC

	push	ebp
	mov			ebp, esp
	push	edx

	mov			edx, [ebp + 8]
	call	WriteString
	call	CrLf
	call	CrLf

	pop			edx
	pop			ebp

	ret		4

instructUser	ENDP

grabInput	PROC

	push	ebp
	mov			ebp, esp

	push	esi
	push	ecx
	push	eax
	mov			esi, [ebp + 16]
	mov			ecx, 10

grabNums:

	readVal userEntered, userInt

	mov			eax, userInt
	mov			[esi], eax
	add			esi, 4
	dec			ecx
	jnz			grabNums

	call	CrLf

	pop			eax
	pop			esi
	pop			ecx
	pop			ebp

	ret		12

grabInput	ENDP



outputArray		PROC

	push	ebp
	mov			ebp, esp

	push	edx
	push	edi
	push	ebx
	push	eax

	mov			edx, [ebp + 12]
	call	WriteString
	call	CrLf

	mov			edi, [ebp + 8]
	mov			ebx, 0

traverseArray:

	mov			eax, 4
	mul			ebx
	mov			esi, edi
	add			esi, eax

	writeVal	[esi], userEntered
	cmp			ebx, 9
	je			skipComma

	push	eax
	mov			al, ','

	call	WriteChar
	mov			al, ' '
	call	WriteChar
	pop			eax

skipComma:

	inc			ebx
	cmp			ebx, 10
	je			finish
	jmp			traverseArray

finish:

	call	CrLf

	pop		eax
	pop		ebx
	pop		edi
	pop		edx
	pop		ebp

	ret		8

outputArray		ENDP


calculateSum	PROC

	push	ebp
	mov			ebp, esp

	push	eax
	push	ebx
	push	edx
	push	esi
	push	edi

	mov			edx, [ebp + 12]
	call	WriteString

	mov			edi, [ebp + 8]

	mov			ebx, 0
	mov			eax, 0

summingLoop:

	add			eax, [edi + ebx * 4]
	inc			ebx
	cmp			ebx, 10

	je			finish
	jmp			summingLoop

finish:

	mov			esi, [ebp + 20]
	mov			[esi], eax

	writeVal	[esi], numArray

	call	CrLf

	pop			edi
	pop			esi
	pop			edx
	pop			ecx
	pop			eax
	pop			ebp

	ret		16

calculateSum	ENDP

calculateAverage	PROC

	push	ebp

	mov			ebp, esp
	push	eax
	push	ebx
	push	edx
	push	edi
	push	esi

	mov			edx, [ebp + 12]
	call	WriteString

	mov			edx, 0
	mov			ebx, 10
	mov			edi, [ebp + 24]

	mov			esi, [ebp + 20]
	mov			eax, [edi]

	cdq

	div			ebx
	mov			[esi], eax

	writeVal	[esi], avgMsg

	call	CrLf
	call	CrLf

	pop		esi
	pop		edi
	pop		edx
	pop		ebx
	pop		eax
	pop		ebp

	ret		20

calculateAverage	ENDP

endMessage	PROC

	push	ebp
	mov			ebp, esp
	push	edx

	mov			edx, [ebp + 8]

	call	WriteString
	call	CrLf

	pop			edx
	pop			ebp

	ret		4

endMessage	ENDP

END main
