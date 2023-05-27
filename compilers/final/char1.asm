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
	mov	al, byte ptr [bp+10]
	mov	si, word ptr [bp+8]
	mov	dl, byte ptr [si]
	cmp	al, dl
	jg	@4

@3:
	jmp	@7

@4:
	mov	al, byte ptr [bp+10]
	mov	si, word ptr [bp+6]
	mov	byte ptr [si], al

@5:

@6:
	jmp	@11

@7:
	jmp	@8

@8:
	mov	si, word ptr [bp+8]
	mov	al, byte ptr [si]
	mov	si, word ptr [bp+6]
	mov	byte ptr [si], al

@9:

@10:
	jmp	@11

@11:
@lala_10:
	mov	sp, bp
	pop	bp
	ret
_lala_10	endp

@12:
__main_1	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 23

@13:
	mov	al, 24h
	mov	byte ptr [bp-3], al

@14:
	mov	al, 0Ah
	mov	byte ptr [bp-2], al

@15:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@16:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@17:
	mov	al, byte ptr [bp-2]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@18:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@19:
	mov	al, 61h
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@20:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@21:
	mov	al, 5Ch
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@22:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@23:
	mov	al, 0Ah
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@24:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@25:
	mov	al, 61h
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@26:
	lea	si, byte ptr [bp-2]
	push	si

@27:
	lea	si, byte ptr [bp-22]
	push	si

@28:
	push	bp
	call	near ptr _lala_10
	add	sp, 7

@29:
	mov	al, byte ptr [bp-22]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@30:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@31:
	lea	di, byte ptr [bp-19]
	mov	ax, 0000h
	mov	word ptr [di+14], ax
	mov	ax, 0000h
	mov	word ptr [di+12], ax
	mov	ax, 0000h
	mov	word ptr [di+10], ax
	mov	ax, 0000h
	mov	word ptr [di+8], ax
	mov	ax, 3837h
	mov	word ptr [di+6], ax
	mov	ax, 3635h
	mov	word ptr [di+4], ax
	mov	ax, 3433h
	mov	word ptr [di+2], ax
	mov	ax, 3231h
	mov	word ptr [di+0], ax

@32:
	mov	ax, 3
	mov	word ptr [bp-21], ax

@33:
	lea	si, byte ptr [bp-19]
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-3], al

@34:
	lea	si, byte ptr [bp-19]
	mov	di, 0
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-2], al

@35:
	lea	si, byte ptr [bp-19]
	mov	di, 15
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-1], al

@36:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@37:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@38:
	mov	al, byte ptr [bp-2]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@39:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@40:
	mov	al, byte ptr [bp-1]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@41:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@42:
	mov	ax, 1
	mov	word ptr [bp-21], ax

@43:
	lea	si, byte ptr [bp-19]
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@44:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@45:
	lea	si, byte ptr [bp-19]
	mov	di, 2
	add	si, di
	mov	al, byte ptr [si]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@46:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@47:
	mov	ax, 3
	mov	word ptr [bp-21], ax

@48:
	lea	si, @STRING_0
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-3], al

@49:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@50:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@51:
	lea	si, @STRING_1
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@52:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@53:
	mov	byte ptr [bp-3], al

@54:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@55:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@56:
	mov	al, 63h
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@57:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@58:
	mov	al, 68h
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@59:
	lea	si, byte ptr [bp-19]
	mov	di, 1
	add	 si, di
	push	si

@60:
	lea	si, byte ptr [bp-23]
	push	si

@61:
	push	bp
	call	near ptr _lala_10
	add	sp, 7

@62:
	mov	al, byte ptr [bp-23]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@63:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@64:
@_main_1:
	mov	sp, bp
	pop	bp
	ret
__main_1	endp

	extrn	_printc : proc
@STRING_0 	DB	63h, 6Fh, 63h, 6Fh, 0h

@STRING_1 	DB	6Ch, 61h, 6Ch, 61h, 0h


xseg	ends
	end	main



From taver  Fri Jul 11 19:04:24 1997
Received: by softlab.ece.ntua.gr
	id TAA18403 at Fri, 11 Jul 1997 19:04:24 +0300 (EET DST)
From: Tavernarakis Costas <taver>
Message-Id: <199707111604.TAA18403@softlab.ece.ntua.gr>
Subject: no subject (file transmission)
To: sivann (Spiros Ioannou)
Date: Fri, 11 Jul 1997 19:04:24 +0300 (EET DST)
X-Work-Phone: +30-1-7722476
X-Home-Phone: +30-1-8824471
X-Cellular-Phone: +30-93-334473
X-Home-Address: 30, Kerkyras Str., Kypseli 113 62, Athens, GREECE
X-Mailer: ELM [version 2.4ME+ PL32 (25)]
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Status: O

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
	mov	al, byte ptr [bp+10]
	mov	si, word ptr [bp+8]
	mov	dl, byte ptr [si]
	cmp	al, dl
	jg	@4

