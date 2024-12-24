.MODEL SMALL
.STACK 100h
.DATA
    closeProgram DB 0

    myCursorX DB 0
    myCursorY DB 0

    otherCursorX DB 0
    otherCursorY DB 13

.CODE
CLEAR_SCREEN PROC
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    RET
CLEAR_SCREEN ENDP

DRAW_SEPARATOR PROC
    ; Set the cursor position to row 12
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 12
    MOV DL, 0
    INT 10H
    
    ; Draw the horizontal line using the character '-'
    MOV AH, 09H
    MOV AL, '-'
    MOV BL, 7
    MOV CX, 80
    INT 10H

    RET
DRAW_SEPARATOR ENDP

INIT_SERIAL PROC
    ; Set Divisor Latch Access Bit
    MOV DX, 3fbh
    MOV AL, 10000000b
    OUT DX, AL

    ; Set LSB byte of the Baud Rate Divisor Latch register.
    MOV DX, 3f8h
    MOV AL, 0ch
    OUT DX, AL

    ; Set MSB byte of the Baud Rate Divisor Latch register.
    MOV DX, 3f9h
    MOV AL, 00h
    OUT DX, AL

    ;Set port configuration
    MOV DX, 3fbh
    MOV AL, 00011011b
    OUT DX, AL

    RET
INIT_SERIAL ENDP

MOVE_MY_CURSOR PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 02H
    MOV BH, 0
    MOV DH, myCursorY
    MOV DL, myCursorX
    INT 10H

    POP DX
    POP BX
    POP AX
    RET
MOVE_MY_CURSOR ENDP

MOVE_OTHER_CURSOR PROC
    PUSH AX
    PUSH BX
    PUSH DX

    MOV AH, 02H
    MOV BH, 0
    MOV DH, otherCursorY
    MOV DL, otherCursorX
    INT 10H

    POP DX
    POP BX
    POP AX
    RET
MOVE_OTHER_CURSOR ENDP

SCROLL_WINDOW PROC
    PUSH AX
    PUSH BX

    MOV AH, 06H
    MOV AL, 01H
    MOV BH, 07H
    INT 10H

    POP BX
    POP AX
    RET
SCROLL_WINDOW ENDP

RECEIVE_KEY PROC
    ; Check if data Ready from UART
    MOV DX, 03FDH
    IN AL, DX
    AND AL, 1
    JNZ R_WAIT_FOR_DATA
    JMP END_RECEIVE_KEY

R_WAIT_FOR_DATA:
    ; Read the value
    MOV DX, 03F8H
    IN AL, DX

    ; Check if esc is pressed
    CMP AL, 27
    JZ R_CLOSE_PROGRAM

    ; Move the cursor to the other side
    CALL MOVE_OTHER_CURSOR

    ; Check if char is a new line
    CMP AL, 0Dh
    JNZ R_DISPLAY_VALUE
    MOV otherCursorX, 0
    INC otherCursorY
    JMP R_CHECK_CURSOR_POS

R_DISPLAY_VALUE:
    ; Check if char is a backspace
    CMP AL, 8
    JNE R_SKIP_BACKSPACE
    CMP otherCursorX, 0
    JE R_CHECK_CURSOR_POS

R_HANDLE_BACKSPACE:
    MOV AH,0eh
    INT 10h
    MOV AL, ' '
    INT 10h
    MOV AL, 8
    INT 10h
    DEC otherCursorX
    JMP R_CHECK_CURSOR_POS

R_SKIP_BACKSPACE:
    ; Display the value
    MOV DL, AL
    MOV BH, 0
    MOV CX, 1
    MOV AH, 09h
    MOV BL, 0Dh
    INT 10h

R_INCREMENT_CURSOR:
    ; Increment the cursor position and check if it is the end of row
    INC otherCursorX
    CMP otherCursorX, 80
    JNE R_CHECK_CURSOR_POS
    MOV otherCursorX, 0
    INC otherCursorY

R_CHECK_CURSOR_POS:
    ; Check if the cursor is at the end of the screen and set a flag
    CMP otherCursorX, 0
    JNE END_RECEIVE_KEY
    CMP otherCursorY, 25
    JNE END_RECEIVE_KEY

    ; Scroll the window
