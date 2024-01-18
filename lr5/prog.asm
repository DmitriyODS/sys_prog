; LR5, Variant 19
; Author: Osipovskiy DS

; базовые макросы
; ============================================

m_print macro string
;; вывод строки на экран через 9h int21h
	push ax
	push dx

	mov ax, 900h
	lea dx, string
	int 21h

	pop dx
	pop ax
endm m_print

; ---------------------------------------------

m_push_all macro
;; отправить в стек все доступные регистры
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
endm m_push_all

; ---------------------------------------------

m_pop_all macro
;; забрать из стека все доступные регистры (после m_push_all)
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
endm m_pop_all

m_clear_display macro
;; очистка экрана
	push ax
	push cx
	push dx

	mov ax, 0f00h
	int 10h

	xor ah, ah
	int 10h

	pop dx
	pop cx
	pop ax
endm m_clear_display

; ============================================

locals __
.model small
.stack 100h
.data
	_fio 			db 'Osipovskiy DS', 0ah, 0dh
	_group 			db 'IUK2-32B'
	_new_line 		db 0ah, 0dh, '$'
	_buf_out 		db 5 dup(0)
	_end_buf 		db '$'
	_msg_input 		db 'Enter N -> $'
	_msg_enter_nums db 'Enter values $'
	_msg_arrow 		db ' -> $'
	_msg_min		db 'Minimum: $'
	_msg_max		db 'Maximum: $'

	min_num dw 9999
	max_num dw -9999

.data?
    _start_free_mem label byte

.code

; базовые процедуры
; ============================================

p_print_str proc near
; процедура вывода текста в нужную позицию
__a_pos 	equ [bp]+4
__ptr_str 	equ [bp]+6

	push bp
	mov bp, sp

	push ax
	push bx
	push dx

	; устанавливаем позицию курсора
	; в DH - строка начала 	(24)
	; в DL - колонка начала (79)
	mov dx, __a_pos
	mov ax, 200h
	xor bx, bx
	int 10h

	; сам вывод
	mov ax, 900h
	mov dx, __ptr_str
	int 21h

	pop dx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret 4
p_print_str endp

; --------------------------------------------

p_print_num proc near
; процедура вывода числа
__out_num		equ [bp]+4
__check_minus 	equ [bp]-2

	push bp
	mov bp, sp

	; выделяем кадр стека под локальные переменные (2 байта)
	sub sp, 2

	push ax
	push bx
	push cx
	push dx

	; настраиваем адрес, куда пишем
	lea bx, _end_buf

	mov ax, word ptr __out_num
	mov word ptr __check_minus, 0
	mov cx, 10

	; проверяем на нуль
	cmp ax, 0
	jne __L0

	dec bx
	mov byte ptr [bx], '0'
	jmp __E1

__L0:
; проверим, отрицательно ли число
	jns __L1

	; отрицательное, записываем знак и инвертируем
	mov word ptr __check_minus, '-'
	neg ax

__L1:
; проверяем, что число ещё есть
	cmp ax, 0
	jne __L2
	jmp __L3

__L2:
; число есть, переводим
	xor dx, dx
	dec bx

	div cx
	add dx, '0'
	mov byte ptr [bx], dl

	jmp __L1

__L3:
; чекаем минус
	cmp word ptr __check_minus, '-'
	jne __E1

	dec bx
	mov byte ptr [bx], '-'

__E1:
; выводим и выходим
	mov ax, 900h
	mov dx, bx
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret 2
p_print_num endp

; --------------------------------------------

p_input_num proc near
; процедура считывания числа
__res_num	equ [bp]+4

	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx

	; настраиваем буфер
	lea dx, _start_free_mem
	lea bx, _start_free_mem

	; запрещаем вводить больше 5
	mov byte ptr [bx], 6

	; вызываем ввод
	mov ax, 0a00h
	int 21h

	; устанавливаем допустимое кол-во цифр (4)
	mov cx, 4

	; проверяем кол-во считанных символов
	cmp byte ptr [bx]+1, 0
	jne __L1
	jmp __E1

__L1:
; число есть, начинаем перевод
	; сдвигаемся на первый символ
	inc bx
	inc bx

	; проверим первый символ, может это минус?
	cmp byte ptr [bx], '-'
	jne __L2

	; минус, сдвигаемся
	inc bx

__L2:
; проверим, что это не конец ...
	cmp byte ptr [bx], 0dh
	jne __L3

	; это всё-таки конец ...
	jmp __L4

__L3:
; сдвинем число в результате, если оно уже там лежит
	mov ax, 10
	mul word ptr __res_num
	mov __res_num, ax

	; уберём за собой
	xor ax, ax
	xor dx, dx

	; переводим
	mov al, byte ptr [bx]
	sub al, '0'
	add __res_num, ax

	inc bx

	loop __L2

__L4:
; проверим первый символ, может это минус?
	cmp byte ptr _start_free_mem+2, '-'
	jne __E1

	; инвертируем результат
	mov ax, word ptr __res_num
	neg ax
	mov word ptr __res_num, ax

__E1:
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
p_input_num endp

; ============================================

; Макросы работы с процедурами
; ============================================

m_input_num macro
;; макрос ввода числа, кладёт его в буфер
	mov ax, 0
	push ax
	call p_input_num
endm m_input_num

m_print_num macro num
;; макрос вывода числа
	push ax

	mov ax, num
	push ax
	call p_print_num

	pop ax
endm m_print_num

; ============================================

; задание ЛР №5
; ============================================

p_lr5 proc near
; процедура выполнения задания ЛР5 19 вариант
	push bp
	mov bp, sp

	; просим ввести число
	m_print _msg_input
	m_input_num
	m_print _new_line

	; записываем число
	pop cx
	mov dx, 1

	; проверяем на нуль
	cmp cx, 0
	jne __L1
	jmp __E1

__L1:
; ввели не нуль, просим числа
	m_print _msg_enter_nums
	m_print_num dx
	m_print _msg_arrow

	m_input_num
	m_print _new_line

	pop ax
	inc dx

	; проверим, может это новый максимум
	cmp ax, max_num
	jng __L2
	mov max_num, ax

__L2:
; проверим, может это новый минимум
	cmp min_num, ax
	jng __L3
	mov min_num, ax

__L3:
; идём дальше вводить числа
	loop __L1

	; выводим минимум
	m_print _new_line
	m_print _msg_min
	m_print_num min_num
	m_print _new_line

	; выводим максимум
	m_print _msg_max
	m_print_num max_num
	m_print _new_line

__E1:
	mov sp, bp
	pop bp
	ret
p_lr5 endp

; ============================================

main:
	mov ax, @data
	mov ds, ax

	; пишем, что мы - это мы
	m_clear_display
	m_print _fio

	; само задание реализовано в отдельной процедуре
	call p_lr5


	mov ax, 4c00h
	int 21h
end main