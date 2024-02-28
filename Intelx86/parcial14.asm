
; Se cuenta con un archivo en formato binario llamado ENCUESTA2.DAT que contiene
; información de las respuestas de una encuesta que consultaba a empleados de 10
; compañías cuál es el recurso más importante que el empleador debía pagar para
; facilitar el trabajo remoto y daba para elegir 4 opciones (Internet, Computadora, Silla,
; Luz). Cada registro del archivo representa la respuesta de un empleado y contiene la
; siguiente información:
;         - Código de recurso: 2 bytes en formato ASCII (IN, CO, SI, LU)
;         - Código de compañía: 1 byte en formato binario punto fijo sin signo (1 a 10)
; Se pide realizar un programa en assembler Intel que:

; 1. Lea el archivo y por cada registro llene una matriz (M) de 4x10 donde cada fila
;    representa a un recurso y cada columna una compañía.  Cada elemento de M es
;    un binario de punto fijo sin signo de 2 bytes y representa la sumatoria de
;    respuestas para cada recurso en cada compañía; 

; 2. Validar los datos del registro mediante una rutina interna (VALREG) para que
;    puedan ser descartados los inválidos.

; 3. Padrón PAR: ingresar por teclado un código de recurso e informar por pantalla la
;    compañía que más lo eligió y que % representa del total. 

;    Padrón IMPAR: ingresar por teclado un código de compañía e informar por pantalla el recurso
;    con mayor cantidad de votos y que % representa del total.

global main
extern sscanf
extern printf
extern fopen
extern fclose
extern fread
extern puts
extern gets

section         .data

    matrizEncuesta         times 40       dw        0
    longitudFila            dq          20
    longitudElemento        dq          2
    cantColumnas            dq          10
    cantFilas               dq          4

    contadorColumna         dq          0
    contadorFila            dq          0

    msjFormatoNum           db             "| %hi |", 0
    msjFormatoString        db             "| %s |", 0

    saltoLinea              db             "", 0

    msjErrorApertura        db           "Error apertura del archivo ...", 0
    msjRegistroInvalido     db           "Registro inválido ...", 0

    msjInputRecurso         db            "Ingrese el código de un recurso (IN/CO/SI/LU): ", 0
    msjDatoInvalido         db            "Dato inválido. Ingrese nuevamente!", 0
    msjCompania             db            "El código de la compañía que más lo eligió es: %hhi", 10, 0

    msjInputCompania        db            "Ingrese el código de la compañía: ", 0
    msjRecurso              db            "El código del recurso más votado es: %hhi", 10,0

    formatoCompania         db             "%hhi", 0

    nombreArchivo           db            "archivoBinario.DAT", 0
    modo                    db            "rb", 0
    handleArchivo           dq             0

    vectorRecursos         db               "INCOSILU", 0

    pruebaRecurso            db             "%s", 0
    pruebaRegistro           db              "%hhi", 10, 0
    pruebaLlegar             db             "LLEGUÉ", 0

    recursoNum               db             0

    maxElegido              dw              0
    maxElegidoComp          dq              1

    maxVotos              dw              0
    maxRecurso            dq              1
    codMaxRecurso         db              "**", 0

section         .bss

    registroValido          resb          1
    recursoValido           resb          1
    companiaValida          resb          1

    registro                times 0        resb     3
    recurso                                resb     2
    compania                               resb     1

    inputRecurso            resb           100
    inputCompania           resb           100


section         .text
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

    mov         byte[recursoNum], 1

    sub         rsp, 8
    call        VALREG
    add         rsp, 8

    cmp         byte[registroValido], 'N'
    je          registroInvalido

    sub         rsp, 8
    call        cargaMatriz
    add         rsp, 8

    mov         qword[contadorColumna], 0
    mov         qword[contadorFila], 0

    sub         rsp, 8
    call        imprimirMatriz
    add         rsp, 8

    jmp         leerRegistro

registroInvalido:

    mov         rdi, msjRegistroInvalido
    sub         rsp, 8
    call        puts
    add         rsp, 8

    jmp         leerRegistro

