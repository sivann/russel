xseg	segment	public	'code'
	assume	cs:xseg, ds:xseg, ss:xseg
	org	100h

main	proc	near
	call	near ptr __main_1
	mov	ax, 4c00h
	int	21h
main	endp


@1:
_move_11	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 0

@2:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 206Dh
	push	ax
	mov	ax, 6F72h
	push	ax
	mov	ax, 6620h
	push	ax
	mov	ax, 676Eh
	push	ax
	mov	ax, 6976h
	push	ax
	mov	ax, 6F4Dh
	push	ax

@3:
	sub	sp, 2
	push	bp
	call	near ptr _prints
	add	sp, 20

@4:
	lea	si, byte ptr [bp+24]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@5:
	sub	sp, 2
	push	bp
	call	near ptr _prints
	add	sp, 20

@6:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 206Fh
	push	ax
	mov	ax, 7420h
	push	ax

@7:
	sub	sp, 2
	push	bp
	call	near ptr _prints
	add	sp, 20

@8:
	lea	si, byte ptr [bp+8]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@9:
	sub	sp, 2
	push	bp
	call	near ptr _prints
	add	sp, 20

@10:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0A2Eh
	push	ax

@11:
	sub	sp, 2
	push	bp
	call	near ptr _prints
	add	sp, 20

@12:
@move_11:
	mov	sp, bp
	pop	bp
	ret
_move_11	endp

@13:
_hanoi_10	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 4

@14:
	mov	ax, word ptr [bp+56]
	mov	dx, 1
	cmp	ax, dx
	jge	@16

@15:
	jmp	@32

@16:
	mov	ax, word ptr [bp+56]
	mov	dx, 1
	sub	ax, dx
	mov	word ptr [bp-2], ax

@17:
	mov	ax, word ptr [bp-2]
	push	ax

@18:
	lea	si, byte ptr [bp+40]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@19:
	lea	si, byte ptr [bp+8]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@20:
	lea	si, byte ptr [bp+24]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@21:
	sub	sp, 2
	push	word ptr [bp+4]
	call	near ptr _hanoi_10
	add	sp, 54

@22:
	lea	si, byte ptr [bp+40]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@23:
	lea	si, byte ptr [bp+24]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@24:
	sub	sp, 2
	push	bp
	call	near ptr _move_11
	add	sp, 36

@25:
	mov	ax, word ptr [bp+56]
	mov	dx, 1
	sub	ax, dx
	mov	word ptr [bp-4], ax

@26:
	mov	ax, word ptr [bp-4]
	push	ax

@27:
	lea	si, byte ptr [bp+8]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@28:
	lea	si, byte ptr [bp+24]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@29:
	lea	si, byte ptr [bp+40]
	mov	ax,word ptr [si+14]
	push	ax
	mov	ax,word ptr [si+12]
	push	ax
	mov	ax,word ptr [si+10]
	push	ax
	mov	ax,word ptr [si+8]
	push	ax
	mov	ax,word ptr [si+6]
	push	ax
	mov	ax,word ptr [si+4]
	push	ax
	mov	ax,word ptr [si+2]
	push	ax
	mov	ax,word ptr [si+0]
	push	ax

@30:
	sub	sp, 2
	push	word ptr [bp+4]
	call	near ptr _hanoi_10
	add	sp, 54

@31:
	jmp	@32

@32:
@hanoi_10:
	mov	sp, bp
	pop	bp
	ret
_hanoi_10	endp

@33:
__main_1	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 4

@34:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0020h
	push	ax
	mov	ax, 3A73h
	push	ax
	mov	ax, 676Eh
	push	ax
	mov	ax, 6952h
	push	ax

@35:
	sub	sp, 2
	push	bp
	call	near ptr _prints
	add	sp, 20

@36:
	lea	si, word ptr [bp-4]
	push	si

@37:
	push	bp
	call	near ptr _readi
	add	sp, 4

@38:
	mov	ax, word ptr [bp-4]
	mov	word ptr [bp-2], ax

@39:
	mov	ax, word ptr [bp-2]
	push	ax

@40:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 7466h
	push	ax
	mov	ax, 656Ch
	push	ax

@41:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0074h
	push	ax
	mov	ax, 6867h
	push	ax
	mov	ax, 6972h
	push	ax

@42:
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 0000h
	push	ax
	mov	ax, 656Ch
	push	ax
	mov	ax, 6C64h
	push	ax
	mov	ax, 696Dh
	push	ax

@43:
	sub	sp, 2
	push	bp
	call	near ptr _hanoi_10
	add	sp, 54

@44:
@_main_1:
	mov	sp, bp
	pop	bp
	ret
__main_1	endp

	extrn	_prints : proc
	extrn	_readi : proc

xseg	ends
	end	main

