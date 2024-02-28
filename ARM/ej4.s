# Escribir el código ARM que ejecutado bajo ARMSim# que lea un entero desde un archivo e
# imprima el mismo entero por pantalla.

#     .equ        SWI_Open_File, 0x66
#     .equ        SWI_Exit, 0x11
#     .equ        SWI_RdInt, 0x6c
#     .equ        SWI_Close, 0x68
#     .equ        SWI_Print_Int, 0x6b

#     .data 

# nombreArchivo: 
#     .asciz      "archivo.txt"
#     .align

# handleArchivo: 
#     .word       0

#     .text 
#     .global _start

# _start: 

#     ldr     r0, =nombreArchivo
#     mov     r1, #0      @ modo: Entrada
#     swi     SWI_Open_File
#     bcs     InFileError
#     ldr     r1, =handleArchivo
#     str     r0, [r1]

#     ldr     r0, =handleArchivo
#     ldr     r0, [r0]
#     swi     SWI_RdInt
#     mov     r2, r0

#     ldr     r0, =handleArchivo
#     ldr     r0, [r0]
#     swi     SWI_Close

#     mov     r0, #1
#     mov     r1, r2 
#     swi     SWI_Print_Int

#     swi     SWI_Exit

# InFileError: 

#     .end 

        .equ        SWI_Open_File, 0x66
        .equ        SWI_Close_File, 0x68
        .equ        SWI_Print_Int, 0x6b
        .equ        SWI_Print_Str, 0x02
        .equ        SWI_Read_Int, 0x6c
        .equ        SWI_Exit, 0x11

        .data 

FileName: 
        .asciz      "enter.txt"
        .align 

ErrorFile: 
        .asciz      "Error Apertura Archivo"
        .align
entero:     
        .word       0

InFileHandle:

        .word       0

        .text 
        .global _start 
_start: 

        # Apertura Archivo
        ldr         r0, =FileName
        mov         r1, #0
        swi         0x66
        bcs         InFileError
        ldr         r1, =InFileHandle
        str         r0, [r1]                    @ str = store el contenido en r0 al dir guardado en r1

        ldr         r0, =InFileHandle
        ldr         r0, [r0]
        swi         0x6c

        ldr         r5, =entero 
        str         r0, [r5]

        ldr         r1, =entero 
        ldr         r1, [r1]
        mov         r0, #1
        swi         0x6b

        ldr         r0, =InFileHandle
        ldr         r0, [r0]     
        swi         0x68

        swi         0x11

InFileError:

        ldr         r0, =ErrorFile
        swi         0x02

        .end 


