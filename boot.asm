[org 0x7C00]
bits 16

start:
    MOV SI, messaggio

    MOV AH, 0x0E

loop:
    LODSB
    CMP AL, 0
    JE fine

    INT 10h

    JMP loop

fine:
    JMP fine

messaggio:
    db "Semantic", 0

times 510-($-$$) db 0
dw 0xAA55
