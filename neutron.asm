    global _start

    section .bss
        heapptr: resq 1 ; reserve 8 bytes to store heap pointer
        heaplimit: resq 1  ; The maximum address we can use before a syscall

    section .data
        hex_chars db '0123456789ABCDEF'

        hxi db "HEX=0x"
        dci db "UINT="
        hxilen equ $ - hxi
        dcilen equ $ - dci

    section .text
        %macro INITIALIZE_HEAP 0
            push rdi
            mov rax, 12
            mov rdi, 0
            syscall
            mov [heapptr], rax
            mov [heaplimit], rax
            pop rdi
            mov rax, [heapptr]
        %endmacro

        %macro MALLOC 1
            ; expects allocation size as argument
            ; returns starting address in rax
            push rbx
            push rdi

            mov rax, [heapptr] ; heapptr in rax, we'll return this
            mov rbx, %1 ; increment length in rbx
            add rbx, rax ; rbx = rbx + rax

            cmp rbx, [heaplimit]
            jle %%allocated
            
            push rax ; save rax state
            mov rdi, rbx
            mov rax, 12
            syscall

            mov [heaplimit], rax
            pop rax ; restore rax state

            %%allocated:
                mov [heapptr], rbx
            
            pop rdi
            pop rbx
        %endmacro

        %macro PRINT 0
            ; expects char* to already be on rsi
            ; expects length to already be on rdx
            push rax
            push rdi

            mov rax, 1  ; sys_write
            mov rdi, 1  ; std_out
            syscall

            pop rdi
            pop rax
        %endmacro

        %macro PRINTLN 0
            ; expects char* to already be on rsi
            push rsi
            push rdx

            mov byte [rsi + rdx], 10 ; add new line to rsi
            inc rdx
            PRINT; call print

            pop rdx
            pop rsi
        %endmacro

        %macro UINT2HEX 1
            ; expects a register name in argument containing the uint
            ; the result is stored in rsi
            ; length is stored in rdx

            section .bss
                %%tmpbuf:    resb 16

            section .text

                push rax
                push rcx
                push rbx

                mov rax, %1
                lea rsi, [%%tmpbuf + 15]
                mov rcx, 0

                %%loop:
                    mov rbx, rax
                    and rbx, 0xF

                    mov bl, [hex_chars + rbx]
                    mov [rsi], bl

                    shr rax, 4
                    inc rcx

                    cmp rax, 0
                    je %%done

                    dec rsi
                    jmp %%loop
                
                %%done:
                    mov rdx, rcx
                
                pop rbx
                pop rcx
                pop rax
        %endmacro

        %macro UINT2STR 1
            ; expects a register name in argument containing the uint
            ; the result is stored in rsi
            ; length is stored in rdx

            section .bss
                %%tmpbuf:    resb 20

            section .text
                push rax
                push rcx
                push rbx
                push rdi

                mov rax, %1
                lea rdi, [%%tmpbuf + 20] ; Start at the very end
                mov rcx, 0
                mov rbx, 10

                %%loop:
                    xor rdx, rdx
                    div rbx
                    add dl, '0'
                    
                    dec rdi              ; Move pointer first
                    mov [rdi], dl
                    inc rcx

                    test rax, rax        ; Faster than cmp rax, 0
                    jnz %%loop
                
                %%done:
                    mov rsi, rdi         ; RSI now points to the first digit
                    mov rdx, rcx
                
                pop rdi
                pop rbx
                pop rcx
                pop rax
        %endmacro

        %macro CONCAT 4
            ; expects 4 registers
            ; register 1 and 2 represent left string length and left string pointer respectively
            ; register 3 and 4 represent right string length and right string pointer respectively
            ; the resultant string is stored in rsi
            ; the resultant length is stored in rdx 
            ; section .bss
            ;     %%concat_buf resb ([%1] + [%3])
            
            section .text

                push rdi
                push rcx
                push rax

                mov rdx, %1
                add rdx, %3

                MALLOC rdx
                ; memory address of malloc start pointer is on rax
                mov rdi, rax

                mov rsi, %2
                mov rcx, %1
                rep movsb

                mov rsi, %4
                mov rcx, %3
                rep movsb

                mov rsi, rax

                pop rax
                pop rcx
                pop rdi
        %endmacro

        _start:
            INITIALIZE_HEAP
            
            ; mov rax, [heapptr]
            UINT2HEX rax
            PRINTLN

            ; mov rax, [heapptr]
            UINT2STR rax
            PRINTLN

            MALLOC 14
            ; mov rax, [heapptr]
            UINT2HEX rax
            PRINTLN

            ; mov rax, [heapptr]
            UINT2STR rax
            PRINTLN

            MALLOC 10
            ; mov rax, [heapptr]
            UINT2HEX rax
            PRINTLN

            ; mov rax, [heapptr]
            UINT2STR rax
            PRINTLN

            mov rax, 60
            mov rdi, 0
            syscall