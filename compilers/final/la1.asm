xseg	segment	public	'code'
	assume	cs:xseg, ds:xseg, ss:xseg
	org	100h

main	proc	near
	call	near ptr __main_1
	mov	ax, 4c00h
	int	21h
main	endp


@1:
_lala_10	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 0

@2:
	jmp	@3

@3:
	mov	si, word ptr [bp+6]
	mov	byte ptr [si], 1

@4:

@5:
	mov	si, word ptr [bp+6]
	mov	byte ptr [si], 0

@6:

@7:
@lala_10:
	mov	sp, bp
	pop	bp
	ret
_lala_10	endp


xseg	ends
	end	main

