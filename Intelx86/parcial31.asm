;Se dispone una matriz C que representa un calendario de actividades de una persona
;La matriz C está formada por 7 columnas (que corresponden a los dias de la semana)
;y por 6 filas (que corresponden a las semanas que puede tenes como maximo un mes)
;Cada elemento de la matriz es un bpf s/signo de 2 bytes (word)
;representa la cantidad de actividades que realizara dicho dia en la semana.
;Ademas se dispone de un archivo de entrada llamado CALEN.DAT donde cada registro tiene el siguiente formato:

    ;-Dia de la semana: caracter de 2 bytes (DO, LU, MA, MI, JU, VI, SA)
    ;-Semana: Binario de 1 byte (1 a 6)
    ;-Actividad: Caracteres de longitud 20 con la descripcion

;Como la informacion leida del archivo puede ser erronea,
;se dispone de una rutina interna llamada VALCAL para su validacion.
;Se pide realizarun programa assembler intel x86 que actualize lamatriz C con aquellos registros validos.
;Al finalizar la actualizacion se solicitara el ingreso por teclado 
;y se debe generar un listado indicando "Dia de la semana - Cantidad de Actividades"

global main
extern fopen
extern fread 
extern fclose 
extern printf 
extern puts
extern sscanf 
extern gets 

section             .data 

    matrizCalendario            times 42        dw      0
    ; Cada celda de la matriz representa la cantidad de actividades que tiene que realizar ese dia
    longitudFila                dq              14
    longitudElemento            dq              2

    nombreArchivoCalen          db              "CALEN.DAT", 0
    modoCalen                   db              "rb", 0
    handleArchivoCalen          dq               0

    msjErrorApertura            db              "Error apertura de CALEN.DAT", 0

    msjInputNumSemana           db              "Ingrese el número de semana: ", 0
    msjInputInvalido            db              "Semana Inválida. Intente nuevamente.", 0
    msjCalendario               db              "%s - %hi", 10, 0

    semanaStr                   db              "*", 0
    formatoSemana               db              "%hhi", 0

    msjLunes                    db              "Lunes", 0
    msjMartes                   db              "Martes", 0
    msjMiercoles                db              "Miércoles", 0
    msjJueves                   db              "Jueves", 0
    msjViernes                  db              "Viernes", 0
    msjSabado                   db              "Sábado", 0
    msjDomingo                  db              "Domingo", 0

    registro                    times 0         db      ''
     diaSemana                  times 2         db      " "
     semana                                     db      0
     actividad                  times 20        db      " "

    diaSemanaNum                dq              0
    vecDiaSemana                db              "DOLUMAMIJUVISA", 0

    contadorColumna             dq              0

    ; PRUEBA DATOS
    msjErrorDiaSemana           db              "Error Dia Semana", 0
    msjErrorSemana              db              "Error Semana", 0
    formatoStr                  db              "%s", 0
    formatoNum                  db              "%hi", 0
    msjPrueba                   db              "llegué", 0

section             .bss

    exitoApertura               resb            1

    registroValido              resb            1
    diaSemanaValido             resb            1
    semanaValida                resb            1

    inputSemana                 resb            100
    inputValido                 resb            1

section             .text 
main: 

    sub             rsp, 8
    call            abrirArchivoCalendario
    add             rsp, 8

    cmp             byte[exitoApertura], 'N'
    je              fin 

leerRegistro: 

    sub             rsp, 8
    call            leerActividad
    add             rsp, 8

    cmp             rax, 0
    jle             cerrarArchivo

    sub             rsp, 8
    call            VALCAL
    add             rsp, 8

    ; mov             rdi, formatoNum
    ; mov             rsi, [semana]
    ; sub             rax, rax
    ; sub             rsp, 8
    ; call            printf
    ; add             rsp, 8

    cmp             byte[registroValido], 'N'
    je              leerRegistro



    sub             rsp, 8
    call            actualizarCalendario
    add             rsp, 8


    jmp             leerRegistro

cerrarArchivo:

    sub             rsp, 8
    call            cerrarArchivoCalendario
    add             rsp, 8

pedirAlUsuario: 

    sub             rsp, 8
    call            pedirInputUsuario
    add             rsp, 8

    cmp             byte[inputValido], 'N'
    je              inputInvalido

    mov             qword[contadorColumna], 0

    sub             rsp, 8
    call            imprimirCalendario
    add             rsp, 8

    jmp             pedirAlUsuario

inputInvalido: 

    mov             rdi, msjInputInvalido
    sub             rsp, 8
    call            puts
    add             rsp, 8

    jmp             pedirAlUsuario

fin:
    ret 

; **************************
;   ABRIR  CALENDARIO
; **************************
abrirArchivoCalendario: 

    mov         byte[exitoApertura], 'N'

    mov         rdi, nombreArchivoCalen
    mov         rsi, modoCalen
    sub         rsp, 8
    call        fopen 
    add         rsp, 8

    cmp         rax, 0
    jle         errorApertura 

    mov         qword[handleArchivoCalen], rax 

    mov         byte[exitoApertura], 'S'
    jmp         finalAbrirArchivoCalendario

errorApertura:

    mov         rdi, msjErrorApertura
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalAbrirArchivoCalendario: 
    ret 

; **************************
;   CERRAR  CALENDARIO
; **************************
cerrarArchivoCalendario:

    mov         rdi, [handleArchivoCalen]
    sub         rsp, 8
    call        fclose 
    add         rsp, 8

finalCerrarArchivoCalendario: 
    ret 

