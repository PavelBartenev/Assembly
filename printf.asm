global _start

SECTION .text

_start:

;____________________________
;mov rbx, rsp

;push msg
;push '!'
;push '@'
;push msg2
;push msg3
;push 3456
;push msg

;push msg4

;push 3802

; msg4 3802 100 '!' 127
;____________________________

push 127

push '!'

push 100

push 3802

push msg4

push commands

call Printf

lea rsp, [rsp + r15 * 8]

mov rax, 60
xor rdi, rdi
syscall

;=================================================
;Printf
;Input: parameters in the stack
;Output: printed message on the screen
;Destroy: all registers 
;=================================================

Printf:

xor r15, r15

push rbp
mov rbp, rsp

mov rbx, rbp

add rbx, 16

mov r8, [rbx]

printf_step:
      cmp byte [r8], 0
      je printf_end

      cmp byte [r8], '%'
      je var_process

      mov rax, 1
      mov rdi, 1
      mov rsi, r8
      mov rdx, 1    
      syscall
      inc r8
      jmp printf_step

      var_process:
           inc r8
           inc r15

           add rbx, 8   

           cmp byte [r8], '%'
           je Procent_process   

           xor rax, rax
           mov al, byte [r8]
           sub al, 'b'

           call [percents_table + rax * 8]

           inc r8
           jmp printf_step
        
           Procent_process:
               mov rax, 1
               mov rdi, 1
               mov rsi, r8
               mov rdx, 1    
               syscall
               inc r8
               sub rbx, 8 ;!!!
               jmp printf_step

printf_end:


mov rsp, rbp
pop rbp

ret

;=====================================
;Input: rbx - pointer to the stack with str
;Output: Print str on the screen
;Destroy: rax, rdi, rsi, rcx, rdx
;=====================================
Print_str:

      mov r10, [rbx]
      mov rax, 1
      mov rdi, 1

   str_loop:
      cmp byte [r10], 0
      je end_str

      mov rsi, r10
      mov rdx, 1
      syscall

      inc r10
   jmp str_loop
   
   end_str:
      ret

;=====================================
;Input: rbx - pointer to the stack with str
;Output: rdx - number of symbols in str
;Destroy: rcx, rdx
;=====================================
Strlen:
       
      xor rdx, rdx
      mov rcx, [rbx]

      next_symbol:
            cmp byte [rcx], 0
            je end_of_str
            inc rdx
            inc rcx
            jmp next_symbol

      end_of_str:
      
      ret
;=========================================
;Input: rbx - pointer to the stack with char
;Output: print char on the screen
;Destroy: rax, rdi, rsi, rdx
;========================================
Print_char:

      mov rax, 1
      mov rdi, 1
      
      mov rsi, rbx
      mov rdx, 1
             
      syscall
               
      ret    

;===========================================
;Input: rbx - pointer to the number
;Output: printed number on the screen. Numeral system is based
;on entry point
;Destroy: r12, r9, r14, rcx, rdx, rax, r10, r11, rsi, rdi, r13
;===========================================
Print_bin:
     
      mov rcx, 1       ; mask len
      mov r12, Bin_mask
      shl r12, 63
      mov r9, 64       ; how many times to put mask
      jmp Pars_num 

Print_oct:

      mov rcx, 3
      mov r12, Oct_mask
      shl r12, 60
      mov r9, 21
      jmp Pars_num

Print_hex:

      mov rcx, 4
      mov r12, Hex_mask
      shl r12, 60
      mov r9, 16
      jmp Pars_num
   
  Pars_num:
      
      mov r10, [rbx]
      xor r14, r14
 
      next_digit:
    
          cmp r9, 0
          je stop_pars

          mov r11, r12
          and r11, r10
          mov r13, rcx
          mov rax, rcx
          dec r9
          mov rcx, r9
          inc r9
          mul rcx
          mov rcx, rax
          shr r11, cl
          mov rcx, r13

          add r11, digit_store

          cmp byte [r11], '0'
          je further

          inc r14

          further:
          cmp r14, 0
          je skip_null

          mov rsi, r11
          mov rax, 1
          mov rdi, 1
          mov rdx, 1
          mov r13, rcx
          syscall
          
          skip_null:
          mov rcx, r13
          shr r12, cl
          dec r9
      jmp next_digit

  stop_pars:
      ret
;=======================================
;Input: rbx - pointer to the number
;Output: printed decimal number on the screen
;Destroy: r12, r9, r14, rcx, rdx, rax, r10, r11, rsi, rdi
;=====================================
Print_dec: 
         mov r12, [rbx]
         mov r9, 20 
         xor r14, r14

         next_dec_digit:

             cmp r9, 0
             je dec_stop
             
             mov rcx, r9
             dec rcx
             xor rdx, rdx
             mov rax, 1
             dec_power:
                cmp rcx, 0
                je stop_dec_power
     
                imul rax, 10
                dec rcx
                jmp dec_power
             stop_dec_power:

             mov r10, rax ; 10^(n-1)
             imul rax, 10
             mov r11, rax ; 10^n
             
             xor rdx, rdx
             mov rax, r12
             idiv r11

             mov rax, rdx
             xor rdx, rdx
             idiv r10

             add rax, digit_store

             cmp byte [rax], '0'
             je further_dec
 
             inc r14

             further_dec:
             cmp r14, 0
             je skip_dec_null

             mov rsi, rax
             mov rax, 1
             mov rdi, 1
             mov rdx, 1
             syscall
            
             skip_dec_null:

             dec r9
             jmp next_dec_digit

        dec_stop:
           ret
          
         
SECTION .data


percents_table:  dq Print_bin
                 times ('c' - 'b' - 1) dq 0
                 dq Print_char
                 times ('d' - 'c' - 1) dq 0
                 dq Print_dec
                 times ('o' - 'd' - 1) dq 0
                 dq Print_oct
                 times ('s' - 'o' - 1) dq 0
                 dq Print_str
                 times ('x' - 's' - 1) dq 0
                 dq Print_hex



Oct_mask equ 7
Hex_mask equ 15
Bin_mask equ 1

msg: db 10, "Hello world with more and more letters!", 10, 0

msg2: db "Good night", 10, 0

msg3: db "Sleep tight", 10, 0

msg4: db "love", 0

; msg4 3802 100 '!' 127

new_commands: db "%b", 0

commands: db "I %s %x. %d%%%c%b", 10, "Just because I could...", 0

our_str: db "Tut polnaya %s Pashi", 0

freedom: db "svoboda", 0

digit_store: db "0123456789ABCDEF", 0
