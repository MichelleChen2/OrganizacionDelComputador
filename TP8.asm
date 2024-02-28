; Bolsas de Correo (II)

; Se tienen n objetos de pesos P1, P2, ..., Pn (con n <= 20) que deben ser enviados por correo a una
; misma dirección. La forma más simple sería ponerlos todos en un mismo paquete; sin embargo, el
; correo no acepta que los paquetes tengan más de 15 Kg. y la suma de los pesos podría ser mayor
; que eso. Afortunadamente, cada uno de los objetos no pesa más de 15 Kg.

; Se trata entonces de pensar un algoritmo que de un método para armar los paquetes, tratando de
; optimizar su cantidad. Debe escribir un programa en assembler Intel 80x86 que:

;       ● Permita la entrada de un entero positivo n.
;       ● La entrada de los n pesos, verificando que 0<Pi<=15 donde i <=n.
;       ● Los Pi pueden ser valores enteros.
;       ● Exhiba en pantalla la forma en que los objetos deben ser dispuestos en los paquetes.

; A su vez existen tres destinos posibles: Posadas, Salta y Tierra del Fuego. El correo por normas
; internas de funcionamiento no puede poner en el mismo paquete objetos que vayan a distinto destino.
; Desarrollar un algoritmo que proporcione una forma de acomodar los paquetes de forma que no haya
; objetos de distinto destino en un mismo paquete y cumpliendo las restricciones de peso. Se sugiere
; tener una salida como la siguiente:


;       • Destinoi – Objeto1 (P1) + Objeto2 (P2)+ ..... + Objeton (Pn)
;       • Destinoi – Objeto1 (P1) + Objeto2 (P2)+ ..... + Objeton (Pn)
;       • Destinoi – Objeto1 (P1) + Objeto2 (P2)+ ..... + Objeton (Pn)

; nasm tp8nuevo.asm -f elf64
; gcc tp8nuevo.o -o tp8nuevo.out -no-pie
; ./tp8nuevo.out

global main
extern printf
extern sscanf
extern gets
extern puts
extern getchar

section             .data

    vecInputPosadas             times 20        db      0
    ; vecInputPosadas                               db      5,5,1,14,5,12,2,3,13,8,4,7,10,1,15,6,5,4,5,5

    contadorNumObjPosadas        dq            1
    contadorNumPaqPosadas        dq            1         

    vecInputSalta               times 20        db      0

    contadorNumObjSalta          dq            1
    contadorNumPaqSalta          dq            1      

    vecInputTFuego              times 20        db      0

    contadorNumObjTFuego         dq            1
    contadorNumPaqTFuego         dq            1      

    matriz                      times 336       db      0
    contadorMatrizFila            dq            1
    contadorMatrizColumna         dq            1
    pesoActualVec                 db            0
    valorActualVec                db            0
    valorSinCambio                db            0
    valorConCambio                db            0

    vecPaquete                  times 20        db      0
    contadorVecPaq                dq            0

    valorActualMatirz             db            0
    valorSiHayAgregar             db            0
    valorAgrego                   db            0

    vecValores                  times  20       db      0
    contadorVecValores            dq            0

    longitudVector                dq             20

    contadorObjPosadas            dq              0
    ; contadorObjPosadas            dq              20

    contadorObjSalta              dq              0
    contadorObjTFuego             dq              0

    contadorPosicion              dq              0
    posicionVacia                 dq              0

    msjInputPeso                db              "Ingrese el peso del objeto (0 kg < peso <= 15 kg) * 0 para empaquetar: ", 0
    msjInputDestino             db              "Ingrese el destino del objeto (P: Posadas / S: Salta / T: Tierra del Fuego): ", 0
    msjTagObjetosPosadas        db              "Objetos a POSADAS: ", 0
    msjTagObjetosSalta          db              "Objetos a SALTA: ", 0
    msjTagObjetosTFuego         db              "Objetos a TIERRA DEL FUEGO: ", 0

    pesoStr                     db              "**", 0
    formatoPeso                 db              "%hhi", 0

    vecDestinos                 db              "PpSsTt", 0

    msjErrorPeso                db              "Peso Inválido", 0
    msjErrorDestino             db              "Destino Inválido", 0
    msjSaltoLinea               db              "", 0

    msjformatoCadaObj           db              "| %hhi |", 0

    msjPaqPosadas                           db                  "       Paquetes con destino a POSADAS: ", 10, 0
    msjPaqSalta                             db                  "       Paquetes con destino a SALTA: ", 10, 0
    msjPaqTFuego                            db                  "       Paquetes con destino a TIERRA DEL FUEGO: ", 10, 0

    msjPosadasLlena                         db                  "¡¡¡ Ya hay 20 objetos para enviar a POSADAS !!!", 10, 0
    msjSaltaLlena                           db                  "¡¡¡ Ya hay 20 objetos para enviar a SALTA !!!", 10, 0
    msjTFuegoLlena                          db                  "¡¡¡ Ya hay 20 objetos para enviar a TIERRA DEL FUEGO !!!", 10, 0

    msjPosadasPaquete                       db                  "       Posadas %hhi: ", 0
    msjSaltaPaquete                         db                  "       Salta %hhi: ", 0
    msjTFuegoPaquete                        db                  "       Tierra del Fuego %hhi: ", 0
    msjPaquete                              db                  " | Objeto N° %hhi (%hhi kg) | ", 0

    msjEntrada                              db                  "                           ********************************************", 10
                                            db                  "                           *  BIENVENIDOS al EMPAQUETADOR a DESTINOS  *", 10
                                            db                  "                           *          - Posadas                       *", 10
                                            db                  "                           *          - Salta                         *", 10
                                            db                  "                           *          - Tierra del Fuego              *", 10
                                            db                  "                           ********************************************", 10, 0
    

    msjInstrucciones                        db                  "               Instrucciones de Uso: ", 10
                                            db                  "                   1. Para cada destino puede ingresar como máximo 20 paquetes.", 10
                                            db                  "                   2. Cada paquete puede pasar entre 0 y 15 kg inclusive", 10
                                            db                  "                   3. Una vez terminado el ingreso, presio 0 para en el ingreso de peso para empezar el empaquetado", 10
                                            db                  "                   4. Los respectivos símbolos para los destinos son: ", 10
                                            db                  "                               - P / p: Posadas",10
                                            db                  "                               - S / s: Salta",10
                                            db                  "                               - T / t: Tierra del Fuego", 10
                                            db                  "                   5. Se mostrará el peso de cada objeto que usted haya ingresado para cada destino", 10, 0

    ; PRUEBA
    formatoNum                  db              "%hhi", 10, 0
    formatoNumM                  db              "MATRIZ: %hhi", 10, 0
    formatoStr                  db              "%s", 10, 0
    msjVecValor                 db              "Vector de Valor: ", 0
    msjVecPaq                   db              "Vector de Paquete: ", 0
    contadorPruebaFil           dq               0
    contadorPruebaCol           dq               0

