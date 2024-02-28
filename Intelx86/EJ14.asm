; EJ14
; Realizar una rutina interna que reciba como parámetros las direcciones (DIR1 y
; DIR2) de dos campos hexadecimales de 2 bytes de longitud cada uno y realice la
; suma de ambos (en BPF s/signo de 16 bits) dejando el resultado en el campo
; resultado RESULT en formato BPF c/s 16 bits.

global main
extern printf

section         .data

    DIR1       db       15h
    DIR2       db       11h

    msj        db       "El resultado es %hhi", 10, 0

section         .bss

    RESULT      resw       1

section         .text
main:

    mov     word[RESULT], 0


    mov     ax, [DIR1]
    mov     dx, [DIR2]
    add     ax, dx
    mov     word[RESULT], ax

    mov     rdi, msj
    mov     rsi, [RESULT]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

fin: 
    ret