; PR5
; Author: Osipovskiy DS

; Базовые макросы
; ====================================

m_print_str macro cur_string
;; макрос вывода на экран строки
	push ax
	push dx

	mov ax, 900h
	lea dx, cur_string
	int 21h

	pop dx
	pop ax
endm m_print_str

m_read_ax macro buffer, size
	local _input, _start_of_convert, _end_of_convert

	push bx
	push cx
	push dx

_input:
	mov [buffer], size
	lea dx, [buffer]
	mov ah, 0ah
	int 21h

	mov ah, 2h
	mov dl, 0dh
	int 21h

	xor ah, 0ah
	cmp ah, [buffer][1]
	jz _input

	xor cx, cx
	mov cl, [buffer][1]

	xor ax, ax
	xor bx, bx
	xor dx, dx
	lea bx, [buffer][2]

	cmp [buffer][2], '-'
	jne _start_of_convert
	inc bx
	dec cl

_start_of_convert:
	mov dx, 10
	mul dx
	cmp ax, 8000h
	jae _input

	mov dl, [bx]
	sub dl, '0'

	add ax, dx
	cmp ax, 8000h
	jae _input

	inc bx
	loop _start_of_convert

	cmp [buffer][2], '-'
	jne _end_of_convert
	neg ax

_end_of_convert:
	pop dx
	pop cx
	pop bx

endm m_read_ax

m_write_ax macro
local _convert, _write

	push ax
	push bx
	push cx
	push dx
	push di

	mov cx, 10
	xor di, di

	or ax, ax
	jns _convert
	push ax

	mov dx, '-'
	mov ah, 2h
	int 21h

	pop ax
	neg ax

_convert:
	xor dx, dx

	div cx
	add dl, '0'
	inc di

	push dx

	or ax, xa
	jnz _convert

_write:
	pop dx

	mov ah, 2h
	int 21h
	dec di
	jnz _write

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
endm m_write_ax

; ====================================

.model small
.stack 100h
.data
	START_NUM equ -100
	END_NUM equ 101
	msg_1 db "Enter an integer number A, count symbol: 1-2 -> $"
	msg_2 db "Enter an integer number B, count symbol: 1-2 -> $"
	msg_3 db ": Y = $"
	err_msg_1 db "An overflow occurred with the input data", 0dh, 0ah, '$'
	newline db 0dh, 0ah, '$'
	var_a dw 0
	var_b dw 0
	var_y dw 0
	buffer db 6
	buf_size db 0
	buf_content db 4 dup('$'), '$'
	s_out_buf db 15 dup(' ')
	e_out_buf db " $ " 

.code
main:
	mov ax, @data
	mov ds, ax

	print macro string
		mov ax, 0900h
		mov dx, offset string
		int 21h
	endm

	input macro
		mov ax, 0a00h
		mov dx, offset buffer
		int 21h
	endm

	mov ax, @data
	mov ds, ax

	; запрашиваем первое число
	print msg_1
	input
	print newline

	; записываем в переменную A
	call parse_to_var
	mov var_a, cx

	; запрашиваем второе число
	print msg_2
	input
	print newline

	; записываем в переменную B
	call parse_to_var
	mov var_b, cx

	; подсчёт выражения
	; b = b+2
	mov ax, var_b
	add ax, 6
	mov var_b, ax

	; организуем цикл по заданному диапозону от -100 до 100
	mov cx, START_NUM

for_1:
	mov ax, cx
	call print_num
	print msg_3

	xor ax, ax
	xor bx, bx
	xor dx, dx

	; Y = A*X
	mov ax, cx
	imul var_a
	jo overflow_1
	mov var_y, ax

	; Y = (X*X - A*X) / B
	mov ax, cx
	imul cx
	jo overflow_1
	sub ax, var_y
	idiv var_b
	mov var_y, ax

	; ax = X*X*X / 3
	mov ax, cx
	imul cx
	jo overflow_1
	imul cx
	jo overflow_1

	mov bx, 3
	idiv bx

	; Y = Y - ax
	sub var_y, ax

	; выводим значение Y на консоль
	mov ax, var_y
	call print_num

	print newline
	jmp end_for_1

overflow_1:
	clc
	print err_msg_1

end_for_1:
	inc cx
	cmp cx, END_NUM+1
	je break_for_1
	jmp for_1

break_for_1:
	mov ax, 4c00h
	int 21h

	; процедура печати на экран числа до 16 знаков включая знак числа
	; число лежит в ax
print_num proc
	push ax
	push bx
	push cx
	push dx

	mov bx, 10
	mov si, offset e_out_buf
	test ax, ax
	jns loop_print

convert_neg:
	neg ax
	mov e_out_buf[2], '-'

loop_print:
	xor dx, dx
	div bx
	add dl, '0'
	mov [si], dl
	dec si
	cmp ax, 0
	jne loop_print

	mov al, e_out_buf[2]
	mov [si], al
	mov e_out_buf[2], ' '
	print s_out_buf

	; чистим буффер вывода
	mov cx, 16
	mov si, offset s_out_buf
	
loop_clear:
	mov byte ptr [si], ' '
	inc si
	loop loop_clear

	pop dx
	pop cx
	pop bx
	pop ax
	ret
print_num endp

	; процедура парсинга в CX положительного числа из буффера ввода
parse_to_var proc
	push ax
	push bx

	xor cx, cx
	xor ax, ax
	mov bx, 10
	mov ax, word ptr buf_content

	cmp al, 0dh
	je end_parse

	sub al, 30h
	mov cl, al

	cmp ah, 0dh
	je end_parse

	sub ah, 30h
	mov cl, ah
	xor ah, ah
	mul bl
	add cl, al
end_parse:
	pop bx
	pop ax
	ret
parse_to_var endp
end main