section             .bss

    inputBuffer         resb         100

    pesoInput           resb         1
    destinoInput        resb         1
    terminarIngreso     resb         1

    pesoValido          resb         1
    destinoValido       resb         1

    contadorFilEmpaquetar       resq            1
    contadorColEmpaquetar       resq            1


section             .text
main:

    mov             rdi, msjEntrada
    sub             rsp, 8
    call            puts
    add             rsp, 8

    mov             rdi, msjInstrucciones
    sub             rsp, 8
    call            puts
    add             rsp, 8

pedirInput:

    sub             rsp, 8
    call            pedirInputUsuario
    add             rsp, 8

    cmp             byte[terminarIngreso], 'S'
    je              empaquetarObjetos

actualizarVectorObjetos:

    sub         rsp, 8
    call        cargarObjeto
    add         rsp, 8

    sub         rsp, 8
    call        mostrarObjetos
    add         rsp, 8

    jmp         pedirInput

empaquetarObjetos:

empaquetarObjetosPosadas: 

    cmp         byte[vecInputPosadas], 0        
    je          empaquetarObjetosSalta

    mov         rdi, msjPaqPosadas
    sub         rsp, 8
    call        puts 
    add         rsp, 8

empaquetarCadaPaqPosadas: 

    sub         rsp, 8
    call        cargarValorPosadas
    add         rsp, 8


    ; ************** PRUEBA *****************
    ; sub         rsp, 8
    ; call        imprimirVecValores
    ; add         rsp, 8
    ; ***************************************

    mov         qword[contadorMatrizFila], 1
    mov         qword[contadorMatrizColumna], 1
    mov         qword[contadorVecPaq], 0
    mov         qword[posicionVacia], 0

    sub         rsp, 8
    call        actualizarMatrizPosadas
    add         rsp, 8

    sub         rsp, 8
    call        empaquetarPosadas
    add         rsp, 8

    sub         rsp, 8
    call        juntarVectorPesoPosadas
    add         rsp, 8

    mov         rdi, msjPosadasPaquete
    mov         rsi, [contadorNumPaqPosadas]
    sub         rax, rax 
    sub         rsp, 8
    call        printf 
    add         rsp, 8

    sub         rsp, 8
    call        imprimirPaquetePosadas
    add         rsp, 8

    inc         qword[contadorNumPaqPosadas]

                ;   PRUEBA
    ; sub         rsp, 8
    ; call        imprimirMatriz
    ; add         rsp, 8

    ; sub         rsp, 8
    ; call        imprimirVecPaquete
    ; add         rsp, 8

    ; sub         rsp, 8
    ; call        mostrarObjetos
    ; add         rsp, 8

    ; sub         rsp, 8
    ; call        imprimirVecValores
    ; add         rsp, 8
    ; ***********

    sub         rsp, 8
    call        vaciarVecValores
    add         rsp, 8

    sub         rsp, 8
    call        vaciarMatriz
    add         rsp, 8

    ; mov        rdi, formatoNumM
    ; mov        rsi, [contadorObjPosadas]
    ; sub        rax, rax
    ; sub        rsp, 8
    ; call       printf
    ; add        rsp, 8



    cmp         byte[contadorObjPosadas], 0
    jg          empaquetarCadaPaqPosadas

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

empaquetarObjetosSalta: 

    cmp         byte[vecInputSalta], 0
    je          empaquetarObjetosTFuego

    mov         rdi, msjPaqSalta
    sub         rsp, 8
    call        puts 
    add         rsp, 8

empaquetarCadaPaqSalta: 

    sub         rsp, 8
    call        cargarValorSalta
    add         rsp, 8

    mov         qword[contadorMatrizFila], 1
    mov         qword[contadorMatrizColumna], 1
    mov         qword[contadorVecPaq], 0
    mov         qword[posicionVacia], 0

    sub         rsp, 8
    call        actualizarMatrizSalta
    add         rsp, 8

    sub         rsp, 8
    call        empaquetarSalta
    add         rsp, 8

    sub         rsp, 8
    call        juntarVectorPesoSalta
    add         rsp, 8

    mov         rdi, msjSaltaPaquete
    mov         rsi, [contadorNumPaqSalta]
    sub         rax, rax 
    sub         rsp, 8
    call        printf 
    add         rsp, 8

    sub         rsp, 8
    call        imprimirPaqueteSalta
    add         rsp, 8

    inc         qword[contadorNumPaqSalta]

    sub         rsp, 8
    call        vaciarVecValores
    add         rsp, 8

    sub         rsp, 8
    call        vaciarMatriz
    add         rsp, 8

    ; PRUEBA
    ; sub         rsp, 8
    ; call        imprimirMatriz
    ; add         rsp, 8

    ; sub         rsp, 8
    ; call        imprimirVecPaquete
    ; add         rsp, 8

    ; sub         rsp, 8
    ; call        mostrarObjetos
    ; add         rsp, 8

    ; sub         rsp, 8
    ; call        imprimirVecValores
    ; add         rsp, 8
    ; ***********************

    cmp         byte[contadorObjSalta], 0
    jg          empaquetarCadaPaqSalta

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

