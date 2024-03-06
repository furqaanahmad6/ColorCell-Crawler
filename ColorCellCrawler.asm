[org 0x0100]
jmp start

move: dw 4,0;1->up, 2->left, 3->down, 4->right + second byte for index of asterik
time: dw 0
score: db 0
stop: db 0
oldisr: dd 0

clrscr:
push es
	mov ax,0xb800
	mov es,ax
	mov di,0
	mov ax,0x0f20
	mov cx,2000	
	cld
	rep stosw
pop es
ret

placecells:
	push es
	push ax
	mov ax,0xb800
	mov es,ax
	
	mov ax,0x2020	; for green cell
	mov bx,0x4020	; for red cell
	
        mov [es:90],ax
	mov [es:472],ax
	mov [es:520],ax
	mov [es:600],ax
	mov [es:1798],ax
	mov [es:2030],ax
	mov [es:2380],ax
	mov [es:2640],ax
	mov [es:3174],ax
	mov [es:3400],ax
	mov [es:3608],ax
	
	mov [es:60],bx
	mov [es:340],bx
	mov [es:570],bx
	mov [es:808],bx
	mov [es:1200],bx
	mov [es:1400],bx
	mov [es:1860],bx
	mov [es:2300],bx
	mov [es:2420],bx
	mov [es:3000],bx
	mov [es:3100],bx
	mov [es:3710],bx

	pop ax
	pop es
	ret

asterik:
	push es
	mov ax,0xb800
	mov es,ax
	
	cmp byte[stop],1
	je near exit
	
	mov ax,[move]
	cmp ax,4
	je right
	
	cmp ax,3
	je near down
	
	cmp ax,2
	je left
	
	cmp ax,1
	je  near up

	right:
		mov ax,[move+2]
		mov bx,160
		mov dx,0
		div bx
		cmp dx,158	;checking if asterik  reaches last column
		jne noch
		
		add word[move+2],-160
		mov di,[move+2]
		mov word[es:di+160],0x0720
		
		noch:
		mov di,[move+2]
		add word[move+2],2
		mov word[es:di],0x0720
		
			cmp word[es:di+2],0x2020	;checking if next place has green cell
		jne rcheck
			inc byte[score]
			jmp nomatch
		
		rcheck:
			cmp word[es:di+2],0x4020	;checking if next place has red cell
			jne nomatch
		
			mov word[stop],1
			mov word[es:di+2],0x4e2a
			jmp near exit
		
		nomatch:
			mov word[es:di+2],0x0f2a
		jmp near exit
		
	left:
		mov ax,[move+2]
		mov bx,160
		mov dx,0
		div bx
		cmp dx,0	;checking if asterik  reaches first column
		jne noch1
		
		add word[move+2],160
		mov di,[move+2]
		mov word[es:di-160],0x0720
		
		noch1:
		mov di,[move+2]
		add word[move+2],-2
		mov word[es:di],0x0720
		
			cmp word[es:di-2],0x2020
		jne rcheck1
			inc byte[score]
			jmp nomatch1
		
		rcheck1:
			cmp word[es:di-2],0x4020
			jne nomatch1
		
			mov word[stop],1
			mov word[es:di-2],0x4e2a
		jmp near exit
		
		nomatch1:
			mov word[es:di-2],0x0f2a
		jmp near exit
		
	up:
		mov ax,[move+2]
		cmp ax,158	;checking if asterik  reaches first row
		ja noch2
		
		add word[move+2],4000
		mov di,[move+2]
		mov word[es:di-4000],0x0720
		
		noch2:
		mov di,[move+2]
		add word[move+2],-160
		mov word[es:di],0x0720
		
			cmp word[es:di-160],0x2020
		jne rcheck2
			inc byte[score]
			jmp nomatch2
		
		rcheck2:
			cmp word[es:di-160],0x4020
			jne nomatch2
		
			mov word[stop],1
			mov word[es:di-160],0x4e2a
			jmp near exit
		
		nomatch2:
			mov word[es:di-160],0x0f2a
		jmp exit
		
	down:
		mov ax,[move+2]
		cmp ax,3840		;checking if asterik  reaches last row
		jb noch3
		
		add word[move+2],-4000
		mov di,[move+2]
		mov word[es:di+4000],0x0720
		
		noch3:
		mov di,[move+2]
		add word[move+2],160
		mov word[es:di],0x0720
		
			cmp word[es:di+160],0x2020
		jne rcheck3
			inc byte[score]
			jmp nomatch3
		
		rcheck3:
			cmp word[es:di+160],0x4020
			jne nomatch3
		
			mov word[stop],1
			mov word[es:di+160],0x4e2a
			jmp near exit
		
		nomatch3:
			mov word[es:di+160],0x0f2a
	
	exit:
	pop es
	ret
	
printscore:
	push es
	push ax
	push bx
	push dx
	mov ax,0xb800
	mov es,ax
	
	mov word[es:di],0x0e22
	mov word[es:di+6],0x0e22
	
	mov al,[score]
	mov ah,0
	mov dx,0
	mov bx,10
	div bx
	
	mov dh,0x0b
	add dl,0x30
	mov [es:di+4],dx
	
	mov dx,0
	mov bx,10
	div bx
	
	mov dh,0x0b
	add dl,0x30
	mov [es:di+2],dx

	pop dx
	pop bx
	pop ax
	pop es
	ret

gameover:
	push es
	mov ax,0xb800
	mov es,ax
	
	mov di,1190	
	mov word[es:di],0xf447	;Game Over
	mov word[es:di+2],0xf461
	mov word[es:di+4],0xf46d
	mov word[es:di+6],0xf465
	mov word[es:di+8],0x7020
	mov word[es:di+10],0xf44f
	mov word[es:di+12],0xf476
	mov word[es:di+14],0xf465
	mov word[es:di+16],0xf472

	pop es
	ret
	
kbisr:
	push ax
	
	in al, 0x60
		cmp al,0x48
		jne nextcmp
		mov word[move],1
		jmp quit
	
	nextcmp:
		cmp al,0x4b
		jne nextcmp1
		mov word[move],2
		jmp quit
	
	nextcmp1:
		cmp al,0x50
		jne nextcmp2
		mov word[move],3
		jmp quit
	
	nextcmp2:
		cmp al,0x4d
		jne quit
		mov word[move],4
	
	quit:
		mov al,0x20
		out 0x20,al
		pop ax
		iret

timer:
	push ax
	
	cmp word[stop],1	;if you hit red cell then terminate program
	je terminate
	
	inc word[cs:time]
	mov ax,[cs:time]
	mov dx,0
	mov bx,10 ;increase this to slow down movement of *
	div bx
	cmp dx,0
	jne end_timer
	
	call asterik
	mov di,0
	call printscore
	
	end_timer:	
		mov al, 0x20
		out 0x20, al
		pop ax
	iret
	
terminate:
	call gameover
	pop ax
	jmp far[oldisr]
	mov ax,0x4c00
	int 0x21
		
start:
	call clrscr
	call placecells
	call asterik
	
		xor ax, ax
		mov es, ax
		
		mov ax,[es:9*4]
		mov [oldisr],ax
		mov ax,[es:9*4+2]
		mov [oldisr+2],ax
		
		cli
		mov word [es:9*4], kbisr
		mov [es:9*4+2], cs
		mov word [es:8*4], timer
		mov [es:8*4+2], cs
		sti

		mov dx, start
		add dx, 15
		mov cl, 4
		shr dx, cl
		
	mov ax,0x3100
	int 0x21