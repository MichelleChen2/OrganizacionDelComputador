# Cálculo de valor absoluto con instrucciones condicionales
# Escribir el código ARM que ejecutado bajo ARMSim# lea un entero desde un archivo e imprima
# el valor absoluto del entero. Utilizar instrucciones ejecutadas condicionalmente y no utilizar
# bifurcaciones condicionales.

#        .equ         SWI_Exit, 0x11
#        .text 
#        .global     _start 

# _start: 

#        cmp         r2, #0   # En r2 está el 7, me interesa el bit de negativo (N)

#        mov         r3, #0 
#        submi       r2, r3, r2 # Restar si es 1 el bit de negativo (N)
        # Si r2 < 0 entonces r2 = r3 - r2 

# Práctica 7: Cálculo de valor absoluto con instrucciones condicionales

# Escribir el código ARM que ejecutado bajo ARMSim# lea un entero desde un archivo e imprima
# el valor absoluto del entero. Utilizar instrucciones ejecutadas condicionalmente y no utilizar
# bifurcaciones condicionales.

        .data
FileName:
        .asciz          "entero.txt"
        .align
MsjEOL:     
        .asciz          "Error opening file"
        .align 
InFileHandle:
        .word           0
AbsoluteValue:
        .word           0
Integer: 
        .word           0

        .text 
        .global    _start 
_start: 

        bl         Open_File

        bl         Read_Int

        ldr        r1, =Integer
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        ldr        r5, =Integer
        ldr        r5, [r5]
        cmp        r5, #0
        blmi       negative
        blpl       positive

        bl         Close_File

        ldr        r1, =AbsoluteValue
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        swi         0x11

Open_File: 
        stmfd       sp!, {lr}

        ldr         r0, =FileName
        mov         r1, #0
        swi         0x66
        bcs         EOL

        ldr         r5, =InFileHandle
        str         r0, [r5]

        ldmfd       sp!, {pc}

Read_Int:

        stmfd       sp!, {lr}

        ldr         r0, =InFileHandle
        ldr         r0, [r0]
        swi         0x6c

        ldr         r5, =Integer
        str         r0, [r5]

        ldmfd       sp!, {pc}

negative: 

        stmfd       sp!, {lr}

        mov         r4, #-1
        mul         r6, r5, r4

        ldr         r1, =AbsoluteValue
        str         r6, [r1]

        ldmfd       sp!, {pc}

positive: 

        stmfd       sp!, {lr}

        ldr         r2, =AbsoluteValue
        str         r5, [r2]

        ldmfd       sp!, {pc}

Close_File: 

        stmfd       sp!, {lr}

        ldr         r0, =InFileHandle
        swi         0x68

        ldmfd       sp!, {pc}

EOL:    
        ldr         r0, =MsjEOL
        swi         0x02
        swi         0x11
        .end 
