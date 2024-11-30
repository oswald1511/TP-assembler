%macro print 2
    mov rdi, %1
    mov rsi, %2
    sub rsp, 8
    call printf 
    add rsp, 8
%endmacro

extern printf
