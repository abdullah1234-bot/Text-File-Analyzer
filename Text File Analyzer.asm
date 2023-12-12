; Project Title: Text File Analyzer
; Features:
;   1. Create New File
;   2. Get Word Count
;   3. Word Search
;   4. Delete Word 
;   5. Replace Word

INCLUDE Irvine32.inc

.data
    buffer BYTE 500 DUP(?)
    filename BYTE "output.txt", 0
    filehandle HANDLE ?
    num DWORD ?
    temp BYTE 30 DUP(?)
    tempstr BYTE 500 DUP(?)
    newstr BYTE 30 DUP(?)
    wordcountmsg BYTE "Press 2 to get word count", 0
    searchwordmsg BYTE "Press 3 to search word ", 0
    deletewordmsg BYTE "Press 4 to delete word", 0
    replacewordmsg BYTE "Press 5 to replace word", 0
    quitmsg BYTE "Press 0 to exit the program", 0
    newfilemsg BYTE "Press 1 to create a new file", 0
    readmsg BYTE "Press 6 to Read & Display existing content of the File",0
    resetmsg BYTE "Press 7 to Reset File",0
    promptdoc BYTE "Write new TextFile-Content: ",0
    content BYTE "TextFile-Content: ",0
    replace BYTE "WORD REPLACED",0
    deleted BYTE "WORD DELETED",0
    frequencymsg BYTE "Frequency: ", 0
    prompt BYTE "Enter: ", 0
    msg1 BYTE "Word count: ", 0
    getword BYTE "Enter word: ", 0
    getreplaceword BYTE "Enter new word: ", 0
    notfoundmsg BYTE "Word not found", 0

.code
main PROC
    mov edx, OFFSET newfilemsg
    call WriteString
    call Crlf
    mov edx, OFFSET wordcountmsg
    call WriteString
    call Crlf
    mov edx, OFFSET searchwordmsg
    call WriteString
    call Crlf
    mov edx, OFFSET deletewordmsg
    call WriteString
    call Crlf
    mov edx, OFFSET replacewordmsg
    call WriteString
    call Crlf
    mov edx, OFFSET readmsg
    call WriteString
    call Crlf
    mov edx, OFFSET resetmsg
    call WriteString
    call Crlf
    mov edx, OFFSET quitmsg
    call WriteString
    call Crlf
    mov edx, OFFSET prompt
    call WriteString
    call ReadInt
    cmp eax, 2
    je wordcount
    cmp eax, 3
    je _searchword
    cmp eax, 4
    je _deleteword
    cmp eax, 5
    je _replaceword
    cmp eax, 1
    je _newfile
    cmp eax, 6
    je _readcontent
     cmp eax, 7
    je _resetcontent
    cmp eax, 0
    je _exit
    jmp quit
_exit:
exit
wordcount:
    call read_file
    call countwords
    jmp quit

_searchword:
    call read_file
    call searchword
    jmp quit

_resetcontent:
    call reset
    jmp quit
    
_deleteword:
    call read_file
    call deleteword
    call updatefile
    jmp quit

_replaceword:
    call read_file
    call replaceword
    call updatefile
    jmp quit

_newfile:
    call newfile
    jmp quit

    _readcontent:
    call read_file
    jmp quit
quit:
    call Crlf
    call Crlf
    call main
main ENDP
updatefile PROC
    mov edx, OFFSET filename
    call CreateOutputFile
    mov filehandle, eax
    mov edx, OFFSET buffer
    mov ecx, 490
    call WriteToFile
    mov eax, filehandle
    call CloseFile
    ret
updatefile ENDP

reset PROC
mov edx, OFFSET filename
    call CreateOutputFile
    call CloseFile
    ret
reset ENDP
replaceword PROC
    push ebp
    mov ebp, esp
    sub esp, 20
    mov edx, OFFSET getreplaceword
    call WriteString
    mov edx, OFFSET newstr
    mov ecx, 300
    call ReadString
    mov [ebp - 20], eax
    call searchword
    cmp eax, 0
    je notfound
    mov ebx, OFFSET buffer
    mov ecx, num
    L2:
        inc ebx
        loop L2
    mov [ebp - 16], ebx
    mov ecx, eax
    mov [ebp - 8], OFFSET buffer
    L1:
        push ecx
        push [ebp - 8]
        call findindex
        mov [ebp - 4], esi
        mov [ebp - 8], edi
        mov [ebp - 12], OFFSET buffer
        mov edi, OFFSET tempstr
        cmp esi, OFFSET buffer
        je middle
        dec esi
        mov eax, [ebp - 4]
        sub eax, [ebp - 12]
        mov [ebp - 4], eax
        mov ecx, [ebp - 4]
        mov esi, OFFSET buffer
        rep movsb
    middle:
        mov esi, OFFSET newstr
        mov ecx, [ebp - 20]
        rep movsb
        mov eax, [ebp - 8]
        cmp eax, [ebp - 16]
        je done
        mov eax, [ebp - 16]
        sub eax, [ebp - 8]
        mov ecx, eax
        mov esi, [ebp - 8]
        rep movsb
        mov edx, OFFSET tempstr
        mov edx, LENGTHOF tempstr
        mov num, edx
        mov esi, OFFSET tempstr
        mov edi, OFFSET buffer
        mov ecx, edx
        rep movsb
        pop ecx
    loop L1
done:
    call Crlf
    mov edx, OFFSET replace
    call WriteString
    jmp quit
notfound:
    mov edx, OFFSET notfoundmsg
    call WriteString