empaquetarObjetosTFuego: 

    cmp         byte[vecInputTFuego], 0
    je          fin

    mov         rdi, msjPaqTFuego
    sub         rsp, 8
    call        puts 
    add         rsp, 8

empaquetarCadaPaqTFuego: 

    sub         rsp, 8
    call        cargarValorTFuego
    add         rsp, 8

    mov         qword[contadorMatrizFila], 1
    mov         qword[contadorMatrizColumna], 1
    mov         qword[contadorVecPaq], 0
    mov         qword[posicionVacia], 0

    sub         rsp, 8
    call        actualizarMatrizTFuego
    add         rsp, 8

    sub         rsp, 8
    call        empaquetarTFuego
    add         rsp, 8

    sub         rsp, 8
    call        juntarVectorPesoTFuego
    add         rsp, 8

    mov         rdi, msjTFuegoPaquete
    mov         rsi, [contadorNumPaqTFuego]
    sub         rax, rax 
    sub         rsp, 8
    call        printf 
    add         rsp, 8

    sub         rsp, 8
    call        imprimirPaqueteTFuego
    add         rsp, 8

    inc         qword[contadorNumPaqTFuego]

    sub         rsp, 8
    call        vaciarVecValores
    add         rsp, 8

    sub         rsp, 8
    call        vaciarMatriz
    add         rsp, 8

    cmp         byte[contadorObjTFuego], 0
    jg          empaquetarCadaPaqTFuego

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

fin:
    ret

; ****************************
;   PEDIR INPUT USUARIO
; ****************************
pedirInputUsuario:

pedirPeso:

    mov         rdi, msjInputPeso
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    mov         rdi, inputBuffer
    sub         rsp, 8
    call        gets
    add         rsp, 8

    sub         rsp, 8
    call        validarPeso
    add         rsp, 8

    cmp         byte[terminarIngreso], 'S'
    je          finalPedirInputUsuario

    cmp         byte[pesoValido], 'N'
    je          pedirPeso

pedirDestino:

    mov         rdi, msjInputDestino
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    mov         rdi, inputBuffer
    sub         rsp, 8
    call        gets
    add         rsp, 8

    sub         rsp, 8
    call        validarDestino
    add         rsp, 8

    cmp         byte[destinoValido], 'N'
    je          pedirDestino

finalPedirInputUsuario:
    ret

; ****************************
;        VALIDAR PESO
; ****************************
validarPeso:

    mov        byte[pesoValido], 'N'
    mov        byte[terminarIngreso], 'S'

    mov        bx, word[inputBuffer] 
    mov        word[pesoStr], bx

    mov        rdi, pesoStr
    mov        rsi, formatoPeso
    mov        rdx, pesoInput
    sub        rax, rax
    sub        rsp, 8
    call       sscanf
    add        rsp, 8

    cmp        rax, 0
    jle        errorPeso

    ; mov        rdi, formatoNum
    ; mov        rsi, [pesoStr]
    ; sub        rax, rax
    ; sub        rsp, 8
    ; call       printf 
    ; add        rsp, 8

    ; mov        rdi, formatoNum
    ; mov        rsi, [pesoInput]
    ; sub        rax, rax
    ; sub        rsp, 8
    ; call       printf
    ; add        rsp, 8

    cmp         byte[pesoInput], 0
    je          finalValidarPeso

    cmp        byte[pesoInput], 0
    jl         errorPeso

    cmp        byte[pesoInput], 15
    jg         errorPeso

    mov         byte[pesoValido], 'S'
    mov         byte[terminarIngreso], 'N'
    jmp          finalValidarPeso

errorPeso:

    mov         byte[terminarIngreso], 'N'

    mov         rdi, msjErrorPeso
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarPeso:
    ret

; ****************************
;       VALIDAR DESTINO
; ****************************
validarDestino:

    mov         byte[destinoValido], 'S'

    mov         al, byte[inputBuffer]
    mov         byte[destinoInput], al

        ; PRUEBA
    ; mov        rdi, formatoStr
    ; mov        rsi, destinoInput
    ; sub        rax, rax
    ; sub        rsp, 8
    ; call       printf
    ; add        rsp, 8

    cmp         byte[destinoInput], 'P'
    je          finalValidarDestino

    cmp         byte[destinoInput], 'p'
    je          cmbDestinoPosadas

    cmp         byte[destinoInput], 'S'
    je          finalValidarDestino

    cmp         byte[destinoInput], 's'
    je          cmbDestinoSalta

    cmp         byte[destinoInput], 'T'
    je          finalValidarDestino

    cmp         byte[destinoInput], 't'
    je          cmbDestinoTFuego

    mov         byte[destinoValido], 'N'
    jmp         errorDestino

cmbDestinoPosadas:

    mov         byte[destinoInput], 'P'
    jmp         finalValidarDestino

cmbDestinoSalta:

    mov         byte[destinoInput], 'S'
    jmp         finalValidarDestino

cmbDestinoTFuego:

    mov         byte[destinoInput], 'T'
    jmp         finalValidarDestino

errorDestino:

    mov         rdi, msjErrorDestino
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarDestino:
    ret

; ****************************
;   CARGAR OBJETO AL VECTOR
; ****************************
cargarObjeto:

    cmp         byte[destinoInput], 'P'
    je          cargarVectorPosadas

    cmp         byte[destinoInput], 'S'
    je          cargarVectorSalta

    cmp         byte[destinoInput], 'T'
    je          cargarVectorTFuego

    jmp         finalCargarObjeto

cargarVectorPosadas:

    cmp         qword[contadorObjPosadas], 20
    je          vectorPosadasLlena

    sub         rsp, 8
    call        cargarVecPosadas
    add         rsp, 8

    jmp         finalCargarObjeto

