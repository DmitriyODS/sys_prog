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
