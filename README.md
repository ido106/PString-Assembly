# PString library in Assembly
In this task, we will implement *P-String library* in assembly language.  

### Background
*P-String* is a type of string which also holds the size of the string in order to return the size in O(1) time complexity:
```
typedef struct {
      char size;
      char string[255];
} Pstring;
```
We will implement the P-String library functions that will allow working with pstring in a similar way to string.h of C language.  

### Files
The task contains 3 assembly files:  
- ```run_main.s```: A program that contains an implementation of the function run_main  
- ```pstring.s```: The Pstring libarary functions  
- ```func_select.s```: A program that calls the right library function with jump table  
> see "Program structure" for a detailed explanation

### Program structure
The ```run_main``` function receives from the user two strings, their lengths and an option in the menu. Afterward, builds two Pstrings according to the strings and lengths recieved, and sends to run_func the menu option and the addresses of the Pstrings.  
```run_func``` reads the menu option and uses jump table (equivalent to switch-case in C) to call the right libarary function.

### Library functions
##### ```char pstrlen (Pstring* pstr)```  
The function gets a pointer to a Pstring and returns the Pstring length.
##### ```Pstring* replaceChar (Pstring* pstr, char oldChar, char newChar)```  
The function receives a pointer to a Pstring and two chars, replaces every instance of oldChar with newChar, and returns the pointer to pstr.
##### ```Pstring* pstrijcpy (Pstring* dst, Pstring* src, char i, char j)```
The function receives two pointers to Pstring and two chars, copies the substring src[i:j] into dst[i:j], and returns the pointer to dst. If copying is not possible, dst is not changed and the message ```invalid input!``` is printed.
##### ```Pstring* swapCase(Pstring* pstr)```
The function receives a pointer to Pstring, and swaps every uppercase letter into lowercase, and every lowercase letter into uppercase. The string can contain non-letter characters.
##### ```int pstrijcmp (Pstring* pstr1, Pstring* pstr2, char i, char j)```
The function receives two pointers to Pstring, and compare pstr1[i:j] to pstr2[i:j]:
1) returns 1 if pstr1[i:j] is larger than pstr2[i:j] lexicographically
2) returns -1 if pstr2[i:j] is larger than pstr1[i:j] lexicographically
3) returns 0 if pstr1[i:j] and pstr2[i:j] are identical
4) if the comparison is not possible, returns -2 and prints ```invalid input```
