; EJ13
; Se tiene una fecha en formato carácter DD/MM/AAAA se pide realizar una rutina
; interna que realice la validación dejando en el campo RESULT de 1 byte una 'S' si
; es válida o una 'N'; en caso contrario.

global main
extern printf
extern sscanf

section .data

    FECHA                       db     "08/08/2000"
    longitudFecha               equ     $ - FECHA

    formato                     db      "%d", 0

    msjNumero                   db      "Valor recibido: %d", 10, 0
    msjSeparador                db      "separador: %s", 10, 0

    msj_valido                  db      "Fecha válida!", 10, 0
    msj_invalido                db      "Fecha Inválida", 10, 0

section .bss

    RESULT                      resb    1

    dia                         resb    2
    mes                         resb    2
    anio                        resb    4
    separador                   resb    2

    numDia                      resb    8
    numMes                      resb    8
    numAnio                     resb    1

section .text
main:

    call validar

    cmp     byte[RESULT], 'S'
    je      fechaValida

    mov     rdi, msj_invalido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8
    jmp     imprimir


fechaValida:

    mov     rdi, msj_valido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

imprimir:

    mov     rdi, msjNumero
    mov     rsi, [numDia]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, msjSeparador
    mov     rsi, separador
    sub     rax, rax
    sub     rsp, 8
    call    printf 
    add     rsp, 8

    mov     rdi, msjNumero
    mov     rsi, [numMes]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, msjNumero
    mov     rsi, [numAnio]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

fin: 
    ret

validar:

    mov     rdx, 10
    cmp     rdx, longitudFecha
    jne     final

    mov     rcx, 2
    lea     rsi, [FECHA]
    lea     rdi, [dia]
    rep     movsb

    mov     rdi, dia
    mov     rsi, formato
    mov     rdx, numDia
    call    sscanf

    mov     rdx, 1
    cmp     [numDia], rdx
    jl      final

    mov     rdx, 31
    cmp     [numDia], rdx
    jg      final

    mov     rcx, 1
    lea     rsi, [FECHA + 2]
    lea     rdi, [separador]
    rep     movsb

    cmp     byte[separador], '/'
    jne     final

    mov     rcx, 2
    lea     rsi, [FECHA + 3]
    lea     rdi, [mes]
    rep     movsb

    mov     rdi, mes
    mov     rsi, formato
    mov     rdx, numMes
    call    sscanf

    mov     rdx, 1
    cmp     [numMes], rdx
    jl      final    

    mov     rdx, 12
    cmp     [numMes], rdx
    jg      final

    mov     rcx, 1
    lea     rsi, [FECHA + 5]
    lea     rdi, [separador]
    rep     movsb

    cmp     byte[separador], '/'
    jne     final

    mov     rcx, 4
    lea     rsi, [FECHA + 6]
    lea     rdi, [anio]
    rep     movsb

    mov     rdi, anio
    mov     rsi, formato
    mov     rdx, numAnio
    call    sscanf

    mov     rdx, 1000
    cmp     [numAnio], rdx
    jl      final

    mov     rdx, 9999
    cmp     [numAnio], rdx
    jg      final

    mov     byte[RESULT], 'S'

final:
    ret