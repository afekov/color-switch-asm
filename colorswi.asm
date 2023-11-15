IDEAL
MODEL small
STACK 100h

cyan equ 52
yellow equ 44
purple equ 34
red equ 39
SCREEN_WIDTH = 320  
 

 
 

DATASEG
	black db 0
	ScrLine 	db SCREEN_WIDTH dup (0)  ; One Color line read buffer

	;BMP File data
	FileName 	db 14 dup (0)
	openscrname db "openscr.bmp",0
	pscr db "pscr.bmp",0
	namescr db "namescr.bmp",0
	modescr db "modescr.bmp",0
	endgame db "endgame.bmp",0
	keysscr db "keysscr.bmp",0
	reset db "reset.bmp",0
	FileHandle	dw 0
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	player_one db "p1$"
	player_two db "p2$"
	player_three db "p3$"
	scoreballs dw 3 dup (30)
	outpput db "71$"
	BmpFileErrorMsg    	db 'Error At Opening Bmp File ', 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'
	; array for mouse int 33 ax=09 (not a must) 64 bytes
	
	 
	
	Xclick dw ?
	Yclick dw ?
	Xp dw ?
	Yp dw ?
	SquareSize dw ?
	 
	BmpLeft dw ?
	BmpTop dw ?
	BmpWidth dw ?
	BmpHeight dw ?
	validname db 1
	;the name off the game
	;is not alredy taken
	scoreball dw 0
	samescreen dw 0;all the screens mov together
	cycle dw 0;the screen doesnt mov
	;online dw 0; is it online
	num db 1
	name_file db 24 dup (?);
	player_name db 24 dup (?)
	RndCurrentPos dw start
	index dw 0
	alive dw 3 dup (0);if there is an active Ball
	cnt1 dw 0
	cnt2 dw 0
	cnt3 dw 0
	Yball dw 0
	Xball dw 0
	pastballs db 48 dup (0)
	pastball db 16 dup (0)
	scoreprinted db 3 dup (0)
	time dw 0
	velocity dw 0
	BallColor db 0
	key dw 0
	numberplayers dw 0
	Xcor dw 0
	Ycor dw 0
	len dw 0
	color db 0
	cccc dw 0
	ballmov dw 0
	ms dw 0
	dead db 3 dup (0)
	numberdead dw 0
	endminus db 0
	Yballs dw 4 dup (-1)
	Xballs dw 4 dup (-1)
	keys dw 4 dup (-1)
	velocities dw 4 dup (-1)
	BallColors db 4 dup (-1)
	obs1 dw 12 dup (-1)
	obs2 dw 12 dup (-1)
	obs3 dw 12 dup (-1)
	change_obs1 dw 80 dup (-1)
	change_obs2 dw 80 dup (-1)
	change_obs3 dw 80 dup (-1)
	change_cor dw 8 dup (-1)
	
	endall db 0
	;;;;;;;;;;;;;;;;;;;;;;
CODESEG
start:
	mov ax,@data
	mov ds,ax
	mov es,ax
	mov ax, 13h
	int 10h
	;mov ah, 9
	;mov dx, offset outpput
	;int 21h
	;mov ah, 9
	;mov dx, offset outpput
	;int 21h
	;mov ah, 9
	;mov dx, offset outpput
	;int 21h
    mov ax,0a000h
    mov es,ax
	mov [word ptr cycle], 0
	call showopenscr
	mov si, 5000
	push si
	call waitms
	call showpscr
	call checknump
	call showkeysscr
	mov ah,0ch
	mov al,0
	int 21h
	call setkeys
	call showmodescr
	call setmode
	mov ax, 13h
	int 10h
    mov ax,0a000h
    mov es,ax
	mov ax, [numberplayers]
	mov [cccc], ax
	;call checkrange
	mov ah,0ch
	mov al,0
	int 21h
	call clearscreen
	mov [Xcor], 120
	mov [Ycor], 80
	call drawobs3
	mov [Xcor], 220
	mov [Ycor], 80
	call drawobs3
	mov [Xcor], 20
	mov [Ycor], 80
	call drawobs3
	mov [Xcor], 101
	mov [Ycor], 10
	call drawobs2
	mov [Xcor], 201
	mov [Ycor], 10
	call drawobs2
	mov [Xcor], 1
	mov [Ycor], 10
	call drawobs2
	mov [word ptr index], 0
	mov cx, [numberplayers]
@@printballs :
	call restartball
	call setball
	call draw_ball
	inc [word ptr index]
	loop @@printballs
	mov cx, 0
	mov ah,0ch
	mov al,0
	int 21h
@@l1 :
	call movallobs2
	call movobs3
	call readkey
	push cx
	mov cx, [numberplayers]
@@test :
	mov [word ptr index], -1
@@moveballs :
	inc [word ptr index]
	mov di, [index]
	cmp [byte ptr dead+di], 1
	je @@looping
	call printscore
	call mov_ball
@@looping :
	loop @@moveballs
	call docycle
	mov si, 1000
	push si
	call waitms
	pop cx
	jmp @@l1
	;mov dx, 10000
	;push dx
	;call waitms
	;call movallobs2
	call finito

exit:
	mov ax, 4c00h
	int 21h
proc finito
	call showendgame
	call showreset
	;----- Initializes the mouse
    mov ax,00h
    int 33h

	;----- Show mouse
    mov ax,01h
    int 33h