cargarVectorSalta:

    cmp         qword[contadorObjSalta], 20
    je          vectorSaltaLlena

    sub         rsp, 8
    call        cargarVecSalta
    add         rsp, 8

    jmp         finalCargarObjeto

cargarVectorTFuego:

    cmp         qword[contadorObjTFuego], 20
    je          vectorTFuegoLlena

    sub         rsp, 8
    call        cargarVecTFuego
    add         rsp, 8

    jmp         finalCargarObjeto

vectorPosadasLlena: 

    mov         rdi, msjPosadasLlena
    sub         rsp, 8
    call        puts 
    add         rsp, 8
    jmp         finalCargarObjeto

vectorSaltaLlena: 

    mov         rdi, msjSaltaLlena
    sub         rsp, 8
    call        puts 
    add         rsp, 8
    jmp         finalCargarObjeto

vectorTFuegoLlena: 

    mov         rdi, msjTFuegoLlena
    sub         rsp, 8
    call        puts 
    add         rsp, 8

finalCargarObjeto:
    ret

; ****************************
;   CARGAR VECTOR POSADAS
; ****************************
cargarVecPosadas:

    ; (i - 1) * longitudElemento

    mov         rdx, [contadorObjPosadas]

    mov         al, byte[pesoInput]
    mov         byte[vecInputPosadas + rdx], al

    inc         byte[contadorObjPosadas]

finalCargarVecPosadas:
    ret

; ****************************
;   CARGAR VECTOR SALTA
; ****************************
cargarVecSalta:

    mov         rdx, [contadorObjSalta]

    mov         al, byte[pesoInput]
    mov         byte[vecInputSalta + rdx], al

    inc         byte[contadorObjSalta]

finalCargarVecSalta:
    ret

; ***********************************
;   CARGAR VECTOR TIERRA DEL FUEGO
; ***********************************
cargarVecTFuego:

    mov         rdx, [contadorObjTFuego]

    mov         al, byte[pesoInput]
    mov         byte[vecInputTFuego + rdx], al

    inc         byte[contadorObjTFuego]

finalCargarVecTFuego:
    ret

; ***********************************
;       MOSTRAR     OBJETOS
; ***********************************
mostrarObjetos:

    ; POSADAS

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rdi, msjTagObjetosPosadas
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rbx, 0

imprimirObjetosPosadas:

    mov         rdi, msjformatoCadaObj
    mov         rsi, [vecInputPosadas + rbx]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    inc         rbx
    cmp         rbx, qword[longitudVector]
    jl          imprimirObjetosPosadas

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ; SALTA

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rdi, msjTagObjetosSalta
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rbx, 0

imprimirObjetosSalta:

    mov         rdi, msjformatoCadaObj
    mov         rsi, [vecInputSalta + rbx]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    inc         rbx
    cmp         rbx, qword[longitudVector]
    jl          imprimirObjetosSalta

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ; TIERRA DEL FUEGO

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rdi, msjTagObjetosTFuego
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rbx, 0

imprimirObjetosTFuego:

    mov         rdi, msjformatoCadaObj
    mov         rsi, [vecInputTFuego + rbx]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    inc         rbx
    cmp         rbx, qword[longitudVector]
    jl          imprimirObjetosTFuego

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalMostrarObjetos:

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret

; ***********************************
;       CARGAR VALOR POSADAS
; ***********************************
cargarValorPosadas:

    mov         rcx, 0

calcularValorPosadas:

    cmp         qword[contadorObjPosadas], rcx
    je          finalCargarValorPosadas

    mov         dl, byte[vecInputPosadas + rcx]
    mov         byte[vecValores + rcx], dl

    inc         rcx
    jmp         calcularValorPosadas

finalCargarValorPosadas:
    ret

; ***********************************
;       EMPAQUETAR OBJETOS POSADAS
; ***********************************
actualizarMatrizPosadas:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento*cantidadColumnas = 1 * 16 = 16

    mov         rbx, qword[contadorMatrizFila]
    dec         rbx
    mov         al, byte[vecValores + rbx]

    mov         byte[valorActualVec], al

    mov         ah, byte[vecInputPosadas + rbx]
    mov         byte[pesoActualVec], ah

    cmp         ah, 0
    je          finalActualizarPosadas

actualizarValorPosadas:

    ; mov         rdi, formatoNum
    ; mov         rsi, [contadorMatrizColumna]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    mov         rbx, qword[contadorMatrizFila]

    dec         rbx
    mov         rdx, qword[contadorMatrizColumna]
    imul        rbx, 16
    add         rbx, rdx

    mov         ah, byte[matriz + rbx]
    mov         byte[valorSinCambio], ah

    movzx       r8, byte[pesoActualVec]
    mov         r9, qword[contadorMatrizColumna]
    sub         r8, r9
    jg          sinCambiosPosadas

    mov         rbx, qword[contadorMatrizFila]
    dec         rbx
    imul        rbx, 16
    mov         rdx, qword[contadorMatrizColumna]
    movzx       r8, byte[pesoActualVec]
    sub         rdx, r8
    add         rbx, rdx

    mov         ah, byte[matriz + rbx]
    add         ah, byte[valorActualVec]

    cmp         ah, byte[valorSinCambio]
    jl          sinCambiosPosadas

    mov         rbx, qword[contadorMatrizFila]
    imul        rbx, 16
    add         rbx, qword[contadorMatrizColumna]

    mov         byte[matriz + rbx], ah

    inc         qword[contadorMatrizColumna]
    cmp         qword[contadorMatrizColumna], 16
    je          proxFilaPosadas
    jmp         actualizarValorPosadas

sinCambiosPosadas:

    mov         rbx, qword[contadorMatrizFila]
    imul        rbx, 16
    mov         rdx, qword[contadorMatrizColumna]
    add         rbx, rdx

    mov         al, byte[valorSinCambio]
    mov         byte[matriz + rbx], al

    inc         qword[contadorMatrizColumna]
    cmp         qword[contadorMatrizColumna], 16
    jl          actualizarValorPosadas

