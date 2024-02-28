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
;   Precio que cumpla la condición pedida

; Rutina que valida y aplica el filtro 
   

global main
extern fopen
extern fclose
extern printf
extern fread
extern fwrite
extern puts
extern gets
extern sscanf

section         .data

    nombreArchivoListado    db              "listado.dat", 0
    modoListado             db              "rb", 0 ; read | binario | abrir o error
    handleArchivoListado    dq               0

    msjErrorAperturaListado        db              "Error de apertura del archivo Listado.dat", 0

    registroListado                times 0           db        ''
      marcaListado                 times 10        db          ' '
      anioListado                  times 4         db          ' ' ; No tiene el 0 binario para el string que lo necesita el sscanf
      patenteListado               times 7         db          ' '
      precioListado                times 4         db          0

    vecMarcas                      db               "Fiat      Ford      Chevrolet Peugeot   ", 0
    formatoAnio                    db               "%hi", 0

    nombreArchivoSeleccionados          db          "seleccionados.dat", 0
    modoSeleccionados                   db          "wb", 0 ; write binary
    handleArchivoSeleccionados          dq          0

    msjErrorAperturaSeleccionados       db          "Error apertura del archivo Seleccionados.dat", 0
    msjErrorMarca                       db          "Marca Inválida", 0
    msjErrorAnio                        db          "Año Inválido", 0
    msjErrorPrecio                      db          "Precio Inválido", 0

    registroSeleccionados           times 0         db          ''
        patenteSeleccionados                        db          "********", 0
        precioSeleccionados                         dd           0

    anioConCero                         db          "****", 0

    msjPrueba                           db          "LLEGÚE", 0
    formatoPruebaString                 db          "%s", 10, 0
    formatoPruebaNum                    db          "%i", 10, 0

section         .bss

    exitoAperturaListado           resb            1
    exitoAperturaSeleccionados     resb            1

    registroListadoValido          resb            1
    marcaValida                    resb            1
    anioValido                     resb            1
    precioValido                   resb            1

    anioNumero                     resw            1

section          .text
main: 

    ; mov         rdi, msjPrueba
    ; sub         rsp, 8
    ; call        puts
    ; add         rsp, 8

    sub         rsp, 8
    call        abrirArchivoListado
    add         rsp, 8

    sub         rsp, 8
    call        abrirArchivoSeleccionados
    add         rsp, 8

    cmp         byte[exitoAperturaListado], 'N'
    je          fin 

    cmp         byte[exitoAperturaSeleccionados], 'N'
    je          cerrarListado

leerRegistroListado: 

    sub         rsp, 8
    call        leerRegistro 
    add         rsp, 8

    cmp         rax, 0
    jle         cerrarArchivos

    sub         rsp, 8
    call        VALREG
    add         rsp, 8

    cmp         byte[registroListadoValido], 'N'
    je          leerRegistroListado

    sub         rsp, 8
    call        construirRegSeleccionados
    add         rsp, 8

    sub         rsp, 8
    call        escribirRegSeleccionados
    add         rsp, 8

    jmp         leerRegistroListado

cerrarArchivos: 

    sub         rsp, 8
    call        cerrarArchivoSeleccionados
    add         rsp, 8

cerrarListado: 

    sub         rsp, 8
    call        cerrarArchivoListado
    add         rsp, 8

fin: 
    ret


; ********************************
;   APERTURA DE ARCHIVO LISTADO
; ********************************
abrirArchivoListado:

    mov         byte[exitoAperturaListado], 'N'

    mov         rdi, nombreArchivoListado
    mov         rsi, modoListado
    sub         rsp, 8
    call        fopen
    add         rsp, 8

    cmp         rax, 0
    jle         errorAperturaListado

    mov         [handleArchivoListado], rax
    mov         byte[exitoAperturaListado], 'S'
    jmp         finalAbrirArchivoListado

errorAperturaListado:
    
    mov         rdi, msjErrorAperturaListado
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalAbrirArchivoListado: 
    ret

; **************************************
;   APERTURA DE ARCHIVO SELECCIONADOS
; **************************************

abrirArchivoSeleccionados:

    mov         byte[exitoAperturaSeleccionados], 'N'

    mov         rdi, nombreArchivoSeleccionados
    mov         rsi, modoSeleccionados
    sub         rsp, 8
    call        fopen
    add         rsp, 8

    cmp         rax, 0
    jle         errorAperturaSeleccionados

    mov         qword[handleArchivoSeleccionados], rax
    mov         byte[exitoAperturaSeleccionados], 'S'
    jmp         finalAbrirArchivoSeleccionados

errorAperturaSeleccionados:
    
    mov         rdi, msjErrorAperturaSeleccionados
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalAbrirArchivoSeleccionados: 
    ret




