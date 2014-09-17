;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;Program Name: Decryption (Lab 2)
;Author: CDT Clayton Jaksha, USMA
;Function: Takes an xor encrypted message, a key (or none), and returns a
;			decrypted message in ROM.
;Last Edited: 15SEP14
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                           	; section

;stores the encrypted message and the key in RAM. Also, stop codes are appended after the message and key so their lengths can be counted.
;if the key is unknown, then the stop code for the key is inputted as the key.
            .text
message		.byte		0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32,0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0,0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90
stop1		.byte		0xff,0x11,0xff,0xaa,0xff
key			.byte		0xff,0xaa,0xff,0x11,0xff	;putting stop code in key means that the key is unknown
stop2		.byte		0xff,0xaa,0xff,0x11,0xff
;these guesses are compared against the most frequent even or odd characters in order to determin the key.
guess1		.string		"e"
guess2		.string		"."

;saves space for the newly decrypted message and the new key, if necessary.
			.data
decrypted	.space		90
newkey		.space		2
;-------------------------------------------------------------------------------
RESET       mov.w   	#__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   	#WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

			;load registers with necessary info for decryptMessage here
			;
			;r4 points to message location
			;r5 points to key location
			;r6 holds message length (bytes)
			;r7 holds key lengths (bytes)
			;r8 holds decrypted pointer
            ;
			mov.w	#message, r4
			mov.w	#key, r5
			mov.w	#decrypted, r8
			clr		r6
			clr		r7
			dec		r4
			dec		r5

;this piece of code counts the length of the message in bytes. It stops counting when it reaches the stop1 sequence.
countmsg	inc		r4
			inc		r6
			cmp.b	#0xff, 0(r4)
			jeq		countf1
			jmp		countmsg
countf1		cmp.b	#0x11, 1(r4)
			jne		countmsg
			cmp.b	#0xff, 2(r4)
			jne		countmsg
			cmp.b	#0xaa, 3(r4)
			jne		countmsg
			cmp.b	#0xff, 4(r4)
			jne		countmsg
			dec		r6

;this piece of code counts the length of the key in bytes. It stops counting when it reaches the stop2 sequence.
countkey	inc		r5
			inc		r7
			cmp.b	#0xff, 0(r5)
			jeq		countf2
			jmp		countkey
countf2		cmp.b	#0xaa, 1(r5)
			jne		countkey
			cmp.b	#0xff, 2(r5)
			jne		countkey
			cmp.b	#0x11, 3(r5)
			jne		countkey
			cmp.b	#0xff, 4(r5)
			jne		countkey
			dec		r7

;this checks if the length of the key is 0; if it is then is calls the subroutine guessthekey which figures out the key.
;otherwise, it goes and decrypts the message byte by byte.
			mov.w	#message, r4
			mov.w	#key, r5
			cmp		#0, r7
			jne		getthemsg
			call	#guessthekey
			mov.w	#newkey, r5
			mov.w	#2, r7
getthemsg	call   	#decryptMessage
;traps the CPU
forever:    jmp     forever

;-------------------------------------------------------------------------------
                                            ; Subroutines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: CDT Clayton Jaksha, USMA
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value.  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs: message pointer (r4), key pointer (r5), message length (r6), key length
;			(r7), decrpyted message pointer (r8)
;Outputs:	Nothing
;Registers destroyed: r4,r5,r6,r7
;-------------------------------------------------------------------------------


;initializes the decryption process and the registers associated with that
;r9 counts through the program and serves as a comparison with the length of the message
;r10 also counts through the program and compares with the length of the key, allowing the key to be shifted through
;r11 is the message byte that gets xor'd with the key byte to get stored in memory
;r12 holds a copy of the initial value of the key pointer so that it can be restored when it needs to be cycled through again
;r13 holds the value of the key byte that the program will xor with the message byte

decryptMessage:
			mov.w	#0, r9
			mov.w	#0,	r10
			mov.w	r5, r12
			dec		r4
			dec		r5
			inc		r6
			inc		r7

