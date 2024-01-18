; LR5, Variant 19
; Author: Osipovskiy DS

.model small
.stack 100h
.data

.code
main:
	mov ax, @data
	mov ds, ax

	mov ax, 4c00h
	int 21h
end main