@@l_none :
	mov ax, 5
	int 33h
	cmp bx, 0
	jz @@l_none
	shr cx, 1
	cmp cx, 303
	jl @@l_none
	cmp dx, 183
	jl @@l_none
	mov ax, 02h
	int 33h
	call resetall
endp finito
proc checknump
;----- Initializes the mouse
    mov ax,00h
    int 33h

;----- Show mouse
    mov ax,01h
    int 33h
@@loopreg :
	mov ax, 5h
	int 33h
	;jmp exit
	shr cx, 1
	;shr dx, 3
	xor bx, bx
	xor ax, ax
	mov ah, 0dh
	push cx
	int 10h
	pop cx
@@check :
	cmp al, 0
	jz @@loopreg
	cmp al, 15
	jz @@loopreg
	mov [word ptr numberplayers],1
	cmp cx,100
	jl @@end
	inc [word ptr numberplayers]
	cmp cx,200
	jl @@end
	inc [word ptr numberplayers]
@@end :
	mov ax, 2 
	int 33h
	ret
	
endp checknump
proc resetall
	mov bx, offset scoreballs
	mov ax, 30
	mov cx, 3
@@l1 :
	mov [bx], ax
	add bx, 2
	loop @@l1
	mov bx,  offset scoreball
	mov ax, 0
@@l2 :
	mov [bx], al
	inc bx
	cmp bx, offset endminus
	jne @@l2
	mov al, -1
@@l3 :
	mov [bx], al
	inc bx
	cmp bx, offset endall
	jne @@l3
	jmp start
endp resetall
proc eraseicon
	push ax
	push bx
	push cx
	push dx
	mov cx, 303
@@l1 :
	mov dx, 183
	mov bx, 0
	mov ax, 0c00h
@@l2 :
	int 10h
	inc dx
	cmp dx, 200
	jne @@l2
	inc cx
	cmp cx, 320
	jne @@l1
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp eraseicon
proc escpressed
	push ax
	push bx
	push cx
	push dx
	call showreset
	;----- Initializes the mouse
    mov ax,00h
    int 33h

	;----- Show mouse
    mov ax,01h
    int 33h
@@l_none :
	mov ah, 1
	int 16h
	jz @@next
	mov ah, 0
	int 16h
	cmp ah, 1
	je @@return
@@next :
	mov ax, 5
	int 33h
	cmp bx, 0
	jz @@l_none
	shr cx, 1
	cmp cx, 303
	jl @@l_none
	cmp dx, 183
	jl @@l_none
	mov ax, 02h
	int 33h
	call resetall
@@return :
	mov ax, 02h
	int 33h
	mov ax, 13h
	int 10h
	call eraseicon
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp escpressed
proc setkeys
	mov si, 0
@@l1 :
	mov ah, 2
	mov dx, 0
	mov bh, 0
	int 21h
	mov dl, 'p'
	mov ah, 2
	int 21h
	mov dl, '1'
	add dx, si
	shl si, 1
	int 21h
@@l_setkey :
	mov ah, 1
	int 16h
	jz @@l_setkey
	mov ah, 0
	int 16h
	mov [keys+si], ax
	add si, 2
	shr si, 1
	cmp si, [numberplayers]
	jne @@l1
	ret
endp setkeys
proc setmode
;----- Initializes the mouse
    mov ax,00h
    int 33h

;----- Show mouse
    mov ax,01h
    int 33h
@@loopreg :
	mov si, 5
	push si
	call waitms
	mov ax, 5h
	int 33h
	;jmp exit
	shr cx, 1
	;shr dx, 3
	mov bh, 0
	xor ax, ax
	mov ah, 0dh
	push cx
	int 10h
	pop cx
	cmp al, 15
	jz @@loopreg
	cmp al, 0
	jz @@loopreg
	cmp cx, 210
	jg @@end
	;jmp exit
	cmp cx,120
	jg @@last
	mov [word ptr cycle], 1
	jmp @@end
@@last :
	mov [word ptr samescreen], 1
@@end :
	mov ax, 2
	int 33h
	ret
	
endp setmode
proc setnumberplayers
	push ax
	push bx
	push cx
	push dx
	mov [word ptr numberplayers], 0
@@l1 :
	mov bx, [word ptr numberplayers]
	shl bx, 1
	mov ah, 1
	int 16h
	jz @@l1
	mov ah, 0
	int 16h
	mov [keys+bx], ax
	cmp ax, 01c0dh
	jne @@world
	je @@end
@@world :
	mov ax, [word ptr numberplayers]
	mov[index], ax
	call restartball
	add [word ptr numberplayers], 1
	cmp [word ptr numberplayers], 4
	je @@too_many
	cmp [word ptr numberplayers], 1
	jne @@second
	mov [Xballs], 48
	jmp @@l1
@@second :
	cmp [word ptr numberplayers], 2
	jne @@third
	mov [Xballs+2], 148
	jmp @@l1
@@third :
	cmp [word ptr numberplayers], 3
	jne @@too_many
	mov [Xballs+4], 248
	jmp @@l1
@@too_many :
	mov ax, 4c00h
	int 21h
@@end :
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp 
proc restartball
	push bx
	push ax
	mov bx, 0300h
	call RandomByCs
	mov ah, 0
	push ax
	call choose_color
	pop ax
	mov bx, [word ptr index]
	mov [BallColors+bx], al
	shl bx, 1
	mov [Yballs+bx], 170
	mov [velocities+bx], 2
	mov ax, 50
	xor dx, dx
	mul bx
	add ax, 48
	mov [Xballs+bx], ax
	pop ax
	pop bx
	ret
