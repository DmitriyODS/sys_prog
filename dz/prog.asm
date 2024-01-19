; DZ1; Author: Osipovslkiy DS IUK2-32B

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
	count_m db 0
	count_n db 0

	_fio 			db 'Osipovskiy DS', 0ah, 0dh
	_group 			db 'IUK2-32B'

	_buf_out 		db 5 dup(0)
	_end_buf 		db '$'

	new_line 		db 0ah, 0dh, '$'
	tab_line		db 9h, '$'
	msg_count_m 	db 'Enter count m -> $'
	msg_count_n 	db 'Enter count n -> $'

	msg_task_1		db 'Task A$'
	msg_task_2		db 'Task B$'
	msg_task_3		db 'Task C$'

	msg_enter_val   db 'Enter value $'
	msg_arrow		db ' -> $'

	msg_old_mtrx	db 'Origin mtrx', 0ah, 0dh
					db '======================', 0ah, 0dh, '$'

	msg_new_mtrx	db 'Transform mtrx', 0ah, 0dh
					db '======================', 0ah, 0dh, '$'

	msg_menu		db 0ah, 0dh, 'DZ #1', 0ah, 0dh
					db 'Main menu', 0ah, 0dh
					db '======================', 0ah, 0dh
					db '1. Transform A', 0ah, 0dh
					db '2. Transofrm B', 0ah, 0dh
					db '3. Transform C', 0ah, 0dh
					db '4. Exit program', 0ah, 0dh
					db 'Press need key ...', 0ah, 0dh, '$'

	ptr_mtrx 		dw 0
	ptr_new_mtrx 	dw 0

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

p_init_mtrx proc near
; процедура заполнения матрицы
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	push di

	; вычисляем указатель на новую матрицу
	lea bx, _start_free_mem
	add bx, 8
	mov ptr_mtrx, bx

	; вычисляем указатель на следующую матрицу
	xor ax, ax
	mov al, count_m
	xor cx, cx
	mov cl, count_n

	mul cx
	mov cx, ax
	shl ax, 1
	add bx, ax
	inc bx
	inc bx
	mov ptr_new_mtrx, bx

	xor bx, bx
	inc bx

	; настраиваем di
	mov di, ptr_mtrx

__L1:
; начинаем заполнять
	m_print msg_enter_val
	m_print_num bx
	m_print msg_arrow
	m_input_num
	m_print new_line
	pop dx

	mov word ptr [di], dx
	inc bx
	inc di
	inc di

loop __L1

	pop di
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
p_init_mtrx endp

p_print_mtrx proc near
	arg mn:word, ptr_m:word
; процедура вывода матрицы

	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	push si

	mov cx, mn
	mov bx, cx

	; устаналиваем указатель на матрицу
	mov si, ptr_m

	m_print new_line

__L0:
; проверяем, осталось ли ещё что-то для вывода
	cmp cl, 0
	jne __L1
	jmp __E1

__L1:
	dec cl
	mov ch, bh

__L2:
; выводим матрицу
	xor ax, ax
	mov ax, word ptr [si]
	m_print_num ax
	m_print tab_line
	inc si
	inc si
	dec ch

	cmp ch, 0
	jg __L2

	m_print new_line
	jmp __L0

__E1:
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
p_print_mtrx endp

; --------------------------------------------

m_init_mtrx macro
;; макрос заполнения базовой матрицы
	call p_init_mtrx
endm m_init_mtrx

; --------------------------------------------

m_print_mtrx macro p_mtrx, pos_m, pos_n
;; макрос вывода матрицы
	mov ax, p_mtrx
	push ax

	mov al, pos_m
	mov ah, pos_n
	push ax

	call p_print_mtrx
endm m_print_mtrx

; --------------------------------------------

p_transform_one proc near
max_item equ [bp]-2
; процедура первого преобразования
	push bp
	mov bp, sp

	; выделяем кадр стека (2 байта)
	sub sp, 2

	push ax
	push bx
	push cx
	push dx
	push si
	push di

	m_print new_line
	m_print msg_task_1
	m_print new_line

	; выводим исходную матрицу
	m_print msg_old_mtrx
	m_print_mtrx ptr_mtrx, count_m, count_n
	m_print new_line

	; настраиваем указатели
	mov si, ptr_mtrx
	mov di, ptr_new_mtrx

	; выполняем копирование матрицы
	xor ax, ax
	xor cx, cx
	mov al, count_n
	mov cl, count_m
	mul cx
	mov cx, ax
	cld
	rep movsw

	; начинаем обработку
	mov si, ptr_new_mtrx
	mov di, si
	xor cx, cx
	mov cl, count_n
	mov ch, count_m

__L0:
; проверяем, не кончилась ли матрица
	cmp ch, 0
	jne __L1
	jmp __E0

__L1:
	dec ch
	mov cl, count_n

	; заранее устаналиваем максимальный элемент
	mov ax, word ptr [di]
	mov max_item, ax

__L2:
; ищем максимум
	mov ax, word ptr [di]
	cmp ax, max_item
	jng __L3

	mov max_item, ax

__L3:
	inc di
	inc di
	dec cl

	cmp cl, 0
	jne __L2

	; сохраняем указатель на начало новой строки
	mov bx, di
	dec di
	dec di

	; выполняем преобразование строки
	mov cl, count_n

