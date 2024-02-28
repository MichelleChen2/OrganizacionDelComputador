
; Se dispone de una matriz (M) de 50x50 elementos que almacena información sobre agroquímicos a aplicar en un campo. 
; Cada elemento de M ocupa 4 bytes y representa una parcela del campo. 

; El primer entero de 2 bytes corresponde a la cantidad de litros de compuesto fungicida 
; a aplicar en esa parcela y el segundo, la cantidad de litros de compuesto fertilizante.

; Además, se cuenta con un archivo AGRO.DAT que contiene una recomendación del 
; proveedor sobre las cantidades de agroquímicos a aplicar en cada parcela, con registros de 
; ancho fijo de acuerdo al siguiente formato:

; 1 byte en BPF c/s indicando el nro. de fila de la parcela (1 a 50)
; 1 byte en BPF c/s indicando el nro. de columna de la parcela (1 a 50)
; 1 byte en ASCII con los siguientes valores posibles:
; 'U' para fungicida
; 'F' para fertilizante
; 2 bytes en BPF sin signo indicando la cantidad de litros de compuesto a aplicar.


; Se pide codificar un programa en Assembler de Intel 80x86 que permita:
; 1. Recorrer el archivo de recomendaciones y actualizar la matriz sumando al valor 
; preexistente el valor recomendado en cada registro

; 2. Chequear que los registros del archivo contienen valores válidos para el dominio del problema. 
; Esta validación deberá realizarse en una rutina aparte con rótulo VALIDA. Los registros no válidos deberán ser descartados.

; 3. Dado un número de fila que se asume ya cargado en un campo llamado filaInforme, 
; mostrar por pantalla la cantidad total de litros de fungicida recomendada para todas las parcelas de dicha fila 
; y la cantidad de parcelas que no necesitan fertilizante también de dicha fila


global main
extern gets 
extern printf
extern puts
extern sscanf
extern fopen 
extern fread
extern fclose 
extern fwrite 
extern fgets 
extern fputs

section         .data

    matriz                  times 2500      dw          1, 0 ; Asumo valores de la matriz como 1L,0L de c/ compuesto
    longitudFila            dq             200 ; Longitd Fila = Longitud Elemento * Cantidad Columnas = 4 * 50 = 200
    longitudElemento        dq             4   ; Longitud Elemento = 4

    nombreArchivo           db             "AGRO.DAT", 0
    modo                    db             "rb", 0
    handleArchivo           dq             0

    msjErrorApertura        db             "Error Apertura Archivo", 0

    registro               times 0          db          ''
     fila                                   db          0
     columna                                db          0
     compuesto                              db          ' '
     litros                                 dw          0 
     ; Iba usar 'dd' porq si es BPF S/S de 2 bytes puede almacenar hasta 2^16 = 65536 listros 
     ; pero como la matriz solamente acepta 2 bytes como máximo para cada compuesto dejé el 'dw'

    vecCompuestos                           db          "UF", 0

    filaInforme                             dq          1

    cantTotalRecFunguicida                  dq          0
    cantParcelasFertilizanteCero            dq          0
    contadorColumna                         dq          0

    msjTotalFungicidaRec                   db          "La cantidad total de fungicida recomendada es: %li Litros", 10, 0
    msjParcelasSinFertilizante              db          "La cantidad de parcelas que no necesitan fertilizantes son: %li Parcelas", 10, 0

section         .bss 

    exitoApertura           resb            1

    registroValido          resb            1
    filaValida              resb            1
    columnaValida           resb            1
    compuestoValido         resb            1
    litrosValido            resb            1

section         .text
main:

    sub         rsp, 8
    call        abrirArchivo
    add         rsp, 8

    cmp         byte[exitoApertura], 'N'
    je          fin 

leerCadaReg: 

    sub         rsp, 8
    call        leerRegistro
    add         rsp, 8

    cmp         rax, 0
    jle         cerrarAgro

    sub         rsp, 8
    call        VALIDA 
    add         rsp, 8

    cmp         byte[registroValido], 'N'
    je          leerCadaReg

    sub         rsp, 8
    call        actualizarMatriz 
    add         rsp, 8

    jmp         leerCadaReg

cerrarAgro: 

    sub         rsp, 8
    call        cerrarArchivo
    add         rsp, 8

mostrarPantalla: 

    mov         qword[contadorColumna], 0

    sub         rsp, 8
    call        fungicidaRecomendada
    add         rsp, 8

    mov         qword[contadorColumna], 0

    sub         rsp, 8
    call        parcelasSinFertilizante 
    add         rsp, 8

    sub         rsp, 8
    call        imprimirFugicidaRec
    add         rsp, 8

    sub         rsp, 8
    call        imprimirParcelasSinFertilizante
    add         rsp, 8

fin: 
    ret 



; ****************************
;   ABRIR ARCHIVO
; ****************************

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

; ****************************
;  CERRAR ARCHIVO
; ****************************
cerrarArchivo: 

    mov         rdi, [handleArchivo]
    sub         rsp, 8
    call        fclose
    add         rsp, 8

finalCerrarArchivo: 
    ret

; ****************************
;   LEER REGISTRO
; ****************************
leerRegistro: 

    mov         rdi, registro 
    mov         rsi, 5
    mov         rdx, 1
    mov         rcx, [handleArchivo]
    sub         rsp, 8
    call        fread
    add         rsp, 8

finalLeerRegistro: 
    ret 

