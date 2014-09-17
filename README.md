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
			;load registers with necessary info for decryptMessage here
			;
			;r4 points to message location
			;r5 points to key location
			;r6 holds message length (bytes)
			;r7 holds key lengths (bytes)
			;r8 holds decrypted pointer
            
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

forever:    jmp     forever	;traps the CPU

```

#### Subroutine 1: `decryptMessage`

#### Subroutine 2: `decryptCharacter`

#### Subroutine 3: `guessthekey`

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
