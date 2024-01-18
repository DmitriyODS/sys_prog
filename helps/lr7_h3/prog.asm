; LR7, Variant 7

; объявление макросов
; =================================================

; дескриптор консоли
STDOUT equ 1h

; базовые макросы

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
    new_line db 0ah, 0dh, '$'

    input_string db 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
        db 'Nam congue nisi vitae eleifend dapibus. Sed eget tincidunt urna. '
        db 'Duis pretium nec neque vel luctus. Donec quis sodales tellus. '
        db 'Phasellus ultricies mollis lorem vel vulputate. Morbi non porttitor mauris. '
        db 'Fusce blandit augue elit, nec mollis dui cursus a. '
        db 'Phasellus venenatis dolor sed dictum gravida.', 0, '$'

    ht_symbols_counts db 80h dup(0), 0

.data?
    arr_words label word

.code
    locals __

; объявление процедур
; =================================================

p_find_max_symbol proc near
; процедура поиска символа, который встречается в строке чаще других
    push bp
    mov bp, sp

    push di
    push si
    push bx

    ; получаем базовый адрес от которого будем отсчитывать смещение букв
    lea di, ht_symbols_counts

    ; настраиваем указатель на начало строки
    lea si, input_string

    xor ax, ax
    xor bx, bx

__L1:
; бежим по строке и считаем кол-во каждой буквы
    ; кладём букву в bl
    mov bl, byte ptr [si]

    ; если дошли до нуля - выходим
    cmp bl, 0
    jne __L2
    jmp __E1

__L2:
; не считаем служебные символы
    cmp bl, ' '
    jg __L3

    jmp __L4

__L3:
; идём по адресу равному: базовый адрес таблицы + смещение по коду символа
; и прибавляем единицу к кол-во
    inc byte ptr [bx+di]

    ; проверим, эта буква чаще ли встречается?
    cmp byte ptr [bx+di], ah
    jbe __L4

    ; кладём новый фаворит в ax
    mov ah, byte ptr [bx+di]
    mov al, bl

__L4:
    inc si
    jmp __L1

__E1:
    pop bx
    pop si
    pop di

    mov sp, bp
    pop bp
    ret
p_find_max_symbol endp

p_get_sorted_words proc near
; процедура создания списка слов от большего к меньшему (по кол-во букв)
    push bp
    mov bp, sp
    m_push_all

    xor ax, ax
    xor bx, bx
    xor cx, cx

    ; настраиваем указатель на строку
    lea si, input_string

__L1:
; смотрим, что лежит по текущему адресу
    cmp byte ptr [si], ' '
    jg __L2
    jmp __L5

__L2:
; какой - то символ, проверим, запоминали ли мы адрес первого символа слова
    cmp bx, 0
    jg __L3

    ; не запоминали, запоминаем
    mov bx, si

__L3:
; увелличиваем счётчик букв в слове
    inc cx

__L7:
; проверим, не конец ли строки
    cmp byte ptr [si], 0
    je __L4

    inc si
    jmp __L1

__L4:
    jmp __E1

__L5:
; пробельный символ, смотрим, запоминали ли мы адрес первого символа
    cmp bx, 0
    jg __L6
    jmp __L7

__L6:
; запоминали, помещаем указатель на слово в отсортированный список
    lea di, arr_words

__L6_1:
    ; проверяем на какое место вставим новое слово
    cmp cx, word ptr [di]
    jg __L8

    inc di
    inc di
    inc di
    inc di
    jmp __L6_1

__L8:
; слово больше текущего, заменяем его
    mov ax, word ptr [di]
    mov word ptr [di], cx
    mov cx, ax

    mov ax, word ptr [di+2]
    mov word ptr [di+2], bx
    mov bx, ax

    inc di
    inc di
    inc di
    inc di

; проверим, не нуль ли мы записали
    cmp cx, 0
    je __L10
    jmp __L6_1

__L10:
; записали нуль, дополняем список и переходим к следующему слову
    mov word ptr [di], cx
    mov word ptr [di+2], bx

    jmp __L1

__E1:
    m_pop_all
    mov sp, bp
    pop bp
    ret
p_get_sorted_words endp

; =================================================

main:
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; инициализируем нулями начало отсортированного списка указателей на слова
    mov word ptr [arr_words], 0
    mov word ptr [arr_words+2], 0

    m_print new_line
    m_print input_string
    m_print new_line
    m_print new_line

    ; создадим массив отсортирвоанных по убыванию слов
    call p_get_sorted_words

    ; выводим эти слова
    lea di, arr_words

L1:
    mov ax, 4000h
    mov bx, STDOUT
    mov cx, word ptr [di]
    inc di
    inc di
    mov dx, word ptr [di]
    inc di
    inc di
    int 21h

    m_print new_line

    cmp word ptr [di], 0
    je L2
    jmp L1

L2:
    m_print new_line
    m_print new_line

    ; найдём самый частый символ
    call p_find_max_symbol
    int 29h

    m_print new_line

E1:
    mov ax, 4c00h
    int 21h
end main
