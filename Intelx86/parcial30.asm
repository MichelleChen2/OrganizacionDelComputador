; Se dispone de una matriz de 30x10 que representa un tablero de Tetris (30 de alto y 10
; de largo).Cada elemento de la matriz indica si ese punto del tablero está ocupado o no
; siendo  '*' (asterisco) ocupado y '' (espacio en blanco) en caso contrario.
; Para cargar el tablero se hará uso de un archivo (FICHAS.DAT) que contiene el
; posicionamiento inicial de las fichas. Solo hay fichas de tipo '|' (dimensión 4x1) y cada
; registro del archivo tiene los siguientes campos:

;       ●  Fila: CL2 (Indica la fila de la posición inicial de la ficha - 1..30)
;       ●  Columna: BL1 (Indica la columna de la posición inicial de la ficha - 1..10)
;       ●  Sentido: CL1 (Indica el sentido hacia donde continúan el resto de las posiciones que
;                   ocupa la ficha en el tablero   A - Arriba; B - Abajo; D - Derecha; I - Izquierda)

; Se pide realizar un programa en assembler Intel 8086 que realice la carga del tablero
; (se asume que las fichas no solapan). Como la información del archivo puede ser
; incorrecta se deberá validar haciendo uso de una rutina interna (VALFICHA) para
; descartar los inválidos. La rutina deberá validar todos los campos del registro (tipo de
; datos, valores y que la ficha quepa en el tablero)  

; Se pide
; 1. Carga del tablero
; 2. Codificación de rutina interna VALFICHA
; 3. Para aquellos alumnos con padrón PAR se deben imprimir los nros de filas
; donde todos los elementos tienen * mientras que los alumnos con padrón IMPAR
; los nros de columnas donde todos tiene *.

global main
extern printf
extern scanf
extern sscanf
extern fopen
extern fclose
extern fread

section     .data

    matrizTetris            times 300       db          ' '

    msjErrorApertura            db              "Error en la apertura del archivo", 0

    msjFilas                    db              "Filas con '*' son: ", 10, 0
    formatoFilas                db              "| %hhi |", 0

    nombreArchivo               db              "FICHAS.DAT", 0
    modo                        db              "rb", 0
    handleArchivo               dq              0

    registro                    times 0         db        ""
    fila                        times 1         db         0
    columna                     times 1         db         0
    sentido                     times 1         db         ' '

    vecSentidos                 db              "ABDI", 0
    asterisco                   db              '*'

    vectorFilas                 times 30        db          0
    contadorColumna             dq              0
    contadorFila                dq              0
    contadorVecFila             dq              1

section     .bss

    fichaValida            resb             1
    filaValida             resb             1
    columnaValida          resb             1
    sentidoValido          resb             1

    comienzo                resq             1
    filaIngresada           resq             1

section     .text
main:

    mov         rdi, nombreArchivo
    mov         rsi, modo
    sub         rsp, 8
    call        fopen
    add         rsp, 8

    cmp         rax, 0
    jle         errorAperturaArchivo

    mov         qword[handleArchivo], rax

leerRegistro:

    mov         rdi, registro
    mov         rsi, 3
    mov         rdx, 1
    mov         rcx, [handleArchivo]
    sub         rsp, 8
    call        fread
    add         rsp, 8

    cmp         rax, 0
    jle         cerrarArchivo

    sub         rsp, 8
    call        VALFICHA
    add         rsp, 8

    cmp         byte[fichaValida], 'N'
    je          cerrarArchivo

    sub         rsp, 8
    call        ingresarFicha
    add         rsp, 8

    jmp         leerRegistro

cerrarArchivo:

    mov         rdi, [handleArchivo]
    sub         rsp, 8
    call        fclose
    add         rsp, 8

    sub         rsp, 8
    call        filasLlenas
    add         rsp, 8

    sub         rsp, 8
    call        imprimirFilas
    add         rsp, 8


errorAperturaArchivo:

    mov         rdi, msjErrorApertura
    sub         rsp, 8
    call        puts
    add         rsp, 8

fin:
    ret



VALFICHA:

    mov         byte[fichaValida], 'N'

    sub         rsp, 8
    call        validarFila
    add         rsp, 8

    cmp         byte[filaValida], 'S'
    jne         finalValFicha

    sub         rsp, 8
    call        validarColumna
    add         rsp, 8

    cmp         byte[columnaValida], 'S'
    jne         finalValFicha

    sub         rsp, 8
    call        validarSentido
    add         rsp, 8

    cmp         byte[sentidoValido], 'S'
    jne         finalValFicha

    mov         byte[fichaValida], 'S'