endp
;===========================
;push x, push y
proc FindLocation 
    push bp
	mov bp, sp
    push bx
    push dx
	push ax
    mov bx,[bp+4]
    mov ax,320
    mul bx
    add [bp+6], ax
	pop ax
    pop dx
    pop bx
	pop bp
    ret 2
endp FindLocation
;di coulum
proc addobs
	push ax
	push bx
	push cx
	push dx
	push di
	cmp [cycle], 0
	jne @@end
	mov cx, 0
	mov bx, di
@@l1 :
	cmp[byte ptr es: bx],0
	je @@checktype
	inc cx
	add bx, 320
	jmp @@l1
@@checktype :
	add bx, 320*55
	cmp [byte ptr es:bx], 0
	jne @@square
	sub cx, 30
@@squre :
	sub cx, 70
	
	mov bx, 0201h
	call RandomByCs
	cmp al, 1
	je @@square
	sub di, 39
	mov [Xcor], di
	mov[Ycor], cx
	call nodrawobs2
	jmp @@end
@@square :
	sub cx, 30
	sub di, 20
	mov [Xcor], di
	mov[Ycor], cx
	call nodrawobs3
@@end :
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp addobs
proc docycle
	push cx
	mov cx, 44
@@l1 :
	call movobs3
	loop @@l1
	mov cx, 25
@@l2 :
	call movallobs2
	loop @@l2
	pop cx
	ret
endp docycle
proc showopenscr
	mov dx, offset openscrname
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	call OpenShowBmp
	ret
endp showopenscr
proc showendgame
	mov dx, offset endgame
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	call OpenShowBmp
	mov ax, [scoreballs]
	cmp ax, [scoreballs+2]
	jge @@next
	mov ax, [scoreballs+2]
@@next :
	cmp ax, [scoreballs+4]
	jge @@next1
	mov ax, [scoreballs+4]
@@next1 :
	mov si, ax
	mov ah,2 
	xor bx, bx
	mov dh, 9
	mov dl,29
	int 10h
	mov ax, si
	xor dx, dx
	mov bx, 100
	div bx
	call ShowAxDecimal
	ret
endp showendgame
proc showpscr
	mov dx, offset pscr
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	call OpenShowBmp
	ret
endp showpscr
proc showreset
	mov dx, offset reset
	mov [BmpLeft],304
	mov [BmpTop],184
	mov [BmpWidth], 16
	mov [BmpHeight] ,16
	call OpenShowBmp
	ret
endp showreset
proc showmodescr
	mov dx, offset modescr
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	call OpenShowBmp
	ret
endp showmodescr
proc shownamescr
	mov dx, offset namescr
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	call OpenShowBmp
	ret
endp shownamescr
proc showkeysscr
	mov dx, offset keysscr
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpWidth], 320
	mov [BmpHeight] ,200
	call OpenShowBmp
	ret
endp showkeysscr
proc movscreen1
	push bp
	mov bp, 99
	push bp
	mov bp, 1
	push bp
	mov bp, sp
	mov bp, [bp+8]
	push bp
	call movscreen
	pop bp
	ret 2
endp
proc movscreen2
	push bp
	mov bp, 199
	push bp
	mov bp, 101
	push bp
	mov bp, sp
	mov bp, [bp+8]
	push bp
	call movscreen
	pop bp
	ret 2
endp
proc movscreen3
	push bp
	mov bp, 299
	push bp
	mov bp, 201
	push bp
	mov bp, sp
	mov bp, [bp+8]
	push bp
	call movscreen
	pop bp
	ret 2
endp
proc movallscreens
	push bp
	mov bp, sp
	add bp, 4
	mov bp, [bp]
	push bp
	call movscreen1
	push bp
	call movscreen2
	push bp
	call movscreen3
	pop bp
	ret 2
endp 
;push endx, startx, dis([bp]=dis)
proc movscreen
	push bp
	mov bp, sp
	add bp, 4
	push ax
	push bx
	push cx
	push dx
	push di
	push si
	mov cx, [bp]
	mov ax, 320
	mul cx
	mov bx, [bp+2]
	mov dx, [bp+4]
	sub dx, bx
	mov di, dx
	inc di
	mov cx, 200
	sub cx, [bp]
	mov bx, [bp+4]
	add bx, 63680
	mov si, bx
	sub si, ax
@@l_lines :
	push cx
	mov cx, di
@@l_pixels :
	mov dl, [es:si]
	mov [es:bx], dl
	dec si
	dec bx
	loop @@l_pixels
	sub bx, 320
	sub si, 320
	add bx, di
	add si, di
	pop cx
	loop @@l_lines
	
	mov cx, [bp]
@@l_linestop :
	push cx
	mov cx, di
@@l_pixelstop :
	mov [byte ptr es:bx], 0
	dec bx
	loop @@l_pixelstop
	sub bx, 320
	add bx, di
	pop cx
	loop @@l_linestop
	
	mov ax, [bp]
	mov bx, offset Xballs
	mov dx, [bp+2]
	mov di, [bp+4]
	mov cx, 3
@@l_balls :
	push dx
	push di
	mov si, [bx]
	push si
	call checkrange
	jc @@looping
	mov si, offset Yballs
	add si, 6
	sub si, cx
	sub si, cx
	add [si], ax
