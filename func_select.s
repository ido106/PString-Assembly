#   Ido Aharon

    .section .rodata
    
# for printf
pstrings_length:     .string "first pstring length: %d, second pstring length: %d\n"
invalid_option:      .string "invalid option!\n"
replace_char:        .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
pstrijcpy_mes:       .string "length: %d, string: %s\n"
cmp_result:          .string "compare result: %d\n"
# for scanf
format_char:         .string "%s"
format_num:          .string "%d"

    .section .text

    .global      run_func
    .type        run_func, @function

# defining run_main jump table for switch case
# rsi <- jump number
run_func:
    # save the pointers
    pushq   %rbp
    movq    %rsp, %rbp

    # start jump table from 0
    subq    $50, %rdi
    # if rsi is bigger than 10, we are in the dafault case
    cmpq    $10, %rdi
    ja      .L20
    #if rsi is smaller than 0, default case
    cmpq    $0, %rdi
    jl      .L20
    
    # jump to switch case table
    jmp     *.L1(, %rdi, 8)
    
.L2: # case 50 or 60 - spstrlen
    # caller saved rdx - save second pstring value
    pushq   %rdx
    # get first pstring length (rsi is the first pstring)
    movq    %rsi, %rdi
    call    pstrlen
    # save result in %r10 - caller saved
    movq    %rax, %r10
    
    #restore %rdx
    popq    %rdx
    # get second pstring length
    mov     %rdx, %rdi
    call    pstrlen
    # save result in r11 - caller saved
    movq    %rax, %r11
    
    # call printf for result
    # string format for print
    movq    $pstrings_length, %rdi
    # move first and second parameter
    movq    %r10, %rsi
    movq    %r11, %rdx
    # zero rax
    xorq    %rax, %rax
    # call printf
    call    printf
    
    jmp .L10 #done
.L3: # case 52 - replaceChar
    # save callee save registers- r12 and r13
    pushq   %r12
    pushq   %r13
    # save pstring 1 and pstring 2
    pushq   %rdx
    pushq   %rsi
    
    # scan 2 chars to oldChar and newChar
    
    # FIRST CHAR
    
    # make place to first char
    leaq    -16(%rsp), %rsp
    # zero rax
    xorq    %rax, %rax
    # move format to first argument
    movq    $format_char, %rdi
    # move stack pointer to second argument
    movq    %rsp, %rsi
    # call scanf
    call    scanf
    
    # save result in r12 - callee saved
    xorq    %r12, %r12
    movb    (%rsp), %r12b
    
    # SECOND CHAR
    
    # zero %rax
    xorq    %rax, %rax
    # move format to first argument
    movq    $format_char, %rdi
    # move stack pointer to second argument
    movq    %rsp, %rsi
    # call scanf
    call    scanf
    
    # save result in r13 - callee saved
    xorq    %r13, %r13
    movb    (%rsp), %r13b
    
    # restore rsp
    leaq    16(%rsp), %rsp
    
    # restore first pstr
    popq    %r10
    # make arguments for replaceChar function
    # FIRST PSTR
    movq    %r10, %rdi
    movq    %r12, %rsi
    movq    %r13, %rdx
    # call replaceChar
    call    replaceChar
    #restore second pstr
    popq    %r11
    # save result
    pushq   %rax
    
    
    # SECOND PSTR
    movq    %r11, %rdi
    movq    %r12, %rsi
    movq    %r13, %rdx
    # call replaceChar
    call    replaceChar
    # save result in r11
    movq    %rax, %r11
    
    # PRINT RESULT
    # mov print format
    movq    $replace_char, %rdi
    # mov first char
    movq    %r12, %rsi
    # mov second char
    movq    %r13, %rdx
    # restore first string
    popq    %rcx
    #move second string
    movq    %r11, %r8
    # zero rax
    xorq    %rax, %rax
    call    printf
    
    # restore callee saved registers
    popq    %r13
    popq    %r12
    jmp .L10 #done 
