TITLE Program 1 Elementary Arithmetic    (Project1.asm)

; Author: Alexander Miranda
; Email: miranale@oregonstate.edu
; Class/Section: CS 271-400
; Assignment: Program 1                 
; Due Date: 07/09/2017
; Description: This program will take two numbers as input and output the results of various operations
; to the user

INCLUDE Irvine32.inc

; Constant definitions:

.data

; Instructional strings

intro			BYTE	"Elementary Arithmetic by Alexander Miranda",0
instruct1		BYTE    "Enter 2 numbers, and I'll show you the sum, difference,",0
instruct2		BYTE	"product, quotient, and remainder.",0
prompt1			BYTE    "Please enter the first number here: ",0
prompt2			BYTE    "Please enter the second number here: ",0
firstNum		BYTE	"First number: ",0
secondNum		BYTE	"Second number: ",0
results			BYTE    "Write outs of the calculations and results are shown below: ",0
replayMsg		BYTE	"Do you want to calculate two new numbers?", 13, 10,
								"Enter 1 to continue or 0 to exit: ",0
farewell		BYTE	"That was fun! Goodbye!",0

; Extra credit prompts

ecPrompt1		BYTE	"**EC: Program loops until user chooses to exit",0
ecPrompt2		BYTE	"**EC: Program validates the second number is less than the first",0
ecPrompt3		BYTE	"**EC: Program calculates and displays the quotient as a floating-point number",0

; Error output strings

negError		BYTE	"The second number should be smaller than the first!",0

; Inputted and calculated values

num1			DWORD   ?	;variable that stores value of first number inputted
num2			DWORD   ?   ;variable that stores value of second number inputted
sum				DWORD   ?	;stores the sum of num1 and num2
diff			DWORD   ?   ;stores the difference of num1 and num2
product			DWORD   ?   ;stores the product of num1 and num2
quotient		DWORD   ?   ;stores the quotient of num1 and num2
floatingPtDiv	REAL4	?	;stores the floating point quotient for extra credit
remainder		DWORD   ?   ;stores the remainder of the quotient of num1 and num2
loopResp		DWORD	?	;stores the user response to continue the program or not

; Result output strings

addSign			BYTE	" + ",0
subSign			BYTE	" - ",0
multSign		BYTE	" x ",0
divSign			BYTE	" / ",0
remainSign		BYTE	" remainder ",0
equalSign		BYTE	" = ",0

.code
main PROC

; Programmer introduction and EC prompts

mainProg:
	mov			edx, OFFSET	intro
	call    WriteString
	call    CrLf
	call	CrLf
	mov			edx, OFFSET ecPrompt1
	call	WriteString
	call	CrLf
	mov			edx, OFFSET ecPrompt2
	call	WriteString
	call	CrLf
	mov			edx, OFFSET ecPrompt3
	call	WriteString
	call	CrLf
	call	CrLf

; Output instructions to user

	mov			edx, OFFSET instruct1
	call	WriteString
	call	CrLf
	mov			edx, OFFSET instruct2
	call	WriteString
	call	CrLf
	call	CrLf


; Grab user input for both numbers

	mov			edx, OFFSET prompt1
	call	WriteString
	call	ReadInt
	mov			num1, eax
	mov			edx, OFFSET prompt2
	call	WriteString
	call	ReadInt
	mov			num2, eax
	call	CrLf

; Output the numbers the user entered

	mov			edx, OFFSET firstNum
	call	WriteString
	mov			eax, num1
	call	WriteDec
	call	CrLf
	mov			edx, OFFSET secondNum
	call	WriteString
	mov			eax, num2
	call	WriteDec
	call	CrLf
	call	CrLf

; Make sure the first number is greater than second

	mov			eax, num1
	cmp			eax, num2
	jl			NegativeError
	jmp			ContinueCalc

NegativeError:

	mov			edx, OFFSET negError
	call	WriteString
	call	CrLf
	call	CrLf
	jmp			LoopProg

ContinueCalc:

; Calculate the sum of num1 and num2

	mov			eax, num1
	mov			ebx, num2
	add			eax, ebx
	mov			sum, eax

; Output the sum to the user
	
	mov			eax, num1
	call	WriteDec
	mov			edx, OFFSET addSign
	call	WriteString
	mov			eax, num2
	call	WriteDec
	mov			edx, OFFSET equalSign
	call	WriteString
	mov			eax, sum
	call	WriteDec
	call	CrLf

; Calculate the difference of num1 and num2

	mov			eax, num1
	mov			ebx, num2
	sub			eax, ebx
	mov			diff, eax

; Output the difference to the user

	mov			eax, num1
	call	WriteDec
	mov			edx, OFFSET subSign
	call	WriteString
	mov			eax, num2
	call	WriteDec
	mov			edx, OFFSET equalSign
	call	WriteString
	mov			eax, diff
	call	WriteDec
	call	CrLf

; Calculate the product of num1 and num2

	mov			eax, num1
	mov			ebx, num2
	mul			ebx
	mov			product, eax

; Outpute the product to the user

	mov			eax, num1
	call	WriteDec
	mov			edx, OFFSET multSign
	call	WriteString
	mov			eax, num2
	call	WriteDec
	mov			edx, OFFSET equalSign
	call	WriteString
	mov			eax, product
	call	WriteDec
	call	CrLf

; Calculate the quotient of num1 and num2 with storing the resulting remainder

	mov			eax, num1
	mov			ebx, num2
	mov			edx, 0
	div			ebx
	mov			quotient, eax
	mov			remainder, edx

; Output the quotient to the user

	mov			eax, num1
	call	WriteDec
	mov			edx, OFFSET divSign
	call	WriteString
	mov			eax, num2
	call	WriteDec
	mov			edx, OFFSET equalSign
	call	WriteString
	mov			eax, quotient
	call	WriteDec
	mov			edx, OFFSET remainSign
	call	WriteString
	mov			eax, remainder
	call	WriteDec
	call	CrLf
	call	CrLf

; Extra credit for floating point result from division

; Outputting the ec prompt three

	mov			edx, OFFSET ecPrompt3
	call	WriteString
	call	CrLf
	call	CrLf

; Outputting the division equation again

	mov			eax, num1
	call	WriteDec
	mov			edx, OFFSET divSign
	call	WriteString
	mov			eax, num2
	call	WriteDec
	mov			edx, OFFSET equalSign
	call	WriteString

; Calculating the floating point quotient and outputting it to the user

	fild	num1
	fild	num2
	fdiv	ST(1), ST(0)
	fstp	floatingPtDiv
	call	WriteFloat
	call	CrLf
	call	CrLf

LoopProg:
; Loop the program until user chooses to exit

	mov			edx, OFFSET replayMsg
	call	WriteString
	call	ReadInt
	mov			loopResp, eax
	cmp			loopResp, 1
	je			mainProg

; Output the farewell message to the user

	mov			edx, OFFSET farewell
	call	WriteString
	call	CrLf

; Exit to operating system

	exit

main ENDP

END main