@@looping :
	inc bx
	inc bx
	loop @@l_balls
	
	mov bx, offset change_obs2
	mov cx, 6
@@l_obs2 :
	push dx
	push di
	mov si, [bx]
	push si
	call checkrange
	jc @@next_obs2
	push cx
	mov cx, 4
	mov si, bx
	add si, 2
@@l_updateobs2 :
	add [si], ax
	add si, 4
	loop @@l_updateobs2
	pop cx
@@next_obs2 :
	add bx, 16
	loop @@l_obs2
	
	
	mov bx, offset change_obs3
	mov cx, 6
@@l_obs3 :
	push dx
	push di
	mov si, [bx]
	push si
	call checkrange
	jc @@next_obs3
	push cx
	mov cx, 4
	mov si, bx
	add si, 2
@@l_updateobs3 :
	add [si], ax
	add si, 4
	loop @@l_updateobs3
	pop cx
@@next_obs3 :
	add bx, 16
	loop @@l_obs3
	
	
	mov bx, offset obs3
	mov cx, 6
@@l_obs3loc :
	push dx
	push di
	mov si, [bx]
	push si
	call checkrange
	jc @@next_obs3loc
	mov si, bx
	add si, 2
	add [si], ax
@@next_obs3loc :
	add bx, 4
	loop @@l_obs3loc
	
@@end :
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp
;push small,big,val
proc checkrange
	push bp
	mov bp, sp
	add bp, 4
	push ax
	push bx
	push cx
	mov ax, [bp]
	cmp ax, [bp+2]
	jle @@next
	stc
	jmp @@poping
@@next :
	cmp ax, [bp+4]
@@poping :
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
endp
proc clearscreen
	push ax 
	push bx
	push cx
	push dx
	push si
	mov cx, 319
loop_width :
	mov dx, 199
	mov al, 0
	cmp cx, 0
	je change_to_white
	cmp cx, 100
	je change_to_white
	cmp cx, 200
	je change_to_white
	cmp cx, 300
	je change_to_white
	jmp loop_height
change_to_white :
	mov al, 15
loop_height :
	push cx
	push dx
	call FindLocation
	pop bx
	mov [es:bx], al
	dec dx
	cmp dx, -1
	jne loop_height
	dec cx
	cmp cx, -1
	jne loop_width
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp
proc printscore
	push dx 
	push cx
	push bx
	push ax
	push si
	mov dh, 0
	mov dl, 78
	shl di, 11
	add dx, di
	shr di, 11
	mov bh, 0
	mov ah, 2
	int 10h
	mov ah, 9
	mov dx, offset player_one
	add dx, di
	shl di, 1
	add dx, di
	int 21h
	mov dh, 2
	shl di, 10
	add dx, di
	shr di, 10
	mov dl, 78
	mov bh, 0
	mov ah, 2
	int 10h
	mov ax, [scoreballs+di]
	mov si, 100
	xor dx, dx
	div si
	call ShowAxDecimal
	shr di, 1
	cmp [cycle], 1
	je @@end
	cmp al, [scoreprinted+di]
	jle @@end
	mov [scoreprinted+di], al
	xor dx, dx
	mov ax, 100
	mul di
	mov di, 40
	add di, ax
	call addobs
@@end :
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp printscore
proc nodrawobs2
	push dx 
	push cx
	push bx
	push ax
	push si
	mov cx, 1
	mov dx, [Ycor]
	mov bx, [Xcor]
	mov si, offset change_obs2
	sub si, 16
	mov ax, [Xcor]
@@add_to_arr :
	add si, 16
	cmp [word ptr si], -1
	jne @@add_to_arr
	add ax, 24
	mov cx, 4
@@assume :
	mov [si], ax
	add si, 2
	add ax, 25
	mov [si], dx
	add si, 2
	loop @@assume
	sub si, 4
	sub [word ptr si], 99
	mov cx, 1
@@l1 :
	mov [Ycor], dx
	mov [Xcor], bx
	mov [byte ptr color], cyan
	mov [word ptr len], 24
	;call draw_line_horizon
	mov [Ycor], dx
	mov [Xcor], bx
	add [word ptr Xcor], 24
	mov [byte ptr color], yellow
	mov [word ptr len], 25
	;call draw_line_horizon
	mov [Ycor], dx
	mov [Xcor], bx
	add [word ptr Xcor], 49
	mov [byte ptr color], purple
	;call draw_line_horizon
	mov [Xcor], bx
	mov [Ycor], dx
	add [word ptr Xcor], 74
	mov [byte ptr color], red
	;call draw_line_horizon
	mov [Ycor], dx
	mov [Xcor], bx
	add [word ptr Xcor], 99
	mov [word ptr len], 1
	mov [byte ptr color], 15
	;call draw_line_horizon
	add dx, 3
	loop @@l1
@@end:
	mov [Ycor], dx
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp
proc drawobs2
	push dx 
	push cx
	push bx
	push ax
	push si
	mov cx, 1
	mov dx, [Ycor]
	mov bx, [Xcor]
	mov si, offset change_obs2
	sub si, 16
	mov ax, [Xcor]
@@add_to_arr :
	add si, 16
	cmp [word ptr si+2], -1
	jne @@add_to_arr
	add ax, 24
	mov cx, 4
