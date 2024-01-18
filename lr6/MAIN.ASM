	.286p
	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 300h
	?debug	S "main.cpp"
	?debug	C E9ED9B3258086D61696E2E637070
	?debug	C E9E6668F5718633A5C42435C494E434C5544455C696F7374726561+
	?debug	C 6D2E68
	?debug	C E9E6668F5715633A5C42435C494E434C5544455C5F646566732E68
	?debug	C E9E6668F5713633A5C42435C494E434C5544455C6D656D2E68
	?debug	C E9E6668F5715633A5C42435C494E434C5544455C5F6E756C6C2E68
	?debug	C E9E6668F5716633A5C42435C494E434C5544455C6C696D6974732E+
	?debug	C 68
MAIN_TEXT	segment byte public 'CODE'
MAIN_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:MAIN_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
MAIN_TEXT	segment byte public 'CODE'
   ;	
   ;	int InputX() {
   ;	
	assume	cs:MAIN_TEXT
@InputX$qv	proc	far
	enter	10,0
   ;	
   ;		int in_x = 0;
   ;	
	mov	word ptr [bp-2],0
   ;	
   ;	
   ;		cout << "Enter X of range: from "
   ;	
   ;	
   ;	             << INT_MIN
   ;	             << " to "
   ;	             << INT_MAX
   ;	             << " -> ";
   ;	
	push	0
	push	0
	push	ds
	push	offset DGROUP:s@
	push	ds
	push	offset DGROUP:_cout
	call	far ptr @ostream@outstr$qnxzct1
	add	sp,12
	push	-1
	push	-32768
	push	ds
	push	offset DGROUP:_cout
	call	far ptr @ostream@$blsh$ql
	add	sp,8
	mov	word ptr [bp-4],dx
	mov	word ptr [bp-6],ax
	push	0
	push	0
	push	ds
	push	offset DGROUP:s@+24
	push	dx
	push	ax
	call	far ptr @ostream@outstr$qnxzct1
	add	sp,12
	push	0
	push	32767
	push	word ptr [bp-4]
	push	word ptr [bp-6]
	call	far ptr @ostream@$blsh$ql
	add	sp,8
	mov	word ptr [bp-8],dx
	mov	word ptr [bp-10],ax
	push	0
	push	0
	push	ds
	push	offset DGROUP:s@+29
	push	dx
	push	ax
	call	far ptr @ostream@outstr$qnxzct1
	add	sp,12
   ;	
   ;		cin >> in_x;
   ;	
	push	ss
	lea	ax,word ptr [bp-2]
	push	ax
	push	ds
	push	offset DGROUP:_cin
	call	far ptr @istream@$brsh$qmi
	add	sp,8
   ;	
   ;	
   ;		if (cin.fail()) {
   ;	
	push	ds
	pop	es
	mov	bx,word ptr DGROUP:_cin
	test	word ptr es:[bx+10],134
	je	short @1@86
   ;	
   ;			cout << "Faild input" << endl;
   ;	
	push	0
	push	0
	push	ds
	push	offset DGROUP:s@+34
	push	ds
	push	offset DGROUP:_cout
	call	far ptr @ostream@outstr$qnxzct1
	add	sp,12
	push	ds
	push	offset DGROUP:_cout
	call	far ptr @endl$qm7ostream
	add	sp,4
@1@86:
   ;	
   ;		}
   ;	
   ;		return in_x;
   ;	
	mov	ax,word ptr [bp-2]
   ;	
   ;	}
   ;	
	leave	
	ret	
@InputX$qv	endp
   ;	
   ;	int main() {
   ;	
	assume	cs:MAIN_TEXT
_main	proc	far
	enter	8,0
	push	si
   ;	
   ;		int in_x = 0;
   ;	
   ;	
   ;		int res = 0;
   ;	
   ;	
   ;	
   ;		in_x = InputX();
   ;	
	push	cs
	call	near ptr @InputX$qv
	mov	dx,ax
   ;	
   ;	
   ;		if (in_x < 0) {
   ;	
	or	dx,dx
	jge	short @2@86
   ;	
   ;	        res = CalcOne(in_x);
   ;	
	push	ax
	call	far ptr _CalcOne
	jmp	short @2@170
@2@86:
   ;	
   ;	    } else if (in_x > 0.5) {
   ;	
	mov	word ptr [bp-2],dx
	fild	word ptr [bp-2]
	fcomp	dword ptr DGROUP:s@+46
	fstsw	word ptr [bp-2]
	fwait	
	mov	ax,word ptr [bp-2]
	sahf	
	jbe	short @2@142
   ;	
   ;	        res = CalcThree(in_x);
   ;	
	push	dx
	call	far ptr _CalcThree
	jmp	short @2@170
@2@142:
   ;	
   ;	    } else {
   ;	        res = CalcTwo(in_x);
   ;	
	push	dx
	call	far ptr _CalcTwo
@2@170:
	pop	cx
	mov	si,ax
   ;	
   ;	    }
   ;	
   ;	    cout << "Res function: "
   ;	
   ;	
   ;	         << res
   ;	         << endl;
   ;	
	push	0
	push	0
	push	ds
	push	offset DGROUP:s@+50
	push	ds
	push	offset DGROUP:_cout
	call	far ptr @ostream@outstr$qnxzct1
	add	sp,12
	mov	word ptr [bp-4],si
	mov	ax,word ptr [bp-4]
	cwd	
	push	dx
	push	ax
	push	ds
	push	offset DGROUP:_cout
	call	far ptr @ostream@$blsh$ql
	add	sp,8
	mov	word ptr [bp-6],dx
	mov	word ptr [bp-8],ax
	push	dx
	push	ax
	call	far ptr @endl$qm7ostream
	add	sp,4
   ;	
   ;	
   ;		return 0;
   ;	
	xor	ax,ax
   ;	
   ;	}
   ;	
	pop	si
	leave	
	ret	
_main	endp
	?debug	C E9
	?debug	C FA10010000
MAIN_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'Enter X of range: from '
	db	0
	db	' to '
	db	0
	db	' -> '
	db	0
	db	'Faild input'
	db	0
	db	0
	db	0
	db	0
	db	'?Res function: '
	db	0
_DATA	ends
MAIN_TEXT	segment byte public 'CODE'
MAIN_TEXT	ends
	public	_main
	public	@InputX$qv
	extrn	_CalcThree:far
	extrn	_CalcTwo:far
	extrn	_CalcOne:far
	extrn	@endl$qm7ostream:far
	extrn	_cout:word
	extrn	_cin:word
	extrn	@ostream@outstr$qnxzct1:far
	extrn	@ostream@$blsh$ql:far
	extrn	@istream@$brsh$qmi:far
_s@	equ	s@
	end
