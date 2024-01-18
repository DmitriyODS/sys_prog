; Module FPU
.model small
.386p
.data
	const_seven dd 7

.code

	public _CalcOne
_CalcOne proc far
	arg val_x:dword
; (cos(x))^4

	push bp
	mov bp, sp

	fld val_x
	fcos
	fmul val_x
	fmul val_x
	fmul val_x

	pop bp
	ret
_CalcOne endp

	public _CalcTwo
_CalcTwo proc far
	arg val_x:dword
; 2^x - 7

	push bp
	mov bp, sp

	fld val_x
	fld1
	fscale
	fild const_seven
	fsub

	pop bp
	ret
_CalcTwo endp

	public _CalcThree
_CalcThree proc far
	arg val_x:dword
; (x^2 + 1)(x - 1)

	push bp
	mov bp, sp

	fld val_x
	fld1
	fsub

	fld val_x
	fmul val_x
	fld1
	fadd

	fmul

	pop bp
	ret
_CalcThree endp

end