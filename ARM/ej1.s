.data 

msjSaludo: 
    .asciz      "Hola Mundo!"

.text 


.global _start 

_start: 

    ldr     r0, =msjSaludo
    swi     0x02