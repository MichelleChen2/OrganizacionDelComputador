# Escribir el código ARM que ejecutado bajo ARMSim# realice las siguientes operaciones
# aritméticas y lógicas sobre dos números cargados en memoria: Suma, Resta, Multiplicación,
# AND, OR, XOR, Shift Izquierda, Shift Derecha, Shift Derecha Aritmética. Dejar el resultado de
# las operaciones en los registros del R2 al R10.

        .equ        SWI_Print_Str, 0x02

        .equ        SWI_Print_Int, 0x6B
        .equ        SWI_Exit, 0x11

        .data 

numero1: 
        .word   10
numero2: 
        .word   2


        .text 

        .global _start
_start: 

        bl      suma

        swi     SWI_Exit


suma: 
        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        mov     r0, #1
        add     r1, r3, r4
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}
        .end

resta: 

        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        sub     r0, r3, r4
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

multiplicacion:

        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        mul     r0, r3, r4
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

opAnd:

        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        mul     r0, r3, r4
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

opOr:

        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        orr     r0, r3, r4
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

opXor: 

        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        eor     r0, r3, r4
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

shiftIzq: 

        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        eor     r0, r3, LSL #1
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

shiftDer:
        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        eor     r0, r3, LSR #1
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}

shiftArithmeticDer: 
        stmfd   sp!, {lr}

        ldr     r3, =numero1
        ldr     r4, =numero2

        ldr     r3, [r3]
        ldr     r4, [r4]

        eor     r0, r3, ASR #1
        swi     SWI_Print_Int  

        ldmfd   sp!, {pc}
        .end


        # bl      resta 
        # bl      multiplicacion
        # bl      opAnd
        # bl      opOr 
        # bl      opXor
        # bl      shiftIzq
        # bl      shiftDer
        # bl      shiftArithmeticDer