proxFilaPosadas:

    mov         qword[contadorMatrizColumna], 1
    inc         qword[contadorMatrizFila]
    cmp         qword[contadorMatrizFila], 21
    jl          actualizarMatrizPosadas

finalActualizarPosadas:
    ret

; ***********************************
;     EMPAQUETAR POSADAS
; ***********************************
empaquetarPosadas:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento*cantidadColumnas = 1 * 16 = 16

    mov           rdx, qword[contadorObjPosadas]
    mov           qword[contadorFilEmpaquetar], rdx

    mov           qword[contadorColEmpaquetar], 15
    mov           qword[contadorVecPaq], 0

empaquetarUnPaqPosadas:

    mov           rdx, qword[contadorFilEmpaquetar]
    imul          rdx, 16

    mov           rbx, qword[contadorColEmpaquetar]
    add           rbx, rdx

    mov           al, byte[matriz + rbx]
    ; PRUEBA
    mov           byte[valorActualMatirz], al

    mov           rdx, qword[contadorFilEmpaquetar]
    dec           rdx
    imul          rdx, 16

    mov           rbx, qword[contadorColEmpaquetar]
    add           rbx, rdx

    mov           ah, byte[matriz + rbx]
    ; PRUEBA
    mov           byte[valorSiHayAgregar], ah

    mov           al, byte[valorActualMatirz]
    mov           ah, byte[valorSiHayAgregar]

    cmp           ah, al
    jne           agregarObjPosadas

    dec           qword[contadorFilEmpaquetar]
    cmp           qword[contadorFilEmpaquetar], 0
    je            finalEmpaquetarPosadas
    jmp           empaquetarUnPaqPosadas

agregarObjPosadas:

    mov           rbx, qword[contadorFilEmpaquetar]
    dec           rbx 
    mov           dl, byte[vecInputPosadas + rbx]

    mov           rcx, qword[contadorVecPaq]
    mov           byte[vecPaquete + rcx], dl

    dec             qword[contadorFilEmpaquetar]
    dec             qword[contadorObjPosadas]

    cmp             qword[contadorFilEmpaquetar], 0
    je              ultimoVecPosadas

    mov             rbx, qword[contadorFilEmpaquetar]

    movzx           rax, byte[vecInputPosadas + rbx]
    sub             qword[contadorColEmpaquetar], rax

    mov           byte[vecInputPosadas +  rbx], 0

    cmp             qword[contadorColEmpaquetar], 0
    jle              finalEmpaquetarPosadas

    inc             qword[contadorVecPaq]
    jmp             empaquetarUnPaqPosadas

ultimoVecPosadas: 

    mov           rbx, qword[contadorFilEmpaquetar]
    mov           byte[vecInputPosadas +  rbx], 0

finalEmpaquetarPosadas:
    ret

; ***********************************
;     JUNTAR VECTOR PESO POSADAS
; *********************************** 
juntarVectorPesoPosadas: 

    mov         rcx, qword[posicionVacia]

    cmp         byte[vecInputPosadas + rcx], 0
    je          posicionVaciaPosadas

    inc         qword[posicionVacia]
    cmp         qword[posicionVacia], 20
    jge         finalJuntarPosadas
    jmp         juntarVectorPesoPosadas

posicionVaciaPosadas: 

    ; mov           rdi, formatoNumM
    ; mov           rsi, rcx
    ; sub           rax, rax
    ; sub           rsp, 8
    ; call          printf
    ; add           rsp, 8

    mov         rbx, qword[posicionVacia]
    inc         rbx 

    cmp         rbx, 20
    jge         finalJuntarPosadas

buscarPesoPosadas: 

    cmp         byte[vecInputPosadas + rbx], 0
    je          proxPesoPosadas

    mov         al, byte[vecInputPosadas + rbx]
    mov         byte[vecInputPosadas + rbx], 0
    mov         rdx, qword[posicionVacia]
    mov         byte[vecInputPosadas + rdx], al

    inc         qword[posicionVacia], 
    cmp         qword[posicionVacia], 20
    jge         finalJuntarPosadas
    jmp         juntarVectorPesoPosadas

proxPesoPosadas: 

    inc         rbx
    cmp         rbx, 20
    jl          buscarPesoPosadas

    inc         qword[posicionVacia]
    cmp         qword[posicionVacia], 20
    jl         juntarVectorPesoPosadas

finalJuntarPosadas: 
    ret 

; ***********************************
;     IMPRIMIR PAQUETE POSADAS
; *********************************** 
imprimirPaquetePosadas: 

    mov         rbx, 0
impUnPaqPosadas: 

    cmp        byte[vecPaquete + rbx], 0
    je         finalImprimirPaquetePosadas

    mov        rdi, msjPaquete
    mov        rsi, [contadorNumObjPosadas]
    mov        rdx, [vecPaquete + rbx]
    sub        rax, rax
    sub        rsp, 8
    call       printf
    add        rsp, 8

    mov        byte[vecPaquete + rbx], 0

    inc        qword[contadorNumObjPosadas]
    inc        rbx 
    cmp        rbx, 20
    jl         impUnPaqPosadas

finalImprimirPaquetePosadas: 

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret 

; ***********************************
;     VACIAR VEC VALORES
; *********************************** 
vaciarVecValores: 

    mov         rcx, 0

vaciarCadaValor: 
    mov         byte[vecValores + rcx], 0

    inc         rcx
    cmp         rcx, 20
    jl          vaciarCadaValor

finalVaciarVecValores:
    ret 

; ***********************************
;     VACIAR MATRIZ
; *********************************** 
vaciarMatriz: 

    mov         r8, 1  ; Fila
    mov         r9, 1  ; Columna

vaciarCadaCelda: 

    mov        rdx, r8
    imul       rdx, 16

    mov        rbx, r9
    add        rbx, rdx 

    mov         byte[matriz + rbx], 0

    inc         r9
    cmp         r9, 16
    je          vaciarProxFil
    jmp         vaciarCadaCelda