finalValFicha:
    ret


validarFila:

    mov         byte[filaValida], 'N'

    cmp         byte[fila], 0
    jle         finalValidarFila

    cmp         byte[fila], 30
    jg          finalValidarFila

    mov         byte[filaValida], 'S'

finalValidarFila:
    ret


validarColumna:

    mov         byte[columnaValida], 'N'

    cmp         byte[columna], 0
    jle         finalValidarColumna

    cmp         byte[columna], 10
    jg          finalValidarColumna

    mov         byte[columnaValida], 'S'

finalValidarColumna:
    ret



validarSentido:

    mov         byte[validarSentido], 'S'

    mov         rcx, 4
    mov         rbx, 0

compararSentido:

    push        rcx

    mov         rcx, 1
    lea         rsi, [vecSentidos + rbx]
    lea         rdi, [sentido]
    rep         cmpsb

    je          finalValidarSentido
    pop         rcx
    inc         rbx
    loop        compararSentido

    mov         byte[validarSentido], 'N'

finalValidarSentido:
    ret



; *************************
;   INGRESAR FICHA
; *************************
ingresarFicha:

    ; (i-1) * longitudFila + (j-1) * longitudElemento

    ; longitdFila = longitudElemento * cantidadColumnas = 1 * 10 = 10 

    mov     rax, [fila]
    dec     rax
    imul    rax, 10

    mov     rdx, [columna]
    dec     rdx

    add     rax, rdx
    mov     qword[comienzo], rax

    cmp     byte[sentido], 'A'
    je      arriba

    cmp     byte[sentido], 'B'
    je      abajo

    cmp     byte[sentido], 'D'
    je      derecha

izquierda: 

    mov     rcx, 4
    mov     rbx, qword[comienzo]

llenarIzquierda:
    push    rcx

    mov     rcx, 1
    lea     rsi, [asterisco]
    lea     rdi, [matrizTetris + rbx]
    repe    movsb

    pop     rcx
    dec     rbx
    loop    llenarIzquierda

    jmp     finalIngresarFicha

derecha: 

    mov     rcx, 4
    mov     rbx, qword[comienzo]

llenarDerecha:
    push    rcx

    mov     rcx, 1
    lea     rsi, [asterisco]
    lea     rdi, [matrizTetris + rbx]
    repe    movsb

    pop     rcx
    inc     rbx
    loop    llenarDerecha

    jmp     finalIngresarFicha

abajo: 

    mov     rbx, qword[comienzo]
    mov     rcx, 4

llenarAbajo:
    push    rcx

    mov     rcx, 1
    lea     rsi, [asterisco]
    lea     rdi, [matrizTetris + rbx]
    repe    movsb

    pop     rcx
    add     rbx, 10
    loop    llenarAbajo

    jmp     finalIngresarFicha

arriba: 

    mov     rbx, qword[comienzo]
    mov     rcx, 4

llenarArriba:
    push    rcx

    mov     rcx, 1
    lea     rsi, [asterisco]
    lea     rdi, [matrizTetris + rbx]
    repe    movsb

    pop     rcx
    sub     rbx, 10
    loop    llenarAbajo

finalIngresarFicha:
    ret


filasLlenas:

    ; (i-1) * longitudFila + (j-1) * longitudElemento

    ; longitdFila = longitudElemento * cantidadColumnas = 1 * 10 = 10 

    mov     rax, [contadorFila]
    imul    rax, 10
    
    add     rax, qword[contadorColumna]


    mov     rcx, 1
    lea     rsi, [asterisco]
    lea     rdi, [matrizTetris + rax]
    repe    cmpsb

    jne     proxFila

    inc     qword[contadorColumna]
    cmp     qword[contadorColumna], 10
    je      filaLlena

filaLlena:

    mov     rdx, [contadorVecFila]
    mov     byte[vectorFilas], rdx

proxFila: 
    inc     qword[contadorFila]
    mov     qword[contadorColumna], 0
    inc     qword[contadorVecFila]

    cmp     qword[contadorFila], 30
    je      finalFilasLlenas

    jmp     filasLlenas

finalFilasLlenas:
    ret



imprimirFilas: 

    mov     rdi, msjFilas
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    mov     rbx, 0

correrVectorFilas:

    mov     rdi, formatoFilas
    mov     rsi, [vectorFilas + rbx]
    sub     rax, rax
    sub     rsp, 8
    call    printf
    add     rsp, 8

    inc     rbx
    cmp     rbx, 10
    je      finalImprimirFilas

    jmp     correrVectorFilas


finalImprimirFilas: 
    ret

