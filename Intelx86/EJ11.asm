; EJERCICIO 11
; Realizar una rutina interna que reciba como parámetro un campo DIA en formato de
; caracteres de 2 bytes y devuelva en un campo resultado RESULT en formato
; carácter de 1 byte, indicando una ‘S’ en caso que el día sea válido, y en caso
; contrario una ‘N’.
; Los valores válidos son LU, MA, MI, JU, VI, SA, DO.

global main

extern printf 
extern sscanf

section .data

    DIA             db      "LUNES"
    longitudDia     equ     $ - DIA
    DIAS            db      "LUMAMIJUVISADO", 0
    msj_valido      db      "El día ingresado es válido. ", 10, 0
    msj_invalido    db      "El día ingresado no es válido. ", 10, 0

section .bss

    RESULT      resb    1

section .text
main: 

    call validar

    cmp     byte[RESULT], 'S'
    je      mensajeValido

    mov     rdi, msj_invalido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8
    jmp     final

mensajeValido:  
    mov     rdi, msj_valido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

fin:
ret

validar: 
    mov     byte[RESULT], 'N'
    mov     rcx, 7
    mov     rax, 0

    mov     rdx, 2
    cmp     rdx, longitudDia
    jne      final

ciclo: 
    mov     rbx, rcx ; Guardo el número del contador rcx
    mov     rcx, 2
    lea     rsi, [DIAS + rax]
    lea     rdi, [DIA]
    repe    cmpsb
    mov     rcx, rbx

    je      diaValido
    add     rax, 2
    loop    ciclo

    jmp     final
diaValido: 
    mov     byte[RESULT], 'S'

final: 
    ret

