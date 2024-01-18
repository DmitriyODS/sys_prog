; LR6, Variant 19
; Author: Osipovskiy DS
; Module FPU

.model small
.code

	public _CalcOne
_CalcOne proc far
	arg val_x:word
	push bp
	mov bp, sp

	mov ax, [val_x]
	inc ax

	pop bp
	ret
_CalcOne endp

	public _CalcTwo
_CalcTwo proc far
	arg val_x:word
	push bp
	mov bp, sp

	mov ax, [val_x]
	inc ax
	inc ax

	pop bp
	ret
_CalcTwo endp

	public _CalcThree
_CalcThree proc far
	arg val_x:word
	push bp
	mov bp, sp

	mov ax, [val_x]
	inc ax
	inc ax
	inc ax

	pop bp
	ret
_CalcThree endp

end