vaciarProxFil: 
    
    mov         r9, 1
    inc         r8
    cmp         r8, 21
    jl          vaciarCadaCelda

finalVaciarMatriz: 
    ret 

; ***********************************
;     PRUEBA IMPRIMIR VEC VALORES
; ***********************************
imprimirVecValores:

    mov         rdi, msjVecValor
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rbx, 0

imprimirCadaValor:

    mov         rdi, msjformatoCadaObj
    mov         rsi, [vecValores + rbx]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    inc         rbx
    cmp         rbx, 20
    jne         imprimirCadaValor

finalImprimirVecValores:

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret

; ***********************************
;     PRUEBA IMPRIMIR MATRIA
; ***********************************
imprimirMatriz:

    mov         qword[contadorPruebaFil], 0
    mov         qword[contadorPruebaCol], 0

imprimirM: 

    mov         rcx, qword[contadorPruebaFil]
    mov         rbx, qword[contadorPruebaCol]

    imul        rcx, 16
    add         rbx, rcx

    mov         rdi, msjformatoCadaObj
    mov         rsi, [matriz + rbx]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    inc         qword[contadorPruebaCol]
    cmp         qword[contadorPruebaCol], 16
    jl          imprimirM

proxFila:

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    inc         qword[contadorPruebaFil]
    mov         qword[contadorPruebaCol], 0
    cmp         qword[contadorPruebaFil], 21
    jl          imprimirM

finalImprimirMatriz:

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret

; ***********************************
;     PRUEBA IMPRIMIR VEC PAQUETE
; ***********************************

imprimirVecPaquete:

    mov         rdi, msjVecPaq
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rbx, 0

imprimirCadaValorPaq:

    mov         rdi, msjformatoCadaObj
    mov         rsi, [vecPaquete + rbx]
    sub         rax, rax
    sub         rsp, 8
    call        printf
    add         rsp, 8

    inc         rbx
    cmp         rbx, 20
    jne         imprimirCadaValorPaq


finalImprimirVecPaquete:

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret




; ***********************************
;       CARGAR VALOR SALTA
; ***********************************
cargarValorSalta:

    mov         rcx, 0

calcularValorSalta:

    cmp         qword[contadorObjSalta], rcx
    je          finalCargarValorSalta

    mov         dl, byte[vecInputSalta + rcx]
    mov         byte[vecValores + rcx], dl

    inc         rcx
    jmp         calcularValorSalta

finalCargarValorSalta:
    ret

; ***********************************
;       EMPAQUETAR OBJETOS SALTA
; ***********************************
actualizarMatrizSalta:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento*cantidadColumnas = 1 * 16 = 16

    mov         rbx, qword[contadorMatrizFila]
    dec         rbx
    mov         al, byte[vecValores + rbx]

    mov         byte[valorActualVec], al

    mov         ah, byte[vecInputSalta + rbx]
    mov         byte[pesoActualVec], ah

    cmp         ah, 0
    je          finalActualizarSalta

actualizarValorSalta:

    ; mov         rdi, formatoNum
    ; mov         rsi, [contadorMatrizColumna]
    ; sub         rax, rax
    ; sub         rsp, 8
    ; call        printf
    ; add         rsp, 8

    mov         rbx, qword[contadorMatrizFila]

    dec         rbx
    mov         rdx, qword[contadorMatrizColumna]
    imul        rbx, 16
    add         rbx, rdx

    mov         ah, byte[matriz + rbx]
    mov         byte[valorSinCambio], ah

    movzx       r8, byte[pesoActualVec]
    mov         r9, qword[contadorMatrizColumna]
    sub         r8, r9
    jg          sinCambiosSalta

    mov         rbx, qword[contadorMatrizFila]
    dec         rbx
    imul        rbx, 16
    mov         rdx, qword[contadorMatrizColumna]
    movzx       r8, byte[pesoActualVec]
    sub         rdx, r8
    add         rbx, rdx

    mov         ah, byte[matriz + rbx]
    add         ah, byte[valorActualVec]

    cmp         ah, byte[valorSinCambio]
    jl          sinCambiosSalta

    mov         rbx, qword[contadorMatrizFila]
    imul        rbx, 16
    add         rbx, qword[contadorMatrizColumna]

    mov         byte[matriz + rbx], ah

    inc         qword[contadorMatrizColumna]
    cmp         qword[contadorMatrizColumna], 16
    je          proxFilaSalta
    jmp         actualizarValorSalta

sinCambiosSalta:

    mov         rbx, qword[contadorMatrizFila]
    imul        rbx, 16
    mov         rdx, qword[contadorMatrizColumna]
    add         rbx, rdx

    mov         al, byte[valorSinCambio]
    mov         byte[matriz + rbx], al

    inc         qword[contadorMatrizColumna]
    cmp         qword[contadorMatrizColumna], 16
    jl          actualizarValorSalta

proxFilaSalta:

    mov         qword[contadorMatrizColumna], 1
    inc         qword[contadorMatrizFila]
    cmp         qword[contadorMatrizFila], 21
    jl          actualizarMatrizSalta

finalActualizarSalta:
    ret


; ***********************************
;     EMPAQUETAR SALTA
; ***********************************
empaquetarSalta:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento*cantidadColumnas = 1 * 16 = 16

    mov           rdx, qword[contadorObjSalta]
    mov           qword[contadorFilEmpaquetar], rdx

    mov           qword[contadorColEmpaquetar], 15
    mov           qword[contadorVecPaq], 0

