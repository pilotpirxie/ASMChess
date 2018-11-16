;%include "/usr/local/share/csc314/asm_io.inc"


; the file that stores the initial state
%define BOARD_FILE 'board.txt'

; how to represent everything
%define BLACK_PAWN 'p'

; the size of the game screen in characters
%define HEIGHT 10
%define WIDTH 18

; these keys do things
%define EXITCHAR 'x'

segment .data

	; used to fopen() the board file defined above
	board_file			db BOARD_FILE,0

	; used to change the terminal mode
	mode_r				db "r",0
	raw_mode_on_cmd		db "stty raw -echo",0
	raw_mode_off_cmd	db "stty -raw echo",0

	; called by system() to clear/refresh the screen
	clear_screen_cmd	db "clear",0

	; things the program will print
	help_str			db 13,10,"Controls: ", \
							"Type quit to end game", \
							13,10,10,0
	last_move_str		db	"Move input: ",0

	; variables to hold the move characters
	move1	db	0
	move2	db	0
	move3	db	0
	move4	db	0

segment .bss

	; this array stores the current rendered gameboard (HxW)
	board	resb	(HEIGHT * WIDTH)

segment .text

	global	asm_main
	global  raw_mode_on
	global  raw_mode_off
	global  init_board
	global  render

	extern	system
	extern	putchar
	extern	getchar
	extern	printf
	extern	fopen
	extern	fread
	extern	fgetc
	extern	fclose

asm_main:
	enter	0,0
	pusha
	;***************CODE STARTS HERE***************************

	; put the terminal in raw mode so the game works nicely
	call	raw_mode_on

	; read the game board file into the global variable
	call	init_board

	game_loop:
		; draw the last move display, then the game board
		mov		BYTE[move1], 0
		mov		BYTE[move2], 0
		mov		BYTE[move3], 0
		mov		BYTE[move4], 0
		call	render
		
		; get move from the user
		call	getchar
		mov		BYTE[move1], al
		call	render
		call	getchar
		mov		BYTE[move2], al
		call	render
		call	getchar
		mov		BYTE[move3], al
		call	render
		call	getchar
		mov		BYTE[move4], al
		call	render

		; see if you need to quit
		cmp		BYTE[move1], 'q'
		jne		noQuit
		cmp		BYTE[move2], 'u'
		jne		noQuit
		cmp		BYTE[move3], 'i'
		jne		noQuit
		cmp		BYTE[move4], 't'
		je		game_loop_end
		noQuit:

		; logic for finding first piece
		mov		eax, board
        mov     ebx, eax

		cmp		BYTE[move1], 'A'
		je		move1A
		cmp		BYTE[move1], 'B'
		je		move1B
		cmp		BYTE[move1], 'C'
		je		move1C
		cmp		BYTE[move1], 'D'
		je		move1D
		cmp		BYTE[move1], 'E'
		je		move1E
		cmp		BYTE[move1], 'F'
		je		move1F
		cmp		BYTE[move1], 'G'
		je		move1G
		cmp		BYTE[move1], 'H'
		je		move1H
		jmp		invalidMove

		move1A:
			add		eax, 2
			jmp		move2Start
		move1B:
			add		eax, 4
			jmp		move2Start
		move1C:
			add		eax, 6
			jmp		move2Start
		move1D:
			add		eax, 8
			jmp		move2Start
		move1E:
			add		eax, 10
			jmp		move2Start
		move1F:
			add		eax, 12
			jmp		move2Start
		move1G:
			add		eax, 14
			jmp		move2Start
		move1H:
			add		eax, 16
			jmp		move2Start

		move2Start:
		cmp		BYTE[move2], '1'
		je		move2_1
		cmp		BYTE[move2], '2'
		je		move2_2
		cmp		BYTE[move2], '3'
		je		move2_3
		cmp		BYTE[move2], '4'
		je		move2_4
		cmp		BYTE[move2], '5'
		je		move2_5
		cmp		BYTE[move2], '6'
		je		move2_6
		cmp		BYTE[move2], '7'
		je		move2_7
		cmp		BYTE[move2], '8'
		je		move2_8
		jmp		invalidMove

		move2_1:
			add		eax, 0
			jmp		move3Start
		move2_2:
			add		eax, 18
			jmp		move3Start
		move2_3:
			add		eax, 36
			jmp		move3Start
		move2_4:
			add		eax, 54
			jmp		move3Start
		move2_5:
			add		eax, 72
			jmp		move3Start
		move2_6:
			add		eax, 90
			jmp		move3Start
		move2_7:
			add		eax, 108
			jmp		move3Start
		move2_8:
			add		eax, 126
			jmp		move3Start

		; logic for finding second piece
        ;mov     ebx, board
		move3Start:
		cmp		BYTE[move3], 'A'
		je		move3A
		cmp		BYTE[move3], 'B'
		je		move3B
		cmp		BYTE[move3], 'C'
		je		move3C
		cmp		BYTE[move3], 'D'
		je		move3D
		cmp		BYTE[move3], 'E'
		je		move3E
		cmp		BYTE[move3], 'F'
		je		move3F
		cmp		BYTE[move3], 'G'
		je		move3G
		cmp		BYTE[move3], 'H'
		je		move3H
		jmp		invalidMove

		move3A:
			add		ebx, 2
			jmp		move4Start
		move3B:
			add		ebx, 4
			jmp		move4Start
		move3C:
			add		ebx, 6
			jmp		move4Start
		move3D:
			add		ebx, 8
			jmp		move4Start
		move3E:
			add		ebx, 10
			jmp		move4Start
		move3F:
			add		ebx, 12
			jmp		move4Start
		move3G:
			add		ebx, 14
			jmp		move4Start
		move3H:
			add		ebx, 16
			jmp		move4Start

        move4Start:
        cmp		BYTE[move4], '1'
		je		move4_1
		cmp		BYTE[move4], '2'
		je		move4_2
		cmp		BYTE[move4], '3'
		je		move4_3
		cmp		BYTE[move4], '4'
		je		move4_4
		cmp		BYTE[move4], '5'
		je		move4_5
		cmp		BYTE[move4], '6'
		je		move4_6
		cmp		BYTE[move4], '7'
		je		move4_7
		cmp		BYTE[move4], '8'
		je		move4_8
		jmp		invalidMove

		move4_1:
			add		ebx, 0
			jmp		endChecking
		move4_2:
			add		ebx, 18
			jmp		endChecking
		move4_3:
			add		ebx, 36
			jmp		endChecking
		move4_4:
			add		ebx, 54
			jmp		endChecking
		move4_5:
			add		ebx, 72
			jmp		endChecking
		move4_6:
			add		ebx, 90
			jmp		endChecking
		move4_7:
			add		ebx, 108
			jmp		endChecking
		move4_8:
			add		ebx, 126
			jmp		endChecking

        endChecking:

        ; TODO: Validate if a piece exists in spot eax

        ; TODO: determine which piece exists in spot eax

        ; TODO: determine if there is a piece in spot ebx

        ; TODO: determine if piece eax can move to spot ebx given whether or not a piece exists in ebx

        ; put piece 1 in the spot of piece 2
        mov     cl, BYTE[eax]
        mov     BYTE[ebx], cl
        mov     BYTE[eax], ' '
       

		invalidMove:
            ; just loop back up to grab input again, maybe add some output later (TODO?)

	jmp		game_loop
	game_loop_end:

	; restore old terminal functionality
	call raw_mode_off

	;***************CODE ENDS HERE*****************************
	popa
	mov		eax, 0
	leave
	ret