cerrarArchivo:

    mov         rdi, [handleArchivo]
    sub         rsp, 8
    call        fclose
    add         rsp, 8

pedirRecurso: 

    mov         rdi, msjInputRecurso
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    mov         rdi, inputRecurso
    sub         rsp, 8
    call        gets
    add         rsp, 8

    mov         rcx, 2
    lea         rsi, [inputRecurso]
    lea         rdi, [recurso]
    rep         movsb

    sub         rsp, 8
    call        validarRecurso
    add         rsp, 8

    cmp         byte[recursoValido], 'N'
    je          datoInvalido 

    mov         qword[contadorColumna], 0
    mov         qword[contadorFila], 0

    sub         rsp, 8
    call        companiaQueMasEligio
    add         rsp, 8

    sub         rsp, 8
    call        imprimirCompania
    add         rsp, 8

pedirCompania: 

    mov         rdi, msjInputCompania
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    mov         rdi, inputCompania
    sub         rsp, 8
    call        gets
    add         rsp, 8

    sub         rsp, 8
    call        companiaANum
    add         rsp, 8

    sub         rsp, 8
    call        validarCompania
    add         rsp, 8

    ; prueba
    mov         rdi, pruebaRecurso
    mov         rsi, companiaValida
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    cmp         byte[companiaValida], 'N'
    je          datoInvalido

    mov         qword[contadorColumna], 0
    mov         qword[contadorFila], 0

    sub         rsp, 8
    call        recursoMasVotado
    add         rsp, 8

    sub         rsp, 8
    call        imprimirRecursoMasVotado
    add         rsp, 8

    jmp         fin

datoInvalido: 

    mov         rdi, msjDatoInvalido
    sub         rsp, 8
    call        puts
    add         rsp, 8

    jmp         pedirRecurso

errorAperturaArchivo:

    mov         rdi, msjErrorApertura
    sub         rsp, 8
    call        puts
    add         rsp, 8

fin:
    ret




imprimirRecursoMasVotado:


    mov         rdi, msjRecurso
    mov         rsi, [maxRecurso]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

finalImprimirRecursoMasVotado: 
    ret







recursoMasVotado:

    mov         rax, 0
    mov         rax, qword[contadorFila]
    imul        rax, 20

    mov         rbx, 0
    movzx       rbx, byte[compania]
    dec         rbx
    imul        rbx, 2

    add         rbx, rax

    mov         dx, word[matrizEncuesta + rbx]
    cmp         word[maxVotos], dx
    jl          masVotos

    jmp         proximo

masVotos: 

    mov         word[maxVotos], dx
    mov         rcx, qword[contadorFila]
    inc         rcx
    mov         qword[maxRecurso], rcx

proximo:  

    inc         qword[contadorFila]
    cmp         qword[contadorFila], 4
    jne         recursoMasVotado

finalRecursoMasVotado: 
    ret



companiaANum:

    mov         rdi, inputCompania
    mov         rsi, formatoCompania
    mov         rdx, compania
    sub         rax, rax
    sub         rsp, 8
    call        sscanf
    add         rsp, 8

    ; prueba
    mov         rdi, pruebaRegistro
    mov         rsi, [compania]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

finalCompaniaANum:
    ret


imprimirCompania:

    mov         rdi, msjCompania
    mov         rsi, [maxElegidoComp]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8


finalImprimirCompania: 
    ret

companiaQueMasEligio:

    mov         rax, 0
    movzx       rax, byte[recursoNum]
    dec         rax
    imul        rax, 20

    mov         rbx, 0
    mov         rbx, [contadorColumna]
    imul        rbx, 2

    add         rbx, rax

    mov         dx, word[matrizEncuesta + rbx]
    cmp         word[maxElegido], dx
    jl          mayor

    jmp         prox

mayor: 

    mov         word[maxElegido], dx
    mov         rcx, qword[contadorColumna]
    inc         rcx
    mov         qword[maxElegidoComp], rcx

    mov         rdi, pruebaRegistro
    mov         rsi, [maxElegidoComp]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

prox: 

    inc     qword[contadorColumna]
    cmp     qword[contadorColumna], 10
    jne     companiaQueMasEligio

