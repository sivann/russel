xseg	segment	public	'code'
	assume	cs:xseg, ds:xseg, ss:xseg
	org	100h

main	proc	near
	call	near ptr __main_1
	mov	ax, 4c00h
	int	21h
main	endp



xseg	ends
	end	main

