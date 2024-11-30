;INTEGRANTES:
;Oswaldo Maldonado, 110404
;Celeste Lai, 110298
 
%include "macros.asm"

section	.data

	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	;output esperado: "xJQ3lWOiHTyG/CKpPXykUWN8KQSTu2UY"

	largoSecuenciaA		db	0x18 ; 24d
   
    formato_string      db  "%s",0


	secuenciaImprmibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d

	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",0

    largoResultado      db  0x20
	
section	.bss
	secuenciaImprimibleA	resb	32
    resultado               resb    32
	secuenciaBinariaB		resb	24
	
;plan de ataque:
;hago el manejo de bytes de 3 en 3 y voy almacenando en el registro rdi. Cada 3 bytes se guardan 4 bytes en rdi pero todo con 00 al principio. 
;luego paso el registro rdi que va a tener los 32 bytes al decodificador a que traduzca su valor con la tabla
;luego el byte decodificado se guarda en la variable secuenciaImprimibleA
section	.text
global	main

main:
    mov rsi, secuenciaBinariaA          ; Puntero a los datos de entrada
    mov rdi, resultado                  ; Puntero de salida a resultado
    movzx r15, byte [largoSecuenciaA]   ; Número de bytes a procesar 
    cmp r15, 0
    je conversion                       ; si el largo de la secuencia es 0 salta a la parte de conversion
procesar_bytes:
    ; Cargar el primer byte
    mov al, byte [rsi]
    ; Extraer los primeros 6 bits
    and al, 0xFC              ; 0xFC = 1111 1100
    shr al, 2                 ; Desplazar a la derecha 2 bits
    ; Guardar el resultado
    mov [rdi], al
    add rdi, 1                ; Avanzar el puntero de salida
    ; Cargar de nuevo el primer byte
    mov al, byte [rsi]
    ; Extraer los 2 bits más bajos
    and al, 0x03              ; 0x03 = 0000 0011
    shl al, 4                 ; Desplazar a la izquierda 4 bits
    ; Cargar el segundo byte
    mov bl, [rsi+1]
    ; Extraer los 4 bits más altos
    and bl, 0xF0              ; 0xF0 = 1111 0000
    shr bl, 4                 ; Desplazar a la derecha 4 bits
    or  al, bl                ; Combinar con los 2 bits del primer byte
    ; Guardar el resultado
    mov [rdi], al
    add rdi, 1                ; Avanzar el puntero de salida
    ; cargar el segundo byte 
    mov al, [rsi+1]
    ; Extraer los 4 bits mas bajos
    and al, 0x0F              ; 0x0F = 0000 1111
    shl al, 2                 ;desplazar a las izquierda 2 bits
    ; Cargar el tercer byte
    mov bl, [rsi+2]
    ; Extraer los dos bits mas altos
    and bl, 0xC0             ; 0xC0 = 1100 0000
    shr bl, 6                ;desplazar a la derecha 6 bits
    or al, bl                ;combinar los 4 bits del 2do byte con los 2 bits del 3er byte
    ; Guardar el resultado
    mov [rdi], al
    add rdi, 1               ; Avanzar el puntero de salida
    ; Cargar el tercer byte
    mov al, [rsi+2]
    ; Extraer los 6 bits mas bajos
    and al, 0x3F             ; 0x3F = 0011 1111
    ;Guardar el resultado
    mov [rdi], al
    add rdi, 1               ; Avanzar el puntero de salida

    ; Avanzar al siguiente grupo de 3 bytes
    add rsi, 3
    sub r15, 3
    cmp r15, 0               ;si r15 es diferente de 0 significa que todavia faltan grupos de 3 bytes por procesar
     
    jne procesar_bytes

conversion:
    mov rdi, secuenciaImprimibleA
    lea rsi, [TablaConversion]      ;guardo la direccion de la tabla en rsi
    mov rbx, resultado
    mov r15, [largoResultado]
    
bucle:

    movzx r12, byte [rbx]           ;muevo un byte de resultado a r12
    mov al, byte [rsi + r12]        ;obtengo el valor de la tabla en la posicion r12
    mov [rdi], al                   ;guardo en secuenciaImprimibleA el valor de la tabla
    inc rdi
    inc rbx

    sub r15, 1                      ;resto uno al largo del resultado
    
    cmp r15, 0                      ;me fijo si yo obtuve todos los resultados, sino sigo en el bucle
    jne bucle
    
fin:
    mov byte [rdi], 0               ;pongo un 0 al final de la secuenciaImprimibleA
    print formato_string, secuenciaImprimibleA
    ret




    
