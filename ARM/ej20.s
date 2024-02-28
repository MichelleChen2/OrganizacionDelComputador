# Práctica 20: Encontrar el menor elemento de un vector
# Escribir el código ARM que ejecutado bajo ARMSim# encuentre e imprima el menor elemento
# de un vector, donde el vector está especificado con el label vector y la longitud del vector con
# el label long_vector .

        .data 

vector: 
        .word       2,8,-10,1,100,0
long_vector:
        .word       6
menor_elem_vector:
        .word       0
        .text 
        .global _start 
_start:

        mov        r4, #4
        ldr        r6, =long_vector
        ldr        r6, [r6]
        mul        r6, r6, r4 

        mov         r5, #0

        ldr         r0, =vector
        ldr         r1, [r0, r5]

        add         r5, r5, r4
        cmp         r6, r5 
        ble         guardar_menor_elem

comparar_cada_elem_vector: 

        ldr         r2, [r0, r5]
        cmp         r2, r1
        bgt         prox_elem
 
        mov         r1, r2 

prox_elem: 
        add         r5, r5, r4
        cmp         r6, r5 
        bgt         comparar_cada_elem_vector

guardar_menor_elem: 

        ldr         r3, =menor_elem_vector
        str         r1, [r3]

imprimir_menor_elem: 

        ldr         r1, =menor_elem_vector
        ldr         r1, [r1]
        mov         r0, #1
        swi         0x6b
        swi         0x11
        .end 