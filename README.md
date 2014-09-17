Lab 2: Decryption
===
#### Clayton Jaksha | ECE 382 | Dr. York | M2A

## Objective and Purpose
### Objective

The objective of this lab is to gain a foundational understanding of cryptography, the usefulness of xor for encryption, and the use of subroutines in complex programming.

### Purpose

This program is designed to take an xor-encrypted message, a key (or none), and return a decrypted message in ROM. Through programming, it will make use of subroutines to perform a specific task(s). For the A-solution, it will not take a key and still decrypt the message, although it still requires some critical thought on the part of the user.

## Preliminary Design

My program should first count the size of the message and key (if there is one), then run through and cycle the key through the message and xor-ing it each time, then store the decrypted message into ROM.

## Flowchart/Pseudocode
### Flowchart

![alt text](http://i.imgur.com/yfCbwaz.png "Flowchart")

### Pseudocode

#### Main Loop

The main loop tackles the job of counting the size of the message and the key, then sends the message off the appropriate subroutine. If the key length is 0, it goes to `guessthekey` to try and guess the key. If an actual key is given, or once a key is determined from `guessthekey`, the loop proceeds to `decryptMessage`. Once returning from `decryptMessage` we trap the CPU and the program ends.

```
load  message;
n=0;
while msgpointer<=endofmsgpointer:
      n+=1;
      msgpointer+=1;
      end while
msglength=n;
n=0;
while keypointer<=endofkeypointer:
      n+=1;
      keypointer+=;
      end while
keylength=n;
if keylength==0:
      call  guessthekey
      call  decryptMessage
else
      call  decryptMessage
      end if
n=0;
while n==0:
      end while
```

#### Subroutine 1: `decryptMessage`

This subroutine takes message pointer, the key pointer, the message length, and the key length. It lines up one byte of the key with one byte of the message and calls `decryptCharacter` to do the actual decrypting. When it receives the decrypted character back, it stores it into memory and starts the process over again until the entire message is decoded.

```
n=1;
m=1;
origval=keypointer;
while n<msglength:
      msgbyte=*msgpointer;
      if m==keylength:
            keybyte=*keypointer;
            keypointer=origval;
            m=0;
      else
            keybyte=*keypointer;
            end if
      call  decryptCharacter
      store msgbyte, decryptedmsglocation
      decryptedmsglocation+=1;
      n+=1;
      m+=1;
      msgpointer+=1;
      end while
return
```

#### Subroutine 2: `decryptCharacter`

This subroutine is extremely simple; it takes in the key byte and message byte, xor's them together, and gives back the decrypted message byte.

```
msgbyte=(msgbyte)XOR(keybyte);
return
```

#### Subroutine 3: `guessthekey`

This subroutine checks the different bytes of the message and looks for ones that are repeated more than others (3 repetitions is the trigger for a 'frequent byte') and then compares that with a guess of what the character is. It creates a key based off of the guess. If the key is 16 bits, then we must check even values for repetition and odd values for repetition separately and have separate guesses for each.

```
n=0;
m=0;
c=0;
guess1="e";
guess2=" ";
msgptrorgval=msgpointer;
while n<=msglength:
      bytewewant=*msgpointer;
      msgpointerval=msgpointer
      while m<=msglength:
            if (bytewewant-*msgpointer)==0:
                  c+=1;
                  if c==3:
                        m=msglength+1;
                        n=msglength+1;
                        keyval=(guess1)XOR(*msgpointerval);
                        store keyval, dcrxnmsgptr;
                        end if
                  msgpointer+=2;
                  m+=2;
            else
                  msgpointer+=2;
                  m+=2;
                  end if
      msgpointer=msgpointerval;
      m=0;
      n+=2;
      msgpointer+=2;
      end while
```
So that first part would check the even bytes for repetition. The next section would do essentially the same thing, but with the odd bytes.
```
n=0;
m=0;
c=0;
msgpointer=msgptrorgval+1;
while n<=msglength:
      bytewewant=*msgpointer;
      msgpointerval=msgpointer
      while m<=msglength:
            if (bytewewant-*msgpointer)==0:
                  c+=1;
                  if c==3:
                        m=msglength+1;
                        n=msglength+1;
                        keyval=(guess2)XOR(*msgpointerval+1);
                        store keyval, dcrxnmsgptr;
                        end if
                  msgpointer+=2;
                  m+=2;
            else
                  msgpointer+=2;
                  m+=2;
                  end if
      msgpointer=msgpointerval;
      m=0;
      n+=2;
      msgpointer+=2;
      end while
return
```

## Code Walkthrough

#### Initialization

We first store the encrypted message in RAM. We follow the message immediately by a unique stop code (`stop1`) that enables the program to count the message and determine its length in bytes.

```
                .text
message		.byte		0x35,0xdf,0x00,0xca,0x5d,0x9e,0x3d,0xdb,0x12,0xca,0x5d,0x9e,0x32,0xc8,0x16,0xcc,0x12,0xd9,0x16,0x90,0x53,0xf8,0x01,0xd7,0x16,0xd0,0x17,0xd2,0x0a,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90,0x53,0xf9,0x1c,0xd1,0x17,0x90
stop1	      	.byte		0xff,0x11,0xff,0xaa,0xff
```
Next, we store the key (if there is one) into RAM. Like the message, we put a stop code (`stop2`) that is unique from `stop1` in order to count the length of the key. If there is no key, we simply input `stop2` as the key. The program will count and read a key length of 0 bytes.
```
key		.byte		0xff,0xaa,0xff,0x11,0xff	;putting stop code in key means that the key is unknown
stop2	      	.byte		0xff,0xaa,0xff,0x11,0xff
```
If no key is given, our program counts up frequently seen bits and compares them against a pair of user-provided guesses to provide a possible key. The guesses should be educated after looking carefully at the message and where the most frequent bytes appear in the string. These guesses are stored in RAM.
```
;these guesses are compared against the most frequent even or odd characters in order to determine the key.
guess1      	.string		"e"
guess2		.string		"."
```
In ROM, we save space for the newly decrypted message (`decrypted`) and the new key (`newkey`) if it is necessary.
```
		.data
decrypted	.space		90
newkey		.space		2
```
We must also initialize the stackpointer and stop the watchdog timer in order for the program to run correctly.
```
RESET         	mov.w   	#__STACK_END,SP         ; Initialize stackpointer
StopWDT       	mov.w   	#WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
```

#### Main Loop

First, we load the registers with the necessary information. r4 will hold the message pointer, r5 holds the key pointer, r6 holds the message length in bytes, r7 holds the key length in bytes, and r8 holds the decrypted message pointer.
```
			mov.w	#message, r4
			mov.w	#key, r5
			mov.w	#decrypted, r8
```
We then prepare to enter our first loop. This loop counts the length of message in bytes by going through each byte and looking for the `stop1` sequence. Once it sees it, it knows to stop counting and we have a value for the length of the message.
```
			clr		r6
			clr		r7
			dec		r4
			dec		r5
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
```
Similarly, the key length counter looks for the value of `stop2` and will continue counting until it reaches it.
```
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
```
If the key length is 0 bytes, then we know we have not been given a key and must determine it on our own. Therefore, we check the key length is 0, if it is we call `guessthekey` to try and guess what the key is before we continue. If/once it is known, we call `decryptMessage` and go about decrpyting the message and saving into memory. Once we're done decrypting, we trap the CPU.
```
			mov.w	#message, r4
			mov.w	#key, r5
			cmp		#0, r7
			jne		getthemsg
			call	#guessthekey
			mov.w	#newkey, r5
			mov.w	#2, r7
getthemsg	call   	#decryptMessage

forever:    jmp     forever	;traps the CPU

```

#### Subroutine 1: `decryptMessage`
This subroutine takes message pointer, the key pointer, the message length, and the key length. It lines up one byte of the key with one byte of the message and calls `decryptCharacter` to do the actual decrypting. When it receives the decrypted character back, it stores it into memory and starts the process over again until the entire message is decoded.

Throughout this subroutine, r4-r8 hold true to their previous values, r9 counts through the program and serves as a comparison with the length of the message, r10 also counts through the program and compares with the length of the key, r11 is the message byte that gets xor'd with the key byte to get stored in memory, r12 holds a copy of the initial value of the key pointer so that it can be restored when it needs to be cycled through again, and r13 holds the value of the key byte that the program will xor with the message byte. The first segment of the subroutine just initializes for the rest of the loop.
```
decryptMessage:
			mov.w	#0, r9
			mov.w	#0,	r10
			mov.w	r5, r12
			dec		r4
			dec		r5
			inc		r6
			inc		r7
```
This loop goes through each byte of the message, cycles through the key bytes, and sends a message byte and key byte off to the decryptCharacter subroutine. When it gets the decrypted byte back from decryptCharacter subroutine. The `dcrxtchar` jump must be used because we need to call `decryptCharacter from different conditions yet return to the same place.
```
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
```
Once we get our decrypted byte back from the `decryptCharacter` subroutine, we store it into the appropriate memory location.
```
done2		mov.b	r11, 0(r8)
			inc		r8
			jmp		startdecrxn
```
After decrypting the whole message, the length registers (r6,r7) are restored and the rest of the registers are cleared so they can be used elsewhere and are not destroyed.
```
done		dec 	r6
			dec		r7
			clr		r9
			clr		r10
			clr		r11
			clr		r12
			clr 	r13
			ret
```
I need this small segment here to call `decryptCharacter` because it can be called from different locations but must return to the same location.
```
dcrxtchar	call	#decryptCharacter
			jmp		done2
```

#### Subroutine 2: `decryptCharacter`

`decryptCharacter` takes the message byte, the key byte, xor's them together and sends back the decrypted message byte in r13.

```
decryptCharacter:
			xor.w	r13, r11
            ret
```

#### Subroutine 3: `guessthekey`
We learn from the decryption of the B functionality message that the key to the A functionality message is 16 bits long. Meaning that every odd bit and every even bit is keyed the same. In order to ascertain the key, we look at what even bytes appear frequently, guess what the decrypted value of that byte is, and then make half of the key based off of that. We create the other half of the key by doing the same to the odd bytes.

Therefore, this sequence is broken into two parts: even and odd bytes. This portion counts the even-addressed bytes and looks for a value that appears 3 times (arbitrarily chosen value). I felt if it appeared 3 times it was a significant character, probably a vowel, a space, or a period. Then, we xor it with the guess for that character is (`guess1`) and store that as the first byte of the new key.
```
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
```
This portion counts the odd-addressed bytes and looks for a value that appears 3 times. It is essentially the same process as the even counter. Then, we xor it with the guess for that character is (`guess2`) and store that as the second byte of the new key.
```
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
```

## Debugging


## Testing Methodology/Results

#### C Functionality


#### B Functionality

#### A Functionality


## Observations and Conclusion
#### Observations


#### Conclusion


## Documentation
##### None