@@assume :
	mov [si], ax
	add si, 2
	add ax, 25
	mov [si], dx
	add si, 2
	loop @@assume
	sub si, 4
	sub [word ptr si], 99
	mov cx, 1
@@l1 :
	mov [Ycor], dx
	mov [Xcor], bx
	mov [byte ptr color], cyan
	mov [word ptr len], 24
	call draw_line_horizon
	mov [Ycor], dx
	mov [Xcor], bx
	add [word ptr Xcor], 24
	mov [byte ptr color], yellow
	mov [word ptr len], 25
	call draw_line_horizon
	mov [Ycor], dx
	mov [Xcor], bx
	add [word ptr Xcor], 49
	mov [byte ptr color], purple
	call draw_line_horizon
	mov [Xcor], bx
	mov [Ycor], dx
	add [word ptr Xcor], 74
	mov [byte ptr color], red
	call draw_line_horizon
	mov [Ycor], dx
	mov [Xcor], bx
	add [word ptr Xcor], 99
	mov [word ptr len], 1
	mov [byte ptr color], 15
	call draw_line_horizon
	add dx, 3
	loop @@l1
@@end:
	mov [Ycor], dx
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp
proc drawobs3
	push dx 
	push cx
	push bx
	push ax
	push si
	mov cx, [Xcor]
	mov dx, [Ycor]
	mov [byte ptr color], cyan	
	mov [len], 55
	call draw_line_horizon
	mov [Xcor], cx
	mov [Ycor], dx
	add [word ptr Ycor], 5
	mov [byte ptr color], red
	call draw_line_vertical
	mov [Xcor], cx
	mov [Ycor], dx
	add [word ptr Xcor], 55
	mov [byte ptr color], yellow
	call draw_line_vertical
	mov [Xcor], cx
	mov [Ycor], dx
	add [word ptr Ycor], 55
	add [word ptr Xcor], 5
	mov [byte ptr color], purple
	call draw_line_horizon
	mov si, offset obs3
	push si
	mov bx, offset change_obs3
	push bx
	call give_end
	pop bx
	pop si
	mov [si], cx
	mov [si+2], dx
	mov [bx], cx
	add [word ptr bx], 55
	mov [bx+2], dx
	mov [bx+4], cx
	add [word ptr bx+4], 55
	mov [bx+6], dx
	add [word ptr bx+6], 55
	mov [bx+8], cx
	mov [bx+10], dx
	add [word ptr bx+10], 55
	mov [bx+12], cx
	mov [bx+14], dx
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp

proc nodrawobs3
	push dx 
	push cx
	push bx
	push ax
	push si
	mov cx, [Xcor]
	mov dx, [Ycor]
	mov [byte ptr color], cyan	
	mov [len], 55
	;call draw_line_horizon
	mov [Xcor], cx
	mov [Ycor], dx
	add [word ptr Ycor], 5
	mov [byte ptr color], red
	;call draw_line_vertical
	mov [Xcor], cx
	mov [Ycor], dx
	add [word ptr Xcor], 55
	mov [byte ptr color], yellow
	;call draw_line_vertical
	mov [Xcor], cx
	mov [Ycor], dx
	add [word ptr Ycor], 55
	add [word ptr Xcor], 5
	mov [byte ptr color], purple
	;call draw_line_horizon
	mov si, offset obs3
	push si
	mov bx, offset change_obs3
	push bx
	call give_end
	pop bx
	pop si
	mov [si], cx
	mov [si+2], dx
	mov [bx], cx
	add [word ptr bx], 55
	mov [bx+2], dx
	mov [bx+4], cx
	add [word ptr bx+4], 55
	mov [bx+6], dx
	add [word ptr bx+6], 55
	mov [bx+8], cx
	mov [bx+10], dx
	add [word ptr bx+10], 55
	mov [bx+12], cx
	mov [bx+14], dx
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp

proc give_end
	push bp
	mov bp, sp
	add bp, 4
	push bx
	mov bx, [bp]
	sub bx, 2
@@l1 :
	add bx, 2
	cmp [word ptr bx], -1
	jne @@l1
	mov [bp], bx
	add bp, 2
	mov bx, [bp]
	sub bx, 2
l2 :
	add bx, 2
	cmp [word ptr bx], -1
	jne l2
	mov [bp], bx
	pop bx
	pop bp
	ret
endp
proc draw_line_horizon
	push dx 
	push cx
	push bx
	push ax
	push si
	mov dh, 0
	mov dl, [color]
	
@@big_loop :
	cmp [word ptr Ycor], 200
	jae @@end
	mov si, [word ptr Ycor]
	
	push dx
	mov ax, 320
	mul si
	mov si, ax
	pop dx
	add si, 99
	mov ax, [Xcor]
	cmp ax, 100
	jb @@done
	add si, 100
	cmp ax, 200
	jb @@done
	add si, 100
@@done :
	push ax
	mov ax, [Ycor]
	push ax
	call FindLocation
	pop bx
	mov cx, [len]
@@createl :
	mov[es:bx], dl
	inc bx
	cmp bx, si
	jbe @@reg
	sub bx, 99
@@reg :
	loop @@createl
@@second_loop :
	inc dh
	inc[Ycor]
	cmp dh, 5
	jne @@big_loop
@@end :
	pop si
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp 


proc draw_line_vertical
	push dx 
	push cx
	push bx
	push ax
	mov dh, 0
	mov dl, [color]
