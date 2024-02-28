; Se cuenta con un archivo en formato binario llamado ENCUESTA.DAT que contiene
; información de las respuestas de una encuesta. La encuesta consultaba a que
; candidato votaría (de una lista de 4 opciones) y se realizó en 10 ciudades.
; Cada registro del archivo representa una respuesta y contiene la siguiente
; información:

;     - Código de candidato: 2 bytes en formato ASCII (AF, MM, RL, SM)
;     - Código de ciudad: 1 bytes en formato binario punto fijo sin signo

; Se pide realizar un programa en assembler Intel x86 que lea el archivo y por cada
; registro llene una matriz (M) de 4x10 donde cada fila representa a un candidato y
; cada columna una ciudad. Cada elemento de la matriz M representa la sumatoria
; de respuestas para cada candidato en cada ciudad; para el llenado de M se hará
; uso de una rutina interna VALREG q validará los datos de cada registro descartando
; los incorrectos.

; Por último el programa debe pedir ingresar un código de candidato e informar por
; pantalla en que ciudad tiene menos intención de votos teniendo en cuenta que
; habrá un vector en memoria de longitud 10, cuyos elementos tienen 20 bytes de
; longitud con los nombres de las ciudades.

global main
extern printf
extern sscanf
extern fopen
extern fclose
extern fread
extern puts
extern gets 

section         .data

    matrizM                  times 40               dq              0
    longitudFila                dq                  80   ; longitudFila = longitudElemento * cantColumnas = 8 * 10 = 80
    longitudElemento            dq                  8

    contadorColumna             dq                  0

    nombreArchivo               db                  "ENCUESTA.dat", 0
    modo                        db                  "rb", 0
    handleArchivo               dq                  0

    msjErrorApertura            db                  "Error apertura ENCUESTA.DAT", 0

    registro                    times 0             db              ''
     candidato                  times 2             db              ' '
     ciudad                                         db              0

    vecCandidato                db                  "AFMMRLSM", 0

    vecCiudades                 db                  "Buenos Aires        "
                                db                  "La Plata            "
                                db                  "Tigre               "
                                db                  "Hurlingham          "
                                db                  "Vicente López       "
                                db                  "Lomas de Zamora     "
                                db                  "Pilar               "
                                db                  "Tres de Febrero     "
                                db                  "Quilmes             "
                                db                  "San Isidro          ", 0

    ciudadMenosVoto             dq                  0
    minVotos                    dq                  0

    msjInputCandidato           db                  "Ingrese el código de candidato: ", 0
    msjInputInvalido            db                  "Candidato Inválido. Intente Nuevamente.", 0
    msjMenosVoto                db                  "La ciudad con menos votos es: %s ", 10, 0

    resultadoCiudad             db                  "********************", 0

    ; ERROR DATO
    msjErrorCandidato           db                  "Candidato Inválido", 0
    msjErrorCiudad              db                  "Ciudad Inválida", 0
    msjPrueba                   db                  "LLEGUÉ", 0
    msjFormatoNum               db                  "%hhi", 10, 0
    msjFormatoStr               db                  "%s", 10, 0

section         .bss

    exitoApertura               resb                1

    registroValido              resb                1
    candidatoValido             resb                1
    ciudadValida                resb                1

    candidatoNum                resq                1

    inputCandidato              resb                100

section         .text
main: 

    sub         rsp, 8
    call        abrirArchivo
    add         rsp, 8

    cmp         byte[exitoApertura], 'N'
    je          fin

leerCadaRegistro: 

    sub         rsp, 8
    call        leerRegistro
    add         rsp, 8

    cmp         rax, 0
    jle         cerrarArchivoEncuesta

    mov         qword[candidatoNum], 1

    sub         rsp, 8
    call        VALREG
    add         rsp, 8

    cmp         byte[registroValido], 'N'
    je          leerCadaRegistro

    sub         rsp, 8
    call        actualizarMatriz
    add         rsp, 8

    jmp           leerCadaRegistro


cerrarArchivoEncuesta: 

    sub         rsp, 8
    call        cerrarArchivo
    add         rsp, 8

    
pedirUsuario: 

    sub         rsp, 8
    call        pedirCandidato
    add         rsp, 8

    mov         qword[candidatoNum], 1

    sub         rsp, 8
    call        validarCandidato
    add         rsp, 8

    cmp         byte[candidatoValido], 'N'
    je          inputInvalido

    mov         qword[contadorColumna], 0

    sub         rsp, 8
    call        buscarCiudadMenosVotos
    add         rsp, 8

    sub         rsp, 8
    call        imprimirCiduad
    add         rsp, 8

    jmp         fin

inputInvalido:

    mov         rdi, msjInputInvalido
    sub         rsp, 8
    call        puts
    add         rsp, 8

    jmp         pedirUsuario

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
    jle         errorAperturaArchivo

    mov         qword[handleArchivo], rax
    mov         byte[exitoApertura], 'S'
    jmp         finalAbrirArchivo
    
errorAperturaArchivo:

    mov         rdi, msjErrorApertura
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalAbrirArchivo:
    ret 

