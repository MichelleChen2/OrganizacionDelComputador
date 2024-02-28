# Práctica 19: Mostrar elementos de un vector utilizando direccionamiento por registro indirecto
# con registro indexado escalado
# Modificar el ejercicio para utilizar direccionamiento por registro indirecto con registro indexado
# escalado.

# Escribir el código ARM que ejecutado bajo ARMSim# imprima los valores de un vector de
# cuatro enteros definidos en memoria, recorriendo el vector mediante una subrutina que utilice
# direccionamiento por registro indirecto.

        .data 

vector: 
        .word       8,14,-105,98

        .text 
        .global _start 

_start:

        mov         r4, #0
        ldr         r5, =vector

mostrar_cada_elem_vector: 

        bl          mostrar_Int

       add          r4, r4, #1
       cmp          r4, #4
       blt          mostrar_cada_elem_vector
       swi          0x11

mostrar_Int: 
        stmfd       sp!, {lr}

        mov         r0, #1
        ldr         r1, [r5, r4, LSL #2]
        swi         0x6b

        ldmfd       sp!, {pc}