; === FUNCTION ===
raw_mode_on:

	push	ebp
	mov		ebp, esp

	push	raw_mode_on_cmd
	call	system
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; === FUNCTION ===
raw_mode_off:

	push	ebp
	mov		ebp, esp

	push	raw_mode_off_cmd
	call	system
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; === FUNCTION ===
init_board:

	push	ebp
	mov		ebp, esp

	; FILE* and loop counter
	; ebp-4, ebp-8
	sub		esp, 8

	; open the file
	push	mode_r
	push	board_file
	call	fopen
	add		esp, 8
	mov		DWORD [ebp-4], eax

	; read the file data into the global buffer
	; line-by-line so we can ignore the newline characters
	mov		DWORD [ebp-8], 0
	read_loop:
	cmp		DWORD [ebp-8], HEIGHT
	je		read_loop_end

		; find the offset (WIDTH * counter)
		mov		eax, WIDTH
		mul		DWORD [ebp-8]
		lea		ebx, [board + eax]

		; read the bytes into the buffer
		push	DWORD [ebp-4]
		push	WIDTH
		push	1
		push	ebx
		call	fread
		add		esp, 16

		; slurp up the newline
		push	DWORD [ebp-4]
		call	fgetc
		add		esp, 4

	inc		DWORD [ebp-8]
	jmp		read_loop
	read_loop_end:

	; close the open file handle
	push	DWORD [ebp-4]
	call	fclose
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; === FUNCTION ===
render:

	push	ebp
	mov		ebp, esp

	; two ints, for two loop counters
	; ebp-4, ebp-8
	sub		esp, 8

	; clear the screen
	push	clear_screen_cmd
	call	system
	add		esp, 4


	push	last_move_str
	call	printf
	add		esp, 4
	push	DWORD[move1]
	call	putchar
	add		esp, 4
	push	DWORD[move2]
	call	putchar
	add		esp, 4
	push	DWORD[move3]
	call	putchar
	add		esp, 4
	push	DWORD[move4]
	call	putchar
	add		esp, 4

	; print the help information
	push	help_str
	call	printf
	add		esp, 4

	; outside loop by height
	; i.e. for(c=0; c<height; c++)
	mov		DWORD [ebp-4], 0
	y_loop_start:
	cmp		DWORD [ebp-4], HEIGHT
	je		y_loop_end

		; inside loop by width
		; i.e. for(c=0; c<width; c++)
		mov		DWORD [ebp-8], 0
		x_loop_start:
		cmp		DWORD [ebp-8], WIDTH
		je 		x_loop_end

			; print whatever's in the buffer
			mov		eax, [ebp-4]
			mov		ebx, WIDTH
			mul		ebx
			add		eax, [ebp-8]
			mov		ebx, 0
			mov		bl, BYTE [board + eax]
			push	ebx
			call	putchar
			add		esp, 4

		inc		DWORD [ebp-8]
		jmp		x_loop_start
		x_loop_end:

		; write a carriage return (necessary when in raw mode)
		push	0x0d
		call 	putchar
		add		esp, 4

		; write a newline
		push	0x0a
		call	putchar
		add		esp, 4

	inc		DWORD [ebp-4]
	jmp		y_loop_start
	y_loop_end:

	mov		esp, ebp
	pop		ebp
	ret