.L4: # case 53 - pstrijcpy
    # callee save
    pushq   %r12
    pushq   %r13
    
    # save the two pstrings
    pushq   %rsi
    pushq   %rdx

    # make place to scanf
    leaq    -16(%rsp), %rsp
    movq    $format_num, %rdi
    movq    %rsp, %rsi
    xorq    %rax, %rax
    call    scanf
    # save result
    xorq    %r12, %r12
    movb    (%rsp), %r12b
    
    # second scanf
    movq    $format_num, %rdi
    movq    %rsp, %rsi
    xorq    %rax, %rax
    call    scanf
    # save result
    xorq    %r13, %r13
    movb    (%rsp), %r13b
    
    # recalculate rsp
    leaq    16(%rsp), %rsp
    
    # restore the pstrings
    popq    %rdx
    popq    %rsi
    
    # save second string
    pushq   %rdx
    
    # call function pstrijcpy
    # keep first pstring
    pushq   %rsi
    
    movq    %rsi, %rdi
    movq    %rdx, %rsi
    movq    %r12, %rdx
    movq    %r13, %rcx
    call    pstrijcpy
    
    # PRINT FIRST STRING
    # move pstring to place
    
    # restore first pstring
    popq    %rsi
    
    # p1 to third argument (only the string)
    leaq    1(%rsi), %rdx
    # length to second argument
    movzx   (%rsi), %rsi
    # format to first argument
    movq    $pstrijcpy_mes, %rdi
    xorq    %rax, %rax
    call    printf
    
    # restore second string
    popq    %rdx
    
    # PRINT SECOND STRING
    # get length
    xorq    %rsi, %rsi
    movb    (%rdx), %sil
    # get string
    leaq    1(%rdx), %rdx
    # get format
    movq    $pstrijcpy_mes, %rdi
    xorq    %rax, %rax
    call    printf
    
    # restore callee
    popq    %r13
    popq    %r12
    jmp .L10 #done 
.L5: # case 54 - swapCase
    # callee save
    pushq   %r14
    pushq   %r15
    
    # move first pstring to r14 and second pstring to r15
    movq    %rsi, %r14
    movq    %rdx, %r15
    
    # SWAP FIRST STRING
    movq    %r14, %rdi
    call    swapCase
    
    # SWAP SECOND STRING
    movq    %r15, %rdi
    call    swapCase
    
    # PRINT FIRST STRING
    # first argument - print format
    movq    $pstrijcpy_mes, %rdi
    # second argument - length
    movzx   (%r14), %rsi
    # third argument - string
    leaq    1(%r14), %rdx
    xorq    %rax, %rax
    call    printf
    
    # PRINT SECOND STRING
    # first argument - print format
    movq    $pstrijcpy_mes, %rdi  
    # second argument - length
    movzx   (%r15), %rsi
    # third argument - string
    leaq    1(%r15), %rdx
    xorq    %rax, %rax
    call    printf
    
    
    # restore callee save
    popq    %r15
    popq    %r14
    
    jmp .L10 #done 
    
.L6: # case 55 - pstrijcmp
    # callee save
    pushq   %r12
    pushq   %r13
    pushq   %r14
    pushq   %r15
    
    # move first pstring to r12
    movq    %rsi, %r12
    # move second pstring to r13
    movq    %rdx, %r13
    
    # GET FIRST CHAR
    
    # make place to first char
    leaq    -16(%rsp), %rsp
    # zero rax
    xorq    %rax, %rax
    # move format to first argument
    movq    $format_num, %rdi
    # move stack pointer to second argument
    movq    %rsp, %rsi
    # call scanf
    call    scanf
    
    # save result in r14
    xorq    %r14, %r14
    movb    (%rsp), %r14b
    
    # GET SECOND CHAR
    
    # zero %rax
    xorq    %rax, %rax
    # move format to first argument
    movq    $format_num, %rdi
    # move stack pointer to second argument
    movq    %rsp, %rsi
    # call scanf
    call    scanf
    
    # save result in r15
    xorq    %r15, %r15
    movb    (%rsp), %r15b
    
    # restore rsp
    leaq    16(%rsp), %rsp
    
    # move arguments for pstrijcmp
    movq    %r12, %rdi
    movq    %r13, %rsi
    movq    %r14, %rdx
    movq    %r15, %rcx
    call    pstrijcmp
    
    # PRINT RESULT
    
    # move format
    movq    $cmp_result, %rdi
    # move result
    movq    %rax, %rsi
    xorq    %rax, %rax
    call    printf
    
    # callee save restore
    popq    %r15
    popq    %r14
    popq    %r13
    popq    %r12
    
    jmp .L10 #done   
.L20: # default case
    # move invalid option string format to printf and reset rax
    movq     $invalid_option, %rdi
    xorq     %rax, %rax
    call     printf


.L10: #done
    # get back pointers
    movq    %rbp, %rsp
    popq    %rbp   
    ret
    
    .align 8
.L1: #jump table
    .quad .L2   #case 50 to L2
    .quad .L20  #case 51 to default
    .quad .L3   #case 52 to L3
    .quad .L4   #case 53
    .quad .L5   #case 54
    .quad .L6   #case 55
    .quad .L20  #case 56 to default
    .quad .L20  #case 57 to default
    .quad .L20  #case 58 to default
    .quad .L20  #case 59 to default
    .quad .L2   #case 60 to L2
