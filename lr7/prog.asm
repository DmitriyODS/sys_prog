; LR7, Variant 19

; объявление макросов
; =================================================

; дескриптор консоли
STDOUT equ 1h

; размер файлового буфера
FILE_BUF_CAP equ 100h

m_print macro string
;; вывод строки на экран
    push ax
    push dx
    
    mov ax, 900h
    lea dx, string
    int 21h
    
    pop dx
    pop ax
endm m_print

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

; =================================================

.model small
.stack 100h
.data
    txt_err_1 db 'Need filename in args', '$'
    txt_err_2 db 'File not found', '$'

    new_line db 0dh, 0ah, '$'

    ptr_file_in dw 0
    filename_in_size db 0
    filename_in db 10h dup(0), 0, '$'

    ptr_file_out dw 0
    filename_out_size db 7
    filename_out db 'res.txt', 0, '$'

    ptr_start_fb dw 0
    file_buf_len dw 0

    count_strings dw 0

    ptr_new_string dw 0
    new_string_len dw 0

    ptr_edited_string dw 0
    edited_string_len dw 0

.data?
    file_buf label byte

.code
    locals __
; объявление процедур
; =================================================

p_scan_fn proc near
; получить имя файла из параметра командной строки
    push bp
    mov bp, sp

    m_push_all
    push ds

    ; получим адрес PSP
    mov ax, 6200h
    int 21h

    ; настраиваем сегмент
    mov ds, bx
    mov si, 80h

    xor cx, cx
    mov cl, [si]

    cmp cl, 0
    je __L1

    dec cl
    inc si

__L1:
    mov es:[filename_in_size], cl

    inc si

    ; копируем имя файла
    lea di, filename_in
    cld
    rep movsb

    pop ds
    m_pop_all

    pop bp
    ret
p_scan_fn endp

; --------------------------------------------------

p_scan_sf proc near
; получить следующую строку из файла
    push bp
    mov bp, sp

    m_push_all

    ; обнуляем длину старой строки
    mov new_string_len, 0

    ; проверяем размер буфера
    cmp file_buf_len, 0
    jg __L1
    jmp __L2

__L1:
; в буфере есть данные
    ; ищем перевод строки
    mov di, ptr_start_fb
    mov cx, file_buf_len
    mov ax, 0ah
    cld
    repne scasb

    ; временно сохраняем результат поиска
    pushf
    push di
    push cx

    ; запишем строку
    mov si, ptr_start_fb
    mov di, ptr_new_string
    add di, new_string_len

    mov ax, file_buf_len
    sub ax, cx
    mov cx, ax
    add new_string_len, cx

    cld
    rep movsb

    ; достаём результат поиска
    pop cx
    pop di
    popf

    ; записываем новые данные
    mov ptr_start_fb, di
    mov file_buf_len, cx

    ; проверим, почему остановились
    jne __L2
    jmp __E1

__L2:
; буфер пуст, пополняем из файла
    mov ax, 3f00h
    mov bx, ptr_file_in
    mov cx, FILE_BUF_CAP
    lea dx, file_buf

    ; возвращаем указатель на начало буфера
    mov ptr_start_fb, dx

    int 21h

    ; записываем реальное кол-во байт в буфере
    mov file_buf_len, ax

    ; проверим файл на пустоту
    cmp ax, 0
    je __E1
    jmp __L1

__E1:
    ; проверим, записали ли что-то в строку
    cmp new_string_len, 0
    je __E2

    ; записали, увеличиваем кол-во считанных строк
    inc count_strings

__E2:
    m_pop_all
    mov sp, bp
    pop bp
    ret
p_scan_sf endp

; --------------------------------------------------

p_edited_s proc near
; изменяет строку согласно правилу
    push bp
    mov bp, sp
    m_push_all

    ; вычисляем указатель на изменённую строку
    mov di, ptr_new_string
    add di, new_string_len
    mov byte ptr [di], 0
    inc di
    mov ptr_edited_string, di

    ; готовимся к копированию
    mov si, ptr_new_string
    mov cx, new_string_len
    xor ax, ax
    xor dx, dx

__L1:
; начинаем копировать
    mov dl, byte ptr [si]

    ; буква, или нет?
    cmp dl, ' '
    jg __L2
    jmp __L4

__L2:
; нашли букву
    ; был ли задан паттерн?
    cmp al, 0
    je __L3
    jmp __L5

__L3:
; паттерн задан не был
    mov al, dl
    jmp __L6

__L4:
; не буква
    xor ax, ax
    jmp __L6

__L5:
; паттерн задан был
    cmp al, dl
    jne __L6
    jmp __L7

__L6:
; пишем в изменённую строку
    mov byte ptr [di], dl
    inc di

__L7:
; переходим дальше
    inc si
    dec cx
    cmp cx, 0
    je __E1
    jmp __L1

__E1:
; сохраняем длину изменённой строки и выходим
    sub di, ptr_edited_string
    mov edited_string_len, di

    m_pop_all
    mov sp, bp
    pop bp
    ret
p_edited_s endp

; =================================================

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; находим адрес новой строки
    lea ax, file_buf[FILE_BUF_CAP]
    inc ax
    mov ptr_new_string, ax
    
    ; получаем имя файла для открытия
    call p_scan_fn
    cmp byte ptr filename_in_size, 0
    jne L1
    jmp E2

L1:
; аругменты присутствуют, начинаем обработку
    ; откроем файл для чтения
    mov ax, 3d00h
    lea dx, filename_in
    int 21h

    jnc L2
    jmp E3

L2:
; файл успешно открыт
    mov ptr_file_in, ax

    ; откроем (создадим) файл для записи
    mov ax, 3c00h
    lea dx, filename_out
    mov cx, 20h
    int 21h
    mov ptr_file_out, ax

L3:
; читаем строку из файла
    call p_scan_sf
    cmp new_string_len, 0
    jg L4
    jmp L5

L4:
; найдём чётные строки
    mov ax, count_strings
    and ax, 1
    cmp ax, 0
    je L6
    jmp L8

L6:
; нашли чётную строку, обработаем и выведем
    ; проверим, что в строке есть буквы
    mov bx, ptr_new_string
    cmp byte ptr [bx], ' '
    jg L7
    jmp L3

L7:
; в строке есть буквы
    call p_edited_s

    m_print new_line

    ; записываем на экран исходную строку
    mov ax, 4000h
    mov bx, STDOUT
    mov cx, new_string_len
    mov dx, ptr_new_string
    int 21h

    ; записываем на экран изменённую строку
    mov ax, 4000h
    mov bx, STDOUT
    mov cx, edited_string_len
    mov dx, ptr_edited_string
    int 21h

    m_print new_line

    ; записываем в файл изменённую строку
    mov ax, 4000h
    mov bx, ptr_file_out
    mov cx, edited_string_len
    mov dx, ptr_edited_string
    int 21h

    jmp L3

L8:
; запишем без изменений не чётную строку
    mov ax, 4000h
    mov bx, ptr_file_out
    mov cx, new_string_len
    mov dx, ptr_new_string
    int 21h

    jmp L3

L5:
    ; закроем файлы
    mov ax, 3e00h
    mov bx, ptr_file_in
    int 21h

    mov ax, 3e00h
    mov bx, ptr_file_out
    int 21h

    jmp E1
E3:
; ошибка открытия файла
    m_print txt_err_2
    m_print new_line
    jmp E1

E2:
; ошибка отсутствия аргументов командной строки
    m_print txt_err_1
    m_print new_line
    
E1:
    mov ax, 4c00h
    int 21h
end main