@@big_loop :
	cmp [word ptr Ycor], 200
	jae @@end
	mov cx,[len]
	cmp [word ptr Ycor], 0
	jnl @@reg
	add cx, [Ycor]
	cmp cx, 0
	jbe @@end
	mov [word ptr Ycor], 0
@@reg :
	mov ax, [Xcor]
	push ax
	mov ax, [Ycor]
	push ax
	call FindLocation
	pop bx

@@createl :
	mov[es:bx], dl
@@loop_without_draw :
	add bx, 320
	cmp bx, 64000
	jae @@endloop
	loop @@createl
@@endloop :
	inc dh
	inc[Xcor]
	cmp dh, 5
	jne @@big_loop
@@end :
	pop ax
	pop bx
	pop cx
	pop dx
	ret
endp 
proc waitms
	push bp
	push cx
	push ax
	mov bp, sp
	add bp, 8
	mov cx, [bp]
	add [time], cx
lms :
	mov ax, 4400
l10 :
	dec ax
	cmp ax, 0
	jne l10
	loop lms
	pop ax
	pop cx
	pop bp
	ret 2
endp 

proc modulo
	push bp
	mov bp, sp
	push dx
	add bp, 4
	push ax
	mov ax, [bp]
	mov dx, [bp+2]
@@decrease_loop :
	cmp ax, dx
	jbe @@end
	sub ax, dx
	jmp @@decrease_loop
	
@@end :
	mov [bp+2], ax
	pop ax
	pop dx
	pop bp
	ret 2
endp


	

proc movallobs2
	push ax
	push bx
	push cx
	push dx
	push si
	mov bx, offset change_obs2
@@big_loop :
	cmp [word ptr bx], -1
	je @@end
	mov si, offset change_cor
	mov cx, 8
@@small_loop :
	mov ax, [bx]
	mov [si], ax
	add si, 2
	add bx, 2
	loop @@small_loop
	call movobs2
	sub bx, 16
	mov dx, 0
	;jmp @@end ;garbage
	mov cx, 4
	cmp [word ptr bx], 100
	jb @@move
	add dx, 100
	cmp [word ptr bx], 200
	jb @@move
	add dx, 100
@@move :
	mov ax, 99
	push ax
	mov ax, [bx]
	sub ax, dx
	add ax, 4
	push ax
	call modulo
	pop ax
	add ax, dx
	mov [bx], ax
	add bx, 4
	loop @@move
	;jmp @@end;garbage
	jmp @@big_loop
@@end :
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp movallobs2
proc movobs2
	push ax
	push bx
	push cx
	push dx
	mov cx,1
@@start_loop :
	mov [word ptr len], 4
	mov ax, [change_cor]
	mov bx, [change_cor+2]
	mov [Xcor], ax
	mov [Ycor], bx
	mov [color], cyan
	call draw_line_horizon
	mov ax, [change_cor+4]
	mov bx, [change_cor+6]
	mov [Xcor], ax
	mov [Ycor], bx
	mov [color], yellow
	call draw_line_horizon
	mov ax, [change_cor+8]
	mov bx, [change_cor+10]
	mov [Xcor], ax
	mov [Ycor], bx
	mov [color], purple
	call draw_line_horizon
	mov ax, [change_cor+12]
	mov bx, [change_cor+14]
	mov [Xcor], ax
	mov [Ycor], bx
	mov [color], red
	call draw_line_horizon
	mov bx, offset change_cor
	add bx, 2
	mov dx, 0
@@higher_heights :
	add [word ptr bx], 30
	add bx, 4
	inc dx
	cmp dx, 4
	jne @@higher_heights
	loop @@start_loop
@@end :
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp 
proc choose_color
	push bp
	mov bp, sp
	add bp, 4
	push ax
	mov ax, 4
	push ax
	mov ax, [bp]
	push ax
	call modulo
	pop ax
		cmp ax, 1
	jne @@a
	mov al, red
	jmp @@end
@@a:
	cmp ax, 2
	jne @@b
	mov al, purple
	jmp @@end
@@b:
	cmp ax, 3
	jne @@c
	mov al, yellow
	jmp @@end
@@c:
	mov al, cyan
@@end :
	mov [bp], ax
	pop ax
	pop bp
	ret
endp
proc movobs3
	push ax
	push bx
	push cx
	push dx
	push si
	mov [word ptr len], 5
	mov bx, offset change_obs3
	mov si, offset obs3
	mov cx, 9
	jmp @@big_loop
@@left :
	mov ax, [bx]
	mov [Xcor], ax
	mov ax, [bx+2]
	mov [Ycor], ax
	call draw_line_vertical
	sub ax, 5
	mov [bx+2], ax
	jmp @@check_conti
@@right:
	mov ax, [bx]
	mov [Xcor], ax
	mov ax, [bx+2]
	mov [Ycor], ax
	call draw_line_vertical
	add ax, 5
	mov [bx+2], ax
	jmp @@check_conti
@@big_loop :
	push cx
	cmp [word ptr bx], -1
	je @@end
	mov cx, 4
@@conti :
	push cx
	call choose_color
	pop ax
	mov [color], al
	mov ax, [si]
	mov dx, [si+2]
	cmp dx, [bx +2]
	jne @@not_top
	add ax, 55
	cmp ax, [bx]
	jne @@top
	jmp @@right
@@not_top :
	add dx, 55
	cmp dx, [bx +2]
	jne @@not_buttom
	cmp ax, [bx]
	je @@left
	jmp @@bottom
	
