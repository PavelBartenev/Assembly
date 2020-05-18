locals @@
.model tiny
.code
org 100h
;============================
VIDEOSEG           equ 0b800h

SCREEN_LENGTH      equ 80

COORD_X            equ 10
COORD_Y            equ 8

GROUND_START       equ (80 * COORD_Y + COORD_X) * 2

SHADOW_START       equ (80 * (COORD_Y + 1) + COORD_X + 2) * 2 

FRAME_PLACE        equ (SHADOW_START + 6)

TEXT_PLACE         equ SHADOW_START + (80 * 3 + 13) * 2

FRAME_LENGTH       equ (GROUND_LENGTH - 10)

FRAME_LENGTH_BYTES equ FRAME_LENGTH * 2

FRAME_HEIGHT       equ 14

GROUND_HEIGHT      equ 10

GROUND_LENGTH      equ 50

SHADOW_COLOUR      equ 70h

GROUND_COLOUR      equ 20h

HORIZ_FRAME        equ 205

VERT_EDGE          equ 186

FRAME_COLOUR       equ 21h

NEWLINE_PASS       equ (SCREEN_LENGTH - GROUND_LENGTH) * 2

UL_CORNER          equ 201

UR_CORNER          equ 187

DL_CORNER          equ 200

DR_CORNER          equ 188

N_LETTERS          equ 20
;============================
Start:

    mov si, cx
    mov bx, VIDEOSEG
    mov es, bx

    mov di, SHADOW_START
    mov cx, GROUND_HEIGHT
    xor ax, ax
    mov ah, SHADOW_COLOUR
    mov bx, GROUND_LENGTH
    call Draw_ground

    mov di, GROUND_START
    mov cx, GROUND_HEIGHT
    mov al, ' '
    mov ah, GROUND_COLOUR
    call Draw_ground

    mov di, FRAME_PLACE
    mov cx, FRAME_LENGTH
    mov al, HORIZ_FRAME
    mov ah, FRAME_COLOUR
    mov bx, FRAME_PLACE
    mov dl, FRAME_LENGTH
    mov dh, FRAME_HEIGHT
    mov si, FRAME_HEIGHT
    mov dx, FRAME_LENGTH
    mov bp, FRAME_HEIGHT * SCREEN_LENGTH
    call Draw_frame

    mov cx, N_LETTERS
    mov bx, TEXT_PLACE
    call Print

    mov ax, 4C00h
    int 21h

;======================================
;Draw a rectangle
;Entry: di - high left corner position
;       cx - height of the rectangle
;       ah - color
;       al - char to draw
;       bx - ground length
;Output: rectangle filled with color
;Destroy: si, cx, di        
;======================================
Draw_ground proc
      @@lp:
         mov si, cx
         mov cx, bx

         rep stosw

         mov cx, si
         add di, NEWLINE_PASS
      loop @@lp
      ret
      endp
;======================================
;Drawing a frame
;Entry: di - high left corner position
;       cx, dx - frame length
;       al - char to draw
;       ah - colour
;       si - frame height
;       bx - frame place
;       bp - frame height * screen length
;Output: regtangular frame
;Destroy: di, cx, si, ah ,al
;======================================
Draw_frame proc

      rep stosw

      mov di, bx
      add di, bp
      mov cx, dx

      rep stosw

      mov di, bx
      sub di, 2
      mov byte ptr es:[di], UL_CORNER

      mov di, bx
      add di, dx
      add di, dx
      mov byte ptr es:[di], UR_CORNER

      mov di, bx
      sub di, 2
 
      add di, bp
 
      mov byte ptr es:[di], DL_CORNER

      add di, 2
      add di, dx
      add di, dx
      mov byte ptr es:[di], DR_CORNER

      mov di, bx
      sub di, 2 - SCREEN_LENGTH * 2
      mov cx, si
      sub cx, 4 * 2
      @@lp:
          mov si, cx
          mov cx, dx
          mov byte ptr es:[di], VERT_EDGE
          inc di
          mov byte ptr es:[di], GROUND_COLOUR
          inc di
          mov ah, FRAME_COLOUR
          xor al, al
          rep stosw
          mov byte ptr es:[di], VERT_EDGE
          inc di
          mov byte ptr es:[di], GROUND_COLOUR
          inc di
          mov cx, si
          add di, (SCREEN_LENGTH - 2) * 2
          sub di, dx
          sub di, dx
      loop @@lp
      ret
      endp

;==============================
;Print text
;Entry: cx - number of letters
;       S - string to print
;       bx - first letter position
;Output: text on the screen
;Destroy: cx, si, bx, dl 
;===============================
Print proc
     mov si, 0
     @@lp:
         mov dl, byte ptr [S + si]
         mov byte ptr es:[bx], dl
         inc bx
         mov byte ptr es:[bx], FRAME_COLOUR
         inc bx
         inc si
     loop @@lp
     ret
     endp
   
S: db "Hello world in frame"
end Start 
     
