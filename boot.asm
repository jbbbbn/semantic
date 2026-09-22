[org 0x7C00]
bits 16

KERNEL_OFFSET equ 0x8000

start:
    MOV [BOOT_DRIVE], DL

    XOR AX, AX
    MOV DS, AX
    MOV ES, AX
    MOV SS, AX
    MOV SP, 0x7C00

    MOV BX, KERNEL_OFFSET
    MOV DH, 4
    MOV DL, [BOOT_DRIVE]
    CALL disk_load

    JMP KERNEL_OFFSET

disk_load:
    MOV AH, 0x02
    MOV AL, DH
    MOV CH, 0x00
    MOV CL, 0x02
    MOV DH, 0x00
    INT 0x13
    RET

BOOT_DRIVE:
    db 0

times 510-($-$$) db 0
dw 0xAA55
