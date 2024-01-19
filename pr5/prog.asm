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

m_set_cursor macro row, col
;; макрос установки курсора в нужную позицию
	push ax
	push bx
	push cx
	push dx

	mov ax, 600h
	mov bh, 7
	xor cx, cx
	mov dx, 184fh
	int 10h

	mov ah, 2
	xor bh, bh
	mov dh, row
	mov dl, col
	int 10h

	pop dx
	pop cx
	pop bx
	pop ax
endm m_set_cursor

; ====================================

.model small
.stack 100h
.data
	msg1 db "Hard is the first step.$"
	msg2 db "Varro, Mark Terence$"
	msg3 db "116-27 years. BC$"
	forname db "Osipovskiy$"
	num_group db "IUK2-32B$"
	name_focult db "IUK$"
	symbol db 5 dup("!"), "$"

.code
main:
	mov ax, @data
	mov ds, ax

	; установка видеорежима 16 цветов
	; функция 00 и 03 - текстовый режим 80x25
	mov ax, 0003h
	int 10h

	; установка цвета (синий на светло-сером)
	mov bx, 1700h
	int 10h

	; курсор слева
	m_set_cursor 0 0
	m_print_str forname

	; курсор справа
	m_set_cursor 0 47h
	m_print_str num_group

	; курсор снизу слева
	m_set_cursor 17h 0
	m_print_str name_focult

	; курсор снизу справа
	m_set_cursor 17h 4ah
	m_print_str symbol

	; курсор в центре
	m_set_cursor 0ch 1bh
	m_print_str msg1

	; курсор в центре
	m_set_cursor 0dh 1bh
	m_print_str msg2

	; курсор в центре
	m_set_cursor 0eh 1bh
	m_print_str msg3

	; возвращаем курсор
	m_set_cursor 17h 0
	m_print_str msg3

	; завершаем программу
	mov ax, 4c00h
	int 21h
end main