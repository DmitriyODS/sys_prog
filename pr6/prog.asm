; PR6, Variant 19
; Author: Osipovskiy DS

.model small
.stack 100h
.data
	a db 1011b
	b db 0010b
	c db 0

.code
main:
	mov ax, @data
	mov ds, ax

	; первое число умножим на 4
	shl a, 2

	; второе разделим на два
	shr b, 1

	; логически сложим результаты
	xor ax, ax
	mov al, a
	mov ah, b
	or ah, al
	mov c, ah

	; поменяем местами 0 и 7 биты местами
	; создадим маску
	mov al, 10000001b
	mov ah, c
	xor ah, al

	mov ax, 4c00h
	int 21h
end main