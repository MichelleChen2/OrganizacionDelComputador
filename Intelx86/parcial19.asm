; Se cuenta con una matriz (M) de 20x20 cuyos elementos son BPFC/S de 16 bits y
; un archivo (carbina.dat) cuyos registros están conformados por los siguientes
; campos:
        ; • Cadena de 16 bytes de caracteres ASCII que representa un BPFc/s de 16 bits
        ; • BPF s/s de 8 bits que indica el número de fila de M
        ; • BPF s/s de 8 bits que indica el número de columna de M
; Se pide codificar un programa que lea los registros del archivo y complete la matriz
; con dicha información. Como el contenido de los registros puede ser inválido
; deberá hacer uso de una rutina interna (VALREG) para validarlos (los registros
; inválidos serán descartados y se procederá a leer el siguiente). Luego realizar la
; sumatoria de la diagonal secundaria e imprimir el resultado por pantalla.
; Nota: Se deberá inicializar M con ceros por si no se lograra completar todos los
; elementos con la información provista en el archivo.

global main
extern printf
extern puts
extern fopen
extern fread
extern fclose
extern sscanf

section             .data 

    matriz         times 400           dw          0

    longitdFila                 dq              40
    longitudElemento            dq              2

    nombreArchivo               db              "carbina.dat", 0
    modo                        db              "rb", 0
    handleArchivo               dq              0

    msjErrorApertura            db              "Error de apertura del archivo", 0

    msjSumDiagSecundaria        db              "El resultado de la sumatoria de la diagonal secundaria es: %i", 10, 0

    registro         times 0        db          ''
     valor           times 16       db          ' '
     fila                           db          0
     columna                        db          0

     valorStr                      db              "****************", 0

    formatoValor                   db           "%hi", 0

    contadorFila                   dq           0
    contadorColumna                dq           19
    sumatoria                      dq           0

    msjErrorValor                  db           "Valor Inválido", 0
    msjErrorFila                   db           "Fila Invlálida", 0
    msjErrorColumna                db           "Columna Inválida", 0

section             .bss

    valorNum                    resb            1

    exitoApertura               resb            1

    registroValido              resb            1
    valorValido                 resb            1
    filaValida                  resb            1
    columnaValida               resb            1

section             .text
main: 

    sub         rsp, 8
    call        abrirArchivo
    add         rsp, 8

    cmp         byte[exitoApertura], 'N'
    je          fin 

leerRegistros:

    sub         rsp, 8
    call        leerCadaRegistro
    add         rsp, 8 

    cmp         rax, 0
    jle         cerrarArch 

    sub         rsp, 8
    call        VALREG
    add         rsp, 8

    cmp         byte[registroValido], 'N'
    je          leerRegistros

    sub         rsp, 8
    call        actualizarMatriz 
    add         rsp, 8

cerrarArch:

    sub         rsp, 8
    call        cerrarArchivo
    add         rsp, 8

diagSecundaria: 

    sub         rsp, 8
    call        calcularDiagSecundaria
    add         rsp, 8

    sub         rsp, 8
    call        imprimirSumatoria
    add         rsp, 8

fin: 
    ret 

; *************************
;      ABRIR ARCHIVO   
; *************************
abrirArchivo: 

    mov         byte[exitoApertura], 'N'

    mov         rdi, nombreArchivo
    mov         rsi, modo
    sub         rsp, 8
    call        fopen
    add         rsp, 8

    cmp         rax, 0
    jle         errorApertura

    mov         qword[handleArchivo], rax

    mov         byte[exitoApertura], 'S'
    jmp         finalAbrirArchivo

errorApertura: 

    mov         rdi, msjErrorApertura
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalAbrirArchivo: 
    ret 

; *************************
;      LEER     REGISTRO  
; *************************
leerCadaRegistro:

    mov         rdi, registro
    mov         rsi, 18
    mov         rdx, 1
    mov         rcx, [handleArchivo]
    sub         rsp, 8
    call        fread
    add         rsp, 8

