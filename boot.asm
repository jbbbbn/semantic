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

    MOV SI, prompt
    CALL print

    .input:
        ; Attende un tasto
        MOV AH, 0x00
        INT 0x16

        ; ENTER?
        CMP AL, 0x0D
        JE .execute

        ; Salva nel buffer
        MOV [DI], AL
        INC DI

        ; Echo sullo schermo
        MOV AH, 0x0E
        INT 0x10

        JMP .input

    .execute:
        ; Chiude la stringa con 0
        MOV BYTE [DI], 0

        CALL newline
        JMP main

; ==========================================
; FUNZIONI
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

; ==========================================
; DATA
; ==========================================

messaggio:
    db "Semantic", 0

prompt:
    db "S:> ", 0

input_buffer:
    times 64 db 0

; ==========================================
; BOOT SIGNATURE
; ==========================================

times 510-($-$$) db 0
dw 0xAA55
