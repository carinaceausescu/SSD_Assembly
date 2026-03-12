
.data
v: .space 1024
nr_operatii: .space 4
index_max: .space 4
cod_operatie: .space 4
nr_fisiere: .space 4
prima_poz: .space 4
ult_poz: .space 4
fd: .space 4
size_kb: .space 4
formatPrintf_134: .asciz "%d: (%d, %d)\n"
formatPrintf_2: .asciz "(%d, %d)\n"
formatScanf: .asciz "%d \n"
formatPrintf: .asciz "%d \n "
formatEndline: .asciz "\n" 
fd2: .space 1

.text

ADD:
    mov $0, %ecx
    mov %ecx, prima_poz
    mov %ecx, ult_poz

    # folosesc %eax pt size_kb
    mov size_kb, %eax
    add $7, %eax
    mov $0, %edx
    mov $8, %ebx
    div %ebx
    mov %eax, size_kb
    # size_kb= size_kb / 8 (aproximare superioara)

    lea v, %edi # retin adresa vectorului in edi
    mov $1024, %esi 
    sub size_kb, %esi
    inc %esi
    
    # o sa parcurg vectorul pana la 1024-size_kb+1
    while_add_1:
        cmp %esi, %ecx
        je ADD_exit

        mov $0, %edx

        # verific daca v[ecx] == 0
        if_add_1:
            movb (%edi, %ecx, 1), %dl
            cmpb $0, %dl
            jne exit_if_add_1

            # iau un contor %ebx sa numar daca am destule zerouri 
            mov $1, %ebx

            # merg cu contorul pana ajung la size_kb
            while_add_2:
                cmp $1024, %ecx
                jge nu_incape
                cmp size_kb, %ebx
                jge if_add_3
                
                # verific daca v[ecx] == 0
                if_add_2:
                    movb (%edi, %ecx, 1), %dl
                    cmpb $0, %dl
                    jne if_add_3

                    # cresc contorul ebx si indexul ecx
                    inc %ebx
                    inc %ecx

                jmp while_add_2

            # daca contorul ebx a ajuns la size_kb pun val fd in vector
            if_add_3:
                movb (%edi, %ecx, 1), %dl
                cmpb $0, %dl
                jne exit_if_add_1
                
                cmp size_kb, %ebx
                jne exit_if_add_1

                mov %ecx, ult_poz
                    
               # pun val fd in vector pana ajunge contorul ebx sa fie 0
                while_add_3:
                    cmp $0, %ebx
                    jle exit_while_add_3

                    # v[ecx]=fd
                    movb fd, %dl
                    movb %dl, (%edi, %ecx, 1)

                    dec %ebx
                    dec %ecx

                    jmp while_add_3

                exit_while_add_3:
                    inc %ecx
                    mov %ecx, prima_poz
                    jmp ADD_exit


        exit_if_add_1:
            inc %ecx
            jmp while_add_1

        nu_incape:
            mov $0, %esi
            mov %esi, prima_poz
            mov %esi, ult_poz
 
    ADD_exit:
        # afisez fd:(prima_poz, ult_poz)
        push ult_poz
        push prima_poz
        push fd
        push $formatPrintf_134
        call printf
        add $16, %esp
        ret

    
GET:
    mov $0, %eax
    mov %eax, prima_poz
    mov %eax, ult_poz
    mov $0, %ecx # indexul in vector
    while_get_1:
        cmp $1024, %ecx
        jge GET_exit

        movb (%edi, %ecx, 1), %al
        cmpb fd, %al
        jne cresc_indexul_2

        mov %ecx, prima_poz

        while_get_2:
            movb (%edi, %ecx, 1), %al
            cmpb fd, %al
            jne exit_while_get_2

            inc %ecx
            jmp while_get_2

        exit_while_get_2:
            dec %ecx
            mov %ecx, ult_poz
            jmp GET_exit
        
        cresc_indexul_2:
            inc %ecx
            jmp while_get_1
        
    GET_exit:
        push ult_poz
        push prima_poz
        push $formatPrintf_2
        call printf 
        add $12, %esp # am afisat (prima_poz, ult_poz)
        ret




DELETE:
    lea v, %edi
    mov $0, %ecx

    while_stergere:
        cmp $1024, %ecx
        je reset_index

        mov $0, %eax
        movb (%edi, %ecx, 1), %al
        cmp fd, %eax
        jne skip_block

        movb $0, %bl
        movb %bl, (%edi, %ecx, 1) # inlocuiesc val fd cu val 0

        skip_block:
            inc %ecx
            jmp while_stergere

    reset_index:
        mov $0, %ecx

    while_afisare:
        cmp $1024, %ecx
        je DELETE_exit

        lea v, %edi
        movb (%edi, %ecx, 1), %al
        cmpb $0, %al
        je skip_afisare

        movb %al, fd2
        mov %ecx, prima_poz

        caut_ult_poz:
            cmp $1024, %ecx
            je set_ult_poz

            cmpb (%edi, %ecx, 1), %al
            jne set_ult_poz

            inc %ecx
            jmp caut_ult_poz

        set_ult_poz:
            dec %ecx
            mov %ecx, ult_poz
            jmp afisare_delete

        afisare_delete:
            push ult_poz
            push prima_poz
            push fd2
            push $formatPrintf_134
            call printf
            add $16, %esp

        caut_urm_val_fd2:
            mov ult_poz, %ecx
            inc %ecx
            mov $0, %eax
            mov %eax, prima_poz
            mov %eax, ult_poz
            movb %al, fd2
            jmp while_afisare

        skip_afisare:
            inc %ecx
            jmp while_afisare

    DELETE_exit:
        ret