@@not_buttom :
	cmp ax,[bx]
	jne @@right
	jmp @@left
@@top:
	mov ax, [bx+2]
	mov [Ycor], ax
	mov ax, [bx]
	mov [Xcor], ax
	call draw_line_horizon
	add ax, 5
	mov [bx], ax
	jmp @@check_conti
@@bottom:
	mov ax, [bx+2]
	mov [Ycor], ax
	mov ax, [bx]
	mov [Xcor], ax
	sub ax, 5
	call draw_line_horizon
	mov [bx], ax
@@check_conti :
	add bx, 4
	loop @@conti
	add si, 4
	pop cx
	loop @@big_loop
@@end :
	cmp cx, 0
	jz @@full
	pop cx
@@full :
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp movobs3
proc movallobs3
	push ax
	push bx
	push cx
	push dx
	push si
	
@@end :
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp
proc readkey
	push ax
	mov ah, 1h
	int 16h
	jz @@fin
	mov ah, 0
	int 16h
	cmp ah, 1
	jne @@next
	call escpressed
@@next :
	mov [word ptr index], 0
	cmp ax, [keys]
	je @@end
	inc [word ptr index]
	cmp ax, [keys+2]
	je @@end
	inc [word ptr index]
	cmp ax, [keys+4]
	jne @@fin
@@end :
	call setball
	mov [word ptr velocity], 5
	call assumeball
@@fin :
	pop ax
	ret
endp
proc setball
	push ax
	push bx
	push cx
	push di
	mov bx, [index]
	mov al, [BallColors+bx]
	mov [BallColor], al
	mov cx, 16
	shl bx, 4
	add bx, offset pastballs
	mov di, offset pastball
@@loopastball :
	mov al, [bx]
	mov [di], al
	inc di
	inc bx
	loop @@loopastball
	mov bx, [index]
	shl bx, 1
	mov ax, [velocities+bx]
	mov [velocity], ax
	mov ax, [scoreballs+bx]
	mov [scoreball], ax
	mov ax, [Xballs+bx]
	mov [Xball], ax
	mov ax, [Yballs+bx]
	mov [Yball], ax
	pop di
	pop cx
	pop bx
	pop ax
	ret
endp
proc assumeball
	push ax
	push bx
	push cx
	push di
	mov bx, [index]
	mov al, [BallColor]
	mov [BallColors+bx], al
	shl bx, 4
	add bx, offset pastballs
	mov di, offset pastball
	mov cx, 16
@@loopastball :
	mov al, [di]
	mov [bx], al
	inc di
	inc bx
	loop @@loopastball
	mov bx, [index]
	shl bx, 1
	mov ax, [velocity]
	mov [velocities+bx], ax
	mov ax, [Xball]
	mov [Xballs+bx], ax
	mov ax, [Yball]
	mov [Yballs+bx], ax
	mov ax, [scoreball]
	mov [scoreballs+bx], ax
	pop di
	pop cx
	pop bx
	pop ax
	ret
endp
proc clear_ball
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov cx, 4
	mov dl, [BallColor]
	mov ax, [word ptr Yball]
	mov si, [word ptr Xball]
	dec ax
	mov di, offset pastball
@@big_loop :
	push cx
	mov cx, 4
	inc ax
@@reg :
	push si
	push ax
	call FindLocation
	pop bx
@@small_loop :
	cmp [byte ptr es : bx], dl
	je @@work
	call lose
	pop cx
	jmp @@end
@@work :
	mov dh, [di]
	mov [byte ptr es : bx], dh
	inc di
	inc bx
	loop @@small_loop
	pop cx
	loop @@big_loop
@@end :
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp
proc draw_ball
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	mov cx, 4
	mov ax, [word ptr Yball]
	mov si, [word ptr Xball]
	dec ax
	mov dl, [BallColor]
	mov di, offset pastball
@@big_loop :
	push cx
	mov cx, 4
	inc ax
	cmp ax, -1
	jg @@check
	pop cx
	call bounds
	jmp @@end
@@check :
	cmp ax, 200
	jb @@reg
	call lose
	pop cx
	jmp @@end
@@reg :
	push si
	push ax
	call FindLocation
	pop bx
@@small_loop :
	cmp [es : bx], dl
	je @@good
	cmp [byte ptr es : bx], 0
	je @@good
	call lose
	pop cx
	jmp @@end
@@good :
	mov dh, [es:bx] 
	mov [di], dh
	inc di
	mov [es : bx], dl
	inc bx
	loop @@small_loop
	pop cx
	loop @@big_loop
@@end :
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp
proc mov_ball 
	push ax
	push dx	
	push si
	call setball
	mov dx, [velocity]
	add [scoreball], dx
	test [word ptr velocity], 0
	jge @@l1
	xor dx, dx
	sub dx, [velocity]
@@l2 :
	cmp dx, 3
	jle @@next1
	call clear_ball
	add [word ptr Yball], 3
	call draw_ball
	sub dx, 3
	jmp @@l2
@@next1 :
	call clear_ball
	add [Yball], dx
	call draw_ball
	jmp @@fin
@@l1 :
	cmp dx, 3
	jle @@next
	call clear_ball
	sub [word ptr Yball], 3
	call draw_ball
	sub dx, 3
	jmp @@l1
@@next :
	call clear_ball
	sub [Yball], dx
	call draw_ball