__L4:
; убеждаемся, что мы на разных сторонах строки
	cmp si, di
	jng __L5
	jmp __L7

__L5:
	mov ax, word ptr [si]
	cmp max_item, ax
	jne __L6

	; меняем местами максимальный и последний
	mov dx, word ptr [di]
	mov word ptr [di], ax
	mov word ptr [si], dx
	dec di
	dec di

__L6:
	inc si
	inc si

	dec cl
	cmp cl, 0
	jne __L4

__L7:
; вертаем всё обратно
	mov si, bx
	mov di, bx

	jmp __L0

__E0:
; матрица построена - выводим
	m_print msg_new_mtrx
	m_print_mtrx ptr_new_mtrx, count_m, count_n
	m_print new_line

__E1:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
p_transform_one endp

p_transform_two proc near
; процедура второго преобразования
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	push si
	push di

	m_print new_line
	m_print msg_task_2
	m_print new_line

	; выводим исходную матрицу
	m_print msg_old_mtrx
	m_print_mtrx ptr_mtrx, count_m, count_n
	m_print new_line

	; настраиваем указатели
	mov si, ptr_mtrx
	mov di, ptr_new_mtrx

	xor cx, cx
	mov cl, count_n
	mov ch, count_m

__L0:
; проверяем, не кончилась ли матрица
	cmp ch, 0
	jne __L1
	jmp __E0

__L1:
; обновляем кол-во строк и столбцов
	dec ch
	mov cl, count_n
	xor dx, dx

__L2:
; копируем элементы в новую матрицу обращая внимание на отрицательность
	mov ax, word ptr [si]

	cmp ax, 0
	js __L3
	jmp __L4

__L3:
; элемент отрицательный, чекаем был ли до него такой
	cmp dx, 0
	jne __L4

	; небыло, пропускаем и запоминаем
	inc dx
	jmp __L5

__L4:
; пишем элемент
	mov word ptr [di], ax
	inc di
	inc di

__L5:
	inc si
	inc si

	dec cl
	cmp cl, 0
	jne __L2
	jmp __L0

__E0:
; матрица построена - выводим
	m_print msg_new_mtrx
	xor dx, dx
	mov dl, count_n
	dec dl
	m_print_mtrx ptr_new_mtrx, count_m, dl
	m_print new_line

__E1:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
p_transform_two endp

p_transform_three proc near
; процедура третьего преобразования
sum_items 		equ [bx]-2
new_count_row 	equ [bx]-4

	push bp
	mov bp, sp

	; создаём кадр стека (4 байта)
	sub sp, 4

	push ax
	push bx
	push cx
	push dx
	push si
	push di

	m_print new_line
	m_print msg_task_3
	m_print new_line

	; выводим исходную матрицу
	m_print msg_old_mtrx
	m_print_mtrx ptr_mtrx, count_m, count_n
	m_print new_line

	; настраиваем указатели
	mov si, ptr_mtrx
	mov di, ptr_new_mtrx

	xor cx, cx
	mov cl, count_n
	mov ch, count_m

	; обнуляем локальные переменные
	xor ax, ax
	mov sum_items, ax
	mov new_count_row, ax

	jmp __L2

__L0:
; проверяем, не кончилась ли матрица
	cmp ch, 0
	jne __L1
	jmp __E0

__L1:
; обновляем кол-во строк и столбцов
	dec ch
	mov cl, count_n

	xor ax, ax
	mov sum_items, ax

__L2:
; копируем элементы в новую матрицу и считаем сумму строки
	mov ax, word ptr [si]
	mov word ptr [di], ax
	add sum_items, ax

	inc si
	inc si
	inc di
	inc di

	dec cl
	cmp cl, 0
	je __L3
	jmp __L2

__L3:
; проверяем сумму
	cmp word ptr sum_items, 0
	jns __L4

	; сумма - отрицательна
	xor ax, ax
	mov al, count_n
	shl ax, 1
	sub di, ax

	jmp __L0

__L4:
; сумма - не отрицательна
	inc word ptr new_count_row
	jmp __L0

__E0:
; матрица построена - выводим
	dec word ptr new_count_row
	m_print msg_new_mtrx
	m_print_mtrx ptr_new_mtrx, new_count_row, count_n
	m_print new_line

__E1:
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	ret
p_transform_three endp

main:
	mov ax, @data
	mov ds, ax
	mov es, ax

	; чистим экран
	m_clear_display

	; представляемся
	m_print _fio
	m_print new_line

	; просим ввести кол-во строк
	m_print msg_count_m
	m_input_num
	pop ax
	m_print new_line
	mov count_m, al

	; просим ввести кол-во столбцов
	m_print msg_count_n
	m_input_num
	pop ax
	m_print new_line
	mov count_n, al

	; заполняем матрицу
	m_init_mtrx

__L1:
	m_print msg_menu

	; ожидаем комманду
	mov ax, 1000h
	int 16h

	cmp al, '1'
	jne __L2

	; выполняем первое действие
	call p_transform_one

__L2:
	cmp al, '2'
	jne __L3

	; второе преобразование
	call p_transform_two

__L3:
	cmp al, '3'
	jne __L4

	; третье преобразование
	call p_transform_three

__L4:
	cmp al, '4'
	je __L5
	jmp __L1

__L5:
	mov ax, 4c00h
	int 21h
end main