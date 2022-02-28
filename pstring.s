#   Ido Aharon

    .section .rodata
    
# for printf
invalid_input:      .string "invalid input!\n"

    .text

.global      pstrlen
.type        pstrlen, @function

# char pstrlen(Pstring* pstr)
# the function gets a pointer to Pstring and returns it's length
# (the length is in the first byte)
    .type pstrlen, @function
pstrlen:
    xor     %rax, %rax
    movb    (%rdi), %al
    ret
    
.global     replaceChar
.type       replaceChar, @function

# Pstring* replaceChar(Pstring* pstr, char oldChar, char newChar)
#
# the function gets a pointer to pstring and replace all occurences of oldChar with newChar
replaceChar:
    # get pstr len
    call    pstrlen
    # decrease len by 1 (we start at 0)
    dec     %rax
    # if count is smaller than 0, finish
    js      .Finish
.Start:
    # calculate current char address
    leaq    1(%rdi, %rax, 1), %r10
    # check if the current char is oldChar occurence
    cmpb   (%r10), %sil
    # if not equal, pass this part
    jne     .not_equal
    # otherwise, replace oldChar with newChar
    movb    %dl, (%r10)
.not_equal:
    # decrease count
    dec     %rax
    # jump to start if count > 0
    jns     .Start
.Finish:
    # mov the pointer to the pstring to rax
    mov     %r10, %rax
    ret

.global     pstrijcpy    
.type       pstrijcpy, @function

# Pstrong* pstrijcpy (Pstring* dst, Pstring* src, char i, char j)
#
# the function gets two pointers to pstring and copy the sub-pstring
# src[i:j] (inclusive) into dst[i:j] (inclusive) and returns the
# pointer to dst
# we can assume that the dst length will not change after the copy
# if i or j is not in src or dst borders, do not change dst and print an
# error message.
pstrijcpy:
    # check if i is less than 0
    cmpq    $0, %rdx
    jl      .INVALID
    # check if j is less than i
    cmpq    %rdx, %rcx
    jl      .INVALID
    # check if j is greater than dst string length
    xor     %rax, %rax
    movb    (%rdi), %al
    dec     %rax
    cmpq    %rax, %rcx
    jg      .INVALID
    # check if j is greater than src string length
    xor     %rax, %rax
    movb    (%rsi), %al
    dec     %rax
    cmpq    %rax, %rcx
    jg      .INVALID
    
    # VALID FROM HERE
    
    # save r12 - callee saved
    pushq   %r12
    pushq   %r13
    pushq   %r15
    
.ijcpy_start:

    #calculate src[j]
    leaq    1(%rsi, %rcx, 1), %r12
    #calculate dst[j]
    leaq    1(%rdi, %rcx, 1), %r13
    
    # replace dst[j] with src[j] - cannot access memory to memory
    xorq    %r15, %r15
    movb    (%r12), %r15b
    movb    %r15b, (%r13)
    
    # decrease j
    dec     %rcx
    # compare j with i
    cmpq    %rdx, %rcx 
    # jmp to start if j >= i
    jge     .ijcpy_start
    
    # mov %r13 to rax
    movq    %rdi, %rax
    
    # restore callee
    popq    %r15
    popq    %r13
    popq    %r12
    ret
.INVALID:
    # move invalid input string format to printf and reset rax
    movq     $invalid_input, %rdi
    xorq     %rax, %rax
    call     printf
    ret
    
.global     swapCase    
.type       swapCase, @function
    
# Pstring* swapCase(Pstring* pstr)
# the function gets a pointer to a pstring and switches all capital letter
# to reguler letter and the opposite.
swapCase:
    # backup callee save
    pushq   %r12

    # get the last index of the pstring
    call    pstrlen
    dec     %rax
    
    # check if the index is above or equal 0
    cmpq    $0, %rax
    js      .DONE
    
