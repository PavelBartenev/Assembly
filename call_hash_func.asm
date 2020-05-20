.686
.MODEL FLAT, C
.code

hash_with_asm proc first_letter: dword, size_of_table: dword

    mov ecx, first_letter
	mov ebx, 5381

	hash_start:
		    cmp byte ptr [ecx], 0
		    je hash_end
		    mov edx, ebx
            shl ebx, 3
		    add ebx, edx
		    add ebx, [ecx]
			inc ecx
	jmp hash_start
	hash_end:

	xor edx, edx
	mov eax, ebx
	mov ecx, size_of_table
	div ecx
	mov eax, edx
   
    ret
hash_with_asm endp

end