;INTEGRANTES:
;Oswaldo Maldonado, 110404
;Celeste Lai, 110298
 
%include "macros.asm"

section	.data
; Casos de prueba:
; SecuenciaBinariaDePrueba db	0x73, 0x38, 0xE7, 0xF7, 0x34, 0x2C, 0x4F, 0x92
;						   db	0x49, 0x55, 0xE5, 0x9F, 0x8E, 0xF2, 0x75, 0x5A 
;						   db	0xD3, 0xC5, 0x53, 0x65, 0x68, 0x52, 0x78, 0x3F
; SecuenciaImprimibleCodificada	db	"czjn9zQsT5JJVeWfjvJ1WtPFU2VoUng/"

; SecuenciaImprimibleDePrueba db "Qy2A2dhEivizBySXb/09gX+tk/2ExnYb"
; SecuenciaBinariaDecodificada	db	0x43, 0x2D, 0x80, 0xD9, 0xD8, 0x44, 0x8A, 0xF8 
;								db	0xB3, 0x07, 0x24, 0x97, 0x6F, 0xFD, 0x3D, 0x81 
;								db	0x7F, 0xAD, 0x93, 0xFD, 0x84, 0xC6, 0x76, 0x1B
 
; Un codificador/decodificador online se puede encontrar en https://www.rapidtables.com/web/tools/base64-encode.html
	
	secuenciaBinariaA	db	0xC4, 0x94, 0x37, 0x95, 0x63, 0xA2, 0x1D, 0x3C 
						db	0x86, 0xFC, 0x22, 0xA9, 0x3D, 0x7C, 0xA4, 0x51 
						db	0x63, 0x7C, 0x29, 0x04, 0x93, 0xBB, 0x65, 0x18 
	largoSecuenciaA		db	0x18 ; 24d
	;output esperado: "xJQ3lWOiHTyG/CKpPXykUWN8KQSTu2UY"

	secuenciaImprmibleB db	"vhyAHZucgTUuznwTDciGQ8m4TuvUIyjU"
	largoSecuenciaB		db	0x20 ; 32d

	TablaConversion		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    bytes db 0xAA, 0xBB, 0xCC  ; Ejemplo de 3 bytes

	
section	.bss
	secuenciaImprimibleA	resb	32
    resultado               resb    32
	secuenciaBinariaB		resb	24
	
;plan de ataque:
;hago el manejo de bytes de 3 en 3 y voy almacenando en el registro rdi. Cada 3 bytes se guardan 4 bytes en rdi pero todo con 00 al principio, se entiende? si no se entiende, me preguntas. Esa parte esta hecha aunque no compila, pero la logica esta.
;luego paso el registro rdi que va a tener los 32 bytes al decodificador a que traduzca su valor con la tabla
;luego el byte decodificado se guarda en la variable secuenciaImprimibleA
section	.text
global	main

main:
    mov rsi, bytes                      ; Puntero a los datos de entrada
    mov rdi, secuenciaImprimibleA                          ; Puntero de salida 
    movzx rax, byte [largoSecuenciaA]   ; Número de bytes a procesar 
    cmp rax, 0
    je final_programa                   ; si el largo de la secuencia es 0 salta al final del programa
procesar_bytes:
    ; Cargar el primer byte
    mov al, byte [rsi]
    ; Extraer los primeros 6 bits
    and al, 0xFC              ; 0xFC = 1111 1100
    shr al, 2               ; Desplazar a la derecha 2 bits
    ; Guardar el resultado
    mov [rdi], al
    add rdi, 1               ; Avanzar el puntero de salida
    ; Cargar de nuevo el primer byte
    mov al, byte [rsi]
    ; Extraer los 2 bits más bajos
    and al, 0x03              ; 0x03 = 0000 0011
    shl al, 4               ; Desplazar a la izquierda 4 bits
    ; Cargar el segundo byte
    mov bl, [rsi+1]
    ; Extraer los 4 bits más altos
    and bl, 0xF0              ; 0xF0 = 1111 0000
    shr bl, 4               ; Desplazar a la derecha 4 bits
    or  al, bl               ; Combinar con los 2 bits del primer byte
    ; Guardar el resultado
    mov [rdi], al
    add rdi, 1             ; Avanzar el puntero de salida
    ; cargar el segundo byte 
    mov al, [rsi+1]
    ; Extraer los 4 bits mas bajos
    and al, 0x0F        ; 0x0F = 0000 1111
    shl al, 4           ;desplazar a las izquierda 4 bits
    ; Cargar el tercer byte
    mov bl, [rsi+2]
    ; Extraer los dos bits mas altos
    and bl, 0xC0        ; 0xC0 = 1100 0000
    shr bl, 6           ;desplazar a la derecha 6 bits
    or al, bl           ;combinar los 4 bits del 2do byte con los 2 bits del 3er byte
    ; Guardar el resultado
    mov [rdi], al
    add rdi, 1         ; Avanzar el puntero de salida
    ; Cargar el tercer byte
    mov al, [rsi+2]
    ; Extraer los 6 bits mas bajos
    and al, 0x3F        ; 0x3F = 0011 1111
    ;Guardar el resultado
    mov [rdi], al
    add rdi, 1     ; Avanzar el puntero de salida

    ; Avanzar al siguiente grupo de 3 bytes
    add rsi, 3
    sub rax, 3
    cmp rax, 0              ;si rax es diferento de 0 significa que todavia faltan grupos de 3 bytes por procesar
    jne procesar_bytes

final_programa:
    ret