R_SCROLL_WINDOW:
    MOV CH, 13
    MOV CL, 0
    MOV DH, 24
    MOV DL, 79
    MOV BL, 03h
    CALL SCROLL_WINDOW
    MOV otherCursorX, 0
    MOV otherCursorY, 24

    JMP END_RECEIVE_KEY

R_CLOSE_PROGRAM:
    MOV closeProgram, 1

END_RECEIVE_KEY:
    RET
RECEIVE_KEY ENDP

TRANS_KEY PROC
    ; Check if key is pressed
    MOV AH, 0Bh
    INT 21h
    CMP AL, 0h
    JNZ T_WAIT_FOR_EMPTY
    JMP EXIT_TRANS_KEY

    ; Check that Transmitter Holding Register is Empty
T_WAIT_FOR_EMPTY:
    MOV DX, 3FDH
    IN AL, DX
    AND AL, 00100000b
    JZ T_WAIT_FOR_EMPTY

    ; Read the value
    MOV AH, 00H
    INT 16h

    ; Transmit the value
    MOV DX, 3F8H
    OUT DX , AL

    ; Check if esc is pressed
    CMP AL, 27
    JZ T_CLOSE_PROGRAM

    ; Move the cursor to the other side
    CALL MOVE_MY_CURSOR

; Check if char is a new line
    CMP AL, 0Dh
    JNZ T_DISPLAY_VALUE
    MOV myCursorX, 0
    INC myCursorY
    JMP T_CHECK_CURSOR_POS

T_DISPLAY_VALUE:
    ; Check for backspace
    CMP AL, 8
    JNE T_SKIP_BACKSPACE
    CMP myCursorX, 0
    JE T_CHECK_CURSOR_POS

T_HANDLE_BACKSPACE:
    MOV AH, 0eh
    INT 10h
    MOV AL, ' '
    INT 10h
    MOV AL, 8
    INT 10h
    DEC myCursorX
    JMP T_CHECK_CURSOR_POS

T_SKIP_BACKSPACE:
    ; Display the value
    MOV DL, AL
    MOV BH, 0
    MOV CX, 1
    MOV AH, 09h
    MOV BL, 0Bh
    INT 10h

T_INCREMENT_CURSOR:
    ; Increment the cursor position and check if it is the end of row
    INC myCursorX
    CMP myCursorX, 80
    JNE T_CHECK_CURSOR_POS
    MOV myCursorX, 0
    INC myCursorY

T_CHECK_CURSOR_POS:
    ; Check if the cursor is at the end of the screen
    CMP myCursorX, 0
    JNE EXIT_TRANS_KEY
    CMP myCursorY, 12
    JNE EXIT_TRANS_KEY

    ; Scroll the window
T_SCROLL_WINDOW:
    MOV CH, 0
    MOV CL, 0
    MOV DH, 11
    MOV DL, 79
    CALL SCROLL_WINDOW
    MOV myCursorX, 0
    DEC myCursorY

    ; Set the cursor position
    CALL MOVE_MY_CURSOR

    JMP EXIT_TRANS_KEY

T_CLOSE_PROGRAM:
    MOV closeProgram, 1

EXIT_TRANS_KEY:
    RET
TRANS_KEY ENDP

MAIN PROC FAR
    MOV AX, @DATA
    MOV DS, AX

    ; Clear the screen
    CALL CLEAR_SCREEN

    ; Divide the screen into two parts
    CALL DRAW_SEPARATOR

    ; Initialize the serial port
    CALL INIT_SERIAL

MAIN_LOOP:
    CALL MOVE_MY_CURSOR

    ; Check if there is a character in the UART
    CALL RECEIVE_KEY

    ; Check if esc is pressed
    CMP closeProgram, 1
    JZ EXIT_PROGRAM

    ; Check if key is pressed and send it to the UART
    CALL TRANS_KEY

    ; Check if esc is pressed
    CMP closeProgram, 1
    JZ EXIT_PROGRAM

    JMP MAIN_LOOP

EXIT_PROGRAM:
    CALL CLEAR_SCREEN

    ; Move the cursor to the top left corner
    MOV AH, 02H
    MOV BH, 0
    MOV DH, 0
    MOV DL, 0
    INT 10H

    MOV AH, 4ch
    INT 21h
MAIN ENDP
END MAIN

