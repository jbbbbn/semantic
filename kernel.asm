[org 0x8000]
bits 16

start:
    MOV SI, messaggio
    CALL print
    CALL newline
    JMP main

; ==========================================
; MAIN TERMINAL
; ==========================================

main:
    MOV DI, input_buffer
    MOV BYTE [DI], 0

    MOV SI, prompt
    CALL print

.input:
    ; Wait for a key
    MOV AH, 0x00
    INT 0x16

    ; Check for ENTER
    CMP AL, 0x0D
    JE .execute

    ; Store character in buffer
    MOV [DI], AL
    INC DI

    ; Echo character
    MOV AH, 0x0E
    INT 0x10

    JMP .input

.execute:
    ; Null-terminate input
    MOV BYTE [DI], 0
    CALL newline

    ; CLS
    MOV SI, input_buffer
    MOV DI, cmd_cls
    CALL strcmp
    JE .do_cls

    ; ECHO
    MOV SI, input_buffer
    MOV DI, cmd_echo
    CALL strcmp4
    JE .do_echo

    ; HELP
    MOV SI, input_buffer
    MOV DI, cmd_help
    CALL strcmp
    JE .do_help

    ; TIME
    MOV SI, input_buffer
    MOV DI, cmd_time
    CALL strcmp
    JE .do_time

    ; VER
    MOV SI, input_buffer
    MOV DI, cmd_ver
    CALL strcmp
    JE .do_ver

    JMP .unknown_command

.do_cls:
    CALL cls
    JMP main

.do_echo:
    CALL echo
    JMP main

.do_help:
    CALL help
    JMP main

.do_time:
    CALL time
    JMP main

.do_ver:
    CALL ver
    JMP main

.unknown_command:
    CALL unknown
    JMP main

; ==========================================
; FUNCTIONS
; ==========================================

newline:
    MOV AH, 0x0E

    MOV AL, 0x0D
    INT 0x10

    MOV AL, 0x0A
    INT 0x10

    RET

print:
    MOV AH, 0x0E

.loop:
    LODSB
    CMP AL, 0
    JE .done

    INT 0x10
    JMP .loop

.done:
    RET

print_bcd:
    PUSH BX

    MOV BL, AL

    ; High digit
    SHR AL, 4
    ADD AL, '0'
    MOV AH, 0x0E
    INT 0x10

    ; Low digit
    MOV AL, BL
    AND AL, 0x0F
    ADD AL, '0'
    MOV AH, 0x0E
    INT 0x10

    POP BX
    RET

strcmp:
.loop:
    MOV AL, [SI]
    MOV BL, [DI]

    CMP AL, BL
    JNE .not_equal

    CMP AL, 0
    JE .equal

    INC SI
    INC DI
    JMP .loop

.not_equal:
    RET

.equal:
    RET

strcmp4:
    MOV CX, 4

.loop:
    MOV AL, [SI]
    MOV BL, [DI]

    CMP AL, BL
    JNE .not_equal

    INC SI
    INC DI
    LOOP .loop

    ; After ECHO, require space or end of string
    MOV AL, [SI]
    CMP AL, ' '
    JE .equal

    CMP AL, 0
    JE .equal

.not_equal:
    RET

.equal:
    RET

cls:
    MOV AH, 0x06
    MOV AL, 0x00
    MOV BH, 0x07
    MOV CX, 0x0000
    MOV DX, 0x184F
    INT 0x10

    ; Move cursor to (0,0)
    MOV AH, 0x02
    MOV BH, 0x00
    MOV DH, 0x00
    MOV DL, 0x00
    INT 0x10

    RET

echo:
    CMP BYTE [SI], 0
    JE .done

    INC SI
    CALL print

.done:
    CALL newline
    RET

help:
    MOV SI, help_text
    CALL print
    CALL newline
    RET

time:
    MOV AH, 0x02
    INT 0x1A

    MOV AL, CH
    CALL print_bcd

    MOV AL, ':'
    MOV AH, 0x0E
    INT 0x10

    MOV AL, CL
    CALL print_bcd

    MOV AL, ':'
    MOV AH, 0x0E
    INT 0x10

    MOV AL, DH
    CALL print_bcd

    CALL newline
    RET

unknown:
    MOV SI, unknown_text
    CALL print
    CALL newline
    RET

ver:
    MOV SI, ver_text
    CALL print
    CALL newline
    RET

; ==========================================
; DATA
; ==========================================

messaggio:
    db "Semantic", 0

prompt:
    db "S:> ", 0

input_buffer:
    times 64 db 0

cmd_cls:
    db "CLS", 0

cmd_echo:
    db "ECHO", 0

cmd_help:
    db "HELP", 0

cmd_time:
    db "TIME", 0

cmd_ver:
    db "VER", 0

help_text:
    db "CLS   - clears the screen",0x0D,0x0A
    db "ECHO  - prints the given text",0x0D,0x0A
    db "HELP  - shows available commands",0x0D,0x0A
    db "TIME  - shows current system time",0x0D,0x0A
    db "VER   - shows system version",0

unknown_text:
    db "Unknown command", 0

ver_text:
    db "Semantic 0.9", 0
