%macro print 1
    mov rdi, %1
    sub rsp, 8
    call printf 
    add rsp, 8
%endmacro

extern printf
extern scanf