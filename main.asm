;****************************************
; Programme Portal
; ---------------------------------------;
;  v 1.1  L. Nicolas  23 Fev 2023
;****************************************

include libgfx.inc
include blocks.inc

pile    segment stack     ; Segment de pile
pile    ends

donnees segment public    ; Segment de donnees

    codeBlock DB 0
    block DW 0

    pX DW 0
    pY DW 0
    retCol DB 0

    posX dw 30
    posY dw 158

    borderLimitLeft DW 30
    borderLimitRight DW 265
    borderLimitBottom DW 160

    portBX DW 10          ; Coordonée X du portail bleu
    portBY DW 10           ; Coordonée Y du portail bleu
    portRX DW 10          ; Coordonée X du portail rouge
    portRY DW 10           ; Coordonée Y du portail rouge
    x DW 0

    jumpMax DW 30
    jumpHeight DW 0

donnees ends

code    segment public    ; Segment de code
assume  cs:code,ds:donnees,es:code,ss:pile

prog:
    mov AX, donnees
	mov DS, AX
    call Video13h
    call draw_sol
    call draw_plafond
    call draw_player

boucle:
    call drawBorder
    call get_userinput
    call teleportation_check
    call teleportation_check_2

    mov tempo, 5
    call sleep
    jmp  boucle

drawBorder:
    mov AX, borderLimitLeft
    mov Rx, AX
    mov Ry, 20
    mov AX, borderLimitRight
    mov Rw, AX
    mov Rh, 160
    mov col, 7
    call Rectangle
    ret

draw_sol:
    mov ax, 170
    mov hY, ax
    mov hX, 30
    loop_draw_sol:
        cmp hX, 290
        je end_loop_draw_sol
        
        mov BX, offset carre
        call drawIcon

        add hX, 10
        jmp loop_draw_sol
    end_loop_draw_sol:
        ret

draw_plafond: 
    mov hY, 21
    mov hX, 30
    loop_draw_plafond:
        cmp hX, 280
        je end_loop_draw_plafond
        
        mov BX, offset carre
        call drawIcon

        add hX, 10
        jmp loop_draw_sol
    end_loop_draw_plafond:
        ret


draw_player:    
    call teleportation_check
    call teleportation_check_2

    mov AX, posX
    mov hX, AX
    mov AX, posY
	mov hY, AX
	mov BX, offset stick
	call drawIcon
    ret

teleportation_check:
    mov ax, [posX]
    cmp ax, portBX
    jne .not_teleport
    
    mov ax, [posY]
    cmp ax, portBY
    jne .not_teleport
    
    mov ax, portRX
    add ax, 10
    mov [posX], ax
    mov ax, portRY
    add ax, 10
    mov [posY], ax

    mov bx, 158
    mov ax, [posY]
    sub bx, ax
    mov jumpHeight, bx
    ;call draw_portal
    call fall_player

teleportation_check_2:
    mov ax, [posX]
    cmp ax, portRX
    jne .not_teleport
    
    mov ax, [posY]
    cmp ax, portRY  
    jne .not_teleport

    mov ax, portBX
    add ax, 10
    mov [posX], ax
    mov ax, portBY
    mov [posY], ax 

    mov bx, 158
    mov ax, [posY]
    sub bx, ax
    mov jumpHeight, bx
    ;call draw_portal
    call fall_player
    
.not_teleport:

get_userinput:
    call PeekKey
    cmp userinput, 'a'
    je end_game
    cmp userinput, 'z'
    je jump_player
    cmp userinput, 'q'
    je deplacer_gauche
    cmp userinput, 'd'
    je deplacer_droite
    cmp userinput, 'f'
    je draw_portal_b
    cmp userinput, 'g'
    je draw_portal_r
    ret

end_game:
    call VideoCMD
    mov AH,4Ch      ; 4Ch = fonction de fin de prog DOS
    mov AL,00h      ; code de sortie 0 (tout s'est bien passe)
    int 21h

deplacer_gauche:
    call clean_player
    sub posX, 2
    mov AX, borderLimitLeft
    call draw_player
    ret

deplacer_droite:
    call clean_player
    add posX, 2
    mov AX, borderLimitRight
    call draw_player
    ret

jump_player:
    call clean_player
    call draw_player
    sub posY, 1
    add jumpHeight, 1
    mov ax, jumpMax
    cmp jumpHeight, ax
    jl jump_player
    cmp jumpHeight, ax
    je fall_player
    ret

draw_portal_b:
    call redraw_pb
	mov BX, offset portBlue
    mov AX, posX
    sub AX, 10
    mov portBX, AX
    mov hX, AX
    mov AX, posY
    sub AX, 10
    mov portBY, AX
	mov hY, AX
	call drawIcon
    ret

draw_portal_r:
    call redraw_pr
	mov BX, offset portRed
    mov AX, posX
    add AX, 10
    mov portRX, AX
    mov hX, AX
    mov AX, posY
    sub AX, 10
    mov portRY, AX
	mov hY, AX
	call drawIcon
    ret

fall_player:
    call clean_player
    call draw_player
    add posY, 1
    sub jumpHeight, 1
    cmp jumpHeight, 0
    jg fall_player
    ret

clean_player:
    mov AX, posX
    mov Rx, AX
    mov AX, posY
    mov Ry, AX
    mov Rw, 12
    mov Rh, 12
    mov col, 0
    call fillRect
    ret

redraw_pr:
    mov AX, portRX
    mov Rx, AX
    mov AX, portRY
    mov Ry, AX
    mov Rw, 12
    mov Rh, 12
    mov col, 0
    call fillRect
    ret

redraw_pb:
    mov AX, portBX
    mov Rx, AX
    mov AX, portBY
    mov Ry, AX
    mov Rw, 12
    mov Rh, 12
    mov col, 0
    call fillRect
    ret

get_color:
    mov ah, 0Dh
    mov CX, pX
    mov DX, pY
    int 10H
    mov retCol, AL
    ret

code    ends               ; Fin du segment de code
end prog                 ; Fin du programme