; ****************************
;   VALIDAR REGISTRO
; ****************************
VALIDA: 

    mov         byte[registroValido], 'N'

    sub         rsp, 8
    call        validarFila
    add         rsp, 8

    cmp         byte[filaValida], 'N'
    je          finalValida

    sub         rsp, 8
    call        validarColumna
    add         rsp, 8

    cmp         byte[columnaValida], 'N'
    je          finalValida

    sub         rsp, 8
    call        validarCompuesto
    add         rsp, 8

    cmp         byte[compuestoValido], 'N'
    je          finalValida

    sub         rsp, 8
    call        validarLitros
    add         rsp, 8

    cmp         byte[litrosValido], 'N'
    je          finalValida

    mov         byte[registroValido], 'S'
finalValida: 
    ret 

; ****************************
;   VALIDAR FILA
; ****************************
validarFila: 

    mov         byte[filaValida], 'N'

    cmp         byte[fila], 1
    jl          finalValidarFila

    cmp         byte[fila], 50
    jg          finalValidarFila

    mov         byte[filaValida], 'S'

finalValidarFila: 
    ret 

; ****************************
;   VALIDAR COLUMNA
; ****************************
validarColumna: 

    mov         byte[columnaValida], 'N'

    cmp         byte[columna], 1
    jl          finalValidarColumna

    cmp         byte[columna], 50
    jg          finalValidarColumna

    mov         byte[columnaValida], 'S'

finalValidarColumna: 
    ret

; ****************************
;   VALIDAR COMPUESTO
; ****************************
validarCompuesto:

    mov         byte[compuestoValido], 'S'

    mov         rcx, 2
    mov         rbx, 0
cadaCompuesto: 
    push        rcx 

    mov         rcx, 1
    lea         rsi, [vecCompuestos + rbx]
    lea         rdi, [compuesto]
    repe        cmpsb
    
    pop         rcx 
    je          finalValidarCompuesto
    inc         rbx 
    loop        cadaCompuesto

    mov         byte[compuestoValido], 'N'
finalValidarCompuesto: 
    ret

; ****************************
;   VALIDAR LITROS
; ****************************
validarLitros:

    mov         byte[litrosValido], 'N'

    cmp         word[litros], 0
    jl          finalValidarLitros

    mov         byte[litrosValido], 'S'

finalValidarLitros: 
    ret 

; ****************************
;   ACTUALIZAR MATRIZ
; ****************************
actualizarMatriz:

; (i-1) * Longitud Fila + (j-1) * Longitud Elemento
; Longitd Fila = Longitud Elemento * Cantidad Columnas = 4 * 50 = 200

    movzx           rdx, byte[fila] 
    ; Uso movzx porque los números deben ser todos positivos y estoy moviendo un dato de tamaño menor a un reg de tamaño mayor
    dec             rdx 
    imul            rdx, qword[longitudFila]

    movzx           rbx, byte[columna]
    dec             rbx 
    imul            rbx, qword[longitudElemento]

    add             rbx, rdx 

    cmp             byte[compuesto], 'U'
    je              actualizarLitros

fertilizante: 
    add             rbx, 2
    ; Si es fertilizante sumo 2 bytes más a rbx para que se desplace hacia los segundos 2 bytes la parcela

actualizarLitros: 

    mov             ax, word[matriz + rbx]
    mov             r8w, [litros]
    add             ax, r8w
    mov             word[matriz + rbx], ax  

finalActualizarMatriz: 
    ret 

; *************************************
;   CALCULAR FUNGICIDA RECOMENDADA 
; *************************************
fungicidaRecomendada:

; (i-1) * Longitud Fila + (j-1) * Longitud Elemento
; Longitd Fila = Longitud Elemento * Cantidad Columnas = 4 * 50 = 200

    mov         rbx, [filaInforme]
    dec         rbx 
    imul        rbx, qword[longitudFila]

    mov         rdx, [contadorColumna]
    imul        rdx, qword[longitudElemento]
    
    add         rbx, rdx 

    movzx         r8, word[matriz + rbx]
    add           qword[cantTotalRecFunguicida], r8

    inc           qword[contadorColumna]
    cmp           qword[contadorColumna], 50
    jne           fungicidaRecomendada

finalFungicidaRecomendada: 
    ret 

; *************************************
;   IMPRIMIR FUNGICIDA RECOMENDADA
; *************************************
imprimirFugicidaRec: 

    mov         rdi, msjTotalFungicidaRec
    mov         rsi, [cantTotalRecFunguicida]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

finalImprimirFungicidaRec: 
    ret 

; *************************************
;   CALCULAR PARCELAS SIN FERTILIZANTE
; *************************************
parcelasSinFertilizante:

    mov         rbx, [filaInforme]
    dec         rbx
    imul        rbx, qword[longitudFila]

    mov         rdx, [contadorColumna]
    imul        rdx, qword[longitudElemento]

    add         rbx, rdx 
    add         rbx, 2 ; Desplazo hacia el segundo 2 bytes de la parcela

    cmp         word[matriz + rbx], 0 ; Si la cant de fertilizante no es 0 desplazo hacia la sig columna
    jne         proxColumna

sumatoriaFertilizanteCero: 

    inc         qword[cantParcelasFertilizanteCero]

proxColumna: 

    inc         qword[contadorColumna]
    cmp         qword[contadorColumna], 50
    jne         parcelasSinFertilizante

finalParcelasSinFertilizante: 
    ret 

; *************************************
;   IMPRIMIR PARCELAS SIN FERTILIZANTE
; *************************************
imprimirParcelasSinFertilizante:

    mov         rdi, msjParcelasSinFertilizante
    mov         rsi, [cantParcelasFertilizanteCero]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

finalImprimirParcelasSinFertilizante: 
    ret 