[org 0x7C00]
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

        MOV SI, input_buffer
        MOV DI, cmd_help
        CALL strcmp
        JE .do_help

        JMP .unknown_command

        .do_help:
            CALL help
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

strcmp:
    .loop:
        MOV AL, [SI]      ; character string 1
        MOV BL, [DI]      ; character string 1

        CMP AL, BL
        JNE .not_equal    ; if different, exit

        CMP AL, 0
        JE .equal         ; if both 0, they're both equal

        INC SI            ; next character
        INC DI
        JMP .loop

    .not_equal:
        RET               ; ZF = 0

    .equal:
        RET               ; ZF = 1

help:
    MOV SI, help_text
    CALL print
    CALL newline
    RET

unknown:
    MOV SI, unknown_text
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

cmd_help:
    db "HELP", 0

help_text:
    db "HELP:   shows available commands", 0

unknown_text:
    db "Unknown command", 0

; ==========================================
; BOOT SIGNATURE
; ==========================================

times 510-($-$$) db 0
dw 0xAA55