; *************************
;      CERRAR ARCHIVO
; *************************
cerrarArchivo:

    mov         rdi, [handleArchivo]
    sub         rsp, 8
    call        fclose
    add         rsp, 8

finalCerrarArchivo:
    ret 

; *************************
;     LEER REGISTRO
; *************************
leerRegistro:

    mov         rdi, registro 
    mov         rsi, 3
    mov         rdx, 1
    mov         rcx, [handleArchivo]
    sub         rsp, 8
    call        fread 
    add         rsp, 8

finalLeerRegistro:
    ret 

; *************************
;    VALIDAR REGISTRO
; *************************
VALREG:

    mov         byte[registroValido], 'N'

    sub         rsp, 8
    call        validarCandidato
    add         rsp, 8

    cmp         byte[candidatoValido], 'N'
    je          finalValidarRegistro

    sub         rsp, 8
    call        validarCiudad
    add         rsp, 8

    cmp         byte[ciudadValida], 'N'
    je          finalValidarRegistro

    mov         byte[registroValido], 'S' 

finalValidarRegistro: 
    ret 

; *************************
;    VALIDAR CANDIDATO
; *************************
validarCandidato:

    mov         byte[candidatoValido], 'S'

    mov         rcx, 4
    mov         rbx, 0

compararCodCandidato: 

    push        rcx

    mov         rcx, 2
    lea         rsi, [vecCandidato + rbx]
    lea         rdi, [candidato]
    repe        cmpsb 
    
    pop         rcx 
    je          finalValidarCandidato 
    add         rbx, 2
    inc         qword[candidatoNum]
    loop        compararCodCandidato

    mov         byte[candidatoValido], 'N'

errorCandidato: 

    mov         rdi, msjErrorCandidato
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarCandidato:
    ret 
; *************************
;    VALIDAR CIUDAD
; *************************
validarCiudad:

    mov         byte[ciudadValida], 'N'

    ; mov         rdi, msjPrueba
    ; sub         rsp, 8
    ; call        puts
    ; add         rsp, 8

    ; mov         rdi, msjFormatoNum
    ; mov         rsi, [ciudad]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    cmp         byte[ciudad], 1
    jl          errorCiudad

    cmp         byte[ciudad], 10
    jg          errorCiudad

    mov         byte[ciudadValida], 'S' 
    jmp         finalValidarCiudad

errorCiudad: 

    mov         rdi, msjErrorCiudad
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarCiudad: 
    ret 

; *************************
;    ACTUALIZAR MATRIZ
; *************************
actualizarMatriz:

    ; (i-1) * Longitud Fila + (j-1) * Longitud Elemento
    ; Longitd Fila = Longitud Elemento * Cantidad Columna = 8 * 10 = 80

    mov         rdx, [candidatoNum]
    dec         rdx 
    imul        rdx, qword[longitudFila]

    movzx         rbx, byte[ciudad]
    dec           rbx 
    imul          rbx, qword[longitudElemento]

    add           rbx, rdx 

    inc           qword[matrizM + rbx]

finalActualizarMatriz: 
    ret 

; *************************
;    PEDIR CANDIDATO
; *************************
pedirCandidato:

    mov         rdi, msjInputCandidato
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    mov         rdi, inputCandidato
    sub         rsp, 8
    call        gets
    add         rsp, 8

    mov         rcx, 2
    lea         rsi, [inputCandidato]
    lea         rdi, [candidato]
    rep         movsb

finalPedirCandidato: 
    ret 

; *****************************
;   BUSCAR CIUDAD MENOS VOTO
; *****************************
buscarCiudadMenosVotos:

    mov         rbx, [candidatoNum]
    dec         rbx 
    imul        rbx, qword[longitudFila]

    mov         rdx, [contadorColumna]
    imul        rdx, qword[longitudElemento]

    add         rbx, rdx

    mov         rax, qword[minVotos]
    cmp         qword[matrizM + rbx], rax 
    jg          proxCiudad

    mov         r8, qword[contadorColumna]
    inc         r8
    mov         qword[ciudadMenosVoto], r8

    mov         r9, qword[matrizM + rbx]
    mov         qword[minVotos], r9

proxCiudad:     

    inc         qword[contadorColumna]
    cmp         qword[contadorColumna], 10
    jne         buscarCiudadMenosVotos

finalBuscarCiudadMenosVotos: 
    ret 

; *******************************
;   IMPRIMIR CIUDAD MENOS VOTOS
; *******************************

imprimirCiduad:

    mov         rbx, qword[ciudadMenosVoto]
    dec         rbx
    imul        rbx, 20

    mov         rcx, 20
    lea         rsi, [vecCiudades + rbx]
    lea         rdi, [resultadoCiudad]
    rep         movsb 

    ; mov         rdi, msjFormatoNum
    ; mov         rsi, [ciudadMenosVoto]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    mov         rdi, msjMenosVoto
    mov         rsi, resultadoCiudad
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8  

finalImprimirCiudad: 
    ret 