finalCompaniaQueMasEligio: 
    ret

;  VALREG

VALREG:

    mov         byte[registroValido], 'N'

    sub         rsp, 8
    call        validarRecurso
    add         rsp, 8

    cmp         byte[recursoValido], 'N'
    je          finalValreg

    sub         rsp, 8
    call        validarCompania
    add         rsp, 8

    cmp         byte[companiaValida], 'N'
    je          finalValreg

    mov         byte[registroValido], 'S'
finalValreg:
    ret

; VALIDAR RECURSO
validarRecurso:

    mov         byte[recursoValido], 'S'

    mov         byte[recursoNum], 1
    mov         rbx, 0
validarCadaRecurso:

    mov         rcx, 2
    lea         rsi, [vectorRecursos + rbx]
    lea         rdi, [recurso]
    repe        cmpsb

    je          finalValidarRecurso
    inc         byte[recursoNum]
    add         rbx, 2
    cmp         rbx, 8
    jne         validarCadaRecurso

    mov         byte[recursoValido], 'N'
    jmp         finalValidarRecurso

finalValidarRecurso:

    ret

; VALIDAR COMPAÑIA
validarCompania:

    mov         byte[companiaValida], 'N'

    cmp         byte[compania], 0
    jle         finalValidarCompania

    cmp         byte[compania], 10
    jg          finalValidarCompania


    mov         byte[companiaValida], 'S'


finalValidarCompania:
    ret


;  CARGAR DATOS REGISTRO  EN LA MATRIZ
cargaMatriz:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento * cantidadColumnas = 2 * 10 = 20

    ; mov         ax, [recursoNum]
    ; dec         ax
    ; imul        ax, 20

    ; mov         rdi, pruebaRegistro
    ; mov         rsi, [recursoNum]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8


    mov         r8, 0
    movzx       r8, byte[recursoNum]
    dec         r8
    imul        r8, 20

    mov         rbx, 0
    movzx        rbx, byte[compania]
    dec         rbx
    imul        rbx, 2

    ; mov         rdi, pruebaRegistro
    ; mov         rsi, r8
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    add         rbx, r8

    ; add         word[matrizEncuesta + rbx], 1

    add         word[matrizEncuesta + rbx], 1

    mov         rdi, pruebaRegistro
    mov         rsi, rbx
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    ; mov         rdi, pruebaRegistro
    ; mov         rsi, [recursoNum]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    ; mov         rdi, pruebaRegistro
    ; mov         rsi, [compania]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

finalCargaMatriz:
    ret


imprimirMatriz:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento * cantidadColumnas = 2 * 10 = 20

columna:
    mov        rax, [contadorFila]
    imul       rax, qword[longitudFila]

    mov        rbx, [contadorColumna]
    imul       rbx, qword[longitudElemento]

    add        rax, rbx

    mov        rdi, msjFormatoNum
    mov        rsi, [matrizEncuesta + rax]
    sub        rax, rax
    sub        rsp, 8
    call       printf
    add        rsp, 8

    add       qword[contadorColumna], 1
    mov       rdx, qword[contadorColumna]
    cmp       rdx, qword[cantColumnas]
    je        proxFila
    jmp       columna

proxFila:

    mov     rdi, saltoLinea
    sub     rsp, 8
    call    puts
    add     rsp, 8

    mov      qword[contadorColumna], 0
    add      qword[contadorFila], 1
    mov      rdx, qword[contadorFila]
    cmp      rdx, qword[cantFilas]
    je       finalImprimirMatriz
    jmp      columna

finalImprimirMatriz:
    ret


    ; mov         rdi, pruebaRecurso
    ; mov         rsi, recurso
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8


    ; mov         rdi, compania
    ; mov         rsi, formatoCompania
    ; mov         rdx, companiaNum
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        sscanf
    ; add         rsp, 8

    ; mov         rdi, pruebaRegistro
    ; mov         rsi, [companiaNum]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8


    ; mov         rdi, pruebaRegistro
    ; mov         rsi, [compania]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    ; mov         rdi, pruebaLlegar
    ; sub         rsp, 8
    ; call        puts
    ; add         rsp, 8