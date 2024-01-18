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
	_fio db 'Osipovskiy DS', 0ah, 0dh
	_group db 'IUK2-32B'
	_new_line db 0ah, 0dh, '$'
	min_num dw 0
	max_num dw 0

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

	pop bp
	ret 4
p_print_str endp

; --------------------------------------------

p_print_num proc near
; процедура вывода числа
	push bp
	mov bp, sp

	; Code goes here...

	pop bp
	ret
p_print_num endp

; --------------------------------------------

p_input_num proc near
; процедура считывания числа
__res_num	equ [bp]+4

	push bp
	mov bp, sp

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
	cmp [bx]+1, 0
	jne __L1
	jmp __E1

__L1:
; число есть, начинаем перевод
	
	; проверим первый символ, может это минус?
	cmp [bx]+2, '-'
	jne __L2

__L2:
; переводим


__E1:
	pop bp
	ret
p_input_num endp

; ============================================

main:
	mov ax, @data
	mov ds, ax

	m_clear_display
	m_print _fio

	push 0
	call p_input_num

	mov ax, 4c00h
	int 21h
end main