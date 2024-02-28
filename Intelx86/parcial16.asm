; Examen Parcial - 1da Oportunidad - 16/6/2020

; Se dispone de una matriz de 12x12 que representa un edificio nuevo a estrenar, donde
; tiene 12 pisos con 12 departamentos en cada uno. Cada elemento de la matriz es un
; binario de 4 bytes, donde guarda el precio de venta en U$S de cada departamento. Se
; dispone de un archivo (PRECIOS.DAT) que contiene los precios de los departamentos,
; donde cada registro del archivo contiene los siguientes campos: 

;                Piso: Carácter de 2 bytes 
;                Departamento:  Binario de 1 byte  
;                Precio venta: Binario de 4 bytes

; Se pide realizar un programa en assembler Intel 80x86 que realice la carga de la matriz
; a través del archivo. Como la información del archivo puede ser incorrecta se deberá
; validar haciendo uso de una rutina interna (VALREG) que descartará los registros
; inválidos (la rutina deberá validar todos los campos del registro).
; Una vez finalizada la carga, se solicitará ingresar por teclado numero (x) y un precio de
; venta (no se requieren validar) y se deberá mostrar todos los departamentos/pisos cuyo
; precio de venta sea menor al ingresado.
; Para alumnos con padrón par, x será un numero de piso y se deberá mostrar por
; pantalla todos los nros de departamento cuyo precio sea inferior al ingresado en el piso
; ingresado.
; Para alumnos con padrón impar, x será un numero de departamento y se deberá
; mostrar por pantalla todos los nros de piso donde el departamento ingresado tenga
; precio inferior al ingresado.

global  main
extern  printf
extern  puts
extern  scanf
extern  sscanf
extern  fopen
extern  fclose
extern  fread


section     .data 

    matrizEdificio          times 144       dd      0

    msjIngresarPiso         db         "Ingrese el número de piso (1-12): ", 0
    msjIngresarPrecio       db          "Ingrese el precio máximo: ", 0
    msjDepartamentos        db          " Departamento N° %hhi |", 0

    formatoIngPiso          db          "%hhi", 0
    formatoIngPrecio        db          "%i", 0

    msjErrorAbrirArchivo    db         "Error apertura de archivo. ", 0

    nombreArchPrecios       db         "PRECIOS.DAT", 0
    modo                    db          "rb", 0
    handleArchivo           dq          0

    registro               times 0      db     ""
    piso                   times 2      db     " "
    departamento           times 1      db     0
    precioVenta            times 1      dd     0

    pisoNum                 db          0
    pisoNumImp              db          0
    formatoPisoNum          db          "%hi", 0

    departamentoUsuario     db          0

    vectorPisos             db          "010203040506070809101112", 0

section     .bss

    registroValido          resb        1

    pisoValido              resb        1
    departamentoValido      resb        1
    precioVentaValido       resb        1

    pisoUsuario             resb        1
    precioMax               resd        1

section     .text
main: 

    mov     rdi, nombreArchPrecios
    mov     rsi, modo
    sub     rsp, 8
    call    fopen
    add     rsp, 8

    cmp     rax, 0
    jle     errorAbrirArchivo

    mov     qword[handleArchivo], rax


leerRegistro: 

    mov     rdi, registro
    mov     rsi, 7
    mov     rdx, 1
    mov     rcx, [handleArchivo]
    sub     rsp, 8
    call    fread
    add     rsp, 8

    cmp     rax, 0
    jle     cerrarArchivo

    sub     rsp, 8
    call    VALREG
    add     rsp, 8

    cmp     byte[registroValido], 'N'
    je      leerRegistro

    sub     rsp, 8
    call    actualizarMatriz
    add     rsp, 8

    jmp     leerRegistro

ingresoUsuario: 

    mov     rdi, msjIngresarPiso
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, formatoIngPiso
    mov     rsi, pisoUsuario
    sub     rsp, 8
    call    scanf
    add     rsp, 8

    cmp     rax, 0
    jle     ingresoUsuario

    mov     rdi, msjIngresarPrecio
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rdi, formatoIngPrecio
    mov     rsi, precioMax
    sub     rsp, 8
    call    scanf
    add     rsp, 8

    cmp     rax, 0
    jle     ingresoUsuario

    sub     rsp, 8
    call    buscarDepartamento
    add     rsp, 8

    jmp     ingresoUsuario

errorAbrirArchivo:

    mov     rdi, msjErrorAbrirArchivo
    sub     rsp, 8
    call    puts
    add     rsp, 8

cerrarArchivo: 

    mov     rdi, [handleArchivo]
    sub     rsp, 8
    call    fclose
    add     rsp, 8

fin:
    ret

; **********************
;       VALREG
; **********************

