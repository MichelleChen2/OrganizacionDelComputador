; EJ15
; Se lee de un archivo una serie de números en formato carácter de 3 bytes. Se pide
; realizar un programa que realice la sumatoria de esos números e informe el
; resultado por pantalla, indicando además la cantidad de números válidos e inválidos
; leídos del archivo.

global main
extern fopen
extern fclose
extern printf
extern fgets
extern sscanf

section     .data

    fileName            db          "archivoej15.txt", 0
    modo                db          "r", 0
    handle              dq           0

    numFormat           db          "%hi", 0

    msjApertura         db          "El archivo se abrió correctamente", 10, 0
    msjNumLeido         db          "El número leído es %s", 10, 0
    msjNumValido        db          "El número leído es válido", 10, 0
    msjCantSum          db          "Cantidad de números: %hi / Sumatoria: %hi",10, 0


    registro        times 0         db      ''
    numero          times 3         db      ' '


section     .bss

    cantidad        resw            1
    sumatoria       resw            1

    registroValido  resb            1
    datoValido      resb            1
    numNumero       resw            1

section     .text

main:
    mov     word[cantidad], 0
    mov     word[sumatoria], 0


    ; Abrir archivo
    mov     rdi, fileName
    mov     rsi, modo
    sub     rsp, 8
    call    fopen
    add     rsp, 8

    ; Verificar si abrió correctamente
    cmp     rax, 0
    jle     fin
    mov     [handle], rax

    ; Mensaje éxito en abrir el archivo
    mov     rdi, msjApertura
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

leer:

    mov     rdi, registro
    mov     rsi, 20
    mov     rdx, [handle]
    sub     rsp, 8
    call    fgets
    add     rsp, 8

    cmp     rax, 0
    jle     cerrarArchivo

    ; Leyó
    mov     rdi, msjNumLeido
    mov     rsi, registro
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    call    validarRegistro
    cmp     byte[registroValido], 'N'
    je      leer

    mov     rdi, msjNumValido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rax, 0
    mov     ax, [numNumero]
    inc     word[cantidad]
    add     word[sumatoria], ax
    jmp     leer

cerrarArchivo: 

    mov     rdi, [handle]
    sub     rsp, 8
    call    fclose
    add     rsp, 8


    mov     rdi, msjCantSum
    mov     rsi, [cantidad]
    mov     rdx, [sumatoria]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8


fin:
    ret


validarRegistro:

    mov     byte[registroValido], 'N'

    call    validarNumero
    cmp     byte[datoValido], 'N'
    je      finValidarRegistro

    mov     byte[registroValido], 'S'

finValidarRegistro:
    ret


validarNumero:

    mov     byte[datoValido], 'N'

    mov     rdi, numero
    mov     rsi, numFormat
    mov     rdx, numNumero
    sub     rsp, 8
    call    sscanf
    add     rsp, 8

    cmp     rax, 1
    jl      finValidarNumero

    cmp     word[numNumero], -999
    jl      finValidarNumero

    cmp     word[numNumero], 999
    jg      finValidarNumero

    mov     byte[datoValido], 'S'


finValidarNumero:
    ret
