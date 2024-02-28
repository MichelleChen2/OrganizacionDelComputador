# Escribir el código ARM que ejecutado bajo ARMSim# lea dos enteros desde un archivo e
# imprima:

# El primer entero en su propia línea.
# El resultado de aplicar NOT al primer entero en su propia línea.
# El segundo entero en su propia línea.
# El resultado de aplicar NOT al segundo entero en su propia línea.

        .data 

FileName:
        .asciz          "entero.txt"
        .align

Enter: 
        .asciz          "\n"
        .align

InFileHandle: 
        .word           0

Integer: 
        .word           0

ErrorFile: 
        .asciz          "Error Apertura Archivo"
        .align


        .text 
        .global _start

_start: 
        ldr         r0, =FileName
        mov         r1, #0
        swi         0x66
        bcs         InFileError
        ldr         r5, =InFileHandle
        str         r0, [r5]

ReadInt: 

        ldr         r0, =InFileHandle
        ldr         r0, [r0]
        swi         0x6c
        ldr         r5, =Integer
        bcs         EOF 
        str         r0, [r5]

        ldr         r1, =Integer
        ldr         r1, [r1]
        mov         r0, #1
        swi         0x6b

        ldr         r0, =Enter 
        swi         0x02

        ldr         r6, =Integer
        ldr         r6, [r6]
        mvn         r7, r6 

        mov         r1, r7 
        ldr         r0, =InFileHandle
        swi         0x6b

        mov         r1, r7
        mov         r0, #1
        swi         0x6b
        b           ReadInt

        ldr         r0, =InFileHandle
        ldr         r0, [r0]
        swi         0x68

        swi         0x11

InFileError:
        ldr         r0, =ErrorFile
        swi         0x02
        swi         0x11
EOF: 
        .end