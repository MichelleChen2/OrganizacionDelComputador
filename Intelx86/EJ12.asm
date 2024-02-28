; EJ12
; Realizar una rutina interna que reciba como parámetro un campo MES en formato
; BPF c/s de 8 bits y devuelva en un campo resultado RESULT en formato carácter de
; 1 byte, indicando una ‘S’ en caso que el valor del mes sea válido, y en caso
; contrario una ‘N’.

global main
extern printf

section .data
    
    MES        db          2

    msj_invalido       db       "El mes es inválido", 10, 0
    msj_valido         db       "El mes es válido", 10, 0

section .bss

    RESULT      resb       1

section .text

main:

    call    validar

    cmp     byte[RESULT], 'S'
    je      mesValido

    mov     rdi, msj_invalido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8
    jmp     fin

mesValido:

    mov     rdi, msj_valido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

fin:
    ret


validar:

    mov     byte[RESULT], 'N'

    cmp   byte[MES], 12
    jg    final

    cmp     byte[MES], 1
    jl      final

    mov     byte[RESULT], 'S'


final:
    ret