quit:
    mov esp, ebp
    pop ebp
    ret
replaceword ENDP

deleteword PROC
    push ebp
    mov ebp, esp
    sub esp, 16
    call searchword
    cmp eax, 0
    je notfound
    mov ebx, OFFSET buffer
    mov ecx, num
    L2:
        inc ebx
        loop L2
    mov [ebp - 16], ebx
    mov ecx, eax
    mov [ebp - 8], OFFSET buffer
    L1:
        push ecx
        push [ebp - 8]
        call findindex
        mov [ebp - 4], esi
        mov [ebp - 8], edi
        mov [ebp - 12], OFFSET buffer
        mov edi, OFFSET tempstr
        cmp esi, OFFSET buffer
        je after
        dec esi
        mov eax, [ebp - 4]
        sub eax, [ebp - 12]
        mov [ebp - 4], eax
        mov ecx, [ebp - 4]
        mov esi, OFFSET buffer
        rep movsb
    after:
        mov eax, [ebp - 8]
        cmp eax, [ebp - 16]
        je done
        mov eax, [ebp - 16]
        sub eax, [ebp - 8]
        mov ecx, eax
        mov esi, [ebp - 8]
        inc esi
        rep movsb
        mov edx, OFFSET tempstr
        mov edx, LENGTHOF tempstr
        mov num, edx
        mov esi, OFFSET tempstr
        mov edi, OFFSET buffer
        mov ecx, edx
        rep movsb
        pop ecx
    loop L1
done:
    call Crlf
    mov edx, OFFSET deleted
    call WriteString
    jmp quit
notfound:
    mov edx, OFFSET notfoundmsg
    call WriteString
quit:
    mov esp, ebp
    pop ebp
    ret
deleteword ENDP

findindex PROC
    push ebp
    mov ebp, esp
    mov edi, OFFSET buffer
    mov dword ptr [ebp - 16], ecx
    mov ecx, num
    L1:
        inc edi
        loop L1
    sub esp, 16
    mov [ebp - 4], edi
    mov edi, [ebp + 8]
    match_first_character:
        mov al, temp[0]
        mov ecx, [ebp - 4]
        sub ecx, edi
        cld
        repne scasb
        jnz quit
        mov [ebp - 12], edi
        dec dword ptr [ebp - 12]
        call compare_substring
        jz found
        cmp byte ptr [edi], 0
        jne match_first_character
        jmp quit

    found:
        mov esi, [ebp - 12]
        mov edi, eax

    quit:
        mov ecx, [ebp - 16]
        mov esp, ebp
        pop ebp
        ret 4
findindex ENDP

searchword PROC
    push ebp
    mov ebp, esp
    mov edx, OFFSET getword
    call WriteString
    mov edx, OFFSET temp
    mov ecx, 20
    call ReadString
    mov edi, OFFSET buffer
    mov ecx, num
    L1:
        inc edi
        loop L1

    sub esp, 12
    mov dword ptr [ebp - 12], 0
    mov [ebp - 4], edi
    mov edi, OFFSET buffer
    match_first_character:
        mov al, temp[0]
        mov ecx, [ebp - 4]
        sub ecx, edi
        cld
        repne scasb
        jnz quit
        call compare_substring
        jz found
        cmp byte ptr [edi], 0
        jne match_first_character
        jmp quit

    found:
        add dword ptr [ebp - 12], 1
        jmp match_first_character

    quit:
        mov edx, OFFSET frequencymsg
        call WriteString
        mov eax, [ebp - 12]
        call WriteDec
        call Crlf
        mov esp, ebp
        pop ebp
        ret
searchword ENDP

compare_substring PROC
    push edi
    mov esi, OFFSET temp
    inc esi
    L1:
        mov al, [esi]
        mov dl, [edi]
        cmp al, 0
        jne L2
        cmp dl, 32
        je L3
        cmp dl, 0
        jmp L3

    L2:
        inc esi
        inc edi
        cmp al, dl
        je L1

    L3:
        mov eax, edi
        pop edi
        ret
compare_substring ENDP

countwords PROC
    push ebp
    mov ebp, esp
    sub esp, 4
    mov dword ptr [ebp - 4], 1
    mov ecx, num
    mov esi, 0
    mov eax, 0
    L1:
        cmp byte ptr [buffer + esi], 32
        jne L2
        add dword ptr [ebp - 4], 1

    L2:
        add esi, 1
        loop L1

    mov edx, OFFSET msg1
    call WriteString
    mov eax, [ebp - 4]
    call WriteDec
    mov esp, ebp
    pop ebp
    ret
countwords ENDP

read_file PROC
    mov edx,OFFSET content
    call WriteString
    mov edx, OFFSET filename
    call OpenInputFile
    mov filehandle, eax

    mov edx, OFFSET buffer
    mov ecx, 500
    mov eax, filehandle
    call ReadFromFile
    jnc valid_file
    jmp quit

valid_file:
    mov num, eax
    mov buffer[eax], 0
    mov edx, OFFSET buffer
    call WriteString
    call Crlf
    mov eax, filehandle
    call CloseFile

quit:
    ret
read_file ENDP

newfile PROC
    mov edx,OFFSET promptdoc
    call WriteString
    mov edx, OFFSET filename
    call CreateOutputFile
    mov filehandle, eax

    mov ecx, 500
    mov edx, OFFSET buffer
    call ReadString
    mov num, eax

    mov eax, filehandle
    mov ecx, num
    call WriteToFile

    mov eax, filehandle
    call CloseFile
    ret
newfile ENDP
END main