; EJ17
; La liga de basquetball de Villa Tachito desea tener un programa para determinar
; quién fue el ganador del torneo anual de clubes. Para ello cuenta con un archivo
; que contiene:
;       Nombre del equipo: 20 caracteres alfanuméricos
;       Resultados: BPF S/S de 16 bits
;       Tantos a favor: Empaquetado de 2 bytes
;       Tantos en contra: Empaquetado de 2 bytes
; El programa deberá imprimir por pantalla el nombre del campeón del torneo junto
; con la cantidad de partidos ganados y perdidos y su diferencia de tantos. Para
; determinar la cantidad de partidos ganados se procesa el campo Resultados que
; indica por cada bit el resultado de un partido del torneo. (En total cada equipo jugó
; 16 partidos) Si el bit está en 1 significa que el equipo ganó ese partido, si está en 0
; significa que lo perdió.

global main
extern sscanf
extern printf
extern fgets
extern fopen
extern fclose

section     .data

    nombreArchivo       db          "archivoej17.txt", 0
    modo                db          "r", 0
    idArchivo           dq          0

    formatoEntrada      db          "%s", 10, 0
    formatoNumero       db          "%hhi", 10, 0

    msjExitoApertura    db          "Archivo se abrió correctamente", 10, 0

section     .bss

    registro                resb        51

    nombreEquipo            resb        20
    longitudNombreEquipo    resq        1

    resultado               resb        25
    aFavor                  resb        3
    enContra                resb        3


section     .text
main:

    mov     rdi, nombreArchivo
    mov     rsi, modo
    sub     rsp, 8
    call    fopen
    add     rsp, 8

    cmp     rax, 0
    jle     cerrarArchivo
    mov     qword[idArchivo], rax

    ; Mensaje éxito apertura
    mov     rdi, msjExitoApertura
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

leerRegistro:

    mov     rdi, registro
    mov     rsi, 50
    mov     rdx, [idArchivo]
    sub     rsp, 8
    call    fgets
    add     rsp, 8

    mov     rdi, formatoEntrada
    mov     rsi, registro
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    call    leer


cerrarArchivo:

    mov     rdi, [idArchivo]
    sub     rsp, 8
    call    fclose
    add     rsp, 8

imprimir:

    mov     rdi, formatoEntrada
    mov     rsi, nombreEquipo
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, formatoNumero
    mov     rsi, [longitudNombreEquipo]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8


    mov     rdi, formatoEntrada
    mov     rsi, resultado
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, formatoEntrada
    mov     rsi, aFavor
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, formatoEntrada
    mov     rsi, enContra
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, formatoNumero
    mov     rsi, rbx
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

fin:
    ret


leer:

    mov     rbx, 0
    mov     qword[longitudNombreEquipo], 0

; Leer nombre del equipo
leerCaracter:

    cmp     byte[registro + rbx], ','
    je      leerResultado

    mov     al, [registro + rbx]
    mov     [nombreEquipo + rbx], al

    inc     rbx
    inc     qword[longitudNombreEquipo]
    loop    leerCaracter

; Leer resultado del nombre
leerResultado:

    mov     rbx, 0
    mov     rdx, 0
    mov     rbx, [longitudNombreEquipo]
    inc     rbx

leerEquipoResultado:

    cmp     byte[registro + rbx], ','
    je      leerAFavor

    mov     al, [registro + rbx]
    mov     [resultado + rdx], al

    inc     rbx
    inc     rdx
    loop    leerEquipoResultado

leerAFavor:

    mov     rbx, 0
    mov     rdx, 0
    mov     rcx, 3
    mov     rbx, [longitudNombreEquipo]
    add     rbx, 18

leerNumeroAFavor:

    cmp     byte[registro], ','
    je      finLeer

    mov     al, [registro + rbx]
    mov     [aFavor + rdx], al

    inc     rbx
    inc     rdx
    loop    leerNumeroAFavor

leerEnContra: 


finLeer:
    ret