empaquetarUnPaqSalta:

    mov           rdx, qword[contadorFilEmpaquetar]
    imul          rdx, 16

    mov           rbx, qword[contadorColEmpaquetar]
    add           rbx, rdx

    mov           al, byte[matriz + rbx]
    ; PRUEBA
    mov           byte[valorActualMatirz], al

    mov           rdx, qword[contadorFilEmpaquetar]
    dec           rdx
    imul          rdx, 16

    mov           rbx, qword[contadorColEmpaquetar]
    add           rbx, rdx

    mov           ah, byte[matriz + rbx]
    ; PRUEBA
    mov           byte[valorSiHayAgregar], ah

    mov           al, byte[valorActualMatirz]
    mov           ah, byte[valorSiHayAgregar]

    cmp           ah, al
    jne           agregarObjSalta

    dec           qword[contadorFilEmpaquetar]
    cmp           qword[contadorFilEmpaquetar], 0
    je            finalEmpaquetarSalta
    jmp           empaquetarUnPaqSalta

agregarObjSalta:

    mov           rbx, qword[contadorFilEmpaquetar]
    dec           rbx 
    mov           dl, byte[vecInputSalta + rbx]

    mov           rcx, qword[contadorVecPaq]
    mov           byte[vecPaquete + rcx], dl

    dec             qword[contadorFilEmpaquetar]
    dec             qword[contadorObjSalta]

    cmp             qword[contadorFilEmpaquetar], 0
    je              ultimoVecSalta

    mov             rbx, qword[contadorFilEmpaquetar]

    movzx           rax, byte[vecInputSalta + rbx]
    sub             qword[contadorColEmpaquetar], rax

    mov           byte[vecInputSalta +  rbx], 0

    cmp             qword[contadorColEmpaquetar], 0
    jle              finalEmpaquetarSalta

    inc             qword[contadorVecPaq]
    jmp             empaquetarUnPaqSalta

ultimoVecSalta: 

    mov           rbx, qword[contadorFilEmpaquetar]
    mov           byte[vecInputSalta +  rbx], 0

finalEmpaquetarSalta:
    ret

; ***********************************
;     JUNTAR VECTOR PESO SALTA
; *********************************** 
juntarVectorPesoSalta: 

    mov         rcx, qword[posicionVacia]

    cmp         byte[vecInputSalta + rcx], 0
    je          posicionVaciaSalta

    inc         qword[posicionVacia]
    cmp         qword[posicionVacia], 20
    jge         finalJuntarSalta
    jmp         juntarVectorPesoSalta

posicionVaciaSalta: 

    ; mov           rdi, formatoNumM
    ; mov           rsi, rcx
    ; sub           rax, rax
    ; sub           rsp, 8
    ; call          printf
    ; add           rsp, 8

    mov         rbx, qword[posicionVacia]
    inc         rbx 

    cmp         rbx, 20
    jge         finalJuntarSalta

buscarPesoSalta: 

    cmp         byte[vecInputSalta + rbx], 0
    je          proxPesoSalta

    mov         al, byte[vecInputSalta + rbx]
    mov         byte[vecInputSalta + rbx], 0
    mov         rdx, qword[posicionVacia]
    mov         byte[vecInputSalta + rdx], al

    inc         qword[posicionVacia], 
    cmp         qword[posicionVacia], 20
    jge         finalJuntarSalta
    jmp         juntarVectorPesoSalta

proxPesoSalta: 

    inc         rbx
    cmp         rbx, 20
    jl          buscarPesoSalta

    inc         qword[posicionVacia]
    cmp         qword[posicionVacia], 20
    jl         juntarVectorPesoSalta

finalJuntarSalta: 
    ret 

; ***********************************
;     IMPRIMIR PAQUETE SALTA
; *********************************** 
imprimirPaqueteSalta: 

    mov         rbx, 0
impUnPaqSalta: 

    cmp        byte[vecPaquete + rbx], 0
    je         finalImprimirPaqueteSalta

    mov        rdi, msjPaquete
    mov        rsi, [contadorNumObjSalta]
    mov        rdx, [vecPaquete + rbx]
    sub        rax, rax
    sub        rsp, 8
    call       printf
    add        rsp, 8

    mov        byte[vecPaquete + rbx], 0

    inc        qword[contadorNumObjSalta]
    inc        rbx 
    cmp        rbx, 20
    jl         impUnPaqSalta

finalImprimirPaqueteSalta: 

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret 




; ***********************************
;    CARGAR VALOR TIERRA DEL FUEGO
; ***********************************
cargarValorTFuego:

    mov         rcx, 0

calcularValorTFuego:

    cmp         qword[contadorObjTFuego], rcx
    je          finalCargarValorTFuego

    mov         dl, byte[vecInputTFuego + rcx]
    mov         byte[vecValores + rcx], dl

    inc         rcx
    jmp         calcularValorTFuego

finalCargarValorTFuego:
    ret

; ***********************************************
;       EMPAQUETAR OBJETOS TIERRA DEL FUEGO
; ***********************************************
actualizarMatrizTFuego:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento*cantidadColumnas = 1 * 16 = 16

    mov         rbx, qword[contadorMatrizFila]
    dec         rbx
    mov         al, byte[vecValores + rbx]

    mov         byte[valorActualVec], al

    mov         ah, byte[vecInputTFuego + rbx]
    mov         byte[pesoActualVec], ah

    cmp         ah, 0
    je          finalActualizarTFuego

actualizarValorTFuego:

    mov         rbx, qword[contadorMatrizFila]

    dec         rbx
    mov         rdx, qword[contadorMatrizColumna]
    imul        rbx, 16
    add         rbx, rdx

    mov         ah, byte[matriz + rbx]
    mov         byte[valorSinCambio], ah

    movzx       r8, byte[pesoActualVec]
    mov         r9, qword[contadorMatrizColumna]
    sub         r8, r9
    jg          sinCambiosTFuego

    mov         rbx, qword[contadorMatrizFila]
    dec         rbx
    imul        rbx, 16
    mov         rdx, qword[contadorMatrizColumna]
    movzx       r8, byte[pesoActualVec]
    sub         rdx, r8
    add         rbx, rdx

    mov         ah, byte[matriz + rbx]
    add         ah, byte[valorActualVec]

    cmp         ah, byte[valorSinCambio]
    jl          sinCambiosTFuego

    mov         rbx, qword[contadorMatrizFila]
    imul        rbx, 16
    add         rbx, qword[contadorMatrizColumna]

    mov         byte[matriz + rbx], ah

    inc         qword[contadorMatrizColumna]
    cmp         qword[contadorMatrizColumna], 16
    je          proxFilaTFuego
    jmp         actualizarValorTFuego

