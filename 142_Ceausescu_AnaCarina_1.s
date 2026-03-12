.data
v: .space 1024
nr_operatii: .space 4
cod_operatie: .space 4
nr_fisiere: .space 4
prim_x: .space 4
prim_y: .space 4
ult_x: .space 4 
ult_y: .space 4
fd: .space 4
size_kb: .space 4
formatPrintf_134: .asciz "%d: ((%d, %d), (%d, %d))\n"
formatPrintf_2: .asciz "((%d, %d), (%d, %d))\n"
formatScanf: .asciz "%d \n"
formatPrintf: .asciz "%d \n "
formatEndline: .asciz "\n" 
index_max: .space 4
opt: .long 8
x: .space 4



.text

ADD:
    mov $0, %ecx
    mov %ecx, prim_x
    mov %ecx, ult_x
    mov %ecx, prim_y 
    mov %ecx, ult_y

    # folosesc %eax pt size_kb
    mov size_kb, %eax
    add $7, %eax
    mov $0, %edx
    mov $8, %ebx
    div %ebx
    mov $0, %ebx
    mov %eax, size_kb
    # size_kb= size_kb / 8 (aproximare superioara)

    mov $0, %eax
    mov $0, %edx

    lea v, %edi # retin adresa vectorului in edi
    mov $1048576, %esi 
    sub size_kb, %esi
    inc %esi
    mov %esi, index_max
    
    mov $0, %esi
    
    # o sa parcurg vectorul pana la 1024^2-size_kb+1
    while_add_1:
        cmp index_max, %ecx
        je ADD_exit

        # verific daca v[ecx] == 0
        if_add_1:
            movb (%edi, %ecx, 1), %bl
            cmpb $0, %bl
            jne exit_if_add_1

            # iau un contor %esi sa numar daca am destule zerouri 
            mov $1, %esi

            # o sa folosesc eax pt a retine coordonata x
            mov $0, %edx
            mov %ecx, %eax
            mov $8, %ebx
            div %ebx
            mov $0, %ebx
            mov %eax, x

            # merg cu contorul pana ajung la size_kb
            while_add_2:
                # daca indexul a ajuns la finalul vectorului
                cmp $1048576, %ecx
                jge nu_mai_cresc

                # daca contorul a ajuns la val size_kb
                cmp size_kb, %esi
                je nu_mai_cresc

                # daca am trecut pe urm rand
                mov %ecx, %eax
                mov $8, %ebx
                div %ebx
                mov $0, %ebx
                cmp x, %eax
                jne nu_mai_cresc

                # daca v[ecx]!=0
                movb (%edi, %ecx, 1), %bl
                cmpb $0, %bl
                jne nu_mai_cresc

                inc %esi
                inc %ecx
                jmp while_add_2

            nu_mai_cresc:
                # verific daca sunt pe ce rand am inceput
                mov %ecx, %eax
                mov $8, %ebx
                div %ebx
                mov $0, %ebx
                cmp x, %eax
                jne while_add_1

                # verific daca am destul loc ( cnt==size_kb)
                cmp size_kb, %esi
                jne while_add_1
                push size_kb
                push $formatPrintf
                call printf
                add $8, %esp

                mov $0, %edx
                mov %ecx, %eax
                mov $8, %ebx
                div %ebx
                mov $0, %ebx
                mov %edx, ult_y
                mov %eax, ult_x

                while_add_3:
                    # ies din loop cand contorul ajunge 0
                    cmp $0, %esi
                    je prima_poz
                    
                    mov fd, %eax
                    movb %al, (%edi, %ecx, 1)
                    dec %ecx
                    dec %esi
                    jmp while_add_3

                prima_poz:
                    inc %ecx
                    mov $0, %edx
                    mov %ecx, %eax
                    mov $8, %ebx
                    div %ebx
                    mov $0, %ebx
                    mov %edx, prim_y
                    mov %eax, prim_x
                    jmp ADD_exit
                
        exit_if_add_1:
            inc %ecx
            jmp while_add_1

    ADD_exit:
        # afisez fd: ((prim_x, prim_y), (ult_x, ult_y))
        push ult_y
        push ult_x
        push prim_y
        push prim_x
        push fd
        push $formatPrintf_134
        call printf
        add $24, %esp
        ret

GET:

DELETE:

DEFRAG:


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

            push fd 
        
            call DELETE
            add $4, %esp 
        
            mov $0, %ecx
            jmp citesc_fiecare_operatie

        defrag_et:
            call DEFRAG
            jmp citesc_fiecare_operatie

et_exit:
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80