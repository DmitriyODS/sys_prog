; LR8, Variant 19
; Author: Osipovskiy DS

; Системные константы
; ============================================

BIOS_SEG_DATA 	equ 40h
PROC_INT_1C		equ 1ch
PROC_INT_1A		equ 1ah
VIDEO_MEM		equ 0b800h

; ============================================

locals __
.model small
.stack 100h
.data
	direct 		db 1
	out_sym 	db '#'
	ex_prog		db 0
	atr_sym_1	db 14
	atr_sym_2	db 10

	start_pos 	dw 2840
	ptr_cs 		dw 0
	ptr_ip 		dw 0

	_fio 			db 'Osipovskiy DS', 0ah, 0dh
	_group 			db 'IUK2-32B'
	_new_line 		db 0ah, 0dh, '$'

.code

; процедура обработки прерывания 1Ch
; ============================================

p_procesing_1c proc far
	push bp
	mov bp, sp

	push ax
	push bx
	push cx
	push dx
	push ds
	push es

	mov ax, @data
	mov ds, ax

	mov ax, BIOS_SEG_DATA
	mov es, ax

	mov ax, es:[PROC_INT_1C]
	mov bx, es:[PROC_INT_1A]
	cmp bx, ax
	jne __L1
	jmp __E1

__L1:
	mov al, es:[bx]
	mov es:[PROC_INT_1C], bx
	cmp al, 30h
	jnz __L2
	mov ex_prog, 1
	jmp __E1

__L2:
	cmp al, 35h
	jne __L3
	mov dl, atr_sym_1
	mov dh, atr_sym_2
	mov atr_sym_1, dh
	mov atr_sym_2, dl
	jmp __E1

__L3:
; определяем нажатие кнопки
	cmp al, '8'
	jne __L4

	mov direct, 8
	jmp __E1

__L4:
	cmp al, '2'
	jne __L5

	mov direct, 2
	jmp __E1

__L5:
	cmp al, '4'
	jne __L6

	mov direct, 4
	jmp __E1

__L6:
	cmp al, '6'
	jne __E1

	mov direct, 6

__E1:
	pop es
	pop ds
	pop dx
	pop cx
	pop bx
	pop ax

	mov sp, bp
	pop bp
	iret
p_procesing_1c endp

; ============================================

; Базовые процедуры
; ============================================

p_delay proc near
; процедура задержки
	push bp
	mov bp, sp
	push cx

	mov cx, 10

__L1:
	push cx
	xor cx, cx

__L2:
	nop
loop __L2

	pop cx
loop __L1

	pop cx
	mov sp, bp
	pop bp
	ret
p_delay endp

; --------------------------------------------

p_cls proc near
; процедура очистики экрана
	push bp
	mov bp, sp

	push cx
	push ax
	push si

	xor si, si
	mov ah, 7
	mov dl, ''
	mov cx, 2000

__L1:
	mov es:[si], ax
	inc si
	inc si
loop __L1

	pop si
	pop ax
	pop cx

	mov sp, bp
	pop bp
	ret
p_cls endp

; --------------------------------------------

p_print_sym proc near
; процедура вывода символа с заданным аттрибутом
	push bp
	mov bp, sp
	push ax
	push bx

	mov al, out_sym
	mov ah, atr_sym_1
	mov bx, start_pos
	call p_delay

	mov es:[bx], ax

	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret
p_print_sym endp

; ============================================

main:
	mov ax, @data
	mov ds, ax

	; сохранение старых прерываний
	mov ah, 35h
	mov al, PROC_INT_1C
	int 21h

	mov ptr_ip, bx
	mov ptr_cs, es

	; установка новых прерываний
	push ds
	lea dx, p_procesing_1c
	mov ax, seg p_procesing_1c
	mov ds, ax

	mov ah, 25h
	mov al, PROC_INT_1C
	int 21h

	pop ds
	mov ax, VIDEO_MEM
	mov es, ax

	call p_cls
	call p_delay

__L1:
; выполняем проверки
	cmp ex_prog, 0
	je __L2
	jnp __E1

__L2:
	cmp direct, 8
	jne __L3

	mov ax, start_pos
	sub ax, 160
	jl __L2_1

	mov start_pos, ax
	call p_print_sym

__L2_1:
	jmp __L1

__L3:
	cmp direct, 4
	jne __L4

	mov ax, start_pos
	sub ax, 2
	jl __L3_1

	mov start_pos, ax
	call p_print_sym

__L3_1:
	jmp __L1

__L4:
	cmp direct, 6
	jne __L5

	mov ax, start_pos
	add ax, 2
	jg __L4_1

	mov start_pos, ax
	call p_print_sym

__L4_1:
	jmp __L1

__L5:
	mov ax, start_pos
	add ax, 160
	cmp ax, 3999
	jg __L5_1

	mov start_pos, ax
	call p_print_sym

__L5_1:
	jmp __L1

__E1:
	call p_cls
	mov dx, ptr_ip
	mov ax, ptr_cs
	mov dx, ax

	mov ah, 25h
	mov al, PROC_INT_1C
	int 21h

	mov ax, 4c00h
	int 21h
end main