VALREG: 

    mov     byte[registroValido], 'N'

    ; Validar Piso
    sub     rsp, 8
    call    validarPiso
    add     rsp, 8

    cmp     byte[pisoValido], 'N'
    je      finalValreg

    ; Validar Departamento
    sub     rsp, 8
    call    validarDepartamento
    add     rsp, 8

    cmp     byte[departamentoValido], 'N'
    je      finalValreg

    ; Validar Precio de Venta
    sub     rsp, 8
    call    validarPrecioVenta
    add     rsp, 8

    cmp     byte[precioVentaValido], 'N'
    je      finalValreg

    mov     byte[registroValido], 'S'

finalValreg:
    ret


; VALIDAR PISO 

validarPiso:

    mov     byte[pisoValido], 'S'

    mov     rbx, 0
    mov     rcx, 12

compararPiso: 
    push    rcx

    mov     rcx, 2
    lea     rsi, [vectorPisos + rbx]
    lea     rdi, [piso]
    repe    cmpsb

    je      pasarFormatoNumeroPiso
    pop     rcx
    add     rbx, 2
    loop    compararPiso

    mov     byte[pisoValido], 'N'
    jmp     finalValidarPiso

pasarFormatoNumeroPiso: 

    mov     rdi, piso
    mov     rsi, formatoPisoNum
    mov     rdx, pisoNum
    sub     rsp, 8
    call    sscanf
    add     rsp, 8

    cmp     rax, 1
    jge     finalValidarPiso

    mov     byte[pisoValido], 'N'

finalValidarPiso:
    ret


; VALIDAR DEPARTAMENTO

validarDepartamento:

    mov     byte[departamentoValido], 'N'

    cmp     byte[departamento], 1
    jl      finalValidarDepartamento

    cmp     byte[departamento], 12
    jg      finalValidarDepartamento

    mov     byte[departamentoValido], 'S'
finalValidarDepartamento: 
    ret

; VALIDAR PRECIO   

validarPrecioVenta:

    mov      byte[precioVentaValido], 'N'

    cmp     dword[precioVenta], 0
    jle     finalValidarPrecioVenta

    mov     byte[precioVentaValido], 'S'
finalValidarPrecioVenta: 
    ret


; *************************
;      Actualizar Matriz
; *************************

actualizarMatriz:

    ; (i-1)*longitudFila + (j-1)*longitudElemento
    ; longitdFila = longitudElemento * cantidadColumnas = 4 * 12 = 48

    mov     al, byte[pisoNum]
    dec     al
    imul    al, 48

    mov     bl, byte[departamento]
    dec     bl
    imul    bl, 4

    add     al, bl
    cbw
    cwde
    cdqe

    mov     ebx, dword[precioVenta]
    mov     dword[matrizEdificio + rax], ebx

finalActualizarMatriz:
    ret


; **********************************
;    BUSCAR DEPARTAMENTO POR PISO
; **********************************

buscarDepartamento:

    ; (i-1)*longitudFila + (j-1)*longitudElemento
    ; longitdFila = longitudElemento * cantidadColumnas = 4 * 12 = 48

recorrerDepartamento:
    mov     al, byte[pisoUsuario]
    dec     al
    imul    al, 48
    cbw
    cwde
    cdqe   

    mov     rcx, 12
    mov     rbx, 0
 
    imul    rbx, 4
    add     rax, rbx

    mov     edx, dword[precioMax]
    cmp     dword[matrizEdificio + rax], edx
    jl      proximo

    mov     qword[departamentoNum], rbx
    inc     qword[departamentoNum]

    sub     rsp, 8
    call    imprimirDepart
    add     rsp, 8

proximo:

    inc     rbx
    dec     rcx
    cmp     rcx, 0
    jne     recorrerDepartamento

finalBuscarDepartamento: 
    ret


imprimirDepart:

    mov     rdi, msjDepartamentos
    mov     rsi, [departamentoNum]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

finalImprimirDepart:
    ret


; **********************************
;    BUSCAR PISO POR DEPARTAMENTO
; **********************************

buscarPiso:

    ; (i-1)*longitudFila + (j-1)*longitudElemento
    ; longitdFila = longitudElemento * cantidadColumnas = 4 * 12 = 48

    mov     rbx, 0
    mov     rcx, 12
recorrerPiso: 
    mov     al, byte[departamentoUsuario]
    dec     al
    imul    al, 4
    cbw
    cwde
    cdqe   

    imul    rbx, 48
    add     rax, rbx

    mov     edx, dword[precioMax]
    cmp     dword[matrizEdificio + rax], edx
    jl      proximo

    mov     byte[pisoNumImp], rbx
    inc     byte[pisoNumImp]  

    sub     rsp, 8
    call    imprimirPiso
    add     rsp, 8  

proximo:

    inc     rbx
    dec     rcx
    cmp     rcx, 0
    jne     recorrerPiso

finalBuscarPiso: 
    ret


imprimirPiso:

    mov     rdi, msjDepartamentos
    mov     rsi, [departamentoNum]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8


finalImprimirPiso: 
    ret