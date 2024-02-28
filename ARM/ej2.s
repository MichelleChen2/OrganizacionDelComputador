# Escribir el código ARM que ejecutado bajo ARMSim# imprima dos cadenas de caracteres
# predefinidas en memoria incluyendo salto de línea “Hola” y ”Chau” utilizando una subrutina
# que imprima un string cuya dirección esté en el R3.

    .equ        SWI_Exit, 0x11
    .equ        SWI_Print_Str, 0x02

    .data 

msjHola:    
            .asciz      "Hola "
msjChau:    
            .asciz      "Chau "
msjSalto:   
            .asciz       "\n"
nombreStr:   
            .asciz      "Michelle"

    .text 
    .global _start 

_start: 

    ldr     r3, =nombreStr
    bl      imprimir_hola 
    swi     SWI_Exit

imprimir_hola: 
    stmfd   sp!, {lr} 

    ldr     r0, =msjHola
    swi     SWI_Print_Str

    mov     r0, r3
    swi     SWI_Print_Str

    ldr     r0, =msjSalto
    swi     SWI_Print_Str

    ldr     r0, =msjChau
    swi     SWI_Print_Str

    mov     r0, r3
    swi     SWI_Print_Str

    ldr     r0, =msjSalto
    swi     SWI_Print_Str

    ldmfd   sp!, {pc} 
    .end

