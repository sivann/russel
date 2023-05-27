xseg	segment	public	'code'
	assume	cs:xseg, ds:xseg, ss:xseg
	org	100h

main	proc	near
	call	near ptr __main_1
	mov	ax, 4c00h
	int	21h
main	endp


@1:
__main_1	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 3

@2:
	jmp	@3

@3:
	jmp	@6

@4:
	mov	al, 1
	mov	byte ptr [bp-1], al

@5:
	jmp	@7

@6:
	mov	al, 0
	mov	byte ptr [bp-1], al

@7:
@_main_1:
	mov	sp, bp
	pop	bp
	ret
__main_1	endp


xseg	ends
	end	main

