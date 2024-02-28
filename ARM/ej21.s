# Práctica 21: Calcular y almacenar suma de una constante a un vector

# Escribir el código ARM que ejecutado bajo ARMSim# lea los valores de un vector ( vector ) de
# longitud long_vector , sume un valor específico ( valor ) y guarde el resultado en otro vector
# ( vector_suma ).

        .data 
vector: 
        .word   0,1,2,3,4
long_vector: 
        .word   5
valor: 
        .word   1
vector_suma:
        .word   0,0,0,0,0

        .text 
        .global _start 
_start: 

        mov      r5, #0

        ldr      r4, =long_vector
        ldr      r4, [r4]

        mov      r7, #4
        mul      r6, r4, r7

sumar_elemento_vector: 

        ldr     r0, =vector 
        ldr     r0, [r0, r5]

        ldr     r2, =valor 
        ldr     r2, [r2]
        add     r0, r0, r2 

        ldr     r3, =vector_suma  
        add     r3, r3, r5 

        str     r0, [r3]

        add     r5, r5, #4
        cmp     r6, r5
        bgt     sumar_elemento_vector

        mov     r5, #0

imprimir_vector_suma: 

        ldr     r1, =vector_suma
        ldr     r1, [r1, r5]
        mov     r0, #1
        swi     0x6b

        add     r5, r5, #4
        cmp     r6, r5 
        bgt     imprimir_vector_suma
        swi     0x11
        .end