;this loop goes through each byte of the message, sends it off to the decryptCharacter subroutine.
;when it gets the decrypted byte back from decryptCharacter subroutine
startdecrxn	inc		r4
			inc		r5
			inc		r9
			inc		r10
            cmp		r6, r9
            jge		done
            mov.b	@r4, r11
            cmp		r7, r10
      		jne		noshift
			mov.w	r12, r5
			mov.b	@r5, r13
			mov.w	#1, r10
			jmp		dcrxtchar
noshift		mov.b	@r5, r13
			jmp		dcrxtchar

;after fetching the decrypted byte, it stores it into the appropriate memory location
done2		mov.b	r11, 0(r8)
			inc		r8
			jmp		startdecrxn
;once the whole message is decoded and stored, the length registers (r6,r7) are restored and teh rest are cleared so they can be used in other subroutines.
done		dec 	r6
			dec		r7
			clr		r9
			clr		r10
			clr		r11
			clr		r12
			clr 	r13
			ret

;I need this small segment here to call the next subroutine because it can be called from different locations but must return to the same location
dcrxtchar	call	#decryptCharacter
			jmp		done2
;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author:	CDT Clayton Jaksha, USMA
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs:	key byte (r13), message byte (r11)
;Outputs:	decrypted message byte (r11)
;Registers destroyed:	r11, r13
;-------------------------------------------------------------------------------

decryptCharacter:
			xor.w	r13, r11
            ret

;-------------------------------------------------------------------------------
;Subroutine Name: guessthekey
;Author:	CDT Clayton Jaksha, USMA
;Function:	Uses the guesses defined in RAM and compares them with the most
;			frequently appearing bytes in the message. When we xor the guess with
;			the most common bytes, we are revealed the key. Iterative testing with
;			common characters will reveal the correct key, at which point we
;			redefine the key pointer and key length.
;Inputs:	message pointer (r4), message length (r6), guess1, guess2
;Outputs:	key pointer (r5), key length (r7)
;Registers destroyed: r5, r7
;-------------------------------------------------------------------------------


;This sequence is broken into two parts: even and odd bytes. This portion counts the even-addressed bytes and looks for a value that appears 3 times (arbitrarily chosen value).
;If it appears three times, we will assume it to be a common character and we xor it with the guess for that character is (guess1) and store that as the first byte of the new key.
guessthekey:
			push 	r4
			mov.w	#newkey, r13
			clr		r9
			clr		r12
checkval	mov.w	0(r4), r11
			mov.w	r4, r10
			clr		r12
checkfreq	incd	r12
			cmp		r6, r12
			jge		nextup
			cmp.b 	@r10, r11
			jeq		wegotone
			incd	r10
			jmp		checkfreq
wegotone	incd	r10
			inc		r9
			cmp		#3, r9
			jeq		bingo
			jmp		checkfreq
nextup		incd	r4
			clr		r9
			cmp		#stop1, r4
			jge		bingo
			jmp		checkval
bingo		mov.b	@r4, 0(r13)
			mov.w	#guess1, r14
			xor.b	0(r14), 0(r13)
			clr		r14
			pop		r4

;This portion counts the odd-addressed bytes and looks for a value that appears 3 times (arbitrarily chosen value).
;If it appears three times, we will assume it to be a common character and we xor it with the guess for that character is (guess2) and store that as the second byte of the new key.
			push 	r4
			mov.w	#newkey, r13
			clr		r9
			clr		r12
checkval1	mov.b	1(r4), r11
			mov.w	r4, r10
			clr		r12
checkfreq1	incd	r12
			cmp		r6, r12
			jge		nextup1
			cmp.b 	1(r10), r11
			jeq		wegotone1
			incd	r10
			jmp		checkfreq1
wegotone1	incd	r10
			inc		r9
			cmp		#3, r9
			jeq		bingo1
			jmp		checkfreq1
nextup1		incd	r4
			clr		r9
			cmp		#stop1, r4
			jge		bingo1
			jmp		checkval1
bingo1		mov.b	1(r4), 1(r13)
			mov.w	#guess2, r14
			xor.b	0(r14), 1(r13)
			clr		r14
			pop		r4
			ret


;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
