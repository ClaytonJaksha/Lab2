Lab 2: Decryption
===
#### Clayton Jaksha | ECE 382 | Dr. York | M2A

## Objective and Purpose
### Objective

The objective of this lab is to gain a foundational understanding of cryptography, the usefulness of xor for encryption, and the use of subroutines in complex programming.

### Purpose

This program is designed to take an xor-encrypted message, a key (or none), and return a decrypted message in ROM. Through programming, it will make use of subroutines to perform a specific task(s). For the A-solution, it will not take a key and still decrypte the message, although it still requires some critical thought on the part of the user.

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

#### Subroutine 3: `guessthekey`

## Code Walkthrough

#### Initialization

#### Main Loop

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
