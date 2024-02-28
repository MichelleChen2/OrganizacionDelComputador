# Mostrar cálculos aritméticos y lógicos
# Escribir el código ARM que ejecutado bajo ARMSim# realice las siguientes operaciones
# aritméticas y lógicas sobre dos enteros almacenados en un archivo: Suma, Resta,
# Multiplicación, AND, OR, XOR, Shift Izquierda, Shift Derecha, Shift Derecha Aritmética. Imprimir
# por pantalla los resultados de las operaciones en sus propias líneas.

#            .equ        Stdout, 1

#            .data 
# fileName: 
#        .asciz      "dos_enteros.txt"

    

# eol: 
#        .asciz      "\n"
#        .align 

# inFileHandle: 
#        .word       0

#        .text 
#        .global     _start 

# _start: 

#        ldr         r0, =fileName
#        mov         r1, #0          # Modo de Apertura
#        swi         SWI_Open_File

#        bcs         inFileError    # Si el bit de carry queda encendido 
                                   # bifurco al InFileError

#        ldr         r1, =inFileHandle
#        str         r0, [r1]        # str = store -> Se guarda en la dir en r1 el handler del archivo

#        bl          read_int 
#        mov         r2, r0 
#        bl          read_int 
#        mov         r3, r0 

#        add         r1, r2, r3 
#        bl          printf_r1_int

# read_int: 

#        stmfd       sp!, {lr}

#        ldr         r0, =inFileHandle
#        ldr         r0, [r0]
#        swi         SWI_Read_Out 

#        ldmfd       sp! {pc}

# print_r1_int: 
#        stmfd       sp!, {r0, r1, lr}

#        ldr         r0, =Stdout
#        swi         SWI_Print_Int
#        ldr         r1, =eol 
#        swi         SWI_Print_Str 

#        ldmfd       sp!, {r0, r1, pc} 

#    .end   


# las siguientes operaciones
# aritméticas y lógicas sobre dos enteros almacenados en un archivo: Suma, Resta,
# Multiplicación, AND, OR, XOR, Shift Izquierda, Shift Derecha, Shift Derecha Aritmética. Imprimir
# por pantalla los resultados de las operaciones en sus propias líneas.

        .data 

FileName: 
        .asciz      "entero.txt"
        .align 
ErrorOpenFile: 
        .asciz      "Error Open File"
        .align 
InFileHandle: 
        .word        0
Integers: 
        .word        0, 0
Sum: 
        .word        0
Substraction: 
        .word        0
Multiplication: 
        .word        0
Operation_And:
        .word        0
Operation_Or:
        .word        0
Operation_Xor:
        .word        0
Operation_Sl:
        .word        0
Operation_Sr:
        .word        0
Operation_Sra:
        .word        0
        .text 
        .global _start 
_start: 

        bl        Open_File

        bl        Read_Int 

        bl        Close_File

        ldr       r1, =Integers
        ldr       r1, [r1]
        mov       r0, #1
        swi       0x6b

        ldr       r1, =Integers
        ldr       r1, [r1, #4]
        mov       r0, #1
        swi       0x6b

        bl         Sumation

        ldr        r1, =Sum 
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        bl         Subs

        ldr        r1, =Substraction 
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        bl         Multiply

        bl         Op_And

        ldr        r1, =Operation_And
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        bl         Op_Or

        ldr        r1, =Operation_Or
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        bl         Op_Xor

        ldr        r1, =Operation_Xor
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        bl         Op_SL

        ldr        r1, =Operation_Sl
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b
        
        bl         Op_Sr

        ldr        r1, =Operation_Sr
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b

        bl         Op_Sra 

        ldr        r1, =Operation_Sra
        ldr        r1, [r1]
        mov        r0, #1
        swi        0x6b     

        swi        0x11

Open_File: 

        stmfd      sp!, {r0, lr}

        ldr        r0, =FileName
        mov        r1, #0
        swi        0x66
        bcs        EOL 

        ldr        r5, =InFileHandle
        str        r0, [r5]

        ldmfd      sp!, {r0, pc}

Close_File:

        stmfd      sp!, {lr}

        ldr        r0, =InFileHandle
        ldr        r0, [r0]
        swi        0x68

        ldmfd      sp!, {pc}

Read_Int:

        stmfd      sp!, {lr}

        ldr        r5, =Integers
Read_Each_Int: 

        ldr        r0, =InFileHandle
        ldr        r0, [r0]
        swi        0x6c
        bcs        End_Reding        

        str        r0, [r5]
        add        r5, r5, #4

        b          Read_Each_Int

End_Reding:
        ldmfd      sp!, {pc}

Sumation: 

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        add         r7, r5, r6

        ldr         r0, =Sum 
        str         r7, [r0]

        ldmfd       sp!, {pc}

Subs: 
        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        sub         r7, r5, r6

        ldr         r0, =Substraction
        str         r7, [r0]

        ldmfd       sp!, {pc}

Multiply: 

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        mul         r7, r5, r6

        ldr         r0, =Multiplication
        str         r7, [r0]

        ldmfd       sp!, {pc}

Op_And: 

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        and         r7, r5, r6

        ldr         r0, =Operation_And
        str         r7, [r0]

        ldmfd       sp!, {pc}

Op_Or: 

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        orr         r7, r5, r6

        ldr         r0, =Operation_Or
        str         r7, [r0]

        ldmfd       sp!, {pc}

Op_Xor:

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        orr         r7, r5, r6

        ldr         r0, =Operation_Xor
        str         r7, [r0]

        ldmfd       sp!, {pc}

Op_SL:

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        mov         r7, r5, LSL r6

        ldr         r0, =Operation_Sl
        str         r7, [r0]

        ldmfd       sp!, {pc}

Op_Sr:

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        mov         r7, r5, LSR r6

        ldr         r0, =Operation_Sr
        str         r7, [r0]

        ldmfd       sp!, {pc}

Op_Sra:

        stmfd       sp!, {lr}

        ldr         r5, =Integers
        ldr         r5, [r5]

        ldr         r6, =Integers 
        add         r6, r6, #4
        ldr         r6, [r6]

        mov         r7, r5, ASR r6

        ldr         r0, =Operation_Sra
        str         r7, [r0]

        ldmfd       sp!, {pc}

EOL: 
        ldr        r0, =ErrorOpenFile
        swi        0x02
        swi        0x11
        .end