locals @@
.model tiny
.code
org 100h
Start:


;==============================
;Finding the first occurence of the character in the array
;Entry: es:di - pointer to the array
;       al - code of the searching symbol       
;       cx - number of characters viewed
;Destruct: cx, di
;==============================
Memchr proc
   cld
   repne scasb

   ret
endp

;===============================
;Fill the block of bytes with character
;Entry: es:di - pointer to the memory block
;       cx - number of bytes to fill
;       al - code of the character
;Destruct: cx, di
;===============================
Memset proc
   cld
   rep stosb

   ret
endp

;===============================
;Copy charaters from one memory block to another
;Entry: ds:si - sourse
;       es:di - destination
;       cx - number of symbols
;Destruct: si, di, cx
;===============================
Memcpy proc
   cld
   rep movsb
  
   ret
endp

;===============================
;Compare two strings
;Entry: ds:si - first string
;       es:di - second string
;       cx - number of symbols to compare
;Destruct: si, di, cx
;===============================
Memcmp proc
   cld
   repe cmpsb

   ret
endp

;===============================
;Return the length of the string
;Entry: es:di - string with the 0 byte at the end
;Destruct: cx, bx, al. di
;===============================
Strlen proc
    cld
    mov cx, 0ffffh
    mov bx, cx
    mov al, 0
    repne scasb
    sub cx, bx

    ret
endp
    
;================================
;Find the character in the array
;Entry: es:di - pointer to the string 
;       al - character to find
;Destruct: si, di, ax, cx, bx 
;================================
Strchr proc
     cld
     mov si, di
     mov ah, al
     call Strlen
     mov di, si
     mov al, ah
     repne scasb

     ret
endp

;===============================
;Find the last occurence of the character in the array
;Entry: es:di - pointer to the string
;       al - character to find
;Destruct: ax, bx, cx, di
;===============================
Strrchr proc
      cld
      mov ah, al
      call Strlen
      mov al, ah
      std
      repne scasb

      ret
endp 

;===============================
;Copy one string to another
;Entry: ds:si - source string
;       es:di - destination string
;Destruct: al, cx, di, si
;===============================
Strcpy proc
    cld
    @@cycle:
       cmp byte ptr ds:[si], 00h
       je stop
       movsb
    loop @@cycle

    @@end:   
    stop
    ret
endp

;===============================
;Compare the lengths of two strings
;Entry: str1 - first string
;       str2 - second string
;Destruct: cx, bx, al, di, si
;=============================== 
Strcmp proc
    cld
    mov di, offset str1
    mov si, offset str2
    call Strlen
    mov di, offset str1
    repe cmpsb

    ret
endp