sinCambiosTFuego:

    mov         rbx, qword[contadorMatrizFila]
    imul        rbx, 16
    mov         rdx, qword[contadorMatrizColumna]
    add         rbx, rdx

    mov         al, byte[valorSinCambio]
    mov         byte[matriz + rbx], al

    inc         qword[contadorMatrizColumna]
    cmp         qword[contadorMatrizColumna], 16
    jl          actualizarValorTFuego

proxFilaTFuego:

    mov         qword[contadorMatrizColumna], 1
    inc         qword[contadorMatrizFila]
    cmp         qword[contadorMatrizFila], 21
    jl          actualizarMatrizTFuego

finalActualizarTFuego:
    ret

; ***********************************
;     EMPAQUETAR TIERRA DEL FUEGO
; ***********************************
empaquetarTFuego:

; (i-1)*longitudFila + (j-1)*longitudElemento

; longitdFila= longitudElemento*cantidadColumnas = 1 * 16 = 16

    mov           rdx, qword[contadorObjTFuego]
    mov           qword[contadorFilEmpaquetar], rdx

    mov           qword[contadorColEmpaquetar], 15
    mov           qword[contadorVecPaq], 0

empaquetarUnPaqTFuego:

    mov           rdx, qword[contadorFilEmpaquetar]
    imul          rdx, 16

    mov           rbx, qword[contadorColEmpaquetar]
    add           rbx, rdx

    mov           al, byte[matriz + rbx]
    ; PRUEBA
    mov           byte[valorActualMatirz], al

    mov           rdx, qword[contadorFilEmpaquetar]
    dec           rdx
    imul          rdx, 16

    mov           rbx, qword[contadorColEmpaquetar]
    add           rbx, rdx

    mov           ah, byte[matriz + rbx]
    ; PRUEBA
    mov           byte[valorSiHayAgregar], ah

    mov           al, byte[valorActualMatirz]
    mov           ah, byte[valorSiHayAgregar]

    cmp           ah, al
    jne           agregarObjTFuego

    dec           qword[contadorFilEmpaquetar]
    cmp           qword[contadorFilEmpaquetar], 0
    je            finalEmpaquetarTFuego
    jmp           empaquetarUnPaqTFuego

agregarObjTFuego:

    mov           rbx, qword[contadorFilEmpaquetar]
    dec           rbx 
    mov           dl, byte[vecInputTFuego + rbx]

    mov           rcx, qword[contadorVecPaq]
    mov           byte[vecPaquete + rcx], dl

    dec             qword[contadorFilEmpaquetar]
    dec             qword[contadorObjTFuego]

    cmp             qword[contadorFilEmpaquetar], 0
    je              ultimoVecTFuego

    mov             rbx, qword[contadorFilEmpaquetar]

    movzx           rax, byte[vecInputTFuego + rbx]
    sub             qword[contadorColEmpaquetar], rax

    mov           byte[vecInputTFuego +  rbx], 0

    cmp             qword[contadorColEmpaquetar], 0
    jle              finalEmpaquetarTFuego

    inc             qword[contadorVecPaq]
    jmp             empaquetarUnPaqTFuego

ultimoVecTFuego: 

    mov           rbx, qword[contadorFilEmpaquetar]
    mov           byte[vecInputTFuego +  rbx], 0

finalEmpaquetarTFuego:
    ret

; *******************************************
;     JUNTAR VECTOR PESO TIERRA DEL FUEGO
; ******************************************* 
juntarVectorPesoTFuego: 

    mov         rcx, qword[posicionVacia]

    cmp         byte[vecInputTFuego + rcx], 0
    je          posicionVaciaTFuego

    inc         qword[posicionVacia]
    cmp         qword[posicionVacia], 20
    jge         finalJuntarTFuego
    jmp         juntarVectorPesoTFuego

posicionVaciaTFuego: 

    mov         rbx, qword[posicionVacia]
    inc         rbx 

    cmp         rbx, 20
    jge         finalJuntarTFuego

buscarPesoTFuego: 

    cmp         byte[vecInputTFuego + rbx], 0
    je          proxPesoTFuego

    mov         al, byte[vecInputTFuego + rbx]
    mov         byte[vecInputTFuego + rbx], 0
    mov         rdx, qword[posicionVacia]
    mov         byte[vecInputTFuego + rdx], al

    inc         qword[posicionVacia], 
    cmp         qword[posicionVacia], 20
    jge         finalJuntarTFuego
    jmp         juntarVectorPesoTFuego

proxPesoTFuego: 

    inc         rbx
    cmp         rbx, 20
    jl          buscarPesoTFuego

    inc         qword[posicionVacia]
    cmp         qword[posicionVacia], 20
    jl         juntarVectorPesoTFuego

finalJuntarTFuego: 
    ret 

; *****************************************
;     IMPRIMIR PAQUETE TIERRA DEL FUEGO
; ***************************************** 
imprimirPaqueteTFuego: 

    mov         rbx, 0
impUnPaqTFuego: 

    cmp        byte[vecPaquete + rbx], 0
    je         finalImprimirPaqueteTFuego

    mov        rdi, msjPaquete
    mov        rsi, [contadorNumObjTFuego]
    mov        rdx, [vecPaquete + rbx]
    sub        rax, rax
    sub        rsp, 8
    call       printf
    add        rsp, 8

    mov        byte[vecPaquete + rbx], 0

    inc        qword[contadorNumObjTFuego]
    inc        rbx 
    cmp        rbx, 20
    jl         impUnPaqTFuego

finalImprimirPaqueteTFuego: 

    mov         rdi, msjSaltoLinea
    sub         rsp, 8
    call        puts
    add         rsp, 8

    ret 