; **************************
;   LEER REGISTRO
; **************************
leerActividad:

    mov         rdi, registro 
    mov         rsi, 23
    mov         rdx, 1
    mov         rcx, [handleArchivoCalen]
    sub         rsp, 8
    call        fread 
    add         rsp, 8


finalLeerActividad: 
    ret 

; **************************
;   VALIDAR REGISTRO
; **************************
VALCAL: 

    mov         byte[registroValido], 'N'

    mov         qword[diaSemanaNum], 1

    sub         rsp, 8
    call        validarDiaSemana
    add         rsp, 8

    cmp         byte[diaSemanaValido], 'N'
    je          finalValcal

    sub         rsp, 8
    call        validarSemana 
    add         rsp, 8
    
    cmp         byte[semana], 'N'
    je          finalValcal

    mov         byte[registroValido], 'S'

finalValcal: 
    ret 

; **************************
;   VALIDAR DIA SEMANA
; **************************
validarDiaSemana:

    mov         byte[diaSemanaValido], 'S'

    mov         rcx, 7
    mov         rbx, 0

compararDia: 

    push        rcx 

    mov         rcx, 2
    lea         rsi, [vecDiaSemana + rbx]
    lea         rdi, [diaSemana]
    repe        cmpsb 

    pop         rcx 
    je          finalValidarDiaSemana
    add         rbx, 2
    inc         qword[diaSemanaNum]
    loop        compararDia 

    mov         byte[diaSemanaValido], 'N'

errorDiaSemana: 

    mov         rdi, msjErrorDiaSemana
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarDiaSemana:
    ret 

; **************************
;   VALIDAR SEMANA
; **************************
validarSemana: 

    mov         byte[semanaValida], 'N'

    cmp         byte[semana], 1
    jl          errorSemana

    cmp         byte[semana], 6
    jg          errorSemana

    mov         byte[semanaValida], 'S'
    jmp         finalValidarSemana
    
errorSemana: 

    mov         rdi, msjErrorSemana
    sub         rsp, 8
    call        puts
    add         rsp, 8

finalValidarSemana: 
    ret 

; **************************
;   ACTUALIZAR CALENDARIO
; **************************
actualizarCalendario: 

    movzx           rdx, byte[semana]
    dec             rdx
    imul            rdx, qword[longitudFila]

    mov             rbx, [ ]
    dec             rbx
    imul            rbx, qword[longitudElemento]

    add             rbx, rdx 

    inc             word[matrizCalendario + rbx]

    ; mov             rdi, msjPrueba
    ; sub             rsp, 8
    ; call            puts
    ; add             rsp, 8

    ; mov             rdi, formatoNum
    ; movzx             rsi, word[matrizCalendario + rbx]
    ; sub             rax, rax
    ; sub             rsp, 8
    ; call            printf
    ; add             rsp, 8

finalActualizarCalendario: 
    ret 

; **************************
;   PEDIR INPUT
; **************************
pedirInputUsuario:

    mov             byte[inputValido], 'N'

    mov             rdi, msjInputNumSemana
    sub             rsp, 8
    call            printf
    add             rsp, 8

    mov              rdi, inputSemana
    sub              rsp, 8
    call             gets 
    add              rsp, 8

    mov             rcx, 1
    lea             rsi, [inputSemana]
    lea             rdi, [semanaStr]
    rep             movsb

    ; mov             rdi, formatoStr
    ; mov             rsi, [semanaStr]
    ; sub             rax, rax
    ; sub             rsp, 8
    ; call            printf
    ; add             rsp, 8

    mov             rdi, semanaStr
    mov             rsi, formatoSemana
    mov             rdx, semana 
    sub             rax, rax
    sub             rsp, 8
    call            sscanf 
    add             rsp, 8

    cmp             rax, 0
    jle             finalPedirInputUsuario

    sub             rsp, 8
    call            validarSemana
    add             rsp, 8

    cmp             byte[semanaValida], 'N'
    je              finalPedirInputUsuario

    mov             byte[inputValido], 'S'

finalPedirInputUsuario: 
    ret 

; **************************
;   IMPRIMIR CALENDARIO
; **************************
imprimirCalendario: 

    mov         rdx, [contadorColumna]

    cmp         rdx, 0
    je          domingo 

    cmp         rdx, 1
    je          lunes 

    cmp         rdx, 2
    je          martes 

    cmp         rdx, 3
    je          miercoles

    cmp         rdx, 4
    je          jueves 

    cmp         rdx, 5
    je          viernes 

    cmp         rdx, 6
    je          sabado


domingo: 

    mov         rsi, msjDomingo
    jmp         imprimir

lunes:

    mov         rsi, msjLunes
    jmp         imprimir

martes: 

    mov         rsi, msjMartes
    jmp         imprimir

miercoles:

    mov         rsi, msjMiercoles
    jmp         imprimir

jueves: 

    mov         rsi, msjJueves
    jmp         imprimir

viernes:        

    mov         rsi, msjViernes
    jmp         imprimir

sabado:         

    mov         rsi, msjSabado

imprimir: 

    mov         rdi, msjCalendario

    movzx       rbx, byte[semana]
    imul        rdx, qword[longitudFila]

    mov         rbx, [contadorColumna]
    dec         rbx
    imul        rbx, qword[longitudElemento]

    add         rbx, rdx 

    movzx         rdx, word[matrizCalendario + rbx]

    sub            rax, rax
    sub            rsp, 8
    call           printf
    add            rsp, 8

    inc         qword[contadorColumna]
    cmp         qword[contadorColumna], 7
    jne         imprimirCalendario

finalImprimirCalendario: 
    ret


