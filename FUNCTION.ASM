locals @@
.model tiny
.code
org 100h
Start:


   mov	di, offset memchr_test
	mov	cx, 04h
	mov	al, 0ch

	call	Memchr
   
 ;_________________________________________   
   mov di, offset strlen_test

   call Strlen 
 ;________________________________________
   mov al, 's'
   mov di, offset strchr_test
  
   call strchr
 ;________________________________________

memchr_test:  db 0bh, 0dh, 0ch, 0fh
strlen_test: db 'hello', 00h
strchr_test: db 'find something', 00h
;==============================
;Finding the first occurence of the character in the array
;Entry: es:di - pointer to the array
;       al - code of the searched symbol       
;       cx - number of characters to view
;Output: di - address of the searched symbol    
;Destruct: cx, di
;==============================
Memchr proc
          cld
          repne scasb
          jne @@stop
          dec di
          
@@stop:   ret

memchr endp

;===============================
;Fill the block of bytes with character
;Entry: es:di - pointer to the memory block
;       cx - number of bytes to fill
;       al - code of the character
;Output: no output
;Destruct: cx, di
;===============================
Memset proc
   cld
   rep stosb
   ret
Memset endp

;===============================
;Copy charaters from one memory block to another
;Entry: ds:si - sourse
;       es:di - destination
;       cx - number of symbols
;Output: no output
;Destruct: si, di, cx
;===============================
Memcpy proc
   cld
   rep movsb 
   ret
Memcpy endp

;===============================
;Compare two strings
;Entry: ds:si - first string
;       es:di - second string
;       cx - number of symbols to compare
;Output: in flags
;Destruct: si, di, cx
;===============================
Memcmp proc
   cld
   repe cmpsb
   ret
Memcmp endp

;===============================
;Return the length of the string
;Entry: es:di - string with the 0 byte at the end
;Output: string length in cx
;Destruct: cx, bx, al, di
;===============================
Strlen proc
    cld
    mov cx, MAX_LENGTH
    xor al, al
    
    repne scasb
    
    xor cx, MAX_LENGTH
    dec cx
    
    ret
Strlen endp
    
;================================
;Find the character in the array
;Entry: es:di - pointer to the string 
;       al - character to find
;Output: di - address of first occurence of the searched symbol 
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
     
     dec di
     ret
Strchr endp

;===============================
;Find the last occurence of the character in the array
;Entry: es:di - pointer to the string
;       al - character to find
;Output: di - pointer to the last occurence of the character
;Destruct: ax, bx, cx, di
;===============================
Strrchr proc
      cld
      mov ah, al
      call Strlen
      mov al, ah   
      sub di, 2
      
      std
      repne scasb
      inc di
      
      ret
Strrchr endp 

;===============================
;Copy one string to another
;Entry: ds:si - source string
;       es:di - destination string
;Output: string copy
;Destruct: al, cx, di, si
;===============================
Strcpy proc
       cld   
 @@cycle:
       cmp byte ptr ds:[si], 00h
       je @@end
       movsb
 loop @@cycle

 @@end:   
       mov byte ptr es:[di], 00h
       ret
       
Strcpy endp

;===============================
;Compare lengths of two strings
;Entry: es:di -  the first string
;       ds:si - the second string
;Output: result in flags
;Destruct: cx, bx, al, di, si
;=============================== 
Strcmp proc
    cld
@@cycle:
    cmpsb
    call Strlen
    mov di, offset str1
    repe cmpsb

    ret
Strcmp endp
