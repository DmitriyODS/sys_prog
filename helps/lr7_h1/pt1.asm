; LR7, Variant 7

.model small
.stack 100h
.data

.code
main:
    mov ax, @data
    mov ds, ax

    push 1234h

    mov ax, 4c00h
    int 21h
end main
