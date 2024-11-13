%include "macros.asm"


section .data
    bienvenida dw "Hola a todos y bienvenidos a nuestro TP. Espero les gueste y se de su agrado. xoxoXOxoOoxX", 0
section .bss
section .text
    global main

    main:
        print bienvenida
        ret