.swap_start:
    # get the address in the A[i]
    leaq    1(%rdi, %rax), %r12
    # get the letter in A[i]
    movzx   (%r12), %r12
    
    # check if the letter is smaller than 65 in ASCII
    cmpq    $65, %r12
    # if r12 < 65 than it's not a letter
    jl  .finish_swap
    
    # HERE WE ARE ABOVE 65
    
    # check if the ASCII value is more than 90,
    # if it does so move to small letters check
    cmpq    $90, %r12
    jg      .small_letters
    
    # HERE WE ARE IN THE SMALL CAPITAL LETTERS
    
    # add the difference (32) of capital letter to get the smaller letter in ascii
    addq    $32, 1(%rdi, %rax)
    jmp     .finish_swap
    
.small_letters:

    # check if the value is less than 97
    cmpq    $97, %r12
    # if its less it's not a letter
    jl      .finish_swap
    # check if the value is greater than 122
    cmpq    $122, %r12
    # if it is it's not a letter
    jg      .finish_swap
    
    # HERE WE ARE IN THE SMALL LETTERS
    
    # sub the difference between the small case to the capital case
    subq    $32, 1(%rdi, %rax)

.finish_swap:
    # compute next i
    dec     %rax
    # check if lower than 0
    cmpq    $0, %rax
    jge     .swap_start
    
.DONE:
    # restore callee save
    popq    %r12
    movq    %rdi, %rax
    
    ret
    

.global     pstrijcmp    
.type       pstrijcmp, @function
    
# int pstrijcmp (Pstring* pstr1, Pstring* pstr2, char i , char j)
# the function gets 2 pointer to pstring and checks lexicographically
# the relation between str1[i:j] and str2[i:j]
pstrijcmp:
    # first check if the indexes are correct
    # check if i is less than 0
    cmpq    $0, %rdx
    jl      .invalid_ijcmp
    # check if j is less than i
    cmpq    %rdx, %rcx
    jl      .invalid_ijcmp
    # check if j is greater than dst string length
    xor     %rax, %rax
    movb    (%rdi), %al
    dec     %rax
    cmpq    %rax, %rcx
    jg      .invalid_ijcmp
    # check if j is greater than src string length
    xor     %rax, %rax
    movb    (%rsi), %al
    dec     %rax
    cmpq    %rax, %rcx
    jg      .invalid_ijcmp
    
    # VALID FROM HERE
    
    # callee save
    pushq   %r14
    pushq   %r15
    
.ijcmp_start:
    # get A[i] adress
    leaq    1(%rdi, %rdx, 1), %r14
    # get A[i] char
    movzx   (%r14), %r14
    
    # get B[i] address
    leaq    1(%rsi, %rdx, 1), %r15
    # get B[i] value
    movzx   (%r15), %r15
    
    # compare A[i] with B[i]
    
    cmpq    %r15, %r14
    
    # case 1 - the chars are the same
    jne     .not_equal_ijcmp
    
    # HERE ITS EQUAL
    
    # i = i+1
    addq    $1, %rdx
    # compare i with j
    cmpq    %rdx, %rcx
    # if i is small or equal to j, continue
    jge     .ijcmp_start
    
    # else, we are done and the cmp is equal
    
    movq    $0, %rax
    jmp     .ijcmp_done
    
    
.not_equal_ijcmp:
    # HERE WE ONLY KNOW ITS NOT EQUAL
    # compare again for flags
    cmpq    %r15, %r14
    
    #if A[i] > B[i]
    jg      .first_greater
    
    # HERE THE SECOND IS GREATER
    xorq    %rax, %rax
    movq    $-1, %rax
    jmp     .ijcmp_done
    
    
.first_greater:
    # HERE THE FIRST STRING IS GREATER
    xorq    %rax, %rax
    movq    $1, %rax
    jmp     .ijcmp_done

.ijcmp_done:
    # restore callee save
    popq    %r15
    popq    %r14
    ret

.invalid_ijcmp:
    # move invalid input string format to printf and reset rax
    movq     $invalid_input, %rdi
    xorq     %rax, %rax
    call     printf
    
    # return -2
    xorq    %rax, %rax
    movq    $-2, %rax
    ret
    
    
    
    
    
    

    