@@fin :
	dec [word ptr velocity]
	call assumeball
	cmp [word ptr cycle], 1
	je @@end
	cmp [word ptr Yball], 100
	jae @@end
	mov ax, 100
	sub ax, [Yball]
	cmp [word  ptr samescreen],1
	jne @@first
	push ax
	call movallscreens
	jmp @@end
@@first :
	cmp [word ptr Xball], 100
	ja @@second
	push ax
	call movscreen1
	jmp @@end
@@second :
	cmp [word ptr Xball], 200
	ja @@third
	push ax
	call movscreen2
	jmp @@end
@@third :
	push ax
	call movscreen3
@@end :
	pop si
	pop dx
	pop ax
	ret
endp
proc bounds
	cmp [word ptr cycle],1 
	je @@gostart
	call lose
	ret
@@gostart :
	call restartball
	call setball
	call draw_ball
	ret
endp
proc lose
	push di
	mov di, [index]
	mov [byte dead+di], 1
	dec [word ptr cccc]
	cmp [word ptr cccc], 0
	jne @@alive
	call finito
@@alive :
	pop di
	ret
endp
proc change_color
	push  ax
	push bx
	call clear_ball
	mov bx, 300h
	call RandomByCs
	mov ah, 0
	push ax
	call choose_color
	pop ax
	mov [BallColor], al
	call draw_ball
	pop bx
	pop ax
	ret
endp

proc OpenShowBmp

	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 
 
	
; input dx filename to open
proc OpenBmpFile					 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile
 
 
 



proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


 
 
proc DrawHorizontalLine	near
	push si
	push cx
DrawLine:
	cmp si,0
	jz ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp DrawLine
	
	
ExitDrawLine:
	pop cx
    pop si
	ret
endp DrawHorizontalLine



proc DrawVerticalLine	near
	push si
	push dx
 
DrawVertical:
	cmp si,0
	jz @@ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	
	 
	
	inc dx
	dec si
	jmp DrawVertical
	
	
@@ExitDrawLine:
	pop dx
    pop si
	ret
endp DrawVerticalLine



; cx = col dx= row al = color si = height di = width 
proc Rect
	push cx
	push di
NextVerticalLine:	
	
	cmp di,0
	jz @@EndRect
	
	cmp si,0
	jz @@EndRect
	call DrawVerticalLine
	inc cx
	dec di
	jmp NextVerticalLine
	
	
@@EndRect:
	pop di
	pop cx
	ret
endp Rect



proc DrawSquare
	push si
	push ax
	push cx
	push dx
	
	mov al,[Color]
	mov si,[SquareSize]  ; line Length
 	mov cx,[Xp]
	mov dx,[Yp]
	call DrawHorizontalLine

	 
	
	call DrawVerticalLine
	 
	
	add dx ,si
	dec dx
	call DrawHorizontalLine
	 
	
	
	sub  dx ,si
	inc dx
	add cx,si
	dec cx
	call DrawVerticalLine
	
	
	 pop dx
	 pop cx
	 pop ax
	 pop si
	 
	ret
endp DrawSquare




 
   
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

 

 
 
proc ShowBMP
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpHeight lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
 
	mov ax,[BmpWidth] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	mov bp, 0
	and ax, 3
	jz @@row_ok
	mov bp,4
	sub bp,ax

@@row_ok:	
	mov cx,[BmpHeight]
    dec cx
	add cx,[BmpTop] ; add the Y on entire screen
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	add di,[BmpLeft]
	cld ; Clear direction flag, for movsb forward
	
	mov cx, [BmpHeight]
@@NextLine:
	push cx
 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpWidth]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory es:di
	mov cx,[BmpWidth]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	sub di,[BmpWidth]            ; return to left bmp
	sub di,SCREEN_WIDTH  ; jump one screen line up
	
	pop cx
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP

proc ShowAxDecimal
       push ax
	   push bx
	   push cx
	   push dx
	   jmp PositiveAx
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   ;mov dl, ','
       ;mov ah, 2h
	   ;int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal
; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. Bl = min (from 0) , BH , Max (till 255)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        Al - rnd num from bl to bh  (example 50 - 150)
; More Info:
; 	Bl must be less than Bh 
; 	in order to get good random value again and agin the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCs
    push es
	push si
	push di
	
	mov ax, 40h
	mov	es, ax
	
	sub bh,bl  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp bh,0
	jz @@ExitP
 
	mov di, [word RndCurrentPos]
	call MakeMask ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
RandLoop: ;  generate random number 
	mov ax, [es:06ch] ; read timer counter
	mov ah, [byte cs:di] ; read one byte from memory (from semi random byte at cs)
	xor al, ah ; xor memory and counter
	
	; Now inc di in order to get a different number next time
	inc di
	cmp di,(EndOfCsLbl - start - 1)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di
	
	and ax, si ; filter result between 0 and si (the nask)
	cmp al,bh    ;do again if  above the delta
	ja RandLoop
	
	add al,bl  ; add the lower limit to the rnd num
		 
@@ExitP:	
	pop di
	pop si
	pop es
	ret
endp RandomByCs
Proc MakeMask    
    push bx

	mov si,1
    
@@again:
	shr bh,1
	cmp bh,0
	jz @@EndProc
	
	shl si,1 ; add 1 to si at right
	inc si
	
	jmp @@again
	
@@EndProc:
    pop bx
	ret
endp  MakeMask




EndOfCsLbl:
END start