DEFRAG:
    mov $0, %ecx
    mov $0, %ebx
    lea v, %edi
    mov $0, %eax
    mov $0, %esi

    vector_plin:
        cmp $1024, %ecx
        je verific_vector_plin
        movb (%edi, %ecx, 1), %al

        cmpb $0, %al
        je am_zerouri

        inc %ecx
        inc %esi
        jmp vector_plin

    verific_vector_plin:
        mov $0, %ecx
        cmp $1024, %esi
        je while_afisare_defrag

    am_zerouri:
        mov $0, %ecx
        mov $0, %esi

    while_defrag_1:
        cmp $1024, %ecx
        je while_defrag_2

        movb (%edi, %ecx, 1), %al
        cmpb $0, %al
        je inc_ecx

        movb %al, (%edi, %ebx, 1)
        inc %ebx

        inc_ecx:
            inc %ecx
            jmp while_defrag_1

    while_defrag_2:
        cmp $1024, %ebx
        je while_afisare_defrag

        mov $0, %ecx
        movb %cl, (%edi, %ebx, 1)
        inc %ebx
        jmp while_defrag_2

    mov $0, %ecx
    mov $0, %eax

    while_afisare_defrag:
        mov $0, %eax
        cmp $1024, %ecx
        je DEFRAG_exit

        lea v, %edi
        movb (%edi, %ecx, 1), %al
        cmpb $0, %al
        je skip_afisare_defrag

        movb %al, fd2
        mov %ecx, prima_poz

        caut_ult_poz_defrag:
            cmp $1024, %ecx
            je set_ult_poz_defrag

            cmpb (%edi, %ecx, 1), %al
            jne set_ult_poz_defrag

            inc %ecx
            jmp caut_ult_poz_defrag

        set_ult_poz_defrag:
            dec %ecx
            mov %ecx, ult_poz
            jmp afisare_defrag

        afisare_defrag:
            push ult_poz
            push prima_poz
            push fd2
            push $formatPrintf_134
            call printf
            add $16, %esp

        caut_urm_val_fd2_defrag:
            mov ult_poz, %ecx
            inc %ecx
            mov $0, %eax
            mov %eax, prima_poz
            mov %eax, ult_poz
            movb %al, fd2
            jmp while_afisare_defrag

        skip_afisare_defrag:
            inc %ecx
            jmp while_afisare_defrag

    DEFRAG_exit:
        ret
    

.global main

main:
    lea v, %edi # retin adresa de memorie a vectorului
    push $nr_operatii
    push $formatScanf
    call scanf 
    add $8, %esp

    citesc_fiecare_operatie:
        mov $0, %eax
        cmp %eax, nr_operatii
        je et_exit
        mov $1, %eax
        sub %eax, nr_operatii

        push $cod_operatie
        push $formatScanf
        call scanf
        add $8, %esp

        mov $1, %eax
        cmp %eax, cod_operatie
        je add_et

        mov $2, %eax
        cmp %eax, cod_operatie
        je get_et

        mov $3, %eax
        cmp %eax, cod_operatie
        je del_et

        mov $4, %eax
        cmp %eax, cod_operatie
        je defrag_et

        add_et:
            push $nr_fisiere
            push $formatScanf
            call scanf
            add $8, %esp # am citit nr_fisiere

            citesc_fiecare_add:
                mov nr_fisiere, %eax
                cmp $0, %eax
                je citesc_fiecare_operatie
                mov $1, %eax
                sub %eax, nr_fisiere
                mov $0, %eax

                push $fd
                push $formatScanf
                call scanf
                add $8, %esp # am citit fd

                push $size_kb
                push $formatScanf
                call scanf
                add $8, %esp # am citit size_kb

                push size_kb
                push fd
                call ADD 
                add $8, %esp
                mov $0, %eax
                mov $0, %ebx
                mov $0, %ecx
                mov $0, %edx
                jmp citesc_fiecare_add

        get_et:
            push $fd
            push $formatScanf
            call scanf
            add $8, %esp # am citit fd

            push fd
            call GET 
            add $4, %esp
            mov $0, %ecx
            jmp citesc_fiecare_operatie

        del_et:
            push $fd
            push $formatScanf
            call scanf
            add $8, %esp # am citit fd

            push fd # pornesc contorul care ar trebui sa ajunga la val din size_kb
        
            call DELETE
            add $4, %esp # pornesc contorul care ar trebui sa ajunga la val din size_kb
        
            mov $0, %eax
            mov $0, %ebx
            mov $0, %ecx
            mov $0, %edx
            mov $0, %esi
            mov %eax, fd
            jmp citesc_fiecare_operatie

        defrag_et:
            call DEFRAG
            jmp citesc_fiecare_operatie
            mov $0, %eax
            mov $0, %ebx
            mov $0, %ecx
            mov $0, %edx
            mov $0, %esi

et_exit:
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80