finalLeerCadaRegistro: 
    ret 

; *************************
;    CERRAR ARCHIVO
; *************************
cerrarArchivo:

    mov         rdi, [handleArchivo]
    sub         rsp, 8
    call        fclose
    add         rsp, 8

finalCerrarArchivo:
    ret

; *************************
;    VALIDAR REGISTRO
; *************************
VALREG: 

    mov         byte[registroValido], 'N'

    sub         rsp, 8
    call        validarValor
    add         rsp, 8

    cmp         byte[valorValido], 'N'
    je          finalValreg

    sub         rsp, 8
    call        validarFila
    add         rsp, 8

    cmp         byte[filaValida], 'N'
    je          finalValreg

    sub         rsp, 8
    call        validarColumna
    add         rsp, 8

    cmp         byte[columnaValida], 'N'
    je          finalValreg

    mov         byte[registroValido], 'S'

finalValreg: 
    ret 

; *************************
;    VALIDAR VALOR
; *************************
validarValor:

    mov         byte[valorValido], 'N'

    mov         rcx, 16
    lea         rsi, [valor]
    lea         rdi, [valorStr]
    rep         movsb 

    mov         rdi, valorStr
    mov         rsi, formatoValor
    mov         rdx, valorNum
    sub         rax, rax
    sub         rsp, 8
    call        sscanf
    add         rsp, 8

    cmp         rax, 0
    jle         errorValor

    mov         byte[valorValido], 'S'
    jmp         finalValidarValor

errorValor: 

    mov         rdi, msjErrorValor
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarValor:
    ret 

; *************************
;    VALIDAR FILA   
; *************************
validarFila:

    mov         byte[filaValida], 'N'

    cmp         byte[fila], 1
    jl          errorFila 

    cmp         byte[fila], 20
    jg          errorFila

    mov         byte[filaValida], 'S'

errorFila: 

    mov         rdi, msjErrorFila
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarFila: 
    ret 

; *************************
;    VALIDAR COLUMNA   
; *************************
validarColumna: 

    mov         byte[columnaValida], 'N'

    cmp         byte[columna], 1
    jl          errorColumna 

    cmp         byte[columna], 20
    jl          errorColumna 

    mov         byte[columnaValida], 'S'
    jmp         finalValidarColumna

errorColumna: 

    mov         rdi, msjErrorColumna
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarColumna:
    ret 

; *************************
;   ACTUALIZAR MATRIZ
; *************************
actualizarMatriz: 

    ; (i-1)*longitudFila + (j-1)*longitudElemento
    ; longitdFila= longitudElemento*cantidadColumnas

    movzx       rdx, byte[fila]
    dec         rdx 
    imul        rdx, qword[longitdFila]

    movzx       rbx, byte[columna]
    dec         rbx 
    imul        rbx, qword[longitudElemento]

    add         rbx, rdx 

    movsx       ax, byte[valor]
    mov         word[matriz + rbx], ax 

finalActualizarMatriz: 
    ret 

; ********************************
;   CALCULAR DIAGONAL SECUNDARIA
; ********************************
calcularDiagSecundaria:

    mov         rdx, qword[contadorFila]
    imul        rdx, qword[longitdFila]

    mov         rbx, qword[contadorColumna]
    imul        rbx, qword[longitudElemento]

    add         rbx, rdx 

    movsx       r8, word[matriz + rbx]
    add         qword[sumatoria], r8 

    inc         qword[contadorFila]

    cmp         qword[contadorFila], 20
    je          finalCalcularDiagSecundaria

    dec         qword[contadorColumna]
    jmp         calcularDiagSecundaria

finalCalcularDiagSecundaria: 
    ret 

; ********************************
;   IMPRIMIR SUMATORIA
; ********************************
imprimirSumatoria: 

    mov         rdi, msjSumDiagSecundaria
    mov         rsi, [sumatoria]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

finalImprimirSum: 
    ret 