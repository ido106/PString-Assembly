#   319024600 Ido Aharon

.section .rodata
# for scanf
format_len:    .string "%d"
format_str:    .string "%s"
    
.text
.global     run_main
.type       run_main, @function
.extern     run_func

# builds two pstrings due to string1, string2 and lengths recieved
# and sends to run_func function the menu_option address and the
# two pstrings addresses
run_main:
    # save the pointers
    pushq   %rbp
    movq    %rsp, %rbp
    # save callee registers
    pushq   %r12
    pushq   %r13
    pushq   %r14
    
    
    # FIRST STRING
    
    # make place to pstring struct
    leaq    -264(%rsp), %rsp
    
    # mov the format to scanf parameter
    movq    $format_len, %rdi
    # mov pointer to scanf
    movq    %rsp, %rsi
    # call scanf for p1 length
    xor     %rax, %rax
    call    scanf
    
    leaq    1(%rsp), %rdx
    # create arguments for scanf
    # and get p1
    movq    $format_str, %rdi
    movq    %rdx, %rsi
    xor     %rax, %rax
    call    scanf
    
    # save p1 starting point at r12
    mov     %rsp, %r12
    
    # ------------
    # SECOND STRING
    
    # make place to pstring struct
    leaq    -272(%rsp), %rsp
    
    # mov the format to scanf parameter
    movq    $format_len, %rdi
    # mov pointer to scanf
    movq    %rsp, %rsi
    # call scanf for p1 length
    xor     %rax, %rax
    call    scanf
    
    leaq    1(%rsp), %rdx
    # create arguments for scanf
    # and get p1
    movq    $format_str, %rdi
    movq    %rdx, %rsi
    xor     %rax, %rax
    call    scanf
    
    # save p2 starting point at r13
    mov     %rsp, %r13
    
    # GET CHOICE
    
    # make place for choice
    leaq -16(%rsp), %rsp
    
    # arg1- format
    movq    $format_len, %rdi
    # arg2- pointer
    movq    %rsp, %rsi
    # call scanf for choice
    xorq    %rax, %rax
    call    scanf
    
    # save choice in r14 and return rsp
    xorq    %r14, %r14
    movb    (%rsp), %r14b
    leaq    16(%rsp), %rsp
    
    # CALL RUN_FUNC
    
    movq    %r14, %rdi
    movq    %r12, %rsi
    movq    %r13, %rdx
    call    run_func
    
    # -----------
    # END
    
    # ASSURE THAT MEM REALLOCATED
    leaq 536(%rsp), %rsp
    # get back r12, r13
    popq    %r14
    popq    %r13
    popq    %r12
    # get back pointers
    movq    %rbp, %rsp
    popq    %rbp
    ret
    