; *******************************
;      CERRAR ARCHIVO LISTADO
; *******************************
cerrarArchivoListado:

    mov       rdi, [handleArchivoListado]
    sub       rsp, 8
    call      fclose
    add       rsp, 8

finalCerrarArchivoListado: 
    ret


; *************************************
;      CERRAR ARCHIVO SELECCIONADOS
; *************************************

cerrarArchivoSeleccionados:

    mov       rdi, [handleArchivoSeleccionados]
    sub       rsp, 8
    call      fclose
    add       rsp, 8

finalCerrarArchivoSeleccionados: 
    ret

; *************************
;    LEER REGISTRO 
; ************************* 
leerRegistro: 

    mov         rdi, registroListado
    mov         rsi, 25
    mov         rdx, 1
    mov         rcx, [handleArchivoListado]
    sub         rsp, 8
    call        fread
    add         rsp, 8

finalLeerRegistro: 
    ret


; *************************
;       VALREG
; ************************* 
VALREG: 

    mov         byte[registroListadoValido], 'N'

    sub         rsp, 8
    call        validarMarca
    add         rsp, 8

    cmp         byte[marcaValida], 'N' 
    je          finalValidarRegistro 

    sub         rsp, 8
    call        validarAnio
    add         rsp, 8

    cmp         byte[anioValido], 'N'
    je          finalValidarRegistro

    sub         rsp, 8
    call        validarPrecio
    add         rsp, 8

    cmp         byte[precioValido], 'N'
    je          finalValidarRegistro

    mov         byte[registroListadoValido], 'S'
finalValidarRegistro: 
    ret

; *************************
;    VALIDAR MARCA
; ************************* 
validarMarca: 

    mov         byte[marcaValida], 'N'

    mov         rcx, 4
    mov         rbx, 0

validarCadaMarca: 
    push        rcx

    mov         rcx, 10
    lea         rsi, [vecMarcas + rbx]
    lea         rdi, [marcaListado]
    repe        cmpsb   

    pop         rcx
    je         marcaEncontrada
    add         rbx, 10
    loop        validarCadaMarca
    ; loop hace rcx - 1 y compara para ver si es 0. Si es 0 sale 

errorMarca: 

    ; mov         rdi, formatoPruebaString
    ; mov         rsi, marcaListado
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    mov         rdi, msjErrorMarca
    sub         rsp, 8
    call        puts
    add         rsp, 8
    jmp         finalValidarMarca

marcaEncontrada: 

    mov         byte[marcaValida], 'S'
    jmp         finalValidarMarca


finalValidarMarca: 
    ret


; ***************************** 
;    VALIDAR AÑO FABRICACIÓN
; ***************************** 
validarAnio:

    mov         byte[anioValido], 'N'

    mov         rcx, 4
    lea         rsi, [anioListado] ; = mov rsi, anioListado porq no hay desplazamiento
    lea         rdi, [anioConCero]
    rep         movsb   



    mov         rdi, anioConCero
    mov         rsi, formatoAnio
    mov         rdx, anioNumero
    sub         rax, rax
    sub         rsp, 8
    call        sscanf
    add         rsp, 8

    cmp         rax, 0
    jle         errorAnio

    ; mov         rdi, formatoPruebaNum
    ; mov         rsi, [anioNumero]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8


    cmp         word[anioNumero], 2020
    jl          errorAnio

    cmp         word[anioNumero], 2022
    jg          errorAnio

    mov         byte[anioValido], 'S'

    jmp         finalValidarAnio

errorAnio: 

    mov         rdi, msjErrorAnio
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarAnio: 
    ret


; ***************************** 
;    VALIDAR PRECIO
; ***************************** 
validarPrecio:

    mov         byte[precioValido], 'N'

    cmp         dword[precioListado], 0
    jl          errorPrecio

    cmp         dword[precioListado], 5000000
    jg          errorPrecio

    mov         byte[precioValido], 'S'
    jmp         finalValidarPrecio

errorPrecio: 
    mov         rdi, msjErrorPrecio
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarPrecio: 
    ret


; ************************************
;   CONSTRUIR REGISTRO SELECCIONADO
; ************************************
construirRegSeleccionados:

    mov      rcx, 7
    lea      rsi, [patenteListado]
    lea      rdi, [patenteSeleccionados]
    rep      movsb 

    mov     edx, dword[precioListado]
    mov     dword[precioSeleccionados], edx

    ; mov         rdi, formatoPruebaNum
    ; mov         rsi, [precioSeleccionados]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

finalConstruirRegSeleccionados: 
    ret

; ************************************
;   ESCRIBIR REGISTRO SELECCIONADO
; ************************************
escribirRegSeleccionados:

    mov         rdi, registroSeleccionados
    mov         rsi, 12
    mov         rdx, 1
    mov         rcx, [handleArchivoSeleccionados]
    sub         rsp, 8
    call        fwrite
    add         rsp, 8

finalEscribirRegSeleccionados: 
    ret