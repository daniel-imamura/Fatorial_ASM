.MODEL small

.DATA

instrucao       DB 13, 10, 13, 10, 'Digite um numero de 16 bits:', 13, 10, '$'
continuacao     DB 13, 10, 13, 10, 'Digite (S) para continuar', 13, 10, '$'
numero          DW 0
numeroString    BYTE 10 DUP(0),'$'
erro            DB 13, 10, '[ERRO] Valor invalido', 13, 10, '$'


.CODE


pergunta:         
            mov ax,@data    
            mov ds,ax          
            mov dx, OFFSET instrucao   

            mov ah, 9
            int 21h
            
            ; Zera os valores dos registradore
            mov dx, 0                  
            mov numero, 0              
            mov ax, 0
            mov cl, 0
            mov di, 0
            jmp digitacao

erroNaEscrita:          
            mov dx, OFFSET erro  
            mov ah, 9           ; printa mensagem de erro
            int 21h
            jmp pergunta        ; reinicia o programa

digitacao:  
            mov ah, 01h   ; selecionei acao de obter digitacao de um char, sem ENTER
            int 21h                

            cmp al, 13           ; caso seja igual a ENTER 
            je prepararConversao ; termina a digitacao

            cmp al, 8            ; caso seja igual a BACKSPACE
            je backspace         ; pula para tratar o BACKSPACE

            cmp al, 48           ; caso não seja um número
            jb erroNaEscrita     ; printa erro na tela

            cmp al, 57           ; caso não seja um número
            jg erroNaEscrita     ; printa erro na tela
            
    
            sub al, 48           ; pego o valor do número digitado
            mov cl, al           ; passo o valor para cl

            mov ax, numero       ; passo o valor atual de numero para ax                   

            mov bx, 10           ; bx passa a ser 10 para realizar a multiplicação
            mul bx

            mov numero, ax       ; o valor multiplicado de ax passa para numero
            add numero, cx       ; somo o valor do número anterior + o número digitado atual                                              

            inc di               ; incremento no di, para saber a quantidade de caracteres
            jmp digitacao        ; volta para digitar novamente
                                               

backspace:
            mov cx, 10           ; cx passa a ser 10 para realizar a divisão
            mov ax, numero       ; ax recebe o valor do numero digitado 
            div cx               ; ax recebe o valor da divisão, perdendo o último número das unidades
            mov numero, ax       ; o número sem o último caractere é passado para numero
            dec di               ; como perdeu um caractere di é decrementado
              
            mov dx, 0            ; limpa o último caractere digitado
            mov ah, 02h          ; acao de digitar um caractere na tela
            int 21h

            mov dx, 8            ; volta um caractere na tela
            mov ah, 02h          ; ação de digitar um caractere na tela
            int 21h

            mov dx, 0            ; zera dx
                       
            jmp digitacao        ; volta para digitar o próximo valor


prepararConversao:
            mov ax, numero       ; o número finalizado é passado para ax
            dec di               ; di é decrementado pois o valor dele começa em 1, ou seja, ele tem um valor a mais do que o número real de digítos
            mov dx, 0            ; zera dx

conversao:                     
            mov cx, 10           ; cx recebe 10 para divisão
            mov dl, 0            ; dl é zerado
            div cx               ; o resto da divisão vai para dl, que agora possui o último dígito das unidades
            add dl, 48           ; adiciona 48 para voltar para o código ASCII do caractere
            mov byte ptr numeroString[di], dl  ; o caractere é armazenado na última posição do numeroString
            dec di               ; como já foi um caractere, di é decrementado
            cmp ax, 0            ; caso ax seja 0, que ocorre quando não mais digítos
            je printar           ; printa a string pronta
            jne conversao        ; caso ainda não tenha acabado, repete o processo

printar:                
            mov dx, OFFSET numeroString 
            mov ah, 9                    ; printa o valor
            int 21h

            mov dx, OFFSET continuacao
            mov ah, 9                    ; pergunta se deseja continuar 
            int 21h

            mov ah, 01h
            int 21h

            cmp al, 83                   ; caso tenha digitado (S)
            je pergunta                  ; retorna para o começo

            cmp al, 115                  ; caso tenha digitado (s)
            je pergunta                  ; retorna para o começo

            mov ah,4Ch                   ; ação de finalizar o programa
            int 21h
END