@3:
	jmp	@7

@4:
	mov	al, byte ptr [bp+10]
	mov	si, word ptr [bp+6]
	mov	byte ptr [si], al

@5:

@6:
	jmp	@11

@7:
	jmp	@8

@8:
	mov	si, word ptr [bp+8]
	mov	al, byte ptr [si]
	mov	si, word ptr [bp+6]
	mov	byte ptr [si], al

@9:

@10:
	jmp	@11

@11:
@lala_10:
	mov	sp, bp
	pop	bp
	ret
_lala_10	endp

@12:
__main_1	proc	near
	push	bp
	mov	bp, sp
	sub	sp, 23

@13:
	mov	al, 24h
	mov	byte ptr [bp-3], al

@14:
	mov	al, 0Ah
	mov	byte ptr [bp-2], al

@15:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@16:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@17:
	mov	al, byte ptr [bp-2]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@18:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@19:
	mov	al, 61h
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@20:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@21:
	mov	al, 5Ch
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@22:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@23:
	mov	al, 0Ah
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@24:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@25:
	mov	al, 61h
	sub	sp,1
	mov	si, sp
	mov	byte ptr [si],al

@26:
	lea	si, byte ptr [bp-2]
	push	si

@27:
	lea	si, byte ptr [bp-22]
	push	si

@28:
	push	bp
	call	near ptr _lala_10
	add	sp, 7

@29:
	mov	al, byte ptr [bp-22]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@30:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@31:
	lea	di, word ptr [bp-19]
	mov	ax, 0000h
	mov	word ptr [di+14], ax
	mov	ax, 0000h
	mov	word ptr [di+12], ax
	mov	ax, 0000h
	mov	word ptr [di+10], ax
	mov	ax, 0000h
	mov	word ptr [di+8], ax
	mov	ax, 3837h
	mov	word ptr [di+6], ax
	mov	ax, 3635h
	mov	word ptr [di+4], ax
	mov	ax, 3433h
	mov	word ptr [di+2], ax
	mov	ax, 3231h
	mov	word ptr [di+0], ax

@32:
	mov	ax, 3
	mov	word ptr [bp-21], ax

@33:
	lea	si, word ptr [bp-19]
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-3], al

@34:
	lea	si, word ptr [bp-19]
	mov	di, 0
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-2], al

@35:
	lea	si, word ptr [bp-19]
	mov	di, 15
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-1], al

@36:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@37:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@38:
	mov	al, byte ptr [bp-2]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@39:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@40:
	mov	al, byte ptr [bp-1]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@41:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@42:
	mov	ax, 1
	mov	word ptr [bp-21], ax

@43:
	lea	si, word ptr [bp-19]
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@44:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@45:
	lea	si, word ptr [bp-19]
	mov	di, 2
	add	si, di
	mov	al, byte ptr [si]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@46:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@47:
	mov	ax, 3
	mov	word ptr [bp-21], ax

@48:
	lea	si, @STRING_0
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	mov	byte ptr [bp-3], al

@49:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@50:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@51:
	lea	si, @STRING_1
	mov	di, word ptr [bp-21]
	add	si, di
	mov	al, byte ptr [si]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@52:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@53:
	mov	byte ptr [bp-3], al

@54:
	mov	al, byte ptr [bp-3]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@55:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@56:
	mov	al, 63h
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@57:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@58:
	mov	al, 68h
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@59:
	lea	si, word ptr [bp-19]
	mov	di, 1
	add	 si, di
	push	si

@60:
	lea	si, byte ptr [bp-23]
	push	si

@61:
	push	bp
	call	near ptr _lala_10
	add	sp, 7

@62:
	mov	al, byte ptr [bp-23]
	sub	sp, 1
	mov	si, sp
	mov	byte ptr [si], al

@63:
	sub	sp, 2
	push	bp
	call	near ptr _printc
	add	sp, 5

@64:
@_main_1:
	mov	sp, bp
	pop	bp
	ret
__main_1	endp

	extrn	_printc : proc
@STRING_0 	DB	63h, 6Fh, 63h, 6Fh, 0h

@STRING_1 	DB	6Ch, 61h, 6Ch, 61h, 0h


xseg	ends
	end	main


