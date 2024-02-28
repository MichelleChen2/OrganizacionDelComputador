; Dado un archivo en formato BINARIO que contiene informacion sobre autos llamado listado.dat
; donde cada REGISTRO del archivo representa informacion de un auto con los campos: 
;   marca:							10 caracteres
;   año de fabricacion:				4 caracteres
;   patente:						7 caracteres
;	precio							4 bytes en bpf s/s
; Se pide codificar un programa en assembler intel que lea cada registro del archivo listado y guarde
; en un nuevo archivo en formato binario llamado seleccionados.dat las patentes y el precio (en bpfc/s) de aquellos autos
; cuyo año de fabricación esté entre 2020 y 2022 (inclusive) y cuyo precio sea inferior a 5.000.000$
; Como los datos del archivo pueden ser incorrectos, se deberan validar mediante una rutina interna.
; Se deberá validar:
;   Marca (que sea Fiat, Ford, Chevrolet o Peugeot)
;   Año (que sea un valor numérico y que cumpla la condicion indicada del rango) 
;   Precio que sea un valor numerico.

global main
extern sscanf
extern printf
extern fopen
extern fclose
extern fread
extern fwrite

section     .data

    nombreArchivoAutos                  db                  "listado.dat", 0
    modoAutos                           db                  "rb", 0
    idArchivoAutos                      dq                  0

    nombreArchivoSeleccionados          db                  "seleccionados.dat", 0
    modoSeleccionados                   db                  "wb", 0
    idSeleccion                         dq                  0

    msjAperturaExito                    db                  "El archivo autos se abrió con éxito", 10, 0
    msjRegistroInvalido                 db                  "Registro Inválido", 10, 0

    registroAutos                      times 0      db      ''
    marcaAutos                         times 10     db      ' '
    anioFabricacionAutos               times 4      db      ' '
    patenteAutos                       times 7      db      ' '
    precioAutos                        times 4      db      ' '

    anioString                          db          "****", 0
    anioNumero                          dw          0

    precioNumero                        dd          0

    vecMarcasValidas                    db          "Fiat      Ford      Chevrolet Peugeot   "
    formatoAnioValido                   db          "%hi", 10, 0

    formatoPruebaString                 db          "%s", 10, 0

    registroSeleccion                  times 0      db      ''
    patenteSeleccionado                times 7      db      ' '
    precioSeleccionado                              dd      0


    msjValidezMarca                     db          "Marca: %s", 10, 0
    msjValidezAnio                      db          "Año: %s", 10, 0
    msjValidezPrecio                    db          "Precio: %s", 10, 0

section     .bss

    registroValido              resb            1

    marcaValida                 resb            1
    precioValido                resb            1
    patenteValido               resb            1
    anioValido                  resb            1

section     .text
main: 

abrirArchivoAutos:
    mov     rdi, nombreArchivoAutos
    mov     rsi, modoAutos
    sub     rsp, 8
    call    fopen
    add     rsp, 8

    cmp     rax, 0
    jle     cerrarArchivoAutos
    mov     qword[idArchivoAutos], rax

    mov     rdi, msjAperturaExito
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8
    
    mov     rdi, nombreArchivoSeleccionados
    mov     rsi, modoSeleccionados
    sub     rsp, 8
    call    fopen
    add     rsp, 8

    cmp     rax, 0
    jle     cerrarArchivoAutos
    mov     qword[idSeleccion], rax

    mov     rdi, msjAperturaExito
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

leerRegistro:

    mov     rdi, registroAutos
    mov     rsi, 25
    mov     rdx, 1
    mov     rcx, [idArchivoAutos]
    sub     rsp, 8
    call    fread   
    add     rsp, 8

    cmp     rax, 0 
    jle     cerrarArchivoAutos

    sub     rsp, 8
    call    validarRegistro
    add     rsp, 8
    cmp     byte[registroValido], 'N'
    je      proximo

    mov     rcx, 7
    lea     rsi, [patenteAutos]
    lea     rdi, [patenteSeleccionado]
    rep     movsb

    mov     eax, [precioAutos]
    mov     dword[precioSeleccionado], eax

    mov     rdi, registroSeleccion
    mov     rsi, 11
    mov     rdx, 1
    mov     rcx, [idSeleccion]
    sub     rsp, 8
    call    fwrite
    add     rsp, 8

    jmp     leerRegistro

proximo: 

    mov     rdi, msjRegistroInvalido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    jmp     leerRegistro





cerrarArchivoAutos: 

    mov     rdi, [idSeleccion]
    sub     rsp, 8
    call    fclose
    add     rsp, 8

    mov     rdi, [idArchivoAutos]
    sub     rsp, 8
    call    fclose
    add     rsp, 8

; imprimir: 

    ; mov     rdi, formatoAnioValido
    ; mov     rsi, anioNumero
    ; sub     rax, rax
    ; sub     rsp, 8
    ; call    printf
    ; add     rsp, 8

fin: 
    ret


; Validar registro

validarRegistro:

    mov     byte[registroValido], 'N'

    sub     rsp, 8
    call    validarMarca
    add     rsp, 8

    cmp     byte[marcaValida], 'N'
    je      finalValidarRegistro

    sub     rsp, 8
    call    validarAnio
    add     rsp, 8

    cmp     byte[anioValido], 'N'
    je      finalValidarRegistro

    sub     rsp, 8
    call    validarPrecio 
    add     rsp, 8

    cmp     byte[precioValido], 'N'
    je      finalValidarRegistro

    mov     byte[registroValido], 'S'

finalValidarRegistro: 

    mov     rdi, formatoPruebaString
    mov     rsi, marcaAutos
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, msjValidezMarca
    mov     rsi, marcaValida
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, msjValidezAnio
    mov     rsi, anioValido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, msjValidezPrecio
    mov     rsi, precioValido
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    ret





; Validar Marca

validarMarca:

    mov     byte[marcaValida], 'S'
    mov     rbx, 0
    mov     rcx, 4

verificarMarca:
	push	rcx

	mov     rcx,10
	lea		rsi, [marcaAutos]
	lea		rdi, [vecMarcasValidas + rbx]
	repe    cmpsb
	pop		rcx

	je		finalValidarMarca
	add		rbx,10
	loop	verificarMarca
	
	mov     byte[marcaValida],'N'

finalValidarMarca: 
    ret





; Validar Anio

validarAnio: 

    mov     byte[anioValido], 'N'

    mov     rcx, 4
    lea     rsi, [anioFabricacionAutos]
    lea     rdi, [anioString]
    rep     movsb
    
    mov     rdi, anioString
    mov     rsi, formatoAnioValido
    mov     rdx, anioNumero
    sub     rsp, 8
    call    sscanf
    add     rsp, 8

    cmp     rax, 1
    jl      finalValidarAnio

    cmp     word[anioNumero], 2022
    jg      finalValidarAnio

    cmp     word[anioNumero], 2020
    jl      finalValidarAnio

    mov     byte[anioValido], 'S'

finalValidarAnio: 
    ret



; Validar Precio

validarPrecio:

    mov     byte[precioValido], 'N'

    cmp     dword[precioAutos], 5000000
    jg     finalValidarPrecio

    mov     byte[precioValido], 'S'

finalValidarPrecio:
    ret